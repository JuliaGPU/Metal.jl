# Contributing

Metal.jl is an especially accessible GPU backend with the presence of GPUs on Apple's recent
popular Macbooks. As a result, an average Julia user can now develop and test
GPU-accelerated code locally on their laptop. If you're using this package and see a bug or
want some additional functionality, this page is for you. Hopefully this information helps
encourage you to contribute to the package yourself.


## What needs help?

If you didn't come to this page with your own feature to add, look at the current issues in
the [git repo](https://github.com/JuliaGPU/Metal.jl/issues) for bugs and requested
functionality.


## I'm a beginner, can I help?

Yes, but you may spend more time learning rather than directly contributing at the start.
Depending on what your goals are though, this might be desirable. There are differing
levels of difficulty when considering contributions to Metal.jl. If you're new to these
things, check the issues for "Good First Issue" tags, look at the documentation for areas
that could be added (beginners are especially good at detecting these sort of deficiencies),
or message on the Slack #gpu channel asking for guidance.

Regardless, if you've never used Metal.jl before, it'd probably be best to gain some
exposure to it before trying to contibute. You might run into bugs yourself or discover some
area you'd really like to help with.

## General Workflow for Adding Functionality

If you're adding some functionality that originates from Metal Shading Language (MSL)
directly (rather than high-level Julia functionality), the workflow will likely look like
the below. If you're adding something that only relies on pure Julia additions, you will
skip the first two steps.

1. Create low-level, Julia wrappers for the Obj-C interface
2. Create high-level Julia structures and functionality
3. Create tests for added functionality

Objective-C object definitions, `struct`s, and `enums` for Objective-C interfaces are automatically generated (see res/wrap/),
so you should not have to define them. If using a struct for the first time in a higher-level
interface, remember to add tests! Objective-C object methods and constructors are not yet automtically
generatied, so any contributions there are welcome.

It is also recommended to follow [these steps](https://github.com/fredrikekre/Runic.jl?tab=readme-ov-file#ignore-formatting-commits-in-git-blame) from the Runic.jl documentation
in your local development repository so that formatting commits are ignored in blame.

## Mapping to Metal Intrinsics

Some Metal functions map directly to Apple intermediate representation intrinsics. In this
case, wrapping them into Metal.jl is relatively easy. All that needs to be done is to create
a mapping from a Julia function via a simple ccall. See the
[threadgroup barrier implementation](https://github.com/JuliaGPU/Metal.jl/blob/main/src/device/intrinsics/synchronization.jl#L43-L44) for
reference.

However, the Metal documentation doesn't tell you what the format of the intrinsic names
should be. To find this out, you need to create your own test kernel directly in the Metal
Shading Language, compile it using Apple's tooling, then view the created intermediate
representation (IR).

## Reverse-Engineering Bare MSL/Apple IR

First, you need to write an MSL kernel that uses the functionality you're interested in.
For example,

```objective-c
#include <metal_stdlib>

using namespace metal;

kernel void dummy_kernel(device volatile atomic_float* out,
                        uint i [[thread_position_in_grid]])
{
    atomic_store_explicit(&out[i], 0.0f, memory_order_relaxed);
}
```

To compile with Metal's tools and emit human-readable IR, run something roughly along the
lines of: `xcrun metal -S -emit-llvm dummy_kernel.metal`

This will create a `.ll` file that you can then parse for whatever information you need.
Be sure to double-check the metadata at the bottom for any significant changes your
functionality introduces.

Test with different types and configurations to see what changes are caused. Also
ensure that when writing very simple kernels, whatever you're interested in doesn't get
optimized away. Double-check that the kernel's IR makes sense for what you wrote.

## Metal Performance Shaders

Metal exposes a special interface to its library of optimized kernels. Rather than accepting
the normal set of input GPU data structures, it requires special `MPS` datatypes that assume
row-major memory layout. As this is not the Julia default, adapt accordingly. Adding MPS
functionality should be mostly straightforward, so this can be an easy entry point to helping.
To get started, you can have a look at the [Metal Performance Shaders
Documentation](https://developer.apple.com/documentation/metalperformanceshaders?language=objc)
from Apple.

## Exposing your Interface

There are varying degrees of user-facing interfaces from Metal.jl. At the lowest level is
`Metal.MTL.xxx`. This is for low-level functionality close to or at bare Objective-C, or things
that a normal user wouldn't directly be using. `Metal.MPS.xxx` is for Metal Performance Shader
specifics (like `MPSMatrix`).
Next, is `Metal.xxx`. This is for higher-level, usually pure-Julian functionality (like `device()`).
The only thing beyond this is exporting into the global namespace. That would be useful for uniquely-named
functions/structures/macros with clear and common use-cases (`MtlArray` or `@metal`).

Additionally, you can override non-Metal.jl functions like `LinearAlgebra.mul!` seen
[here](https://github.com/JuliaGPU/Metal.jl/blob/main/lib/mps/linalg.jl#L34). This is essentially (ab)using multiple dispatch to
specialize for certain cases (usually for more performant execution).

If your function is only available from within GPU kernels (like thread indexing intrinsics).
Be sure to properly annotate with `@device_function` to ensure that calling from the host
doesn't kill your Julia process.

Generally, think about how frequently you expect your addition to be used, how complex
its use-case is, and whether or not it clashes/reimplements/optimizes existing functionality
from outside Metal.jl. Put it behind the corresponding interface.

## Creating Tests

As it's good practice, and JuliaGPU has great CI/CD workflows, your addition should have
associated tests to ensure correctness and edge cases. Look to existing examples under the
`test` folder for initial guidance, and be sure to create tests for all valid types. Any
new Julia file in this folder will be ran as its own testset. If you feel your tests don't
fit in any existing place, you'll probably want to create a new file with an appropriate name.

## Running a Subset of the Existing Tests

Sometimes you won't want to run the entire testsuite. You may just want to run the tests
for your new functionality. To do that, you can either pass the name of the testset to the
`test/runtests.jl` script: `julia --project=test test/runtests.jl metal` or you can isolate test
files by running them alone after running the `test/setup.jl` script:
`julia --project=test -L test/setup.jl test/metal.jl`

## Thank You and Good Luck

Open-source projects like this only happen because people like you are willing to spend
their free time helping out. Most anything you're able to do is helpful, but if you get
stuck, seek guidance from Slack or Discourse. Don't feel like your contribution has to be
perfect. If you put in effort and make progress, there will likely be some senior developer
willing to polish your code before merging. Open-source software is a team effort...welcome
to the team!
