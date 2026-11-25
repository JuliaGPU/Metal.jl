@public AS

"""
    Metal.AS

The address spaces of pointers in Metal's device code, for the `A` parameter of
`Core.LLVMPtr{T,A}`, e.g. of [`MtlDeviceArray`](@ref Metal.MtlDeviceArray)s: `AS.Device`
for device memory, `AS.Constant` for constant memory, and `AS.ThreadGroup` for threadgroup
memory.
"""
module AS
    const Generic               = 0 # No Generic address space?
    const Device                = 1 # Checked
    const Constant              = 2 # Checked
    const ThreadGroup           = 3 # Checked
    const Thread                = 4 # Ends up same as Device?
    const ThreadGroup_ImgBlock  = 5 # Like ThreadGroup but only accessible from
    const Ray                   = 6
end
