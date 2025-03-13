# EXCLUDE FROM TESTING
"""
This example demonstrates how to integrate Metal and Gtk4.
An image is generated using a Metal kernel and efficiently displayed using Gtk4
"""

using Pkg, Metal
metal_dir = dirname(@__DIR__)

Pkg.activate(; temp=true)
Pkg.add(["Gtk4", "Colors", "FixedPointNumbers"])
Pkg.develop(path=metal_dir)

using Colors, FixedPointNumbers, Gtk4, Metal

if !isinteractive()
    Gtk4.GLib.start_main_loop()
end

function generate(img, pos)
    r, c = Int32.(size(img))
    i,j = thread_position_in_grid_2d()
    @inbounds if i <= r && j <= c
        img[i,j] = pos < j < pos + 10 ? colorant"red" : colorant"thistle"
    end
    return
end

img = Metal.@sync MtlMatrix{RGB{N0f8}, Metal.SharedStorage}(undef, 800, 600)
host = unsafe_wrap(Array{RGB{N0f8}}, img, size(img))

## initial image
threads = 16,16
groups = cld.(size(img), threads)
Metal.@sync @metal threads=16,16 groups=groups generate(img, 0)

win = GtkWindow("Test", 800, 600);

data = reinterpret(Gtk4.GdkPixbufLib.RGB, host)
pixbuf = Gtk4.GdkPixbufLib.GdkPixbuf(data,false)
view = GtkImage(pixbuf)

push!(win,view)

for i=1:400
    Metal.@sync @metal threads=16,16 groups=groups generate(img, i*2)
    #forces redraw without copy
    Gtk4.G_.set_from_pixbuf(view, pixbuf)
    sleep(0.01)
    win.visible || break
end

if !isinteractive()
    !win.visible || Gtk4.GLib.waitforsignal(win,:close_request)
end
