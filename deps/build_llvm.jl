using Scratch, CMake_jll, Libdl, Preferences

Metal = Base.UUID("dde4c033-4e86-420c-a63e-0dd931031962")

# get scratch directories
source_dir = get_scratch!(Metal, "llvm")
install_dir = get_scratch!(Metal, "llvm-metal")

# get sources
if isdir(joinpath(source_dir, ".git"))
    run(`git -C $source_dir fetch`)
else
    rm(source_dir; recursive=true)
    run(`git clone https://github.com/JuliaGPU/llvm-metal.git $source_dir`)
end
llvm_ver = Int(Base.libllvm_version.major)
run(`git -C $source_dir reset --hard origin/llvm_release_$(llvm_ver)`)

# compile and install
isdir(install_dir) && rm(install_dir; recursive=true)
mktempdir() do build_dir
    run(`$(cmake()) -DCMAKE_INSTALL_PREFIX=$(install_dir) -B$(build_dir) -S$(source_dir)/llvm -DCMAKE_BUILD_TYPE=Debug -DLLVM_TARGETS_TO_BUILD=Metal`)
    run(`$(cmake()) --build $(build_dir) --parallel $(Sys.CPU_THREADS) --target metallib-as --target metallib-dis`)
    run(`$(cmake()) --install $(build_dir) --component metallib-as`)
    run(`$(cmake()) --install $(build_dir) --component metallib-dis`)
end

# Tell Metal_LLVM_Tools_jll to load our executables instead of the default artifact ones
set_preferences!(
    joinpath(dirname(@__DIR__), "LocalPreferences.toml"),
    "Metal_LLVM_Tools_jll",
    "metallib_as_path" => joinpath(install_dir, "bin", "metallib-as"),
    "metallib_dis_path" => joinpath(install_dir, "bin", "metallib-dis"),
    force=true,
)

# Copy the preferences to `test/` as well to work around Pkg.jl#2500
cp(joinpath(dirname(@__DIR__), "LocalPreferences.toml"),
   joinpath(dirname(@__DIR__), "test", "LocalPreferences.toml"); force=true)

# XXX: only do this if things have changed? or env var? or label?
