#!/usr/bin/env python3
"""Draws the tool illustrations for the Fluids & Thermal, Standard Sections
and Vibration tools, in the style of the hand-made icons already in
`images/icons/`.

Those were drawn by hand; these are generated so the seven of them stay
consistent with each other and can be nudged without redrawing. The house style
they follow, sampled from the existing assets:

    white ground, black outlines, #E8D8C8 for a solid body, #D8D8D8 for a
    secondary one, #E02020 for whatever the diagram is actually about (a load,
    a heat flow, a pressure difference), bold Arial labels, dashed lines for
    reference geometry.

Everything is drawn at 4x and downsampled, which is what gives the curves and
diagonals their antialiasing — PIL has no antialiased primitives of its own.

    python3 tool/make_tool_icons.py
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

REPO = Path(__file__).resolve().parent.parent
OUT = REPO / "images" / "icons"

SIZE = 300
S = 4  # supersample factor
W, H = SIZE * S, SIZE * S

WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
TAN = (232, 216, 200)
GREY = (216, 216, 216)
DARK_GREY = (127, 127, 127)
RED = (224, 32, 32)

LW = 5  # default stroke, in logical px

FONT_PATH = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def px(v: float) -> float:
    return v * S


class Canvas:
    def __init__(self) -> None:
        self.img = Image.new("RGB", (W, H), WHITE)
        self.d = ImageDraw.Draw(self.img)

    # -- primitives ------------------------------------------------------
    def line(self, p0, p1, color=BLACK, w=LW):
        self.d.line([px(p0[0]), px(p0[1]), px(p1[0]), px(p1[1])],
                    fill=color, width=int(px(w)))

    def polyline(self, pts, color=BLACK, w=LW):
        flat = [px(c) for p in pts for c in p]
        self.d.line(flat, fill=color, width=int(px(w)), joint="curve")

    def rect(self, box, fill=None, outline=BLACK, w=LW):
        x0, y0, x1, y1 = box
        self.d.rectangle([px(x0), px(y0), px(x1), px(y1)],
                         fill=fill, outline=outline, width=int(px(w)))

    def ellipse(self, box, fill=None, outline=BLACK, w=LW):
        x0, y0, x1, y1 = box
        self.d.ellipse([px(x0), px(y0), px(x1), px(y1)],
                       fill=fill, outline=outline, width=int(px(w)))

    def polygon(self, pts, fill=BLACK, outline=None):
        self.d.polygon([px(c) for p in pts for c in p], fill=fill,
                       outline=outline)

    def dashed(self, p0, p1, color=BLACK, w=2.5, dash=9, gap=6):
        (x0, y0), (x1, y1) = p0, p1
        total = math.hypot(x1 - x0, y1 - y0)
        if total == 0:
            return
        ux, uy = (x1 - x0) / total, (y1 - y0) / total
        t = 0.0
        while t < total:
            e = min(t + dash, total)
            self.line((x0 + ux * t, y0 + uy * t), (x0 + ux * e, y0 + uy * e),
                      color, w)
            t = e + gap

    def arrow(self, p0, p1, color=BLACK, w=LW, head=18, spread=0.42):
        """Line from p0 to p1 with a filled head at p1."""
        (x0, y0), (x1, y1) = p0, p1
        ang = math.atan2(y1 - y0, x1 - x0)
        # Stop the shaft inside the head so the two do not overlap-bulge.
        bx, by = x1 - head * 0.85 * math.cos(ang), y1 - head * 0.85 * math.sin(ang)
        self.line((x0, y0), (bx, by), color, w)
        self.polygon([
            (x1, y1),
            (x1 - head * math.cos(ang - spread), y1 - head * math.sin(ang - spread)),
            (x1 - head * math.cos(ang + spread), y1 - head * math.sin(ang + spread)),
        ], fill=color)

    def arc(self, center, r, a0, a1, color=BLACK, w=LW, head=None):
        """Circular arc from a0 to a1 degrees, arrow-headed at a1 if asked.

        Angles run the usual way but on screen axes, where y grows downward,
        so 270 is the top of the circle and increasing angle sweeps clockwise.
        Traced as a polyline because PIL's own arc has no antialiasing and no
        way to cap an end with an arrowhead.
        """
        cx, cy = center
        steps = max(8, int(abs(a1 - a0) / 3))
        pts = []
        for i in range(steps + 1):
            a = math.radians(a0 + (a1 - a0) * i / steps)
            pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
        if head is None:
            self.polyline(pts, color, w)
        else:
            self.polyline(pts[:-1], color, w)
            self.arrow(pts[-2], pts[-1], color, w, head)

    def dim(self, p0, p1, color=BLACK, w=3.5, head=14):
        """Double-headed dimension arrow."""
        self.arrow(p0, p1, color, w, head)
        self.arrow(p1, p0, color, w, head)

    def hatch(self, box, color=BLACK, spacing=13, w=3):
        """45-degree hatching clipped to box — the fixed-support convention."""
        x0, y0, x1, y1 = box
        layer = Image.new("RGB", (W, H), WHITE)
        ld = ImageDraw.Draw(layer)
        span = (x1 - x0) + (y1 - y0)
        t = -(y1 - y0)
        while t < span:
            ld.line([px(x0 + t), px(y1), px(x0 + t + (y1 - y0)), px(y0)],
                    fill=color, width=int(px(w)))
            t += spacing
        mask = Image.new("L", (W, H), 0)
        ImageDraw.Draw(mask).rectangle(
            [px(x0), px(y0), px(x1), px(y1)], fill=255)
        self.img.paste(layer, (0, 0), mask)

    # -- text ------------------------------------------------------------
    def _font(self, size):
        return ImageFont.truetype(FONT_PATH, int(px(size)))

    def text(self, xy, s, size=40, color=BLACK, anchor="mm"):
        self.d.text((px(xy[0]), px(xy[1])), s, font=self._font(size),
                    fill=color, anchor=anchor)

    def text_sub(self, xy, main, sub, size=40, color=BLACK):
        """`main` with a subscript, centred as a unit on xy.

        Drawn by hand rather than with Unicode subscript codepoints, which
        Arial Bold does not carry for every digit.
        """
        f, fs = self._font(size), self._font(size * 0.62)
        wm = self.d.textlength(main, font=f)
        ws = self.d.textlength(sub, font=fs)
        left = px(xy[0]) - (wm + ws) / 2
        self.d.text((left, px(xy[1])), main, font=f, fill=color, anchor="lm")
        self.d.text((left + wm, px(xy[1]) + px(size) * 0.22), sub, font=fs,
                    fill=color, anchor="lm")

    def save(self, name):
        OUT.mkdir(parents=True, exist_ok=True)
        self.img.resize((SIZE, SIZE), Image.LANCZOS).save(OUT / name)
        print(f"  {name}")


def pin_support(c: Canvas, x, y, half=21, h=42):
    """The triangle-on-hatched-ground support, apex at (x, y)."""
    tri = [(x, y), (x - half, y + h), (x + half, y + h)]
    c.polygon(tri, fill=TAN)
    c.polyline(tri + [tri[0]], BLACK, LW)
    c.hatch((x - half - 5, y + h, x + half + 5, y + h + 14))
    c.line((x - half - 5, y + h), (x + half + 5, y + h), BLACK, 5)


def i_shape(c: Canvas, cx, cy, h, w, tf, tw, fill=TAN, lw=LW):
    """A symmetric I cross-section centred on (cx, cy)."""
    x0, x1 = cx - w / 2, cx + w / 2
    y0, y1 = cy - h / 2, cy + h / 2
    c.rect((x0, y0, x1, y0 + tf), fill=fill, w=lw)
    c.rect((x0, y1 - tf, x1, y1), fill=fill, w=lw)
    c.rect((cx - tw / 2, y0 + tf, cx + tw / 2, y1 - tf), fill=fill, w=lw)
    # Re-cover the flange/web seams so the joint reads as one member.
    c.d.rectangle([px(cx - tw / 2 + lw / 2), px(y0 + tf - lw / 2),
                   px(cx + tw / 2 - lw / 2), px(y0 + tf + lw / 2)], fill=fill)
    c.d.rectangle([px(cx - tw / 2 + lw / 2), px(y1 - tf - lw / 2),
                   px(cx + tw / 2 - lw / 2), px(y1 - tf + lw / 2)], fill=fill)


# ---------------------------------------------------------------- icons


def reynolds():
    """Pipe with laminar streamlines giving way to turbulent eddies."""
    c = Canvas()
    top, bot = 105, 235
    c.rect((18, top, 282, bot), fill=GREY, outline=None, w=0)
    # Laminar half: parallel, orderly.
    for y in (135, 170, 205):
        c.arrow((32, y), (128, y), BLACK, 5, 16)
    # Turbulent half: the same three streams, broken up.
    for y0, amp in ((135, 15), (170, 20), (205, 15)):
        pts = []
        for i in range(49):
            t = i / 48
            x = 145 + t * 115
            pts.append((x, y0 + amp * math.sin(t * 8.2) * (0.25 + t)))
        c.polyline(pts, RED, 5)
        c.arrow(pts[-2], pts[-1], RED, 5, 15)
    # Pipe walls last, so the streams tuck under them.
    c.line((18, top), (282, top), BLACK, 7)
    c.line((18, bot), (282, bot), BLACK, 7)
    c.dashed((18, 170), (282, 170), DARK_GREY, 2.5, 10, 8)
    c.text((150, 58), "Re", 62)
    c.save("icon_reynolds.png")


def pipe_pressure_drop():
    """Two standpipes over a run of pipe, at visibly different heads."""
    c = Canvas()
    pipe_top, pipe_bot = 214, 266
    h1, h2 = 62, 148  # standpipe fluid tops
    for x, top in ((72, h1), (216, h2)):
        c.rect((x - 15, top, x + 15, pipe_top), fill=TAN, w=LW)
    c.rect((18, pipe_top, 282, pipe_bot), fill=TAN, w=LW)
    # Clear the two tee joints so the standpipes open into the pipe.
    for x in (72, 216):
        c.d.rectangle([px(x - 15 + LW / 2), px(pipe_top - LW / 2),
                       px(x + 15 - LW / 2), px(pipe_top + LW / 2)], fill=TAN)
    c.arrow((110, 240), (180, 240), BLACK, 5, 17)
    # The head difference is the whole point, so it gets the red.
    c.dashed((72, h1), (150, h1), BLACK, 2.5, 8, 6)
    c.dashed((216, h2), (150, h2), BLACK, 2.5, 8, 6)
    c.dim((150, h1), (150, h2), RED, 4, 15)
    c.text((166, (h1 + h2) / 2), "Δp", 46, RED, anchor="lm")
    c.save("icon_pipe_pressure_drop.png")


def pump_power():
    """Centrifugal pump: volute, impeller, side inlet, top discharge."""
    c = Canvas()
    cx, cy, r = 152, 178, 82
    c.arrow((150, 96), (150, 24), BLACK, 7, 22)     # discharge
    c.arrow((16, 178), (78, 178), BLACK, 7, 22)     # suction
    c.ellipse((cx - r, cy - r, cx + r, cy + r), fill=GREY, w=6)
    for k in range(6):
        a0 = k * math.pi / 3
        pts = []
        for i in range(13):
            t = i / 12
            rad = 26 + t * 48
            ang = a0 + t * 0.85
            pts.append((cx + rad * math.cos(ang), cy + rad * math.sin(ang)))
        c.polyline(pts, BLACK, 5)
    c.ellipse((cx - 26, cy - 26, cx + 26, cy + 26), fill=TAN, w=5)
    c.text((252, 122), "P", 54, RED)
    c.save("icon_pump_power.png")


def composite_wall():
    """Three-layer wall with heat driven through it by a temperature drop."""
    c = Canvas()
    y0, y1 = 62, 250
    bounds = [(92, 128), (128, 172), (172, 212)]
    # Fills first with no stroke of their own: abutting rectangles would each
    # draw an outline into the shared seam and it would read as a black bar
    # rather than as the boundary between two materials.
    for (a, b), fill in zip(bounds, (TAN, GREY, TAN)):
        c.rect((a, y0, b, y1), fill=fill, outline=None, w=0)
    for a, _ in bounds[1:]:
        c.line((a, y0), (a, y1), BLACK, LW)
    c.rect((bounds[0][0], y0, bounds[-1][1], y1), fill=None, w=LW)
    c.arrow((22, 156), (280, 156), RED, 7, 24)
    c.text((52, 120), "q", 46, RED)
    c.text_sub((48, 214), "T", "1", 44)
    c.text_sub((252, 214), "T", "2", 44)
    c.save("icon_composite_wall.png")


def fin():
    """A fin off a hot base, shedding heat to the surroundings."""
    c = Canvas()
    c.rect((26, 40, 66, 260), fill=TAN, w=LW)
    c.hatch((26, 40, 66, 260))
    c.rect((26, 40, 66, 260), fill=None, w=LW)
    c.rect((66, 128, 236, 172), fill=TAN, w=LW)
    for x in (105, 150, 195):
        c.arrow((x, 124), (x, 78), RED, 4.5, 15)
        c.arrow((x, 176), (x, 222), RED, 4.5, 15)
    c.text((262, 100), "h", 44, RED)
    c.dim((66, 250), (236, 250), BLACK, 3.5, 14)
    c.text((151, 276), "L", 42)
    c.save("icon_fin.png")


def heat_exchanger():
    """Counter-flow: hot one way, cold the other, across a tube wall."""
    c = Canvas()
    c.rect((18, 78, 282, 222), fill=GREY, w=6)
    c.rect((18, 130, 282, 170), fill=TAN, w=5)
    c.arrow((40, 104), (262, 104), RED, 7, 22)
    c.arrow((262, 196), (40, 196), DARK_GREY, 7, 22)
    # Plain "ΔT": an "lm" subscript is illegible at the size a tool card
    # renders this at, and reads as part of the word rather than under it.
    c.text((150, 40), "ΔT", 50)
    c.save("icon_heat_exchanger.png")


def standard_sections():
    """A graduated series of rolled shapes — a catalogue, not one section."""
    c = Canvas()
    base = 252
    # Widths and gaps chosen so no two profiles touch; a series that overlaps
    # reads as one malformed shape instead of as a range of sizes. No standard
    # letter is stamped on it either — the library spans W, IPE and HEB, and
    # any one of those marks would misdescribe the other two.
    # Flanges and webs are drawn thicker than scale: at the default 5px stroke
    # a true-to-life web is thinner than its own two outlines and fills in
    # solid black. A lighter stroke keeps them open at this size.
    specs = [(52, 84, 52, 13, 11), (148, 130, 74, 16, 14),
             (248, 178, 94, 20, 17)]
    for cx, h, w, tf, tw in specs:
        i_shape(c, cx, base - h / 2 - 4, h, w, tf, tw, lw=4)
    c.line((14, base), (286, base), BLACK, 6)
    c.save("icon_standard_sections.png")


def shaft_critical_speed():
    """A rotor at midspan, the shaft bowed out into its first whirl."""
    c = Canvas()
    x0, x1, axis = 45, 255, 205
    for x in (x0, x1):
        pin_support(c, x, axis)
    c.dashed((x0, axis), (x1, axis), DARK_GREY, 2.5, 10, 8)
    # The whirl: half a sine between the bearings, which is what separates
    # this from a statically deflected beam.
    pts = []
    for i in range(97):
        t = i / 96
        pts.append((x0 + (x1 - x0) * t, axis - 52 * math.sin(math.pi * t)))
    c.polyline(pts, RED, 6)
    # The rotor rides the bow and hides the shaft passing behind it.
    cx, cy, r = 150, axis - 52, 34
    c.ellipse((cx - r, cy - r, cx + r, cy + r), fill=TAN, w=LW)
    c.arc((cx, cy), 50, 208, 332, RED, 4.5, head=16)
    c.text_sub((150, 50), "N", "c", 52, RED)
    c.save("icon_shaft_critical_speed.png")


def beam_natural_frequency():
    """A simply supported beam carrying its first two bending mode shapes."""
    c = Canvas()
    x0, x1, axis = 44, 256, 182
    c.rect((x0, axis - 8, x1, axis + 8), fill=TAN, w=LW)
    for x in (x0 + 10, x1 - 10):
        pin_support(c, x, axis + 8, half=20, h=38)
    # Two modes, not one: a single hump reads as a static deflection, and the
    # tool reports three modes.
    for amp, cycles, color, w in ((30, 2, DARK_GREY, 4), (58, 1, RED, 6)):
        pts = []
        for i in range(129):
            t = i / 128
            pts.append((x0 + (x1 - x0) * t,
                        axis - amp * math.sin(cycles * math.pi * t)))
        c.polyline(pts, color, w)
    c.text_sub((150, 50), "f", "n", 52, RED)
    c.save("icon_beam_natural_frequency.png")


def torsional_frequency():
    """Two rotors twisting against each other about a node on the shaft."""
    c = Canvas()
    c.rect((70, 146, 230, 174), fill=TAN, w=LW)
    # Rotors face-on, the left the heavier of the two, drawn over the shaft.
    c.ellipse((24, 108, 128, 212), fill=TAN, w=LW)
    c.ellipse((190, 122, 270, 202), fill=TAN, w=LW)
    # Opposed sweeps — that opposition is what holds a node still between them.
    c.arc((76, 160), 64, 202, 338, RED, 5, head=17)
    c.arc((230, 162), 52, 338, 202, RED, 5, head=17)
    # The node sits nearer the larger inertia.
    c.dashed((146, 104), (146, 218), DARK_GREY, 3, 10, 7)
    c.text_sub((150, 256), "ω", "n", 50, RED)
    c.save("icon_torsional_frequency.png")


def power_screw():
    """A screw jack: load pressing down on the nut, torque turning the screw."""
    c = Canvas()
    axis, top, base = 150, 92, 246
    # Base plate the screw stands on, hatched like a fixed support.
    c.rect((58, base, 242, base + 14), fill=GREY, w=LW)
    c.hatch((58, base + 14, 242, base + 34))
    # The screw column.
    c.rect((axis - 23, top, axis + 23, base), fill=TAN, w=LW)
    # The thread, drawn as the helix crossing the column rather than as a
    # zigzag on its edges: the lead angle is what the whole calculation turns
    # on, so it is what the icon should show.
    y = top + 14
    while y < base - 6:
        c.line((axis - 23, y + 9), (axis + 23, y - 9), BLACK, 3.5)
        y += 20
    # The load riding on the nut, and the force it puts down the screw.
    c.rect((94, top - 30, 206, top), fill=GREY, w=LW)
    c.arrow((axis, 18), (axis, top - 36), RED, 6, head=20)
    c.text((axis + 26, 34), "F", 46, RED)
    # The torque that raises it, swept about the screw axis at the collar.
    c.arc((axis, base - 4), 62, 200, 340, RED, 5.5, head=18)
    c.text_sub((axis + 92, base - 40), "T", "R", 44, RED)
    c.save("icon_power_screw.png")


def steam_tables():
    """A boiler drum part-full: water below, steam leaving above, a gauge."""
    c = Canvas()
    x0, y0, x1, y1 = 40, 92, 260, 262
    water = 196
    # Water fills the lower part; the vapour space above it stays white.
    c.rect((x0, water, x1, y1), fill=GREY, outline=None, w=0)
    # Bubbles rising through the water: this is saturation, not just water.
    for bx, by, r in ((92, 238, 9), (130, 220, 7), (178, 242, 10),
                      (216, 222, 7), (150, 246, 6)):
        c.ellipse((bx - r, by - r, bx + r, by + r), fill=WHITE, w=3)
    c.line((x0, water), (x1, water), BLACK, 4)
    # Steam lifting off the surface, in the red: it is what the table is about.
    for sx in (100, 150, 200):
        pts = []
        for i in range(25):
            t = i / 24
            pts.append((sx + 9 * math.sin(t * 2 * math.pi * 1.3), water - 14 - t * 64))
        c.polyline(pts, RED, 5)
    c.rect((x0, y0, x1, y1), fill=None, w=6)
    # Pressure gauge on a stub above the drum.
    c.rect((142, 60, 158, 92), fill=TAN, w=LW)
    c.ellipse((114, 12, 186, 84), fill=WHITE, w=LW)
    c.line((150, 48), (172, 30), RED, 5)
    c.ellipse((145, 43, 155, 53), fill=BLACK, outline=None, w=0)
    c.save("icon_steam_tables.png")


def ideal_gas():
    """Gas in a cylinder, compressed by a piston, heat crossing the wall."""
    c = Canvas()
    x0, x1, top, bot = 58, 242, 60, 262
    piston = 132
    # Gas below the piston, drawn as scattered molecules on grey.
    c.rect((x0, piston, x1, bot), fill=GREY, outline=None, w=0)
    for mx, my in ((88, 170), (132, 200), (176, 166), (212, 214), (104, 236),
                   (160, 240), (206, 178), (120, 158)):
        c.ellipse((mx - 6, my - 6, mx + 6, my + 6), fill=BLACK, outline=None, w=0)
    # Piston and rod.
    c.rect((x0, piston - 26, x1, piston), fill=TAN, w=LW)
    c.rect((140, top - 40, 160, piston - 26), fill=TAN, w=LW)
    # Cylinder walls and bottom.
    c.line((x0, top), (x0, bot), BLACK, 7)
    c.line((x1, top), (x1, bot), BLACK, 7)
    c.line((x0, bot), (x1, bot), BLACK, 7)
    # The work going in, and the heat that may cross the wall.
    c.arrow((208, 16), (208, 96), RED, 6, 20)
    c.arrow((296, 200), (252, 200), RED, 5, 17)
    c.text((276, 172), "Q", 40, RED)
    c.text((236, 50), "W", 40, RED)
    c.save("icon_ideal_gas.png")


def air_cycle():
    """An Otto cycle on p–v: two isentropes closed by two constant-volume legs."""
    c = Canvas()
    ox, oy = 44, 262
    c.arrow((ox, oy), (ox, 22), BLACK, 5, 16)
    c.arrow((ox, oy), (288, oy), BLACK, 5, 16)
    # Axis letters outside the plot, where the cycle cannot run into them.
    c.text((ox - 24, 30), "p", 40)
    c.text((276, oy + 22), "v", 40)
    v2, v1 = 84, 256
    k = 1.4

    def isentrope(p_at_v2):
        pts = []
        for i in range(41):
            v = v2 + (v1 - v2) * i / 40
            p = p_at_v2 * (v2 / v) ** k
            pts.append((v, oy - p))
        return pts

    lower = isentrope(128)   # compression 1→2
    upper = isentrope(212)   # expansion 3→4
    # Shade the enclosed net work.
    c.polygon(upper + list(reversed(lower)), fill=TAN)
    c.polyline(upper, RED, 6)
    c.polyline(lower, RED, 6)
    c.line(lower[0], upper[0], RED, 6)
    c.line(lower[-1], upper[-1], RED, 6)
    # Direction: clockwise, as every power cycle runs.
    c.arrow(upper[14], upper[17], RED, 6, 20)
    c.save("icon_air_cycle.png")


def rankine():
    """The steam plant loop: boiler, turbine, condenser and pump."""
    c = Canvas()
    # Boiler (left) and condenser (right), the two heat exchangers.
    c.rect((26, 64, 104, 188), fill=TAN, w=LW)
    c.rect((196, 190, 274, 262), fill=GREY, w=LW)
    # Turbine: a trapezoid widening in the flow direction.
    c.polygon([(186, 58), (262, 34), (262, 158), (186, 134)], fill=GREY)
    c.polyline([(186, 58), (262, 34), (262, 158), (186, 134), (186, 58)], BLACK, LW)
    # Pump.
    c.ellipse((40, 214, 88, 262), fill=TAN, w=LW)
    # The working fluid, round the loop, in red.
    c.polyline([(104, 90), (186, 90)], RED, 6)
    c.arrow((150, 90), (178, 90), RED, 6, 18)
    c.polyline([(236, 150), (236, 190)], RED, 6)
    c.arrow((236, 164), (236, 186), RED, 6, 18)
    c.polyline([(196, 240), (88, 240)], RED, 6)
    c.arrow((150, 240), (100, 240), RED, 6, 18)
    c.polyline([(64, 214), (64, 188)], RED, 6)
    c.arrow((64, 208), (64, 192), RED, 6, 16)
    # Shaft work leaving the turbine.
    c.line((262, 96), (292, 96), BLACK, 7)
    c.text((280, 126), "W", 36, RED)
    c.save("icon_rankine.png")


def main() -> None:
    print("writing icons:")
    reynolds()
    pipe_pressure_drop()
    pump_power()
    composite_wall()
    fin()
    heat_exchanger()
    standard_sections()
    shaft_critical_speed()
    beam_natural_frequency()
    torsional_frequency()
    power_screw()
    steam_tables()
    ideal_gas()
    air_cycle()
    rankine()


if __name__ == "__main__":
    main()
