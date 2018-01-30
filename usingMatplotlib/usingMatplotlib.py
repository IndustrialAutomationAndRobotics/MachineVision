import numpy as np
import cv2
from matplotlib import pyplot as plt

# Read image
# The flag values for imread are 1, 0, -1 for color, grayscale and unchanged respectively
img = cv2.imread('image.png',0)

# Check wether the image is read correctly
if img is None:
    print("Error: image not read from file \n\n")
    cv2.waitKey(0)
    cv2.destroyAllWindows()

# using pyplot to display image
# cmap -> Colormap, specify that we are showing grayscale image
#         cmap is ignored if image is 3-D, directly specifying RGB values
# interpolation -> we use bicubic, a bicubic interpolation over 4x4 pixel neighborhood
# more on interpolation algorithim : http://tanbakuchi.com/posts/comparison-of-openv-interpolation-algorithms/
# documentation : https://matplotlib.org/devdocs/api/_as_gen/matplotlib.pyplot.imshow.html
plt.imshow(img, cmap = 'gray', interpolation = 'nearest')
plt.xticks([]), plt.yticks([]) # to hide tick values on X and Y axis
plt.show()