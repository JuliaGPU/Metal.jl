# compatibility with EnzymeCore
module EnzymeCoreExt

using Metal
import Metal: GPUCompiler, MetalBackend

import EnzymeCore
using EnzymeCore.EnzymeRules

# the compiler job that kernels for Metal are compiled with, for Enzyme to compile the
# derivatives of kernels (e.g. by KernelAbstractions' Enzyme extension) and their tapes
function EnzymeCore.compiler_job_from_backend(
        ::MetalBackend, @nospecialize(F::Type), @nospecialize(TT::Type)
    )
    mi = GPUCompiler.methodinstance(F, TT)
    return GPUCompiler.CompilerJob(mi, Metal.compiler_config(Metal.device()))
end

# waiting for the GPU has no derivative
EnzymeRules.inactive(::typeof(Metal.synchronize), args...; kwargs...) = nothing

end
