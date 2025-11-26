import numpy as np
import pandas as pd
import cv2
import matplotlib.pyplot as plt

MASTER_FILE = "/home/rahul/Documents/Image-processing/Image_data_for_Assessment_FPGA_Engineer_Digantara.csv"
TEST_FILE   = "/home/rahul/Documents/Image-processing/out.csv"

master = pd.read_csv(MASTER_FILE, header=None).values
test   = pd.read_csv(TEST_FILE, header=None).values

print("\n--- FILE SHAPE ---")
print("Master :", master.shape)
print("Test   :", test.shape)

# --------------------------------------------------
# AUTO-FIX SIZE MISMATCH (trim to min dimension)
# --------------------------------------------------
min_rows = min(master.shape[0], test.shape[0])
min_cols = min(master.shape[1], test.shape[1])

if master.shape != test.shape:
    print(f"\n⚠ Size mismatch detected — trimming to [{min_rows} x {min_cols}] for comparison")
    master = master[:min_rows, :min_cols]
    test   = test[:min_rows, :min_cols]
else:
    print("\n✓ Size matched, full comparison possible")

# --------------------------------------------------
total_pixels = master.size
matches = np.sum(master == test)
accuracy = (matches / total_pixels) * 100

mae = np.mean(np.abs(master-test))
mse = np.mean((master-test)**2)
psnr = float("inf") if mse == 0 else 20*np.log10(255/np.sqrt(mse))

print("\n--- RESULT ---")
print(f"Pixel Accuracy   : {accuracy:.5f} %")
print(f"MAE              : {mae:.5f}")
print(f"MSE              : {mse:.5f}")
print(f"PSNR             : {psnr:.5f} dB")

# --------------------------------------------------
# SAVE IMAGES FOR VISUAL REVIEW
# --------------------------------------------------
cv2.imwrite("master_trimmed.png", master.astype(np.uint8))
cv2.imwrite("test_trimmed.png", test.astype(np.uint8))
cv2.imwrite("difference_heatmap.png", np.abs(master-test).astype(np.uint8))

plt.figure(figsize=(14,5))
plt.subplot(1,3,1); plt.title("MASTER Trimmed"); plt.imshow(master,cmap='gray')
plt.subplot(1,3,2); plt.title("TEST Trimmed"); plt.imshow(test,cmap='gray')
plt.subplot(1,3,3); plt.title("Difference"); plt.imshow(np.abs(master-test),cmap='hot')
plt.show()
