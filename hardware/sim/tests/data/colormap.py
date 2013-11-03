#!/usr/bin/python

# Generate grayscale colormap
colormap = [(i,i,i) for i in xrange(256)]

# Overwrite with pure R,G,B
colormap[1] = (255, 0, 0)
colormap[2] = (0, 255, 0)
colormap[3] = (0, 0, 255)

f = open('colormap.hex','w')
for color in colormap:
  f.write('%02X%02X%02X\n' % color)

f.close()
