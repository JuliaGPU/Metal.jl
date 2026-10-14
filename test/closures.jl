# closures box the variables they capture when those are reassigned, which makes the code
# around them type unstable.
if isdefined(Test, :detect_closure_boxes)
    @test isempty(Test.detect_closure_boxes(Metal))
end
