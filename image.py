

import numpy as np
import cv2
import matplotlib.pyplot as plt

FPGA_OUTCSV = "/home/rahul/Documents/Image-processing/out.csv"
WIDTH  = 3124
HEIGHT = 3030

print("   Reading FPGA CSV safely...")


# -------- SAFE LOAD FIX --------
with open(FPGA_OUTCSV) as f:
    text = f.read().replace("\n",",")
    raw  = text.split(",")
    clean = [x for x in raw if x.strip().isdigit()]      # remove empty/invalid
    pixels = np.array(list(map(int, clean)), dtype=np.uint8)

print(f"✔ Loaded {len(pixels)} values")

if len(pixels) != WIDTH*HEIGHT:
    print(f"⚠ Pixel mismatch {len(pixels)}/{WIDTH*HEIGHT}, resizing anyway...")

img = pixels[:WIDTH*HEIGHT].reshape(HEIGHT,WIDTH)
print("✔ Reconstruct complete →", img.shape)

# -------- Display Image --------
plt.figure(figsize=(10,10))
plt.title("FPGA RESULT IMAGE")
plt.imshow(img,cmap='gray')
plt.axis('off')
plt.show()

cv2.imwrite("fpga_output_image.png", img)

print(" Image Saved → fpga_output_image.png")

