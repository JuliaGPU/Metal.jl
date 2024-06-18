using PrecompileTools: @setup_workload, @compile_workload

@setup_workload begin
    metallib_file = joinpath(dirname(@__DIR__), "test", "dummy.metallib")

    # parsing and writing metal libraries
    metallib = parse(MetalLib, metallib_file)
    sprint(write, metallib)
end
