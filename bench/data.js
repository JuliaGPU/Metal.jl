window.BENCHMARK_DATA = {
  "lastUpdate": 1754424592449,
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
      }
    ]
  }
}