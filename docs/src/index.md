# MacOS GPU programming in Julia

The Metal.jl package is the main entry point for GPU programming on MacOS in Julia. The package
makes it possible to do so at various abstraction levels, from easy-to-use arrays down to
hand-written kernels using low-level Metal APIs.

If you have any questions, please feel free to use the `#gpu` channel on the [Julia
slack](https://julialang.slack.com/), or the [GPU domain of the Julia
Discourse](https://discourse.julialang.org/c/domain/gpu).

As this package is still under development, if you spot a bug, please file
[an issue](https://github.com/JuliaGPU/Metal.jl/issues).


## Quick Start

Metal.jl ties into your system's existing Metal Shading Language compiler toolchain, so no additional
installs are required (unless you want to [view profiled GPU operations](profiling.md))

```julia
# install the package
using Pkg
Pkg.add("Metal")

# smoke test
using Metal
Metal.versioninfo()
```

If you want to ensure everything works as expected, you can execute the test suite.

```julia
using Pkg
Pkg.test("Metal")
```

The following resources may also be of interest (although are mainly focused on the CUDA GPU
 backend):

- Effectively using GPUs with Julia:
  [slides](https://docs.google.com/presentation/d/1l-BuAtyKgoVYakJSijaSqaTL3friESDyTOnU2OLqGoA/)
- How Julia is compiled to GPUs: [video](https://www.youtube.com/watch?v=Fz-ogmASMAE)

## Contributing

If you want to help improve this package, look at [the contributing page](faq/contributing.md) for more details.

## Acknowledgements

The Julia Metal stack has been a collaborative effort by many individuals. Significant
contributions have been made by the following individuals:

- Tim Besard (@maleadt) (lead developer)
- Filippo Vicentini (@PhilipVinc)
- Max Hawkins (@max-Hawkins)

## Supporting and Citing

Some of the software in this ecosystem was developed as part of academic research. If you
would like to help support it, please star the repository as such metrics may help us secure
funding in the future. If you use our software as part of your research, teaching, or other
activities, we would be grateful if you could cite our work. The
[CITATION.cff](https://github.com/JuliaGPU/Metal.jl/blob/main/CITATION.cff) file in the
root of this repository lists the relevant papers.
