# GPUToolbox's shared overrides (e.g. `throw_overrides`) throw through this function, with
# the exception type and message as constants; report them like `@gputhrow` does
@device_override @generated function GPUToolbox.Overlays.device_throw(::Type{E}, ::Val{reason}) where {E<:Exception, reason}
    quote
        $(Expr(:meta, :noinline))
        @gputhrow $(String(nameof(E))) $(String(reason))
    end
end

# math.jl
@static if isdefined(Base.Math, :throw_finite_domainerror)
    @device_override @noinline Base.Math.throw_finite_domainerror(f::Symbol, x) =
        @gputhrow "DomainError" "function is only defined for finite x."
end
@device_override @noinline Base.Math.throw_complex_domainerror(f::Symbol, x) =
    @gputhrow "DomainError" "This operation requires a complex input to return a complex result"
@device_override @noinline Base.Math.throw_exp_domainerror(x) =
    @gputhrow "DomainError" "Exponentiation yielding a complex result requires a complex argument"
@device_override function Base.Math.exponent(x::T) where T<:Base.IEEEFloat
    xs = reinterpret(Unsigned, x) & ~Base.sign_mask(T)
    xs >= Base.exponent_mask(T) && @gputhrow "DomainError" "Cannot be NaN or Inf."
    k = Int(xs >> Base.significand_bits(T))
    if k == 0 # x is subnormal
        xs == 0 && @gputhrow "DomainError" "Cannot be ±0.0."
        m = leading_zeros(xs) - Base.exponent_bits(T)
        k = 1 - m
    end
    return k - Base.exponent_bias(T)
end

# checked.jl
@device_override @noinline Base.Checked.throw_overflowerr_binaryop(op, x, y) =
    @gputhrow "OverflowError" "Binary operation overflowed"

# boot.jl
@device_override @noinline Core.throw_inexacterror(f::Symbol, ::Type{T}, val) where {T} =
    @gputhrow "InexactError" "Inexact conversion"

# bool.jl / float.jl
# `Bool(::Real)` and `Bool(::Float16)` don't go through `throw_inexacterror` but construct
# the `InexactError` themselves, through its vararg `@nospecialize` constructor. On the
# device that means boxing the arguments into a heap-allocated tuple on the throwing branch
# (an allocation the optimizer can't remove), so route them through `@gputhrow` instead.
#
# One overlay answers both, because overlays must not shadow one another. When Julia 1.12+
# loads a package image, it only trusts a kernel's edge to an overlay that no more specific
# method of the same table intersects. It verifies other edges against the global method
# table, which doesn't have the overlay, so it drops the kernel and every session compiles
# it again (fixed by JuliaLang/julia#64727).
@device_override function Base.Bool(x::Real)
    x == 0 && return false
    x == 1 && return true
    @gputhrow "InexactError" "Inexact conversion"
end

# abstractarray.jl
# the overrides drop the array, as CUDA.jl's do: passed to a call that isn't inlined, a
# local array that is indexed with bounds checks (e.g. an `MVector`) escapes, and is then
# allocated on the device heap instead of the stack
@device_function @noinline throw_boundserror() =
    @gputhrow "BoundsError" "Out-of-bounds array access"
@device_override @inline Base.throw_boundserror(A, I) = throw_boundserror()

# essentials.jl
# Julia 1.14 routes indexed bounds errors through `_throw_boundserror_indices`
# rather than `throw_boundserror`, bypassing the override above.
@static if isdefined(Base, :_throw_boundserror_indices)
    @device_override @inline Base._throw_boundserror_indices(A) = throw_boundserror()
    @device_override @inline Base._throw_boundserror_indices(A, i1, I...) = throw_boundserror()
end

# trig.jl
@static if isdefined(Base.Math, :sincos_domain_error)
    @device_override @noinline Base.Math.sincos_domain_error(x) =
        @gputhrow "DomainError" "sincos(x) is only defined for finite x."
end

# diagonal.jl
# XXX: remove when we have malloc
import LinearAlgebra
@device_override function Base.setindex!(D::LinearAlgebra.Diagonal, v, i::Int, j::Int)
    @boundscheck checkbounds(D, i, j)
    if i == j
        @inbounds D.diag[i] = v
    elseif !iszero(v)
        @gputhrow "ArgumentError" "cannot set off-diagonal entry to a nonzero value"
    end
    return v
end

# number.jl
# XXX: remove when we have malloc
@device_override @inline function Base.getindex(x::Number, I::Integer...)
    @boundscheck all(isone, I) ||
        @gputhrow "BoundsError" "Out-of-bounds access of scalar value"
    x
end

# complex.jl
@device_override function Base.ssqs(x::T, y::T) where T<:Real
    k::Int = 0
    ρ = x*x + y*y
    if !isfinite(ρ) && (isinf(x) || isinf(y))
        ρ = convert(T, Inf)
    elseif isinf(ρ) || (ρ==0 && (x!=0 || y!=0)) || ρ<nextfloat(zero(T))/(2*eps(T)^2)
        m::T = max(abs(x), abs(y))
        k = m==0 ? 0 : exponent(m)
        xk, yk = ldexp(x,-k), ldexp(y,-k)
        ρ = xk*xk + yk*yk
    end
    ρ, k
end

@static if VERSION >= v"1.12.0-DEV.1736" # Partially reverts JuliaLang/julia PR #56750
    let BitInteger64 = Union{Int64,UInt64}
        @device_override function Base.checkbounds(::Type{Bool}, v::StepRange{<:BitInteger64, <:BitInteger64}, i::BitInteger64)
            @inline
            return checkindex(Bool, eachindex(IndexLinear(), v), i)
        end
    end
end
