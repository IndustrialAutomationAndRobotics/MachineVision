import numpy as np
import cv2

cap = cv2.VideoCapture(0)

if cap.isOpened() == False:
    print("Error: capWebcam not accessed successfully \n")
    cv2cv2.destroyAllWindows()

while cv2.waitKey(1) != 27 and cap.isOpened():

    ret, frame = cap.read()

    if ret == False:
        break

    height, width, channels = frame.shape

    print(height,width,channels)

    x1 = int(width/6)
    y1 = int(height/6)
    x2 = int(width-(width/6))
    y2 = int(height-(height/6))

    cv2.rectangle(frame,(x1,y1),(x2,y2),(255,255,255),3)

    frameROI = frame[y1:y2, x1:x2]

    cv2.imshow('frame', frame)
    cv2.imshow('frameROI', frameROI)

cap.release()
cv2.destroyAllWindows()