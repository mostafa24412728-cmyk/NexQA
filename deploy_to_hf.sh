# ============================================================
# خطوات رفع NexQA على Hugging Face Spaces (مجاناً)
# ============================================================
# غيّر YOUR_USERNAME باسم حسابك على Hugging Face

# 1. أضف remote لـ Hugging Face
git remote add huggingface https://huggingface.co/spaces/YOUR_USERNAME/nexqa-engine

# 2. ارفع الكود (هيطلب اسم المستخدم والـ Token)
git push huggingface main

# ============================================================
# الـ Token: 
# روح https://huggingface.co/settings/tokens
# → New token → اسم: nexqa → Role: Write → Generate
# استخدمه كـ Password لما يطلب منك
# ============================================================
