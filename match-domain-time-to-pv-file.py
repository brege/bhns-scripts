#!/usr/bin/env python
import sys, os
import numpy as np
sys.path.insert(0,os.path.realpath(__file__+'/../../Python'))

hytimes = np.loadtxt('/RQexec/brege/MicrophysicsSurvey/BHNS/tmp/hytimes.txt',delimiter=' ',ndmin=1)
h5time = np.loadtxt('/RQexec/brege/MicrophysicsSurvey/BHNS/tmp/h5time.txt',delimiter=' ')
hytimes = np.loadtxt('/RQexec/brege/MicrophysicsSurvey/BHNS/tmp/hytimes.txt',delimiter=' ')

#print h5time

biggest=10000000
tol = 0.000001

for t in range(len(hytimes)):
    smallest = abs(hytimes[t] - h5time)
    if smallest < biggest and hytimes[t] - h5time < 0.:
        biggest = smallest

#print biggest

for t in range(len(hytimes)):
    if abs(hytimes[t] - h5time)-biggest < tol and hytimes[t] - h5time < 0.:
        print('%.8f' % hytimes[t])
