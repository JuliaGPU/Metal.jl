const ci_cache = GPUCompiler.CodeCache()

struct MetalCompilerParams <: GPUCompiler.AbstractCompilerParams end

MetalCompilerJob = CompilerJob{MetalCompilerTarget,MetalCompilerParams}

GPUCompiler.runtime_module(::MetalCompilerJob) = Metal

GPUCompiler.ci_cache(::MetalCompilerJob) = ci_cache

GPUCompiler.method_table(::MetalCompilerJob) = method_table