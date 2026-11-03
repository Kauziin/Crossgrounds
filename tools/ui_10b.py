"""Scoped local Studio source bridge. No publishing or account mutations."""
from pathlib import Path
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/ui-10b-2026-11-03'
def bundle():
    entries=[]
    for file in json.loads((OUT/'files.json').read_text()):
        path=file.removesuffix('.luau');kind='ModuleScript'
        if path.endswith('.local'):path=path.removesuffix('.local');kind='LocalScript'
        if path.endswith('.server'):path=path.removesuffix('.server');kind='Script'
        before=OUT/'before'/file
        entries.append(dict(path=path.replace('/','.'),className=kind,
          source=(ROOT/'src'/file).read_text(encoding='utf-8-sig'),
          before=before.read_text(encoding='utf-8-sig') if before.exists() else None))
    return entries
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path=='/bundle':value=bundle()
        elif self.path=='/tests':value={p.stem:p.read_text(encoding='utf-8-sig') for p in (ROOT/'tests/Unit/Cases').glob('*.luau')}
        else:self.send_error(404);return
        body=json.dumps(value,ensure_ascii=False).encode();self.send_response(200);self.end_headers();self.wfile.write(body)
    def do_POST(self):
        name=self.path.strip('/')
        if not name or '/' in name or '..' in name:self.send_error(400);return
        (OUT/name).write_bytes(self.rfile.read(int(self.headers['Content-Length'])));self.send_response(200);self.end_headers();self.wfile.write(b'OK')
    def log_message(self,*_):pass
if __name__=='__main__':HTTPServer(('127.0.0.1',18779),Handler).serve_forever()
