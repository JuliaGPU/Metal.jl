group = addgroup!(SUITE, "metal")

let group = addgroup!(group, "synchronization")
    group["stream"] = @benchmarkable synchronize()
    group["context"] = @benchmarkable device_synchronize()
end
