# local method table for device functions
Base.Experimental.@MethodTable(method_table)

# throw a device-side exception of type `name`, reported with `reason`
using GPUCompiler: @gputhrow

const HAS_CONSISTENT_OVERLAY = VERSION >= v"1.12.0-DEV.745" || v"1.11-rc1" <= VERSION < v"1.12-"

# for packages that implement functions for Metal's device code, e.g. the device
# functions of a kernel language, or functions with a Metal-specific implementation
@public method_table, var"@device_override", var"@device_function"

macro device_override(ex)
    esc(GPUToolbox.Overlays.device_override(__module__, GlobalRef(Metal, :method_table), ex))
end

macro device_function(ex)
    esc(GPUToolbox.Overlays.device_function(__module__, GlobalRef(Metal, :method_table), ex))
end
