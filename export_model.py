from ultralytics import YOLO
import os

model_path = "runs/wood_defects/train/weights/best.pt"
if not os.path.exists(model_path):
    model_path = "best.pt"

if os.path.exists(model_path):
    model = YOLO(model_path)
    model.export(format="tflite")
    print("Exported to TFLite successfully")
else:
    print(f"Model path {model_path} not found")
