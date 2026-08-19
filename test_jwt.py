import urllib.request
import json

url = "https://ihnvsbjayzebmtouravh.supabase.co/auth/v1/signup"
headers = {
    "apikey": "sb_publishable_-LNf1Y1z5sexOzmDg1JFqw_eZ1SZH8n",
    "Content-Type": "application/json"
}
data = json.dumps({"email": "testagent10@example.com", "password": "password123"}).encode("utf-8")

req = urllib.request.Request(url, data=data, headers=headers)
try:
    with urllib.request.urlopen(req) as response:
        resp = json.loads(response.read().decode())
        token = resp.get("access_token")
        if token:
            header = token.split(".")[0]
            import base64
            # Add padding
            header += "=" * ((4 - len(header) % 4) % 4)
            print("JWT Header:", base64.b64decode(header).decode())
        else:
            print("No access token:", resp)
except Exception as e:
    print("Error:", e)
