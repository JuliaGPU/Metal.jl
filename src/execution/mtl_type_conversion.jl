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
