"""
reference : https://github.com/ablarry91/Optical-Flow-LucasKanade-HornSchunck
"""

import cv2
import numpy as np
from matplotlib import pyplot as plt
import time


def compareGraphs(imgOld, imgNew, POI, V):
    plt.imshow(imgNew,cmap = 'gray')
    plt.scatter(POI[:,0,1],POI[:,0,0])
    for i in range(len(POI)):
        plt.arrow(POI[i,0,1],POI[i,0,0],V[i,1]*1,V[i,0]*1, color = 'red')

    plt.show()

def buildA(img, centerX, centerY, kernelSize):
    mean = kernelSize//2
    count = 0
    home = int(img[centerY, centerX])

    A = np.zeros([kernelSize**2, 2])

    for j in range(-mean,mean+1):
        for i in range(-mean,mean+1):
            if i == 0:
                Ax = 0
            else:
                Ax = (home - img[centerY+j, centerX+i])/i
            if j == 0:
                Ay = 0
            else:
                Ay = (home - img[centerY+j, centerX+i])/j

            A[count] = np.array([Ay, Ax])
            count += 1


    return A

def buildB(imgNew, imgOld, centerX, centerY, kernelSize):
    mean = kernelSize//2
    count = 0
    home = imgNew[centerY, centerX]

    B = np.zeros([kernelSize**2])

    for j in range(-mean,mean+1):
        for i in range(-mean,mean+1):
            Bt = int(imgNew[centerY+j,centerX+i]) - int(imgOld[centerY+j, centerX+i])
            B[count] = Bt
            count += 1

    return B

def gaussianWeight(kernelSize, even=False):
    if even == True:
        weight = np.ones([kernelSize, kernelSize])

        weight = weight.reshape((1,kernelSize**2))

        weight = np.array(weight)[0]

        weight = np.diag(weight)

        return weight

    SIGMA = 1
    CORRELATION = 0
    weight = np.zeros([kernelSize,kernelSize])
    cpt = kernelSize%2+kernelSize//2
    for i in range(len(weight)):
        for j in range(len(weight)):
            ptx = i + 1
            pty = j + 1
            weight[i,j] = 1/(2*np.pi*SIGMA**2)/(1-CORRELATION**2)**.5*np.exp(-1/(2*(1-CORRELATION**2))*((ptx-cpt)**2+(pty-cpt)**2)/(SIGMA**2))

    weight = weight.reshape((1,kernelSize**2))
    weight = np.array(weight)[0]
    weight = np.diag(weight)

    return weight

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


    POI = POI.astype(int)
    return POI
def LK():

    KERNEL = 5
    FILTER = 7

    count = 0

    #directory = 'box/box.'
    #directory = 'office/office.'
    #directory = 'rubic/rubic.'
    directory = 'sphere/sphere.'
    fileName = directory + str(count) + '.bmp'
    imgOld = cv2.imread(fileName,0)
    imgOld = cv2.GaussianBlur(imgOld,(FILTER,FILTER),1)

    POI = getPOI(200,200,KERNEL)

##    for i in range(1521):
##        s = ''
##        for j in range(1):
##            s = s + str(POI[i][j]) + ' '
##        print(s)

    W = gaussianWeight(KERNEL,even=True)

##    for i in range(25):
##            s = ''
##            for j in range(25):
##                s = s + str(W[i][j]) + ' '
##            print(s)

    while True:

        count += 1
        imgNew = cv2.imread(directory + str(count) + '.bmp',0)
        imgNew = cv2.GaussianBlur(imgNew,(FILTER,FILTER),1)

        try:
            if imgNew.any():
                print('it exists')
                pass
        except:
            print('it doesnt exist')
            break


        V = np.zeros([(POI.shape)[0],2])

        for i in range(len(POI)):
            A = buildA(imgNew, POI[i][0][1], POI[i][0][0], KERNEL)
            B = buildB(imgNew, imgOld, POI[i][0][1], POI[i][0][0], KERNEL)

            try:
                Vpt = np.matrix((A.T).dot(W**2).dot(A)).I.dot(A.T).dot(W**2).dot(B)
                print(Vpt)
                V[i,0] = Vpt[0,0]
                V[i,1] = Vpt[0,1]
            except:
                pass

        compareGraphs(imgOld,imgNew, POI, V)

        if count == 2:
            break

        imgOld = imgNew
        POI = getPOI(200,200,KERNEL)

LK()