window.BENCHMARK_DATA = {
  "lastUpdate": 1727354318705,
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
      }
    ]
  }
}