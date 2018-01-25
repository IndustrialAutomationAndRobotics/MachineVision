import numpy as py
import cv2

# Read image
# The flag values for imread are 1, 0, -1 for color, grayscale and unchanged respectively
img = cv2.imread('image.png',0)

# Check to see if the image is read correctly
if img is None:
    print("error: image not read from file \n\n")
    cv2.waitKey(0)

# Show image
cv2.namedWindow('image', cv2.WINDOW_NORMAL)
cv2.imshow('image',img)

# Save user input
userInput = cv2.waitKey(0)

# Check user input, wether they just want to exit or save and exit
if userInput == 27:
    cv2.destroyAllWindows()
elif userInput == ord('s'):
    cv2.imwrite('imageGray.png',img)
    cv2.destroyAllWindows()


