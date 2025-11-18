## random number generation

using Random
import RandomNumbers


# global state

# 16 is the lower bound for `threads_per_simdgroup()`, 1024 is the upper bound
# for `threads_per_threadgroup()`, so we can have 64 simdgroups per threadgroup
const max_simdgroups_per_threadgroup = 64

@inline @generated function emit_global_random_values(::Val{name}) where name
    @dispose ctx=Context() begin
        T_val = convert(LLVMType, UInt32)
        T_ptr = convert(LLVMType, LLVMPtr{UInt32,AS.ThreadGroup})

        # define function and get LLVM module
        llvm_f, _ = create_function(T_ptr)
        mod = LLVM.parent(llvm_f)

        # create a global memory global variable
        T_global = LLVM.ArrayType(T_val, max_simdgroups_per_threadgroup)
        gv = GlobalVariable(mod, T_global, "global_random_$(name)", AS.ThreadGroup)
        linkage!(gv, LLVM.API.LLVMLinkOnceAnyLinkage)
        initializer!(gv, LLVM.null(T_global))
        unnamed_addr!(gv, true)
        alignment!(gv, 4)

        # generate IR
        @dispose builder=IRBuilder() begin
            entry = BasicBlock(llvm_f, "entry")
            position!(builder, entry)

            ptr = gep!(builder, T_global, gv, [ConstantInt(0), ConstantInt(0)])

            untyped_ptr = bitcast!(builder, ptr, T_ptr)

            ret!(builder, untyped_ptr)
        end

        call_function(llvm_f, LLVMPtr{UInt32,AS.ThreadGroup})
    end
end

# shared memory with the actual seed, per simdgroup, loaded lazily or overridden by calling `seed!`
@inline function global_random_keys()
    ptr = emit_global_random_values(Val{:keys}())::LLVMPtr{UInt32,AS.ThreadGroup}
    return MtlDeviceArray{UInt32,1,AS.ThreadGroup}((max_simdgroups_per_threadgroup,), ptr)
end

# shared memory with per-simdgroup counters, incremented when generating numbers
@inline function global_random_counters()
    ptr = emit_global_random_values(Val{:counters}())::LLVMPtr{UInt32,AS.ThreadGroup}
    return MtlDeviceArray{UInt32,1,AS.ThreadGroup}((max_simdgroups_per_threadgroup,), ptr)
end

# initialization function, called automatically at the start of each kernel because
# there's no reliable way to detect uninitialized shared memory (see JuliaGPU/CUDA.jl#2008)
function initialize_rng_state()
    simdgroupId = simdgroup_index_in_threadgroup()

    @inbounds global_random_keys()[simdgroupId] = kernel_state().random_seed
    @inbounds global_random_counters()[simdgroupId] = 0
end

# generators

using Random123: philox2x_round, philox2x_bumpkey

# GPU-compatible/optimized version of the generator from Random123.jl
struct Philox2x32{R} <: RandomNumbers.AbstractRNG{UInt64}
    @inline function Philox2x32{R}() where R
        return new{R}()
    end
end

# default to 7 rounds; enough to pass SmallCrush
@inline Philox2x32() = Philox2x32{7}()

@inline function Base.getproperty(rng::Philox2x32, field::Symbol)
    simdgroupId = simdgroup_index_in_threadgroup()

    if field === :seed
        @inbounds global_random_seed()[1]
    elseif field === :key
        @inbounds global_random_keys()[simdgroupId]
    elseif field === :ctr1
        @inbounds global_random_counters()[simdgroupId]
    elseif field === :ctr2
        globalId = KI.get_global_id().x +
                   (KI.get_global_id().y - 1i32) * KI.get_global_size().x +
                   (KI.get_global_id().z - 1i32) * KI.get_global_size().x * KI.get_global_size().y
        globalId % UInt32
    end::UInt32
end

@inline function Base.setproperty!(rng::Philox2x32, field::Symbol, x)
    simdgroupId = simdgroup_index_in_threadgroup()

    if field === :key
        @inbounds global_random_keys()[simdgroupId] = x
    elseif field === :ctr1
        @inbounds global_random_counters()[simdgroupId] = x
    end
end

@device_override @inline Random.default_rng() = Philox2x32()

"""
    Random.seed!(rng::Philox2x32, seed::Integer, [counter::Integer=0])

Seed the on-device Philox2x32 generator with an UInt32 number.
Should be called by at least one thread per simdgroup.
"""
function Random.seed!(rng::Philox2x32, seed::Integer, counter::Integer=UInt32(0))
    rng.key = seed % UInt32
    rng.ctr1 = counter
    return
end

# seeding the implicit default RNG
@static if VERSION >= v"1.11-"
    @device_override Random.seed!(seed) =
        Random.seed!(Random.default_rng(), seed)
else
    @device_override Random.seed!(::Random._GLOBAL_RNG, seed) =
        Random.seed!(Random.default_rng(), seed)
end

"""
    Random.rand(rng::Philox2x32, UInt32)

Generate a byte of random data using the on-device Philox generator.
"""
function Random.rand(rng::Philox2x32{R},::Type{UInt64}) where {R}
    ctr1, ctr2, key = rng.ctr1, rng.ctr2, rng.key

    if R > 0                               ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 1  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 2  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 3  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 4  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 5  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 6  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 7  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 8  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 9  key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 10 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 11 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 12 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 13 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 14 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end
    if R > 15 key = philox2x_bumpkey(key); ctr1, ctr2 = philox2x_round(ctr1, ctr2, key); end

    # update the simdgroup counter
    # NOTE: this performs the same update on every thread in the simdgroup, but each
    #       simdgroup writes to a unique location so the duplicate writes are innocuous
    # XXX: what if this overflows? we can't increment ctr2. bump the key?
    rng.ctr1 += Int32(1)

    # NOTE: it's too expensive to keep both numbers around in case the user only wanted one,
    #       so just make our 2x32 generator return 64-bit numbers by default.
    return (ctr1 % UInt64) << 32 | (ctr2 % UInt64)
end


# normally distributed

# use the AbstractFloat fallback from Base, which doesn't widen and only relies on `rand()`.
# the Ziggurat method used by other back-ends relies on Float64 support.
@device_override @inline function Random.randn(rng::Philox2x32, ::Type{T}) where {T <: AbstractFloat}
    @invoke Random.randn(rng::AbstractRNG, T::Type{<:AbstractFloat})
end


# exponentially distributed

# use the AbstractFloat fallback from Base, which doesn't widen and only relies on `rand()`.
# the Ziggurat method used by other back-ends relies on Float64 support.
@device_override @inline function Random.randexp(rng::Philox2x32, ::Type{T}) where {T <: AbstractFloat}
    @invoke Random.randexp(rng::AbstractRNG, T::Type{<:AbstractFloat})
end

@device_override Random.Sampler(::Type{<:AbstractRNG}, r::AbstractUnitRange{T},
                                ::Random.Repetition) where {T<:Union{Int64, UInt64}} = Random.SamplerRangeFast(r)
