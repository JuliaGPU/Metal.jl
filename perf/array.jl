const m = 512
const n = 1000
const m_long = 3
const n_long = 1_000_000

group = addgroup!(SUITE, "array")

for (S, smname) in [(Metal.PrivateStorage,"private"), (Metal.SharedStorage,"shared")]
    let group = addgroup!(group, smname)

        # generate some arrays
        cpu_mat = rand(rng, Float32, m, n)
        gpu_mat = MtlMatrix{Float32,S}(cpu_mat)
        gpu_vec = reshape(gpu_mat, length(gpu_mat))
        gpu_mat_ints = MtlMatrix{Int64,S}(rand(rng, -10:10, m, n))
        gpu_vec_ints = reshape(gpu_mat_ints, length(gpu_mat_ints))
        gpu_mat_bools = MtlMatrix{Bool,S}(rand(rng, Bool, m, n))
        gpu_vec_bools = reshape(gpu_mat_bools, length(gpu_mat_bools))

        group["copy"] = @benchmarkable Metal.@sync copy($gpu_mat)

        gpu_mat2 = copy(gpu_mat)
        let group = addgroup!(group, "copyto!")
            group["cpu_to_gpu"] = @benchmarkable Metal.@sync copyto!($gpu_mat, $cpu_mat)
            group["gpu_to_cpu"] = @benchmarkable Metal.@sync copyto!($cpu_mat, $gpu_mat)
            group["gpu_to_gpu"] = @benchmarkable Metal.@sync copyto!($gpu_mat2, $gpu_mat)
        end

        let group = addgroup!(group, "iteration")
            group["scalar"] = @benchmarkable Metal.@allowscalar [$gpu_vec[i] for i in 1:10]

            group["logical"] = @benchmarkable $gpu_vec[$gpu_vec_bools]

            let group = addgroup!(group, "findall")
                group["bool"] = @benchmarkable findall($gpu_vec_bools)
                group["int"] = @benchmarkable findall(isodd, $gpu_vec_ints)
            end

            let group = addgroup!(group, "findfirst")
                group["bool"] = @benchmarkable findfirst($gpu_vec_bools)
                group["int"] = @benchmarkable findfirst(isodd, $gpu_vec_ints)
            end

            let group = addgroup!(group, "findmin") # findmax
                group["1d"] = @benchmarkable Metal.@sync findmin($gpu_vec)
                group["2d"] = @benchmarkable Metal.@sync findmin($gpu_mat; dims=1)
            end
        end
    end
end

cpu_mat = rand(rng, Float32, m, n)
gpu_mat = MtlMatrix{Float32}(cpu_mat)
gpu_mat_long = MtlMatrix{Float32}(rand(rng, Float32, m_long, n_long))
gpu_vec = reshape(gpu_mat, length(gpu_mat))
gpu_arr_3d = reshape(gpu_mat, (m, 40, 25))
gpu_arr_4d = reshape(gpu_mat, (m, 10, 10, 10))
gpu_mat_ints = MtlMatrix{Int64}(rand(rng, -10:10, m, n))
gpu_mat_long_ints = MtlMatrix{Int64}(rand(rng, -10:10, m_long, n_long))
gpu_vec_ints = reshape(gpu_mat_ints, length(gpu_mat_ints))

# let group = addgroup!(group, "reverse")
#     group["1d"] = @benchmarkable Metal.@sync reverse($gpu_vec)
#     group["2d"] = @benchmarkable Metal.@sync reverse($gpu_mat; dims=1)
#     group["1d_inplace"] = @benchmarkable Metal.@sync reverse!($gpu_vec)
#     group["2d_inplace"] = @benchmarkable Metal.@sync reverse!($gpu_mat; dims=1)
# end
group["construct"] = @benchmarkable MtlArray{Int,1}(undef, 1)

group["broadcast"] = @benchmarkable Metal.@sync $gpu_mat .= 0f0

# no need to test inplace version, which performs the same operation (but with an alloc)
let group = addgroup!(group, "accumulate")
    let group = addgroup!(group, "Float32")
        group["1d"] = @benchmarkable Metal.@sync accumulate(+, $gpu_vec)
        group["dims=1"] = @benchmarkable Metal.@sync accumulate(+, $gpu_mat; dims=1)
        group["dims=2"] = @benchmarkable Metal.@sync accumulate(+, $gpu_mat; dims=2)
        group["dims=1L"] = @benchmarkable Metal.@sync accumulate(+, $gpu_mat_long; dims=1)
        group["dims=2L"] = @benchmarkable Metal.@sync accumulate(+, $gpu_mat_long; dims=2)
    end
    let group = addgroup!(group, "Int64")
        group["1d"] = @benchmarkable Metal.@sync accumulate(+, $gpu_vec_ints)
        group["dims=1"] = @benchmarkable Metal.@sync accumulate(+, $gpu_mat_ints; dims=1)
        group["dims=2"] = @benchmarkable Metal.@sync accumulate(+, $gpu_mat_ints; dims=2)
        group["dims=1L"] = @benchmarkable Metal.@sync accumulate(+, $gpu_mat_long_ints; dims=1)
        group["dims=2L"] = @benchmarkable Metal.@sync accumulate(+, $gpu_mat_long_ints; dims=2)
    end
end

let group = addgroup!(group, "reductions")
    let group = addgroup!(group, "reduce")
        let group = addgroup!(group, "Float32")
            group["1d"] = @benchmarkable Metal.@sync reduce(+, $gpu_vec)
            group["dims=1"] = @benchmarkable Metal.@sync reduce(+, $gpu_mat; dims=1)
            group["dims=2"] = @benchmarkable Metal.@sync reduce(+, $gpu_mat; dims=2)
            group["dims=1L"] = @benchmarkable Metal.@sync reduce(+, $gpu_mat_long; dims=1)
            group["dims=2L"] = @benchmarkable Metal.@sync reduce(+, $gpu_mat_long; dims=2)
        end
        let group = addgroup!(group, "Int64")
            group["1d"] = @benchmarkable Metal.@sync reduce(+, $gpu_vec_ints)
            group["dims=1"] = @benchmarkable Metal.@sync reduce(+, $gpu_mat_ints; dims=1)
            group["dims=2"] = @benchmarkable Metal.@sync reduce(+, $gpu_mat_ints; dims=2)
            group["dims=1L"] = @benchmarkable Metal.@sync reduce(+, $gpu_mat_long_ints; dims=1)
            group["dims=2L"] = @benchmarkable Metal.@sync reduce(+, $gpu_mat_long_ints; dims=2)
        end
    end

    let group = addgroup!(group, "mapreduce")
        let group = addgroup!(group, "Float32")
            group["1d"] = @benchmarkable Metal.@sync mapreduce(x->x+1, +, $gpu_vec)
            group["dims=1"] = @benchmarkable Metal.@sync mapreduce(x->x+1, +, $gpu_mat; dims=1)
            group["dims=2"] = @benchmarkable Metal.@sync mapreduce(x->x+1, +, $gpu_mat; dims=2)
            group["dims=1L"] = @benchmarkable Metal.@sync mapreduce(x->x+1, +, $gpu_mat_long; dims=1)
            group["dims=2L"] = @benchmarkable Metal.@sync mapreduce(x->x+1, +, $gpu_mat_long; dims=2)
        end
        let group = addgroup!(group, "Int64")
            group["1d"] = @benchmarkable Metal.@sync mapreduce(x->x+1, +, $gpu_vec_ints)
            group["dims=1"] = @benchmarkable Metal.@sync mapreduce(x->x+1, +, $gpu_mat_ints; dims=1)
            group["dims=2"] = @benchmarkable Metal.@sync mapreduce(x->x+1, +, $gpu_mat_ints; dims=2)
            group["dims=1L"] = @benchmarkable Metal.@sync mapreduce(x->x+1, +, $gpu_mat_long_ints; dims=1)
            group["dims=2L"] = @benchmarkable Metal.@sync mapreduce(x->x+1, +, $gpu_mat_long_ints; dims=2)
        end
    end

    # used by sum, prod, minimum, maximum, all, any, count
end

let group = addgroup!(group, "random")
    let group = addgroup!(group, "rand")
        group["Float32"] = @benchmarkable Metal.@sync Metal.rand(Float32, m*n)
        group["Int64"] = @benchmarkable Metal.@sync Metal.rand(Int64, m*n)
    end

    let group = addgroup!(group, "rand!")
        group["Float32"] = @benchmarkable Metal.@sync Metal.rand!($gpu_vec)
        group["Int64"] = @benchmarkable Metal.@sync Metal.rand!($gpu_vec_ints)
    end

    let group = addgroup!(group, "randn")
        group["Float32"] = @benchmarkable Metal.@sync Metal.randn(Float32, m*n)
    end

    let group = addgroup!(group, "randn!")
        group["Float32"] = @benchmarkable Metal.@sync Metal.randn!($gpu_vec)
    end
end

# let group = addgroup!(group, "sorting")
#     group["1d"] = @benchmarkable Metal.@sync sort($gpu_vec)
#     group["2d"] = @benchmarkable Metal.@sync sort($gpu_mat; dims=1)
#     group["by"] = @benchmarkable Metal.@sync sort($gpu_vec; by=sin)
# end

let group = addgroup!(group, "permutedims")
    group["2d"] = @benchmarkable Metal.@sync permutedims($gpu_mat, (2,1))
    group["3d"] = @benchmarkable Metal.@sync permutedims($gpu_arr_3d, (3,1,2))
    group["4d"] = @benchmarkable Metal.@sync permutedims($gpu_arr_4d, (2,1,4,3))
end
