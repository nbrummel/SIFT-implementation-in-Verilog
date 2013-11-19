#!/usr/bin/python

import cv2
import sys

infile = sys.argv[1]
outfile = infile.split('.')[0] + '.coe'

img = cv2.imread(infile)

fout = open(outfile,'w')

fout.write('memory_initialization_radix=16;\n')
fout.write('memory_initialization_vector=\n')

n_row = len(img)
n_col = len(img[0])

for i in range(n_row):
  for j in range(n_col):
    fout.write('%02x' % img[i,j,0])
    if i == (n_row-1) and j == (n_col-1):
      fout.write(';\n')
    else:
      fout.write(',\n')

fout.close()
