from http.server import BaseHTTPRequestHandler,HTTPServer
from pathlib import Path
import json
ROOT=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-main-2026-10-27');ROOT.mkdir(parents=True,exist_ok=True)
class H(BaseHTTPRequestHandler):
 def do_POST(self):
  if self.path not in ['/before','/validation']:self.send_error(404);return
  p=ROOT/(self.path[1:]+'.json')
  if self.path=='/before' and p.exists():self.send_error(409);return
  p.write_bytes(self.rfile.read(int(self.headers['Content-Length'])));self.send_response(200);self.end_headers();self.wfile.write(b'OK')
 def do_GET(self):
  if self.path!='/bundle':self.send_error(404);return
  data={'.'.join(p.relative_to(ROOT/'merged').with_suffix('').parts):p.read_text(encoding='utf-8-sig') for p in (ROOT/'merged').rglob('*.luau')}
  b=json.dumps(data).encode();self.send_response(200);self.end_headers();self.wfile.write(b)
HTTPServer(('127.0.0.1',18770),H).serve_forever()
