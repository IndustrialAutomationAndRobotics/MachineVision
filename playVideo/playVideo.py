

import numpy as np
import cv2

# capture video
# change the camera index to the vedio file name to play a video
cap = cv2.VideoCapture('vid.avi')

# Check wether can open video or not
if cap.isOpened() == False:
    print("Error reading video file")
    cv2.waitKey(0)
    cv2.destroyAllWindows()

# Run this until user press Esc or the video has ended
while cv2.waitKey(2) != 27 and cap.isOpened():

    # Capture frame by frame
    # read returns boolean value and the image
    ret, frame = cap.read()

    # Break loop if there are no frame read
    if ret == False:
        break

    # Change it to grayscale
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Display the resulting frame
    cv2.imshow('frame', gray)
    
# When everything is done, release the capture
cap.release()
cv2.destroyAllWindows()