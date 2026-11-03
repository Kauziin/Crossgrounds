from http.server import BaseHTTPRequestHandler,HTTPServer
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/nova-runtime-2026-11-03'
class Handler(BaseHTTPRequestHandler):
 def do_GET(self):
  if self.path=='/tests':
   value={p.stem:p.read_text(encoding='utf-8-sig')for p in (ROOT/'tests/Unit/Cases').glob('*.luau')if any(k in p.name for k in ['InterfaceStyle','Preference','ThemeAndInterface','MobileMenusAndSafeZone'])}
  else:
   value=[]
   for file in json.loads((OUT/'files.json').read_text()):
    name=file.removesuffix('.luau');kind='ModuleScript'
    if name.endswith('.local'):name=name.removesuffix('.local');kind='LocalScript'
    before=OUT/'before'/file
    value.append(dict(path=name.replace('/','.'),kind=kind,source=(ROOT/'src'/file).read_text(encoding='utf-8-sig'),before=before.read_text(encoding='utf-8-sig')if before.exists()else None))
  body=json.dumps(value).encode();self.send_response(200);self.end_headers();self.wfile.write(body)
 def do_POST(self):
  name=self.path.strip('/')
  if '/'in name or '..'in name:self.send_error(400);return
  (OUT/name).write_bytes(self.rfile.read(int(self.headers['Content-Length'])));self.send_response(200);self.end_headers()
 def log_message(self,*_):pass
HTTPServer(('127.0.0.1',18783),Handler).serve_forever()
