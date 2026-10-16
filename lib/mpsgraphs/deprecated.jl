# names used before the MPSGraphs array operations were documented

function graph_mapreducedim!(op, out, input)
    Base.depwarn("`MPSGraphs.graph_mapreducedim!` is deprecated, use `MPSGraphs.reduce!` instead.",
                 :graph_mapreducedim!)
    return reduce!(op, out, input)
end

function graph_scan!(op, out, input; dim::Integer=1)
    Base.depwarn("`MPSGraphs.graph_scan!(op, out, input; dim)` is deprecated, use `MPSGraphs.accumulate!(op, out, input; dims)` instead.",
                 :graph_scan!)
    return accumulate!(op, out, input; dims=dim)
end
