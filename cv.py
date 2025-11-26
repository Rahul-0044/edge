import numpy as np
import cv2
import matplotlib.pyplot as plt

CSV = "/home/rahul/Documents/Image-processing/Image_data_for_Assessment_FPGA_Engineer_Digantara.csv"

# Expected - your actual image size
EXP_H = 3030
EXP_W = 3124

# ---------------------- LOAD CSV ------------------------
print("\n==============================")
print("  Loading flexible CSV image  ")
print("==============================")

img = np.loadtxt(CSV, delimiter=",", dtype=np.uint16)
print(f"Loaded shape → {img.shape}")

H, W = img.shape

# ---------------------- SIZE FIXING ----------------------
def fit_dim(val, expected):
    """Allow ±2 row/col mismatch"""
    if val == expected:
        return expected
    if abs(val - expected) <= 2:
        print(f"⚠ Dimension mismatch {val} vs {expected} → correcting to {expected}")
        return expected
    raise ValueError(f"❌ Size error — expected {expected}, got {val}")

H2 = fit_dim(H, EXP_H)
W2 = fit_dim(W, EXP_W)

# Trim or pad rows
if H > H2: img = img[:H2, :]
elif H < H2: img = np.pad(img, ((0,H2-H),(0,0)), constant_values=0)

# Trim or pad cols
if W > W2: img = img[:, :W2]
elif W < W2: img = np.pad(img, ((0,0),(0,W2-W)), constant_values=0)

print(f"✔ Final shape → {img.shape}")

img = img.astype(np.uint8)

# ---------------------- CANNY ----------------------------
blur = cv2.GaussianBlur(img,(5,5),1.0)
edges = cv2.Canny(blur,50,120)

# ---------------------- SHOW OUTPUT ----------------------
plt.figure(figsize=(12,6))
plt.subplot(1,2,1); plt.title("Original"); plt.imshow(img,cmap='gray'); plt.axis('off')
plt.subplot(1,2,2); plt.title("Canny Edge Output"); plt.imshow(edges,cmap='gray'); plt.axis('off')
plt.show()

cv2.imwrite("opencv_canny_result.png",edges)
print("\n==============================")
print(" SAVED → opencv_canny_result.png")
print("==============================\n")
