@static if Sys.isapple() && Metal.macos_version() < v"15"
    const MTLAllocation = NSObject
elseif !Sys.isapple()
    abstract type MTLAllocation end
end
