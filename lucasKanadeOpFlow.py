import numpy as np
import cv2

cap = cv2.VideoCapture("D:/invader/Workspace/MachineVision/sample/awan.mp4")

ret, frame = cap.read()
gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

corners = cv2.goodFeaturesToTrack(gray, mask=None, maxCorners=100, qualityLevel=0.3, minDistance=7, blockSize=7)
cornerColors = np.random.randint(0, 255, (corners.shape[0],3))

mask = np.zeros_like(frame)

lkParameters = dict(winSize=(15,15), maxLevel=2, criteria=(cv2.TERM_CRITERIA_COUNT | cv2.TERM_CRITERIA_EPS, 10, 0.03))

while True:

    previousGray = gray
    previousCorners = corners.reshape(-1,1,2)

    ret, frame = cap.read()

    if ret:

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        corners, st, err = cv2.calcOpticalFlowPyrLK(previousGray, gray, previousCorners, None, **lkParameters)

        corners = corners[st == 1]

        previousCorners = previousCorners[st == 1]
        #cornerColors[st == 1]

        if corners.shape[0] == 0:
            print('Stopping. There are no corners left to track')
            break

        for i in range(corners.shape[0]):
            x,y = corners[i]
            xPrev, yPrev = previousCorners[i]
            color = cornerColors[i].tolist()
            frame = cv2.circle(frame, (x,y), 5, color, -1)
            mask = cv2.line(mask, (x, y), (xPrev, yPrev), color, 2)
        frame = cv2.add(frame,mask)

        cv2.imshow('optical flow', frame)
        k = cv2.waitKey(100) & 0xff

        
        if k == 27:
            break

    else:

        break

cap.release()
cv2.destroyAllWindows()