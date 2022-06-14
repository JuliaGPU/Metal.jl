# Apple's Metal for `C`

C Wrapper for Apple's METAL framework. This library is C bindings of Metal API (MetalGL). 

This started as a fork of [rcp/cmt](https://github.com/recp/cmt), with the aim of wrapping Metal in Julia, but at the time of writing is more complete.

The graphics-related part of the API are not very developed. At the moment mostly functionality related to computing is wrapped.

Currently this library does not alloc memory for its types. It retains ObjC objects and work on them. This also makes the library very very thin layer on ObjC. 

## Building and linking

A CMake project is included that builds a shared library. The headers for that library are contained in `include/cmt`, and are bare-C.


```C

MtDevice                   *device;
MtCommandQueue             *cmdQueue;
MtRenderPipelineDescriptor *pipDesc;
MtLibrary                  *lib;
MtFunction                 *vertFunc, *fragFunc;
MtRenderPipelineState      *pip;

device   = mtCreateDevice();
lib      = mtDefaultLibrary(device);
cmdQueue = mtCommandQueueCreate(device);
pipDesc  = mtRenderDescCreate(MtPixelFormatBGRA8Unorm);

vertFunc = mtCreateFunc(lib, "vertexShader");
fragFunc = mtCreateFunc(lib, "fragmentShader");

mtSetFunc(pipDesc, vertFunc, MT_FUNC_VERT);
mtSetFunc(pipDesc, fragFunc, MT_FUNC_FRAG);

pip = mtRenderStateCreate(device, pipDesc);
  
```

### Trademarks

Apple name/logo and Metal are trademarks of Apple Inc. This software only provides C bindings for Metal, it is not alternative to Metal.
