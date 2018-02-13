import numpy as np
import cv2

haar_cascade_path = 'D:/invader/Documents/py/MachineVision/segmentationAndFaceDetection/CascadeFiles'
face_cascade = cv2.CascadeClassifier(haar_cascade_path + '/haarcascade_frontalface_alt.xml')

count = 1
cap = cv2.VideoCapture(0)

if cap.isOpened() == False:
    print("Error: capWebcam not accessed successfully \n")
    cv2cv2.destroyAllWindows()

while cv2.waitKey(1) != 27 and cap.isOpened():

    ret, frame = cap.read()

    if ret == False:
        break

    height, width, channels = frame.shape

    x1 = int(width/6)
    y1 = int(height/6)
    x2 = int(width-(width/6))
    y2 = int(height-(height/6))

    cv2.rectangle(frame,(x1,y1),(x2,y2),(255,255,255),3)

    frameROI = frame[y1:y2, x1:x2]
    faces = face_cascade.detectMultiScale(frameROI, 1.3, 5)

    cv2.putText(frame,"Faces Detected: ", (10,25), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1, 255)
    cv2.putText(frame,"{0}".format(len(faces)), (200,25), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1, 255)

    if count > 100:
        break
    else:
        cv2.putText(frame,"Frame Save: ", (10,50), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1, 255)
        cv2.putText(frame,"{0}".format(count), (200,50), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1, 255)

    for(x,y,w,h) in faces:
        cv2.rectangle(frameROI, (x,y),(x+w, y+h),(255,255,255),3)
        faceFrame = frameROI[y:y+h,x:x+h]
        cv2.imwrite("D:/invader/Documents/py/MachineVision/getFaceAndCentroid/output/frame%d.png" % count,faceFrame)
        count = count + 1

    
   
    cv2.imshow('frame', frame)
    cv2.imshow('frameROI', frameROI)

cap.release()
cv2.destroyAllWindows()