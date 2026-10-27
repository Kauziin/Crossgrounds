from pathlib import Path
from http.server import BaseHTTPRequestHandler,HTTPServer
import json,hmac
R=Path(__file__).resolve().parent
ROOT=R.parents[1]
TOKEN=(ROOT/'artifacts/weapons-motion-2026-10-27/bridge-token.txt').read_text().strip()
class Handler(BaseHTTPRequestHandler):
 def do_GET(self):
  if self.path!='/plan' or not hmac.compare_digest(self.headers.get('X-Task-Token',''),TOKEN):
   self.send_error(403);return
  rows=[]
  for name in ('FirstPersonRenderer','CombatPresentation'):
   rel=Path('StarterPlayer/StarterPlayerScripts')/(name+'.luau')
   rows.append({'path':'.'.join(rel.with_suffix('').parts),'before':(R/'before'/rel).read_text(encoding='utf-8-sig'),'after':(ROOT/'src'/rel).read_text(encoding='utf-8-sig')})
  body=json.dumps(rows).encode();self.send_response(200);self.end_headers();self.wfile.write(body)
 def log_message(self,*args):pass
HTTPServer(('127.0.0.1',18773),Handler).serve_forever()
