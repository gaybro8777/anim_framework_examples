#!/usr/bin/python3
#+
# Example use of anim_framework: flying through a starfield.
#
# Copyright 2015 by Lawrence D'Oliveiro <ldo@geek-central.gen.nz>. This
# script is licensed CC0
# <https://creativecommons.org/publicdomain/zero/1.0/>; do with it
# what you will.
#-

import sys
import os
import time
import qahirah as qah
from qahirah import \
    CAIRO, \
    Colour, \
    Vector, \
    distribute
from anim import \
    common

drawing_dims = Vector(16, 9) * 80
anim_duration = 5.0
frame_rate = 25
nr_cycles = 1

near_dist = 0.01
far_dist = 5
stars = []
nr_steps = 20 # small number for testing
# TODO: random distribution
for x in distribute(nrdivs = nr_steps, p1 = 0.0, p2 = 1.0, endincl = False) :
    if x != 0.0 :
        for y in distribute(nrdivs = nr_steps, p1 = 0.0, p2 = 1.0, endincl = False) :
            if y != 0.0 :
                for z in distribute(nrdivs = nr_steps, p1 = 0.0, p2 = 1.0, endincl = False) :
                    if z != 0.0 :
                        stars.append({"pos" : (x, y, z), "colour" : Colour.grey(1)})
                          # TODO: random colours
                    #end if
                #end for
            #end if
        #end for
    #end if
#end for

def anim_init(g) :
    g.operator = CAIRO.OPERATOR_SOURCE
    g.translate(drawing_dims / 2)
    g.rotate(45 * qah.deg)
    g.line_width = 2
    g.line_cap = CAIRO.LINE_CAP_ROUND
#end anim_init

def draw_stars(g, t) :
    g.source_colour = Colour.grey(0)
    g.paint()
    for star in stars :
        pos = star["pos"]
        dist = 1 + near_dist - (pos[2] + t / anim_duration * nr_cycles) % 1.0
        g.source_colour = star["colour"].replace_hsva(v = 1 - dist)
        g.move_to(Vector((pos[0] - 0.5) / dist / far_dist, (pos[1] - 0.5) / dist / far_dist) * max(tuple(drawing_dims)))
        g.rel_line_to((0, 0))
        g.stroke()
    #end for
#end draw_stars

start = time.time()
frame_range = common.render_anim \
  (
    dimensions = drawing_dims,
    start_time = 0,
    end_time = anim_duration,
    frame_rate = frame_rate,
    draw_frame = draw_stars,
    overall_presetup = anim_init,
    out_dir = os.path.join(os.path.dirname(sys.argv[0]), "frames"),
    start_frame_nr = 1
  )
sys.stdout.write("{} frames in {:.3f}s\n".format(frame_range[1], time.time() - start))
