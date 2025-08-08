window.BENCHMARK_DATA = {
  "lastUpdate": 1754678696497,
  "repoUrl": "https://github.com/JuliaGPU/Metal.jl",
  "entries": {
    "Metal Benchmarks": [
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "distinct": true,
          "id": "71b784ec9d6adf8a758e4d77f3b12ed53e7cea34",
          "message": "Temporarily allow benchmark runs on all workers.\n\n[only benchmarks]",
          "timestamp": "2024-10-02T09:50:18+02:00",
          "tree_id": "1e15b5261c536d7ff8d5ef15b90409f342ae0db6",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/71b784ec9d6adf8a758e4d77f3b12ed53e7cea34"
        },
        "date": 1727856593123,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4403995333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6895957979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 723655188,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 757604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1623541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7472\nallocs=289\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8853854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15824\nallocs=620\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1573521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2624459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11392\nallocs=454\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 455583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4664\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 461916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=48\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 19250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=224\nallocs=9\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 19791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=368\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tgymnich@icloud.com",
            "name": "Tim Gymnich",
            "username": "tgymnich"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "ff7c7ebdcd5f6d513614e3a27062d06a07ce81f7",
          "message": "Use unified memory for scalar indexing of permutation matrices (#313)\n\nCo-authored-by: Tim Besard <tim.besard@gmail.com>",
          "timestamp": "2024-10-02T14:14:21+02:00",
          "tree_id": "979007b2651f0a3bbacd0edd2379af4efb2cc7f5",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/ff7c7ebdcd5f6d513614e3a27062d06a07ce81f7"
        },
        "date": 1727874377921,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4407793041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6915521687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 726643917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 749270.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1557959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7472\nallocs=289\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8832020.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15824\nallocs=620\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1611291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2583750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11392\nallocs=454\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 476584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4664\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 441500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=48\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 19208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=224\nallocs=9\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 19750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=368\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "da83511095b183728e47e2adc14079f5e3c120e6",
          "message": "Disable nightly CI and fix invalid Metal API usage (#448)",
          "timestamp": "2024-10-04T10:13:55+02:00",
          "tree_id": "a220ced490cbb715e87750be20d3e728bf135421",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/da83511095b183728e47e2adc14079f5e3c120e6"
        },
        "date": 1728035589087,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4407307208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6930583500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 723401145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 746250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1556458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7472\nallocs=289\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8821042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15824\nallocs=620\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1563958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2552084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11392\nallocs=454\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 470917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4664\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 446250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 11791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=48\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 19541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=224\nallocs=9\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 19833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=368\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "cd9e68a1ffd37e8cf8c86af81acefed56f371f0b",
          "message": "Don't report benchmarks on main branch commits (#450)\n\n[only benchmarks]",
          "timestamp": "2024-10-04T15:05:20-03:00",
          "tree_id": "92ee9bd1278fccd97052c5bb03ab0061d2bf9850",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/cd9e68a1ffd37e8cf8c86af81acefed56f371f0b"
        },
        "date": 1728074161106,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4410766833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6887075395.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 725464062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 755125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1577625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7472\nallocs=289\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8895417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15824\nallocs=620\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1559209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2635958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11392\nallocs=454\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 462375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4664\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 446500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 11833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=48\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 19542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=224\nallocs=9\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 19833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=368\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "46298cad934c43caa525a092d2668bf51ec629e1",
          "message": "Fix unsafe_wrap of a view. (#452)\n\nAnd some other small fixes.",
          "timestamp": "2024-10-05T13:55:15+02:00",
          "tree_id": "314a2bcc453ee62e76e425f9585df9a65f54cfc8",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/46298cad934c43caa525a092d2668bf51ec629e1"
        },
        "date": 1728132347494,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4400518084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6886083333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 723478145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 753417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1585834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7472\nallocs=289\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8919167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15824\nallocs=620\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1547541.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2641479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11392\nallocs=454\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 467500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4664\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 444417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 11125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=48\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 19166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=224\nallocs=9\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 19750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=368\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "c4c0e28302380dd63aff9cb308c099157510c50d",
          "message": "Use CPU memcpy for SharedStorage copyto! (#445)",
          "timestamp": "2024-10-08T10:27:03+02:00",
          "tree_id": "51555f01cddbaa3f7a94105a2e8dbf8f72317172",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/c4c0e28302380dd63aff9cb308c099157510c50d"
        },
        "date": 1728378303530,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4401597375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6711178812,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 720307000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 743250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1607375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7472\nallocs=289\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11412000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15824\nallocs=620\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1562958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2659937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11552\nallocs=455\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 470417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4664\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 478812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=48\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=224\nallocs=9\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=368\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "dbed7500692b8587cbcc78048386048e0e04f365",
          "message": "Only load BFloat16sExt on Apple systems (#454)",
          "timestamp": "2024-10-10T16:13:10-03:00",
          "tree_id": "a4aa490413fea3afc9c0dbe93c7e5cd252df94d4",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/dbed7500692b8587cbcc78048386048e0e04f365"
        },
        "date": 1728590651520,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4390918458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6919873812,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 720849750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 762834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1655833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7472\nallocs=289\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8906833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15824\nallocs=620\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1551959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2757562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11392\nallocs=454\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 470270.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4664\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 451542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 11583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=48\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 19750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=224\nallocs=9\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 20209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=368\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "41898282+github-actions[bot]@users.noreply.github.com",
            "name": "github-actions[bot]",
            "username": "github-actions[bot]"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "ddca5c4f08f24187885556fc498856c6791bceda",
          "message": "CompatHelper: bump compat for GPUCompiler to 1, (keep existing compat) (#455)\n\nCo-authored-by: CompatHelper Julia <compathelper_noreply@julialang.org>",
          "timestamp": "2024-10-11T07:50:08+02:00",
          "tree_id": "f8f9b21f1991243f90e3dce441c035eec3c5b44c",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/ddca5c4f08f24187885556fc498856c6791bceda"
        },
        "date": 1728628035492,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4397344834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6908319354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 719607250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 756958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1632792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7472\nallocs=289\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8919542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15824\nallocs=620\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1659354.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2684500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11392\nallocs=454\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 478708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4664\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 476750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 12084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=48\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 19916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=224\nallocs=9\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 20209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=368\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "100f8318a60fcbbbde1964c304f95d9419ee1928",
          "message": "Fix loading on unsupported platforms (#459)\n\n* Gate getpagesize call behind function\r\n\r\n* Make `functional` require a fully-supported GPU",
          "timestamp": "2024-10-16T15:16:50-03:00",
          "tree_id": "b64711bdc147fb5573ee1d0cebb822c26ccfb9a3",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/100f8318a60fcbbbde1964c304f95d9419ee1928"
        },
        "date": 1729105215646,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4396587542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6698494124.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 722852834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 719875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1530167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7472\nallocs=289\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9115541.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15824\nallocs=620\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1520271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2666416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11392\nallocs=454\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 468541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4664\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 461292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=48\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=224\nallocs=9\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=368\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "c953739eb6fda54b5c6239fe7b4cae96dea3f9e8",
          "message": "Remove old code and clean-up tests (#464)",
          "timestamp": "2024-10-19T08:46:54+02:00",
          "tree_id": "f0358c18d581a0d2e4466ba7a200c7700777d500",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/c953739eb6fda54b5c6239fe7b4cae96dea3f9e8"
        },
        "date": 1729323717201,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4510050000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6891418604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 879412875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 718604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7112\nallocs=286\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1570417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7600\nallocs=297\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9622874.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15952\nallocs=628\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1560084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7112\nallocs=286\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2487792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11520\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 491104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4792\nallocs=193\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 472750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4800\nallocs=193\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1472\nallocs=53\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=416\nallocs=20\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "15ac66d722f1e83584a127bde61b47e4d91d83f8",
          "message": "Switch CI to 1.11. (#462)",
          "timestamp": "2024-10-19T20:02:23+02:00",
          "tree_id": "0ad8178685a124168abd87706d12a0116b6babfd",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/15ac66d722f1e83584a127bde61b47e4d91d83f8"
        },
        "date": 1729363490141,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5210869875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6541068271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1140328708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 694000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1586291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10928917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1622646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2588083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 488771,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 478083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "9019b56c05055db3e5dcd93ca0d08bf264c908cd",
          "message": "Adapt to JuliaGPU/GPUArrays.jl#567. (#475)",
          "timestamp": "2024-10-30T14:28:49+01:00",
          "tree_id": "e49a1b0d9881cf501bf4c7b3d9dfa3f540a62e0f",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/9019b56c05055db3e5dcd93ca0d08bf264c908cd"
        },
        "date": 1730297444386,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5193067083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6487019417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1129040229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 699833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1611416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11381521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1574875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2675708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 453209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 460187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 36083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":4,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "240c4b0988abf6cd6337072141ceb55ad9699ad2",
          "message": "Bump LLVM downgrader (#479)",
          "timestamp": "2024-11-08T09:20:40+01:00",
          "tree_id": "ea7a6a57627b091e30259ec6c541b4f65a60a06c",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/240c4b0988abf6cd6337072141ceb55ad9699ad2"
        },
        "date": 1731056647568,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5189463875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6484573312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1127755937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 727750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1603458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10250541.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1591771,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5208\nallocs=206\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2610104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8608\nallocs=343\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 452792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 450875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "3ec440f5540d372f02660cc7c59f29458ab0bf3e",
          "message": "Store more debug files when encountering compilation errors. (#482)",
          "timestamp": "2024-11-27T22:57:49+01:00",
          "tree_id": "7b30f0f91da1532e35240e79077bda789051572f",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/3ec440f5540d372f02660cc7c59f29458ab0bf3e"
        },
        "date": 1732747247292,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5253931625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6649813771,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1145857916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 750770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1662375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 20314209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1666875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2757583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 460145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 463042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 35656.25,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":4,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "8ccd416c47d335db3934d3c22f1d28e06ba6ff30",
          "message": "Still run GH Action when merged (#486)",
          "timestamp": "2024-11-30T20:42:33-04:00",
          "tree_id": "1624ce7df283973ecc907fafd491f84500b60b95",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/8ccd416c47d335db3934d3c22f1d28e06ba6ff30"
        },
        "date": 1733016273103,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5186888417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6501679688,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1131305770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 695667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1628959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10528167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1564708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2716709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 455416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 450645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "3fd6c06456dfdea8fa73483d396178a3202db666",
          "message": "Use `OncePerProcess` when possible (#483)",
          "timestamp": "2024-12-02T15:25:33+01:00",
          "tree_id": "aafd39d90f0ef12538d08ae2847c6ae5281173f1",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/3fd6c06456dfdea8fa73483d396178a3202db666"
        },
        "date": 1733152290657,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 6399118167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6579444208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1130024792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 710542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1546084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9416354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1601166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2699792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 457917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 449833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10034.833333333332,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "e6abcc63d2924914d79803e52ac0fe31d52cacdd",
          "message": "Bump IR downgrader (#489)",
          "timestamp": "2024-12-05T08:42:11+01:00",
          "tree_id": "4c748331379e2fc8dec3c62063d316fc8ec41930",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/e6abcc63d2924914d79803e52ac0fe31d52cacdd"
        },
        "date": 1733395199921,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5119209208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6736074937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1150978708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 712813,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1640250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10578833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1533458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2647313,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 493833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 484521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9889,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "d14426c0a6162e645b04f051ecc1da73be6fc872",
          "message": "Move MTL tests and add a few (#491)",
          "timestamp": "2024-12-10T10:29:24+01:00",
          "tree_id": "3be9055df0349510959b853d593e33986f5a52e9",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/d14426c0a6162e645b04f051ecc1da73be6fc872"
        },
        "date": 1733825333492,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5133928042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6740222625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1147095896.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 711042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1631916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8785708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1557875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2693167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 490416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 478416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "c2207d2e5027534f42992d380dd3af518b6a44e8",
          "message": "Fix copy tests (#493)",
          "timestamp": "2024-12-10T16:15:54-04:00",
          "tree_id": "2c97b9c48daa979597a062bb043bf8a6027849c1",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/c2207d2e5027534f42992d380dd3af518b6a44e8"
        },
        "date": 1733864235105,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5220350875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6674789459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1170613792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 748083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1676958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 21394667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1658146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2814542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 459916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 462041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "distinct": true,
          "id": "634cec7a042ee34d919c5a32122404151261c238",
          "message": "Move benchmark results into a subfolder.\n\n[skip tests]",
          "timestamp": "2024-12-11T14:06:50+01:00",
          "tree_id": "7eedcbed3061321e656119040321359e57346243",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/634cec7a042ee34d919c5a32122404151261c238"
        },
        "date": 1733923559959,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5138248250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6754936625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1151697916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 719667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1560604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10389833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1566416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2542084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 487187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 469791.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "8c119cfc518fa5b90da8b9e6b9eb782d4d79f7c6",
          "message": "Fix global linear indexing (`fill!`) (#496)",
          "timestamp": "2024-12-16T09:18:12+01:00",
          "tree_id": "d531405e0dbdee1a063c1d58138802e782ca9f38",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/8c119cfc518fa5b90da8b9e6b9eb782d4d79f7c6"
        },
        "date": 1734339479641,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5143804334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6880237708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1161084541.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 715041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5208\nallocs=206\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1632375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10058875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1585312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2691375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8608\nallocs=343\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 462625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 460479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10104.166666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "5056e3348749686c452b91dcd1ea541ea87599a1",
          "message": "Initial support for MPSNDArray (#499)",
          "timestamp": "2024-12-16T17:33:46+01:00",
          "tree_id": "67e6f94bb26330cb72160408eeb5e0a46220deb1",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/5056e3348749686c452b91dcd1ea541ea87599a1"
        },
        "date": 1734369581808,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5243893542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6538101604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1165440583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 705833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1588833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10079959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1568145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2643625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 444959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 446541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10666.666666666666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "distinct": true,
          "id": "5a8daaa3d5b31b8626e6f553953f1c2741b05d84",
          "message": "Benchmarks: Fix workflow.\n\n[only benchmarks]",
          "timestamp": "2024-12-18T10:17:09+01:00",
          "tree_id": "5cc1c4b3c11a237474291503453ba6fc55652e0c",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/5a8daaa3d5b31b8626e6f553953f1c2741b05d84"
        },
        "date": 1734514670731,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5246987875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6666328874.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1165891041.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 718542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1537583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8342167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1552229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2618584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 458000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 473584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10069.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "84447c4db5b2701f3618900a947b3f90adb53bf9",
          "message": "Fix `MPSNDArrayDescriptor` wrapper (#502)\n\nDon't reverse dimensions automatically",
          "timestamp": "2024-12-19T10:42:27+01:00",
          "tree_id": "8bd198c3d210ed12a28014c2d2442d407729da42",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/84447c4db5b2701f3618900a947b3f90adb53bf9"
        },
        "date": 1734603700312,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5246979375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6653773250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1164822625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 713667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1535999.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9724167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1540854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2638000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 476334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 477542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "ea1d6ad8ace75f25a77605a9dc6437ba1512cdb1",
          "message": "Generate MTL and MPS structs and enums with Clang.jl (#492)\n\n* Add Docs and wrapping readme\n\nCo-authored-by: Tim Besard <tim.besard@gmail.com>\n\n---------\n\nCo-authored-by: Tim Besard <tim.besard@gmail.com>",
          "timestamp": "2024-12-20T10:01:23-04:00",
          "tree_id": "e7fc5926ccc2d5229244cb939745af76bc6d2254",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/ea1d6ad8ace75f25a77605a9dc6437ba1512cdb1"
        },
        "date": 1734705832809,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5769911666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6647448292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1167766604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 719229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1521583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9443084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1487604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2653771,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 531041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 472333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10201.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 13917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "e762b0160d4f666531d74e17d96646cc4b2e9f56",
          "message": "Adjust random tests to avoid spurious test failures. (#506)",
          "timestamp": "2024-12-21T08:32:32+01:00",
          "tree_id": "c2f99e96b7faf2827821765846943e0a4d090332",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/e762b0160d4f666531d74e17d96646cc4b2e9f56"
        },
        "date": 1734768929203,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5772774167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6734636291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1170506875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 708167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1570895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9804542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1559062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2645000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 457583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 459812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "182095779fe4fb6af497a1824a09383dbc5de3cf",
          "message": "Bump LLVM downgrader (#507)\n\nv0.6 includes fixes for constant values and known intrinsics.",
          "timestamp": "2024-12-21T22:25:25+01:00",
          "tree_id": "6acb60b9adc9af28ac2e19c143fd539ae7dfc046",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/182095779fe4fb6af497a1824a09383dbc5de3cf"
        },
        "date": 1734818840310,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5763160083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6663954270.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1169291583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 714333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1647416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8868125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1566291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2727167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 457375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 456500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 37291.75,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":4,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "6a760a60a33b864b2c7fa3e856e38e1e6299f871",
          "message": "Remove type piracy and enable function wrapping (#505)\n\nIgnore MPS functions for now since MPS does not seem to have a dylib.",
          "timestamp": "2024-12-24T11:01:48+01:00",
          "tree_id": "1ae235dea8ea251d4fca9dde25c2087061fb1e24",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/6a760a60a33b864b2c7fa3e856e38e1e6299f871"
        },
        "date": 1735037260267,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5847134584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6545482667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1169724375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 713125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1580770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9774042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1598000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2571895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 457542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 458645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "cf21f9db92e7359105bd0ca44727dfa74739c56d",
          "message": "Update Documenter (#515)",
          "timestamp": "2025-01-04T14:51:16-04:00",
          "tree_id": "e3c2e52daa6b488baa1d613c1f637ae2d16e7bed",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/cf21f9db92e7359105bd0ca44727dfa74739c56d"
        },
        "date": 1736019452425,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5856015937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6607073479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1171437917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 699417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1594083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5536\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11850083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11808\nallocs=466\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1622417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5048\nallocs=205\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2525791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8448\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 466979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3384\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 479562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3392\nallocs=137\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=896\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "de8eed59b79b19cbbcbb1053c16dea5c2aa49667",
          "message": "Remove `device_code_agx` (#512)\n\nIt doesn't work on M3 anyway, and the Python\r\ndependency is quite heavy.",
          "timestamp": "2025-01-06T08:37:52+01:00",
          "tree_id": "4250ae495043ca18f93ae011766adbb42ca0cfd7",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/de8eed59b79b19cbbcbb1053c16dea5c2aa49667"
        },
        "date": 1736151729946,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5818530541.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3076733499.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1161722437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 769000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1682812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 20107416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1668458.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2862250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 465667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 471958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "6ac7f3c349202e87ddc55525aa30f6786c781970",
          "message": "Fix typo in random tests (#514)",
          "timestamp": "2025-01-06T12:39:35+01:00",
          "tree_id": "a89e5c479a2ed58acbb174b5aa6d7708df29bb9f",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/6ac7f3c349202e87ddc55525aa30f6786c781970"
        },
        "date": 1736166020775,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5830401479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3083600896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1160891875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 760875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1682042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 19850395.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1666916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2824958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 460854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 468479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "aae82e4a223a87a24b78925fec2c461af25dbf08",
          "message": "Test loading of package on unsupported platforms (#509)\n\nCo-authored-by: Tim Besard <tim.besard@gmail.com>",
          "timestamp": "2025-01-07T09:05:33+01:00",
          "tree_id": "6f6668750f0f18a8781e4d65ab241f530a7d56df",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/aae82e4a223a87a24b78925fec2c461af25dbf08"
        },
        "date": 1736240104536,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5826737333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3079494895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1160708708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 765458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1661833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 19882209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1644041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2825375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 463333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 462792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9507,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "dff150fda84839a0e989183f5d1cff2ed81d8b48",
          "message": "Bump version.",
          "timestamp": "2025-01-08T11:20:19+01:00",
          "tree_id": "900b2f0f751c959a807d10eb04930865ae2e516d",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/dff150fda84839a0e989183f5d1cff2ed81d8b48"
        },
        "date": 1736334025024,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5746549250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3031731729.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1141085375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 702604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1638604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10832625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1552542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2686333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 458104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 461500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "6efc3491ed501ddf2d1ec99eafe56dcd6c1a8d2c",
          "message": "Add Runic action to suggest formatting changes. (#517)",
          "timestamp": "2025-01-08T12:39:18+01:00",
          "tree_id": "26c4b2e2525edeacb05955d0a80e6e8405cc2a8f",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/6efc3491ed501ddf2d1ec99eafe56dcd6c1a8d2c"
        },
        "date": 1736339112663,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5747134375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3037577833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1141637625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 709666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1579791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8864667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1608125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2584187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 454625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 451458.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "573b4f4e9a414f62bd34624589ac2c1e80866b89",
          "message": "Adapt to new features of ObjectiveC.jl (#513)",
          "timestamp": "2025-01-08T19:59:37+01:00",
          "tree_id": "2a4baca58363700d420e17d64cb63aeef4811766",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/573b4f4e9a414f62bd34624589ac2c1e80866b89"
        },
        "date": 1736381101513,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5781727291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3044061917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1145053833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 708792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1606375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 13181333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1561646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2574125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 462208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 472541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "aaef44cfbdbd4bb8ab25ff36d4be78aaa4d86d6d",
          "message": "Increase polling interval for benchmark action (#518)",
          "timestamp": "2025-01-10T16:51:13+01:00",
          "tree_id": "3a72952ecad7222a27cf75e5e9ef9e6eeae41a0c",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/aaef44cfbdbd4bb8ab25ff36d4be78aaa4d86d6d"
        },
        "date": 1736525717762,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5781581500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3048361000.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1146280625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 720104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1584854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11074458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1621062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2602812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 469833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 479604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9826.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "6c2df1f01773e451439024ad3abcf3141410c976",
          "message": "Adapt to GPUArrays.jl changes. (#519)",
          "timestamp": "2025-01-16T16:14:51+01:00",
          "tree_id": "003bb95cd0bea45041aedb0063110b0373a700d9",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/6c2df1f01773e451439024ad3abcf3141410c976"
        },
        "date": 1737043478359,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5771935000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3043459271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1141145166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 708416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1636104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11296375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1554291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2595417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8528\nallocs=339\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 459999.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 456125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9368,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "c7227793c02b315afd876ae3fe39f3942703d2ef",
          "message": "Bump version.",
          "timestamp": "2025-01-17T09:01:02+01:00",
          "tree_id": "0e6ce7889fb5202709e543853669aa5c3f89ee7a",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/c7227793c02b315afd876ae3fe39f3942703d2ef"
        },
        "date": 1737103363372,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5845726333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3079599792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1161760499.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 759958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1662458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 21205687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1646250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2834791.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 464709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 468438,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "ebf223fdcf53f08643f0b40927dc1324d12b4d3e",
          "message": "Re-enable `add_functions!` test under shader validation (#522)",
          "timestamp": "2025-01-21T08:31:15+01:00",
          "tree_id": "a25fa0a162a70c800794f29c600d465466606c51",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/ebf223fdcf53f08643f0b40927dc1324d12b4d3e"
        },
        "date": 1737447174493,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5777750625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3042774604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1143862583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 714708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1633333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11174041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1586104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2623021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 453208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 449750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "distinct": true,
          "id": "e85bf52ba533dcb986ed630079439b8e0a84e82b",
          "message": "Update wrapping readme",
          "timestamp": "2025-01-23T17:25:39-04:00",
          "tree_id": "36220de522617d3d4b5db5b8e3404cf5ab60a1f9",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/e85bf52ba533dcb986ed630079439b8e0a84e82b"
        },
        "date": 1737671854479,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 5910171250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3465308333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1125491375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 737042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1633542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10788666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1612083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2533875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 459145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 452250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10291.666666666666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "4293d1ae3bbe5a2fcddcb79261d655c6a261b1d7",
          "message": "Automatically wrap Metal and MPS headers (feat. Properties) (#526)\n\n* Stray `!= nothing`\n\n* @objcwrapper generation\n\n* @objcwrappers MTL\n\n* @objcwrapper MPS\n\n* Version gates\n\nimmutable by default\n\n* Allow overriding supertypes\n\n* Reduce indentation\n\n* Change toml api format\n\n* Enable ObjCProperties type override\n\n* Comment out objcproperties blocks\n\n* Slightly breaking changes due to some instance methods previously disguised as properties\n\n* Wrap properties\n\n* Update README.md\n\n* Minor fixes\n\n* Switch to Runic.jl for post-wrapper formatting\n\n* Fix loading on unsupported platforms (again)\n\n* Bump ObjectiveC.jl compat\n\n* `api.propertytype.<name>` -> `api.<name>.proptype`\n\n* Refactor for consistency\n\n* Manually define struct constructors\n\n* Remove old `@objcproperties` declarations",
          "timestamp": "2025-01-28T18:16:47-04:00",
          "tree_id": "d95294b5635da131869fdc50c13474571e091614",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/4293d1ae3bbe5a2fcddcb79261d655c6a261b1d7"
        },
        "date": 1738105287161,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 8819859791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3601196084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1233148709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 709292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1635521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9780625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1577791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2702000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 448583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 457708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "1b811cba27b360aa70ebf294d4008c98ffaeb820",
          "message": "Small followup to #526 (#528)\n\n* Oops\n\n* Update `versioninfo()` output\n\n* Update contributing docs",
          "timestamp": "2025-01-28T23:31:16-04:00",
          "tree_id": "f9bc61c47f15067ad0e91ecb2af655951c3509da",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/1b811cba27b360aa70ebf294d4008c98ffaeb820"
        },
        "date": 1738123973711,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 8799224667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3600655125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1231127083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 701416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1566354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10376042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1610875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2715041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 474291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 475895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "62803658+vovw@users.noreply.github.com",
            "name": "atharva",
            "username": "vovw"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "ca092c83220f149913f8e80b018f9c76421fa834",
          "message": "Add error reporting to command buffer completion handler (#521)\n\nCo-authored-by: Tim Besard <tim.besard@gmail.com>",
          "timestamp": "2025-02-03T12:52:18+01:00",
          "tree_id": "ade42373423975a549c5fbfd22a9699d7d745e55",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/ca092c83220f149913f8e80b018f9c76421fa834"
        },
        "date": 1738585974161,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 8811389416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3608628500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1231898292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 713792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1617854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9687812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1589625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2675542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 470792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 463208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9527.666666666666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "924a13037368f007b738fcf32654f3ecbb2bf939",
          "message": "Fix rewriter for version-gated expressions (#535)",
          "timestamp": "2025-02-04T15:19:56-04:00",
          "tree_id": "19620615adedaa8106f152d9502a2f552c82e079",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/924a13037368f007b738fcf32654f3ecbb2bf939"
        },
        "date": 1738700024347,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 8851374292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3620472000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1235528208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 717959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1539333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9117125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1560292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2731458.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 457750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 455833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "e3d369e73a6d2b922f2aafd545d96b17e65e39c3",
          "message": "Fix Float16 sincos intrinsic (#533)",
          "timestamp": "2025-02-05T10:15:52+01:00",
          "tree_id": "9995d80cfe8ae47f8f8a0b51d46a87975d8ec57f",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/e3d369e73a6d2b922f2aafd545d96b17e65e39c3"
        },
        "date": 1738749571238,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9027805916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3651306917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1258009083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 766250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1672854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 20372728.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1623708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2837417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 457417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 459896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "a1c0b8f267ce8b8ee8ebc07dab359e76e0437d77",
          "message": "Move BFloat16 code out of extension (#536)",
          "timestamp": "2025-02-06T10:38:36+01:00",
          "tree_id": "96f958218afcaf2847d97f4a161c66efd7ced6bf",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/a1c0b8f267ce8b8ee8ebc07dab359e76e0437d77"
        },
        "date": 1738837453938,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 8842830584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3608651792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1231860208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 712708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1634250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9569375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1568812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2710271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 487354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 484875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "ede2dfdcfc133cebb9d72f6fe2b19ef878ee7191",
          "message": "Fix format suggestion formatting when diff contains triple-ticks. (#534)",
          "timestamp": "2025-02-06T14:19:06-04:00",
          "tree_id": "4a0676bb0e1a9c4c4075e31d3eb0267b78b212d7",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/ede2dfdcfc133cebb9d72f6fe2b19ef878ee7191"
        },
        "date": 1738868754386,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 8839962333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3596303959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1231643125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 713417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1604458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9263625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1578292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2646917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 460458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 452667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "6654291ec951515dcb95096392f422f76392c4a3",
          "message": "Version-related fixes to MPSNDArray (#537)",
          "timestamp": "2025-02-07T10:05:43+01:00",
          "tree_id": "7f8a41ced98429ab4954c1ed7204a762225f6220",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/6654291ec951515dcb95096392f422f76392c4a3"
        },
        "date": 1738921822044,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 8868498250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3613257333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1235355708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 721583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1558729.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9618396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1546854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2557458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 476250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 466417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "991f6df5c23bd3840a4a7030cbe7cc01dd5749ae",
          "message": "Add `nextafter` intrinsic (#529)",
          "timestamp": "2025-02-11T08:45:11+01:00",
          "tree_id": "c349659c81bf38b09d1637c4cda2480f40ad1d04",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/991f6df5c23bd3840a4a7030cbe7cc01dd5749ae"
        },
        "date": 1739262464827,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9074494166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3656792125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1254788541.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 748729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1661625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 20205125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1671416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2830312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 463666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 470208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9090.333333333334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "f3549a471b247c90f0ec71d700cc36a2b572e0a2",
          "message": "Objective-C Availability support (#527)",
          "timestamp": "2025-02-11T19:55:37+01:00",
          "tree_id": "fe0a51e07836ec805acba48b83b395b74574b059",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/f3549a471b247c90f0ec71d700cc36a2b572e0a2"
        },
        "date": 1739302821647,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9333770458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3667897583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1260213562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 755021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1660416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 19639208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1654791.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2784750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 453666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 460291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8986,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "3ad45e2cd0482d89c22b9c04bf92b40c1d2bfeb9",
          "message": "Test suite: Assume compatible system if xcode not installed (#539)",
          "timestamp": "2025-02-12T08:57:07+01:00",
          "tree_id": "60b341387d229c27887869be4f93392069cdf8da",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/3ad45e2cd0482d89c22b9c04bf92b40c1d2bfeb9"
        },
        "date": 1739349644198,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9206066500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3620935333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1245867333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 714833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1636083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9396937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1512312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2672792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 476292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 457062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "bec8c7165e2981d001ea993610e221f3bc206cbe",
          "message": "Add .git-blame-ignore-revs and a few other fixes (#541)",
          "timestamp": "2025-02-14T21:14:46+01:00",
          "tree_id": "eff0359937072144eaacfe0d8e42bac0c2d89b55",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/bec8c7165e2981d001ea993610e221f3bc206cbe"
        },
        "date": 1739566770795,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9097851875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3676407792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1241771750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 701916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1647333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10016083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1621729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2740896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 467166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 472958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "4324871a973c864cbc752ad94c61904a70be906b",
          "message": "Use GPUToolbox (#538)",
          "timestamp": "2025-02-15T13:07:29-04:00",
          "tree_id": "ea66d3410e2e83cc6a28efeba4e3a819b36982bc",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/4324871a973c864cbc752ad94c61904a70be906b"
        },
        "date": 1739642227342,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9071946333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3672313458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1239159916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 723334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1627542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10224103.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1593833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2576042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 459437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 464146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "eb1acb37102025b347cd3c25cb7b3e1f702861fa",
          "message": "Indentation consistency (#545)",
          "timestamp": "2025-02-17T11:47:08+01:00",
          "tree_id": "c3ca7916aa6ab795e0c0d26f0767c95b8385d06b",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/eb1acb37102025b347cd3c25cb7b3e1f702861fa"
        },
        "date": 1739792032367,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9045175500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3672503667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1237216416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 721750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1563042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9628354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1615666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2507334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 454125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 474208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10666.666666666666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "97121c85e69780af528041755c77901b5399d747",
          "message": "Update .git-blame-ignore-revs (#546)",
          "timestamp": "2025-02-17T10:32:48-04:00",
          "tree_id": "c3698c92ab8090d4a9ebe31d51a3458b0fce6afd",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/97121c85e69780af528041755c77901b5399d747"
        },
        "date": 1739805509541,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9053175042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3671462500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1240563166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 704854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1599291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10684895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1572666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2576292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 474000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 460542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "5af28d2a32dcc855dadb75146ae681af42eea10c",
          "message": "Integer & atomic Intrinsics improvements (#544)",
          "timestamp": "2025-02-18T13:51:31+01:00",
          "tree_id": "f10fc5a7946092dc36e677f8c65b2ced298137c4",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/5af28d2a32dcc855dadb75146ae681af42eea10c"
        },
        "date": 1739885588784,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9074421167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3673370834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1239309417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 706958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1568250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9660917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1508833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2730854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 450875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 457667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 37604.25,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":4,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "2bf7e24f5897b1860c5a312e57a1cd7e483639ab",
          "message": "Link to issue instead of embedding (not minimal) MWE",
          "timestamp": "2025-02-18T11:21:58-04:00",
          "tree_id": "9cb1ba00e8eb86017389840fce230f8389827c85",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/2bf7e24f5897b1860c5a312e57a1cd7e483639ab"
        },
        "date": 1739895408614,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9061843500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3674383375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1241024208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 711875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1598333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5616\nallocs=216\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10125958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1602937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2618167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 451291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 452166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9534.833333333332,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "79e5e6a0c31a8a1186a621fe2fa148345b56352e",
          "message": "Test both simd shuffle intrinsics. (#553)\n\n* Docstring fixup\n\n* Test both up and down shuffles",
          "timestamp": "2025-03-02T14:47:11-04:00",
          "tree_id": "fb72547bd7b7a5a899e47afb8c1db40eef3fe112",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/79e5e6a0c31a8a1186a621fe2fa148345b56352e"
        },
        "date": 1740944513543,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9053329292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3667844500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1238958834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 716333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1507500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8736937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1583375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2624645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 469542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 470666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "c5b425d97740873d1080d4871c9c1ed969917207",
          "message": "Enabling previously disabled test and mark broken (#554)",
          "timestamp": "2025-03-03T15:57:29+01:00",
          "tree_id": "cba2f741bf010fe86957b24e5dafbece60a80edb",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/c5b425d97740873d1080d4871c9c1ed969917207"
        },
        "date": 1741016714469,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9072804750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3675978250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1242875750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 713042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1568958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9347292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1561458.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2616271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 470084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 470000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 36947.75,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":4,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "b1eb6aa00b881297e608de75cfd051f5bbcba7a5",
          "message": "Support pow with Int exponent (#557)",
          "timestamp": "2025-03-04T07:26:54+01:00",
          "tree_id": "6c4f440193d82c2903ec5656c9160d490fb78d97",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/b1eb6aa00b881297e608de75cfd051f5bbcba7a5"
        },
        "date": 1741072470779,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9064648875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3675763375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1240346792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 708167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1543083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8482417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1657521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2673750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 480625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 465500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "82445622799857676998e511b1bda701b47169de",
          "message": "Fixes and more tests for `unsafe_wrap` (#558)\n\n* Prevent (broken) `unsafe_wrap` of `MtlArray` into `Array` of different eltype",
          "timestamp": "2025-03-10T14:10:06-03:00",
          "tree_id": "19adcc83bcba2ca9c1e91b61e212563db9069ea0",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/82445622799857676998e511b1bda701b47169de"
        },
        "date": 1741629232041,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9075600500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3679147333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1245610375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 719042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1522708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 12398375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1575917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2695167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 449292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 443375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "cd1526c80587dc88b3c54f9d42d2b80851dc2f4c",
          "message": "Update GPUToolbox compat (#560)",
          "timestamp": "2025-03-11T14:41:08-03:00",
          "tree_id": "201ada92f9359bd240c4df14fd3fc6fba9979daf",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/cd1526c80587dc88b3c54f9d42d2b80851dc2f4c"
        },
        "date": 1741717488683,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9077117791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3631655291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1243118458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 739646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1628917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 13236042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1551041.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2655167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 455479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 463250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "4903c64d7912dbce3345551f8b8b71e353665a2e",
          "message": "[NFC] Split up intrinsics tests (#561)",
          "timestamp": "2025-03-11T15:45:10-03:00",
          "tree_id": "9c035102861ea3f184fde3603bb302ef4fa579c7",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/4903c64d7912dbce3345551f8b8b71e353665a2e"
        },
        "date": 1741724173563,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9065026583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3618215084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1245634417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 715042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1564979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10783271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1534875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2619125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 468687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 468687,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9437.666666666666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "e3b6210d4675b13c5f2802d3d1e9435d20d4fe3c",
          "message": "Tweak profiling docs (#563)",
          "timestamp": "2025-03-13T09:42:11-03:00",
          "tree_id": "f058defbdce9ee63345e2956a12eb294d6b6b164",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/e3b6210d4675b13c5f2802d3d1e9435d20d4fe3c"
        },
        "date": 1741872653937,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9075402667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3636451500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1247012083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 736792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1563042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9313499.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1572166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2724375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 459666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 465833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "de0e3f937f28924841c8f06a949245e5f4ecdc95",
          "message": "Move linalg wrappers out of MPS lib (#565)",
          "timestamp": "2025-03-17T08:13:02-03:00",
          "tree_id": "290b26d43c6378504a6d37d4b8546b32f0c7afa2",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/de0e3f937f28924841c8f06a949245e5f4ecdc95"
        },
        "date": 1742212839826,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9065410083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3628496208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1243334625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 735687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1580375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11156583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1579979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2627208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 475541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 473334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10639,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "ebd90c56203b7a872bcd7dd468fccbba9275b004",
          "message": "`Pi` and `e` to `Float32` and `Float16` (#559)\n\n* pi and e to Float32 and Float16\n\n* Mimic Julia behaviour\n\n* Fix\n\n* OOPS\n\n* Automated definitions",
          "timestamp": "2025-03-17T09:39:24-03:00",
          "tree_id": "dc88bb0e1ff039c2a77814f31ec098165c89724a",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/ebd90c56203b7a872bcd7dd468fccbba9275b004"
        },
        "date": 1742217599994,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9087249625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3630022125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1243493750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 707479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1613375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9163416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1526479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2717875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 478167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 466875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 36687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":4,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "b7606f0143c80745aa27debd54f218b0a89325f0",
          "message": "Remove copy when possible from cpu rand using GPU RNG (#568)\n\n* Remove copy when possible from cpu rand using GPU RNG\n\n* Format",
          "timestamp": "2025-03-17T15:28:08-03:00",
          "tree_id": "f8fad35ede6c1cc468c2b90a264d591e72e58369",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/b7606f0143c80745aa27debd54f218b0a89325f0"
        },
        "date": 1742238710265,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9098777875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 5137594083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1244565875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 710917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1594958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9534438,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1613834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2614209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 453145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 452729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "8d4dd5de6af520c32cf0d0cb68e2e596cd454846",
          "message": "Code coverage and misc fixes (#569)\n\n* NDArray construction bug fix\n\n* `size` for MPSMatrix\n\n* Add and fix MPSMatrix tests\n\n* Don't track coverage for examples\n\n* Exclude device-only code from coverage\n\n* Exclude profiler tests from coverage\n\n* format\n\n* Struct coverage\n\n* MTLDevice tests\n\n* Move MPSDataType out of matrix file and test\n\n* Storage type tests\n\n* Format\n\n* Fix\n\n* Update lib/mps/matrix.jl\n\nCo-authored-by: Tim Besard <tim.besard@gmail.com>\n\n* Remove unused code and tests\n\n---------\n\nCo-authored-by: Tim Besard <tim.besard@gmail.com>",
          "timestamp": "2025-03-21T12:36:27-03:00",
          "tree_id": "e14db4d244dd572fac1e4da131d4b68239c4fe6e",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/8d4dd5de6af520c32cf0d0cb68e2e596cd454846"
        },
        "date": 1742574432626,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9093545041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3631460416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1244317708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 877750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1589083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5456\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10720104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11728\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1547292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4968\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2695437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8368\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 468750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3304\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 463584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3312\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "d606fee4502fe7650f87a88087a6457c0b333488",
          "message": "Remove obsolete `MtlLargerDeviceArray` (#574)",
          "timestamp": "2025-03-26T13:43:34-03:00",
          "tree_id": "3b09598511d271cf5a8d52ae1f8b34698f0c85b8",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/d606fee4502fe7650f87a88087a6457c0b333488"
        },
        "date": 1743013245031,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9077384625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3683558625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1246565625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 710333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1642625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8899770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1545146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2724375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 480417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 462979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 37000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":4,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "f3f5210bb1768962577978c1c34471b9cf9bc857",
          "message": "Silence warning on 1.12+ (#575)",
          "timestamp": "2025-03-27T15:52:21+01:00",
          "tree_id": "57c09567362b8d9fe6537925371c7b45d2ecb008",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/f3f5210bb1768962577978c1c34471b9cf9bc857"
        },
        "date": 1743089818461,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9095425375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3716855084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1240712291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 730166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1590000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11574896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1621834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2683541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 478375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 485708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10097.166666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "369e292b48874901608a2b3a75729c52b236be98",
          "message": "15.4 SDK changes (#579)",
          "timestamp": "2025-04-02T14:15:05-03:00",
          "tree_id": "cd0264c1f90cde97f01b896c12d5c11a10615245",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/369e292b48874901608a2b3a75729c52b236be98"
        },
        "date": 1743617089006,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9111380625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3718960708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1244311500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 714084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1562604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10396459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1559083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2742208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 464021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 461542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "fab6fc2c7bb3d1ebf19c8e9f813ec73d420233a5",
          "message": "Initial MPSGraph support & use for matmul (#566)\n\n* Initial MPSGraph support\n\n* Use MPSGraph for matrix multiplication\n\n* Add encode function and move run functions\n\n* Implementation more similar to MPS implementation\n\n* Also use MPSGraph matmul for int -> float matmul\n\nThe only code left running with MPS are the contiguous views.\n\n* Remove copying\n\n* All operations using Float32\n\n* Tweak\n\n* Fix cast to Float32 when beta != 0\n\n* More operations\n\n* Support more complex broadcasting behaviour\n\nWill unblock NNlib issue 614\n\n* More API\n\n* Use optimization Level 0 by default to disable use of neural engine\n\n* @autoreleasepool\n\n* Push test script\n\n* Fix and test MPSGraph random\n\n* Comment out unused and slightly broken code\n\n* Tests and coverage-related fixes\n\n* Add comment explaining why use OptimizationLevel0\n\n* format\n\n* Guard against invalid ranks\n\n* Move flopscomp to examples\n\n* Fix running tests locally\n\n* Fix",
          "timestamp": "2025-04-11T10:17:33-03:00",
          "tree_id": "498ad71afaa454564a5ac17d68e25853c35755d4",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/fab6fc2c7bb3d1ebf19c8e9f813ec73d420233a5"
        },
        "date": 1744379958904,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9625622625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3681887084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1253500083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 712750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1515459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9046333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1617542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2591083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 479250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 476500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9743.166666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "distinct": true,
          "id": "a5b56dc73c9344277a828b77f89bddcef0c13bc1",
          "message": "Fix example\n\nGot a CI failure and it may be due to the crazy number of threads and groups launched",
          "timestamp": "2025-04-17T15:54:29-03:00",
          "tree_id": "1c4b8d655666c9e5d3c3411da1c1ab04946eb213",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/a5b56dc73c9344277a828b77f89bddcef0c13bc1"
        },
        "date": 1744918941808,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9742903667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3743066375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1260251146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 725167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1637687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9931917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1568625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2585875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 451375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 455625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 40828.125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":4,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "ab25f7b4c88b6a9bd6f0fd047db454ef53655979",
          "message": "Fix `erf` and a few other improvements (#582)\n\n* Fix `erf`\n\n* [NFC] Semicolon cleanup\n\n* Test proper type",
          "timestamp": "2025-04-18T10:22:34-03:00",
          "tree_id": "8e3470e355113643022abe6450c67ff06f3cbba6",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/ab25f7b4c88b6a9bd6f0fd047db454ef53655979"
        },
        "date": 1744985903369,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9727177292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3750015354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1262111583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 721208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1603583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9133667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1551042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2667229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 454291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 451708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "770621195fd548b7efb008e3b2b5f76b0c5c60c6",
          "message": "Faster matmul sometimes (#580)\n\n* Use MPS instead of MPSGraph matmul when optimal\n\n* Faster testing\n\n* Fix\n\n* Algorithm selection\n\n* flopscomp improvements\n\n* Fix & tests\n\n* No need for AppleAccelerate\n\n* More specific error\n\n* More tests",
          "timestamp": "2025-04-18T11:58:55-03:00",
          "tree_id": "8561c6465aa96c0b37c5bebcdb7e9254efdb1b66",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/770621195fd548b7efb008e3b2b5f76b0c5c60c6"
        },
        "date": 1744991017965,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9749067333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3755012187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1264204812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 728416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1650459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11271625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1575188,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2712750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 448895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 454416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "987264c3befd92434ee1c70cfd2dbfc1fc987ff6",
          "message": "Clean up test imports (#584)\n\n* Fix MPSGraphRandomOpDescriptor tests\n\n* Clean up test imports\n\n* Whitespace consistency\n\n* Capitalization consistency\n\n* `end` clarifcation comments",
          "timestamp": "2025-04-20T23:59:25-03:00",
          "tree_id": "76f2b6d41baf823d28bf0516c3b96caca7a6eca2",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/987264c3befd92434ee1c70cfd2dbfc1fc987ff6"
        },
        "date": 1745207167793,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9739659292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3741470917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1262158250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 731437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1601250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9288917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1623083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2532250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 495125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 491500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "30432ce08d76ab243e696dcf9da5316103df3cce",
          "message": "Fix `findall` output type (#587)",
          "timestamp": "2025-04-26T10:48:48-03:00",
          "tree_id": "638d9f5204c4eedf89b0862d7574094fdec60aa3",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/30432ce08d76ab243e696dcf9da5316103df3cce"
        },
        "date": 1745678018557,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9809228875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4098260792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1283734937,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 720666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1606875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9182208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1555916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2739750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 495292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 479312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10020.833333333334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 16167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "145dc33dc229bde7a436c4e8e89b8d682732f7db",
          "message": "Fix some type ambiguities (#585)",
          "timestamp": "2025-04-29T10:51:14-03:00",
          "tree_id": "2443b672fe0330e857a584e7c98ea2c9bf267c48",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/145dc33dc229bde7a436c4e8e89b8d682732f7db"
        },
        "date": 1745937471092,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9789281125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4093497583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1281719042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 730042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1532271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9674062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1553625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2640083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 504437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 490208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9305.666666666666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "e1cb12e0ccac43a9cc4c2b1faf0a74c1b9a8744a",
          "message": "Fix tests for macOS 13 (#591)",
          "timestamp": "2025-05-20T11:08:45-03:00",
          "tree_id": "0dfb0bdc86d82da0d3a49c1eb1da5eda90c86707",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/e1cb12e0ccac43a9cc4c2b1faf0a74c1b9a8744a"
        },
        "date": 1747753167953,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9800310667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4097349916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1279086125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 731938,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1554979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8369583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1571292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2549291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 450459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 456000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9173.666666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "caf299690aa52448ee72ffc5688939b157fc1ba2",
          "message": "Minor `findall` and `accumulate` tests improvements (#592)",
          "timestamp": "2025-05-21T07:38:08-03:00",
          "tree_id": "f31f9c64412fda9847e41dc70dbc5a5df1cddac4",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/caf299690aa52448ee72ffc5688939b157fc1ba2"
        },
        "date": 1747826570533,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9802163250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4108894000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1286845416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 708167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1642916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9533624.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1619479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2720083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 461167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 459625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "2ff52d6a4a218e19a8c92ee9e05b16dbf06a4a93",
          "message": "Bump version (#595)\n\n* Bump version\n\n* Update README",
          "timestamp": "2025-05-24T13:50:39-03:00",
          "tree_id": "d367e4f5ba0079865eb1501e4ffe79102969ecd9",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/2ff52d6a4a218e19a8c92ee9e05b16dbf06a4a93"
        },
        "date": 1748108178083,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9822209833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4092380750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1283501208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 729375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1590271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8280666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1604292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2643292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 475208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 479875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "marco.lombardi@gmail.com",
            "name": "Marco Lombardi",
            "username": "astrozot"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "f4afc6b619942b26ca08dc584664d8335831e205",
          "message": "Define `KA.functional()` (#598)",
          "timestamp": "2025-05-25T22:38:44-03:00",
          "tree_id": "3f946afad6c68165d3d5f9aaa79e76ff8f0ee981",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/f4afc6b619942b26ca08dc584664d8335831e205"
        },
        "date": 1748226381121,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9809183500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4095908542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1281441729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 715625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1506187,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8870729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1457625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2581000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 457000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 453083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 37052,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":4,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "914900661e9792b1a7a4a731cd2328916febaf61",
          "message": "Update requirements (#599)",
          "timestamp": "2025-05-27T09:43:39-03:00",
          "tree_id": "305baf991b120ceb2a35a6614b79075ac93e8833",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/914900661e9792b1a7a4a731cd2328916febaf61"
        },
        "date": 1748351536908,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9811772417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 5450180479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1282178937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 739104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1571021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10064521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1580812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2557374.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 491625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 488334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "b908b0ac5adf6cc99bd758ada7f91d1834fb130a",
          "message": "Fix findall with empty MtlArray of Bool (#601)",
          "timestamp": "2025-05-29T13:53:13-03:00",
          "tree_id": "72894c6bd7739013358522a0b018563703ea0b74",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/b908b0ac5adf6cc99bd758ada7f91d1834fb130a"
        },
        "date": 1748540455124,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9837898584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 5460261541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1287414708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 701916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1560125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10094709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1444145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2527917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 484625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 488666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "distinct": true,
          "id": "7ceb3e57eaade8e0a1f036ab280e2fc7de8dc01d",
          "message": "[NFC] Typo",
          "timestamp": "2025-06-02T14:34:44-03:00",
          "tree_id": "84593b607c5e72831eb035d07768b2699f98985a",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/7ceb3e57eaade8e0a1f036ab280e2fc7de8dc01d"
        },
        "date": 1748888971640,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9803886125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4095186000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1284667625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 720250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1512208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9805521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1519500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2566000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 464417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 467042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 10215.166666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "3e9bbacdb5f55cf3fbf497be1b7985ba035e102d",
          "message": "Add bare minimum for macOS 26 Tahoe (#604)\n\n* Add bare minimum for macOS 26 tahoe\n\n* Bump Version",
          "timestamp": "2025-06-10T16:50:46-03:00",
          "tree_id": "0aa2d1ad40e96012edef9085920ba74fb3a5ba6c",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/3e9bbacdb5f55cf3fbf497be1b7985ba035e102d"
        },
        "date": 1749587844278,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9824383333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4070078667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1287479896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 720750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1611417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10181000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1551083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2535687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 462813,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 474667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "ian.limarta@gmail.com",
            "name": "Ian",
            "username": "limarta"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "d81fd4c2438ccd5dd40aa1c7eda0c276e3bed2e6",
          "message": "Handle broadcasting when storage types are different (#605)\n\nCo-authored-by: Christian Guinard <28689358+christiangnrd@users.noreply.github.com>",
          "timestamp": "2025-06-14T10:35:38+02:00",
          "tree_id": "f279739a5f3d1c7827dd20e960bb154449a61fa5",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/d81fd4c2438ccd5dd40aa1c7eda0c276e3bed2e6"
        },
        "date": 1749892936457,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9798579083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4058922333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1282770000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 720917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1523750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9127916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1459041.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2650250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 464792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 494250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9048.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "962e9e1c9657999667b6078c4ddc056f8b055214",
          "message": "Add JLD2 to test env (#606)",
          "timestamp": "2025-06-17T10:55:37-03:00",
          "tree_id": "ffcd72b657a45b47970996e5eb26d5a78eba677b",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/962e9e1c9657999667b6078c4ddc056f8b055214"
        },
        "date": 1750171229766,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9854126084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4090824417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1291574687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 696750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1608354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11656583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1611937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2737625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 468000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 464333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "distinct": true,
          "id": "2fb763ce6c12bbbc48a4ee8e8cb13809de489b70",
          "message": "Tahoe versioning",
          "timestamp": "2025-06-23T08:45:11-03:00",
          "tree_id": "05aa67ad78fee3a2b2dcc747a8f950a4626a256e",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/2fb763ce6c12bbbc48a4ee8e8cb13809de489b70"
        },
        "date": 1750681963284,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9808326625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4064804750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1280817728.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 726791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1505104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8601792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1585459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2587750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 453375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 455792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 11590.166666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "945a1ae2fdf8ec5f027d692b10c817ee61394cfe",
          "message": "Add `MemoryFlagDevice` to KA.jl's synchronization primitive. (#609)\n\nKernelAbstractions (influenced by CUDA) states\n\n> After a  statement all read and writes to global and local memory\n> from each thread in the workgroup are visible in from all other threads in the\n> workgroup.",
          "timestamp": "2025-06-23T19:22:51-03:00",
          "tree_id": "eceeeb72d03a3d6fa2661173dba57623038bd8e5",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/945a1ae2fdf8ec5f027d692b10c817ee61394cfe"
        },
        "date": 1750721016162,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9852724792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4077657833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1282163438,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 730833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1525395.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8785291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1540792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2728291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 478958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 471145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 35843.75,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":4,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "4abe75f501fa2f25e06fc43fa2995c1079c888fa",
          "message": "Bump version (#611)",
          "timestamp": "2025-06-24T08:56:01+02:00",
          "tree_id": "b56223ce0199a10924647cde20da15cf5492b75d",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/4abe75f501fa2f25e06fc43fa2995c1079c888fa"
        },
        "date": 1750750837512,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9812875250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4071015166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1279968583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 706083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1645500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10475417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1618417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2694041.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 458250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 462875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "2a99e5c00c61d9af69ca135c0dce945901db1114",
          "message": "Synchronize resources before cpu access of `ManagedStorage` resource (#617)\n\n* Synchronize resources before cpu access of `ManagedStorage` resource\n\nAlso a few test tweaks\n\n* Update MPSCopy tests",
          "timestamp": "2025-06-30T07:15:10-03:00",
          "tree_id": "e88e2db7b1885a448bcb30d204194847cb61666a",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/2a99e5c00c61d9af69ca135c0dce945901db1114"
        },
        "date": 1751281369528,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9964488334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4129414541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1301301833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 770583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1701146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 20300124.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1687833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2866292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 469709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 478333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "7c2b8202c98c99fc1d749412b195fdeb71c33e86",
          "message": "Remove the unnecessary reshape during mapreduce (#615)\n\n* Remove the unnecessary reshape during mapreduce\n\n* Work around issue #616\n\n* Add details\n\n* Only create new kernel when needed.\n\nComment from CUDA implementation",
          "timestamp": "2025-06-30T14:49:36-03:00",
          "tree_id": "4c820f1edbc71247b1119a1eaa4db49a4f559f0e",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/7c2b8202c98c99fc1d749412b195fdeb71c33e86"
        },
        "date": 1751308696773,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9950118875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4131570708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1296551562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 748500.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1658417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 19917854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1652292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2864083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 461812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 460708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "b8fb8128a335d6aae1acc04ab96aa3f973c8bf41",
          "message": "More accumulation and reduction benchmarks (#614)\n\n* Test exapanded benchmarking\n\n* Increase benchmark timeout\n\n* Only run some benchmarks once",
          "timestamp": "2025-07-02T08:19:09-03:00",
          "tree_id": "220d29756c6c8b5949043729499ab7067d4d7478",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/b8fb8128a335d6aae1acc04ab96aa3f973c8bf41"
        },
        "date": 1751456921377,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9965709083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4063753917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1303617167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 765458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1661250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 20890458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1655417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2854062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 465250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 475208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 25114.583333333336,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1184\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 461750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3440\nallocs=128\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 906334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1944\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 596562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 557084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 550583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 891916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1960\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 804792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1944\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1535042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33200\nallocs=1207\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1798792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8688\nallocs=320\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2210416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8736\nallocs=323\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 12547791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8624\nallocs=316\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9415479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=36224\nallocs=1303\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1454000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33312\nallocs=1216\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1534083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=322\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 1905312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8752\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 10710542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8640\nallocs=318\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7104312,
            "unit": "ns",
            "extra": "gctime=0\nmemory=36336\nallocs=1312\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1223209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=475\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 1108979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5824\nallocs=209\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1143875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12168\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 20783687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5808\nallocs=208\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3578083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=654\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 955229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12528\nallocs=484\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 689916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5856\nallocs=211\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 781646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12360\nallocs=447\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 7099958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5888\nallocs=213\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1735249.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=669\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1222375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=475\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 1085125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5824\nallocs=209\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1134083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12168\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 20902625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5808\nallocs=208\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3612500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=654\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 951270.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12528\nallocs=484\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 701875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5856\nallocs=211\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 807229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12360\nallocs=447\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 7122000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5888\nallocs=213\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1731250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=669\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 541458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 679917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 692500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 2100062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45440\nallocs=1623\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1811792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38632\nallocs=1399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1758729.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25112\nallocs=930\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1688917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25112\nallocs=930\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 2497333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=533\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 3299479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=63416\nallocs=2313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1718042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23184\nallocs=841\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1437479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20328\nallocs=668\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 854229.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2416\nallocs=79\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 80292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 79833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 79625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 2063375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45440\nallocs=1623\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1819667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38696\nallocs=1403\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1425146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24088\nallocs=888\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1399458.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24088\nallocs=888\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 162417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 3274083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=62408\nallocs=2270\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1390271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22160\nallocs=799\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1436083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20328\nallocs=668\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 215375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2448\nallocs=79\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2672375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10720\nallocs=314\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1124041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9088\nallocs=311\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1819750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9768\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "1e1e193282b80da3d5f16b2296a6b091e6d120a1",
          "message": "Fix linalg tests for MPS and MPSGraph (#618)",
          "timestamp": "2025-07-03T08:36:34+02:00",
          "tree_id": "41ebd599c98ba32cde8da7f1d4a1a7760ce9d853",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/1e1e193282b80da3d5f16b2296a6b091e6d120a1"
        },
        "date": 1751527513306,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9827584125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4013032375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1282295875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 708125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1494458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10025187,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1528125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2599833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 462166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 447666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 23458.333333333332,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1184\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 467000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3440\nallocs=128\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 787333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1944\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 630062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 576083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 600458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 769458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1960\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 599750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1944\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1379000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33200\nallocs=1207\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1634125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8688\nallocs=320\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2007812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8736\nallocs=323\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 11781708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8624\nallocs=316\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9305062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=36224\nallocs=1303\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1365500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33312\nallocs=1216\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1398667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=322\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 1704521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8752\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 10062125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8640\nallocs=318\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 6950854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=36336\nallocs=1312\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1183542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=475\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 955083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5824\nallocs=209\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1071917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12168\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 19691271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5808\nallocs=208\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3377000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=654\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 1040625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12528\nallocs=484\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 660187,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5856\nallocs=211\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 760896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12360\nallocs=447\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 6651562,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5888\nallocs=213\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1671125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=669\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1189833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=475\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 980250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5824\nallocs=209\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1073291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12168\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 19772500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5808\nallocs=208\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3401979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=654\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 1044083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12528\nallocs=484\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 651500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5856\nallocs=211\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 754104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12360\nallocs=447\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 6699063,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5888\nallocs=213\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1672541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=669\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 658250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 833666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 672166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1859416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45440\nallocs=1623\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1617958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38632\nallocs=1399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1643250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25112\nallocs=930\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1633625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25112\nallocs=930\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 3896458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=533\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 3000958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=63464\nallocs=2316\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1621604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23184\nallocs=841\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1335750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20328\nallocs=668\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 558292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2416\nallocs=79\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 79917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 83000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 86333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1870083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=44584\nallocs=1592\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1622375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38632\nallocs=1399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1355375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24088\nallocs=888\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1342334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24088\nallocs=888\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 157917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2902167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=62408\nallocs=2270\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1332938,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22160\nallocs=799\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1358459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20328\nallocs=668\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 242792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2448\nallocs=79\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2470875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10720\nallocs=314\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1032542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9088\nallocs=311\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1571750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9768\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "9a7dd1e2d2c65edcd127e113b5cf672a9aa13f44",
          "message": "Don't warn on macOS 26 and bump version (#620)",
          "timestamp": "2025-07-14T07:46:25-03:00",
          "tree_id": "52f59ce7048a586cf5bb1908299a36ca167fc2b9",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/9a7dd1e2d2c65edcd127e113b5cf672a9aa13f44"
        },
        "date": 1752492785860,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9834677750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3969921708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1272069979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 727687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1533792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 8832333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1547458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2518229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 459625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 468479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 24883.4,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1184\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":5,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 462917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3440\nallocs=128\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 804521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1944\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 632000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 563541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 595375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 782792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1960\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 630188,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1944\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1367375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33104\nallocs=1202\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1633416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8688\nallocs=320\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2000167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8736\nallocs=323\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 11697000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8624\nallocs=316\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9292209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=36128\nallocs=1298\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1363292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33200\nallocs=1210\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1390500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=322\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 1703167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8752\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 10070270.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8640\nallocs=318\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 6938583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=36224\nallocs=1306\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1179333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=475\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 970333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5824\nallocs=209\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1072667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12168\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 19752708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5808\nallocs=208\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3391792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=654\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 1044167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12528\nallocs=484\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 656416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5856\nallocs=211\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 759000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12360\nallocs=447\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 6657791.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5888\nallocs=213\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1650270.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=669\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1184979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=475\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 957125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5824\nallocs=209\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1081104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12168\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 19812499.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5808\nallocs=208\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3408312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=654\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 1056500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12528\nallocs=484\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 668667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5856\nallocs=211\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 776229.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12360\nallocs=447\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 6700208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5888\nallocs=213\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1670375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=669\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 663709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 831895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 672083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1863541.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=44488\nallocs=1587\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1615645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38536\nallocs=1394\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1642916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25112\nallocs=930\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1636459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25112\nallocs=930\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 3878750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=533\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2979000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=63304\nallocs=2307\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1616083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23184\nallocs=841\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1338333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20328\nallocs=668\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 562000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2416\nallocs=79\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 79875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 79209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 79584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1870354.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=44488\nallocs=1587\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1618667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38536\nallocs=1394\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1344416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24088\nallocs=888\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1331083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24088\nallocs=888\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 159458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2878854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=62312\nallocs=2265\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1319812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22160\nallocs=799\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1350604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20328\nallocs=668\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 231166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2448\nallocs=79\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2558458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10464\nallocs=307\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1030125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8912\nallocs=304\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1602333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9560\nallocs=306\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "5412886+jandrej@users.noreply.github.com",
            "name": "Julian Andrej",
            "username": "jandrej"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "b19b48a859252997e2638abb0df2d37a4cc3cbe8",
          "message": "Typo in `MPSMatrixMultiplication` comment (#622)",
          "timestamp": "2025-07-17T23:50:52-03:00",
          "tree_id": "58bbe4284564a9eb28069f704d495893924f10d7",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/b19b48a859252997e2638abb0df2d37a4cc3cbe8"
        },
        "date": 1752809906387,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9832701583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3978120417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1277029646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 727041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1525459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10129000.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1524958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2634459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 457417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 461916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 24371.583333333336,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1184\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 464084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3440\nallocs=128\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 820792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1944\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 630166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 558750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 586084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 781208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1960\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 606500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1944\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1365646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33104\nallocs=1202\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1634708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8688\nallocs=320\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2010729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8736\nallocs=323\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 11733792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8624\nallocs=316\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9454334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=36128\nallocs=1298\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1369917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33200\nallocs=1210\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1397708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=322\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 1739791.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8752\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 10024417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8640\nallocs=318\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7001437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=36224\nallocs=1306\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1183437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=475\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 952416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5824\nallocs=209\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1080000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12168\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 19770708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5808\nallocs=208\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3373708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=654\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 1051000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12528\nallocs=484\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 671417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5856\nallocs=211\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 765833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12360\nallocs=447\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 6650708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5888\nallocs=213\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1647959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=669\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1193292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=475\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 978458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5824\nallocs=209\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1066292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12168\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 19998375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5808\nallocs=208\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3402541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=654\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 1042271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12528\nallocs=484\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 665937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5856\nallocs=211\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 768375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12360\nallocs=447\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 6679625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5888\nallocs=213\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1680958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=669\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 678166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 676125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 831437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1845146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45344\nallocs=1618\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1614542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38664\nallocs=1402\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1653500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25112\nallocs=930\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1650166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25112\nallocs=930\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 3630291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=533\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2991875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=63400\nallocs=2313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1604750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23184\nallocs=841\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1336000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20328\nallocs=668\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 579979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2416\nallocs=79\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 80750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 85291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 84042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1878688,
            "unit": "ns",
            "extra": "gctime=0\nmemory=44488\nallocs=1587\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1618416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38536\nallocs=1394\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1358792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24088\nallocs=888\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1342959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24088\nallocs=888\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 160750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2887750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=62312\nallocs=2265\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1326208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22160\nallocs=799\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1354958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20328\nallocs=668\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 249917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2448\nallocs=79\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2537312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10464\nallocs=307\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1024062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8912\nallocs=304\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1585583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9560\nallocs=306\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "46d33590e6486962b79d0ac99fae5478bf167495",
          "message": "Accept alternate filename as optional argument (#629)\n\n[ ci skip]",
          "timestamp": "2025-07-23T16:03:28-04:00",
          "tree_id": "1e679fbe4f98c4e900ba2d3a85ae32d4bda23008",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/46d33590e6486962b79d0ac99fae5478bf167495"
        },
        "date": 1753304601081,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9807940542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3973285229.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1276664875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 716166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1553292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5472\nallocs=215\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9169958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11744\nallocs=462\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1535541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4984\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2601541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8384\nallocs=338\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 472646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3320\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 465583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3328\nallocs=133\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 23531.25,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1184\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 458875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3440\nallocs=128\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 825917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1944\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 611750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 575792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 601666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 774459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1960\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 613125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1944\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1385604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33104\nallocs=1202\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1631166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8688\nallocs=320\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2020896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8736\nallocs=323\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 11902666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8624\nallocs=316\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9342417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=36128\nallocs=1298\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1326813,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33200\nallocs=1210\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1390208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=322\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 1697437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8752\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 10044750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8640\nallocs=318\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 6941959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=36224\nallocs=1306\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1171041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=475\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 957125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5824\nallocs=209\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1040084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12168\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 19732792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5808\nallocs=208\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3383833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=654\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 1035000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12528\nallocs=484\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 655833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5856\nallocs=211\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 758708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12360\nallocs=447\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 6633583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5888\nallocs=213\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1656916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=669\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1166792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=475\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 956250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5824\nallocs=209\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1063104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12168\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 19777937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5808\nallocs=208\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3388208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=654\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 1027125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12528\nallocs=484\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 654375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5856\nallocs=211\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 754375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12360\nallocs=447\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 6681083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5888\nallocs=213\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1671083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=669\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 676625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 612417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 831687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1837500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45344\nallocs=1618\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1588958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38536\nallocs=1394\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1667083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25112\nallocs=930\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1631708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25112\nallocs=930\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 3568083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=533\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2978833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=63320\nallocs=2308\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1605187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23184\nallocs=841\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1326917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20328\nallocs=668\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 569458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2416\nallocs=79\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 82750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 83042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 82875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1829354.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=44520\nallocs=1589\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1609229.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38536\nallocs=1394\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1355667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24088\nallocs=888\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1332708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24088\nallocs=888\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 153542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2866917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=62312\nallocs=2265\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1310334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22160\nallocs=799\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1345333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20328\nallocs=668\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 248625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2448\nallocs=79\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2536000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10464\nallocs=307\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1004208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8912\nallocs=304\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1694792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9560\nallocs=306\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "b6e4050c0a96eb0edf245086edd5e438581ff668",
          "message": "Remove unnecessary OS signposts (#623)",
          "timestamp": "2025-07-26T12:33:47-04:00",
          "tree_id": "01cd4ffbd0668b71c39c095ed347866d3b156cfe",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/b6e4050c0a96eb0edf245086edd5e438581ff668"
        },
        "date": 1753550786402,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9831353875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3978943458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1278518291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 904833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1626125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3760\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10456187,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7440\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1628104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2744500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5376\nallocs=254\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 647875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2456\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 561896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2464\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 6160.714285714285,
            "unit": "ns",
            "extra": "gctime=0\nmemory=976\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 621125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2576\nallocs=104\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 826667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 620520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 564000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 595000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 805000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1440\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 645959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1368021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21752\nallocs=908\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1924583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5624\nallocs=242\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2266229.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5672\nallocs=245\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 11838896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5560\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9915353.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23912\nallocs=980\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1246625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21848\nallocs=916\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1650375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5640\nallocs=244\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 1980708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5688\nallocs=247\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 10024417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5576\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7431291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24008\nallocs=988\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1570334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8984\nallocs=379\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 1136083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1273438,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8568\nallocs=351\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 19899834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4008\nallocs=166\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3546708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13120\nallocs=528\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 1037750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9112\nallocs=387\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 855417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4056\nallocs=169\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 808833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8760\nallocs=363\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 6613292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4088\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1857792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13360\nallocs=543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1599417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8984\nallocs=379\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 1134979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1299125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8568\nallocs=351\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 20003167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4008\nallocs=166\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3554167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13120\nallocs=528\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 1026895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9112\nallocs=387\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 852812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4056\nallocs=169\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 809292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8760\nallocs=363\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 6616708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4088\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1867083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13360\nallocs=543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 659166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 826375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 821750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1719333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29528\nallocs=1227\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1538229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 2021520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18592\nallocs=756\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1752979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18592\nallocs=756\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 4175146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8112\nallocs=413\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2665417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=43224\nallocs=1803\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1959500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=703\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1502250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=566\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 645625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1896\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 83875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 83542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 83042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1706416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29912\nallocs=1241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1553583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1532708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18000\nallocs=726\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1398521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18000\nallocs=726\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 152083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2579500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=42648\nallocs=1773\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1441833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17320\nallocs=673\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1523979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=566\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 247375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1928\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2529375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7784\nallocs=241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1271291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6264\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1843542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6880\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "b80b103148d12c19d0bd8e3c602afd10b3b84e2d",
          "message": "Add function to retrieve # of gpu cores in system (#626)\n\n* Add function to retrieve # of gpu cores in system\n\n* Add core information to `versioninfo`",
          "timestamp": "2025-07-26T17:02:10-03:00",
          "tree_id": "8ba34d19797efaa7d53cb0323093d28ad5b0915e",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/b80b103148d12c19d0bd8e3c602afd10b3b84e2d"
        },
        "date": 1753563470679,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9807795917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3975416666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1273178666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 903000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1591646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3760\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10090187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7440\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1602375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2678959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5376\nallocs=254\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 653667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2456\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 664666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2464\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 6309.428571428572,
            "unit": "ns",
            "extra": "gctime=0\nmemory=976\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 635167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2576\nallocs=104\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 879375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 632083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 567583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 586833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 821792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1440\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 606625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1354083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21752\nallocs=908\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1911250.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5624\nallocs=242\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2281271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5672\nallocs=245\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 11889875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5560\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9885250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23912\nallocs=980\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1247042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21848\nallocs=916\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1650625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5640\nallocs=244\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 1985958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5688\nallocs=247\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 9951125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5576\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7429646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24008\nallocs=988\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1551833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8984\nallocs=379\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 1142188,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1300062,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8568\nallocs=351\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 19892167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4008\nallocs=166\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3550583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13120\nallocs=528\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 1039479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9112\nallocs=387\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 856709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4056\nallocs=169\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 760459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8760\nallocs=363\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 6615708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4088\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1870875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13360\nallocs=543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1557375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8984\nallocs=379\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 1158167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1317312,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8568\nallocs=351\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 19972584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4008\nallocs=166\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3572292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13120\nallocs=528\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 1046833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9112\nallocs=387\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 860083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4056\nallocs=169\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 819166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8760\nallocs=363\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 6603562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4088\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1875437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13360\nallocs=543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 671604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 823458.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 811416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1742833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1530833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1863166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18592\nallocs=756\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1768333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18592\nallocs=756\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 5543708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8112\nallocs=413\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2687375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=43224\nallocs=1803\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1958146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=703\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1510333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=566\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 569000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1896\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 79500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 84500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 82542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1705000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1566479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1424625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18000\nallocs=726\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1404125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18000\nallocs=726\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 156416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2564083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=42648\nallocs=1773\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1410500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17320\nallocs=673\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1534125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=566\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 249708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1928\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2516250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7784\nallocs=241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1264292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6264\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1839792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6880\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "fd9e25e65698ad4af167750162d296d31f119768",
          "message": "Support KA unified memory (#630)",
          "timestamp": "2025-07-28T05:15:56-04:00",
          "tree_id": "b61ca7c7b2ccad346afcd4640690a068ad1dd327",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/fd9e25e65698ad4af167750162d296d31f119768"
        },
        "date": 1753697330649,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9966752250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4040946375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1295912291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 896645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1675771,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3760\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 21136291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7440\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1645854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2800541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5376\nallocs=254\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 500375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2456\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 534709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2464\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 6465.166666666667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=976\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 530396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2576\nallocs=104\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 946417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 593187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 550291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 557666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 913042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1440\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 822937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1438146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21752\nallocs=908\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 2035104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5624\nallocs=242\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2386291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5672\nallocs=245\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 12662229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5560\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 10029667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23912\nallocs=980\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1220250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21848\nallocs=916\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1753125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5640\nallocs=244\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 2194917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5688\nallocs=247\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 10791916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5576\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7704333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24008\nallocs=988\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1307333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8984\nallocs=379\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 1166958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1310437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8568\nallocs=351\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 21046625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4008\nallocs=166\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3601500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13120\nallocs=528\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 842312,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9112\nallocs=387\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 878583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4056\nallocs=169\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 779125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8760\nallocs=363\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 7130396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4088\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1914874.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13360\nallocs=543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1294375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8984\nallocs=379\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 1177000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1310875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8568\nallocs=351\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 21050333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4008\nallocs=166\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3653646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13120\nallocs=528\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 846042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9112\nallocs=387\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 849375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4056\nallocs=169\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 779604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8760\nallocs=363\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 7155250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4088\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1923833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13360\nallocs=543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 554041.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 709896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 719834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1680375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1588041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1825542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18592\nallocs=756\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1762208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18592\nallocs=756\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 3153687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8112\nallocs=413\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2774583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=43224\nallocs=1803\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1843125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=703\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1544959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=566\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 907458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1896\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 80083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 82583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 80458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1687937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1591250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1498187,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18000\nallocs=726\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1431750.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18000\nallocs=726\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 156667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2601854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=42648\nallocs=1773\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1492458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17320\nallocs=673\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1573041.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=566\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 213709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1928\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2700208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7784\nallocs=241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1336333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6264\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 2008833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6880\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tim.besard@gmail.com",
            "name": "Tim Besard",
            "username": "maleadt"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "4b05d303c2f5528d993e570b4f2123d3baea2b68",
          "message": "Bump version.",
          "timestamp": "2025-07-28T19:08:32+02:00",
          "tree_id": "19e6e7b52ab1c0850e81438e6de5ed59ebd4fca9",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/4b05d303c2f5528d993e570b4f2123d3baea2b68"
        },
        "date": 1753725250748,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9958861667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4033351208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1297505000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 902875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1648541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3760\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 22029125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7440\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1623791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2786541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5376\nallocs=254\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 520645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2456\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 518542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2464\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 7917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 6347.333333333333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=976\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 543229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2576\nallocs=104\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 950624.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 600750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 551666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 549417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 938188,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1440\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 869917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1410625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21752\nallocs=908\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1979291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5624\nallocs=242\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2362542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5672\nallocs=245\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 12465354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5560\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 10148791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23912\nallocs=980\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1224854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21848\nallocs=916\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1703208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5640\nallocs=244\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 2167708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5688\nallocs=247\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 10650916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5576\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7679250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24008\nallocs=988\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1263833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8984\nallocs=379\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 1165042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1280125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8568\nallocs=351\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 20815958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4008\nallocs=166\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3593875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13120\nallocs=528\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 798792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9112\nallocs=387\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 852417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4056\nallocs=169\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 759000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8760\nallocs=363\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 7077896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4088\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1897354.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13360\nallocs=543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1295374.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8984\nallocs=379\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 1157625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1294375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8568\nallocs=351\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 20902334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4008\nallocs=166\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3606709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13120\nallocs=528\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 818041.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9112\nallocs=387\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 852604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4056\nallocs=169\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 749937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8760\nallocs=363\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 7111292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4088\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1908333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13360\nallocs=543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 590083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 711041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 770062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1686125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1580166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1852416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18592\nallocs=756\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1757666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18592\nallocs=756\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 3010667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8112\nallocs=413\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2785479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=43224\nallocs=1803\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1798000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17912\nallocs=703\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1541250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=566\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 845208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1896\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 82750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 83417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 79208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1688833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1594000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1482792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18000\nallocs=726\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1418770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18000\nallocs=726\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 162375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2631645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=42648\nallocs=1773\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1454209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17320\nallocs=673\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1555083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=566\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 215125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1928\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2652167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7784\nallocs=241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1302500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6264\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1987209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6880\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "distinct": true,
          "id": "422c43f72bf88c0670ffa7f799b2afa2eede2320",
          "message": "Port mapreduce optimization from CUDA",
          "timestamp": "2025-07-31T22:37:54-03:00",
          "tree_id": "9a79a78ee50e9924d36430bca1ff292925969644",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/422c43f72bf88c0670ffa7f799b2afa2eede2320"
        },
        "date": 1754015197945,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9811445750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3973553937,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1273914917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 919250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1620625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3760\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9296666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7440\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1601437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2670791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5376\nallocs=254\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 668834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2456\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 663708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2464\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 6125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=976\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 635500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2576\nallocs=104\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 815104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 635375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 572750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 597958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 733583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1440\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 620604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1328542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21752\nallocs=908\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1915812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5624\nallocs=242\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2252917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5672\nallocs=245\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 11629709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5560\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9677895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23912\nallocs=980\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1230791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21848\nallocs=916\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1648666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5640\nallocs=244\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 1970042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5688\nallocs=247\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 9975938,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5576\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7387104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24008\nallocs=988\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1582500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9032\nallocs=384\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 1150791.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=168\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1302979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8616\nallocs=356\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 2153834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3856\nallocs=161\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3552729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13184\nallocs=535\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 1047958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9272\nallocs=399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 875334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4120\nallocs=174\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 801083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8920\nallocs=375\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 1800646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3888\nallocs=164\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1880520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13616\nallocs=562\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1555709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9032\nallocs=384\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 1139791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=168\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1276833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8616\nallocs=356\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 2162875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3856\nallocs=161\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3576375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13184\nallocs=535\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 1077521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9272\nallocs=399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 869417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4120\nallocs=174\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 796458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8920\nallocs=375\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 1791958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3888\nallocs=164\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1892687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13616\nallocs=562\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 654917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 822333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 815083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1662667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1504500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1894188,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18656\nallocs=763\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1818166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18656\nallocs=763\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 4215375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8112\nallocs=413\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2643833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=43272\nallocs=1808\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1959625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17976\nallocs=710\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1525062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=567\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 563000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1896\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 83167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 83500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 82792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1691958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1524959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1420354.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18064\nallocs=733\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1403958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18064\nallocs=733\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 158834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2536750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=42696\nallocs=1778\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1418937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17384\nallocs=680\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1545646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=567\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 246937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1928\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2531354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7784\nallocs=241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1248000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6264\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1810958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6880\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "194296871068a39eec434c7f9338fa0d50cfc049",
          "message": "Synchronize via MTLSharedEvents (#633)",
          "timestamp": "2025-08-01T09:38:05-03:00",
          "tree_id": "3b8b0ebb9fd15f85eec374439e012632245a956c",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/194296871068a39eec434c7f9338fa0d50cfc049"
        },
        "date": 1754054640520,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9844653958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3972040229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1275530958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 828500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3112\nallocs=142\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1536750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3600\nallocs=156\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 9632625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6896\nallocs=307\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1543583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3112\nallocs=142\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2621958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5024\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 567792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2424\nallocs=106\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 569292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=106\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 6625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=976\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 583375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2544\nallocs=101\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 784333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1536\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 623250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=544\nallocs=25\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 547458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=544\nallocs=25\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 585291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=544\nallocs=25\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 771250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1552\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 622687,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1536\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1277104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20312\nallocs=817\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1868333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5336\nallocs=223\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2183625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5384\nallocs=226\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 11737104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5272\nallocs=219\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9771416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22344\nallocs=881\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1142833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20408\nallocs=825\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1570458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5352\nallocs=225\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 1931625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5400\nallocs=228\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 9864375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5288\nallocs=221\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7308021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22936\nallocs=920\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1373353.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9256\nallocs=396\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 1069291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3928\nallocs=161\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1193292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8312\nallocs=336\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 2113062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3760\nallocs=154\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3456458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12784\nallocs=509\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 971625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9496\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 808458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 768979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8616\nallocs=355\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 1739041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3792\nallocs=157\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1772125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13312\nallocs=542\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1456146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9256\nallocs=396\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 1074875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3928\nallocs=161\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1206417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8312\nallocs=336\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 2119292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3760\nallocs=154\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3444375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12688\nallocs=503\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 990792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9496\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 810062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 761104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8616\nallocs=355\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 1740812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3792\nallocs=157\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1781292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13104\nallocs=529\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 651375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=52\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 805542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1088\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 817667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1088\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1646500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=27944\nallocs=1127\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1444584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24056\nallocs=979\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1754958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18768\nallocs=769\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1703625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18768\nallocs=769\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 4772500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9232\nallocs=473\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2536917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=43496\nallocs=1820\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1815666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18200\nallocs=722\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1431750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15360\nallocs=542\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 538167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2120\nallocs=85\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 86375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1088\nallocs=52\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 86583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=752\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 84833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=752\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1609874.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=27944\nallocs=1127\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1464354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24168\nallocs=986\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1377750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17360\nallocs=688\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1319166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17360\nallocs=688\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 217500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3472\nallocs=173\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2288708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=42776\nallocs=1781\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1421750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17192\nallocs=666\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1430854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15360\nallocs=542\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 248666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2152\nallocs=85\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2438438,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7560\nallocs=226\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1193250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6040\nallocs=223\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1768458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6656\nallocs=225\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 19916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=240\nallocs=11\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 20375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=384\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "9b8c6043c223433a9b601ffc3bf2dcc060017cd9",
          "message": "Revert \"Synchronize via MTLSharedEvents (#633)\" (#645)",
          "timestamp": "2025-08-01T21:30:30-03:00",
          "tree_id": "9a79a78ee50e9924d36430bca1ff292925969644",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/9b8c6043c223433a9b601ffc3bf2dcc060017cd9"
        },
        "date": 1754097553864,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9950383250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4042521958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1300517645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 902833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1627146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3760\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 19739042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7440\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1631792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2799250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5376\nallocs=254\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 502291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2456\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 524417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2464\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8479.166666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":3,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 5958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=976\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 544166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2576\nallocs=104\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 901875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 602875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 559458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 549500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 939708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1440\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 838375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1396042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21752\nallocs=908\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1920958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5624\nallocs=242\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2316166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5672\nallocs=245\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 12541000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5560\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 10017708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23912\nallocs=980\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1188292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21848\nallocs=916\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1700584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5640\nallocs=244\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 2092542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5688\nallocs=247\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 10561084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5576\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7616166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24008\nallocs=988\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1284584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9032\nallocs=384\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 1156208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=168\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1306625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8616\nallocs=356\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 2170417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3856\nallocs=161\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3596875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13184\nallocs=535\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 831770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9272\nallocs=399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 842667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4120\nallocs=174\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 754645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8920\nallocs=375\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 1861417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3888\nallocs=164\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1892375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13616\nallocs=562\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1287479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9032\nallocs=384\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 1167833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=168\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1287792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8616\nallocs=356\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 2217750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3856\nallocs=161\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3605771,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13184\nallocs=535\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 804562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9272\nallocs=399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 839750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4120\nallocs=174\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 750625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8920\nallocs=375\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 1827146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3888\nallocs=164\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1906334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13616\nallocs=562\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 585500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 762979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 716333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1641375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29528\nallocs=1227\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1569250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1846916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18656\nallocs=763\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1736417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18656\nallocs=763\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 3512729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8112\nallocs=413\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2713125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=43272\nallocs=1808\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1797333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17976\nallocs=710\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1538604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=567\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 852167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1896\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 79583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 81125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 80125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1640084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1570958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25528\nallocs=1072\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1480750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18064\nallocs=733\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1411792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18064\nallocs=733\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 158875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2506750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=42696\nallocs=1778\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1439375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17384\nallocs=680\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1557645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=567\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 214333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1928\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2582042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7784\nallocs=241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1282666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6264\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1945146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6880\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "973b0b9ca8e85cdd1e8e14b7d65708db2726debf",
          "message": "More `MPSGraphs` API (#624)\n\n* MPSGraphShapedType\n\n* MPSGraphDevice\n\n* MPSGraph compilation/serialization\n\n* Fix cenversion to MPSShape\n\n* Oops\n\n* Add test",
          "timestamp": "2025-08-05T16:29:15-03:00",
          "tree_id": "9ab1f4bd064e83d13408f113e71d948bc82782fd",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/973b0b9ca8e85cdd1e8e14b7d65708db2726debf"
        },
        "date": 1754424589698,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9829669667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 3983003812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1278572979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 899625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1625000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3760\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 10642250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7440\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1618291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2666792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5376\nallocs=254\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 645375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2456\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 672958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2464\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 6042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=976\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 630750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2576\nallocs=104\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 835041.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 646604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 571125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 598750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 744542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1440\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 605729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1339688,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21752\nallocs=908\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1926271.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5624\nallocs=242\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2238208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5672\nallocs=245\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 11748125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5560\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9832542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23912\nallocs=980\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1230271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21848\nallocs=916\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1620292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5640\nallocs=244\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 1978083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5688\nallocs=247\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 9896520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5576\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7358458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24008\nallocs=988\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1579208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9032\nallocs=384\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 1166917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=168\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1310042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8616\nallocs=356\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 2160750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3856\nallocs=161\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3545250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13184\nallocs=535\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 921333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9272\nallocs=399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 859479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4120\nallocs=174\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 823250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8920\nallocs=375\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 1787187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3888\nallocs=164\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1878875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13616\nallocs=562\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1557583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9032\nallocs=384\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 1127084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=168\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1301458.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8616\nallocs=356\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 2175375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3856\nallocs=161\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3560125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13184\nallocs=535\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 1045542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9272\nallocs=399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 861895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4120\nallocs=174\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 812250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8920\nallocs=375\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 1797833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3888\nallocs=164\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1893375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13616\nallocs=562\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 668646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 811458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 828167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1708834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29560\nallocs=1229\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1514291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25560\nallocs=1074\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1963083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18656\nallocs=763\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1807125.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18656\nallocs=763\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 4248000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8112\nallocs=413\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2622854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=43272\nallocs=1808\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1966500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17976\nallocs=710\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1522479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=567\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 603458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1896\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 81208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 83750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 84792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1705542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1532145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1446833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18064\nallocs=733\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1411583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18064\nallocs=733\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 159625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2528604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=42696\nallocs=1778\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1422709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17384\nallocs=680\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1536083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=567\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 248833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1928\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2519500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7784\nallocs=241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1257083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6264\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1814375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6880\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "28689358+christiangnrd@users.noreply.github.com",
            "name": "Christian Guinard",
            "username": "christiangnrd"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "4906e89486b4bf7bcd6d280c06ddb7ac1852da4f",
          "message": "Remove support for s backed by managed storage. (#649)",
          "timestamp": "2025-08-08T14:58:11-03:00",
          "tree_id": "06b2a3a58485f10af0a3d1b2fec2d69b5866017d",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/4906e89486b4bf7bcd6d280c06ddb7ac1852da4f"
        },
        "date": 1754678692983,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 9962072625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 4033234875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 1298936416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=46\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 908604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1653083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3760\nallocs=167\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 20429083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7440\nallocs=342\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1638125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3272\nallocs=153\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2766062,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5376\nallocs=254\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 518270.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2456\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 556833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2464\nallocs=109\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 9250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 6083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=976\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 568959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2576\nallocs=104\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 916625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 594667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 548834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 554667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 891083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1440\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 820667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1424\nallocs=50\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/1d",
            "value": 1380750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21752\nallocs=908\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1",
            "value": 1958812,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5624\nallocs=242\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2",
            "value": 2307125.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5672\nallocs=245\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=1L",
            "value": 12507146.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5560\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Int64/dims=2L",
            "value": 9986291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23912\nallocs=980\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/1d",
            "value": 1167542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21848\nallocs=916\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1",
            "value": 1696875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5640\nallocs=244\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2",
            "value": 2117750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5688\nallocs=247\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=1L",
            "value": 10523417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5576\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/Float32/dims=2L",
            "value": 7647041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24008\nallocs=988\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/1d",
            "value": 1279292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9032\nallocs=384\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1",
            "value": 1154958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=168\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2",
            "value": 1299833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8616\nallocs=356\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=1L",
            "value": 2196312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3856\nallocs=161\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Int64/dims=2L",
            "value": 3571208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13184\nallocs=535\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/1d",
            "value": 780167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9272\nallocs=399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1",
            "value": 858875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4120\nallocs=174\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2",
            "value": 752916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8920\nallocs=375\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=1L",
            "value": 1839312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3888\nallocs=164\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/Float32/dims=2L",
            "value": 1908229.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13616\nallocs=562\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/1d",
            "value": 1289416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9032\nallocs=384\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1",
            "value": 1168334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4024\nallocs=168\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2",
            "value": 1296375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8616\nallocs=356\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=1L",
            "value": 2151812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3856\nallocs=161\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Int64/dims=2L",
            "value": 3609395.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13184\nallocs=535\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/1d",
            "value": 810875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9272\nallocs=399\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1",
            "value": 848875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4120\nallocs=174\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2",
            "value": 750083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8920\nallocs=375\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=1L",
            "value": 1861979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3888\nallocs=164\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/Float32/dims=2L",
            "value": 1902979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13616\nallocs=562\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_gpu",
            "value": 517291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/cpu_to_gpu",
            "value": 761917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copyto!/gpu_to_cpu",
            "value": 716395.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=44\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/int",
            "value": 1654041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findall/bool",
            "value": 1542709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/int",
            "value": 1804750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18656\nallocs=763\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findfirst/bool",
            "value": 1738875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18656\nallocs=763\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/scalar",
            "value": 2870750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8112\nallocs=413\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/logical",
            "value": 2736687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=43272\nallocs=1808\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/1d",
            "value": 1769250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17976\nallocs=710\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/iteration/findmin/2d",
            "value": 1534416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=567\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/private/copy",
            "value": 820792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1896\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_gpu",
            "value": 82916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/cpu_to_gpu",
            "value": 84459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copyto!/gpu_to_cpu",
            "value": 80812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/int",
            "value": 1649459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=29736\nallocs=1240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findall/bool",
            "value": 1552875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=25496\nallocs=1070\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/int",
            "value": 1486375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18064\nallocs=733\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findfirst/bool",
            "value": 1417812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18064\nallocs=733\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/scalar",
            "value": 162000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/logical",
            "value": 2561750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=42696\nallocs=1778\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/1d",
            "value": 1440417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17384\nallocs=680\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/iteration/findmin/2d",
            "value": 1548708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15744\nallocs=567\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/shared/copy",
            "value": 207333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1928\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 2610042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7784\nallocs=241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 1292209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6264\nallocs=238\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 1927666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6880\nallocs=240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 15084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=128\nallocs=5\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 15875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=272\nallocs=13\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      }
    ]
  }
}