#!/usr/bin/env python
import sys, os
import numpy as np
sys.path.insert(0,os.path.realpath(__file__+'/../../Python'))

basedir=os.environ["basedir"]

hytimes = np.loadtxt('%s/tmp/hytimes.txt' % basedir,delimiter=' ',ndmin=1)
h5time = np.loadtxt('%s/tmp/h5time.txt' % basedir,delimiter=' ')

#print h5time

biggest=10000000
tol = 0.000001

for t in range(len(hytimes)):
    smallest = abs(hytimes[t] - h5time)
    if smallest < biggest and hytimes[t] - h5time < 0.:
        biggest = smallest

# messy hack to make sure digit format is right
for t in range(len(hytimes)):
    if abs(hytimes[t] - h5time)-biggest < tol and hytimes[t] - h5time < 0.:
        if hytimes[t] >= 1 and hytimes[t] < 10:
            print( '%.11f' % hytimes[t])
        elif hytimes[t] >= 10**1 and hytimes[t] < 10**2:
            print( '%.10f' % hytimes[t])
        elif hytimes[t] >= 10**2 and hytimes[t] < 10**3:
            print( '%.9f' % hytimes[t])
        elif hytimes[t] >= 10**3 and hytimes[t] < 10**4:
            print( '%.8f' % hytimes[t])
        elif hytimes[t] >= 10**4 and hytimes[t] < 10**5:
            print( '%.7f' % hytimes[t])
        elif hytimes[t] >= 10**5 and hytimes[t] < 10**6:
            print( '%.6f' % hytimes[t])
        elif hytimes[t] >= 10**6 and hytimes[t] < 10**7:
            print( '%.5f' % hytimes[t])
        elif hytimes[t] >= 10**7 and hytimes[t] < 10**8:
            print( '%.4f' % hytimes[t])
        elif hytimes[t] >= 10**8 and hytimes[t] < 10**9:
            print( '%.3f' % hytimes[t])
        elif hytimes[t] >= 10**9 and hytimes[t] < 10**10:
            print( '%.2f' % hytimes[t])
        elif hytimes[t] >= 10**10 and hytimes[t] < 10**11:
            print( '%.1f' % hytimes[t])
        elif hytimes[t] >= 10**11 and hytimes[t] < 10**12:
            print( '%.0f' % hytimes[t])

