# Hacking

This page collects the low-level techniques used to develop Metal.jl itself: reading the
Apple IR (AIR) that Metal kernels compile to, packaging that IR into Metal libraries by
hand, and tracking down crashes in Apple's GPU compiler. None of this is needed to *use*
Metal.jl, but it is what you reach for when a kernel miscompiles, the backend compiler
segfaults, or you need to know how Apple's tools expect some construct to be spelled.

Most of the tooling lives in the `bin/` directory of the repository. The scripts there run
inside the package's own environment, so the first invocation will instantiate and
precompile before doing anything.

## Reverse-engineering bare MSL and Apple IR

Some Metal functions map directly onto AIR intrinsics, in which case wrapping them is little
more than a `ccall`. See the [threadgroup barrier
implementation](https://github.com/JuliaGPU/Metal.jl/blob/main/src/device/intrinsics/synchronization.jl#L43-L44)
for an example. The catch is that Apple's documentation does not tell you how the intrinsic
is spelled, what arguments it takes, or what metadata has to accompany it. The way to find
out is to write the construct in Metal Shading Language (MSL), compile it with Apple's
tools, and read the IR that comes out.

Start with a small MSL kernel that exercises the feature you care about:

```objective-c
#include <metal_stdlib>

using namespace metal;

kernel void dummy_kernel(device volatile atomic_float* out,
                         uint i [[thread_position_in_grid]])
{
    atomic_store_explicit(&out[i], 0.0f, memory_order_relaxed);
}
```

Compile it to human-readable IR with:

```
xcrun metal -S -emit-llvm dummy_kernel.metal
```

That writes a `.ll` file you can read. The function bodies show you the intrinsic names and
signatures; the metadata at the bottom (`!air.kernel`, `!air.version`, and the per-argument
`!air.buffer` entries) shows you what Metal.jl has to attach for the kernel to be accepted.

A few things to watch for:

- Keep the kernel minimal, but not so minimal that the optimizer deletes the part you wanted
  to see. If a store has no observable effect it will be folded away.
- Vary the types and address spaces. An atomic on `device` memory lowers to a different
  intrinsic than the same atomic on `threadgroup` memory, and the argument types change with
  the element type.
- Cross-check the result against what your Julia code produces. Metal.jl emits IR through
  LLVM, and small differences in metadata or intrinsic spelling are usually the reason a
  kernel that looks correct fails to compile.

## Disassembling, assembling, and loading Metal libraries

A `.metallib` is a container that wraps one or more AIR modules (LLVM bitcode) together with
the metadata Metal needs to instantiate them. Three scripts in `bin/` let you move between
that container and plain LLVM IR, and load the result onto a real device.

`metallib-dis` unpacks a library back into LLVM modules:

```
./metallib-dis -S broken.metallib -o reduced.ll
```

Without `-S` you get bitcode (`.bc`); with `-S` it runs the disassembler and gives you
textual IR. If the library holds more than one function, name the one you want or let the
script write each to a numbered file.

`metallib-as` does the reverse, packaging an LLVM module into a library:

```
./metallib-as reduced.ll -o reduced.metallib
```

The input can be textual IR or bitcode, and `-` reads from standard input. The module has to
contain exactly one external function, which becomes the library's entry point. Behind the
scenes the script downgrades the IR to the bitcode version Metal accepts (5.0), so this is
also the path you take when you have IR from a newer LLVM than Metal understands.

`metallib-load` takes a library and instantiates it on the GPU:

```
./metallib-load -v reduced.metallib
```

This loads the library and then builds a compute pipeline state for each function, which is
the step that forces Apple's *backend* compiler to translate the AIR into machine code for
your GPU. A library can load fine and still fail here, because loading only validates the
container while pipeline creation is what actually compiles the code. This is where backend
crashes surface, which makes `metallib-load` the tool you use to confirm a crash and, once
you start cutting the IR down, to check that you still have it.

The three compose, so you can take a library apart, edit the IR, and put it back together:

```
./metallib-dis -S input.metallib -o kernel.ll
$EDITOR kernel.ll
./metallib-as kernel.ll -o - | ./metallib-load -
```

When you feed them something they cannot handle, the error tells you which stage rejected
it. Malformed IR fails in `metallib-as` while LLVM is still parsing:

```
ERROR: LoadError: LLVM error: error: expected top-level entity
```

A file that is not a valid container fails in `metallib-load`:

```
ERROR: Failed to load Metal library; the library is likely invalid or corrupt.
```

Round-tripping IR through `metallib-as | metallib-dis -S` is useful on its own: the bitcode
downgrade and the re-parse both run the LLVM verifier, which catches malformed intrinsic
signatures (for example an `air.*` call with the wrong argument types) before Apple's
compiler ever sees them.

## The metallib container format

The `.metallib` container is undocumented, but understood well enough to implement.
Metal.jl has a pure-Julia reader and writer in `src/compiler/library.jl`; useful outside
references are [MetalLibraryArchive](https://github.com/YuAo/MetalLibraryArchive) and the
[floor](https://github.com/a2flo/floor_llvm) project, whose `MetalLibWriterPass.cpp` and
`metallib-dis` tool are the most complete third-party implementation.

A library starts with a fixed header: the `MTLB` magic, the file-format version, file and
platform types, the platform version, and the offsets of the main sections. Then comes a
function list, where each function is a group of tagged values (name, program type, module
hash, AIR/MSL versions, and offsets into the other sections), followed by per-function
public and private metadata, and the AIR bitcode modules themselves. Optional sections are
referenced from a header extension after the function list: embedded source archives
(`HSRD`), the dynamic header recording the library name (`HDYN`), reflection data (`RLST`),
script lists (`SLST`), and a UUID.

The file-format version follows the deployment target, as do the AIR and MSL versions
recorded per function and stamped into the bitcode:

| `-mmacosx-version-min` | metallib | AIR | MSL |
|:-----------------------|:---------|:----|:----|
| 14                     | 1.2.7    | 2.6 | 3.1 |
| 15                     | 1.2.8    | 2.7 | 3.2 |
| 26                     | 1.2.9    | 2.8 | 4.0 |

The `Metal.metallib_support`, `Metal.air_support` and `Metal.metal_support` functions encode
this mapping, and Metal.jl emits the same versions the offline compiler would when targeting
the host. The header of `src/version.jl` describes how to re-derive the table for a new
macOS release using `xcrun metal` and a hex editor.

Since metallib v1.2.7 the toolchain attaches reflection data to every function: an `RBUF`
buffer holding a flatbuffer with an `AIRR` file identifier, describing the function's
signature and resource bindings. The flatbuffer schemas are not published, but Apple embeds
them as binary flatbuffer schemas (BFBS) in the Metal toolchain binaries, from where they
can be extracted and fed to a flatbuffers implementation. The one non-standard part is that
nodes are encoded through a double table: the first table holds the node type and an offset
to a second table with the type-specific fields. floor implements writing these buffers
(see its `metal_reflection_types.hpp` and `metal_reflection_writing.hpp`).

Metal.jl reads and round-trips all of the above, but only generates the sections it has
data for. In practice that means libraries without reflection buffers or script lists,
which the runtime accepts. The header of `src/compiler/library.jl` lists what is not
implemented yet.

## Reproducing and reducing backend compiler crashes

A good chunk of Metal.jl debugging is narrowing a crash in Apple's GPU compiler down to the
smallest piece of IR that still triggers it. [Issue
#332](https://github.com/JuliaGPU/Metal.jl/issues/332) is a representative example: a kernel
that uses an atomic on threadgroup memory makes the backend compiler segfault, and the only
clue Metal.jl can give the user is "Compilation to native code failed; attach this
`.metallib`."

The starting point is that `.metallib`. Disassemble it to IR, then cut the IR down by hand:
delete instructions and basic blocks, drop arguments, replace called functions with stubs,
and re-run `metallib-as | metallib-load` after each change. As long as the crash reproduces,
keep cutting. When it stops, back up one step. The aim is an IR file small enough to read
and to attach to a bug report. The reduced module for the atomic crash above is only a
handful of lines: a kernel that calls an internal function whose entire body is a single
`air.atomic.local.add.f32`.

Two failure messages bracket the process, and the exact wording shifts between toolchain
versions. When the backend compiler crashes, the loader reports that the compiler service
died:

```
NSError: Compilation failed due to an interrupted connection:
XPC_ERROR_CONNECTION_INTERRUPTED. (AGXMetalG15X_M1, code 2)
```

Older toolchains phrase the same situation as "Compiler encountered an internal error." The
crash happens in a separate process (the Metal compiler XPC service), so what the loader
sees is only that the connection dropped, not where. The backtrace is in the crash log,
covered in the next section.

It pays to script the loop so each candidate gives a yes/no answer. Clear out the old crash
logs, assemble and load the file, then check the freshly written crash log for the function
at the top of the backtrace:

```sh
rm -f ~/Library/Logs/DiagnosticReports/MTLCompilerService*.ips
./metallib-as candidate.ll -o - | ./metallib-load -
grep -q buildAtomic ~/Library/Logs/DiagnosticReports/MTLCompilerService*.ips && echo "same crash"
```

Checking the backtrace symbol, rather than just "the load failed," is what keeps the
reduction honest: it tells you the file still crashes *the same way* and that you have not
swapped one bug for another while cutting.

## Offline pipeline compilation with `metal-tt`

`metallib-load` goes through the GPU driver and its XPC compiler service. There is also an
offline path that runs the same backend compiler directly from the command line, which gives
you a normal process with a normal exit code instead of a dropped connection. The tool is
`metal-tt`, the AIR translator driver:

```
xcrun metal-tt -arch applegpu_g15s -o main.gpubin descriptor.mtlp-json input.metallib
```

It takes two inputs. The `.metallib` is the library you want to compile, and the
`.mtlp-json` is a pipeline descriptor that names the function and pins down the pipeline
state the way the driver would at runtime:

```json
{
  "pipelines": {
    "compute_pipelines": [
      {
        "compute_function": "_Z1g",
        "threadgroup_size_is_multiple_of_thread_execution_width": true,
        "max_total_threads_per_threadgroup": 704
      }
    ]
  }
}
```

The `compute_function` has to match the entry point in the library. `-arch` selects the GPU
family to generate code for (`applegpu_g15s` and similar). On success you get a `.gpubin`,
the fully compiled machine code; on the atomic crash above, the compile dies instead:

```
air-tt: applegpu-nt command failed
```

Pass `-verbose` to see the subcommands `metal-tt` spawns. The one that does the real work is
`applegpu-nt`, the native translator. Running it directly reproduces the crash with an
honest exit status (`139`, i.e. `SIGSEGV`), which is convenient in a script:

```
applegpu-nt -arch applegpu_g15s -platform_version macos <ver> <sdk> \
  -sysroot <sysroot> input.metallib -N descriptor.mtlp-json -o out
```

The offline route has one drawback worth knowing. The standalone translator ships stripped,
so its crash log has no symbol names. For a readable backtrace you want the crash log from
the GPU-driver path, which links the symbolicated compiler core. In practice it is worth
having both: `metal-tt` for a scriptable repro with a clean exit code, and `metallib-load`
for the crash log that actually names the failing function.

## Reading crash logs

When the Metal compiler segfaults, macOS writes a crash report to
`~/Library/Logs/DiagnosticReports/`. The XPC service is named `MTLCompilerService`, and the
offline translator is `air-nt`, so the relevant files are:

```
~/Library/Logs/DiagnosticReports/MTLCompilerService-<timestamp>.ips
~/Library/Logs/DiagnosticReports/air-nt-<timestamp>.ips
```

Each `.ips` file is two JSON documents back to back: a one-line header (process name,
version, OS build, incident id) followed by the full report. The report names the exception
and the faulting thread, and lists the backtrace for every thread. The frame at the top of
the faulting thread is the one you care about. For the atomic crash it is:

```
AGCLLVMAirBuiltins::buildAtomic(llvm::Value**, llvm::StringRef)   [AGXCompilerCore]
AGCLLVMAirBuiltinReplacement<...>::doReplacement(...)             [AGXCompilerCore]
AGCLLVMAirBuiltins::replaceBuiltins()                             [AGXCompilerCore]
...
AIRNTEmitPipelineImageInternal(...)                              [AGXCompilerCore]
MTLCompilerObject::backendCompileModule(...)                     [MTLCompiler]
```

with an `EXC_BAD_ACCESS` (a null dereference) at the top. That symbol, `buildAtomic`, is
what tells you the crash is in the compiler's atomic-builtin lowering, and it is the string
to grep the crash log for when checking that a reduction still hits the same bug. Crash
reports are also viewable in the Console app under *Crash Reports*, which is handier when you
want to read one than to parse it.

The `MTLCompilerService` report is the more useful of the two, because its backtrace is
symbolicated against `AGXCompilerCore`. The `air-nt` report from the offline tool shows the
same crash but only as addresses in `libapplegpu-nt.dylib`.

## The Console app and the unified log

The compiler runs as a system service, and it logs to the unified logging system like
anything else. That log is what the Console app shows (look under your Mac's name in the
sidebar, with *Include Info Messages* and *Include Debug Messages* turned on), and it is the
same log the `log` command-line tool reads. They are two views of one source, so pick
whichever fits: Console for browsing and live capture, `log show` when you want to grep.

A failing pipeline build shows up as a conversation between two processes. The compiler
service logs the start of each request:

```
MTLCompilerService ... (MTLCompiler) Compilation BEGIN (ParentProcessName=julia_NNN) Build request: MTLBuildFunctions - pipeline
```

and the client-side Metal framework logs the failure, at fault level:

```
julia ... (Metal) MTLCompiler: Compilation failed with XPC_ERROR_CONNECTION_INTERRUPTED on 1 try.
```

For the atomic crash this repeats: each `BEGIN` is followed by the service crashing and
Metal retrying, so you see four failed tries before it gives up. A `BEGIN` with no matching
completion is the tell that the service died mid-compile rather than rejecting the input.
The symbolicated backtrace for that crash is the `.ips` report from the previous section,
which Console also lists under *Crash Reports*. A recoverable error reads differently: a bad
link, for instance, surfaces as an `Undefined symbols` error returned to the process rather
than a dropped connection.

From the command line, the messages you want sit at info and debug level, which `log show`
drops unless you ask for them:

```sh
log show --last 2m --info --debug \
  --predicate 'process == "MTLCompilerService" OR (process BEGINSWITH "julia" AND eventMessage CONTAINS "Compil")'
```
