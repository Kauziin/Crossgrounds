from http.server import BaseHTTPRequestHandler,HTTPServer
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/ui-unification-2026-11-01'
NEW=['ReplicatedStorage/Crossgrounds/ThemeCatalog.luau','ReplicatedStorage/Crossgrounds/InterfaceLayout.luau','ServerStorage/ThemePassConfiguration.luau','ServerScriptService/Crossgrounds/ThemeEntitlements.luau','StarterPlayer/StarterPlayerScripts/ThemeSelectionView.luau','StarterPlayer/StarterPlayerScripts/MenuDialog.luau']
def entries():
 paths=[]
 for before in (OUT/'before').rglob('*.luau'):
  p=ROOT/'src'/before.relative_to(OUT/'before')
  if p.exists() and p.read_bytes()!=before.read_bytes():paths.append(p)
 paths+= [ROOT/'src'/p for p in NEW]
 result=[]
 for p in dict.fromkeys(paths):
  parts=list(p.relative_to(ROOT/'src').with_suffix('').parts); name=parts.pop();cls='ModuleScript'
  if name.endswith('.local'):name=name[:-6];cls='LocalScript'
  elif name.endswith('.server'):name=name[:-7];cls='Script'
  if name!='init':parts.append(name)
  result.append({'path':'.'.join(parts),'className':cls,'source':p.read_text(encoding='utf-8-sig')})
 return result
class H(BaseHTTPRequestHandler):
 def do_GET(self):
  if self.path=='/bundle':value=entries()
  elif self.path=='/tests':value={p.stem:p.read_text(encoding='utf-8-sig') for p in (ROOT/'tests/Unit/Cases').glob('*.luau')};value['RunUnitTest']=(ROOT/'tests/Unit/RunUnitTest.luau').read_text(encoding='utf-8-sig')
  else:self.send_error(404);return
  data=json.dumps(value,ensure_ascii=False).encode();self.send_response(200);self.end_headers();self.wfile.write(data)
 def do_POST(self):
  name=self.path.strip('/')
  if not name or '/' in name or '..' in name:self.send_error(400);return
  (OUT/name).write_bytes(self.rfile.read(int(self.headers['Content-Length'])));self.send_response(200);self.end_headers();self.wfile.write(b'OK')
 def log_message(self,*_):pass
HTTPServer(('127.0.0.1',18773),H).serve_forever()
