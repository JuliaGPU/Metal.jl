using Metal

srcpath = dirname(pathof(Metal))*"/../lib/core/kernels/vadd.metal"
tmpdir = tempdir()

fname = "vadd"
airname = joinpath(tmpdir, fname*".air")
libname = joinpath(tmpdir, fname*".metallib")

run(`xcrun -sdk macosx metal -c $srcpath -o $airname`)
run(`xcrun -sdk macosx metallib $airname -o $libname`)
