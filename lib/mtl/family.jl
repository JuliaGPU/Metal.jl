export supports_family

@cenum MTLGPUFamily::NSUInteger begin
    MTLGPUFamilyMetal3 = 5001 # Metal 3 support

    MTLGPUFamilyApple8 = 1008 # M2 & A15
    MTLGPUFamilyApple7 = 1007 # M1 & A14
    MTLGPUFamilyApple6 = 1006 #      A13
    MTLGPUFamilyApple5 = 1005 #      A12
    MTLGPUFamilyApple4 = 1004 #      A11
    MTLGPUFamilyApple3 = 1003 # A9 & A10
    MTLGPUFamilyApple2 = 1002 #      A8
    MTLGPUFamilyApple1 = 1001 #      A7

    MTLGPUFamilyCommon3 = 3003
    MTLGPUFamilyCommon2 = 3002
    MTLGPUFamilyCommon1 = 3001

    MTLGPUFamilyMac2 = 2002 # Mac family 2 GPU features
end

function supports_family(device::MTLDevice, gpufamily::MTLGPUFamily)
    @objc [device::MTLDevice supportsFamily:gpufamily::MTLGPUFamily]::Bool
end