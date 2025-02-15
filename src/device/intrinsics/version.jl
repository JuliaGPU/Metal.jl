## accessors for the Metal and AIR version

export metal_version, air_version

for var in ["metal_major", "metal_minor", "air_major", "air_minor"]
    @eval @inline $(Symbol(var))() =
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
@device_function @inline air_version() = SimpleVersion(air_major(), air_minor())
