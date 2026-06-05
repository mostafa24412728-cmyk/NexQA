---
title: NexQA Expert Engine
emoji: 🪵
colorFrom: amber
colorTo: orange
sdk: docker
pinned: false
license: mit
app_port: 7860
---

# 🪵 NexQA Expert Engine

**نظام ذكاء اصطناعي لفحص جودة الأخشاب ومختبر خلط الدهانات**

## الميزات
- 🔍 **فحص عيوب الخشب** باستخدام YOLOv8
- 🎨 **مختبر الدهانات** — استخراج اللون وتوليد وصفة الخلط
- 📋 **سجل الألوان** — حفظ كل لون مع وصفته الكاملة
- 🔐 **نظام تسجيل دخول** للمصانع

## API Endpoints
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/predict` | POST | فحص صورة خشب |
| `/api/color-recipe` | POST | استخراج لون + وصفة |
| `/api/color-history` | GET | سجل الألوان |
| `/api/signup` | POST | تسجيل مصنع |
| `/api/login` | POST | تسجيل دخول |
