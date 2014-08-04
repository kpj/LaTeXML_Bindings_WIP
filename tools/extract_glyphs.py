"""
call with ./fontforge -script $0 
fontforge module is provided
"""

import os, shutil, sys

from fontforge import *


if len(sys.argv) != 2:
    print('Usage: %s <svg font>' % sys.argv[0])
    sys.exit(1)
fontfile = sys.argv[1]

font = open(fontfile)

try:
    shutil.rmtree(font.fontname)
except FileNotFoundError:
    pass
finally:
    os.mkdir(font.fontname)
    os.chdir(font.fontname)

print('Encoding: ' + font.encoding)
for glyph in font.glyphs():
    glyph.export('%s.svg' % glyph.glyphname)
