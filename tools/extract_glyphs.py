"""
call with ./fontforge -script $0 <arg>
fontforge module is provided
"""

import os, sys
from xml.etree import ElementTree as et

from fontforge import open as open_font


# helper functions
def getSVG(glyph):
    tmp_name = 'myverysecretsvgfilewhichnoonewilleverknow.svg'
    glyph.export(tmp_name)
    with open(tmp_name, 'r') as fd:
        content = fd.read()
    os.remove(tmp_name)
    return et.fromstring(content)

# handle startup
if len(sys.argv) != 2:
    print('Usage: %s <pfb font>' % sys.argv[0])
    sys.exit(1)
fontfile = sys.argv[1]

pfb_font = open_font(fontfile)

# extract glyphs
xml = et.Element('font')
for glyph in pfb_font.glyphs():
    svg = getSVG(glyph)

    g = et.Element('glyph', attrib={'index': str(glyph.encoding), 'name': glyph.glyphname})
    g.append(svg)

    xml.append(g)

# save extracted glyphs
with open('%s.xml' % pfb_font.fontname, 'w') as fd:
    fd.write(et.tostring(xml))
