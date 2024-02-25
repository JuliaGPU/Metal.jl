# test that we can parse and regenerate Metal libraries accurately

using Metal: MetalLibFunction, MetalLib

using Printf: @printf

# display the contents of a file in hexadecimal
hexdump(obj) = hexdump(stdout, obj)
hexdump(io, obj) = GC.@preserve obj hexdump(io, pointer(obj), sizeof(obj))
hexdump(io, mem::Ptr, len::Integer) = hexdump(io, mem, len)
function hexdump(io::IO, mem::Ptr, len::Integer; per_line::Integer=16, split_per::Integer=2)
    mem = convert(Ptr{UInt8}, mem)
    off = 1
    while off <= len
        @printf io "%08x: " off-1

        # bytes
        str = ""
        for i in 1:per_line
            if off <= len
                val = unsafe_load(mem, off)
                @printf io "%02x" val

                str *= if 0x20 <= val <= 0x7e
                    # more strict than isascii to prevent control characters, etc
                    Char(val)
                else
                    '.'
                end
            else
                @printf io "  "
            end

            if i%split_per == 0
                print(io, " ")
            end
            off += 1
        end

        print(io, " ", str)

        if off <= len
            println(io)
        end
    end
end

# diff two objects, highlighting using `colordiff`
hexdiff(obj1, obj2) = hexdiff(stdout, obj1, obj2)
function hexdiff(io, obj1, obj2)
    dump1 = sprint(io -> hexdump(io, obj1))
    dump2 = sprint(io -> hexdump(io, obj2))
    colordiff(io ,IOBuffer(dump1), IOBuffer(dump2))
end

# diff two streams, highlighting different lines and additionally different characters.
colordiff(in1, in2) = colordiff(stdout, in1, in2)
function colordiff(io, in1, in2; context=2)
    lines1 = collect(eachline(in1))
    lines2 = collect(eachline(in2))
    lines = max(length(lines1), length(lines2))

    # find relevant line numbers
    line_status = fill(0, lines)
    ## print those that differ
    for i in 1:lines
        if get(lines1, i, "") != get(lines2, i, "")
            line_status[i] = 1
        end
    end
    ## if any differ, also include the start and end
    if any(line_status .== 1)
        line_status[1] = 1
        line_status[end] = 1
    end
    ## include context
    for i in 1:lines
        if line_status[i] == 1
            for j in max(1, i-context):min(lines, i+context)
                if line_status[j] == 0
                    line_status[j] = 2
                end
            end
        end
    end

    if !any(line_status .== 1)
        return
    end

    # print relevant lines
    was_printing = true
    linelen = max(maximum(length, lines1), maximum(length, lines2))
    for i in 1:lines
        if line_status[i] == 0
            if was_printing
                println(io, "...")
                was_printing = false
            end
            continue
        end
        was_printing = true

        line1 = get(lines1, i, "")
        if length(line1) < linelen
            line1 *= " "^(linelen - length(line1))
        end
        line2 = get(lines2, i, "")
        if length(line2) < linelen
            line2 *= " "^(linelen - length(line2))
        end
        line = "$(line1)     $(line2)"

        if line1 != line2
            for j in 1:linelen
                color = line1[j] != line2[j] ? :red : :cyan
                printstyled(io, line1[j]; color)
            end
            print(io, "  |  ")
            for j in 1:linelen
                color = line1[j] != line2[j] ? :red : :cyan
                printstyled(io, line2[j]; color)
            end
        else
            print(io, line)
        end

        if i != lines
            println(io)
        end
    end
end

function compare(ref_path)
    # parse the reference version
    ref_bytes = read(ref_path)
    ref_library = open(ref_path) do io
        read(io, MetalLib)
    end

    # generate new data, and parse it again
    new_bytes = let IO=IOBuffer()
        write(IO, ref_library)
        take!(IO)
    end

    # compare
    if ref_bytes == new_bytes
        return true
    else
        println("Encountered differences while comparing $(basename(ref_path))")

        display(ref_library)
        println()

        hexdiff(ref_bytes, new_bytes)

        return false
    end
end


@testset "metallib" begin

metallib_dir = joinpath(@__DIR__, "metallib")
metallibs = String[]
for file in readdir(metallib_dir)
    if endswith(file, ".metallib")
        push!(metallibs, file)
    end
end

@testset for metallib in metallibs
    @test compare(joinpath(metallib_dir, metallib))
end

end
