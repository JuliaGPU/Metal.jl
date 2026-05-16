using PrecompileTools: @setup_workload, @compile_workload

@setup_workload begin
    metallib_file = joinpath(dirname(@__DIR__), "test", "dummy.metallib")

    @compile_workload begin
        # parsing and writing metal libraries
        metallib = parse(MetalLib, metallib_file)
        sprint(write, metallib)

        # compile a trivial kernel to exercise the full compilation pipeline:
        #   mtlfunction → GPUCompiler → LLVM IR → AIR → metallib → link
        mtlfunction(identity, Tuple{Nothing})
    end
end

# Worth the hassle
if isdefined(Base, :Compiler) && isdefined(Base.Compiler, :typeinf_local)
    precompile(Tuple{typeof(Base.Compiler.typeinf_local), GPUCompiler.GPUInterpreter{Base.Compiler.CachedMethodTable{Base.Compiler.OverlayMethodTable}}, Base.Compiler.InferenceState, Base.Compiler.CurrentState})
end
