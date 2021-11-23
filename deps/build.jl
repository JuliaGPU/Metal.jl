sourcedir = joinpath(dirname(@__DIR__), "cmt")

builddir = joinpath(@__DIR__, "build")
if isdir(builddir)
    rm(builddir; recursive=true)
end
mkdir(builddir)

run(`cmake -S $sourcedir -B $builddir -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=$(@__DIR__) -DCMAKE_BUILD_TYPE=Debug`)
run(`make -C $builddir -j$(Sys.CPU_THREADS) VERBOSE=1`)
