"""
call with ./fontforge -script $0 
fontforge module is provided
"""

import os, os.path, shutil, sys

from fontforge import *


if len(sys.argv) != 2:
    print('Usage: %s <pfb font>' % sys.argv[0])
    sys.exit(1)
fontfile = sys.argv[1]

pbf_font = open(fontfile)

# prepare working environment
font_dir = pbf_font.fontname
try:
    shutil.rmtree(font_dir)
except shutil.FileNotFoundError:
    pass
finally:
    os.mkdir(font_dir)
    os.chdir(font_dir)

# convert font
svg_fontfile = '%s.svg' % pbf_font.fontname
pbf_font.generate(svg_fontfile)
svg_font = open(os.path.join(font_dir, svg_fontfile))

# extract glyphs
print('Encoding: ' + svg_font.encoding)
for glyph in svg_font.glyphs():
    print(glyph.glyphname, glyph.boundingBox())
    glyph.export('%s.svg' % glyph.glyphname)
