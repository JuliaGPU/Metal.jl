
function julia_exec(args::Cmd, env...)
    cmd = Base.julia_cmd()
    if Base.JLOptions().project != C_NULL
        cmd = `$cmd --project=$(unsafe_string(Base.JLOptions().project))`
    end
    cmd = `$cmd --color=no $args`

    out = Pipe()
    err = Pipe()
    proc = run(pipeline(addenv(cmd, env...), stdout=out, stderr=err), wait=false)
    close(out.in)
    close(err.in)
    wait(proc)
    proc, read(out, String), read(err, String)
end