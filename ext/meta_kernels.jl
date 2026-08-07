# Device-side meta kernels (mirrors AMDGPU.jl's ext/AMDGPUEnzymeCoreExt/meta_kernels.jl).

@inline function thread_linear_index()
    pos = Metal.thread_position_in_grid_3d()
    tpg = Metal.threads_per_threadgroup_3d()
    ng = Metal.threadgroups_per_grid_3d()
    ex = tpg.x * ng.x
    ey = tpg.y * ng.y
    return (pos.x - 1) + ex * ((pos.y - 1) + ey * (pos.z - 1)) + 1
end

function metaf(config, fn, args::Vararg{Any, N}) where {N}
    EnzymeCore.autodiff_deferred(EnzymeCore.set_runtime_activity(Forward, config), Const(fn), Const, args...)
    return nothing
end

function meta_augf(config, f, tape::Metal.MtlDeviceArray{TapeType}, args::Vararg{Any, N}) where {N, TapeType}
    forward, _ = EnzymeCore.autodiff_deferred_thunk(
        ReverseSplitModified(EnzymeCore.set_runtime_activity(ReverseSplitWithPrimal, config), Val(EnzymeRules.overwritten(config))),
        TapeType,
        Const{Core.Typeof(f)},
        Const{Nothing},
        map(typeof, args)...,
    )
    i = thread_linear_index()
    @inbounds tape[i] = forward(Const(f), args...)[1]
    return nothing
end

function meta_revf(config, f, tape::Metal.MtlDeviceArray{TapeType}, args::Vararg{Any, N}) where {N, TapeType}
    _, reverse = EnzymeCore.autodiff_deferred_thunk(
        ReverseSplitModified(EnzymeCore.set_runtime_activity(ReverseSplitWithPrimal, config), Val(EnzymeRules.overwritten(config))),
        TapeType,
        Const{Core.Typeof(f)},
        Const{Nothing},
        map(typeof, args)...,
    )
    i = thread_linear_index()
    @inbounds reverse(Const(f), args..., tape[i])
    return nothing
end
