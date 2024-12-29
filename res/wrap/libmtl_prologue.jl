@static if Metal.macos_version() < v"15"
    const MTLAllocation = NSObject
end
