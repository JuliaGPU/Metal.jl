# Async warmup to reduce first-kernel JIT compilation latency
#
# The first GPU kernel in a Metal.jl session takes ~1.75s due to one-time JIT
# compilation of GPUCompiler internals. By starting a minimal kernel compilation
# in the background during __init__(), we can reduce this to 0.035-0.20s for the
# user's first actual kernel—a 9-50x improvement.

export warmup

# Minimal kernel that triggers the full compilation pipeline
function _warmup_kernel!(a)
    i = thread_position_in_grid().x
    if i <= length(a)
        a[i] = 0.0f0
    end
    return nothing
end

# Called from __init__() via @async
function _warmup_compilation()
    try
        # Minimal allocation - just need to trigger compilation
        arr = MtlArray{Float32}(undef, 1)
        # launch=false compiles but doesn't execute - fastest warmup path
        @metal launch = false _warmup_kernel!(arr)
        unsafe_free!(arr)
    catch
        # Silently ignore warmup failures - this is a non-critical optimization
    end
    return nothing
end

"""
    warmup(; blocking::Bool=true)

Ensure the GPU compilation pipeline is warmed up.

The first GPU kernel in a Metal.jl session incurs a one-time JIT compilation overhead
of ~1.7 seconds. Metal.jl automatically starts warming up in the background when the
package is loaded. This function allows you to explicitly wait for warmup to complete.

If `blocking=true` (default), waits for warmup to complete before returning.
If `blocking=false`, returns immediately while warmup continues in background.

# When to use

Call `warmup()` before timing-sensitive code to ensure consistent benchmark results:

```julia
using Metal
Metal.warmup()  # wait for warmup to complete
@time @metal kernel!(a)  # consistently fast (~0.035s, not ~1.7s)
```

# Note

You never need to call this function for correctness—only for consistent timing.
Most users will never need to call this explicitly, as the background warmup will
complete during normal program setup (loading data, preprocessing, etc.).
"""
function warmup(; blocking::Bool = true)
    task = _warmup_task[]
    if task === nothing
        # Warmup wasn't started (non-functional GPU or disabled)
        return nothing
    end
    if blocking
        wait(task)
    end
    return nothing
end
