using Scratch, CMake_jll, Libdl, Preferences

Metal = Base.UUID("dde4c033-4e86-420c-a63e-0dd931031962")

# get a scratch directory
scratch_dir = get_scratch!(Metal, "cmt")
isdir(scratch_dir) && rm(scratch_dir; recursive=true)
source_dir = joinpath(@__DIR__, "cmt")

mktempdir() do build_dir
    run(`$(cmake()) -DCMAKE_INSTALL_PREFIX=$(scratch_dir) -B$(build_dir) -S$(source_dir) -DCMAKE_BUILD_TYPE=Debug`)
    run(`$(cmake()) --build $(build_dir) --parallel $(Sys.CPU_THREADS)`)
    run(`$(cmake()) --install $(build_dir)`)
end

# Discover built libraries
built_libs = filter(readdir(joinpath(scratch_dir, "lib"))) do file
    endswith(file, ".$(Libdl.dlext)")
end
lib_path = joinpath(scratch_dir, "lib", only(built_libs))
isfile(lib_path) || error("Could not find library $lib_path in build directory")

# Tell cmt_jll to load our library instead of the default artifact one
set_preferences!(
    joinpath(dirname(@__DIR__), "LocalPreferences.toml"),
    "cmt_jll",
    "libcmt_path" => lib_path;
    force=true,
)

# Copy the preferences to `test/` as well to work around Pkg.jl#2500
cp(joinpath(dirname(@__DIR__), "LocalPreferences.toml"),
   joinpath(dirname(@__DIR__), "test", "LocalPreferences.toml"); force=true)
