# # import numpy as np
# # import cv2

# # W, H = 3124, 3030

# # # Read CSV, allow non-numeric ('x') → become NaN, then replace with 0
# # raw = np.genfromtxt("out.csv", delimiter=",", dtype=float, filling_values=0.0)

# # # Replace NaNs (from 'x') with 0
# # raw = np.nan_to_num(raw, nan=0.0)

# # # Convert to uint8 image
# # sobel = raw.astype(np.uint8)

# # # Flatten and reshape to H×W (8 pixels per row written)
# # sobel = sobel.reshape(-1)[:H*W].reshape(H, W)

# # cv2.imwrite("fpga_output_edges.jpg", sobel)
# # print("DONE → fpga_output_edges.jpg")
# import numpy as np
# import cv2
# import matplotlib.pyplot as plt

# # ==============================
# # FILE PATHS (EDIT IF NEEDED)
# # ==============================
# INPUT_CSV   = "/home/rahul/Documents/Image-processing/Image_data_for_Assessment_FPGA_Engineer_Digantara.csv"
# FPGA_OUTCSV = "/home/rahul/Documents/Image-processing/out.csv"   # TB output
# WIDTH  = 3124
# HEIGHT = 3030

# # ==============================
# # LOAD RAW IMAGE CSV
# # ==============================
# print("Loading Image CSV...")
# pixels = np.loadtxt(INPUT_CSV, delimiter=",", dtype=np.uint8)

# if len(pixels) != WIDTH*HEIGHT:
#     raise ValueError(f"CSV pixels ≠ {WIDTH*HEIGHT}. Got {len(pixels)} instead!")

# # reshape into 2D image
# img = pixels.reshape(HEIGHT, WIDTH)
# print("✔ Image Loaded & Reshaped:", img.shape)

# # ==============================
# # CPU REFERENCE PROCESSING
# # ==============================

# # Gaussian 5x5 (same kernel as FPGA)
# gauss_kernel = np.array([
#     [1,  4,  6,  4, 1],
#     [4, 16, 24, 16, 4],
#     [6, 24, 36, 24, 6],
#     [4, 16, 24, 16, 4],
#     [1,  4,  6,  4, 1]
# ], dtype=np.float32) / 256

# gaussed = cv2.filter2D(img, -1, gauss_kernel)

# # Sobel 3×3 (FPGA version uses |Gx|+|Gy|)
# sobelx = cv2.Sobel(gaussed, cv2.CV_32F, 1, 0, ksize=3)
# sobely = cv2.Sobel(gaussed, cv2.CV_32F, 0, 1, ksize=3)

# mag = np.abs(sobelx) + np.abs(sobely)
# cpu_edges = np.where(mag > 40, 255, 0).astype(np.uint8)   # same FPGA threshold

# print("✔ CPU Edge Reference Generated")

# # ==============================
# # LOAD FPGA OUTPUT CSV
# # ==============================
# print("Loading FPGA output file...")
# fpga_pixels = np.loadtxt(FPGA_OUTCSV, delimiter=",", dtype=np.uint8)
# if len(fpga_pixels) != WIDTH*HEIGHT:
#     print(f"⚠ Warning: FPGA output count mismatch ({len(fpga_pixels)}) expected {WIDTH*HEIGHT}")

# fpga_edges = fpga_pixels.reshape(HEIGHT, WIDTH)

# # ==============================
# # DISPLAY COMPARISON
# # ==============================
# plt.figure(figsize=(15,10))
# plt.subplot(1,3,1); plt.title("RAW IMAGE");    plt.imshow(img,cmap='gray'); plt.axis('off')
# plt.subplot(1,3,2); plt.title("CPU Sobel Edge"); plt.imshow(cpu_edges,cmap='gray'); plt.axis('off')
# plt.subplot(1,3,3); plt.title("FPGA Output Edge"); plt.imshow(fpga_edges,cmap='gray'); plt.axis('off')
# plt.show()

# # OPTIONAL → save images
# cv2.imwrite("cpu_edges.png", cpu_edges)
# cv2.imwrite("fpga_edges.png", fpga_edges)

# print("\n===============================================")
# print(" Visualization Complete")
# print(" CPU Edge → cpu_edges.png")
# print(" FPGA Edge → fpga_edges.png")
# print("===============================================\n")


import numpy as np
import cv2
import matplotlib.pyplot as plt

FPGA_OUTCSV = "/home/rahul/Documents/Image-processing/tmp.csv"
WIDTH  = 3124
HEIGHT = 3030

print("\n======================================")
print("   Reading FPGA CSV safely...")
print("======================================")

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
print("\n======================================")
print(" Image Saved → fpga_output_image.png")
print("======================================\n")
