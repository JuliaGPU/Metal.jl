# Frequently Asked Questions

## Can you wrap this Metal API?

Most likely. Any help on designing or implementing high-level wrappers for MSL's low-level functionality
is greatly appreciated, so please consider [contributing](contributing.md) your uses of these APIs on the
respective repositories.

## Why do Float32 subnormals become zero on the GPU?

On Apple GPUs, `Float32` arithmetic flushes subnormal operands and results to zero.
Comparisons also treat subnormal operands as zero, so `iszero(x)` and `x == 0` can be true
for a nonzero value stored in memory. Multiplying a subnormal input by a power of two
therefore does not recover its value.

The [Metal Shading Language specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf)
(section 8.1) permits flushing subnormals to zero, including for `Float16`; code should not
assume that disabling fast math preserves them. Algorithms that need to handle subnormal
inputs, such as `cbrt`, can normalize their bit patterns using integer operations before
performing floating-point arithmetic.
