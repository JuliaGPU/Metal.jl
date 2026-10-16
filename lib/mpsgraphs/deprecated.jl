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

function graph_sort!(out, input; dim::Integer=1, rev::Bool=false)
    Base.depwarn("`MPSGraphs.graph_sort!(out, input; dim)` is deprecated, use `MPSGraphs.sort!(out, input; dims)` instead.",
                 :graph_sort!)
    return sort!(out, input; dims=dim, rev)
end

function graph_sortperm!(index, input; dim::Integer=1, rev::Bool=false)
    Base.depwarn("`MPSGraphs.graph_sortperm!(index, input; dim)` is deprecated, use `MPSGraphs.sortperm!(index, input; dims)` instead.",
                 :graph_sortperm!)
    return sortperm!(index, input; dims=dim, rev)
end

function graph_matmul!(c, a, b, alpha::Number=true, beta::Number=false,
                       transpose_a='N', transpose_b='N')
    Base.depwarn("`MPSGraphs.graph_matmul!(c, a, b, α, β, tA, tB)` is deprecated, use `MPSGraphs.matmul!(c, a, b, α, β; tA, tB)` instead.",
                 :graph_matmul!)
    return matmul!(c, a, b, alpha, beta; tA=transpose_a, tB=transpose_b)
end

function graph_matvecmul!(c, a, b, alpha::Number=true, beta::Number=false, transpose='N')
    Base.depwarn("`MPSGraphs.graph_matvecmul!(c, a, b, α, β, tA)` is deprecated, use `MPSGraphs.matvecmul!(c, a, b, α, β; tA)` instead.",
                 :graph_matvecmul!)
    return matvecmul!(c, a, b, alpha, beta; tA=transpose)
end

for (old, new) in ((:graph_softmax!, :softmax!), (:graph_logsoftmax!, :logsoftmax!),
                   (:graph_softmax_grad!, :softmax_grad!),
                   (:graph_logsoftmax_grad!, :logsoftmax_grad!),
                   (:graph_conv!, :conv!), (:graph_conv_data_grad!, :conv_data_grad!),
                   (:graph_conv_filter_grad!, :conv_filter_grad!),
                   (:graph_maxpool!, :maxpool!), (:graph_maxpool_grad!, :maxpool_grad!),
                   (:graph_meanpool!, :meanpool!), (:graph_meanpool_grad!, :meanpool_grad!))
    msg = "`MPSGraphs.$old` is deprecated, use `MPSGraphs.$new` instead."
    @eval function $old(args...; kwargs...)
        Base.depwarn($msg, $(QuoteNode(old)))
        return $new(args...; kwargs...)
    end
end
