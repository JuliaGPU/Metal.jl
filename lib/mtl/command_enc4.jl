export endEncoding!, barrierAfterStages!

# @objcwrapper immutable=true MTL4CommandEncoder <: NSObject

function barrierAfterStages!(encoder::MTL4CommandEncoder, afterStages::MTLStages=MTLStageAll, queueStages::MTLStages=MTLStageAll, visibilityOptions::MTL4VisibilityOptions=MTL4VisibilityOptionDevice)
    @objc [encoder::id{MTL4CommandEncoder} barrierAfterStages:afterStages::MTLStages
                                            beforeQueueStages:queueStages::MTLStages
                                            visibilityOptions:visibilityOptions::MTL4VisibilityOptions]::Nothing
end

endEncoding!(ce::MTL4CommandEncoder) = @objc [ce::id{MTL4CommandEncoder} endEncoding]::Nothing
Base.close(ce::MTL4CommandEncoder) = endEncoding!(ce)
