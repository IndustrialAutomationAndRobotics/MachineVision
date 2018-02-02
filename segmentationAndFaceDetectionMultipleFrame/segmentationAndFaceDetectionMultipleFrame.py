import numpy as np
import cv2
import os

'''
Helper Functions and Variables
'''

# variable to keep track the number of frame we save
count = 1

# Create structuring element for morphological transformation
strElement3x3 = cv2.getStructuringElement(cv2.MORPH_RECT,(3,3))
strElement5x5 = cv2.getStructuringElement(cv2.MORPH_RECT,(5,5))
strElement7x7 = cv2.getStructuringElement(cv2.MORPH_RECT,(7,7))
strElement9x9 = cv2.getStructuringElement(cv2.MORPH_RECT,(9,9))

# Function to filter the frame
def denoise(frame):
    frame = cv2.medianBlur(frame,5)
    #frame = cv2.GaussianBlur(frame,(5,5),0)
    return frame

# Function to fill the holes in our binary image
def fillHole(frame):
    
    #Copy the threshold image
    imgClone = frame.copy()

    # Mask used to flood filling
    h, w = frame.shape[:2]
    mask = np.zeros((h+2, w+2), np.uint8)

    # FloodFill from point (0,0)
    cv2.floodFill(imgClone, mask, (0,0), 255)

    # Invert floodfilled image
    imgCloneInv = cv2.bitwise_not(imgClone)

    # Combine the two images to get the foreground
    imgOut = frame | imgCloneInv
     
    return imgOut



'''
Load path and files
'''

# Main path
mainPath = 'E:/Parasite/Documents/py'

# Load haar cascade for face detection
face_cascade = cv2.CascadeClassifier(mainPath + '/MachineVision/segmentationAndFaceDetection/CascadeFiles/haarcascade_frontalface_alt.xml')

# Create save frame files
os.makedirs(mainPath + '/Sample/segmentationAndFaceDetectionMultipleFrame/frame', exist_ok=True)

# Get the background image and the video
imgBack = cv2.imread(mainPath + '/Sample/getFrame/frame/kosong28.png')
vid = cv2.VideoCapture(mainPath + '/Sample/getFrame/nurisebok.mp4')

# Check wethe the image and video succesfully loaded
if imgBack is None:
    print("Error loading image")
if vid.isOpened() == False:
    print("Error loading video")

# Show the background image
#cv2.imshow('background', imgBack)

'''
Main Code
'''

# remove noise and change to grayscale
imgBackDenoise = denoise(imgBack)
imgBackGray = cv2.cvtColor(imgBackDenoise, cv2.COLOR_BGR2GRAY)


while cv2.waitKey(1) != 27 and vid.isOpened():

    # retrieve the frame
    ret, frame = vid.read()

    # check wether the frame is retrieve or not
    if ret == False:
        break

    # remove noise and change to grayscale
    frameDenoise = denoise(frame)
    frameGray = cv2.cvtColor(frameDenoise, cv2.COLOR_BGR2GRAY)
    
    # use absolute different to subtract the frame
    imgSubtract = cv2.absdiff(imgBackGray, frameGray)

    # Threshold the image to get binary images
    ret, imgThresh = cv2.threshold(imgSubtract, 30, 255, cv2.THRESH_BINARY)
    
    # Use structuring element for morphological transformation
    imgStrel = cv2.erode(imgThresh, strElement5x5)
    imgStrel = cv2.dilate(imgStrel, strElement9x9)
    imgStrel = cv2.dilate(imgStrel, strElement9x9)

    # Fill object holes
    imgFill = fillHole(imgStrel)
    
    # find contour of the image to get our roi
    imContour, contours, hierarchy = cv2.findContours(imgFill,cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)

    # Create bounding box around the object
    for c in contours:
        rect = cv2.boundingRect(c)
        x,y,w,h = rect
        cv2.rectangle(imContour, (x,y),(x+w,y+h), (255,255,255),2)

    # Create a new image from the roi above
    imgROI = frameGray[y:y+h, x:x+w]
    imgFace = frame[y:y+h, x:x+w]

    # Use haar cascade to detect the faces
    faces = face_cascade.detectMultiScale(imgROI, 1.3, 5)

    print("Found {0} faces!".format(len(faces)))

    for(x,y,w,h) in faces:
        cv2.rectangle(imgFace, (x,y), (x+w, y+h), (255,255,255),2)
        cv2.imwrite(mainPath + "/Sample/segmentationAndFaceDetectionMultipleFrame/frame/faceDetect%d.png" % count,imgFace)
        count = count + 1



    cv2.imshow('faces', imgFace)

    




    # show the video
    #cv2.imshow('Video', frame)

vid.release()
cv2.destroyAllWindows()
