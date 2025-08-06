export endEncoding!, updateFence!, waitForFence
export barrierAfterEncoderStages!, barrierAfterQueueStages!, barrierAfterStages!

# @objcwrapper immutable=true MTL4CommandEncoder <: NSObject

function updateFence!(encoder::MTL4CommandEncoder, fence::MTLFence, afterEncoderStages::MTLStages=MTLStageAll)
    @objc [encoder::id{MTL4CommandEncoder} updateFence:fence::id{MTLFence}
                                            afterEncoderStages:afterEncoderStages::MTLStages]::Nothing
end

function waitForFence(encoder::MTL4CommandEncoder, fence::MTLFence, beforeEncoderStages::MTLStages=MTLStageAll)
    @objc [encoder::id{MTL4CommandEncoder} waitForFence:fence::id{MTLFence}
                                            beforeEncoderStages:afterEncoderStages::MTLStages]::Nothing
end

function barrierAfterEncoderStages!(encoder::MTL4CommandEncoder, afterEncoderStages::MTLStages=MTLStageAll, beforeEncoderStages::MTLStages=MTLStageAll, visibilityOptions::MTL4VisibilityOptions=MTL4VisibilityOptionResourceAlias)
    @objc [encoder::id{MTL4CommandEncoder} barrierAfterEncoderStages:afterEncoderStages::MTLStages
                                            beforeEncoderStages:beforeEncoderStages::MTLStages
                                            visibilityOptions:visibilityOptions::MTL4VisibilityOptions]::Nothing
end

function barrierAfterQueueStages!(encoder::MTL4CommandEncoder, afterQueueStages::MTLStages=MTLStageAll, beforeStages::MTLStages=MTLStageAll, visibilityOptions::MTL4VisibilityOptions=MTL4VisibilityOptionResourceAlias)
    @objc [encoder::id{MTL4CommandEncoder} barrierAfterQueueStages:afterQueueStages::MTLStages
                                            beforeStages:beforeStages::MTLStages
                                            visibilityOptions:visibilityOptions::MTL4VisibilityOptions]::Nothing
end

function barrierAfterStages!(encoder::MTL4CommandEncoder, afterStages::MTLStages=MTLStageAll, beforeQueueStages::MTLStages=MTLStageAll, visibilityOptions::MTL4VisibilityOptions=MTL4VisibilityOptionResourceAlias)
    @objc [encoder::id{MTL4CommandEncoder} barrierAfterStages:afterStages::MTLStages
                                            beforeQueueStages:beforeQueueStages::MTLStages
                                            visibilityOptions:visibilityOptions::MTL4VisibilityOptions]::Nothing
end

endEncoding!(ce::MTL4CommandEncoder) = @objc [ce::id{MTL4CommandEncoder} endEncoding]::Nothing
Base.close(ce::MTL4CommandEncoder) = endEncoding!(ce)
