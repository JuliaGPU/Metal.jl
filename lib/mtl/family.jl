export supports_family

@cenum MTLGPUFamily::NSUInteger begin
    metal3 = 5001 # Metal 3 support

    apple8 = 1008 # M2 & A15
    apple7 = 1007 # M1 & A14
    apple6 = 1006 #      A13
    apple5 = 1005 #      A12
    apple4 = 1004 #      A11
    apple3 = 1003 # A9 & A10
    apple2 = 1002 #      A8
    apple1 = 1001 #      A7

    common3 = 3003
    common2 = 3002
    common1 = 3001

    mac2 = 2002 # Mac family 2 GPU features
end

function supports_family(device::MTLDevice, gpufamily::MTLGPUFamily)
    @objc [device::MTLDevice supportsFamily:gpufamily::MTLGPUFamily]::Bool
end