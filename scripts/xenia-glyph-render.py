#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 XeniaCloud
# SPDX-License-Identifier: GPL-3.0-or-later
"""Render the Xenia two-bubble glyph into the PNG imagesets that need it.

The glyph is the mark approved on 12 Sep 2026 and already applied in vector form
to AppIcon.icon/Assets/Talk-white.svg and changelog-avatar.imageset (XNT-92):
two solid overlapping rounded rectangles plus a solid triangular tail, flat
fill, no even-odd cutout. Geometry here is the same design expressed in the
24x24 coordinate system of Talk-white.svg, with the tail-join fix from XNT-101 -
the tail's top-left corner moves from x=6.8 to x=7.6 so it meets the straight
part of the lower bubble's bottom edge rather than its rounded corner, which
left a small notch.

Assets are PNG 1x/2x/3x imagesets rather than vectors, so every scale is
rendered here. Each one keeps the footprint of the artwork it replaces: the
glyph is scaled to the width of the previous glyph's alpha bounding box and
centred on that box, so navigation bars and the login screen keep their
existing rhythm. The glyph is wider than it is tall, so matching width leaves
it very slightly shorter than the old circular mark.

Run from the repository root:

    python3 scripts/xenia-glyph-render.py

Requires Pillow. Rendering is supersampled 16x and downsampled with an exact
box filter, which is what produces the antialiased edges at 24pt.
"""

import os
import sys

try:
    from PIL import Image, ImageDraw
except ImportError:  # pragma: no cover
    sys.exit("Pillow is required: python3 -m pip install Pillow")

# Glyph geometry in the 24x24 frame of AppIcon.icon/Assets/Talk-white.svg.
# rect: (x, y, width, height, corner radius)
RECT_UPPER = (11.6, 6.4, 8.0, 6.4, 1.8)
RECT_LOWER = (5.2, 10.4, 9.2, 7.2, 2.2)
TAIL = ((7.6, 17.6), (5.6, 20.2), (9.8, 17.6))

# Tight bounding box of the three shapes above, used to place the glyph.
GLYPH_BOX = (5.2, 6.4, 19.6, 20.2)

SUPERSAMPLE = 16

WHITE = (255, 255, 255, 255)
BLACK = (0, 0, 0, 255)
# The grey the placeholder artwork is drawn in upstream, #d5d5d5. PlaceholderView
# re-renders the image as a template and tints it with NCAppBranding
# placeholderColor, so on screen only the alpha channel of these assets matters -
# the colour is kept to match the sibling placeholders at source level.
GREY = (213, 213, 213, 255)

# name -> (canvas w, canvas h, glyph width, fill) at 1x. Canvas and glyph width
# are taken from the asset being replaced; see the module docstring.
ASSETS = {
    "loginLogo": (250, 125, 66.67, WHITE),
    "navigationLogo": (24, 24, 21.33, WHITE),
    "navigationLogoDark": (24, 24, 21.33, BLACK),
    "app-logo-callkit": (40, 40, 35.33, WHITE),
    # logo-action is deliberately absent. It sits next to "Open in Nextcloud"
    # and identifies the Nextcloud app, so XNT-117 restored the upstream mark;
    # rendering it here would silently undo that.
    # XNT-106. launchscreen is drawn by LaunchScreen.xib on every cold start;
    # talk-20 is a template image, so only its alpha channel matters.
    "launchscreen": (200, 200, 175.33, WHITE),
    "talk-20": (20, 20, 18.0, WHITE),
    # XNT-129. The empty conversation list. The mark it replaces is the
    # Nextcloud outline "Q", 112pt wide on a 128pt canvas at every scale.
    "conversations-placeholder": (128, 128, 112.0, GREY),
}

ASSET_ROOT = os.path.join("NextcloudTalk", "Images.xcassets")


def render(canvas_w, canvas_h, glyph_w, fill, scale):
    """Render one scale of the glyph, centred on the canvas."""
    px_w, px_h = canvas_w * scale, canvas_h * scale
    image = Image.new("RGBA", (px_w * SUPERSAMPLE, px_h * SUPERSAMPLE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    box_w = GLYPH_BOX[2] - GLYPH_BOX[0]
    box_h = GLYPH_BOX[3] - GLYPH_BOX[1]
    # One factor from glyph units to supersampled pixels.
    k = (glyph_w * scale * SUPERSAMPLE) / box_w
    # Offsets that centre the glyph's bounding box on the canvas.
    off_x = (px_w * SUPERSAMPLE - box_w * k) / 2 - GLYPH_BOX[0] * k
    off_y = (px_h * SUPERSAMPLE - box_h * k) / 2 - GLYPH_BOX[1] * k

    def point(x, y):
        return (x * k + off_x, y * k + off_y)

    for x, y, w, h, radius in (RECT_UPPER, RECT_LOWER):
        x0, y0 = point(x, y)
        x1, y1 = point(x + w, y + h)
        draw.rounded_rectangle((x0, y0, x1, y1), radius=radius * k, fill=fill)
    draw.polygon([point(*p) for p in TAIL], fill=fill)

    # BOX, not LANCZOS: the supersample factor is an exact integer, so a box
    # filter is plain area averaging and is what antialiases the edges. Lanczos
    # has negative lobes, which ring a faint halo of non-zero alpha several
    # pixels past the glyph and quietly widen its bounding box.
    return image.resize((px_w, px_h), Image.BOX)


def main():
    if not os.path.isdir(ASSET_ROOT):
        sys.exit(f"run from the repository root: {ASSET_ROOT} not found")

    for name, (canvas_w, canvas_h, glyph_w, fill) in ASSETS.items():
        imageset = os.path.join(ASSET_ROOT, f"{name}.imageset")
        if not os.path.isdir(imageset):
            sys.exit(f"missing imageset: {imageset}")
        for scale in (1, 2, 3):
            suffix = "" if scale == 1 else f"@{scale}x"
            path = os.path.join(imageset, f"{name}{suffix}.png")
            render(canvas_w, canvas_h, glyph_w, fill, scale).save(path)
            print(f"wrote {path}")


if __name__ == "__main__":
    main()
