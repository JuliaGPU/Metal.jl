## accessors for the Metal and AIR version, and the targeted GPU family

export metal_version, air_version, apple_family, @sv_str

for var in ["metal_major", "metal_minor", "air_major", "air_minor", "apple_family"]
    @eval @device_function @inline $(Symbol(var))() =
        Base.llvmcall(
            $("""@$var = external global i32
                 define i32 @entry() #0 {
                     %val = load i32, i32* @$var
                     ret i32 %val
                 }
                 attributes #0 = { alwaysinline }
            """, "entry"), UInt32, Tuple{})
end

@device_function @inline metal_version() = SimpleVersion(metal_major(), metal_minor())

"""
    metal_version()

Return the Metal Shading Language version that the kernel is compiled for, as a version
that compares with `sv"..."` literals. This is a compile-time constant, so a branch on it
is resolved during compilation and can guard code that needs a newer version:

```julia
if metal_version() >= sv"4.1"
    # use functionality that needs MSL 4.1
end
```

The version defaults to the newest the host supports (see [`Metal.metal_target`](@ref)),
and can be chosen with the `metal` keyword of [`@metal`](@ref). Only use this in kernels.
"""
metal_version

@device_function @inline air_version() = SimpleVersion(air_major(), air_minor())

"""
    air_version()

Return the AIR version that the kernel is compiled for, as a version that compares with
`sv"..."` literals. Like [`metal_version`](@ref), this is a compile-time constant. Only use
this in kernels.
"""
air_version

"""
    apple_family()

Return the `n` of the highest `MTLGPUFamilyApple<n>` that the kernel is compiled for (e.g.,
7 for M1, 8 for M2, 9 for M3 and M4, 10 for M5), or `0` if the device reports no Apple
family. Like [`metal_version`](@ref), this is a compile-time constant that can guard
family-specific code. Only use this in kernels.
"""
apple_family
