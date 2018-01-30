

import numpy as np
import cv2

count = 1

cap = cv2.VideoCapture(0)

if cap.isOpened() == False:
    print("Error: cap not accessed successfully \n\n")
    cv2.waitKey(0)
    cv2.destroyAllWindows()

while cv2.waitKey(1) != 27 and cap.isOpened():

    ret, frame = cap.read()

    cv2.imshow('frame', frame)

    count = count + 1
    
    countString = str(count)

    cv2.imwrite("frame%d.png" % count,frame)
    print("capture frame %d" % count)

cap.release()
cv2.destroyAllWindows()