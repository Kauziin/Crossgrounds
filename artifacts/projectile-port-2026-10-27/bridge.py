from pathlib import Path
from http.server import BaseHTTPRequestHandler,HTTPServer
import json,secrets,hmac
T=Path(__file__).resolve().parent
token=secrets.token_urlsafe(24);(T/'token.txt').write_text(token)
class Handler(BaseHTTPRequestHandler):
 def do_GET(self):
  if self.path!='/plan' or not hmac.compare_digest(self.headers.get('X-Task-Token',''),token): self.send_error(403);return
  rows=[]
  for p in (T/'work/src').rglob('*.luau'):
   rel=p.relative_to(T/'work/src');b=T/'baseline'/rel
   rows.append(dict(path='.'.join(rel.with_suffix('').parts),before=b.read_text(encoding='utf-8') if b.exists() else None,after=p.read_text(encoding='utf-8'),className='LocalScript' if p.stem=='GraphicsController' else 'ModuleScript'))
  data=json.dumps(rows).encode();self.send_response(200);self.end_headers();self.wfile.write(data)
 def do_POST(self):
  if self.path!='/evidence' or not hmac.compare_digest(self.headers.get('X-Task-Token',''),token): self.send_error(403);return
  (T/'validation.txt').write_bytes(self.rfile.read(int(self.headers['Content-Length'])))
  self.send_response(200);self.end_headers()
 def log_message(self,*a):pass
HTTPServer(('127.0.0.1',18776),Handler).serve_forever()
