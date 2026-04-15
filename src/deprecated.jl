export current_device

@deprecate current_device() device()

# RNG renames: the old `Metal.RNG` (kernel-based) is now `Metal.KernelRNG`,
# and `Metal.RNG` is an alias for `GPUArrays.RNG{MtlArray}`.
@deprecate mtl_rng() default_rng() false
@deprecate mpsrand_rng() mps_rng() false
@deprecate gpuarrays_rng() default_rng() false
