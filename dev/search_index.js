var documenterSearchIndex = {"docs":
[{"location":"api/compiler/#Compiler","page":"Compiler","title":"Compiler","text":"","category":"section"},{"location":"api/compiler/#Execution","page":"Compiler","title":"Execution","text":"","category":"section"},{"location":"api/compiler/","page":"Compiler","title":"Compiler","text":"The main entry-point to the compiler is the @metal macro:","category":"page"},{"location":"api/compiler/","page":"Compiler","title":"Compiler","text":"@metal","category":"page"},{"location":"api/compiler/#Metal.@metal","page":"Compiler","title":"Metal.@metal","text":"@metal [kwargs...] func(args...)\n\nHigh-level interface for executing code on a GPU. The @metal macro should prefix a call, with func a callable function or object that should return nothing. It will be compiled to a Metal function upon first use, and to a certain extent arguments will be converted and managed automatically using mtlconvert. Finally, a call to mtlcall is performed, creating a command buffer in the current global command queue then committing it.\n\nThere is one supported keyword argument that influences the behavior of @metal.\n\nlaunch: whether to launch this kernel, defaults to true. If false the returned kernel object should be launched by calling it and passing arguments again.\n\n\n\n\n\n","category":"macro"},{"location":"api/compiler/","page":"Compiler","title":"Compiler","text":"If needed, you can use a lower-level API that lets you inspect the compiler kernel:","category":"page"},{"location":"api/compiler/","page":"Compiler","title":"Compiler","text":"Metal.mtlconvert\nMetal.mtlfunction","category":"page"},{"location":"api/compiler/#Metal.mtlconvert","page":"Compiler","title":"Metal.mtlconvert","text":"mtlconvert(x, [cce])\n\nThis function is called for every argument to be passed to a kernel, allowing it to be converted to a GPU-friendly format. By default, the function does nothing and returns the input object x as-is.\n\nDo not add methods to this function, but instead extend the underlying Adapt.jl package and register methods for the the Metal.Adaptor type.\n\n\n\n\n\n","category":"function"},{"location":"api/compiler/#Metal.mtlfunction","page":"Compiler","title":"Metal.mtlfunction","text":"mtlfunction(f, tt=Tuple{}; kwargs...)\n\nLow-level interface to compile a function invocation for the currently-active GPU, returning a callable kernel object. For a higher-level interface, use @metal.\n\nThe output of this function is automatically cached, i.e. you can simply call mtlfunction in a hot path without degrading performance. New code will be generated automatically when the function changes, or when different types or keyword arguments are provided.\n\n\n\n\n\n","category":"function"},{"location":"api/compiler/#Reflection","page":"Compiler","title":"Reflection","text":"","category":"section"},{"location":"api/compiler/","page":"Compiler","title":"Compiler","text":"If you want to inspect generated code, you can use macros that resemble functionality from the InteractiveUtils standard library:","category":"page"},{"location":"api/compiler/","page":"Compiler","title":"Compiler","text":"@device_code_lowered\n@device_code_typed\n@device_code_warntype\n@device_code_llvm\n@device_code_metal\n@device_code","category":"page"},{"location":"api/compiler/","page":"Compiler","title":"Compiler","text":"For more information, please consult the GPUCompiler.jl documentation. code_metal is actually code_native:","category":"page"},{"location":"api/array/#Array-programming","page":"Array programming","title":"Array programming","text":"","category":"section"},{"location":"api/array/","page":"Array programming","title":"Array programming","text":"The Metal array type, MtlArray, generally implements the Base array interface and all of its expected methods.","category":"page"},{"location":"api/essentials/#Essentials","page":"Essentials","title":"Essentials","text":"","category":"section"},{"location":"api/essentials/#Global-State","page":"Essentials","title":"Global State","text":"","category":"section"},{"location":"api/essentials/","page":"Essentials","title":"Essentials","text":"device!\ndevices\ncurrent_device\nglobal_queue\nsynchronize\ndevice_synchronize","category":"page"},{"location":"api/essentials/#Metal.device!","page":"Essentials","title":"Metal.device!","text":"device!(dev::MTLDevice)\n\nSets the Metal GPU device associated with the current Julia task.\n\n\n\n\n\n","category":"function"},{"location":"api/essentials/#Metal.MTL.devices","page":"Essentials","title":"Metal.MTL.devices","text":"devices()\n\nGet an iterator for the compute devices.\n\n\n\n\n\n","category":"function"},{"location":"api/essentials/#Metal.current_device","page":"Essentials","title":"Metal.current_device","text":"current_device()::MTLDevice\n\nReturn the Metal GPU device associated with the current Julia task.\n\nSince all M-series systems currently only externally show a single GPU, this function effectively returns the only system GPU.\n\n\n\n\n\n","category":"function"},{"location":"api/essentials/#Metal.global_queue","page":"Essentials","title":"Metal.global_queue","text":"global_queue(dev::MTLDevice)::MTLCommandQueue\n\nReturn the Metal command queue associated with the current Julia thread.\n\n\n\n\n\n","category":"function"},{"location":"api/essentials/#Metal.synchronize","page":"Essentials","title":"Metal.synchronize","text":"synchronize(queue)\n\nWait for currently committed GPU work on this queue to finish.\n\nCreate a new MTLCommandBuffer from the global command queue, commit it to the queue, and simply wait for it to be completed. Since command buffers should execute in a First-In-First-Out manner, this synchronizes the GPU.\n\n\n\n\n\n","category":"function"},{"location":"api/essentials/#Metal.device_synchronize","page":"Essentials","title":"Metal.device_synchronize","text":"device_synchronize()\n\nSynchronize all committed GPU work across all global queues\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Kernel-programming","page":"Kernel programming","title":"Kernel programming","text":"","category":"section"},{"location":"api/kernel/","page":"Kernel programming","title":"Kernel programming","text":"This section lists the package's public functionality that corresponds to special Metal functions for use in device code. For more information about these functions, please consult the Metal Shading Language specification.","category":"page"},{"location":"api/kernel/","page":"Kernel programming","title":"Kernel programming","text":"This is made possible by interfacing with the Metal libraries through a small C library that wraps the ObjectiveC APIs. These low-level wrappers, along with some slightly higher-level Julia wrappers, are available in the MTL submodule exported by Metal.jl. All wrapped C functions and types start with the mt prefix, whereas the Julia wrappers are prefixed with Mtl:","category":"page"},{"location":"api/kernel/#Indexing-and-dimensions","page":"Kernel programming","title":"Indexing and dimensions","text":"","category":"section"},{"location":"api/kernel/","page":"Kernel programming","title":"Kernel programming","text":"thread_execution_width\nthread_index_in_quadgroup\nthread_index_in_simdgroup\nthread_index_in_threadgroup\nthread_position_in_grid_1d\nthread_position_in_threadgroup_1d\nthreadgroup_position_in_grid_1d\nthreadgroups_per_grid_1d\nthreads_per_grid_1d\nthreads_per_simdgroup\nthreads_per_threadgroup_1d\nsimdgroups_per_threadgroup\nsimdgroup_index_in_threadgroup\nquadgroup_index_in_threadgroup\nquadgroups_per_threadgroup\ngrid_size_1d\ngrid_origin_1d","category":"page"},{"location":"api/kernel/#Metal.thread_execution_width","page":"Kernel programming","title":"Metal.thread_execution_width","text":"thread_execution_width()::UInt32\n\nReturn the execution width of the compute unit.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.thread_index_in_quadgroup","page":"Kernel programming","title":"Metal.thread_index_in_quadgroup","text":"thread_index_in_quadgroup()::UInt32\n\nReturn the index of the current thread in its quadgroup.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.thread_index_in_simdgroup","page":"Kernel programming","title":"Metal.thread_index_in_simdgroup","text":"thread_index_in_simdgroup()::UInt32\n\nReturn the index of the current thread in its simdgroup.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.thread_index_in_threadgroup","page":"Kernel programming","title":"Metal.thread_index_in_threadgroup","text":"thread_index_in_threadgroup()::UInt32\n\nReturn the index of the current thread in its threadgroup.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.thread_position_in_grid_1d","page":"Kernel programming","title":"Metal.thread_position_in_grid_1d","text":"thread_position_in_grid_1d()::UInt32\nthread_position_in_grid_2d()::NamedTuple{(:x, :y), Tuple{UInt32, UInt32}}\nthread_position_in_grid_3d()::NamedTuple{(:x, :y, :z), Tuple{UInt32, UInt32, UInt32}}\n\nReturn the current thread's position in an N-dimensional grid of threads.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.thread_position_in_threadgroup_1d","page":"Kernel programming","title":"Metal.thread_position_in_threadgroup_1d","text":"thread_position_in_threadgroup_1d()::UInt32\nthread_position_in_threadgroup_2d()::NamedTuple{(:x, :y), Tuple{UInt32, UInt32}}\nthread_position_in_threadgroup_3d()::NamedTuple{(:x, :y, :z), Tuple{UInt32, UInt32, UInt32}}\n\nReturn the current thread's unique position within a threadgroup.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.threadgroup_position_in_grid_1d","page":"Kernel programming","title":"Metal.threadgroup_position_in_grid_1d","text":"threadgroup_position_in_grid_1d()::UInt32\nthreadgroup_position_in_grid_2d()::NamedTuple{(:x, :y), Tuple{UInt32, UInt32}}\nthreadgroup_position_in_grid_3d()::NamedTuple{(:x, :y, :z), Tuple{UInt32, UInt32, UInt32}}\n\nReturn the current threadgroup's unique position within the grid.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.threadgroups_per_grid_1d","page":"Kernel programming","title":"Metal.threadgroups_per_grid_1d","text":"threadgroups_per_grid_1d()::UInt32\nthreadgroups_per_grid_2d()::NamedTuple{(:x, :y), Tuple{UInt32, UInt32}}\nthreadgroups_per_grid_3d()::NamedTuple{(:x, :y, :z), Tuple{UInt32, UInt32, UInt32}}\n\nReturn the number of threadgroups per grid.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.threads_per_grid_1d","page":"Kernel programming","title":"Metal.threads_per_grid_1d","text":"threads_per_grid_1d()::UInt32\nthreads_per_grid_2d()::NamedTuple{(:x, :y), Tuple{UInt32, UInt32}}\nthreads_per_grid_3d()::NamedTuple{(:x, :y, :z), Tuple{UInt32, UInt32, UInt32}}\n\nReturn the grid size.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.threads_per_simdgroup","page":"Kernel programming","title":"Metal.threads_per_simdgroup","text":"threads_per_simdgroup()::UInt32\n\nReturn the thread execution width of a simdgroup.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.threads_per_threadgroup_1d","page":"Kernel programming","title":"Metal.threads_per_threadgroup_1d","text":"threads_per_threadgroup_1d()::UInt32\nthreads_per_threadgroup_2d()::NamedTuple{(:x, :y), Tuple{UInt32, UInt32}}\nthreads_per_threadgroup_3d()::NamedTuple{(:x, :y, :z), Tuple{UInt32, UInt32, UInt32}}\n\nReturn the thread execution width of a threadgroup.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.simdgroups_per_threadgroup","page":"Kernel programming","title":"Metal.simdgroups_per_threadgroup","text":"simdgroups_per_threadgroup()::UInt32\n\nReturn the simdgroup execution width of a threadgroup.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.simdgroup_index_in_threadgroup","page":"Kernel programming","title":"Metal.simdgroup_index_in_threadgroup","text":"simdgroup_index_in_threadgroup()::UInt32\n\nReturn the index of a simdgroup within a threadgroup.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.quadgroup_index_in_threadgroup","page":"Kernel programming","title":"Metal.quadgroup_index_in_threadgroup","text":"quadgroup_index_in_threadgroup()::UInt32\n\nReturn the index of a quadgroup within a threadgroup.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.quadgroups_per_threadgroup","page":"Kernel programming","title":"Metal.quadgroups_per_threadgroup","text":"quadgroups_per_threadgroup()::UInt32\n\nReturn the quadgroup execution width of a threadgroup.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.grid_size_1d","page":"Kernel programming","title":"Metal.grid_size_1d","text":"grid_size_1d()::UInt32\ngrid_size_2d()::NamedTuple{(:x, :y), Tuple{UInt32, UInt32}}\ngrid_size_3d()::NamedTuple{(:x, :y, :z), Tuple{UInt32, UInt32, UInt32}}\n\nReturn maximum size of the grid for threads that read per-thread stage-in data.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.grid_origin_1d","page":"Kernel programming","title":"Metal.grid_origin_1d","text":"grid_origin_1d()::UInt32\ngrid_origin_2d()::NamedTuple{(:x, :y), Tuple{UInt32, UInt32}}\ngrid_origin_3d()::NamedTuple{(:x, :y, :z), Tuple{UInt32, UInt32, UInt32}}\n\nReturn the origin offset of the grid for threads that read per-thread stage-in data.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Device-arrays","page":"Kernel programming","title":"Device arrays","text":"","category":"section"},{"location":"api/kernel/","page":"Kernel programming","title":"Kernel programming","text":"Metal.jl provides a primitive, lightweight array type to manage GPU data organized in an plain, dense fashion. This is the device-counterpart to the MtlArray, and implements (part of) the array interface as well as other functionality for use on the GPU:","category":"page"},{"location":"api/kernel/","page":"Kernel programming","title":"Kernel programming","text":"MtlDeviceArray\nMetal.Const","category":"page"},{"location":"api/kernel/#Metal.MtlDeviceArray","page":"Kernel programming","title":"Metal.MtlDeviceArray","text":"MtlDeviceArray(dims, ptr)\nMtlDeviceArray{T}(dims, ptr)\nMtlDeviceArray{T,A}(dims, ptr)\nMtlDeviceArray{T,A,N}(dims, ptr)\n\nConstruct an N-dimensional dense Metal device array with element type T wrapping a pointer, where N is determined from the length of dims and T is determined from the type of ptr.\n\ndims may be a single scalar, or a tuple of integers corresponding to the lengths in each dimension). If the rank N is supplied explicitly as in Array{T,N}(dims), then it must match the length of dims. The same applies to the element type T, which should match the type of the pointer ptr.\n\n\n\n\n\n","category":"type"},{"location":"api/kernel/#Metal.Const","page":"Kernel programming","title":"Metal.Const","text":"Const(A::MtlDeviceArray)\n\nMark a MtlDeviceArray as constant/read-only and to use the constant address space.\n\nwarning: Warning\nExperimental API. Subject to change without deprecation.\n\n\n\n\n\n","category":"type"},{"location":"api/kernel/#Shared-memory","page":"Kernel programming","title":"Shared memory","text":"","category":"section"},{"location":"api/kernel/","page":"Kernel programming","title":"Kernel programming","text":"MtlThreadGroupArray","category":"page"},{"location":"api/kernel/#Metal.MtlThreadGroupArray","page":"Kernel programming","title":"Metal.MtlThreadGroupArray","text":"MtlThreadGroupArray(::Type{T}, dims)\n\nCreate an array local to each threadgroup launched during kernel execution.\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Synchronization","page":"Kernel programming","title":"Synchronization","text":"","category":"section"},{"location":"api/kernel/","page":"Kernel programming","title":"Kernel programming","text":"threadgroup_barrier\nsimdgroup_barrier","category":"page"},{"location":"api/kernel/#Metal.threadgroup_barrier","page":"Kernel programming","title":"Metal.threadgroup_barrier","text":"threadgroup_barrier(flag::MemoryFlags=MemoryFlagNone)\n\nSynchronize all threads in a threadgroup.\n\nPossible flags that affect the memory synchronization behavior are found in MemoryFlags\n\n\n\n\n\n","category":"function"},{"location":"api/kernel/#Metal.simdgroup_barrier","page":"Kernel programming","title":"Metal.simdgroup_barrier","text":"simdgroup_barrier(flag::MemoryFlags=MemoryFlagNone)\n\nSynchronize all threads in a SIMD-group.\n\nPossible flags that affect the memory synchronization behavior are found in MemoryFlags\n\n\n\n\n\n","category":"function"},{"location":"#MacOS-GPU-programming-in-Julia","page":"Home","title":"MacOS GPU programming in Julia","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The Metal.jl package is the main entrypoint for GPU programming on MacOS in Julia. The package makes it possible to do so at various abstraction levels, from easy-to-use arrays down to hand-written kernels using low-level Metal APIs.","category":"page"},{"location":"","page":"Home","title":"Home","text":"If you have any questions, please feel free to use the #gpu channel on the Julia slack, or the GPU domain of the Julia Discourse.","category":"page"},{"location":"","page":"Home","title":"Home","text":"As this package is still under development, if you spot a bug, please file an issue.","category":"page"},{"location":"#Quick-Start","page":"Home","title":"Quick Start","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Metal.jl ties into your system's existing Metal Shading Language compiler toolchain, so no additional installs are required (unless you want to view profiled GPU operations)","category":"page"},{"location":"","page":"Home","title":"Home","text":"# install the package\nusing Pkg\nPkg.add(\"Metal\")\n\n# smoke test\nusing Metal\nMetal.versioninfo()","category":"page"},{"location":"","page":"Home","title":"Home","text":"If you want to ensure everything works as expected, you can execute the test suite.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Pkg\nPkg.test(\"Metal\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"The following resources may also be of interest (although are mainly focused on the CUDA GPU  backend):","category":"page"},{"location":"","page":"Home","title":"Home","text":"Effectively using GPUs with Julia: video, slides\nHow Julia is compiled to GPUs: video","category":"page"},{"location":"#Acknowledgements","page":"Home","title":"Acknowledgements","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The Julia Metal stack has been a collaborative effort by many individuals. Significant contributions have been made by the following individuals:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Tim Besard (@maleadt) (lead developer)\nFilippo Vicentini (@PhilipVinc)\nMax Hawkins (@max-Hawkins)","category":"page"},{"location":"#Supporting-and-Citing","page":"Home","title":"Supporting and Citing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Some of the software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. If you use our software as part of your research, teaching, or other activities, we would be grateful if you could cite our work. The CITATION.bib file in the root of this repository lists the relevant papers.","category":"page"},{"location":"faq/#Can-you-wrap-this-Metal-API?","page":"FAQ","title":"Can you wrap this Metal API?","text":"","category":"section"},{"location":"faq/","page":"FAQ","title":"FAQ","text":"Most likely. Any help on designing or implementing high-level wrappers for MSL's low-level functionality is greatly appreciated, so please consider contributing your uses of these APIs on the respective repositories.","category":"page"},{"location":"profiling/#Profiling","page":"Profiling","title":"Profiling","text":"","category":"section"},{"location":"profiling/","page":"Profiling","title":"Profiling","text":"Profiling GPU code is harder than profiling Julia code executing on the CPU. For one, kernels typically execute asynchronously, and thus require appropriate synchronization when measuring their execution time. Furthermore, because the code executes on a different processor, it is much harder to know what is currently executing.","category":"page"},{"location":"profiling/#Time-measurements","page":"Profiling","title":"Time measurements","text":"","category":"section"},{"location":"profiling/","page":"Profiling","title":"Profiling","text":"For robust measurements, it is advised to use the BenchmarkTools.jl package which goes to great lengths to perform accurate measurements. Due to the asynchronous nature of GPUs, you need to ensure the GPU is synchronized at the end of every sample, e.g. by calling synchronize() or, even better, wrapping your code in Metal.@sync:","category":"page"},{"location":"profiling/","page":"Profiling","title":"Profiling","text":"Note that the allocations as reported by BenchmarkTools are CPU allocations.","category":"page"},{"location":"profiling/#Application-profiling","page":"Profiling","title":"Application profiling","text":"","category":"section"},{"location":"profiling/","page":"Profiling","title":"Profiling","text":"For profiling large applications, simple timings are insufficient. Instead, we want a overview of how and when the GPU was active, to avoid times where the device was idle and/or find which kernels needs optimization.","category":"page"},{"location":"profiling/","page":"Profiling","title":"Profiling","text":"As we cannot use the Julia profiler for this task, we will use Metal's GPU profiler directly. Use the Metal.@profile macro to surround the code code of interest. This macro tells your system to track GPU calls and usage statistics and will save this information in a temporary folder ending in '.gputrace'. For later viewing, copy this folder to a stable location or use the 'dir' argument of the profile macro to store the gputrace to a different location directly.","category":"page"},{"location":"profiling/","page":"Profiling","title":"Profiling","text":"To profile GPU code from a Julia process, you must set the METALCAPTUREENABLED environment variable. On the first Metal command detected, you should get a message stating \"Metal GPU Frame Capture Enabled\" if the variable was set correctly.","category":"page"},{"location":"profiling/","page":"Profiling","title":"Profiling","text":"$ METAL_CAPTURE_ENABLED=1 julia\n...\n\njulia> using Metal\n\njulia> function vadd(a, b, c)\n           i = thread_position_in_grid_1d()\n           c[i] = a[i] + b[i]\n           return\n       end\nvadd (generic function with 1 method)\n\njulia> a = MtlArray([1]); b = MtlArray([2]); c = similar(a);\n... Metal GPU Frame Capture Enabled\n\njulia> Metal.@profile @metal threads=length(c) vadd(a, b, c);\n[ Info: GPU frame capture saved to /var/folders/x3/75r5z4sd2_bdwqs68_nfnxw40000gn/T/jl_WzKxYVMlon/jl_metal.gputrace/","category":"page"},{"location":"profiling/","page":"Profiling","title":"Profiling","text":"To view these GPU traces though, Xcode, with its quite significant install size, needs to be  installed.","category":"page"}]
}
