using PrecompileTools: @setup_workload, @compile_workload

@setup_workload begin
    metallib_file = joinpath(dirname(@__DIR__), "test", "dummy.metallib")

    # parsing and writing metal libraries
    metallib = parse(MetalLib, metallib_file)
    sprint(write, metallib)
end

precompile(compile_to_metallib, (CompilerJob,))
precompile(Tuple{typeof(GPUCompiler.finish_ir!), GPUCompiler.CompilerJob{GPUCompiler.MetalCompilerTarget, Metal.MetalCompilerParams}, LLVM.Module, LLVM.Function})
precompile(Tuple{typeof(GPUCompiler.finish_module!), GPUCompiler.CompilerJob{GPUCompiler.MetalCompilerTarget, Metal.MetalCompilerParams}, LLVM.Module, LLVM.Function})
precompile(Tuple{typeof(GPUCompiler.check_ir), GPUCompiler.CompilerJob{GPUCompiler.MetalCompilerTarget, Metal.MetalCompilerParams}, LLVM.Module})
