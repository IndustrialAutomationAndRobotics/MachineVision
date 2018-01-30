

import numpy as np
import cv2
import os

# Create the directory to save the frame
# Enter the absolute path where you want to create
# the folder, if you copy the path from windows
# change the slashes from \ to /
path = 'D:/invader/Documents/py/Sample/getFrame/frame'

# Creating the directory, the exist_ok is change to true
# so that this line will not give error if the directory
# already exist
os.makedirs(path, exist_ok=True)

# use to initialize the frame count
count = 1

# get vedio from our webcam or pass in video files
cap = cv2.VideoCapture(0)

# check wether the webcam can be accessed or not
if cap.isOpened() == False:
    print("Error: cap not accessed successfully \n\n")
    cv2.waitKey(0)
    cv2.destroyAllWindows()

# get frame until user press ESC key or the webcam is closed
while cv2.waitKey(1) != 27 and cap.isOpened():

    # retrieve the frame
    ret, frame = cap.read()

    # check wether the frame is retrieve or not
    if ret == False:
        break

    # Show the frame
    cv2.imshow('frame', frame)

    # Save the current frame
    cv2.imwrite(path + "/frame%d.png" % count,frame)

    # Show in the console the current number of frame is save in the file
    print("capture frame %d save in %s" % (count,path))

    # Increase the count for next save
    count = count + 1

# release the webcam or video
cap.release()
cv2.destroyAllWindows()