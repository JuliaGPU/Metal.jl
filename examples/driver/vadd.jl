using Test
using Metal

dims = (3,4)
a = round.(rand(Float32, dims) * 100)
b = round.(rand(Float32, dims) * 100)
c = similar(a)

d_a = MtlArray(a)
d_b = MtlArray(b)
d_c = MtlArray(c)

len = prod(dims)

# Get the Metal device
dev = device()
src = read(joinpath(@__DIR__, "vadd.metal"), String)
# Create a Metal library from a Metal Shading Language File
lib = MtlLibrary(dev, src, MtlCompileOptions())
# Parse the compiled kernel from the library
vadd = Metal.MtlKernel(dev, lib, "add_vectors")
# Call the kernel passing the Metal arrays by their buffers
Metal.mtlcall(vadd, Tuple{Core.LLVMPtr{Float32, 1},Core.LLVMPtr{Float32, 1},Core.LLVMPtr{Float32, 1}}, d_a.buffer, d_b.buffer, d_c.buffer; threads=len)

@test a+b ≈ Array(d_c)

# Reset for next test
lib  = nothing
vadd = nothing
d_c  = MtlArray(c)

# Create a Metal library from a Metal library file
lib = MtlLibraryFromFile(dev, joinpath(@__DIR__, "vadd.metallib"))
vadd = Metal.MtlKernel(dev, lib, "add_vectors")
Metal.mtlcall(vadd, Tuple{Core.LLVMPtr{Float32, 1},Core.LLVMPtr{Float32, 1},Core.LLVMPtr{Float32, 1}}, d_a.buffer, d_b.buffer, d_c.buffer; threads=len)

@test a+b ≈ Array(d_c)
