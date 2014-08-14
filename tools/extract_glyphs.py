"""
call with ./fontforge -script $0 <arg>
fontforge module is provided
"""

import os, sys
from xml.etree import ElementTree as et

from fontforge import open as open_font


# helper functions
def getSVG(glyph):
    # convert glyph
    tmp_name = 'myverysecretsvgfilewhichnoonewilleverknow.svg'
    glyph.export(tmp_name)
    with open(tmp_name, 'r') as fd:
        content = fd.read()
    os.remove(tmp_name)
    svg = et.fromstring(content)

    svg.set('viewBox', '0 0 1000 1000')
    svg.insert(0, et.Element('rect', attrib={'x': "0", 'y': "0", 'width': "1000", 'height': "1000", 'style': "fill:none;stroke-width:50;stroke:currentColor;"}))

    # set namespace (svg: http://www.w3.org/2000/svg)
    for e in svg.getiterator():
        e.tag = 'svg:' + e.tag

    return svg

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

    g = et.Element('glyph', attrib={'index': str(glyph.encoding), 'name': glyph.glyphname, 'xmlns:svg': 'http://www.w3.org/2000/svg'})
    g.append(svg)

    xml.append(g)

# save extracted glyphs
with open('%s.xml' % pfb_font.fontname, 'w') as fd:
    fd.write(et.tostring(xml))
