from http.server import BaseHTTPRequestHandler,HTTPServer
from pathlib import Path
import json
R=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-kills-alerts-2026-10-27')
class H(BaseHTTPRequestHandler):
 def do_POST(self):
  if self.path not in ['/before','/validation']:self.send_error(404);return
  p=R/(self.path[1:]+'.json')
  if self.path=='/before'and p.exists():self.send_error(409);return
  data=self.rfile.read(int(self.headers['Content-Length']));p.write_bytes(data)
  if self.path=='/before':
   for name,source in json.loads(data).items():
    p=R/'before'/Path(*name.split('.')).with_suffix('.luau');p.parent.mkdir(parents=True,exist_ok=True);p.write_text(source,encoding='utf-8')
  self.send_response(200);self.end_headers();self.wfile.write(b'OK')
 def do_GET(self):
  if self.path!='/bundle':self.send_error(404);return
  data={'.'.join(p.relative_to(R/'src').with_suffix('').parts):p.read_text(encoding='utf-8-sig') for p in(R/'src').rglob('*.luau')};self.send_response(200);self.end_headers();self.wfile.write(json.dumps(data).encode())
HTTPServer(('127.0.0.1',18772),H).serve_forever()
