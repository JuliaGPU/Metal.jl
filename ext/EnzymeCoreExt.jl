module EnzymeCoreExt

using Metal
import Metal: mtlconvert, mtlfunction

using EnzymeCore
using EnzymeCore.EnzymeRules
using GPUArrays

include("meta_kernels.jl")

# Inactive: these device-state accessors are data-independent (ObjC queue, task-local storage).
function EnzymeCore.EnzymeRules.inactive_noinl(::typeof(Metal.synchronize), args...)
    return nothing
end
function EnzymeCore.EnzymeRules.inactive_noinl(::typeof(Metal.device), args...)
    return nothing
end
function EnzymeCore.EnzymeRules.inactive_noinl(::typeof(Metal.global_queue), args...)
    return nothing
end

## mtlfunction

function EnzymeCore.EnzymeRules.forward(config, ofn::Const{typeof(mtlfunction)},
                                        ::Type{<:Duplicated}, f::Const{F}, tt::Const{TT}; kwargs...) where {F,TT}
    res = ofn.val(f.val, tt.val; kwargs...)
    return Duplicated(res, res)
end

function EnzymeCore.EnzymeRules.forward(config, ofn::Const{typeof(mtlfunction)},
                                        ::Type{BatchDuplicated{T,N}}, f::Const{F}, tt::Const{TT}; kwargs...) where {F,TT,T,N}
    res = ofn.val(f.val, tt.val; kwargs...)
    return BatchDuplicated(res, ntuple(_ -> res, Val(N)))
end

function EnzymeCore.EnzymeRules.augmented_primal(config, ofn::Const{typeof(mtlfunction)},
                                        ::Type{RT}, f::Const{F}, tt::Const{TT}; kwargs...) where {F, CT, RT<:EnzymeCore.Annotation{CT}, TT}
    res = ofn.val(f.val, tt.val; kwargs...)
    primal = EnzymeRules.needs_primal(config) ? res : nothing
    shadow = if EnzymeRules.needs_shadow(config)
        EnzymeRules.width(config) == 1 ? res : ntuple(_ -> res, Val(EnzymeRules.width(config)))
    else
        nothing
    end
    return EnzymeRules.AugmentedReturn{EnzymeRules.primal_type(config, RT), EnzymeRules.shadow_type(config, RT), Nothing}(primal, shadow, nothing)
end

function EnzymeCore.EnzymeRules.reverse(config, ofn::Const{typeof(mtlfunction)}, ::Type{RT}, subtape, f, tt; kwargs...) where {RT}
    return (nothing, nothing)
end

## mtlconvert

function EnzymeCore.EnzymeRules.forward(config, ofn::Const{typeof(mtlconvert)}, ::Type{RT}, x::IT) where {RT, IT}
    if EnzymeRules.needs_primal(config) && EnzymeRules.needs_shadow(config)
        if EnzymeRules.width(config) == 1
            Duplicated(ofn.val(x.val), ofn.val(x.dval))
        else
            BatchDuplicated(ofn.val(x.val), ntuple(i -> ofn.val(x.dval[i])::eltype(RT), Val(EnzymeRules.width(config))))
        end
    elseif EnzymeRules.needs_shadow(config)
        if EnzymeRules.width(config) == 1
            ofn.val(x.dval)::EnzymeCore.shadow_type(config, RT)
        else
            (ntuple(i -> ofn.val(x.dval[i])::eltype(RT), Val(EnzymeRules.width(config))))::EnzymeCore.shadow_type(config, RT)
        end
    elseif EnzymeRules.needs_primal(config)
        ofn.val(x.val)::eltype(RT)
    else
        nothing
    end
end

function EnzymeCore.EnzymeRules.augmented_primal(config, ofn::Const{typeof(mtlconvert)}, ::Type{RT}, x::IT) where {RT, IT}
    primal = EnzymeRules.needs_primal(config) ? ofn.val(x.val) : nothing
    shadow = if EnzymeRules.needs_shadow(config)
        EnzymeRules.width(config) == 1 ? ofn.val(x.dval) :
            ntuple(i -> ofn.val(x.dval[i]), Val(EnzymeRules.width(config)))
    else
        nothing
    end
    return EnzymeRules.AugmentedReturn{EnzymeRules.primal_type(config, RT), EnzymeRules.shadow_type(config, RT), Nothing}(primal, shadow, nothing)
end

function EnzymeCore.EnzymeRules.reverse(config, ofn::Const{typeof(mtlconvert)}, ::Type{RT}, tape, x::IT) where {RT, IT}
    return (nothing,)
end

## MtlArray constructors

function EnzymeCore.EnzymeRules.forward(config, ofn::Const{Type{AT}},
        ::Type{RT}, uval::EnzymeCore.Annotation{UndefInitializer}, args...) where {AT <: MtlArray, RT}
    primargs = ntuple(i -> args[i].val, Val(length(args)))
    if EnzymeRules.needs_primal(config) && EnzymeRules.needs_shadow(config)
        if EnzymeRules.width(config) == 1
            shadow = ofn.val(uval.val, primargs...)::AT
            fill!(shadow, 0)
            Duplicated(ofn.val(uval.val, primargs...), shadow)
        else
            tup = ntuple(Val(EnzymeRules.width(config))) do i
                Base.@_inline_meta
                shadow = ofn.val(uval.val, primargs...)::AT
                fill!(shadow, 0)
                shadow::AT
            end
            BatchDuplicated(ofn.val(uval.val, primargs...), tup)
        end
    elseif EnzymeRules.needs_shadow(config)
        if EnzymeRules.width(config) == 1
            shadow = ofn.val(uval.val, primargs...)::AT
            fill!(shadow, 0)
            shadow::EnzymeCore.shadow_type(config, RT)
        else
            tup = ntuple(Val(EnzymeRules.width(config))) do i
                Base.@_inline_meta
                shadow = ofn.val(uval.val, primargs...)::AT
                fill!(shadow, 0)
                shadow::AT
            end
            tup::EnzymeCore.shadow_type(config, RT)
        end
    elseif EnzymeRules.needs_primal(config)
        ofn.val(uval.val, primargs...)
    else
        nothing
    end
end

## make_zero / make_zero!

@inline function EnzymeCore.make_zero(
    x::MtlArray{FT},
) where {FT<:AbstractFloat}
    return Base.zero(x)
end
@inline function EnzymeCore.make_zero(
    x::MtlArray{Complex{FT}},
) where {FT<:AbstractFloat}
    return Base.zero(x)
end

@inline function EnzymeCore.make_zero(
    ::Type{CT},
    seen::IdDict,
    prev::CT,
    ::Val{copy_if_inactive} = Val(false),
)::CT where {copy_if_inactive, FT<:AbstractFloat, CT <: Union{MtlArray{FT},MtlArray{Complex{FT}}}}
    if haskey(seen, prev)
        return seen[prev]
    end
    newa = Base.zero(prev)
    seen[prev] = newa
    return newa
end

@inline function EnzymeCore.make_zero!(
    prev::MtlArray{FT},
    seen::ST,
)::Nothing where {FT<:AbstractFloat,ST}
    if !isnothing(seen)
        if prev in seen
            return nothing
        end
        push!(seen, prev)
    end
    fill!(prev, zero(FT))
    return nothing
end

@inline function EnzymeCore.make_zero!(
    prev::MtlArray{Complex{FT}},
    seen::ST,
)::Nothing where {FT<:AbstractFloat,ST}
    if !isnothing(seen)
        if prev in seen
            return nothing
        end
        push!(seen, prev)
    end
    fill!(prev, zero(Complex{FT}))
    return nothing
end

## GPUArrays.mapreducedim!

function EnzymeCore.EnzymeRules.forward(config, ofn::Const{typeof(GPUArrays.mapreducedim!)},
                                        ::Type{RT},
                                        f::EnzymeCore.Const{typeof(Base.identity)},
                                        op::EnzymeCore.Const{typeof(Base.add_sum)},
                                        R::EnzymeCore.Annotation{<:MtlArray{T}}, A; init) where {RT, T}
    if R isa Const || R isa Duplicated || R isa BatchDuplicated
        ofn.val(f.val, op.val, R.val, A.val; init)
    end

    if A isa Duplicated || A isa DuplicatedNoNeed
        if A isa Const
            Base.fill!(R.dval, zero(T))
        else
            ofn.val(f.val, op.val, R.dval, A.dval)
        end
    elseif R isa BatchDuplicated || R isa BatchDuplicatedNoNeed
        ntuple(Val(EnzymeRules.batch_width(R))) do i
            Base.@_inline_meta
            if A isa Const
                Base.fill!(R.dval[i], zero(T))
            else
                ofn.val(f.val, op.val, R.dval[i], A.dval[i])
            end
            nothing
        end
    end

    if EnzymeRules.needs_primal(config) && EnzymeRules.needs_shadow(config)
        R
    elseif EnzymeRules.needs_shadow(config)
        R.dval
    elseif EnzymeRules.needs_primal(config)
        R.val
    else
        nothing
    end
end

function EnzymeCore.EnzymeRules.augmented_primal(config, ofn::Const{typeof(GPUArrays.mapreducedim!)},
                                        ::Type{RT},
                                        f::EnzymeCore.Const{typeof(Base.identity)},
                                        op::EnzymeCore.Const{typeof(Base.add_sum)},
                                        R::EnzymeCore.Annotation{<:MtlArray{T}}, A; init) where {RT, T<:AbstractFloat}
    if A isa Const || A isa Duplicated || A isa BatchDuplicated
        ofn.val(f.val, op.val, R.val, A.val)
    end

    primal = if EnzymeRules.needs_primal(config)
        R.val
    else
        nothing
    end

    shadow = if EnzymeRules.needs_shadow(config)
        R.dval
    else
        nothing
    end
    return EnzymeRules.AugmentedReturn(primal, shadow, nothing)
end

function EnzymeCore.EnzymeRules.reverse(config, ofn::Const{typeof(GPUArrays.mapreducedim!)},
                                        ::Type{RT},
                                        tape,
                                        f::EnzymeCore.Const{typeof(Base.identity)},
                                        op::EnzymeCore.Const{typeof(Base.add_sum)},
                                        R::EnzymeCore.Annotation{<:MtlArray{T}}, A; init) where {RT, T<:AbstractFloat}

    if !(A isa Const) && !(R isa Const)
        if A isa Duplicated || A isa DuplicatedNoNeed
            A.dval .+= R.dval
            Base.fill!(R.dval, zero(T))
        elseif A isa BatchDuplicated || A isa BatchDuplicatedNoNeed
            ntuple(Val(EnzymeRules.batch_width(A))) do i
                Base.@_inline_meta
                A.dval[i] .+= R.dval[i]
                Base.fill!(R.dval[i], zero(T))
                nothing
            end
        end
    end

    return (nothing, nothing, nothing, nothing)
end

## GPUArrays._mapreduce

function EnzymeCore.EnzymeRules.forward(config, ofn::Const{typeof(GPUArrays._mapreduce)},
                                        ::Type{RT},
                                        f::EnzymeCore.Const{typeof(Base.identity)},
                                        op::EnzymeCore.Const{typeof(Base.add_sum)},
                                        A::EnzymeCore.Annotation{<:MtlArray{T}}; dims::D, init) where {RT, T, D}

    if EnzymeRules.needs_primal(config) && EnzymeRules.needs_shadow(config)
        if EnzymeRules.width(config) == 1
            shadow = ofn.val(f.val, op.val, A.dval; dims, init)
            Duplicated(ofn.val(f.val, op.val, A.val; dims, init), shadow)
        else
            tup = ntuple(Val(EnzymeRules.batch_width(RT))) do i
                Base.@_inline_meta
                ofn.val(f.val, op.val, A.dval[i]; dims, init)
            end
            BatchDuplicated(ofn.val(f.val, op.val, A.val; dims, init), tup)
        end
    elseif EnzymeRules.needs_shadow(config)
        if EnzymeRules.width(config) == 1
            ofn.val(f.val, op.val, A.dval; dims, init)
        else
            ntuple(Val(EnzymeRules.batch_width(RT))) do i
                Base.@_inline_meta
                ofn.val(f.val, op.val, A.dval[i]; dims, init)
            end
        end
    elseif EnzymeRules.needs_primal(config)
        ofn.val(f.val, op.val, A.val; dims, init)
    else
        nothing
    end
end

function EnzymeCore.EnzymeRules.augmented_primal(config, ofn::Const{typeof(GPUArrays._mapreduce)},
                                                ::Type{Active{RT}},
                                        f::EnzymeCore.Const{typeof(Base.identity)},
                                        op::EnzymeCore.Const{typeof(Base.add_sum)},
                                        A::EnzymeCore.Annotation{<:MtlArray{T}}; dims::D, init) where {RT, T<:AbstractFloat, D}
    primal = if EnzymeRules.needs_primal(config)
        ofn.val(f.val, op.val, A.val; dims, init)
    else
        nothing
    end

    shadow = if EnzymeRules.needs_shadow(config)
        A.dval
    else
        nothing
    end
    return EnzymeRules.AugmentedReturn(primal, shadow, nothing)
end

function EnzymeCore.EnzymeRules.reverse(config, ofn::Const{typeof(GPUArrays._mapreduce)},
                                        dres::Active{RT},
                                        tape,
                                        f::EnzymeCore.Const{typeof(Base.identity)},
                                        op::EnzymeCore.Const{typeof(Base.add_sum)},
                                        A::EnzymeCore.Annotation{<:MtlArray{T}}; dims::D, init) where {RT, T<:AbstractFloat, D}

    if A isa Duplicated || A isa DuplicatedNoNeed
        A.dval .+= dres.val
    elseif A isa BatchDuplicated || A isa BatchDuplicatedNoNeed
        ntuple(Val(EnzymeRules.batch_width(A))) do i
            Base.@_inline_meta
            A.dval[i] .+= dres.val
            nothing
        end
    end

    return (nothing, nothing, nothing)
end

## HostKernel launch rules: differentiate the launch via device-side autodiff (meta_kernels.jl).

# tape_type needs a GPU parent job; only its backend is used.
function EnzymeCore.compiler_job_from_backend(::Metal.MetalBackend, @nospecialize(F::Type), @nospecialize(TT::Type))
    mi = Metal.GPUCompiler.methodinstance(F, TT)
    return Metal.GPUCompiler.CompilerJob(mi, Metal.compiler_config(Metal.device()))
end

launch_extent(x::Integer) = Int(x)
launch_extent(x::NTuple{N, Integer}) where {N} = prod(Int, x)

function EnzymeCore.EnzymeRules.forward(config, ofn::EnzymeCore.Annotation{Metal.HostKernel{F, TT}},
                                        ::Type{Const{Nothing}}, args...;
                                        groups = 1, threads = 1, kwargs...) where {F, TT}
    GC.@preserve args begin
        dargs = ((mtlconvert(a) for a in args)...,)
        TT2 = Tuple{typeof(config), F, map(typeof, dargs)...}
        kernel = mtlfunction(metaf, TT2)
        kernel(config, ofn.val.f, dargs...; groups, threads, kwargs...)
    end
    return nothing
end

function EnzymeCore.EnzymeRules.augmented_primal(config, ofn::EnzymeCore.Annotation{Metal.HostKernel{F, TT}},
                                        ::Type{Const{Nothing}}, args0...;
                                        groups = 1, threads = 1, kwargs...) where {F, TT}
    args = ((mtlconvert(a) for a in args0)...,)
    TapeType = EnzymeCore.tape_type(
        EnzymeCore.compiler_job_from_backend(Metal.MetalBackend(), typeof(Base.identity), Tuple{Float32}),
        ReverseSplitModified(EnzymeCore.set_runtime_activity(ReverseSplitWithPrimal, config), Val(EnzymeRules.overwritten(config))),
        Const{F},
        Const{Nothing},
        map(typeof, args)...,
    )
    n = launch_extent(threads) * launch_extent(groups)
    subtape = Metal.MtlArray{TapeType}(undef, n)

    GC.@preserve args subtape begin
        subtape2 = mtlconvert(subtape)
        TT2 = Tuple{typeof(config), F, typeof(subtape2), map(typeof, args)...}
        kernel = mtlfunction(meta_augf, TT2)
        kernel(config, ofn.val.f, subtape2, args...; groups, threads, kwargs...)
    end

    return EnzymeRules.AugmentedReturn{Nothing, Nothing, Metal.MtlArray}(nothing, nothing, subtape)
end

function EnzymeCore.EnzymeRules.reverse(config, ofn::EnzymeCore.Annotation{Metal.HostKernel{F, TT}},
                                        ::Type{Const{Nothing}}, subtape, args0...;
                                        groups = 1, threads = 1, kwargs...) where {F, TT}
    args = ((mtlconvert(a) for a in args0)...,)
    GC.@preserve args0 subtape begin
        subtape2 = mtlconvert(subtape)
        TT2 = Tuple{typeof(config), F, typeof(subtape2), map(typeof, args)...}
        kernel = mtlfunction(meta_revf, TT2)
        kernel(config, ofn.val.f, subtape2, args...; groups, threads, kwargs...)
    end
    return ntuple(Returns(nothing), Val(length(args0)))
end

end # module EnzymeCoreExt
