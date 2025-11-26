import numpy as np
import cv2

# ===========================
# CONFIG
# ===========================
RAW_IMAGE = "/home/rahul/Downloads/Assessment_FPGA_Engineer_Digantara/Raw_image_Fig1.jpg"
FPGA_OUTCSV = "/home/rahul/Documents/Image-processing/out.csv"
WIDTH = 3124
HEIGHT = 3030

print("\n=== Loading Original Image ===")
img = cv2.imread(RAW_IMAGE, cv2.IMREAD_GRAYSCALE)
assert img is not None, "❌ ERROR: Raw image not found!"

img_resized = cv2.resize(img, (WIDTH, HEIGHT))
cv2.imwrite("raw_resized.png", img_resized)
print("✔ raw_resized.png generated")

# ===========================
# CPU SOBEL REFERENCE
# ===========================
print("\n=== CPU SOBEL COMPUTING ===")
sobelx = cv2.Sobel(img_resized, cv2.CV_32F, 1, 0, ksize=3)
sobely = cv2.Sobel(img_resized, cv2.CV_32F, 0, 1, ksize=3)

cpu_mag = np.abs(sobelx) + np.abs(sobely)
cpu_sobel = np.clip(cpu_mag, 0, 255).astype(np.uint8)

cv2.imwrite("cpu_sobel.png", cpu_sobel)
print("✔ cpu_sobel.png generated")

# ===========================
# LOAD FPGA OUTPUT
# ===========================
print("\n=== Loading FPGA CSV ===")
with open(FPGA_OUTCSV) as f:
    text = f.read().replace("\n",",")
    arr = [x for x in text.split(",") if x.isdigit()]
    fpga_pixels = np.array(list(map(int, arr)), dtype=np.uint8)

if len(fpga_pixels) < WIDTH*HEIGHT:
    fpga_pixels = np.pad(fpga_pixels, (0, WIDTH*HEIGHT-len(fpga_pixels)))

fpga_sobel = fpga_pixels[:WIDTH*HEIGHT].reshape(HEIGHT, WIDTH)
cv2.imwrite("fpga_sobel.png", fpga_sobel)
print("✔ fpga_sobel.png generated")

# ===========================
# COMPARISON METRICS
# ===========================
print("\n=== Calculating Accuracy ===")

diff = cv2.absdiff(cpu_sobel, fpga_sobel)
cv2.imwrite("difference_map.png", diff)

pixel_match = np.sum(cpu_sobel == fpga_sobel)
accuracy = (pixel_match / (WIDTH*HEIGHT)) * 100

print(f"✔ Pixel Accuracy: {accuracy:.2f}%")
print("✔ difference_map.png generated (bright = mismatch)")

# ===========================
# SIDE BY SIDE OUTPUT IMAGE
# ===========================
comparison = np.hstack((cpu_sobel, fpga_sobel, diff))
cv2.imwrite("compare_cpu_vs_fpga.png", comparison)

print("\n==============================================")
print(" OUTPUTS GENERATED")
print(" 🔹 cpu_sobel.png")
print(" 🔹 fpga_sobel.png")
print(" 🔹 difference_map.png  (highlight mismatch)")
print(" 🔹 compare_cpu_vs_fpga.png  (side-by-side)")
print("==============================================\n")
