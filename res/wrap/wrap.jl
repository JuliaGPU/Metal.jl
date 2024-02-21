using Clang.Generators

@add_def off_t

function main()
    options = load_options(joinpath(@__DIR__, "wrap.toml"))

    args = get_default_args()
    includedir = joinpath(dirname(@__DIR__), "deps", "cmt", "include")
    push!(args, "-I$includedir")

    headers = [joinpath(includedir, "cmt", "cmt.h")]

    ctx = create_context(headers, args, options)

    build!(ctx, BUILDSTAGE_NO_PRINTING)

    # tweak exprs
    for node in get_nodes(ctx.dag)
        exprs = get_exprs(node)
        for (i, expr) in enumerate(exprs)
            exprs[i] = make_opaque(expr)
        end
    end

    build!(ctx, BUILDSTAGE_PRINTING_ONLY)
end

# cmt declares all Ns/Mt objects as `typedef void`, instead of using opaque types.
# make those definitions opaque instead to avoid potential conversiosn between them.
#
# TODO: fix cmt? consider LLVM's approach; look for LLVMModuleRef
function make_opaque(x::Expr)
    Meta.isexpr(x, :const) || return x
    y = x.args[1]
    Meta.isexpr(y, :(=)) || return x
    var, val = y.args
    if (startswith(String(var), "Mt") || startswith(String(var), "Ns")) && val === :Cvoid
        return :(struct $var end)
    end
    return x
end

isinteractive() || main()
