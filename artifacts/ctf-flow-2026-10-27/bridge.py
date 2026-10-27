from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
import json
ROOT=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27')
class Handler(BaseHTTPRequestHandler):
 def do_POST(self):
  if self.path not in ['/baseline','/evidence']: self.send_error(404); return
  data=self.rfile.read(int(self.headers['Content-Length']))
  if self.path=='/baseline':
   items=json.loads(data)
   for name,source in items.items():
    p=ROOT/'baseline'/Path(*name.split('.')).with_suffix('.luau'); p.parent.mkdir(parents=True,exist_ok=True); p.write_text(source,encoding='utf-8')
   (ROOT/'baseline.json').write_bytes(data)
  else: (ROOT/'validation.json').write_bytes(data)
  self.send_response(200); self.end_headers(); self.wfile.write(b'OK')
 def do_GET(self):
  if self.path!='/bundle': self.send_error(404); return
  payload={str(p.relative_to(ROOT/'src').with_suffix('')).replace('\\','.'):p.read_text(encoding='utf-8-sig') for p in (ROOT/'src').rglob('*.luau')}
  body=json.dumps(payload).encode(); self.send_response(200); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
HTTPServer(('127.0.0.1',18769),Handler).serve_forever()
