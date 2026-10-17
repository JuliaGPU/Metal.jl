# decoding the reflection data of Metal library functions
#
# Apple's toolchain describes every function in a library with an "AIRR" FlatBuffer (the RBUF
# tag): its arguments, return values, attributes, function constants, and the types involved.
# The Metal runtime does not use it (it reflects functions from the metadata in their
# modules), but `MTLLibrary.reflectionForFunctionWithName:` and Apple's tools do.
#
# The decoder is driven by the schema Apple's tools use (see airr_schema.jl), so every kind of
# node decodes the same way, as a `ReflectionObject`.

include("flatbuffers.jl")
include("airr_schema.jl")

"""
    Metal.ReflectionObject

A table or struct of the reflection data of a library function (see
[`Metal.reflection`](@ref)). `nameof(obj)` is its type in Apple's schema, without the
namespace (e.g. `:BufferArg` or `:KernelFunction`), and its fields are available as
properties, in the order of the schema.

Fields that the data does not contain are `nothing`, except for numbers and booleans, which
then have their default value. Structs that only wrap a number (like `UIntValue`) are used
by the schema for optional values, so a `nothing` there means "not specified" rather than 0.

References between nodes are `NodeId` objects; index the reflection root with them to get
the node they refer to.
"""
struct ReflectionObject
    kind::Symbol
    fields::Vector{Pair{Symbol,Any}}
end

"""
    Metal.ReflectionEnum

A value of an enumeration in reflection data: `type` is the enumeration, `name` the name of
the value, or `nothing` if the schema doesn't know it, and `value` its number.
"""
struct ReflectionEnum
    type::Symbol
    name::Union{Nothing,Symbol}
    value::Int64
end

"""
    Metal.UnknownReflectionNode

A node of a kind the schema doesn't know: `tag` is its type, `offset` where its table starts
in the reflection data.
"""
struct UnknownReflectionNode
    tag::Int64
    offset::Int
end

Base.nameof(obj::ReflectionObject) = getfield(obj, :kind)

function Base.getproperty(obj::ReflectionObject, name::Symbol)
    for (field, value) in getfield(obj, :fields)
        field === name && return value
    end
    throw(ArgumentError("$(nameof(obj)) has no field $name"))
end
Base.propertynames(obj::ReflectionObject) = first.(getfield(obj, :fields))
Base.hasproperty(obj::ReflectionObject, name::Symbol) =
    any(f -> first(f) === name, getfield(obj, :fields))

Base.:(==)(a::ReflectionObject, b::ReflectionObject) =
    nameof(a) == nameof(b) && getfield(a, :fields) == getfield(b, :fields)
Base.hash(obj::ReflectionObject, h::UInt) =
    hash(getfield(obj, :fields), hash(nameof(obj), hash(ReflectionObject, h)))

# resolve a node reference
function Base.getindex(root::ReflectionObject, id::ReflectionObject)
    nameof(root) === :Reflection && nameof(id) === :NodeId ||
        throw(ArgumentError("index the reflection root with a NodeId"))
    nodes = something(root.nodes, ReflectionObject[])
    0 <= id.id < length(nodes) || throw(BoundsError(nodes, Int(id.id) + 1))
    return nodes[id.id+1].node
end


## decoding

short_name(name::String) = Symbol(last(split(name, '.')))

# a bound on the nesting of objects, to reject cyclic or deeply nested data
const max_reflection_depth = 64

# the state of decoding one buffer. objects can be referred to many times, and can overlap,
# which would let small inputs decode to huge amounts of data. so tables, strings and vectors
# are decoded once per position (and type), sharing the result, and the amount of data
# decoded is limited to a multiple of the size of the buffer.
struct ReflectionDecoder
    schema::FBSchema
    buf::Vector{UInt8}
    cache::Dict{Tuple{Int,FBBaseType,Int32},Any}
    budget::Base.RefValue{Int}
end
ReflectionDecoder(schema, buf) =
    ReflectionDecoder(schema, buf, Dict{Tuple{Int,FBBaseType,Int32},Any}(),
                      Ref(16 * length(buf) + 4096))

cached(f, d::ReflectionDecoder, pos, base, index) = get!(f, d.cache, (pos, base, Int32(index)))

# account for decoding `n` units of data (bytes of strings, elements of vectors or fields)
function charge!(d::ReflectionDecoder, n, pos)
    d.budget[] -= n
    d.budget[] >= 0 ||
        throw(FlatBufferError("the data decodes to much more than the buffer holds", pos))
    return
end

function decode_scalar(d::ReflectionDecoder, type::FBType, base::FBBaseType, pos)
    T = get(fb_scalar_types, base, nothing)
    T === nothing && throw(FlatBufferError("unsupported scalar type $base", pos))
    value = fb_read(T, d.buf, pos)
    return type.index >= 0 ? enum_value(d.schema, type.index, value) : value
end

function enum_value(schema::FBSchema, index, value)
    enum = schema.enums[index+1]
    i = findfirst(v -> last(v) == value, enum.values)
    name = i === nothing ? nothing : Symbol(first(enum.values[i]))
    return ReflectionEnum(short_name(enum.name), name, Int64(value))
end

function default_value(schema::FBSchema, f::FBField)
    T = fb_scalar_types[f.type.base]
    value = T <: AbstractFloat ? T(f.default_real) :
            T === Bool ? f.default_integer != 0 : T(f.default_integer)
    return f.type.index >= 0 ? enum_value(schema, f.type.index, value) : value
end

# the size of a field within its table
function field_size(schema::FBSchema, f::FBField)
    T = get(fb_scalar_types, f.type.base, nothing)
    T === nothing || return sizeof(T)
    if f.type.base == FB_OBJ
        obj = schema.objects[f.type.index+1]
        obj.is_struct && return Int(obj.bytesize)
    end
    return 4    # an offset
end

decode_string(d::ReflectionDecoder, pos) = cached(d, pos, FB_STRING, -1) do
    str = fb_string(d.buf, pos)
    charge!(d, sizeof(str), pos)
    str
end

function decode_struct(d::ReflectionDecoder, obj::FBObject, pos)
    fields = Pair{Symbol,Any}[]
    for f in obj.fields
        p = pos + Int(f.offset)
        value = if f.type.base == FB_OBJ
            decode_struct(d, d.schema.objects[f.type.index+1], p)
        elseif f.type.base == FB_ARRAY
            elsize, decode = element_decoder(d, f.type, 0)
            [decode(p + i * elsize) for i in 0:Int(f.type.fixed_length)-1]
        else
            decode_scalar(d, f.type, f.type.base, p)
        end
        push!(fields, f.name => value)
    end
    return ReflectionObject(short_name(obj.name), fields)
end

function decode_table(d::ReflectionDecoder, index, pos, depth)
    depth > max_reflection_depth && throw(FlatBufferError("objects nested too deeply", pos))
    cached(d, pos, FB_OBJ, index) do
        decode_table_uncached(d, d.schema.objects[index+1], pos, depth)
    end
end

function decode_table_uncached(d::ReflectionDecoder, obj::FBObject, pos, depth)
    schema = d.schema
    t = FBTable(d.buf, pos)
    charge!(d, length(obj.fields), pos)
    fields = Pair{Symbol,Any}[]
    for f in obj.fields
        f.deprecated && continue
        p = fb_field(t, f.id, field_size(schema, f))
        value = if haskey(fb_scalar_types, f.type.base)
            p === nothing ? default_value(schema, f) : decode_scalar(d, f.type, f.type.base, p)
        elseif p === nothing
            nothing
        elseif f.type.base == FB_STRING
            decode_string(d, fb_deref(d.buf, p))
        elseif f.type.base == FB_OBJ
            fobj = schema.objects[f.type.index+1]
            fobj.is_struct ? decode_struct(d, fobj, p) :
                             decode_table(d, f.type.index, fb_deref(d.buf, p), depth + 1)
        elseif f.type.base == FB_UNION
            # the type of a union is stored in the field before it
            tf = obj.fields[findfirst(g -> g.id == f.id - 1, obj.fields)]
            T = fb_scalar_types[tf.type.base]
            tp = fb_field(t, tf.id, sizeof(T))
            tag = tp === nothing ? 0 : Int64(fb_read(T, d.buf, tp))
            decode_union(d, schema.enums[f.type.index+1], tag, fb_deref(d.buf, p), depth + 1)
        elseif f.type.base == FB_VECTOR
            decode_vector(d, f.type, fb_deref(d.buf, p), depth + 1)
        else
            throw(FlatBufferError("unsupported field type $(f.type.base)", p))
        end
        push!(fields, f.name => value)
    end
    return ReflectionObject(short_name(obj.name), fields)
end

function decode_union(d::ReflectionDecoder, enum::FBEnum, tag, pos, depth)
    i = findfirst(v -> last(v) == tag, enum.values)
    if i === nothing || enum.union_objects[i] < 0
        return UnknownReflectionNode(tag, pos)
    end
    return decode_table(d, enum.union_objects[i], pos, depth)
end

function decode_vector(d::ReflectionDecoder, type::FBType, pos, depth)
    cached(d, pos, type.element, type.index) do
        elsize, decode = element_decoder(d, type, depth)
        len, first = fb_vector(d.buf, pos, elsize)
        charge!(d, len, pos)
        Any[decode(first + i * elsize) for i in 0:len-1]
    end
end

# the size of the elements of a vector or array, and a function decoding one at a position
function element_decoder(d::ReflectionDecoder, type::FBType, depth)
    base = type.element
    if base == FB_STRING
        return 4, p -> decode_string(d, fb_deref(d.buf, p))
    elseif base == FB_OBJ
        obj = d.schema.objects[type.index+1]
        if obj.is_struct
            return Int(obj.bytesize), p -> decode_struct(d, obj, p)
        else
            return 4, p -> decode_table(d, type.index, fb_deref(d.buf, p), depth)
        end
    elseif haskey(fb_scalar_types, base)
        return sizeof(fb_scalar_types[base]), p -> decode_scalar(d, type, base, p)
    else
        throw(FlatBufferError("unsupported element type $base", -1))
    end
end

"""
    Metal.reflection(fun::MetalLibFunction)
    Metal.reflection(data::Vector{UInt8})

Decode the reflection data of a library function, as stored by Apple's toolchain, or
`nothing` if the function has none (Metal.jl does not generate it). The result is the root
[`ReflectionObject`](@ref) of the data, a `:Reflection`: its `nodes` describe the
function, its arguments and the types involved, and lists like `kernel_functions` refer to
them by `NodeId`.

```julia
julia> r = Metal.reflection(lib.functions[1]);

julia> kernel = r[only(r.kernel_functions)];

julia> [r[arg].name for arg in kernel.arguments]
2-element Vector{String}:
 "a"
 "i"
```

Malformed data throws a `FlatBufferError`.
"""
reflection(fun::MetalLibFunction) =
    fun.reflection_data === nothing ? nothing : reflection(fun.reflection_data)

function reflection(data::Vector{UInt8})
    schema = airr_schema
    root = fb_root(data; identifier=schema.file_identifier)
    return decode_table(ReflectionDecoder(schema, data), schema.root_table, root.pos, 0)
end


## construction and encoding

const airr_objects = Dict(short_name(obj.name) => i - 1
                          for (i, obj) in enumerate(airr_schema.objects))

function schema_object(schema::FBSchema, kind::Symbol)
    schema === airr_schema || throw(ArgumentError("unsupported schema"))
    index = get(airr_objects, kind, nothing)
    index === nothing && throw(ArgumentError("unknown reflection object $kind"))
    return index
end

"""
    Metal.ReflectionObject(kind::Symbol; fields...)

Create a reflection object of the type `kind` in Apple's schema (e.g. `:BufferArg`), to
encode with [`Metal.reflection_data`](@ref). Fields that are not given are absent (or have
their default value, for numbers and booleans). Numbers are converted to the type of their
field, enumerations can be given by name, and the type of a union (e.g. the `node_type` of a
`:Node`) is derived from its value.

```julia
julia> Metal.ReflectionObject(:NodeId; id=1)
#1
```
"""
function ReflectionObject(kind::Symbol; kwargs...)
    schema = airr_schema
    obj = schema.objects[schema_object(schema, kind)+1]
    given = Dict{Symbol,Any}(kwargs)
    fields = Pair{Symbol,Any}[]
    for f in obj.fields
        f.deprecated && continue
        value = pop!(given, f.name, nothing)
        if haskey(fb_scalar_types, f.type.base)
            if value === nothing && f.type.base in (FB_UTYPE, FB_UTYPE32)
                # the type of the union that follows
                union = obj.fields[findfirst(g -> g.id == f.id + 1, obj.fields)]
                member = get(kwargs, union.name, nothing)
                value = member === nothing ? 0 : union_tag(schema, union, member)
            end
            value = value === nothing ? default_value(schema, f) :
                    scalar_value(schema, f.type, f.type.base, value)
        elseif value !== nothing && f.type.base == FB_VECTOR
            value = if haskey(fb_scalar_types, f.type.element)
                Any[scalar_value(schema, f.type, f.type.element, v) for v in value]
            else
                Any[value...]
            end
        end
        push!(fields, f.name => value)
    end
    isempty(given) || throw(ArgumentError("$kind has no field $(first(keys(given)))"))
    return ReflectionObject(kind, fields)
end

function scalar_value(schema::FBSchema, type::FBType, base::FBBaseType, value)
    T = fb_scalar_types[base]
    type.index >= 0 || return convert(T, value)
    enum = schema.enums[type.index+1]
    if value isa Symbol
        i = findfirst(v -> first(v) == String(value), enum.values)
        i === nothing && throw(ArgumentError("$(short_name(enum.name)) has no value $value"))
        value = last(enum.values[i])
    elseif value isa ReflectionEnum
        value = value.value
    end
    return enum_value(schema, type.index, convert(T, value))
end

function union_tag(schema::FBSchema, f::FBField, member::ReflectionObject)
    enum = schema.enums[f.type.index+1]
    index = schema_object(schema, nameof(member))
    i = findfirst(==(index), enum.union_objects)
    i === nothing &&
        throw(ArgumentError("$(nameof(member)) is not a member of $(short_name(enum.name))"))
    return last(enum.values[i])
end

"""
    Metal.reflection_data(root::ReflectionObject)

Encode reflection data, the inverse of [`Metal.reflection`](@ref): `root` is a
`:Reflection`, e.g. as decoded, or built with the [`ReflectionObject`](@ref) constructor.
Nodes that were decoded as an [`UnknownReflectionNode`](@ref) cannot be encoded.
"""
function reflection_data(root::ReflectionObject)
    schema = airr_schema
    nameof(root) === :Reflection ||
        throw(ArgumentError("expected a Reflection, got $(nameof(root))"))
    return fb_finish(; identifier=schema.file_identifier) do b
        encode_table!(b, schema, schema.root_table, root)
    end
end

function check_kind(schema::FBSchema, index, value)
    expected = short_name(schema.objects[index+1].name)
    value isa ReflectionObject && nameof(value) === expected ||
        throw(ArgumentError("expected a $expected, got $(repr(value))"))
end

function encode_table!(b::FBBuilder, schema::FBSchema, index, obj::ReflectionObject)
    check_kind(schema, index, obj)
    fields = Any[]
    schema_fields = schema.objects[index+1].fields
    for f in schema_fields
        f.deprecated && continue
        value = getproperty(obj, f.name)
        value === nothing && continue
        base = f.type.base
        if haskey(fb_scalar_types, base)
            if base in (FB_UTYPE, FB_UTYPE32)
                # (the type of a union, which must match its value)
                union = schema_fields[findfirst(g -> g.id == f.id + 1, schema_fields)]
                member = getproperty(obj, union.name)
                member isa ReflectionObject && (value = union_tag(schema, union, member))
            end
            T = fb_scalar_types[base]
            bytes = encode_scalar(schema, f.type, base, value)
            push!(fields, FBInlineField(f.id, bytes, sizeof(T)))
        elseif base == FB_STRING
            push!(fields, FBOffsetField(f.id, b -> fb_string!(b, value)))
        elseif base == FB_OBJ && schema.objects[f.type.index+1].is_struct
            push!(fields, FBInlineField(f.id, encode_struct(schema, f.type.index, value),
                                        struct_alignment(schema, f.type.index)))
        elseif base == FB_OBJ
            push!(fields, FBOffsetField(f.id, b -> encode_table!(b, schema, f.type.index, value)))
        elseif base == FB_UNION
            value isa UnknownReflectionNode &&
                throw(ArgumentError("cannot encode an unknown node (tag $(value.tag))"))
            push!(fields, FBOffsetField(f.id,
                b -> encode_table!(b, schema, schema_object(schema, nameof(value)), value)))
        elseif base == FB_VECTOR
            push!(fields, FBOffsetField(f.id, b -> encode_vector!(b, schema, f.type, value)))
        else
            throw(ArgumentError("unsupported field type $base"))
        end
    end
    return fb_table!(b, fields)
end

function encode_scalar(schema, type, base, value)
    value = scalar_value(schema, type, base, value)
    return fb_bytes(value isa ReflectionEnum ? fb_scalar_types[base](value.value) : value)
end

function struct_alignment(schema::FBSchema, index)
    align = 1
    for f in schema.objects[index+1].fields
        base = f.type.base == FB_ARRAY ? f.type.element : f.type.base
        align = max(align, base == FB_OBJ ? struct_alignment(schema, f.type.index) :
                           sizeof(fb_scalar_types[base]))
    end
    return align
end

function encode_struct(schema::FBSchema, index, obj)
    check_kind(schema, index, obj)
    s = schema.objects[index+1]
    bytes = Base.zeros(UInt8, s.bytesize)
    for f in s.fields
        value = getproperty(obj, f.name)
        value === nothing && continue
        if f.type.base == FB_ARRAY
            length(value) == f.type.fixed_length ||
                throw(ArgumentError("$(f.name) needs $(f.type.fixed_length) elements"))
            elements, element_type = value, f.type.element
        else
            elements, element_type = (value,), f.type.base
        end
        pos = Int(f.offset)
        for el in elements
            data = element_type == FB_OBJ ? encode_struct(schema, f.type.index, el) :
                                            encode_scalar(schema, f.type, element_type, el)
            copyto!(bytes, pos + 1, data, 1, length(data))
            pos += length(data)
        end
    end
    return bytes
end

function encode_vector!(b::FBBuilder, schema::FBSchema, type::FBType, values::AbstractVector)
    base = type.element
    if base == FB_STRING
        return fb_offset_vector!(b, Any[b -> fb_string!(b, v) for v in values])
    elseif base == FB_OBJ && !schema.objects[type.index+1].is_struct
        return fb_offset_vector!(b, Any[b -> encode_table!(b, schema, type.index, v)
                                        for v in values])
    elseif base == FB_OBJ
        return fb_inline_vector!(b, [encode_struct(schema, type.index, v) for v in values],
                                 struct_alignment(schema, type.index))
    elseif haskey(fb_scalar_types, base)
        return fb_inline_vector!(b, [encode_scalar(schema, type, base, v) for v in values],
                                 sizeof(fb_scalar_types[base]))
    else
        throw(ArgumentError("unsupported element type $base"))
    end
end


## display

function Base.show(io::IO, obj::ReflectionObject)
    if nameof(obj) === :NodeId
        print(io, "#", obj.id)
        return
    end
    print(io, nameof(obj), "(")
    first = true
    for (name, value) in getfield(obj, :fields)
        value === nothing && continue
        first || print(io, ", ")
        first = false
        print(io, name, "=")
        show_value(io, value)
    end
    print(io, ")")
end

show_value(io::IO, x) = show(io, x)
show_value(io::IO, x::Integer) = print(io, x)
function show_value(io::IO, x::AbstractVector)
    print(io, "[")
    for (i, v) in enumerate(x)
        i > 1 && print(io, ", ")
        show_value(io, v)
    end
    print(io, "]")
end

function Base.show(io::IO, ::MIME"text/plain", obj::ReflectionObject)
    if nameof(obj) !== :Reflection
        show(io, obj)
        return
    end
    v = obj.version
    nodes = something(obj.nodes, [])
    print(io, "AIRR reflection")
    v === nothing || print(io, " v$(v.major).$(v.minor).$(v.sub_minor)")
    print(io, " with $(length(nodes)) nodes")
    for (i, node) in enumerate(nodes)
        print(io, "\n  #$(i-1) ")
        show(io, node.node)
    end
    for (name, value) in getfield(obj, :fields)
        name in (:version, :nodes) && continue
        value === nothing && continue
        print(io, "\n  $name: ")
        show_value(io, value)
    end
end

Base.show(io::IO, e::ReflectionEnum) =
    print(io, e.name === nothing ? "$(e.type)($(e.value))" : e.name)
Base.show(io::IO, n::UnknownReflectionNode) =
    print(io, "UnknownReflectionNode(tag=$(n.tag), offset=$(n.offset))")

@public reflection, reflection_data, ReflectionObject, ReflectionEnum, UnknownReflectionNode,
        FlatBufferError
