window.BENCHMARK_DATA = {
  "lastUpdate": 1732747249384,
  "repoUrl": "https://github.com/JuliaGPU/Metal.jl",
  "entries": {
    "Metal Benchmarks": [
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
          "id": "8652754205fbcc15a3b9133a10fbe20e085c888b",
          "message": "Add Benchmarking CI (#420)",
          "timestamp": "2024-09-26T14:07:24+02:00",
          "tree_id": "a198a169fdd1786d563a5699528d09637d9f67d1",
          "url": "https://github.com/JuliaGPU/Metal.jl/commit/8652754205fbcc15a3b9133a10fbe20e085c888b"
        },
        "date": 1727354317020,
        "tool": "julia",
        "benches": [
          {
            "name": "latency/precompile",
            "value": 4401680834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/ttfp",
            "value": 6678542687,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":60,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "latency/import",
            "value": 721498042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1312\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":30,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/metaldevrt",
            "value": 708167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=1",
            "value": 1530625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7472\nallocs=289\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=3",
            "value": 11010542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15824\nallocs=620\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/reference",
            "value": 1585084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6984\nallocs=278\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "integration/byval/slices=2",
            "value": 2472708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11392\nallocs=454\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing",
            "value": 454333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4664\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/indexing_checked",
            "value": 455667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=185\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "kernel/launch",
            "value": 8459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=48\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/construct",
            "value": 27638.916666666664,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/broadcast",
            "value": 464625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn/Float32",
            "value": 813083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/randn!/Float32",
            "value": 634041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Int64",
            "value": 552750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand!/Float32",
            "value": 577083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Int64",
            "value": 800833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/random/rand/Float32",
            "value": 583709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/copyto!/gpu_to_gpu",
            "value": 643166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/copyto!/cpu_to_gpu",
            "value": 600020.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/copyto!/gpu_to_cpu",
            "value": 777166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/1d",
            "value": 1334916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41936\nallocs=1544\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/accumulate/2d",
            "value": 1419167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11800\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/iteration/findall/int",
            "value": 2072542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=57048\nallocs=2078\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/iteration/findall/bool",
            "value": 1854833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=50056\nallocs=1845\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/iteration/findfirst/int",
            "value": 1674333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/iteration/findfirst/bool",
            "value": 1643833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/iteration/scalar",
            "value": 3625334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17056\nallocs=701\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/iteration/logical",
            "value": 3281021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=84632\nallocs=3107\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/iteration/findmin/1d",
            "value": 1572104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22032\nallocs=776\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/iteration/findmin/2d",
            "value": 1325292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/1d",
            "value": 1055583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/reduce/2d",
            "value": 690959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/1d",
            "value": 1057604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/reductions/mapreduce/2d",
            "value": 700416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/4d",
            "value": 846917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/2d",
            "value": 856979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/permutedims/3d",
            "value": 916917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "array/copy",
            "value": 610041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/stream",
            "value": 14667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=224\nallocs=9\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "metal/synchronization/context",
            "value": 14916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=368\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 23715.25,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 474145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 994125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 644458.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 569958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 606250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 831750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 897625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 660666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 555208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 709417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1430125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41936\nallocs=1544\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1499500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11800\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2210520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=57048\nallocs=2078\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 2041209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=50056\nallocs=1845\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1704833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1645334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 2430625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17056\nallocs=701\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3432895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=84632\nallocs=3107\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1763667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22032\nallocs=776\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1353479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 730853.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 709708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 800041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 713125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 949333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 930958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 1018708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 582583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 23972.166666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 478708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4912\nallocs=179\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 987500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 641062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 576520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 592333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 870458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 935229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 546667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 94125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=800\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 84208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=800\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1434979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41920\nallocs=1543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1497729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11784\nallocs=434\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1971125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=55688\nallocs=2024\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1777500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=48696\nallocs=1791\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1410291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1388708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 189562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3616\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3205291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=83272\nallocs=3053\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1479229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20656\nallocs=723\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1373083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26632\nallocs=869\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 616666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 716854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 686417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 710584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 960250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 925458.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1015208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 598354.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 26687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 465979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 993270.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 632166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 568500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 583500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 880458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 844333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 614333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 739479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 599208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1447750.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41936\nallocs=1544\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1496375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11800\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2263917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=57048\nallocs=2078\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 1989875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=50056\nallocs=1845\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1678000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1663625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 2393834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17056\nallocs=701\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3431520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=84632\nallocs=3107\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1794125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22032\nallocs=776\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1403416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 805792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 704146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 815812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 716666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 943959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 938875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 1005416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 862875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 23756.916666666664,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 469584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 1020166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 634458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 572000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 593208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 742792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 898812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 659667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 94458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=800\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 84333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=800\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1418250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41920\nallocs=1543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1500167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11784\nallocs=434\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1939666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=55688\nallocs=2024\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1746333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=48696\nallocs=1791\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1413458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1374750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 189167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3616\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3212770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=83272\nallocs=3053\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1481709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20656\nallocs=723\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1379250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 659583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 706354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 620667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 704958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 963438,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 939020.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1003520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 880541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 26465.25,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 461042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 1011750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 641708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 573459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 602667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 861583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 878333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 473041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 713958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 442208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1437271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41936\nallocs=1544\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1483417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11800\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2255250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=57048\nallocs=2078\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 2046124.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=50360\nallocs=1846\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1680458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1669021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 2356917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17056\nallocs=701\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3450375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=84632\nallocs=3107\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1770125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22032\nallocs=776\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1371417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 750333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 723583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 791625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 713708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 957895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 944583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 994792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 861917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 23930.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 453646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 1017833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 649500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 572417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 613583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 813417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 847083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 658542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 84500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=800\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 85916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=800\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1449250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41920\nallocs=1543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1494791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11784\nallocs=434\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 2003708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=55688\nallocs=2024\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1778291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=48696\nallocs=1791\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1418958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1386270.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 193750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3616\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3214083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=83272\nallocs=3053\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1474146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20656\nallocs=723\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1391229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 680375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 711146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 673729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 714021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 958167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 947375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 999917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 856125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 26732.583333333336,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 461834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 1007750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 633312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 581542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 592916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 870916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 977958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 486875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 720666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 576000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1445354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41936\nallocs=1544\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1477250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11800\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2238875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=57048\nallocs=2078\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 2031625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=50056\nallocs=1845\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1678291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1671396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 2361083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17056\nallocs=701\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3433396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=84632\nallocs=3107\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1770396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22032\nallocs=776\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1363729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 724645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 711916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 798667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 714500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 946542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 937833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 1007167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 893375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 24125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 467083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 1016896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 634250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 573167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 592958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 865103.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 831271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 678792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 94625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=800\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 84125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=800\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1446583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41920\nallocs=1543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1483229.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11784\nallocs=434\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1952167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=55688\nallocs=2024\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1778083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=48696\nallocs=1791\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1415604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1376542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 192125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3616\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3214833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=83272\nallocs=3053\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1477146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20656\nallocs=723\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1384958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 644417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 700500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 673667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 710479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 935500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 944334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1023583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 808959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 25739.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 458958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 1002854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 636250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 573500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 607375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 869584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 867417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 488708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 676271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 548688,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1439583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41936\nallocs=1544\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1476083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11800\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2256417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=57048\nallocs=2078\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 2053916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=50056\nallocs=1845\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1656375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1643709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 2401417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17056\nallocs=701\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3425750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=84632\nallocs=3107\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1773625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22032\nallocs=776\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1368042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 799187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 704583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 842458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 708020.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 946458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 944750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 990416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 850750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 24263.833333333332,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 468875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 1017250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 648500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 574375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 606417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 843500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 866145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 596334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 84000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=800\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 83083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=800\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1450166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41920\nallocs=1543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1487041.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11784\nallocs=434\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1963687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=55688\nallocs=2024\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1783187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=48696\nallocs=1791\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1414208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1386312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 189250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3616\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3167645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=83272\nallocs=3053\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1477541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20656\nallocs=723\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1386291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 685375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 707167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 677292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 707000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 955687,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 940958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1018396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 768750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 26854.166666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 462625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 755020.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 615958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 546708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 580395.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 775979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 613959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 634458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 763959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 586667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1322145.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41936\nallocs=1544\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1413437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11800\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2100833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=57048\nallocs=2078\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 1836853.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=50056\nallocs=1845\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1763166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1640479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 3154645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17056\nallocs=701\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3261458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=84632\nallocs=3107\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1545667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22032\nallocs=776\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1328896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 1068666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 700396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 1047125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 692042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 841000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 843750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 917750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 647874.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 23483.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":5,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 465250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 780542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 645041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 549166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 581208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 791375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 627646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 89250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1120\nallocs=54\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 85000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=720\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 80792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=720\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1351083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41920\nallocs=1543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1404792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11784\nallocs=434\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1809750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=55688\nallocs=2024\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1578708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=48696\nallocs=1791\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1384250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1359834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 149792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3616\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3048854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=83272\nallocs=3053\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1279854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20656\nallocs=723\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1341854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 680542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 698666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 725209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 699125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 847916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 866729,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 941229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 247125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2744\nallocs=91\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 26291.666666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 467021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 753375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 671520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 583625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 605396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 822187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 573083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 496250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 721500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 547709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1449000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41936\nallocs=1544\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1485208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11800\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2232249.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=57048\nallocs=2078\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 2050021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=50056\nallocs=1845\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1710500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1672020.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 2420750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17056\nallocs=701\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3460208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=84632\nallocs=3107\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1811500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22032\nallocs=776\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1375271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 847500.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 715458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 859542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 723104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 951667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 935062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 1007666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 510583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 24708.333333333332,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 463042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 792208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 664166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 586062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 610958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 831208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 592125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 93125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1120\nallocs=54\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 92917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=720\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 84625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=720\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1443292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41920\nallocs=1543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1480896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11784\nallocs=434\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 2014375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=55688\nallocs=2024\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1752250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=49744\nallocs=1822\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1410000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1376812,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 196709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3616\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3222917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=83272\nallocs=3053\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1484375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20656\nallocs=723\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1391000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 697000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 709667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 704312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 767125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 939312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 915250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1002479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 283250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2744\nallocs=91\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 26722.25,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 467500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 751250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 636125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 578875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 589417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 813250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 542500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 515812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 727666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 554625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1444334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41936\nallocs=1544\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1469333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11800\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2243208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=57048\nallocs=2078\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 2115125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=50056\nallocs=1845\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1690562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1674250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 2412750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17056\nallocs=701\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3443541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=84632\nallocs=3107\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1771104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22032\nallocs=776\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1362584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 793250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 713896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 864750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 712500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 912916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 931604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 1000937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 509083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 24899.25,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 470042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 754416,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 650708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 586083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 595750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 809708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 589562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 93459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1120\nallocs=54\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 95291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=720\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 84042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=720\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1440417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41920\nallocs=1543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1482250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11784\nallocs=434\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1940666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=55688\nallocs=2024\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1770833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=48696\nallocs=1791\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1395458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1371084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 195250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3616\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3219395.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=83272\nallocs=3053\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1497458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20656\nallocs=723\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1371541.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 638333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 718750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 708500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 707208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 952146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 929292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1039791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 288396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2744\nallocs=91\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 26340.333333333332,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 465791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 827937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 635250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 562291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 594500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 801791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 591208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 645500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1200\nallocs=58\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 618187.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 798500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=73\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1333083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41936\nallocs=1544\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1424500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11800\nallocs=435\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2100167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=57048\nallocs=2078\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 1847000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=50056\nallocs=1845\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1696166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1651958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=23952\nallocs=851\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 3657771,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17056\nallocs=701\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3264437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=83248\nallocs=3066\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1565166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22032\nallocs=776\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1351333.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 1063291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 695645.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 1078084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18336\nallocs=689\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 705166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 860084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 862229.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 919520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 574854,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2824\nallocs=95\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 26069.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 468333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4752\nallocs=178\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 785583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 626541.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 564084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 598792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 788666,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 629791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 96916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1120\nallocs=54\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 88583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=720\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 83458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=720\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1356667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41920\nallocs=1543\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1421333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11784\nallocs=434\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1792833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=55688\nallocs=2024\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1620166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=48696\nallocs=1791\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1385791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1376291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22576\nallocs=798\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 151458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3616\nallocs=171\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3042333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=83272\nallocs=3053\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1274875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20656\nallocs=723\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1346333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26472\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 694458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 702292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 754229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16992\nallocs=636\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 705395.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8808\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 858875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9920\nallocs=350\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 862292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9520\nallocs=346\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 923916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9720\nallocs=348\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 246583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2744\nallocs=91\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 27302.166666666668,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 464542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4880\nallocs=186\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 828520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=78\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 665000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=912\nallocs=43\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 583958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=912\nallocs=43\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 622708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=912\nallocs=43\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 800646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=78\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 622292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=78\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 719708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1392\nallocs=69\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 532375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2448\nallocs=83\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 761083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2448\nallocs=83\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1385770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45000\nallocs=1661\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1421333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11928\nallocs=443\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2173833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=60288\nallocs=2206\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 1899500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=53216\nallocs=1968\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1674542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24224\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1641375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=24224\nallocs=868\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 3935416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18176\nallocs=771\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3285624.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=89136\nallocs=3291\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1565229.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22352\nallocs=796\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1333667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26760\nallocs=886\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 1067374.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18496\nallocs=707\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 678125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8776\nallocs=319\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 1090458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18496\nallocs=707\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 675959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8776\nallocs=319\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 2919166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13368\nallocs=415\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 1048417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11560\nallocs=405\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 1612625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 620333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3016\nallocs=106\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 25784.75,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1264\nallocs=35\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 456500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4880\nallocs=186\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 797209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=78\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 691500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=912\nallocs=43\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 580375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=912\nallocs=43\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 616291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=912\nallocs=43\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 739770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=78\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 636312,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2432\nallocs=78\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 88708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1216\nallocs=60\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 86000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 79334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=816\nallocs=38\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1397709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=44984\nallocs=1660\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1416959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11912\nallocs=442\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1896416.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=59912\nallocs=2179\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1653228.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=51792\nallocs=1910\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1389478.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22784\nallocs=811\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1371062.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=22784\nallocs=811\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 160750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4096\nallocs=201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3047833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=87712\nallocs=3233\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1278291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=20912\nallocs=739\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1342625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=26760\nallocs=886\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 711500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17088\nallocs=650\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 677791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8776\nallocs=319\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 758667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17088\nallocs=650\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 677250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8776\nallocs=319\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 2921500.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13368\nallocs=415\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 1044792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=11560\nallocs=405\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1603709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 251979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2840\nallocs=97\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 27827.428571428572,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 465541,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3504\nallocs=132\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 831500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 656625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 548229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 596000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 772125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1832\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 616292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 705667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 630625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 825292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1304812.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33488\nallocs=1233\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1382792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2027166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45944\nallocs=1652\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 1816875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=40624\nallocs=1490\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1688271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=675\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1629458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=675\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 3825958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=533\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3194354.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=66504\nallocs=2453\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1736437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16888\nallocs=618\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1346833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21496\nallocs=716\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 1045562,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13056\nallocs=510\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 647334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 1051375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13056\nallocs=510\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 656291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 2701896,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10656\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 1005771,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9024\nallocs=310\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 1561083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9704\nallocs=312\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 599500.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=74\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 25173.583333333336,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 470833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3504\nallocs=132\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 785625.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 661417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 576917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 612500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 809208.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1832\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 625083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 87167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 88083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 84167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1339709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33488\nallocs=1233\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1382229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1775500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=44664\nallocs=1609\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1593041.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38760\nallocs=1416\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1388583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17128\nallocs=633\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1350167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17128\nallocs=633\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 157125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 2964584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=65496\nallocs=2410\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1459458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15864\nallocs=576\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1367083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21496\nallocs=716\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 740209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12064\nallocs=468\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 664125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 748291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12064\nallocs=468\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 662708.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 2702396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10656\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 1011791.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9024\nallocs=310\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1577625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9704\nallocs=312\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 245125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2320\nallocs=74\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 26791.714285714286,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 456167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3504\nallocs=132\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 822916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 623604,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 546542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 587084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 751458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1832\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 567021,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 486625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 810666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 614333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1326250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33488\nallocs=1233\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1382709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2047625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45656\nallocs=1651\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 1824979.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=39768\nallocs=1459\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1694750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=675\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1644604.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=675\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 3778833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=533\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3169979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=66504\nallocs=2453\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1756542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16888\nallocs=618\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1335208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21496\nallocs=716\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 1020375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13056\nallocs=510\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 650833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 1036291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13056\nallocs=510\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 652916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 3071292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10656\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 998625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9184\nallocs=311\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 1578500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9704\nallocs=312\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 586396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=74\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 25750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 462875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3504\nallocs=132\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 806354.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 647333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 549333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 583750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 769417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1832\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 639209,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 87667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 84917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 82208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1353834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33488\nallocs=1233\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1379437,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1792708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45504\nallocs=1639\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1589958.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38760\nallocs=1416\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1398958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17128\nallocs=633\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1356875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17128\nallocs=633\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 155500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 2962771,
            "unit": "ns",
            "extra": "gctime=0\nmemory=65496\nallocs=2410\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1464208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15864\nallocs=576\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1356667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21496\nallocs=716\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 722708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12064\nallocs=468\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 653541.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 740083.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12064\nallocs=468\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 655334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 2936646,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10656\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 1005417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9184\nallocs=311\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1572312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9704\nallocs=312\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 243917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2320\nallocs=74\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 28101.285714285714,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 459125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3504\nallocs=132\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 793875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 658979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 559916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 585959,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 781459,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1832\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 594542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 633792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 792521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 674167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1332000,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33488\nallocs=1233\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1375083,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2087917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45688\nallocs=1653\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 1820166.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=40624\nallocs=1490\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1693770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=675\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1657375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=675\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 3841520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=533\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3160687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=66504\nallocs=2453\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1755333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16888\nallocs=618\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1343458.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21496\nallocs=716\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 1029271,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13056\nallocs=510\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 655542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 1052084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13056\nallocs=510\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 653937.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 3078396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10656\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 989042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9024\nallocs=310\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 1572500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9704\nallocs=312\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 617250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=74\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 26208.333333333332,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 454562.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3504\nallocs=132\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 820333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 678895.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 559834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 595854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 757584,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1832\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 624229,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 87167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 86834,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 84208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1347875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33488\nallocs=1233\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1385042,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 1772479.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45240\nallocs=1630\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1569917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38760\nallocs=1416\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1406542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17128\nallocs=633\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1364375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17128\nallocs=633\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 150542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 2973291.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=65496\nallocs=2410\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1460375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15864\nallocs=576\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1359417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21496\nallocs=716\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 724500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12064\nallocs=468\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 659500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 747542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12064\nallocs=468\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 656792,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 3090875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10656\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 1004542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9024\nallocs=310\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1574188,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9704\nallocs=312\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 233916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2320\nallocs=74\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
            "name": "private array/construct",
            "value": 25494,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/broadcast",
            "value": 464917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3504\nallocs=132\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn/Float32",
            "value": 913875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/randn!/Float32",
            "value": 595833.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Int64",
            "value": 551583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand!/Float32",
            "value": 558666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Int64",
            "value": 899583,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1832\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/random/rand/Float32",
            "value": 817333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_gpu",
            "value": 561250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=832\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/cpu_to_gpu",
            "value": 702791.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copyto!/gpu_to_cpu",
            "value": 621542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/1d",
            "value": 1408542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33488\nallocs=1233\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/accumulate/2d",
            "value": 1502750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/int",
            "value": 2276334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=45656\nallocs=1651\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findall/bool",
            "value": 1993104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=39864\nallocs=1465\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/int",
            "value": 1808458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=675\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findfirst/bool",
            "value": 1712312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18152\nallocs=675\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/scalar",
            "value": 2520292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12272\nallocs=533\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/logical",
            "value": 3486084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=66504\nallocs=2453\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/1d",
            "value": 1882417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=16888\nallocs=618\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/iteration/findmin/2d",
            "value": 1417750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21496\nallocs=716\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/1d",
            "value": 964500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13056\nallocs=510\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/reduce/2d",
            "value": 697917,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/1d",
            "value": 997020.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=13056\nallocs=510\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/reductions/mapreduce/2d",
            "value": 693750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/4d",
            "value": 3093667,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10656\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/2d",
            "value": 1068458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9024\nallocs=310\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/permutedims/3d",
            "value": 1842166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9704\nallocs=312\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "private array/copy",
            "value": 836458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2288\nallocs=74\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
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
          },
          {
            "name": "shared array/construct",
            "value": 25805.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/broadcast",
            "value": 461791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3504\nallocs=132\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn/Float32",
            "value": 919417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/randn!/Float32",
            "value": 600250,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Int64",
            "value": 548958,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand!/Float32",
            "value": 561916,
            "unit": "ns",
            "extra": "gctime=0\nmemory=432\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Int64",
            "value": 876166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1832\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/random/rand/Float32",
            "value": 824312.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1816\nallocs=51\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_gpu",
            "value": 80334,
            "unit": "ns",
            "extra": "gctime=0\nmemory=864\nallocs=40\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/cpu_to_gpu",
            "value": 81084,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copyto!/gpu_to_cpu",
            "value": 79125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=528\nallocs=23\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/1d",
            "value": 1417750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=33488\nallocs=1233\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/accumulate/2d",
            "value": 1499520.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=8704\nallocs=325\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/int",
            "value": 2022521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=44648\nallocs=1608\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findall/bool",
            "value": 1713854.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38760\nallocs=1416\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/int",
            "value": 1489417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17128\nallocs=633\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findfirst/bool",
            "value": 1415500,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17128\nallocs=633\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/scalar",
            "value": 159208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2352\nallocs=113\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/logical",
            "value": 3167979,
            "unit": "ns",
            "extra": "gctime=0\nmemory=65496\nallocs=2410\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/1d",
            "value": 1558916.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=15864\nallocs=576\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/iteration/findmin/2d",
            "value": 1427437.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=21656\nallocs=717\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/1d",
            "value": 697458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12064\nallocs=468\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/reduce/2d",
            "value": 697125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/1d",
            "value": 707292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12064\nallocs=468\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/reductions/mapreduce/2d",
            "value": 702291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=6352\nallocs=231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/4d",
            "value": 3157708,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10656\nallocs=313\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/2d",
            "value": 1067771,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9024\nallocs=310\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/permutedims/3d",
            "value": 1874583.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=9704\nallocs=312\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "shared array/copy",
            "value": 206458,
            "unit": "ns",
            "extra": "gctime=0\nmemory=2320\nallocs=74\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      }
    ]
  }
}