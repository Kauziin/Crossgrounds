from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import hmac
import secrets

ROOT = Path(__file__).resolve().parent
TOKEN = secrets.token_urlsafe(32)
(ROOT / 'bridge-token.txt').write_text(TOKEN)
class Handler(BaseHTTPRequestHandler):
    def authorized(self):
        if not hmac.compare_digest(self.headers.get('X-Task-Token',''),TOKEN):
            self.send_error(403); return False
        return True
    def do_GET(self):
        if not self.authorized(): return
        if self.path not in ('/bundle', '/merged', '/tests'):
            self.send_error(404); return
        folder = ROOT / {'/bundle':'work/src', '/merged':'merged/src', '/tests':'work/tests'}[self.path]
        body = json.dumps({'.'.join(p.relative_to(folder).with_suffix('').parts):p.read_text(encoding='utf-8-sig') for p in folder.rglob('*.luau')}).encode()
        self.send_response(200); self.end_headers(); self.wfile.write(body)
    def do_POST(self):
        if not self.authorized(): return
        names = {'/baseline':'baseline.json', '/main':'main-before-merge.json', '/evidence':'evidence.json', '/validation':'validation.json'}
        if self.path not in names:
            self.send_error(404); return
        target = ROOT / names[self.path]
        data = self.rfile.read(int(self.headers['Content-Length']))
        if self.path != '/evidence' and target.exists():
            self.send_error(409); return
        target.write_bytes(data)
        if self.path == '/baseline':
            for name,entry in json.loads(data).items():
                file = ROOT / 'work/src' / Path(*name.split('.')).with_suffix('.luau')
                file.parent.mkdir(parents=True,exist_ok=True)
                file.write_text(entry['source'],encoding='utf-8',newline='\n')
        self.send_response(200); self.end_headers(); self.wfile.write(b'OK')
    def log_message(self,*args): pass
ThreadingHTTPServer(('127.0.0.1',18771),Handler).serve_forever()
