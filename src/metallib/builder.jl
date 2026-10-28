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
    MetalLibFunction(mod::LLVM.Module, entry::String; air_module, reflect=false, kwargs...)

Create a [`MetalLibFunction`](@ref) for the function `entry` of the AIR module `mod`,
deriving its metadata from the module like Apple's toolchain does:
- `type` from the named metadata listing the module's entry points (`air.kernel`,
  `air.visible`, ...), or `METALLIB_UNQUALIFIED_FUNCTION` if `entry` is in none of them;
- `air_version` and `metal_version` from `air.version` and `air.language_version`;
- `constants` from `air.function_constants`. Unless the module records whether a constant
  is required (as linked modules do), a constant is required if `entry` uses it (directly,
  through the functions it calls, or through program-scope constants the module's static
  initializers derive from it) without checking it with `air.is_function_constant_defined`.
  Constants `entry` does not use are listed as optional: Apple's linker omits them along
  with the code that uses them, but the runtime cannot build a function that lists no
  constants from a module that has some;
- `debug_info` from the debug info of `entry`, if the module was compiled with debug info
  (not `debug_level=0`) and it names the source file by an absolute path (Julia records
  relative paths for Base methods, and pseudo-files like `REPL[1]` or `none` for code that
  is not defined in a file).

With `reflect=true`, the function also gets reflection data (see
[`Metal.reflection`](@ref)), which Apple's tools and `MTLLibrary`'s
`reflectionForFunctionWithName:` use; the Metal runtime does not need it.

`air_module` is the bitcode to store in the library, i.e. `mod` as Metal should see it
(typically downgraded). Other keyword arguments set fields of the function directly,
overriding what would be derived from the module.

The module's LLVM context must be active.
"""
function MetalLibFunction(mod::LLVM.Module, entry::String; air_module::Vector{UInt8},
                          reflect::Bool=false, kwargs...)
    haskey(mod.functions, entry) ||
        throw(ArgumentError("module does not contain a function named $entry"))
    fn = mod.functions[entry]

    fields = Dict{Symbol,Any}(kwargs)
    get!(() -> program_type(mod, fn), fields, :type)
    get!(() -> air_version(mod), fields, :air_version)
    get!(() -> metal_version(mod), fields, :metal_version)
    get!(() -> function_constants(mod, fn), fields, :constants)
    get!(() -> debug_info(mod, fn), fields, :debug_info)
    if reflect
        get!(() -> reflection_data(reflection(mod, entry)), fields, :reflection_data)
    end
    return MetalLibFunction(; name=entry, air_module, fields...)
end

# look through the pointer casts of typed-pointer modules
function strip_casts(val::LLVM.Value)
    while val isa LLVM.ConstantExpr &&
          val.opcode in (LLVM.Opcode.BitCast, LLVM.Opcode.AddrSpaceCast)
        val = val.operands[1]
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
function function_constants(mod::LLVM.Module, fn::LLVM.Function)
    haskey(mod.metadata, "air.function_constants") || return FunctionConstant[]
    used, checked = function_constant_uses(mod, fn)
    constants = FunctionConstant[]
    for node in LLVM.operands(mod.metadata["air.function_constants"])
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
            initializer in used && !(initializer in checked)
        end
        push!(constants, FunctionConstant(name, datatype, index, required))
    end
    return constants
end

# the globals `fn` depends on, and those it checks with `is_function_constant_defined`.
#
# Apple's front-end computes program-scope constants derived from function constants (e.g.
# `constant uint y = is_function_constant_defined(x) ? x : 0;`) in static initializers
# that store to globals. A function that reads such a global depends on the computation of
# the value stored to the part it reads, and on the branches leading to that store, but not
# on the rest of the initializers, which compute the constants of all functions in the
# module.
function function_constant_uses(mod::LLVM.Module, fn::LLVM.Function)
    # what the static initializers write to, per global
    Path = Union{Nothing,Vector{Int}}
    stores = Dict{LLVM.Value,Vector{Tuple{Path,LLVM.Instruction}}}()
    unknown_stores = LLVM.Instruction[]
    for f in LLVM.functions(mod)
        LLVM.section(f) == "air.static_init" || continue
        for bb in LLVM.blocks(f), inst in LLVM.instructions(bb)
            if inst isa LLVM.StoreInst
                val, ptr = LLVM.operands(inst)
                loc = access_path(ptr, LLVM.value_type(val))
                if loc === nothing
                    push!(unknown_stores, inst)
                else
                    push!(get!(stores, loc[1], eltype(valtype(stores))[]), (loc[2], inst))
                end
            elseif inst isa LLVM.CallInst
                # calls may write to the globals they get a pointer to (e.g. `memcpy`),
                # but AIR intrinsics like `air.is_function_constant_defined` do not
                callee = LLVM.called_operand(inst)
                callee isa LLVM.Function && startswith(LLVM.name(callee), "air.") && continue
                for arg in LLVM.arguments(inst)
                    loc = access_path(arg, nothing)
                    loc === nothing && continue
                    push!(get!(stores, loc[1], eltype(valtype(stores))[]), (nothing, inst))
                end
            end
        end
    end

    visited = Set{LLVM.Value}()
    globals = Set{LLVM.Value}()     # globals that are used
    expanded = Set{LLVM.Value}()    # globals that are used as a whole
    checked = Set{LLVM.Value}()
    worklist = LLVM.Value[fn]

    # the parts of a global that are used depend on what is stored there
    function use_global(gv, path)
        if !(gv in globals)
            push!(globals, gv)
            init = LLVM.initializer(gv)
            init === nothing || push!(worklist, init)
            # stores to addresses we cannot trace to a global (e.g. to local memory) may
            # store to this one. this is conservative, and may require constants that the
            # function does not use.
            append!(worklist, unknown_stores)
        end
        for (store_path, store) in get(stores, gv, ())
            if path === nothing || store_path === nothing || overlaps(path, store_path)
                push!(worklist, store)
            end
        end
    end
    # an address that is a known part of a global only depends on that part
    function use_address(ptr, type)
        loc = access_path(ptr, type)
        (loc === nothing || loc[2] === nothing) && return false
        use_global(loc...)
        return true
    end

    postdomtrees = Dict{LLVM.Function,LLVM.PostDomTree}()
    try
        walk_dependences!(worklist, visited, expanded, checked, postdomtrees,
                          use_global, use_address)
    finally
        foreach(LLVM.dispose, values(postdomtrees))
    end
    return globals, checked
end

function walk_dependences!(worklist, visited, expanded, checked, postdomtrees,
                           use_global, use_address)
    while !isempty(worklist)
        val = pop!(worklist)
        if val isa LLVM.GlobalVariable
            val in expanded && continue
            push!(expanded, val)
            use_global(val, nothing)
            continue
        end
        val in visited && continue
        push!(visited, val)

        if val isa LLVM.Function
            # (all of a function we call, but only part of a static initializer)
            for bb in LLVM.blocks(val), inst in LLVM.instructions(bb)
                push!(worklist, inst)
            end
        elseif val isa LLVM.BasicBlock
            # an instruction depends on the branches that decide whether it executes
            postdomtree = get!(() -> LLVM.PostDomTree(LLVM.parent(val)), postdomtrees,
                               LLVM.parent(val))
            append!(worklist, control_dependences(postdomtree, val))
        elseif val isa LLVM.LoadInst
            push!(worklist, LLVM.parent(val))
            ptr = only(LLVM.operands(val))
            use_address(ptr, LLVM.value_type(val)) || push!(worklist, ptr)
        elseif val isa LLVM.StoreInst
            # a store depends on the value it stores, not on what it overwrites
            push!(worklist, LLVM.parent(val))
            stored, ptr = LLVM.operands(val)
            push!(worklist, stored)
            loc = access_path(ptr, LLVM.value_type(stored))
            if loc === nothing
                push!(worklist, ptr)
            elseif loc[2] === nothing
                # (an unknown part of a global, which depends on the address computation)
                address = strip_casts(ptr)
                if address isa LLVM.Instruction || address isa LLVM.ConstantExpr
                    for op in LLVM.operands(address)
                        op isa LLVM.GlobalVariable || push!(worklist, op)
                    end
                end
            end
        elseif val isa LLVM.ConstantExpr && use_address(val, nothing)
            # (a part of a global, accessed in another way)
        elseif val isa LLVM.Instruction || val isa LLVM.ConstantExpr ||
               val isa LLVM.ConstantAggregate
            if val isa LLVM.Instruction
                push!(worklist, LLVM.parent(val))
            end
            if val isa LLVM.CallInst
                callee = LLVM.called_operand(val)
                if callee isa LLVM.Function &&
                   LLVM.name(callee) == "air.is_function_constant_defined"
                    push!(checked, strip_casts(LLVM.arguments(val)[1]))
                end
            elseif val isa LLVM.PHIInst
                # the value also depends on the branches that select it
                for (_, block) in LLVM.incoming(val)
                    push!(worklist, block, LLVM.terminator(block))
                end
            end
            for op in LLVM.operands(val)
                # (skip the successors of branches, and metadata arguments)
                (op isa LLVM.BasicBlock || op isa LLVM.MetadataAsValue) && continue
                push!(worklist, op)
            end
        end
    end
end

# the terminators of the blocks that decide whether `block` executes, i.e., that have a
# successor `block` post-dominates without `block` post-dominating them
function control_dependences(postdomtree::LLVM.PostDomTree, block::LLVM.BasicBlock)
    postdominates(a, b) = a == b ||
        LLVM.dominates(postdomtree, first(LLVM.instructions(a)), first(LLVM.instructions(b)))
    terminators = LLVM.Instruction[]
    for pred in LLVM.blocks(LLVM.parent(block))
        successors = LLVM.successors(LLVM.terminator(pred))
        length(successors) > 1 || continue
        if (pred == block || !postdominates(block, pred)) &&
           any(succ -> postdominates(block, succ), successors)
            push!(terminators, LLVM.terminator(pred))
        end
    end
    return terminators
end

# the global an access of `type` (or of an unknown type) through `ptr` is to, and the
# indices of the part of the global it accesses (`nothing` if unknown)
function access_path(ptr::LLVM.Value, type::Union{Nothing,LLVM.LLVMType})
    base = strip_casts(ptr)
    if base isa LLVM.GlobalVariable
        gv = base
        base == ptr || return gv, nothing
        path = [0]
        current = LLVM.global_value_type(gv)
    elseif base isa LLVM.ConstantExpr && base.opcode == LLVM.Opcode.GetElementPtr
        gv, indices... = LLVM.operands(base)
        gv isa LLVM.GlobalVariable || return nothing
        (base == ptr && LLVM.source_element_type(base) == LLVM.global_value_type(gv) &&
         all(index -> index isa LLVM.ConstantInt, indices)) || return gv, nothing
        path = [convert(Int, index) for index in indices]
        current = LLVM.global_value_type(gv)
        for index in path[2:end]
            current = if current isa LLVM.StructType
                LLVM.elements(current)[index+1]
            elseif current isa LLVM.ArrayType || current isa LLVM.VectorType
                LLVM.element_type(current)
            else
                return gv, nothing
            end
        end
    elseif base isa LLVM.GetElementPtrInst || base isa LLVM.ConstantExpr
        # an unknown part of a global
        loc = access_path(LLVM.operands(base)[1], nothing)
        return loc === nothing ? nothing : (loc[1], nothing)
    else
        return nothing
    end

    # an access to the first element of an aggregate uses its address
    if type !== nothing
        while current != type
            if current isa LLVM.StructType && !isempty(LLVM.elements(current))
                current = LLVM.elements(current)[1]
            elseif current isa LLVM.ArrayType
                current = LLVM.element_type(current)
            else
                return gv, nothing
            end
            push!(path, 0)
        end
    end
    return gv, path
end

# whether two parts of a global overlap, i.e. one contains the other
function overlaps(a::Vector{Int}, b::Vector{Int})
    n = min(length(a), length(b))
    return a[1:n] == b[1:n]
end

# where the function was defined, like the `DEBI` Apple's toolchain records with `-g`
function debug_info(mod::LLVM.Module, fn::LLVM.Function)
    emits_debug_info(mod) || return nothing
    sp = LLVM.subprogram(fn)
    sp === nothing && return nothing
    file = LLVM.file(sp)
    file === nothing && return nothing
    path = joinpath(LLVM.directory(file), LLVM.filename(file))
    line = LLVM.line(sp)
    isabspath(path) && line >= 0 || return nothing
    return DebugInfo(line, path)
end

# the source files the debug info of a module refers to, through its functions and the
# locations of their instructions (including the functions they inlined), as the absolute
# paths they are recorded with; Julia records some files (e.g. Base's) by a bare name.
function debug_source_files(mod::LLVM.Module)
    paths = String[]
    emits_debug_info(mod) || return paths
    add!(file) = file === nothing ||
        push!(paths, joinpath(something(LLVM.directory(file), ""), LLVM.filename(file)))
    for fn in mod.functions
        sp = LLVM.subprogram(fn)
        sp === nothing && continue
        add!(LLVM.file(sp))
        for bb in LLVM.blocks(fn), inst in LLVM.instructions(bb)
            md = LLVM.metadata(inst)
            haskey(md, LLVM.MD_dbg) || continue
            loc = md[LLVM.MD_dbg]
            while loc isa LLVM.DILocation
                scope = LLVM.scope(loc)
                scope === nothing || add!(LLVM.file(scope))
                loc = LLVM.inlined_at(loc)
            end
        end
    end
    return filter!(isabspath, unique!(paths))
end

# Julia emits subprograms and locations even without `-g`, but then marks its compile unit
# `NoDebug`
function emits_debug_info(mod::LLVM.Module)
    haskey(mod.metadata, "llvm.dbg.cu") || return false
    return any(mod.metadata["llvm.dbg.cu"].operands) do cu
        cu.emission_kind != LLVM.DebugEmissionKind.NoDebug
    end
end


## reflection

# the built-in arguments of compute functions, which are described by their type and name
const builtin_argument_kinds = Dict(
    "air.$(name)" => Symbol(join(uppercasefirst.(split(name, '_'))), "Arg")
    for name in ["thread_position_in_grid", "threads_per_grid", "threadgroup_position_in_grid",
                 "threadgroups_per_grid", "thread_position_in_threadgroup",
                 "threads_per_threadgroup", "dispatch_threads_per_threadgroup",
                 "thread_index_in_threadgroup", "thread_execution_width",
                 "thread_index_in_simdgroup", "threads_per_simdgroup",
                 "simdgroup_index_in_threadgroup", "simdgroups_per_threadgroup",
                 "dispatch_simdgroups_per_threadgroup", "thread_index_in_quadgroup",
                 "quadgroup_index_in_threadgroup", "quadgroups_per_threadgroup",
                 "dispatch_quadgroups_per_threadgroup"])

struct UnsupportedReflection <: Exception
    msg::String
end
Base.showerror(io::IO, err::UnsupportedReflection) =
    print(io, "cannot describe this function with reflection data: ", err.msg)

"""
    Metal.reflection(mod::LLVM.Module, entry::String)

Derive the reflection data of the function `entry` of an AIR module from the module's
metadata, like Apple's linker does. The result can be encoded with
[`Metal.reflection_data`](@ref).

Only kernels and visible functions are supported, with buffer (incl. threadgroup memory)
and built-in arguments. Other functions or arguments (e.g. textures) throw an error, as does
malformed metadata.

An argument is `unused` if the metadata says so (as in modules Apple's linker linked), or if
the module does not use it. Arguments that only dead code uses count as used.

The function constants are those of the library function (see [`MetalLibFunction`](@ref)).
For a module that is shared by several functions, that may include constants the function
doesn't use, which Apple's linker would have removed.

The module's LLVM context must be active.
"""
function reflection(mod::LLVM.Module, entry::String)
    haskey(mod.functions, entry) ||
        throw(ArgumentError("module does not contain a function named $entry"))
    fn = mod.functions[entry]
    nodes = Any[]
    function add_node!(node)
        push!(nodes, node)
        return ReflectionObject(:NodeId; id=length(nodes) - 1)
    end
    set_node!(id, node) = (nodes[id.id+1] = ReflectionObject(:Node; node))

    fields = Dict{Symbol,Any}(:version => ReflectionObject(:Version; major=0, minor=4,
                                                            sub_minor=0))
    type = program_type(mod, fn)
    if type == METALLIB_COMPUTE_FUNCTION
        md = function_metadata(mod, "air.kernel", fn)
        id = add_node!(nothing)
        fields[:kernel_functions] = [id]
        set_node!(id, kernel_function(mod, fn, md, add_node!, set_node!))
    elseif type == METALLIB_VISIBLE_FUNCTION
        # (Apple's linker only records the name of visible functions)
        fields[:visible_functions] = [add_node!(ReflectionObject(:Node;
            node=ReflectionObject(:VisibleFunction; name=entry)))]
    else
        throw(UnsupportedReflection("$entry is a $type"))
    end

    constants = map(reflected_constants(mod, fn)) do (type, constant)
        add_node!(ReflectionObject(:Node; node=ReflectionObject(:FunctionConstant;
            type_name=type, constant.name, constant.index, constant.required)))
    end
    isempty(constants) || (fields[:function_constants] = constants)

    functions, globals = reachable(fn)
    if haskey(mod.metadata, "air.visible_function_references")
        references = ReflectionObject[]
        for ref in LLVM.operands(mod.metadata["air.visible_function_references"])
            ops = LLVM.operands(ref)
            length(ops) == 3 && ops[2] isa LLVM.ValueAsMetadata ||
                malformed("visible function reference", ref)
            metadata_value(ops[2]) in functions || continue
            name = md_string(ops[3], "visible function reference", ref)
            push!(references, add_node!(ReflectionObject(:Node;
                node=ReflectionObject(:VisibleFunctionReference; function_name=name))))
        end
        isempty(references) || (fields[:visible_function_references] = references)
    end

    allocations = ReflectionObject[]
    dl = LLVM.datalayout(mod)
    for gv in globals
        LLVM.addrspace(LLVM.value_type(gv)) == 3 || continue
        push!(allocations, ReflectionObject(:LocalAllocation;
            size=LLVM.storage_size(dl, LLVM.global_value_type(gv)),
            alignment=LLVM.alignment(gv)))
    end
    isempty(allocations) || (fields[:static_local_allocations] = allocations)

    return ReflectionObject(:Reflection; nodes, fields...)
end

# the entry for `fn` in a list of functions (e.g. `!air.kernel`)
function function_metadata(mod::LLVM.Module, name::String, fn::LLVM.Function)
    for node in LLVM.operands(mod.metadata[name])
        ops = LLVM.operands(node)
        !isempty(ops) && ops[1] isa LLVM.ValueAsMetadata && metadata_value(ops[1]) == fn &&
            return ops
    end
end

# reading metadata, failing clearly on metadata of an unexpected form
malformed(what, md) = throw(ArgumentError("malformed $what metadata: $md"))
md_operand(ops, i, what, node) = i <= length(ops) ? ops[i] : malformed(what, node)
function md_int(op, what, node)
    val = op isa LLVM.ValueAsMetadata ? LLVM.Value(op) : nothing
    val isa LLVM.ConstantInt || malformed(what, node)
    return convert(Int, val)
end
function md_unsigned(op, what, node)
    val = md_int(op, what, node)
    0 <= val <= typemax(UInt32) || malformed(what, node)
    return val
end
md_string(op, what, node) = op isa LLVM.MDString ? convert(String, op) : malformed(what, node)
md_tuple(op, what, node) = op isa LLVM.MDTuple ? op : malformed(what, node)

md_uint(op, what, node) = ReflectionObject(:UIntValue; value=md_unsigned(op, what, node))

# `!{ptr @kernel, !{return values...}, !{arguments...}, attributes...}`
function kernel_function(mod, fn, md, add_node!, set_node!)
    node = "kernel $(LLVM.name(fn))"
    length(md) >= 3 || malformed("kernel", node)
    isempty(LLVM.operands(md_tuple(md[2], "kernel", node))) ||
        throw(UnsupportedReflection("kernels return nothing"))
    params = LLVM.parameters(fn)
    struct_types = Dict{LLVM.Metadata,ReflectionObject}()
    arguments = map(LLVM.operands(md_tuple(md[3], "kernel", node))) do arg
        ops = LLVM.operands(md_tuple(arg, "argument", arg))
        index = md_int(md_operand(ops, 1, "argument", arg), "argument", arg)
        0 <= index < length(params) || malformed("argument", arg)
        kind = md_string(md_operand(ops, 2, "argument", arg), "argument", arg)
        id = add_node!(nothing)
        properties = if kind == "air.buffer"
            buffer_properties(arg, struct_types, add_node!, set_node!)
        elseif haskey(builtin_argument_kinds, kind)
            argument_properties(arg) do properties, key, i
                throw(UnsupportedReflection("unknown property $key of argument $kind"))
            end
        else
            throw(UnsupportedReflection("unsupported argument kind $kind"))
        end
        # (Apple's linker records unused arguments, otherwise look at the IR)
        unused = pop!(properties, :unused, isempty(LLVM.uses(params[index+1])))
        type = kind == "air.buffer" ? :BufferArg : builtin_argument_kinds[kind]
        set_node!(id, ReflectionObject(type; function_constant=false, unused, properties...))
        id
    end

    attributes = Dict{Symbol,Any}()
    for attr in md[4:end]
        attr isa LLVM.MDTuple ||
            throw(UnsupportedReflection("unsupported function attribute $attr"))
        ops = LLVM.operands(attr)
        name = md_string(md_operand(ops, 1, "function attribute", attr), "function attribute",
                         attr)
        if name == "air.max_work_group_size"
            length(ops) == 2 || malformed("function attribute", attr)
            size = md_uint(ops[2], "function attribute", attr)
            attributes[:workgroup_max_size] =
                add_node!(ReflectionObject(:Node;
                                           node=ReflectionObject(:WorkgroupMaxSizeFnAttr; size)))
        else
            throw(UnsupportedReflection("unsupported function attribute $name"))
        end
    end
    return ReflectionObject(:KernelFunction; name=LLVM.name(fn),
                            arguments=isempty(arguments) ? nothing : arguments, attributes...)
end

# the properties of an argument after its index and kind, `!"key", values...`, as fields of
# its reflection node. `other(properties, key, i)` handles keys that are specific to the kind
# of argument, whose values start at operand `i`, returning how many values it used.
function argument_properties(other, arg)
    ops = LLVM.operands(arg)
    properties = Dict{Symbol,Any}()
    i = 3
    while i <= length(ops)
        key = md_string(ops[i], "argument", arg)
        if key == "air.arg_type_name"
            properties[:type_name] = md_string(md_operand(ops, i + 1, "argument", arg),
                                               "argument", arg)
            i += 2
        elseif key == "air.arg_name"
            properties[:name] = md_string(md_operand(ops, i + 1, "argument", arg), "argument",
                                          arg)
            i += 2
        elseif key == "air.arg_unused"
            properties[:unused] = true
            i += 1
        else
            i += 1 + other(properties, key, i + 1)
        end
    end
    return properties
end

function buffer_properties(arg, struct_types, add_node!, set_node!)
    ops = LLVM.operands(arg)
    value(i) = md_operand(ops, i, "argument", arg)
    uint(i) = md_uint(value(i), "argument", arg)
    return argument_properties(arg) do properties, key, i
        if key == "air.buffer_size"
            properties[:buffer_size] = uint(i)
            return 1
        elseif key == "air.location_index"
            properties[:location_index] = uint(i)
            properties[:location_count] = uint(i + 1)
            return 2
        elseif key in ("air.read", "air.write", "air.read_write")
            properties[:access_qualifier] = Dict("air.read" => :Read, "air.write" => :Write,
                                                 "air.read_write" => :ReadWrite)[key]
            return 0
        elseif key == "air.address_space"
            space = md_unsigned(value(i), "argument", arg)
            space <= typemax(UInt8) || malformed("argument", arg)
            properties[:address_space] = space
            return 1
        elseif key == "air.struct_type_info"
            properties[:struct_type_info] =
                struct_type_info(md_tuple(value(i), "argument", arg), struct_types,
                                 add_node!, set_node!)
            return 1
        elseif key == "air.arg_type_size"
            properties[:type_size] = uint(i)
            return 1
        elseif key == "air.arg_type_align_size"
            properties[:type_align] = uint(i)
            return 1
        else
            throw(UnsupportedReflection("unknown property $key of a buffer argument"))
        end
    end
end

# `!{[!"air.struct_type_info", !{...},] offset, size, array entries, !"type", !"name", ...}`,
# described once per module like Apple's linker does
function struct_type_info(md, struct_types, add_node!, set_node!)
    haskey(struct_types, md) && return struct_types[md]
    id = struct_types[md] = add_node!(nothing)
    ops = LLVM.operands(md)
    value(i) = md_operand(ops, i, "struct type", md)
    fields = ReflectionObject[]
    i = 1
    while i <= length(ops)
        nested = nothing
        if ops[i] isa LLVM.MDString
            key = convert(String, ops[i])
            key == "air.struct_type_info" ||
                throw(UnsupportedReflection("unsupported struct field property $key"))
            nested = struct_type_info(md_tuple(value(i + 1), "struct type", md), struct_types,
                                      add_node!, set_node!)
            i += 2
        end
        offset, size, entries = (md_unsigned(value(j), "struct type", md) for j in i:i+2)
        push!(fields, ReflectionObject(:StructTypeInfoField; struct_type_info=nested,
                                       offset, size, array_entries=entries,
                                       type_name=md_string(value(i + 3), "struct type", md),
                                       field_name=md_string(value(i + 4), "struct type", md)))
        i += 5
    end
    set_node!(id, ReflectionObject(:StructTypeInfo; fields))
    return id
end

# the function constants of a function, with their type as spelled in the module
function reflected_constants(mod::LLVM.Module, fn::LLVM.Function)
    constants = function_constants(mod, fn)
    isempty(constants) && return []
    types = Dict(convert(String, LLVM.operands(node)[3]) => convert(String, LLVM.operands(node)[2])
                 for node in LLVM.operands(mod.metadata["air.function_constants"]))
    return [(types[c.name], c) for c in constants]
end

# the functions `fn` (transitively) refers to, and the globals they use
function reachable(fn::LLVM.Function)
    functions = Set{LLVM.Value}([fn])
    globals = LLVM.GlobalVariable[]
    worklist = LLVM.Value[fn]
    seen = Set{LLVM.Value}()
    visit(val) = (val in seen || (push!(seen, val); push!(worklist, val)))
    while !isempty(worklist)
        val = pop!(worklist)
        if val isa LLVM.Function
            push!(functions, val)
            for bb in LLVM.blocks(val), inst in LLVM.instructions(bb), op in LLVM.operands(inst)
                visit(op)
            end
        elseif val isa LLVM.GlobalVariable
            push!(globals, val)
        elseif val isa LLVM.ConstantExpr
            foreach(visit, LLVM.operands(val))
        end
    end
    return functions, globals
end
