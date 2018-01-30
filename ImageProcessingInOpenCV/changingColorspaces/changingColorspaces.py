
import cv2
import numpy as np

capWebcam = cv2.VideoCapture(0)

if capWebcam.isOpened() == False:
    print("Error: capWebcam not accessed successfully \n\n")
    cv2.waitKey(0)
    cv2.destroyAllWindow()

while cv2.waitKey(1) != 27 and capWebcam.isOpened():

    # Get each frame
    blnFrameReadSuccessfully, imgOriginal = capWebcam.read()

    # Check if frame is get successfully
    if not blnFrameReadSuccessfully or imgOriginal is None:
        print("Error: frame not read from webcam\n")
        cv2.waitKey(0)
        break

    # Convert BGR to HSV
    imgHSV = cv2.cvtColor(imgOriginal, cv2.COLOR_BGR2HSV)

    # Define range of blue color in HSV
    lower_blue = np.array([110,50,50])
    upper_blue = np.array([130,255,255])

    # Threshold the HSV image to get only blue colors
    mask = cv2.inRange(imgHSV, lower_blue, upper_blue)

    # Bitwise-AND mask and original image
    res = cv2.bitwise_and(imgOriginal, imgOriginal, mask= mask)

    cv2.imshow('frame', imgOriginal)
    cv2.imshow('mask', mask)
    cv2.imshow('res', res)

capWebcam.release()
cv2.destroyAllWindows()

