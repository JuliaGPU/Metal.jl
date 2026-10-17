# compile a Metal.jl kernel to AIR, for the reflection tests in test/metallib.jl
#
# Usage: julia --project=test res/airr/kernels.jl NAME OUTPUT
#
# test/metallib/Makefile links the AIR of these kernels with Apple's toolchain, which
# derives reflection data from the metadata Metal.jl emits. The kernels cover the kinds of
# arguments Metal.jl kernels have.

using Metal

struct Params
    scale::Float32
    offset::UInt32
    shift::NTuple{2,Float32}
end
struct Outer
    p::Params
    flag::Bool
    h::Float16
end

function vadd(a, b, n)
    i = thread_position_in_grid().x
    if i <= n
        @inbounds a[i] += b[i]
    end
    return
end

# structs passed by reference, and an unused argument
function structs(a, p::Params, o::Outer, unused::Int32)
    i = thread_position_in_grid().x
    @inbounds a[i] = p.scale * a[i] + p.shift[1] + o.p.offset + Float32(o.h) + o.flag
    return
end

# static threadgroup memory, and more built-in arguments
function reduce_groups(out, a)
    shared = MtlThreadGroupArray(Float32, 64)
    tid = thread_position_in_threadgroup().x
    gid = threadgroup_position_in_grid().x
    @inbounds shared[tid] = a[(gid - 1) * threads_per_threadgroup().x + tid]
    threadgroup_barrier(Metal.MemoryFlagThreadGroup)
    if tid == 1
        s = 0f0
        for k in 1:64
            @inbounds s += shared[k]
        end
        @inbounds out[gid] = s + simdgroup_index_in_threadgroup() + thread_index_in_simdgroup()
    end
    return
end

# a pointer, which is passed as a buffer
function pointers(p::Core.LLVMPtr{Float32,1}, x::Float32)
    unsafe_store!(p, x, thread_position_in_grid().x)
    return
end

const kernels = let a = MtlArray(zeros(Float32, 64)), p = Params(1, 2, (3, 4))
    Dict("vadd" => (vadd, (a, a, UInt32(64))),
         "structs" => (structs, (a, p, Outer(p, true, 1), Int32(0))),
         "reduce_groups" => (reduce_groups, (a, a)),
         "pointers" => (pointers, (reinterpret(Core.LLVMPtr{Float32,1}, C_NULL), 1f0)))
end

function main(name, output)
    f, args = kernels[name]
    mktempdir() do dir
        withenv("JULIA_METAL_DUMP_DIR" => dir) do
            @metal launch=false f(args...)
        end
        cp(only(filter(endswith(".air"), readdir(dir; join=true))), output; force=true)
    end
    return
end

main(ARGS...)
