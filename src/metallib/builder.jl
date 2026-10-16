# building the functions of a Metal library from AIR modules
#
# like Apple's linker, we derive a function's library metadata from the `air.*` metadata of
# its module, so that the module stays the single source of truth.

# the named metadata listing a module's entry points, per type of function
const program_type_metadata = [
    "air.kernel"        => METALLIB_COMPUTE_FUNCTION,
    "air.vertex"        => METALLIB_VERTEX_FUNCTION,
    "air.fragment"      => METALLIB_FRAGMENT_FUNCTION,
    "air.visible"       => METALLIB_VISIBLE_FUNCTION,
    "air.ci"            => METALLIB_CI_FUNCTION,
    "air.intersection"  => METALLIB_INTERSECTION_FUNCTION,
    "air.mesh"          => METALLIB_MESH_FUNCTION,
    "air.object"        => METALLIB_OBJECT_FUNCTION,
]

"""
    MetalLibFunction(mod::LLVM.Module, entry::String; air_module, kwargs...)

Create a [`MetalLibFunction`](@ref) for the function `entry` of the AIR module `mod`,
deriving its metadata from the module like Apple's toolchain does:
- `type` from the named metadata listing the module's entry points (`air.kernel`,
  `air.visible`, ...), or `METALLIB_UNQUALIFIED_FUNCTION` if `entry` is in none of them;
- `air_version` and `metal_version` from `air.version` and `air.language_version`;
- `constants` from `air.function_constants`. Constants the module checks with
  `air.is_function_constant_defined` are optional, unless the module records whether they
  are required (as linked modules do). Note that this lists all of the module's constants,
  while Apple's linker only lists those the function uses.

`air_module` is the bitcode to store in the library, i.e. `mod` as Metal should see it
(typically downgraded). Other keyword arguments set fields of the function directly,
overriding what would be derived from the module.

The module's LLVM context must be active.
"""
function MetalLibFunction(mod::LLVM.Module, entry::String; air_module::Vector{UInt8},
                          kwargs...)
    haskey(mod.functions, entry) ||
        throw(ArgumentError("module does not contain a function named $entry"))
    fn = mod.functions[entry]

    fields = Dict{Symbol,Any}(kwargs)
    get!(() -> program_type(mod, fn), fields, :type)
    get!(() -> air_version(mod), fields, :air_version)
    get!(() -> metal_version(mod), fields, :metal_version)
    get!(() -> function_constants(mod), fields, :constants)
    return MetalLibFunction(; name=entry, air_module, fields...)
end

# look through the pointer casts of typed-pointer modules
function strip_casts(val::LLVM.Value)
    while val isa LLVM.ConstantExpr &&
          LLVM.opcode(val) in (LLVM.API.LLVMBitCast, LLVM.API.LLVMAddrSpaceCast)
        val = LLVM.operands(val)[1]
    end
    return val
end
metadata_value(md::LLVM.Metadata) = strip_casts(LLVM.Value(md))

function program_type(mod::LLVM.Module, fn::LLVM.Function)
    for (name, type) in program_type_metadata
        haskey(mod.metadata, name) || continue
        for node in LLVM.operands(mod.metadata[name])
            ops = LLVM.operands(node)
            if !isempty(ops) && ops[1] isa LLVM.ValueAsMetadata &&
               metadata_value(ops[1]) == fn
                return type
            end
        end
    end
    return METALLIB_UNQUALIFIED_FUNCTION
end

# the single node of a named metadata entry holding a version, e.g. `!{i32 2, i32 7, i32 0}`
function version_metadata(mod::LLVM.Module, name::String)
    haskey(mod.metadata, name) ||
        throw(ArgumentError("module has no $name metadata; pass the version explicitly"))
    node = only(LLVM.operands(mod.metadata[name]))
    return LLVM.operands(node)
end
function version_number(ops)
    parts = map(ops) do op
        val = op isa LLVM.ValueAsMetadata ? LLVM.Value(op) : nothing
        val isa LLVM.ConstantInt || throw(ArgumentError("malformed version metadata: $ops"))
        convert(Int, val)
    end
    return VersionNumber(parts...)
end

# `!air.version = !{!{i32 2, i32 7, i32 0}}`
air_version(mod::LLVM.Module) = version_number(version_metadata(mod, "air.version"))

# `!air.language_version = !{!{!"Metal", i32 3, i32 2, i32 0}}`
function metal_version(mod::LLVM.Module)
    ops = version_metadata(mod, "air.language_version")
    return version_number(ops[2:end])
end

# the data types of function constants, by their MSL spelling
const function_constant_types = let
    types = Dict{String,MTL.MTLDataType}()
    for (msl, mtl) in ["bool" => "Bool", "char" => "Char", "uchar" => "UChar",
                       "short" => "Short", "ushort" => "UShort", "int" => "Int",
                       "uint" => "UInt", "long" => "Long", "ulong" => "ULong",
                       "half" => "Half", "bfloat" => "BFloat", "float" => "Float"],
        width in ["", "2", "3", "4"]
        types[msl * width] = getproperty(MTL, Symbol("MTLDataType", mtl, width))
    end
    types
end

# `!air.function_constants = !{!{ptr addrspace(2) @init, !"type", !"name", i32 index}}`,
# where linked modules add an `i1 required` operand
function function_constants(mod::LLVM.Module)
    haskey(mod.metadata, "air.function_constants") || return FunctionConstant[]
    optional = optional_function_constants(mod)
    map(LLVM.operands(mod.metadata["air.function_constants"])) do node
        ops = LLVM.operands(node)
        length(ops) in (4, 5) ||
            throw(ArgumentError("malformed function constant metadata: $node"))
        initializer = metadata_value(ops[1])
        type = convert(String, ops[2])
        datatype = get(function_constant_types, type) do
            throw(ArgumentError("unsupported function constant type $type"))
        end
        name = convert(String, ops[3])
        index = convert(Int, LLVM.Value(ops[4]))
        required = if length(ops) == 5
            convert(Int, LLVM.Value(ops[5])) != 0
        else
            !(initializer in optional)
        end
        FunctionConstant(name, datatype, index, required)
    end
end

# the initializers of the function constants the module checks are defined
function optional_function_constants(mod::LLVM.Module)
    optional = LLVM.Value[]
    haskey(mod.functions, "air.is_function_constant_defined") || return optional
    for use in LLVM.uses(mod.functions["air.is_function_constant_defined"])
        call = LLVM.user(use)
        call isa LLVM.CallInst || continue
        push!(optional, strip_casts(LLVM.arguments(call)[1]))
    end
    return optional
end
