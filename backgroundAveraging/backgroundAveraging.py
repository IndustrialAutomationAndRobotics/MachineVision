import numpy as np
import cv2

class BackGroundSubtractor:

    # This class take 2 arguments
    # alpha : The background learning factor, its value
    # should be between 0 and 1. The higher the value,
    # the more quickly you program learns the changes in
    # the background. Therefore, for a static background
    # use a lower value, like 0.001. But if your background
    # has moving trees and stuff, use a higher value.
    # firstFrame: This is the first frame from the video/webcam
    def __init__(self,alpha,firstFrame):
        self.alpha = alpha
        self.backGroundModel = firstFrame

    def getForeground(self,frame):
        # apply the background averaging formula:
        # New_Background = Current_Frame * Alpha + Old_Background * (1 - Alpha)
        self.backGroundModel = frame * self.alpha + self.backGroundModel * (1 - self.alpha)

        # The datatype of backGroundModel after we do the equation above will
        # change to float. Therefore, we cannot use absdiff directly,
        # instead we change it to uint8 datatype and then use absdiff
        return cv2.absdiff(self.backGroundModel.astype(np.uint8),frame)

# get the video. Change the parameter to use a webcam
cam = cv2.VideoCapture('E:/Parasite/Documents/py/MachineVision/sample/vid.avi')

# check if the video is successfully read
if cam.isOpened() == False:
    print("Error reading video file")
    cv2.waitKey(0)
    cv2.destroyAllWindows()

# function to filter the image and change it to grayscale
def denoise(frame):
    frame = cv2.medianBlur(frame,5)
    frame = cv2.GaussianBlur(frame,(5,5),0)
    frame = cv2.cvtColor(frame,cv2.COLOR_BGR2GRAY)

    return frame

# read the first frame
ret,frame = cam.read()

# initialize the backgroundSubtractor class
if ret is True:
    backSubtractor = BackGroundSubtractor(0.1,denoise(frame))
    run = True
else:
    run = False

while(run):

    # get the next frame
    ret, frame = cam.read()

    # if succesfully get the frame, 
    if ret is True:

        # Show filtered image
        cv2.imshow('input', denoise(frame))

        # get the foreground
        foreGround = backSubtractor.getForeground(denoise(frame))

        # Apply thresholding on the background and display the resulting mask
        ret, mask = cv2.threshold(foreGround, 15, 255, cv2.THRESH_BINARY)

        cv2.imshow('mask', mask)

        key = cv2.waitKey(10)

    else:
        break

    if key == 27:
        break

cam.release()
cv2.destroyAllWindows()