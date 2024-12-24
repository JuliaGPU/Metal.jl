using Distributed
using Dates
using Printf: @sprintf
import REPL
using Test

# parse some command-line arguments
function extract_flag!(args, flag, default=nothing)
    for f in args
        if startswith(f, flag)
            # Check if it's just `--flag` or if it's `--flag=foo`
            if f != flag
                val = split(f, '=')[2]
                if default !== nothing && !(typeof(default) <: AbstractString)
                  val = parse(typeof(default), val)
                end
            else
                val = default
            end

            # Drop this value from our args
            filter!(x -> x != f, args)
            return (true, val)
        end
    end
    return (false, default)
end
do_help, _ = extract_flag!(ARGS, "--help")
if do_help
    println("""
        Usage: runtests.jl [--help] [--list] [--jobs=N] [TESTS...]

               --help             Show this text.
               --list             List all available tests.
               --quickfail        Fail the entire run as soon as a single test errored.
               --jobs=N           Launch `N` processes to perform tests (default: Sys.CPU_THREADS).

               Remaining arguments filter the tests that will be executed.""")
    exit(0)
end
_, jobs = extract_flag!(ARGS, "--jobs", Sys.CPU_THREADS)
do_quickfail, _ = extract_flag!(ARGS, "--quickfail")

include("setup.jl")     # make sure everything is precompiled
@info "System information:\n" * sprint(io->Metal.versioninfo(io))
@info "Running $jobs tests in parallel. If this is too many, specify the `--jobs` argument to the tests, or set the JULIA_CPU_THREADS environment variable."

# choose tests
const tests = []
const test_runners = Dict()
## files in the test folder
for (rootpath, dirs, files) in walkdir(@__DIR__)
  # find Julia files
  filter!(files) do file
    endswith(file, ".jl") && file !== "setup.jl" && file !== "runtests.jl"
  end
  isempty(files) && continue

  # strip extension
  files = map(files) do file
    file[1:end-3]
  end

  # prepend subdir
  subdir = relpath(rootpath, @__DIR__)
  if subdir != "."
    files = map(files) do file
      joinpath(subdir, file)
    end
  end

  append!(tests, files)
  for file in files
    test_runners[file] = ()->include("$(@__DIR__)/$file.jl")
  end
end
## GPUArrays testsuite
for name in keys(TestSuite.tests)
    if Metal.DefaultStorageMode != Metal.PrivateStorage && name == "indexing scalar"
        # GPUArrays' scalar indexing tests assume that indexing is not supported
        continue
    end
    push!(tests, "gpuarrays$(Base.Filesystem.path_separator)$name")
    test_runners["gpuarrays$(Base.Filesystem.path_separator)$name"] = ()->TestSuite.tests[name](MtlArray)
end
unique!(tests)

# parse some more command-line arguments
## --list to list all available tests
do_list, _ = extract_flag!(ARGS, "--list")
if do_list
    println("Available tests:")
    for test in sort(tests)
        println(" - $test")
    end
    exit(0)
end
## no options should remain
optlike_args = filter(startswith("-"), ARGS)
if !isempty(optlike_args)
    error("Unknown test options `$(join(optlike_args, " "))` (try `--help` for usage instructions)")
end
## the remaining args filter tests
if !isempty(ARGS)
  filter!(tests) do test
    any(arg->startswith(test, arg), ARGS)
  end
end

# add workers
const test_exeflags = Base.julia_cmd()
filter!(test_exeflags.exec) do c
    return !(startswith(c, "--depwarn") || startswith(c, "--check-bounds"))
end
push!(test_exeflags.exec, "--check-bounds=yes")
push!(test_exeflags.exec, "--startup-file=no")
push!(test_exeflags.exec, "--depwarn=yes")
push!(test_exeflags.exec, "--project=$(Base.active_project())")
const test_exename = popfirst!(test_exeflags.exec)
function addworker(X; env=[], kwargs...)
    withenv("JULIA_NUM_THREADS" => 1, "OPENBLAS_NUM_THREADS" => 1, env...) do
        procs = addprocs(X; exename=test_exename, exeflags=test_exeflags, kwargs...)
        @everywhere procs include($(joinpath(@__DIR__, "setup.jl")))
        procs
    end
end
addworker(min(jobs, length(tests)))

# pretty print information about gc and mem usage
testgroupheader = "Test"
workerheader = "(Worker)"
name_align        = maximum([textwidth(testgroupheader) + textwidth(" ") +
                             textwidth(workerheader); map(x -> textwidth(x) +
                             3 + ndigits(nworkers()), tests)])
elapsed_align     = textwidth("Time (s)")
gc_align      = textwidth("GC (s)")
percent_align = textwidth("GC %")
alloc_align   = textwidth("Alloc (MB)")
rss_align     = textwidth("RSS (MB)")
printstyled(" "^(name_align + textwidth(testgroupheader) - 3), " | ")
printstyled("         | ---------------- CPU ---------------- |\n", color=:white)
printstyled(testgroupheader, color=:white)
printstyled(lpad(workerheader, name_align - textwidth(testgroupheader) + 1), " | ", color=:white)
printstyled("Time (s) | GC (s) | GC % | Alloc (MB) | RSS (MB) |\n", color=:white)
print_lock = stdout isa Base.LibuvStream ? stdout.lock : ReentrantLock()
if stderr isa Base.LibuvStream
    stderr.lock = print_lock
end
function print_testworker_stats(test, wrkr, resp)
    @nospecialize resp
    lock(print_lock)
    try
        printstyled(test, color=:white)
        printstyled(lpad("($wrkr)", name_align - textwidth(test) + 1, " "), " | ", color=:white)
        time_str = @sprintf("%7.2f",resp[2])
        printstyled(lpad(time_str, elapsed_align, " "), " | ", color=:white)

        cpu_gc_str = @sprintf("%5.2f", resp[4])
        printstyled(lpad(cpu_gc_str, gc_align, " "), " | ", color=:white)
        # since there may be quite a few digits in the percentage,
        # the left-padding here is less to make sure everything fits
        cpu_percent_str = @sprintf("%4.1f", 100 * resp[4] / resp[2])
        printstyled(lpad(cpu_percent_str, percent_align, " "), " | ", color=:white)
        cpu_alloc_str = @sprintf("%5.2f", resp[3] / 2^20)
        printstyled(lpad(cpu_alloc_str, alloc_align, " "), " | ", color=:white)

        cpu_rss_str = @sprintf("%5.2f", resp[6] / 2^20)
        printstyled(lpad(cpu_rss_str, rss_align, " "), " |\n", color=:white)
    finally
        unlock(print_lock)
    end
end
global print_testworker_started = (name, wrkr)->begin
end
function print_testworker_errored(name, wrkr)
    lock(print_lock)
    try
        printstyled(name, color=:red)
        printstyled(lpad("($wrkr)", name_align - textwidth(name) + 1, " "), " |",
            " "^elapsed_align, " failed at $(now())\n", color=:red)
    finally
        unlock(print_lock)
    end
end

# run tasks
t0 = now()
results = []
all_tasks = Task[]
all_tests = copy(tests)
try
    # Monitor stdin and kill this task on ^C
    # but don't do this on Windows, because it may deadlock in the kernel
    t = current_task()
    running_tests = Dict{String, DateTime}()
    if !Sys.iswindows() && isa(stdin, Base.TTY)
        stdin_monitor = @async begin
            term = REPL.Terminals.TTYTerminal("xterm", stdin, stdout, stderr)
            try
                REPL.Terminals.raw!(term, true)
                while true
                    c = read(term, Char)
                    if c == '\x3'
                        Base.throwto(t, InterruptException())
                        break
                    elseif c == '?'
                        println("Currently running: ")
                        tests = sort(collect(running_tests), by=x->x[2])
                        foreach(tests) do (test, date)
                            println(test, " (running for ", round(now()-date, Minute), ")")
                        end
                    end
                end
            catch e
                isa(e, InterruptException) || rethrow()
            finally
                REPL.Terminals.raw!(term, false)
            end
        end
    end
    @sync begin
        function recycle_worker(p)
            rmprocs(p, waitfor=30)
            return nothing
        end

        for p in workers()
            @async begin
                push!(all_tasks, current_task())
                while length(tests) > 0
                    test = popfirst!(tests)

                    # the `capturing` test is special, and needs an environment variable set
                    if test == "capturing"
                        recycle_worker(p)
                        p = addworker(1; env=["METAL_CAPTURE_ENABLED"=>1])[1]
                    end

                    # sometimes a worker failed, and we need to spawn a new one
                    if p === nothing
                        p = addworker(1)[1]
                    end
                    wrkr = p

                    # catch timeouts
                    pid = remotecall_fetch(getpid, wrkr)
                    timer = Timer(480) do _
                        @warn "Test timed out: $test"

                        # trigger a stacktrace and profile dump
                        ccall(:kill, Cint, (Cint, Cint), pid, #=SIGINFO=# 29)
                        sleep(5)

                        # exit the worker (which may fail, so fall back to killing it)
                        t1 = rmprocs(wrkr, waitfor=0)
                        t2 = Timer(10) do _
                            @warn "Couldn't kill worker $wrkr, killing process $pid forcefully"
                            ccall(:kill, Cint, (Cint, Cint), pid, Base.SIGTERM)
                            t3 = Timer(5) do _
                                ccall(:kill, Cint, (Cint, Cint), pid, Base.SIGKILL)
                            end
                            wait(t1)
                            close(t3)
                        end
                        wait(t1)
                        close(t2)
                    end

                    # run the test
                    local resp
                    running_tests[test] = now()
                    try
                        resp = remotecall_fetch(runtests, wrkr, test_runners[test], test)
                    catch e
                        isa(e, InterruptException) && return
                        resp = Any[e]
                    end
                    close(timer)
                    delete!(running_tests, test)
                    push!(results, (test, resp))

                    # act on the results
                    if resp[1] isa Exception
                        print_testworker_errored(test, wrkr)
                        do_quickfail && Base.throwto(t, InterruptException())

                        # the worker encountered some failure, recycle it
                        # so future tests get a fresh environment
                        p = recycle_worker(p)
                    else
                        print_testworker_stats(test, wrkr, resp)

                        cpu_rss = resp[6]
                        if haskey(ENV, "CI") && cpu_rss > 3*2^30
                            # XXX: collecting garbage
                            #      after each test, we are leaking CPU memory somewhere.
                            #      this is a problem on CI, where we don't have much RAM.
                            #      work around this by periodically recycling the worker.
                            p = recycle_worker(p)
                        end
                    end

                    # make sure the `capturing` test environment variable doesn't leak
                    if test == "capturing"
                        recycle_worker(p)
                        p = addworker(1; env=["METAL_CAPTURE_ENABLED"=>0])[1]
                    end
                end

                if p !== nothing
                    recycle_worker(p)
                end
            end
        end
    end
catch e
    isa(e, InterruptException) || rethrow()
    # If the test suite was merely interrupted, still print the
    # summary, which can be useful to diagnose what's going on
    foreach(task -> begin
            istaskstarted(task) || return
            istaskdone(task) && return
            try
                schedule(task, InterruptException(); error=true)
            catch ex
                @error "InterruptException" exception=ex,catch_backtrace()
            end
        end, all_tasks)
    for t in all_tasks
        # NOTE: we can't just wait, but need to discard the exception,
        #       because the throwto for --quickfail also kills the worker.
        try
            wait(t)
        catch e
            showerror(stderr, e)
        end
    end
finally
    if @isdefined stdin_monitor
        schedule(stdin_monitor, InterruptException(); error=true)
    end
end
t1 = now()
elapsed = canonicalize(Dates.CompoundPeriod(t1-t0))
println("Testing finished in $elapsed")

# construct a testset to render the test results
o_ts = Test.DefaultTestSet("Overall")
Test.push_testset(o_ts)
completed_tests = Set{String}()
for (testname, (resp,)) in results
    push!(completed_tests, testname)
    if isa(resp, Test.DefaultTestSet)
        Test.push_testset(resp)
        Test.record(o_ts, resp)
        Test.pop_testset()
    elseif isa(resp, Tuple{Int,Int})
        fake = Test.DefaultTestSet(testname)
        for i in 1:resp[1]
            Test.record(fake, Test.Pass(:test, nothing, nothing, nothing, nothing))
        end
        for i in 1:resp[2]
            Test.record(fake, Test.Broken(:test, nothing))
        end
        Test.push_testset(fake)
        Test.record(o_ts, fake)
        Test.pop_testset()
    elseif isa(resp, RemoteException) && isa(resp.captured.ex, Test.TestSetException)
        println("Worker $(resp.pid) failed running test $(testname):")
        Base.showerror(stdout, resp.captured)
        println()
        fake = Test.DefaultTestSet(testname)
        for i in 1:resp.captured.ex.pass
            Test.record(fake, Test.Pass(:test, nothing, nothing, nothing, nothing))
        end
        for i in 1:resp.captured.ex.broken
            Test.record(fake, Test.Broken(:test, nothing))
        end
        for t in resp.captured.ex.errors_and_fails
            Test.record(fake, t)
        end
        Test.push_testset(fake)
        Test.record(o_ts, fake)
        Test.pop_testset()
    else
        if !isa(resp, Exception)
            resp = ErrorException(string("Unknown result type : ", typeof(resp)))
        end
        # If this test raised an exception that is not a remote testset exception,
        # i.e. not a RemoteException capturing a TestSetException that means
        # the test runner itself had some problem, so we may have hit a segfault,
        # deserialization errors or something similar.  Record this testset as Errored.
        fake = Test.DefaultTestSet(testname)
        Test.record(fake, Test.Error(:nontest_error, testname, nothing, Any[(resp, [])], LineNumberNode(1)))
        Test.push_testset(fake)
        Test.record(o_ts, fake)
        Test.pop_testset()
    end
end
for test in all_tests
    (test in completed_tests) && continue
    fake = Test.DefaultTestSet(test)
    Test.record(fake, Test.Error(:test_interrupted, test, nothing,
                                    [("skipped", [])], LineNumberNode(1)))
    Test.push_testset(fake)
    Test.record(o_ts, fake)
    Test.pop_testset()
end
println()
Test.print_test_results(o_ts, 1)
if !o_ts.anynonpass
    println("    \033[32;1mSUCCESS\033[0m")
else
    println("    \033[31;1mFAILURE\033[0m\n")
    Test.print_test_errors(o_ts)
    throw(Test.FallbackTestSetException("Test run finished with errors"))
end
