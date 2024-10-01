module NTTS
using Test: Test, DefaultTestSet

export NoThrowTestSet

mutable struct NoThrowTestSet <: Test.AbstractTestSet
    testset::DefaultTestSet
end
function NoThrowTestSet(desc::AbstractString; verbose::Bool = false, showtiming::Bool = true, failfast::Union{Nothing,Bool} = nothing, source = nothing)
    if isnothing(failfast)
        # pass failfast state into child testsets
        parent_ts = Test.get_testset()
        if parent_ts isa DefaultTestSet || parent_ts isa NoThrowTestSet
            failfast = parent_ts.failfast
        else
            failfast = false
        end
    end
    return NoThrowTestSet(DefaultTestSet(String(desc)::String, [], 0, false, verbose, showtiming, time(), nothing, failfast, Test.extract_file(source)))
end

Base.getproperty(obj::NoThrowTestSet, sym::Symbol) = sym == :testset ? getfield(obj, :testset) : Base.getproperty(getfield(obj, :testset), sym)
Base.setproperty!(obj::NoThrowTestSet, sym::Symbol, x) = sym == :testset ? setfield!(obj, :testset, x) : Base.setproperty!(getfield(obj, :testset), sym, x)

function Test.finish(ts::NoThrowTestSet; print_results::Bool=Test.TESTSET_PRINT_ENABLE[])
    ts.time_end = time()
    # If we are a nested test set, do not print a full summary
    # now - let the parent test set do the printing
    if Test.get_testset_depth() != 0
        # Attach this test set to the parent test set
        parent_ts = Test.get_testset()
        Test.record(parent_ts, ts)
    end

    return ts
end
if VERSION < v"1.11.0-DEV.1529"
    function Test.get_test_counts(ts::Union{DefaultTestSet,NoThrowTestSet})
        passes, fails, errors, broken = ts.n_passed, 0, 0, 0
        c_passes, c_fails, c_errors, c_broken = 0, 0, 0, 0
        for t in ts.results
            isa(t, Test.Fail)   && (fails  += 1)
            isa(t, Test.Error)  && (errors += 1)
            isa(t, Test.Broken) && (broken += 1)
            if isa(t, Test.AbstractTestSet)
                np, nf, ne, nb, ncp, ncf, nce , ncb, duration = Test.get_test_counts(t)
                c_passes += np + ncp
                c_fails  += nf + ncf
                c_errors += ne + nce
                c_broken += nb + ncb
            end
        end
        ts.anynonpass = (fails + errors + c_fails + c_errors > 0)
        (; time_start, time_end) = ts
        duration = if isnothing(time_end)
            ""
        else
            dur_s = time_end - time_start
            if dur_s < 60
                string(round(dur_s, digits = 1), "s")
            else
                m, s = divrem(dur_s, 60)
                s = lpad(string(round(s, digits = 1)), 4, "0")
                string(round(Int, m), "m", s, "s")
            end
        end
        return passes, fails, errors, broken, c_passes, c_fails, c_errors, c_broken, duration
    end
else
    Test.get_test_counts(ts::NoThrowTestSet) = Test.get_test_counts(ts.testset)
end


Test.record(ts::NoThrowTestSet, t) = Test.record(ts.testset, t)

function print_counts(ts::NoThrowTestSet, depth, align,
                      pass_width, fail_width, error_width, broken_width, total_width, duration_width, showtiming)
    # Count results by each type at this level, and recursively
    # through any child test sets
    passes, fails, errors, broken, c_passes, c_fails, c_errors, c_broken, duration = Test.get_test_counts(ts)
    subtotal = passes + fails + errors + broken + c_passes + c_fails + c_errors + c_broken
    # Print test set header, with an alignment that ensures all
    # the test results appear above each other
    print(rpad(string("  "^depth, ts.description), align, " "), " | ")

    np = passes + c_passes
    if np > 0
        printstyled(lpad(string(np), pass_width, " "), "  ", color=:green)
    elseif pass_width > 0
        # No passes at this level, but some at another level
        print(lpad(" ", pass_width), "  ")
    end

    nf = fails + c_fails
    if nf > 0
        printstyled(lpad(string(nf), fail_width, " "), "  ", color=Base.error_color())
    elseif fail_width > 0
        # No fails at this level, but some at another level
        print(lpad(" ", fail_width), "  ")
    end

    ne = errors + c_errors
    if ne > 0
        printstyled(lpad(string(ne), error_width, " "), "  ", color=Base.error_color())
    elseif error_width > 0
        # No errors at this level, but some at another level
        print(lpad(" ", error_width), "  ")
    end

    nb = broken + c_broken
    if nb > 0
        printstyled(lpad(string(nb), broken_width, " "), "  ", color=Base.warn_color())
    elseif broken_width > 0
        # None broken at this level, but some at another level
        print(lpad(" ", broken_width), "  ")
    end

    if np == 0 && nf == 0 && ne == 0 && nb == 0
        printstyled(lpad("None", total_width, " "), "  ", color=Base.info_color())
    else
        printstyled(lpad(string(subtotal), total_width, " "), "  ", color=Base.info_color())
    end

    if showtiming
        printstyled(lpad(string(duration), duration_width, " "))
    end
    println()

    # Only print results at lower levels if we had failures or if the user
    # wants.
    if (np + nb != subtotal) || (ts.verbose)
        for t in ts.results
            if isa(t, DefaultTestSet) || isa(t, NoThrowTestSet)
                Test.print_counts(t, depth + 1, align,
                    pass_width, fail_width, error_width, broken_width, total_width, duration_width, ts.showtiming)
            end
        end
    end
end
end
