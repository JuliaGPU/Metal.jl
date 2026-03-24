# Automated wrapper generation

This directory contains scripts to generate Julia wrappers for
the Metal, Metal Performance Shaders, and Metal Performance Shaders Graph
frameworks.

Objective-C methods are not yet supported.

The scripts are meant to be run from this directory, with the latest
Julia release supported by Metal.jl.

--------

Comment from removed file on `MTLDataType`. Parsing the headers does not reveal these hidden values.

~~~
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

~~~
