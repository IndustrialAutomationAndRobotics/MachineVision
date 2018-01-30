
import numpy as np
import cv2

# capture video
# The index use to select camera
# If only one camera exist, use 0
# Second camera can be selected by passing 1 and so on
cap = cv2.VideoCapture(0)

# Check wether the webcam can be access or not
if cap.isOpened() == False:
    print("Error: capWebcam not accessed successfully \n\n")
    cv2.waitKey(0)
    cv2.destroyAllWindows()

# Run this until the user press Esc or webcam connection lost
while cv2.waitKey(1) != 27 and cap.isOpened():

    # Capture frame by frame
    # read returns boolean value and the image
    ret, frame = cap.read()

    # Change it to grayscale
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Display the resulting frame
    cv2.imshow('frame', gray)
    
# When everything is done, release the capture
cap.release()
cv2.destroyAllWindows()


