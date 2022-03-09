using Scratch, CMake_jll

Metal = Base.UUID("dde4c033-4e86-420c-a63e-0dd931031962")

# get a scratch directory
scratch_dir = get_scratch!(Metal, "cmt")
isdir(scratch_dir) && rm(scratch_dir; recursive=true)
source_dir = joinpath(dirname(@__DIR__), "cmt")

mktempdir() do build_dir
    run(`$(cmake()) -DCMAKE_INSTALL_PREFIX=$(scratch_dir) -B$(build_dir) -S$(source_dir) -DCMAKE_BUILD_TYPE=Debug`)
    run(`$(cmake()) --build $(build_dir) --parallel $(Sys.CPU_THREADS)`)
    run(`$(cmake()) --install $(build_dir)`)
end