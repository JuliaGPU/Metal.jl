export endEncoding!, updateFence!, waitForFence!
export barrierAfterEncoderStages!, barrierAfterQueueStages!, barrierAfterStages!

# @objcwrapper managed = true MTL4CommandEncoder <: NSObject

"""
    updateFence!(encoder, fence, [afterEncoderStages])

Update `fence` once the given stages of the work encoded so far in `encoder` complete.
"""
function updateFence!(encoder::MTL4CommandEncoderLike, fence::MTLFence,
                      afterEncoderStages::MTLStages=MTLStageAll)
    @objc [encoder::id{MTL4CommandEncoder} updateFence:fence::id{MTLFence}
                                afterEncoderStages:afterEncoderStages::MTLStages]::Nothing
end

"""
    waitForFence!(encoder, fence, [beforeEncoderStages])

Block the given stages of subsequently encoded work in `encoder` until `fence` is updated.
"""
function waitForFence!(encoder::MTL4CommandEncoderLike, fence::MTLFence,
                       beforeEncoderStages::MTLStages=MTLStageAll)
    @objc [encoder::id{MTL4CommandEncoder} waitForFence:fence::id{MTLFence}
                               beforeEncoderStages:beforeEncoderStages::MTLStages]::Nothing
end

"""
    barrierAfterEncoderStages!(encoder, after, before, [visibilityOptions])

Order work *within* `encoder`: commands encoded after this barrier do not start their
`before` stages until the `after` stages of all previously encoded commands complete.

Metal 4 command encoders execute their commands concurrently by default, so this is what
gives consecutive dispatches in one encoder the serial, program-order semantics that Metal
3's compute encoder provided implicitly.
"""
function barrierAfterEncoderStages!(encoder::MTL4CommandEncoderLike,
                                    afterEncoderStages::MTLStages=MTLStageAll,
                                    beforeEncoderStages::MTLStages=MTLStageAll,
                                    visibilityOptions::MTL4VisibilityOptions=MTL4VisibilityOptionDevice)
    @objc [encoder::id{MTL4CommandEncoder} barrierAfterEncoderStages:afterEncoderStages::MTLStages
                                              beforeEncoderStages:beforeEncoderStages::MTLStages
                                                visibilityOptions:visibilityOptions::MTL4VisibilityOptions]::Nothing
end

"""
    barrierAfterQueueStages!(encoder, after, before, [visibilityOptions])

Block the `before` stages of work encoded after this barrier until the `after` stages of
all work previously committed to the queue complete.
"""
function barrierAfterQueueStages!(encoder::MTL4CommandEncoderLike,
                                  afterQueueStages::MTLStages=MTLStageAll,
                                  beforeStages::MTLStages=MTLStageAll,
                                  visibilityOptions::MTL4VisibilityOptions=MTL4VisibilityOptionDevice)
    @objc [encoder::id{MTL4CommandEncoder} barrierAfterQueueStages:afterQueueStages::MTLStages
                                                     beforeStages:beforeStages::MTLStages
                                                visibilityOptions:visibilityOptions::MTL4VisibilityOptions]::Nothing
end

"""
    barrierAfterStages!(encoder, after, beforeQueue, [visibilityOptions])

Block subsequently committed queue work until the `after` stages of the work encoded so far
in `encoder` complete.
"""
function barrierAfterStages!(encoder::MTL4CommandEncoderLike,
                             afterStages::MTLStages=MTLStageAll,
                             beforeQueueStages::MTLStages=MTLStageAll,
                             visibilityOptions::MTL4VisibilityOptions=MTL4VisibilityOptionDevice)
    @objc [encoder::id{MTL4CommandEncoder} barrierAfterStages:afterStages::MTLStages
                                            beforeQueueStages:beforeQueueStages::MTLStages
                                            visibilityOptions:visibilityOptions::MTL4VisibilityOptions]::Nothing
end

function push_debug_group!(encoder::MTL4CommandEncoderLike, name::Union{String,NSString})
    @objc [encoder::id{MTL4CommandEncoder} pushDebugGroup:name::id{NSString}]::Nothing
end

function pop_debug_group!(encoder::MTL4CommandEncoderLike)
    @objc [encoder::id{MTL4CommandEncoder} popDebugGroup]::Nothing
end

endEncoding!(ce::MTL4CommandEncoderLike) =
    @objc [ce::id{MTL4CommandEncoder} endEncoding]::Nothing

function Base.close(ce::MTL4CommandEncoderLike)
    try
        endEncoding!(ce)
    finally
        release(ce)
    end
    return nothing
end
