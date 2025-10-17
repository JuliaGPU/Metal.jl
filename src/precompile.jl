using PrecompileTools: @setup_workload, @compile_workload

@setup_workload begin
    metallib_file = joinpath(dirname(@__DIR__), "test", "dummy.metallib")

    # parsing and writing metal libraries
    metallib = parse(MetalLib, metallib_file)
    sprint(write, metallib)
end

precompile(compile, (CompilerJob,))
precompile(Tuple{typeof(GPUCompiler.finish_ir!), GPUCompiler.CompilerJob{GPUCompiler.MetalCompilerTarget, Metal.MetalCompilerParams}, LLVM.Module, LLVM.Function})
precompile(Tuple{typeof(GPUCompiler.finish_module!), GPUCompiler.CompilerJob{GPUCompiler.MetalCompilerTarget, Metal.MetalCompilerParams}, LLVM.Module, LLVM.Function})
precompile(Tuple{typeof(GPUCompiler.check_ir), GPUCompiler.CompilerJob{GPUCompiler.MetalCompilerTarget, Metal.MetalCompilerParams}, LLVM.Module})
precompile(Tuple{typeof(GPUCompiler.actual_compilation), Base.Dict{Any, Any}, Core.MethodInstance, UInt64, GPUCompiler.CompilerConfig{GPUCompiler.MetalCompilerTarget, Metal.MetalCompilerParams}, typeof(Metal.compile), typeof(Metal.link)})

# Worth the hassle
if isdefined(Base, :Compiler) && isdefined(Base.Compiler, :typeinf_local)
    precompile(Tuple{typeof(Base.Compiler.typeinf_local), GPUCompiler.GPUInterpreter{Base.Compiler.CachedMethodTable{Base.Compiler.OverlayMethodTable}}, Base.Compiler.InferenceState, Base.Compiler.CurrentState})
end
