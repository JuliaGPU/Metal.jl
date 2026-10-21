# TEMPORARY: test this Metal checkout against the unreleased coordinated stack.
# Remove after the v13 dependencies are registered and normal resolution passes.
using TOML
const stack_backend_root=normpath(joinpath(@__DIR__,".."))
const stack_gpuarrays_revision="31bd874b5b18b3b0e5d86ce0f129b0cdf9d3d456"
const stack_keep_sources=any(arg->startswith(arg,"--setup-project="),ARGS)
const stack_checkout=mktempdir(;prefix="metal-sparse-v13-",cleanup=!stack_keep_sources)
run(`git clone --quiet --filter=blob:none https://github.com/JuliaGPU/GPUArrays.jl $stack_checkout`)
run(`git -C $stack_checkout checkout --quiet --detach $stack_gpuarrays_revision`)
readchomp(`git -C $stack_checkout rev-parse HEAD`)==stack_gpuarrays_revision || error("wrong GPUArrays revision")
ENV["GPUARRAYS_V13_STACK_BACKEND"]=stack_backend_root
const stack_preferences=joinpath(stack_backend_root,"LocalPreferences.toml")
isfile(stack_preferences) && (ENV["GPUARRAYS_V13_STACK_PREFERENCES"]=stack_preferences)
const stack_arguments=copy(ARGS)
const stack_setup_arg=findfirst(arg->startswith(arg,"--setup-project="),stack_arguments)
if stack_setup_arg!==nothing
    target=split(stack_arguments[stack_setup_arg],'=';limit=2)[2]
    target in ("docs","perf","examples") || error("unsupported setup project")
    ENV["GPUARRAYS_V13_STACK_SETUP_PROJECT"]=joinpath(stack_backend_root,target)
    deleteat!(stack_arguments,stack_setup_arg)
    push!(stack_arguments,"--setup-only")
end
empty!(ARGS)
append!(ARGS,["Metal";stack_arguments])
include(joinpath(stack_checkout,".buildkite","sparse-v13-stack.jl"))
