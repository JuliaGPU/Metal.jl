# Convolution performance notes

Benchmarks backing the design of the GPU convolution support (the `DSP.conv` /
`DSP.xcorr` extension and its internal FFT engine). Measured on Apple Silicon
(Metal), `Float32`, with warmup + `Metal.synchronize()`, reported as the best of
5 runs × 30 calls (ms/call). These numbers drive the "single-implementation"
decision and are intended as source material for the PR description.

## CPU vs GPU (`DSP.conv`)

GPU `DSP.conv` (via `MetalDSPExt`) vs CPU `DSP.conv` (FFTW-backed), `Float32`.
GPU times are compute-only (`Metal.synchronize()`, data already on device). The
GPU has a ~0.4–0.8 ms fixed dispatch/sync overhead, so it wins only at scale.

1-D (kernel 127):

| signal | CPU (ms) | GPU (ms) | speedup |
|-------:|---------:|---------:|--------:|
| 10³    | 0.037    | 0.412    | 0.1× |
| 10⁴    | 0.061    | 0.422    | 0.1× |
| 10⁵    | 0.288    | 0.491    | 0.6× |
| 10⁶    | 2.469    | 0.815    | **3.0×** |

2-D (kernel 15×15):

| image | CPU (ms) | GPU (ms) | speedup |
|------:|---------:|---------:|--------:|
| 128²  | 0.128    | 0.598    | 0.2× |
| 256²  | 0.427    | 0.592    | 0.7× |
| 512²  | 1.457    | 0.830    | **1.8×** |
| 1024² | 5.135    | 1.633    | **3.1×** |

Guidance: the GPU path pays off for large signals/images (1-D ≳ 10⁶, 2-D ≳ 512²)
or when data already lives on the GPU; for small inputs CPU FFTW is faster. A
one-off `CPU→GPU→CPU` round trip shifts the crossover further right.

## Single 2-D image, `mode = :same`

| image | kernel | fused FFT | MPS-direct | fused speedup |
|------:|-------:|----------:|-----------:|--------------:|
| 16²   | 3²     | 0.53      | 2.30       | 4.3× |
| 32²   | 3²     | 0.58      | 2.79       | 4.8× |
| 64²   | 5²     | 0.53      | 3.38       | 6.3× |
| 128²  | 5²     | 0.59      | 5.76       | 9.8× |
| 256²  | 5²     | 0.58      | 5.18       | 9.0× |
| 512²  | 3²–63² | 0.6–0.8   | 2.4–11.1   | 2–18× |

The fused FFT path is ~0.6 ms and essentially **kernel-size independent**, while
MPS-direct (`convolution2DWithSourceTensor`) is slower at every size measured —
including the small kernels the old `:auto` heuristic routed to it.

## Repeated convolution: plan vs one-shot (512², `mode = :full`)

| kernel | one-shot fused | `ConvFFTPlan` (reuse) | ratio |
|-------:|---------------:|----------------------:|------:|
| 7²     | 0.65           | 1.23                  | 0.52× |
| 15²    | 0.62           | 1.19                  | 0.52× |
| 31²    | 0.66           | 1.19                  | 0.56× |

The `ConvFFTPlan` repeated-convolution path is **~2× slower** than simply calling
the one-shot fused convolution. The fused graph and its transforms are already
cached by the FFT graph cache, so the plan's separate rfft/irfft + buffer reuse
adds overhead without a payoff.

## Design decisions

- **Single implementation = fused FFT.** It is the fastest path in every regime
  measured, so collapsing to it (per reviewer guidance on the FFT PR — "one
  implementation, like CUDA.jl") costs **no performance**. It also removes the
  `:auto` heuristic that mis-routed small kernels to the slower direct path, so
  the trim is a net speed-up for that case.
- **Drop MPS-direct** from the signal-convolution engine: always slower here.
- **Drop `ConvFFTPlan` / `plan_conv_fft`:** slower than one-shot — negative value.
- **`imfilter`** routes to the fused FFT path (its old direct branch is removed).

## Coordination with PR #745 and NNlib

PR #745 (`MPSGraphs.graph_conv!`) implements **NN-style** convolution
(`convolution2DWithSourceTensor` with stride/dilation/padding/groups) for the
NNlib/Flux lane (issue #210). This work covers **signal-processing** convolution
(`DSP.conv` / `DSP.xcorr`, FFT-based). They are complementary:

- Dropping MPS-direct here also drops our `convolution2DWithSourceTensor` /
  `MPSGraphConvolution2DOpDescriptor` wrappers, **removing the overlap** with #745.
- We do **not** add `NNlib.conv` here — it would duplicate #745. The NN path
  belongs in #745 (or a follow-up NNlib extension), not the DSP/signal PR.

## Caveats

Numbers are for single-array (all-dims) `Float32` signal convolution on one GPU.
NN-style batched/channelled convolution (many small filters, NCHW layout) is a
different workload where the MPS conv2d primitive is appropriate — that is #745's
domain, not this PR's.
