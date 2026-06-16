import os
from ultralytics import YOLO

def main():
    print("=" * 50)
    print("🚀 بدء تجهيز وتدريب نموذج كمبيوتر فيجن لعيوب الخشب")
    print("=" * 50)
    
    # 1. التأكد من وجود الداتا
    dataset_yaml = "Wood defect detection.v1i.yolov8/data.yaml"
    if not os.path.exists(dataset_yaml):
        print("❌ لم يتم العثور على داتا التدريب!")
        print("يرجى تحميل الداتا (YOLOv8 format) ووضعها في مجلد باسم 'Wood defect detection.v1i.yolov8'")
        print("وتأكد من وجود ملف data.yaml بداخل المجلد.")
        print("\nلتحميل داتا احترافية مجاناً:")
        print("1. اذهب إلى: https://universe.roboflow.com/search?q=wood%20defect")
        print("2. اختر أي Dataset تعجبك.")
        print("3. اضغط Download Dataset بصيغة YOLOv8.")
        print("4. فك الضغط في المجلد في هذا المسار.")
        return

    print(f"✅ تم العثور على ملف الداتا: {dataset_yaml}")
    print("⏳ جاري تهيئة الموديل YOLOv8 (النسخة Nano / Small)...")
    
    # 2. تحميل الموديل المبدئي
    # نستخدم yolov8s.pt لأنه يوازن بين الدقة العالية وسرعة الاستنتاج للموبايل
    model = YOLO('yolov8n.pt') 

    print("🔥 بدء التدريب (Training)...")
    print("تم إيقاف الإعدادات الثقيلة لتسريع التدريب على جهازك المحلي.")
    
    # 3. إعدادات التدريب السريعة
    model.train(
        data=dataset_yaml,
        epochs=50,                  # عدد دورات التدريب
        imgsz=320,                  # تقليل حجم الصورة لتسريع المعالجة
        batch=16,                   # حجم الدفعة
        name='wood_defect_model_fast', # اسم الموديل الناتج
        workers=0,                  # حل مشكلة تعليق التدريب في نظام ويندوز
        device=0,                   # استخدام كارت الشاشة (GPU) للتدريب
        # === تم تعطيل Data Augmentation الثقيلة لتقليل العبء على الـ CPU والـ GPU ===
        mosaic=0.0,
        mixup=0.0,
        copy_paste=0.0,
        degrees=0.0,
        translate=0.0,
        scale=0.0,
        shear=0.0,
        perspective=0.0,
        fliplr=0.0,
        flipud=0.0,
        hsv_h=0.0,
        hsv_s=0.0,
        hsv_v=0.0
    )
    
    print("\n✅ تم التدريب بنجاح!")
    print("الآن يوجد مجلد جديد باسم 'runs/detect/wood_defect_model/weights/'")
    print("انسخ ملف 'best.pt' منه والصقه في المجلد الرئيسي للمشروع ليعمل النظام به.")

if __name__ == '__main__':
    main()
