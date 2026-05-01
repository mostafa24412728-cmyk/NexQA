import os
import sys
from ultralytics import YOLO
import cv2

# Configuration
MODEL_PATH = "runs/wood_defects/train/weights/best.pt"
CLASS_NAMES_AR = [
    "كوارتزيت (Quartzity)", "عقدة حية (Live Knot)", "نخاع (Marrow)", 
    "راتنج (Resin)", "عقدة ميتة (Dead Knot)", "عقدة مشققة (Knot with Crack)", 
    "عقدة مفقودة (Knot missing)", "شرخ (Crack)"
]

def test_image(img_path):
    if not os.path.exists(MODEL_PATH):
        print(f"❌ Error: Model not found at {MODEL_PATH}")
        return

    print(f"🚀 Loading model: {MODEL_PATH}...")
    model = YOLO(MODEL_PATH)
    
    print(f"📸 Analyzing image: {img_path}...")
    img = cv2.imread(img_path)
    if img is None:
        print(f"❌ Error: Could not read image at {img_path}")
        return

    results = model.predict(img, conf=0.5) # High threshold for testing
    
    print("\n" + "="*40)
    print("      DETECTION RESULTS")
    print("="*40)
    
    found = False
    for result in results:
        for box in result.boxes:
            found = True
            cls_id = int(box.cls[0])
            conf = float(box.conf[0])
            name = CLASS_NAMES_AR[cls_id] if cls_id < len(CLASS_NAMES_AR) else f"Unknown ({cls_id})"
            print(f"📍 Found: {name:<30} | Confidence: {conf:.2%}")

    if not found:
        print("✅ No defects detected (Clean Wood)")
    
    print("="*40)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python test_cli.py <path_to_image>")
    else:
        test_image(sys.argv[1])
