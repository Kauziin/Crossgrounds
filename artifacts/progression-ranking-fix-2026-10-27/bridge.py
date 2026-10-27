from http.server import BaseHTTPRequestHandler,HTTPServer
from pathlib import Path
import json
class H(BaseHTTPRequestHandler):
 def do_GET(self):
  body=json.dumps({n:Path('src/ServerScriptService/Crossgrounds/'+n+'.luau').read_text(encoding='utf-8') for n in ['ProgressionService','ProgressionRanking']}).encode();self.send_response(200);self.end_headers();self.wfile.write(body)
 def log_message(self,*a):pass
HTTPServer(('127.0.0.1',18782),H).serve_forever()
