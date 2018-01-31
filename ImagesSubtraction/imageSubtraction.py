
import numpy as np
import cv2
import os

# Function to filter the frame
def denoise(frame):
    frame = cv2.medianBlur(frame,5)
    #frame = cv2.GaussianBlur(frame,(5,5),0)

    return frame

# Create a directory to save the output file
savePath = 'D:/invader/Documents/py/MachineVision/ImagesSubtraction/output'

# Creating the directory, the exist_ok is change to true so
# that this line will not give error if the directory already exist
os.makedirs(savePath, exist_ok=True)

# The path where we save the frame
path = 'D:/invader/Documents/py/Sample/getFrame/frame'

# Read two file, the first one is the background
# the second one is the background with and object
frame1 = cv2.imread(path + '/kosong28.png')
frame2 = cv2.imread(path + '/nuri65.png')

# check if image is read successfully
if frame1 is None and frame2 is None:
    print("error: image not read")
    cv2.waitKey(0)

# Removing noise from frame
frame1 = denoise(frame1)
frame2 = denoise(frame2)

# Show the original images
cv2.imshow('kosong', frame1)
cv2.imshow('nuri', frame2)

# Change the image to grayscale befor subtract
frame1 = cv2.cvtColor(frame1, cv2.COLOR_BGR2GRAY)
frame2 = cv2.cvtColor(frame2, cv2.COLOR_BGR2GRAY)

# Use absolute different to subtract the frame
imgSubstract = cv2.absdiff(frame1,frame2)
cv2.imshow('substract', imgSubstract)
cv2.imwrite(savePath + "/subtract.png",imgSubstract)

# Threshold the image to get binary images
ret,imgThresh = cv2.threshold(imgSubstract,30,255,cv2.THRESH_BINARY)
cv2.imshow('Threshold', imgThresh)
cv2.imwrite(savePath + "/threshold.png",imgThresh)

# Create structuring element
strElement3x3 = cv2.getStructuringElement(cv2.MORPH_RECT,(3,3))
strElement5x5 = cv2.getStructuringElement(cv2.MORPH_RECT,(5,5))
strElement7x7 = cv2.getStructuringElement(cv2.MORPH_RECT,(7,7))
strElement9x9 = cv2.getStructuringElement(cv2.MORPH_RECT,(9,9))

# Use the structuring element for mophological transformation
# We use erode first to get rid of the noise
# Then we dilate it back because the image we want get
# shrunk from erode operation
imgStrel = cv2.erode(imgThresh,strElement5x5)
imgStrel = cv2.dilate(imgStrel,strElement7x7)
imgStrel = cv2.dilate(imgStrel,strElement7x7)
cv2.imshow('Morphological Transformation', imgStrel)
cv2.imwrite(savePath + "/MorphologicalTransformation.png",imgStrel)

# find contour of the image
im, contours, hierarchy = cv2.findContours(imgStrel,cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
cv2.imshow('contour', im)
cv2.imwrite(savePath + "/contour.png",im)

cv2.waitKey(0)

