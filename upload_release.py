import subprocess, json, sys, os

# Fix encoding for Windows console
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# Get token from Windows Credential Manager
result = subprocess.run(
    ["git", "credential", "fill"],
    input="protocol=https\nhost=github.com\n",
    capture_output=True, text=True
)
token = ""
for line in result.stdout.splitlines():
    if line.startswith("password="):
        token = line.split("=", 1)[1]
        break

if not token:
    print("No cached token found. Enter your GitHub Personal Access Token:")
    token = input("Token: ").strip()

repo = "mostafa24412728-cmyk/NexQA"
apk_path = r"c:\Users\win\Downloads\NexQA\nexqa_flutter_factory_auth\nexqa_flutter\build\app\outputs\flutter-apk\app-release.apk"

import urllib.request, urllib.error

headers = {
    "Authorization": f"token {token}",
    "Accept": "application/vnd.github+json",
    "Content-Type": "application/json",
    "User-Agent": "NexQA-Deployer"
}

print("Creating GitHub Release v1.0.0...")
data = json.dumps({
    "tag_name": "v1.0.0",
    "name": "NexQA v1.0.0 - Android App",
    "body": "NexQA Android App - first release",
    "draft": False,
    "prerelease": False
}).encode()

req = urllib.request.Request(
    f"https://api.github.com/repos/{repo}/releases",
    data=data, headers=headers, method="POST"
)
try:
    with urllib.request.urlopen(req) as resp:
        release = json.loads(resp.read())
        upload_url = release["upload_url"].replace("{?name,label}", "")
        release_url = release["html_url"]
        print(f"Release created: {release_url}")
except urllib.error.HTTPError as e:
    body = e.read().decode()
    if "already_exists" in body:
        req2 = urllib.request.Request(
            f"https://api.github.com/repos/{repo}/releases/tags/v1.0.0",
            headers=headers
        )
        with urllib.request.urlopen(req2) as resp:
            release = json.loads(resp.read())
            upload_url = release["upload_url"].replace("{?name,label}", "")
            release_url = release["html_url"]
            print(f"Release already exists: {release_url}")
    else:
        print(f"Failed to create release: {body}")
        sys.exit(1)

print("Uploading APK (48MB) ...")
with open(apk_path, "rb") as f:
    apk_data = f.read()

upload_headers = {**headers, "Content-Type": "application/octet-stream"}
req3 = urllib.request.Request(
    f"{upload_url}?name=NexQA-v1.0.0.apk",
    data=apk_data, headers=upload_headers, method="POST"
)
try:
    with urllib.request.urlopen(req3) as resp:
        asset = json.loads(resp.read())
        download_url = asset["browser_download_url"]
        print(f"\n=== DOWNLOAD LINK ===")
        print(download_url)
        print("====================")
except urllib.error.HTTPError as e:
    err = e.read().decode()
    print(f"Upload failed: {err}")
    print(f"Upload manually from: {apk_path}")
    print(f"To releases page: {release_url}")
