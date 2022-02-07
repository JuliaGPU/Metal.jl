# stuff in this file takes Julia types and converts them to Ctypes compatible
# to be used inside of


# Convert Data structures to C
function to_mtl_ref(arg::T) where T
    if !Base.datatype_pointerfree(T)
        error("Types should not contain pointers: $T")
    end
    if contains_different_layout(T)
        x = replace_different_layout(arg)
        return Base.RefValue(x), sizeof(x)
    end
    Base.RefValue(arg), sizeof(arg)
end

## Identify if there is a mtlbuffer in this structure...

# returns true if structure contains a device buffer, false otherwise
function _contains_mtlbuffer(::Type{T}) where T
    if Base.has_free_typevars(T)
        throw("Only concrete types can be sent to GPU!")
    end
    for typ in T.types
        typ <: DeviceBuffer && return true
    end

    return false
end

@generated function contains_mtlbuffer(::Type{T}) where T
    :($(_contains_mtlbuffer(T)))
end




##
function _contains_different_layout(::Type{T}) where T
    sizeof(T) == 0 && return true
    nfields(T) == 0 && return false
    for fname in fieldnames(T)
        contains_different_layout(fieldtype(T, fname)) && return true
    end
    return false
end

contains_different_layout(::Type{NTuple{3, T}}) where {T <: Union{Float32, Float64, Int8, Int32,
                                                                  Int64, UInt8, UInt32, UInt64}} = true

"""
    contains_different_layout(T)
Empty types and NTuple{3, CLNumber} have different layouts and need to be replaced
(Where `CLNumber <: Union{Float32, Float64, Int8, Int32, Int64, UInt8, UInt32, UInt64}`)
TODO: Float16 + Int16 should also be in CLNumbers
"""
@generated function contains_different_layout(::Type{T}) where T
    :($(_contains_different_layout(T)))
end

function struct2tuple(x::T) where T
    ntuple(nfields(x)) do i
        getfield(x, i)
    end
end

replace_different_layout(red::NTuple{N, Any}, rest::Tuple{}) where N = red
function replace_different_layout(red::NTuple{N, Any}, rest) where N
    elem1 = first(rest)
    T = typeof(elem1)
    repl = if sizeof(T) == 0 && nfields(elem1) == 0
        Int32(0)
    elseif contains_different_layout(T)
        replace_different_layout(elem1)
    else
        elem1
    end
    replace_different_layout((red..., repl), Base.tail(rest))
end

# TODO UInt16/Float16?
# Handle different sizes of OpenCL Vec3, which doesn't agree with julia
function replace_different_layout(arg::NTuple{3, T}) where T <: Union{Float32, Float64, Int8, Int32, Int64, UInt8, UInt32, UInt64}
    pad = T(0)
    (arg..., pad)
end

Base.@pure datatype_align(x::T) where {T} = datatype_align(T)
Base.@pure function datatype_align(::Type{T}) where {T}
    # typedef struct {
    #     uint32_t nfields;
    #     uint32_t alignment : 9;
    #     uint32_t haspadding : 1;
    #     uint32_t npointers : 20;
    #     uint32_t fielddesc_type : 2;
    # } jl_datatype_layout_t;
    field = T.layout + sizeof(UInt32)
    unsafe_load(convert(Ptr{UInt16}, field)) & convert(Int16, 2^9-1)
end
