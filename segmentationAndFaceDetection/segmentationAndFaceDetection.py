
import numpy as np
import cv2
import os

# Change all this path corresponds to your device path
# The path where we save the frame
path = 'E:/Parasite/Documents/py/Sample/getFrame/frame'
# Create a directory to save the output file
savePath = 'E:/Parasite/Documents/py/MachineVision/segmentationAndFaceDetection/output'
# The path to the haar_cascade xml files
# Resource from https://github.com/prateekvjoshi/Body-Parts-Detection/blob/master/detectBodyParts.cpp
haar_cascade_path = 'E:/Parasite/Documents/py/MachineVision/segmentationAndFaceDetection/CascadeFiles'

# Load the face cascade files
# This haar cascade files will be use to detect face
# https://docs.opencv.org/3.3.0/d7/d8b/tutorial_py_face_detection.html
face_cascade = cv2.CascadeClassifier(haar_cascade_path + '/haarcascade_frontalface_alt.xml')

# Creating the directory, the exist_ok is change to true so
# that this line will not give error if the directory already exist
os.makedirs(savePath, exist_ok=True)

# Function to filter the frame
def denoise(frame):
    frame = cv2.medianBlur(frame,5)
    #frame = cv2.GaussianBlur(frame,(5,5),0)
    return frame

# Function to fill the holes in our binary image
def fillHole(frame):

    # Copy the thresholded image
    imgClone = frame.copy()

    # Mask used to flood filling
    h, w = frame.shape[:2]
    mask = np.zeros((h+2, w+2), np.uint8)

    # Floodfill from point (0,0)
    cv2.floodFill(imgClone, mask, (0,0), 255)

    # Invert floodfilled image
    imgCloneInv = cv2.bitwise_not(imgClone)

    # Combine the two images to get the foreground
    imgOut = frame | imgCloneInv

    return imgOut

# Read two file, the first one is the background
# the second one is the background with and object
frame1 = cv2.imread(path + '/kosong28.png')
frame2 = cv2.imread(path + '/nuri65.png')

# check if image is read successfully
if frame1 is None and frame2 is None:
    print("error: image not read")
    cv2.waitKey(0)

# Removing noise from frame
img1Denoise = denoise(frame1)
img2Denoise = denoise(frame2)

# Change the image to grayscale before subtract
img1Gray = cv2.cvtColor(img1Denoise, cv2.COLOR_BGR2GRAY)
img2Gray = cv2.cvtColor(img2Denoise, cv2.COLOR_BGR2GRAY)

# Use absolute different to subtract the frame
imgSubstract = cv2.absdiff(img1Gray,img2Gray)

# Threshold the image to get binary images
ret,imgThresh = cv2.threshold(imgSubstract,30,255,cv2.THRESH_BINARY)

# Create structuring element
strElement3x3 = cv2.getStructuringElement(cv2.MORPH_RECT,(3,3))
strElement5x5 = cv2.getStructuringElement(cv2.MORPH_RECT,(5,5))
strElement7x7 = cv2.getStructuringElement(cv2.MORPH_RECT,(7,7))
strElement9x9 = cv2.getStructuringElement(cv2.MORPH_RECT,(9,9))

# Use the structuring element for mophological transformation
# We use erode first to get rid of the noise
# Then we dilate it back because the image we want get
# shrunk from erode operation, dilate is done twice because
# we want the left part of our object not seperated from the main object
imgStrel = cv2.erode(imgThresh,strElement5x5)
imgStrel = cv2.dilate(imgStrel,strElement9x9)
imgStrel = cv2.dilate(imgStrel,strElement9x9)

# Fill object holes
imgFill = fillHole(imgStrel)

# find contour of the image to get our roi
im, contours, hierarchy = cv2.findContours(imgFill,cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)

# Create bounding box around the object
for c in contours:
    rect = cv2.boundingRect(c)
    x,y,w,h = rect
    cv2.rectangle(im,(x,y),(x+w,y+h),(255,255,255),2)

# Create a new image from the roi above
imgROI = frame2[y:y+h, x:x+w]

# Change it to grayscale
# Do histogram equalization if needed to
imgROIGray = cv2.cvtColor(imgROI,cv2.COLOR_BGR2GRAY)
#imgROI = cv2.equalizeHist(imgROI)

# Use haar cascade to detect the faces, manipulate the
# scale factor and minNeighbour for the best result
faces = face_cascade.detectMultiScale(imgROIGray, 1.3, 5)

print("Found {0} faces!".format(len(faces)))

# Create bounding boxes around the faces
for (x,y,w,h) in faces:
    cv2.rectangle(imgROIGray, (x,y), (x+w, y+h), (255,255,255),2)

# Show the the images
#cv2.imshow('kosong', frame1)
#cv2.imshow('nuri', frame2)
#cv2.imshow('substract', imgSubstract)
#cv2.imshow('Threshold', imgThresh)
#cv2.imshow('Morphological Transformation', imgStrel)
#cv2.imshow("Bounding box the object",im)
cv2.imshow("Face Detected", imgROIGray)
# Save the output image
cv2.imwrite(savePath + "/subtract.png",imgSubstract)
cv2.imwrite(savePath + "/threshold.png",imgThresh)
cv2.imwrite(savePath + "/MorphologicalTransformation.png",imgStrel)
cv2.imwrite(savePath + "/boundingBox.png",im)
cv2.imwrite(savePath + "/Face.png",imgROIGray)

cv2.waitKey(0)

