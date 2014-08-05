"""
call with ./fontforge -script $0 <arg>
fontforge module is provided
"""

import os, shutil, sys

from fontforge import *


# handle startup
if len(sys.argv) != 2:
    print('Usage: %s <pfb font>' % sys.argv[0])
    sys.exit(1)
fontfile = sys.argv[1]

pfb_font = open(fontfile)

# prepare working environment
font_dir = pfb_font.fontname
try:
    shutil.rmtree(font_dir)
except: # for compatibility with python 2 and 3
    pass
finally:
    os.mkdir(font_dir)
    os.chdir(font_dir)

# extract glyphs
for glyph in pfb_font.glyphs():
    print(glyph.glyphname, glyph.encoding)
    glyph.export('%s.svg' % glyph.glyphname)
