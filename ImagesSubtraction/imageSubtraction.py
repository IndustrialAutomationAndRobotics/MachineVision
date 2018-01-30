
import numpy as np
import cv2

frame1 = cv2.imread(frame52.png)
frame2 = cv2.imread(frame65.png)

if frame1 is None:
    print("error: image not read")
    cv2.waitKey(0)


imgSubstract = frame2 - frame1

cv2.imshow('substract', imgSubstract)

cv2.waitKey(0)

