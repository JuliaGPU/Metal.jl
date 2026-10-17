# a minimal reader for FlatBuffers (https://flatbuffers.dev), driven by a schema
#
# Metal libraries store the reflection data of their functions as FlatBuffers. Apple's
# toolchain embeds the schemas of these buffers in binary form (BFBS, i.e. FlatBuffers
# themselves, following flatc's `reflection.fbs`), which `res/airr/generate.jl` turns into the
# schema description used here. Positions are 0-based offsets into the buffer, like in the
# FlatBuffers documentation.

"""
    FlatBufferError(msg, offset)

An error decoding a FlatBuffer: `offset` is the position in the buffer where it was found.
"""
struct FlatBufferError <: Exception
    msg::String
    offset::Int
end

Base.showerror(io::IO, err::FlatBufferError) =
    print(io, "FlatBufferError: ", err.msg, " (at offset ", err.offset, ")")


## buffer access

function fb_read(::Type{T}, buf::AbstractVector{UInt8}, pos::Integer) where {T}
    0 <= pos && pos + sizeof(T) <= length(buf) ||
        throw(FlatBufferError("reading $(sizeof(T)) bytes past the end of the buffer", pos))
    GC.@preserve buf begin
        return ltoh(unsafe_load(Ptr{T}(pointer(buf, pos + 1))))
    end
end
fb_read(::Type{Bool}, buf::AbstractVector{UInt8}, pos::Integer) = fb_read(UInt8, buf, pos) != 0

# follow an unsigned offset stored at `pos`
fb_deref(buf, pos) = pos + Int(fb_read(UInt32, buf, pos))

function fb_string(buf, pos)
    len = Int(fb_read(UInt32, buf, pos))
    pos + 4 + len < length(buf) ||
        throw(FlatBufferError("string of $len bytes runs past the end of the buffer", pos))
    buf[pos+4+len+1] == 0x00 ||
        throw(FlatBufferError("string is not terminated by a NUL byte", pos + 4 + len))
    return String(buf[pos+5:pos+4+len])
end

# a vector at `pos`: its length and the position of its first element
function fb_vector(buf, pos, elsize)
    len = Int(fb_read(UInt32, buf, pos))
    pos + 4 + len * elsize <= length(buf) ||
        throw(FlatBufferError("vector of $len elements runs past the end of the buffer", pos))
    return len, pos + 4
end

# a table at `pos`, with its vtable, which gives the size of the table and the offsets of its
# fields within it
struct FBTable
    buf::Vector{UInt8}
    pos::Int
    size::Int
    vtable::Int
    vtable_size::Int
end

function FBTable(buf::Vector{UInt8}, pos::Int)
    vtable = pos - Int(fb_read(Int32, buf, pos))
    vtable_size = Int(fb_read(UInt16, buf, vtable))
    vtable_size >= 4 && iseven(vtable_size) ||
        throw(FlatBufferError("invalid vtable of $vtable_size bytes", vtable))
    fb_read(UInt8, buf, vtable + vtable_size - 1)   # (bounds check)
    size = Int(fb_read(UInt16, buf, vtable + 2))
    4 <= size && pos + size <= length(buf) ||
        throw(FlatBufferError("invalid table of $size bytes", pos))
    return FBTable(buf, pos, size, vtable, vtable_size)
end

# the position of field `id` (of `size` bytes) in a table, or `nothing` if the table doesn't
# store it
function fb_field(t::FBTable, id::Integer, size::Integer=1)
    entry = 4 + 2 * id
    entry < t.vtable_size || return nothing
    offset = Int(fb_read(UInt16, t.buf, t.vtable + entry))
    offset == 0 && return nothing
    4 <= offset && offset + size <= t.size ||
        throw(FlatBufferError("field $id lies outside of its table", t.pos))
    return t.pos + offset
end

# the root table of a buffer, optionally checking its file identifier
function fb_root(buf::Vector{UInt8}; identifier::Union{Nothing,String}=nothing)
    if identifier !== nothing
        length(buf) >= 8 && String(buf[5:8]) == identifier ||
            throw(FlatBufferError("expected the file identifier \"$identifier\"", 4))
    end
    return FBTable(buf, fb_deref(buf, 0))
end


## schemas
#
# a subset of flatc's reflection schema, describing the objects (tables and structs) and enums
# (incl. unions) of a schema. indices refer to the objects or enums of the same schema.

# base types, as numbered in reflection.fbs. Apple's schemas add a 32-bit union type, for
# unions with more variants than fit the standard 8-bit type field.
@enum FBBaseType::UInt8 begin
    FB_NONE; FB_UTYPE; FB_BOOL; FB_BYTE; FB_UBYTE; FB_SHORT; FB_USHORT; FB_INT; FB_UINT
    FB_LONG; FB_ULONG; FB_FLOAT; FB_DOUBLE; FB_STRING; FB_VECTOR; FB_OBJ; FB_UNION; FB_ARRAY
    FB_VECTOR64
    FB_UTYPE32 = 254
end

function fb_base_type(x::UInt8)
    x <= 18 || x == 254 || throw(FlatBufferError("unknown base type $x in schema", -1))
    return FBBaseType(x)
end

const fb_scalar_types = Dict(FB_UTYPE => UInt8, FB_UTYPE32 => UInt32, FB_BOOL => Bool, FB_BYTE => Int8,
                             FB_UBYTE => UInt8, FB_SHORT => Int16, FB_USHORT => UInt16,
                             FB_INT => Int32, FB_UINT => UInt32, FB_LONG => Int64,
                             FB_ULONG => UInt64, FB_FLOAT => Float32, FB_DOUBLE => Float64)

struct FBType
    base::FBBaseType
    element::FBBaseType     # for vectors and arrays
    index::Int32            # object or enum, or -1
    fixed_length::UInt16    # for arrays
end

struct FBField
    name::Symbol
    type::FBType
    id::UInt16
    offset::UInt16          # in the vtable of tables, or the layout of structs
    default_integer::Int64
    default_real::Float64
    deprecated::Bool
end

struct FBObject
    name::String
    is_struct::Bool
    bytesize::Int32         # for structs
    fields::Vector{FBField} # ordered by id
end

struct FBEnum
    name::String
    is_union::Bool
    underlying::FBBaseType
    values::Vector{Pair{String,Int64}}
    union_objects::Vector{Int32}    # for unions: the object of every value, or -1
end

struct FBSchema
    file_identifier::String
    root_table::Int32
    objects::Vector{FBObject}
    enums::Vector{FBEnum}
end

# the schema of the BFBS schemas themselves (flatc's reflection.fbs), as far as needed to read
# them; field ids are those of reflection.fbs
function read_bfbs(buf::Vector{UInt8})
    root = fb_root(buf; identifier="BFBS")
    str(t, id) = (p = fb_field(t, id, 4); p === nothing ? "" : fb_string(buf, fb_deref(buf, p)))
    scalar(T, t, id, default) =
        (p = fb_field(t, id, sizeof(T)); p === nothing ? T(default) : fb_read(T, buf, p))
    table(t, id) = (p = fb_field(t, id, 4); p === nothing ? nothing : FBTable(buf, fb_deref(buf, p)))
    function tables(t, id)
        p = fb_field(t, id, 4)
        p === nothing && return FBTable[]
        len, first = fb_vector(buf, fb_deref(buf, p), 4)
        return [FBTable(buf, fb_deref(buf, first + 4i)) for i in 0:len-1]
    end
    function type(t)
        t === nothing && return FBType(FB_NONE, FB_NONE, -1, 0)
        return FBType(fb_base_type(scalar(UInt8, t, 0, 0)), fb_base_type(scalar(UInt8, t, 1, 0)),
                      scalar(Int32, t, 2, -1), scalar(UInt16, t, 3, 0))
    end

    objects = map(tables(root, 0)) do obj
        fields = map(tables(obj, 1)) do f
            FBField(Symbol(str(f, 0)), type(table(f, 1)), scalar(UInt16, f, 2, 0),
                    scalar(UInt16, f, 3, 0), scalar(Int64, f, 4, 0), scalar(Float64, f, 5, 0),
                    scalar(Bool, f, 6, false))
        end
        sort!(fields; by = f -> f.id)
        FBObject(str(obj, 0), scalar(Bool, obj, 2, false), scalar(Int32, obj, 4, 0), fields)
    end
    enums = map(tables(root, 1)) do e
        vals = tables(e, 1)
        FBEnum(str(e, 0), scalar(Bool, e, 2, false), type(table(e, 3)).base,
               [str(v, 0) => scalar(Int64, v, 1, 0) for v in vals],
               [type(table(v, 3)).index for v in vals])
    end
    root_table = let t = table(root, 4)
        t === nothing ? Int32(-1) : Int32(findfirst(o -> o.name == str(t, 0), objects) - 1)
    end
    return FBSchema(str(root, 2), root_table, objects, enums)
end


## building
#
# buffers are written front to back. a table is preceded by its vtable (unless an identical
# one was written before, which it then shares), and followed by the strings, vectors and
# tables it refers to, because offsets to those are unsigned and must point forward.

struct FBBuilder
    buf::Vector{UInt8}
    vtables::Dict{Vector{UInt16},Int}
end
FBBuilder() = FBBuilder(UInt8[], Dict{Vector{UInt16},Int}())

fb_pad!(b::FBBuilder, align) = append!(b.buf, Base.zeros(UInt8, mod(-length(b.buf), align)))

fb_bytes(x) = reinterpret(UInt8, [htol(x)])

# append a value, returning its position
function fb_put!(b::FBBuilder, x)
    pos = length(b.buf)
    append!(b.buf, fb_bytes(x))
    return pos
end

fb_patch!(b::FBBuilder, pos, bytes::AbstractVector{UInt8}) =
    copyto!(b.buf, pos + 1, bytes, 1, length(bytes))
# make the offset at `pos` refer to `target`
fb_patch_offset!(b::FBBuilder, pos, target) = fb_patch!(b, pos, fb_bytes(UInt32(target - pos)))

function fb_string!(b::FBBuilder, str::String)
    fb_pad!(b, 4)
    pos = fb_put!(b, UInt32(ncodeunits(str)))
    append!(b.buf, codeunits(str))
    push!(b.buf, 0x00)
    return pos
end

# a vector of scalars or structs, each given as its bytes
function fb_inline_vector!(b::FBBuilder, elements::AbstractVector, align)
    # (the elements, which follow the length, must be aligned)
    fb_pad!(b, 4)
    while (length(b.buf) + 4) % align != 0
        append!(b.buf, Base.zeros(UInt8, 4))
    end
    pos = fb_put!(b, UInt32(length(elements)))
    foreach(el -> append!(b.buf, el), elements)
    return pos
end

# a vector of strings or tables, each written by a function that returns its position
function fb_offset_vector!(b::FBBuilder, writers::Vector)
    fb_pad!(b, 4)
    pos = fb_put!(b, UInt32(length(writers)))
    slots = [fb_put!(b, UInt32(0)) for _ in writers]
    for (slot, write) in zip(slots, writers)
        fb_patch_offset!(b, slot, write(b))
    end
    return pos
end

# a field of a table: either stored inline (scalars and structs, as bytes), or an offset to
# an object that `write` writes after the table, returning its position
struct FBInlineField
    id::Int
    bytes::Vector{UInt8}
    align::Int
end
struct FBOffsetField
    id::Int
    write::Any
end

function fb_table!(b::FBBuilder, fields::Vector)
    # lay out the fields after the offset to the vtable, the most aligned ones first
    size(f) = f isa FBInlineField ? length(f.bytes) : 4
    align(f) = f isa FBInlineField ? f.align : 4
    offsets = Dict{Int,Int}()
    tsize = 4
    for f in sort(fields; by = f -> -align(f))
        tsize += mod(-tsize, align(f))
        offsets[f.id] = tsize
        tsize += size(f)
    end
    nfields = maximum(f -> f.id + 1, fields; init=0)
    vtable = UInt16[4 + 2nfields, tsize, (get(offsets, id, 0) for id in 0:nfields-1)...]

    vpos = get!(b.vtables, vtable) do
        fb_pad!(b, 2)
        pos = length(b.buf)
        foreach(x -> fb_put!(b, x), vtable)
        pos
    end
    fb_pad!(b, maximum(align, fields; init=4))
    pos = length(b.buf)
    append!(b.buf, Base.zeros(UInt8, tsize))
    fb_patch!(b, pos, fb_bytes(Int32(pos - vpos)))
    for f in fields
        f isa FBInlineField && fb_patch!(b, pos + offsets[f.id], f.bytes)
    end
    for f in sort(filter(f -> f isa FBOffsetField, fields); by = f -> f.id)
        fb_patch_offset!(b, pos + offsets[f.id], f.write(b))
    end
    return pos
end

# a complete buffer, with the root table written by `write_root`
function fb_finish(write_root; identifier::Union{Nothing,String}=nothing)
    b = FBBuilder()
    fb_put!(b, UInt32(0))
    if identifier !== nothing
        ncodeunits(identifier) == 4 || throw(ArgumentError("file identifiers have 4 bytes"))
        append!(b.buf, codeunits(identifier))
    end
    fb_patch_offset!(b, 0, write_root(b))
    fb_pad!(b, 4)
    return b.buf
end
