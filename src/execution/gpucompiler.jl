# While Metal.jl is still in development, clarify undefined MetalCompilerTarget error
isdefined(GPUCompiler, :MetalCompilerTarget) ||
    error("MetalCompilerTarget is undefined. \
            A special fork of GPUCompiler is currently required for this package. The link is in the top-level README. \
            Dev that GPUCompiler version then try precompiling Metal.jl again.")

const ci_cache = GPUCompiler.CodeCache()

struct MetalCompilerParams <: GPUCompiler.AbstractCompilerParams end

MetalCompilerJob = CompilerJob{MetalCompilerTarget,MetalCompilerParams}

GPUCompiler.runtime_module(::MetalCompilerJob) = Metal

GPUCompiler.ci_cache(::MetalCompilerJob) = ci_cache

GPUCompiler.method_table(::MetalCompilerJob) = method_table