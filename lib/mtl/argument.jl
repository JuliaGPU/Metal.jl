@cenum MTLDataType::NSUInteger begin
    MTLDataTypeNone = 0

    MTLDataTypeStruct = 1
    MTLDataTypeArray = 2

    MTLDataTypeFloat = 3
    MTLDataTypeFloat2 = 4
    MTLDataTypeFloat3 = 5
    MTLDataTypeFloat4 = 6

    MTLDataTypeFloat2x2 = 7
    MTLDataTypeFloat2x3 = 8
    MTLDataTypeFloat2x4 = 9

    MTLDataTypeFloat3x2 = 10
    MTLDataTypeFloat3x3 = 11
    MTLDataTypeFloat3x4 = 12

    MTLDataTypeFloat4x2 = 13
    MTLDataTypeFloat4x3 = 14
    MTLDataTypeFloat4x4 = 15

    MTLDataTypeHalf = 16
    MTLDataTypeHalf2 = 17
    MTLDataTypeHalf3 = 18
    MTLDataTypeHalf4 = 19

    MTLDataTypeHalf2x2 = 20
    MTLDataTypeHalf2x3 = 21
    MTLDataTypeHalf2x4 = 22

    MTLDataTypeHalf3x2 = 23
    MTLDataTypeHalf3x3 = 24
    MTLDataTypeHalf3x4 = 25

    MTLDataTypeHalf4x2 = 26
    MTLDataTypeHalf4x3 = 27
    MTLDataTypeHalf4x4 = 28

    MTLDataTypeInt = 29
    MTLDataTypeInt2 = 30
    MTLDataTypeInt3 = 31
    MTLDataTypeInt4 = 32

    MTLDataTypeUInt = 33
    MTLDataTypeUInt2 = 34
    MTLDataTypeUInt3 = 35
    MTLDataTypeUInt4 = 36

    MTLDataTypeShort = 37
    MTLDataTypeShort2 = 38
    MTLDataTypeShort3 = 39
    MTLDataTypeShort4 = 40

    MTLDataTypeUShort = 41
    MTLDataTypeUShort2 = 42
    MTLDataTypeUShort3 = 43
    MTLDataTypeUShort4 = 44

    MTLDataTypeChar = 45
    MTLDataTypeChar2 = 46
    MTLDataTypeChar3 = 47
    MTLDataTypeChar4 = 48

    MTLDataTypeUChar = 49
    MTLDataTypeUChar2 = 50
    MTLDataTypeUChar3 = 51
    MTLDataTypeUChar4 = 52

    MTLDataTypeBool = 53
    MTLDataTypeBool2 = 54
    MTLDataTypeBool3 = 55
    MTLDataTypeBool4 = 56

    MTLDataTypeTexture = 58
    MTLDataTypeSampler = 59
    MTLDataTypePointer = 60

    MTLDataTypeR8Unorm = 62
    MTLDataTypeR8Snorm = 63
    MTLDataTypeR16Unorm = 64
    MTLDataTypeR16Snorm = 65
    MTLDataTypeRG8Unorm = 66
    MTLDataTypeRG8Snorm = 67
    MTLDataTypeRG16Unorm = 68
    MTLDataTypeRG16Snorm = 69
    MTLDataTypeRGBA8Unorm = 70
    MTLDataTypeRGBA8Unorm_sRGB = 71
    MTLDataTypeRGBA8Snorm = 72
    MTLDataTypeRGBA16Unorm = 73
    MTLDataTypeRGBA16Snorm = 74
    MTLDataTypeRGB10A2Unorm = 75
    MTLDataTypeRG11B10Float = 76
    MTLDataTypeRGB9E5Float = 77

    MTLDataTypeRenderPipeline = 78
    MTLDataTypeComputePipeline = 79
    MTLDataTypeIndirectCommandBuffer = 80

    MTLDataTypeLong = 81
    MTLDataTypeLong2 = 82
    MTLDataTypeLong3 = 83
    MTLDataTypeLong4 = 84

    MTLDataTypeULong = 85
    MTLDataTypeULong2 = 86
    MTLDataTypeULong3 = 87
    MTLDataTypeULong4 = 88

    MTLDataTypeDouble = 89
    MTLDataTypeDouble2 = 90
    MTLDataTypeDouble3 = 91
    MTLDataTypeDouble4 = 92

    MTLDataTypeFloat8 = 93
    MTLDataTypeFloat16 = 94

    MTLDataTypeHalf8 = 95
    MTLDataTypeHalf16 = 96

    MTLDataTypeInt8 = 97
    MTLDataTypeInt16 = 98

    MTLDataTypeUInt8 = 99
    MTLDataTypeUInt16 = 100

    MTLDataTypeShort8 = 101
    MTLDataTypeShort16 = 102

    MTLDataTypeUShort8 = 103
    MTLDataTypeUShort16 = 104

    MTLDataTypeChar8 = 105
    MTLDataTypeChar16 = 106

    MTLDataTypeUChar8 = 107
    MTLDataTypeUChar16 = 108

    MTLDataTypeLong8 = 109
    MTLDataTypeLong16 = 110

    MTLDataTypeULong8 = 111
    MTLDataTypeULong16 = 112

    MTLDataTypeDouble8 = 113
    MTLDataTypeDouble16 = 114

    MTLDataTypeVisibleFunctionTable = 115
    MTLDataTypeIntersectionFunctionTable = 116
    MTLDataTypePrimitiveAccelerationStructure = 117
    MTLDataTypeInstanceAccelerationStructure = 118

    MTLDataTypeBool8 = 119
    MTLDataTypeBool16 = 120

    MTLDataTypeBFloat = 121
    MTLDataTypeBFloat2 = 122
    MTLDataTypeBFloat3 = 123
    MTLDataTypeBFloat4 = 124
    MTLDataTypeBFloat8 = 125
    MTLDataTypeBFloat16 = 126

    MTLDataTypeBFloat2x2 = 127
    MTLDataTypeBFloat2x3 = 128
    MTLDataTypeBFloat2x4 = 129

    MTLDataTypeBFloat3x2 = 130
    MTLDataTypeBFloat3x3 = 131
    MTLDataTypeBFloat3x4 = 132

    MTLDataTypeBFloat4x2 = 133
    MTLDataTypeBFloat4x3 = 134
    MTLDataTypeBFloat4x4 = 135
end

#=

Possible (undocumented) values for this enum can be iterated using the MTLTypeInternal type:

```julia
load_framework("Metal")

@objcwrapper immutable=false MTLType <: NSObject

@objcwrapper immutable=false MTLTypeInternal <: MTLType

@objcproperties MTLTypeInternal begin
    @autoproperty dataType::UInt64
    @autoproperty description::id{NSString}
end

function MTLTypeInternal(dataType::Integer)
    obj = MTLTypeInternal(@objc [MTLTypeInternal alloc]::id{MTLTypeInternal})
    finalizer(dealloc, obj)
    @objc [obj::id{MTLTypeInternal} initWithDataType:dataType::UInt64]::id{MTLTypeInternal}
    return obj
end

dealloc(obj::MTLTypeInternal) = @objc [obj::id{MTLTypeInternal} dealloc]::Cvoid

for i in 1:200
    typ = MTLTypeInternal(i)
    name = string(typ.description)
    if name != "Unknown"
        println("    $name = $i")
    end
end
```

=#


# the actual MTLArgument class is deprecated, so we don't wrap it
