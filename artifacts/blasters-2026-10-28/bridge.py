from pathlib import Path
from http.server import BaseHTTPRequestHandler,HTTPServer
import secrets,json,hmac
T=Path(__file__).resolve().parent
token=secrets.token_urlsafe(24);(T/'token.txt').write_text(token)
class Handler(BaseHTTPRequestHandler):
 def authorized(self):return hmac.compare_digest(self.headers.get('X-Task-Token',''),token)
 def do_GET(self):
  if not self.authorized():self.send_error(403);return
  if self.path=='/assets':data=(T/'assets.json').read_bytes()
  elif self.path=='/sources':
   rows=[]
   for p in (T/'work/src').rglob('*.luau'):
    rel=p.relative_to(T/'work/src');b=T/'baseline'/rel
    rows.append(dict(path='.'.join(rel.with_suffix('').parts),after=p.read_text(encoding='utf-8-sig'),before=b.read_text(encoding='utf-8-sig') if b.exists() else None))
   data=json.dumps(rows).encode()
  else:self.send_error(404);return
  self.send_response(200);self.end_headers();self.wfile.write(data)
 def do_POST(self):
  if not self.authorized() or self.path not in ['/assets','/evidence']:self.send_error(403);return
  (T/('assets.json' if self.path=='/assets' else 'evidence.txt')).write_bytes(self.rfile.read(int(self.headers['Content-Length'])))
  self.send_response(200);self.end_headers()
 def log_message(self,*a):pass
HTTPServer(('127.0.0.1',18778),Handler).serve_forever()
