from pathlib import Path
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
ROOT=Path.cwd()
OUT=ROOT/'artifacts/progression-visual-2026-10-27'
class Handler(BaseHTTPRequestHandler):
 def do_GET(self):
  if self.path!='/bundle': self.send_error(404); return
  names=('ProgressionPanel','ProgressionView')
  body=json.dumps({n:(ROOT/'src/StarterPlayer/StarterPlayerScripts'/f'{n}.luau').read_text(encoding='utf-8-sig') for n in names}).encode()
  self.send_response(200); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
 def do_POST(self):
  names={'/before':'studio-before.json','/checks':'checks.json'}
  if self.path not in names: self.send_error(404); return
  p=OUT/names[self.path]
  if self.path=='/before' and p.exists(): self.send_error(409); return
  p.write_bytes(self.rfile.read(int(self.headers['Content-Length'])))
  self.send_response(200); self.end_headers(); self.wfile.write(b'OK')
 def log_message(self,*args): pass
HTTPServer(('127.0.0.1',18781),Handler).serve_forever()
