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
- `air_version` and `metal_version` from `air.version` and `air.language_version`.

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
    return MetalLibFunction(; name=entry, air_module, fields...)
end

# a value referenced from metadata, looking through the casts of typed-pointer modules
function metadata_value(md::LLVM.Metadata)
    val = LLVM.Value(md)
    while val isa LLVM.ConstantExpr &&
          LLVM.opcode(val) in (LLVM.API.LLVMBitCast, LLVM.API.LLVMAddrSpaceCast)
        val = LLVM.operands(val)[1]
    end
    return val
end

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
