import os, re

base = r'c:\Users\win\Downloads\NexQA\nexqa_flutter_factory_auth\nexqa_flutter\lib\screens'
files = ['home_screen.dart', 'login_screen.dart', 'signup_screen.dart', 'dashboard_screen.dart']

for file in files:
    path = os.path.join(base, file)
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove const _c. declarations
    content = re.sub(r'^.*?const _c\.[a-zA-Z]+ = .*?;\n', '', content, flags=re.MULTILINE)
    
    # Fix specific known const errors
    content = content.replace('const Icon(Icons.qr_code_scanner, color: _c.mutedForeground', 'Icon(Icons.qr_code_scanner, color: _c.mutedForeground')
    content = content.replace('const Icon(Icons.chevron_right, color: _c.mutedForeground', 'Icon(Icons.chevron_right, color: _c.mutedForeground')
    content = content.replace('const Icon(Icons.qr_code_scanner, color: _c.primary', 'Icon(Icons.qr_code_scanner, color: _c.primary')
    content = content.replace('const Icon(Icons.visibility_outlined, color: _c.mutedForeground)', 'Icon(Icons.visibility_outlined, color: _c.mutedForeground)')
    content = content.replace('const BorderSide(color: _c.border)', 'BorderSide(color: _c.border)')
    content = content.replace('const BorderSide(color: _c.primary, width: 1.5)', 'BorderSide(color: _c.primary, width: 1.5)')
    content = content.replace('const Icon(Icons.arrow_back_ios_new, color: _c.mutedForeground', 'Icon(Icons.arrow_back_ios_new, color: _c.mutedForeground')
    content = content.replace('const AlwaysStoppedAnimation(_c.success)', 'AlwaysStoppedAnimation(_c.success)')
    content = content.replace('const BoxDecoration(\n          border: Border(top: BorderSide(color: _c.border', 'BoxDecoration(\n          border: Border(top: BorderSide(color: _c.border')
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
print("Fixed!")
