import cv2
import numpy as np
from matplotlib import pyplot as plt
import time

def getPOI(xSize, ySize, kernelSize):

    mean = kernelSize//2
    xPos = mean
    yPos = mean

    xStep = (xSize-mean)//kernelSize
    yStep = (ySize-mean)//kernelSize
    length = xStep*yStep
    POI = np.zeros([length,1,2])
    count = 0
    for i in range(yStep):
        for j in range(xStep):
            POI[count,0,1] = xPos
            POI[count,0,0] = yPos
            xPos += kernelSize
            count += 1
        xPos = mean
        yPos += kernelSize



    return POI
def LK():

    KERNEL = 5
    FILTER = 7

    count = 0

    directory = 'sphere/sphere.'
    fileName = directory + str(count) + '.bmp'
    imgOld = cv2.imread(fileName,0)
    imgOld = cv2.GaussianBlur(imgOld,(FILTER,FILTER),1)

    POI = getPOI(200,200,KERNEL)

    for i in range(1521):
        s = ''
        for j in range(1):
            s = s + str(POI[i][j]) + ' '
        print(s)

LK()