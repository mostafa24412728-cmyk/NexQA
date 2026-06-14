import os
import base64
import json
import datetime
import requests
from flask import Flask, render_template, request, jsonify, send_from_directory, redirect
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from pathlib import Path
from PIL import Image as PILImage
from dotenv import load_dotenv
# NOTE: ultralytics, cv2, numpy, google.generativeai are imported lazily inside
#       get_model() / get_gemini() to reduce startup RAM on Railway free tier.

# --- CONFIGURATION ---
load_dotenv()
app = Flask(__name__)
CORS(app)

# استخدام PostgreSQL على Railway أو SQLite محلياً
_db_url = os.getenv('DATABASE_URL', 'sqlite:///wood_defects.db')
# Railway بيرجع postgres:// لكن SQLAlchemy بيحتاج postgresql://
if _db_url.startswith('postgres://'):
    _db_url = _db_url.replace('postgres://', 'postgresql://', 1)
app.config['SQLALCHEMY_DATABASE_URI'] = _db_url
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

UPLOAD_FOLDER = 'static/uploads'
Path(UPLOAD_FOLDER).mkdir(parents=True, exist_ok=True)

# --- EXPERT KNOWLEDGE BASE ---
DEFECT_KNOWLEDGE = {
    "knot": {
        "desc": "عقدة طبيعية ناتجة عن نمو الأغصان.",
        "impact": "تؤدي لتغيير اتجاه الألياف مما قد يقلل من قوة الشد في هذه المنطقة."
    },
    "dead_knot": {
        "desc": "عقدة ميتة (سوداء) منفصلة عن أنسجة الخشب المحيطة.",
        "impact": "عالية الخطورة؛ قد تسقط وتترك فجوة، مما يضعف الهيكل الإنشائي ويشوه المظهر."
    },
    "knot_with_crack": {
        "desc": "عقدة مصابة بتشققات داخلية أو حولها.",
        "impact": "تؤدي لضعف شديد واحتمالية انكسار اللوح عند تعرضه لأحمال ميكانيكية."
    },
    "crack": {
        "desc": "تشقق طولي في ألياف الخشب نتيجة الجفاف أو الإجهاد.",
        "impact": "يقلل من متانة اللوح بشكل كبير ويسمح بنفاذ الرطوبة والحشرات للداخل."
    },
    "mold": {
        "desc": "نمو فطري على سطح الخشب.",
        "impact": "يؤدي لتلف الألياف بمرور الوقت وقد يسبب مشاكل صحية وتغير في اللون."
    }
}

# --- MODELS (Lazy Loading — يُحمَّل عند أول طلب لتوفير RAM) ---
print("🚀 [VERIFIED VERSION 2.1] Starting NexQA Expert Engine...")
_model = None
_gemini_model = None

def get_model():
    global _model
    if _model is None:
        print("⏳ Loading YOLO model...")
        from ultralytics import YOLO
        _model = YOLO('best.pt')
        print("✅ YOLO Model Loaded Successfully.")
    return _model

def get_gemini():
    global _gemini_model
    if _gemini_model is None:
        import google.generativeai as genai
        genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
        _gemini_model = genai.GenerativeModel('gemini-1.5-flash')
    return _gemini_model

class ProductRecord(db.Model):
    id = db.Column(db.String(50), primary_key=True)
    image_base64 = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(20), nullable=False)
    confidence = db.Column(db.Float, nullable=False)
    defect_type = db.Column(db.String(100), nullable=False)
    buyer = db.Column(db.String(100))
    shipping = db.Column(db.String(100))
    inspected_at = db.Column(db.String(50))

class FactoryUser(db.Model):
    id            = db.Column(db.Integer, primary_key=True)
    factory_name  = db.Column(db.String(100), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)

class ColorRecord(db.Model):
    id              = db.Column(db.String(50), primary_key=True)
    image_base64    = db.Column(db.Text, nullable=False)
    hex_code        = db.Column(db.String(10), nullable=False)
    r               = db.Column(db.Integer, nullable=False)
    g               = db.Column(db.Integer, nullable=False)
    b               = db.Column(db.Integer, nullable=False)
    color_name      = db.Column(db.String(100), nullable=False)
    recipe_markdown = db.Column(db.Text, nullable=False)
    created_at      = db.Column(db.String(50))

with app.app_context():
    db.create_all()


# --- ROUTES ---
@app.route('/')
def index():
    return "<h1>🚀 NexQA Expert Engine is Running</h1>"

# ── المصادقة ──────────────────────────────────────────────────────────
import hashlib

def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

@app.route('/api/signup', methods=['POST'])
def api_signup():
    try:
        data         = request.get_json()
        factory_name = data.get('factory_name', '').strip()
        password     = data.get('password', '')

        if not factory_name or not password:
            return jsonify({"success": False, "message": "اسم المصنع وكلمة المرور مطلوبان"}), 400

        existing = FactoryUser.query.filter_by(factory_name=factory_name).first()
        if existing:
            return jsonify({"success": False, "message": "اسم المصنع مسجّل مسبقاً"}), 409

        user = FactoryUser(
            factory_name  = factory_name,
            password_hash = hash_password(password),
        )
        db.session.add(user)
        db.session.commit()
        return jsonify({"success": True, "message": "تم إنشاء الحساب بنجاح", "factory_name": factory_name})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

@app.route('/api/login', methods=['POST'])
def api_login():
    try:
        data         = request.get_json()
        factory_name = data.get('factory_name', '').strip()
        password     = data.get('password', '')

        user = FactoryUser.query.filter_by(
            factory_name  = factory_name,
            password_hash = hash_password(password),
        ).first()

        if not user:
            return jsonify({"success": False, "message": "اسم المصنع أو كلمة المرور غير صحيحة"}), 401

        return jsonify({"success": True, "message": "تم تسجيل الدخول بنجاح", "factory_name": factory_name})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

@app.route('/api/predict', methods=['POST'])
def api_predict():
    if 'image' not in request.files:
        return jsonify({"success": False, "message": "No image"}), 400
    
    file = request.files['image']
    img_path = Path(UPLOAD_FOLDER) / f"mob_{file.filename}"
    file.save(img_path)
    
    results = get_model().predict(img_path, conf=0.15, verbose=False)
    
    yolo_detections = []
    expert_report = []
    
    for r in results:
        for box in r.boxes:
            label = get_model().names[int(box.cls[0])]
            conf = float(box.conf[0])
            yolo_detections.append(label)
            
            # Get Expert Knowledge
            info = DEFECT_KNOWLEDGE.get(label.lower(), {
                "desc": f"تم اكتشاف {label} بواسطة نظام الرؤية.",
                "impact": "يؤثر على جودة المنتج النهائي."
            })
            
            expert_report.append({
                "name": label,
                "description": info["desc"],
                "impact": info["impact"],
                "confidence": conf
            })

    if not yolo_detections:
        final_status = "passed"
        expert_report = [{
            "name": "None",
            "description": "الخشب سليم تماماً ومطابق للمواصفات القياسية.",
            "impact": "لا يوجد أي تأثير سلبي؛ اللوح جاهز للاستخدام الإنشائي.",
            "confidence": 1.0
        }]
    else:
        final_status = "rejected"

    # Gemini Fallback (Optional)
    try:
        image_pil = PILImage.open(img_path)
        prompt = f"خبير جودة. الموديل وجد: {yolo_detections}. اشرح التأثير الفني باختصار JSON."
        gemini_resp = get_gemini().generate_content([prompt, image_pil], request_options={"timeout": 5})
        import re
        json_match = re.search(r'\{.*\}', gemini_resp.text, re.DOTALL)
        if json_match and yolo_detections:
             # If Gemini works, we can enrich the report
             pass 
    except Exception as e:
        print(f"⚠️ Gemini Skipped: {e}")

    # Plot Detections
    import cv2
    import numpy as np
    res = results[0]
    processed_img = res.plot()
    _, buffer = cv2.imencode('.jpg', processed_img)
    encoded_string = base64.b64encode(buffer).decode('utf-8')
    
    record_id = f"#{db.session.query(ProductRecord).count() + 1}"
    new_record = ProductRecord(
        id=record_id, image_base64=encoded_string, status=final_status,
        confidence=expert_report[0]['confidence'], defect_type=expert_report[0]['name'],
        buyer="NexQA Final Verified Station", shipping="Air Cargo",
        inspected_at=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    )
    db.session.add(new_record)
    db.session.commit()

    return jsonify({
        "success": True, "status": final_status, "data": expert_report,
        "image_base64": encoded_string, "id": record_id,
        "buyer": new_record.buyer, "shipping": new_record.shipping
    })

@app.route('/api/history', methods=['GET'])
def api_history():
    records = ProductRecord.query.order_by(ProductRecord.inspected_at.desc()).all()
    return jsonify({"success": True, "history": [
        {"id": r.id, "status": r.status, "confidence": r.confidence, "defect_type": r.defect_type, 
         "buyer": r.buyer, "shipping": r.shipping, "inspected_at": r.inspected_at, "image_base64": r.image_base64} 
        for r in records
    ]})

# ─────────────────────────────────────────────────────
#  COLOR RECIPE — مختبر مزج الدهانات الذكي
# ─────────────────────────────────────────────────────

COLOR_NAMES_AR = [
    # (r, g, b, arabic_name, english_name)
    (255, 255, 255, "أبيض نقي",        "Pure White"),
    (0,   0,   0,   "أسود عميق",       "Deep Black"),
    (139, 90,  43,  "بني خشبي دافئ",  "Warm Wood Brown"),
    (101, 67,  33,  "بني داكن",        "Dark Brown"),
    (160, 120, 60,  "بيج خشبي",        "Wood Beige"),
    (210, 180, 140, "تان فاتح",         "Light Tan"),
    (205, 133, 63,  "بيرو ذهبي",       "Golden Peru"),
    (245, 222, 179, "قمحي فاتح",       "Wheat Light"),
    (222, 184, 135, "بسكويتي",          "Bisque"),
    (188, 143, 143, "وردي محترق",      "Rosy Brown"),
    (255, 228, 196, "لوز فاتح",        "Almond Light"),
    (128, 0,   0,   "أحمر كستنائي",   "Maroon Red"),
    (165, 42,  42,  "بني أحمر",        "Brownish Red"),
    (220, 20,  60,  "أحمر قرمزي",     "Crimson Red"),
    (255, 165, 0,   "برتقالي ذهبي",   "Golden Orange"),
    (255, 215, 0,   "ذهبي لامع",       "Bright Gold"),
    (255, 255, 0,   "أصفر صافٍ",      "Pure Yellow"),
    (154, 205, 50,  "أخضر زيتي",      "Olive Green"),
    (34,  139, 34,  "أخضر غابات",     "Forest Green"),
    (0,   128, 128, "فيروزي كلاسيك",  "Classic Teal"),
    (70,  130, 180, "أزرق فولاذي",    "Steel Blue"),
    (25,  25,  112, "أزرق ليلي",      "Midnight Blue"),
    (128, 0,   128, "بنفسجي ملكي",    "Royal Purple"),
    (192, 192, 192, "فضي رمادي",      "Silver Gray"),
    (128, 128, 128, "رمادي متوسط",    "Medium Gray"),
    (64,  64,  64,  "رمادي داكن",     "Dark Gray"),
    (255, 248, 220, "كريمي دافئ",     "Warm Cream"),
    (250, 240, 230, "بيج ناعم",        "Soft Beige"),
    (240, 230, 140, "أصفر خاكي",      "Khaki Yellow"),
    (107, 142, 35,  "أخضر زيتون",     "Olive Drab"),
]


def get_dominant_color(img_path: str, n_clusters: int = 3):
    """استخرج اللون المسيطر من الصورة بدون sklearn."""
    import numpy as np
    img = PILImage.open(img_path).convert("RGB")
    img = img.resize((150, 150))  # تصغير للسرعة
    pixels = np.array(img).reshape(-1, 3).astype(np.float32)

    # K-Means يدوي بسيط باستخدام numpy
    np.random.seed(42)
    idx = np.random.choice(len(pixels), n_clusters, replace=False)
    centers = pixels[idx].copy()

    for _ in range(20):
        dists = np.linalg.norm(pixels[:, None] - centers[None, :], axis=2)
        labels = np.argmin(dists, axis=1)
        new_centers = np.array([
            pixels[labels == k].mean(axis=0) if (labels == k).any() else centers[k]
            for k in range(n_clusters)
        ])
        if np.allclose(centers, new_centers, atol=1):
            break
        centers = new_centers

    counts = np.bincount(labels, minlength=n_clusters)
    dominant = centers[np.argmax(counts)].astype(int)
    return int(dominant[0]), int(dominant[1]), int(dominant[2])


def rgb_to_hex(r, g, b):
    return f"#{r:02X}{g:02X}{b:02X}"


def find_color_name_ar(r, g, b):
    """أقرب اسم عربي للون المستخرج."""
    min_dist = float('inf')
    best = ("لون مخصص", "Custom Color")
    for cr, cg, cb, ar_name, en_name in COLOR_NAMES_AR:
        d = ((r - cr) ** 2 + (g - cg) ** 2 + (b - cb) ** 2) ** 0.5
        if d < min_dist:
            min_dist = d
            best = (ar_name, en_name)
    return best[0], best[1]


def build_gemini_paint_prompt(hex_code, r, g, b, color_name_ar):
    return f"""أنت مهندس كيميائي وخبير محترف في تركيب وخلط دهانات الأخشاب في مصنع ذكي.
مهمتك هي استقبال بيانات اللون المستخرج من صورة رفعها المستخدم، وتحويلها إلى "وصفة خلط وتقريب" دقيقة وعملية يستطيع فني أو عامل الدهانات تنفيذها فوراً في الورشة.

[المدخلات الحالية]:
- كود اللون المستخرج (HEX): {hex_code}
- قيم اللون الرقمية (RGB): R={r}, G={g}, B={b}
- الاسم التجاري التقريبي للون: {color_name_ar}

[التعليمات والشروط الصارمة للصياغة]:
1. اللغة: يجب أن تكون الإجابة باللغة العربية، بأسلوب تقني ومباشر يناسب عمال ومصممي الأثاث والدهانات.
2. نظام الخلط: افترض أن العامل يمتلك الصبغات الأساسية للدهانات (قاعدة بيضاء/شفافة، مركزات صبغة: أحمر، أصفر، أزرق، أسود، بني).
3. طبيعة السطح (الخشب): ضع في الحسبان أن اللون سيُطبق على أسطح خشبية. إذا كان اللون يحتاج بطانة معينة (معجون أو سيلر) ليظهر بشكل صحيح، اذكر ذلك باختصار.
4. التقسيم التلقائي: قسّم الإجابة إلى أقسام واضحة ومحددة ومناسبة للعرض على شاشة الموبايل دون رغي أو مقدمات طويلة.

[صيغة المخرجات المطلوبة بدقة]:
توقع مخرجاً بتنسيق Markdown يحتوي على العناصر التالية فقط:

### 🎨 تفاصيل اللون المطلوب
- **الاسم التقريبي:** [اسم اللون]
- **كود اللون المعتمد:** {hex_code}

### 🧪 وصفة التركيب والخلط (النسب التقريبية)
- **القاعدة الأساسية (Base):** [مثال: 80% دهان أبيض أو شفاف]
- **المنشطات والصبغات المضافة:**
  - صبغة [اللون الأول]: [النسبة المئوية أو عدد النقاط لـ 1 لتر]
  - صبغة [اللون الثاني]: [النسبة المئوية]
  *(ملاحظة: مجموع النسب الكلية = 100%)*

### 🛠️ خطوات التنفيذ للعامل
1. [خطوة 1: تجهيز السطح أو البطانة]
2. [خطوة 2: إضافة الصبغات تدريجياً للتقليب]
3. [خطوة 3: نصيحة ذكية لتجربة اللون وتعديله]"""


def generate_fallback_recipe(hex_code, r, g, b, color_name_ar):
    # Determine base
    brightness = (r + g + b) / 3
    if brightness > 180:
        base_desc = "90% دهان أساس أبيض (White Base)"
        remaining = 10
    else:
        base_desc = "85% دهان أساس شفاف (Clear Base/Binder)"
        remaining = 15
    
    # Simple pigment calculation based on RGB
    pigments = []
    
    # Calculate black/darkness contribution
    black_pct = max(0, int((255 - max(r, g, b)) / 255 * remaining))
    
    # Calculate color contributions
    r_diff = max(0, r - min(r, g, b))
    g_diff = max(0, g - min(r, g, b))
    b_diff = max(0, b - min(r, g, b))
    total_diff = r_diff + g_diff + b_diff
    
    if total_diff > 0:
        red_factor = r_diff / total_diff
        green_factor = g_diff / total_diff
        blue_factor = b_diff / total_diff
    else:
        red_factor = green_factor = blue_factor = 0
        
    color_rem = remaining - black_pct
    
    # Heuristic for wood pigments: Brown, Yellow, Red, Blue, Black
    # Brown is usually high R, medium G, low B
    is_wood_tone = (r > g) and (g > b) and (r - b > 30)
    
    if is_wood_tone:
        brown_pct = int(color_rem * 0.7)
        yellow_pct = int(color_rem * 0.2)
        red_pct = color_rem - brown_pct - yellow_pct
        if brown_pct > 0:
            pigments.append(f"صبغة بني (Wood Brown): {brown_pct}%")
        if yellow_pct > 0:
            pigments.append(f"صبغة أصفر (oxide yellow): {yellow_pct}%")
        if red_pct > 0:
            pigments.append(f"صبغة أحمر (oxide red): {red_pct}%")
    else:
        # Standard colors
        red_pct = int(color_rem * red_factor)
        blue_pct = int(color_rem * blue_factor)
        yellow_pct = color_rem - red_pct - blue_pct
        
        if red_pct > 0:
            pigments.append(f"صبغة أحمر أساسي: {red_pct}%")
        if yellow_pct > 0:
            pigments.append(f"صبغة أصفر أساسي: {yellow_pct}%")
        if blue_pct > 0:
            pigments.append(f"صبغة أزرق أساسي: {blue_pct}%")
            
    if black_pct > 0:
        pigments.append(f"صبغة أسود (Carbon Black): {black_pct}%")
        
    # If no pigments added, add a tiny bit of brown or black
    if not pigments:
        pigments.append("صبغة بني (Wood Brown): 2%")
        pigments.append("صبغة أصفر (oxide yellow): 1%")

    pigments_str = "\n".join([f"  - {p}" for p in pigments])

    # Steps based on color type
    if is_wood_tone:
        step1 = "تجهيز السطح الخشبي بالسنفرة الجيدة (حبيبات 180 ثم 320) وتنظيفه من الأتربة."
        step2 = "خلط المكونات تدريجياً بدءاً من القاعدة الشفافة، ثم إضافة صبغة البني أولاً، تليها الأصفر والأحمر للحصول على درجة الخشب المطلوبة."
        step3 = "قم بتجربة اللون على قطعة خشبية صغيرة خارجية (عينة) واتركها تجف تماماً لرؤية الدرجة النهائية قبل الطلاء الكامل."
    else:
        step1 = "تجهيز السطح الخشبي وسد المسام باستخدام معجون الأخشاب المناسب وسنفرته جيداً."
        step2 = "إضافة الصبغات تدريجياً للدهان الأساس المختار مع التقليب المستمر حتى يتجانس الخليط بالكامل."
        step3 = "قارن درجة عينة مجففة باللون المطلوب تحت إضاءة طبيعية، وأضف صبغة سوداء بحذر شديد إذا أردت تعميق اللون."

    markdown = f"""### 🎨 تفاصيل اللون المطلوب
- **الاسم التقريبي:** {color_name_ar or 'درجة خشبية مميزة'}
- **كود اللون المعتمد:** {hex_code}

### 🧪 وصفة التركيب والخلط (النسب التقريبية)
- **القاعدة الأساسية (Base):** {base_desc}
- **المنشطات والصبغات المضافة:**
{pigments_str}
  *(ملاحظة: مجموع النسب الكلية = 100%)*

### 🛠️ خطوات التنفيذ للعامل
1. {step1}
2. {step2}
3. {step3}"""
    return markdown

@app.route('/api/color-recipe', methods=['POST'])
def api_color_recipe():
    """استخرج اللون المسيطر من صورة وأنشئ وصفة خلط دهانات بالعربية."""
    try:
        r_val = g_val = b_val = None
        hex_code = color_name_ar = None
        encoded_string = ""

        # ── مسار 1: صورة مرفوعة ──────────────────────────────────────
        if 'image' in request.files:
            file = request.files['image']
            
            # Read bytes to encode to base64
            file_bytes = file.read()
            encoded_string = base64.b64encode(file_bytes).decode('utf-8')
            
            # Reset file pointer and save to disk
            file.seek(0)
            img_path = Path(UPLOAD_FOLDER) / f"color_{file.filename}"
            file.save(img_path)
            
            r_val, g_val, b_val = get_dominant_color(str(img_path))
            hex_code = rgb_to_hex(r_val, g_val, b_val)
            color_name_ar, _ = find_color_name_ar(r_val, g_val, b_val)

        # ── مسار 2: JSON مع hex/rgb مباشرة ──────────────────────────
        elif request.is_json:
            data = request.get_json()
            hex_code = data.get('hex', '#8B5A2B')
            rgb_raw  = data.get('rgb', {})
            r_val    = int(rgb_raw.get('r', 139))
            g_val    = int(rgb_raw.get('g', 90))
            b_val    = int(rgb_raw.get('b', 43))
            color_name_ar = data.get('color_name', '')
            encoded_string = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
            if not color_name_ar:
                color_name_ar, _ = find_color_name_ar(r_val, g_val, b_val)
        else:
            return jsonify({"success": False, "message": "يجب إرسال صورة أو JSON"}), 400

        # ── توليد الوصفة عبر Gemini ───────────────────────────────────
        try:
            prompt = build_gemini_paint_prompt(hex_code, r_val, g_val, b_val, color_name_ar)
            gemini_response = get_gemini().generate_content(prompt)
            recipe_markdown = gemini_response.text.strip()
        except Exception as gemini_err:
            print(f"⚠️ Gemini Recipe Generation failed, using local rule-based fallback. Error: {gemini_err}")
            recipe_markdown = generate_fallback_recipe(hex_code, r_val, g_val, b_val, color_name_ar)

        # ── حفظ السجل في قاعدة البيانات ──────────────────────────────────
        record_id = f"#C{db.session.query(ColorRecord).count() + 1}"
        new_record = ColorRecord(
            id=record_id,
            image_base64=encoded_string,
            hex_code=hex_code,
            r=r_val,
            g=g_val,
            b=b_val,
            color_name=color_name_ar,
            recipe_markdown=recipe_markdown,
            created_at=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        )
        db.session.add(new_record)
        db.session.commit()

        return jsonify({
            "success": True,
            "id": record_id,
            "image_base64": encoded_string,
            "color": {
                "hex":        hex_code,
                "r":          r_val,
                "g":          g_val,
                "b":          b_val,
                "name_ar":    color_name_ar,
            },
            "recipe_markdown": recipe_markdown,
        })

    except Exception as e:
        print(f"❌ Color Recipe Error: {e}")
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/color-history', methods=['GET'])
def api_color_history():
    try:
        records = ColorRecord.query.order_by(ColorRecord.created_at.desc()).all()
        return jsonify({
            "success": True,
            "history": [
                {
                    "id": r.id,
                    "image_base64": r.image_base64,
                    "hex_code": r.hex_code,
                    "r": r.r,
                    "g": r.g,
                    "b": r.b,
                    "color_name": r.color_name,
                    "recipe_markdown": r.recipe_markdown,
                    "created_at": r.created_at
                }
                for r in records
            ]
        })
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5001))
    app.run(host='0.0.0.0', port=port, debug=False)

