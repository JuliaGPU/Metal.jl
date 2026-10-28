# sysimage builds compile methods for the host, which must not reach device-only code
import GPUToolbox
@test isempty(GPUToolbox.Overlays.host_leaks(Metal))
