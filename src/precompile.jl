using PrecompileTools: @setup_workload, @compile_workload

@setup_workload begin
    metallib_file = joinpath(dirname(@__DIR__), "test", "dummy.metallib")

    @compile_workload begin
        # parsing and writing metal libraries
        metallib = parse(MetalLib, metallib_file)
        sprint(write, metallib)

        # launch a trivial kernel to precompile the full pipeline:
        #   mtlfunction → GPUCompiler → LLVM IR → AIR → metallib → link → launch
        # (GPU submission is skipped during precompilation, but the entire
        #  encoding path — encode_arguments!, command buffer setup, etc. — runs)
        kernel() = return
        @metal kernel()

        # launch a realistic kernel with array arguments
        a = MtlArray(Float32[1])
        b = MtlArray(Float32[1])
        c = MtlArray(Float32[0])
        function precompile_vadd(a, b, c)
            i = thread_position_in_grid().x
            c[i] = a[i] + b[i]
            return
        end
        @metal precompile_vadd(a, b, c)

        # also exercise 2D arrays (common in real workloads)
        a2 = MtlArray(Float32[1 1])
        b2 = MtlArray(Float32[1 1])
        c2 = MtlArray(Float32[0 0])
        @metal precompile_vadd(a2, b2, c2)

        # precompile MtlArray → Array copy-back
        Array(c)
        Array(c2)
    end
end

# GPUCompiler macro-expansion utilities (compiled at every @metal callsite).
# split_kwargs is called with 3 Vector{Symbol} groups (MACRO/COMPILER/LAUNCH_KWARGS).
precompile(Tuple{typeof(GPUCompiler.split_kwargs), Tuple{Expr}, Vector{Symbol}, Vector{Symbol}, Vector{Symbol}})
precompile(Tuple{typeof(GPUCompiler.assign_args!), Expr, Vector{Any}})
