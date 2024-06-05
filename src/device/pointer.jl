module AS
    const Generic               = 0 # No Generic address space?
    const Device                = 1 # Checked
    const Constant              = 2 # Checked
    const ThreadGroup           = 3 # Checked
    const Thread                = 4 # Ends up same as Device?
    const ThreadGroup_ImgBlock  = 5 # Like ThreadGroup but only accessible from
    const Ray                   = 6
end
