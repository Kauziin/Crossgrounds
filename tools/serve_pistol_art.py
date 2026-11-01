"""Loopback bridge for isolated attachment-art/pistol-animation work."""
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
import json
import mimetypes
import shutil

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/pistol-art-2026-11-01'
OUT.mkdir(parents=True,exist_ok=True)
FILES=[
 'ReplicatedStorage/Crossgrounds/PistolReloadMotion',
 'ReplicatedStorage/Crossgrounds/WeaponReloadMotion',
 'ReplicatedStorage/Crossgrounds/AttachmentArt',
 'StarterPlayer/StarterPlayerScripts/ArsenalSelectionView',
 'StarterPlayer/StarterPlayerScripts/FirstPersonRenderer',
 'StarterPlayer/StarterPlayerScripts/WeaponPose.local',
 'ServerScriptService/Crossgrounds/ImportedWeaponVisuals',
 'ServerScriptService/MainGameScript/GameManager/KitService',
 'ServerScriptService/MainGameScript/GameManager/WeaponFactory',
]
def entry(p):
 rel=p.relative_to(ROOT/'src').as_posix()[:-5]
 parts=rel.split('/')
 name=parts.pop()
 cls='ModuleScript'
 if name.endswith('.local'): name=name[:-6]; cls='LocalScript'
 elif name.endswith('.server'): name=name[:-7]; cls='Script'
 if name!='init': parts.append(name)
 return {"path":'.'.join(parts),"className":cls,"source":p.read_text(encoding='utf-8-sig')}
for name in FILES:
 p=ROOT/'src'/(name+'.luau'); dest=OUT/'before'/(name+'.luau')
 if p.exists() and not dest.exists(): dest.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(p,dest)
class Handler(BaseHTTPRequestHandler):
 def do_GET(self):
  if self.path in ('/bundle','/fullbundle'):
   paths=[ROOT/'src'/(n+'.luau') for n in FILES] if self.path=='/bundle' else [p for service in ('ReplicatedStorage','ServerScriptService','StarterPlayer') for p in (ROOT/'src'/service).rglob('*.luau')]
   value=[entry(p) for p in paths if p.exists()]
  elif self.path=='/tests':
   value={str(p.relative_to(ROOT/'tests/Unit')).replace('\\','.').removesuffix('.luau'):p.read_text(encoding='utf-8-sig') for p in (ROOT/'tests/Unit').rglob('*.luau') if 'Runner.server' not in p.name}
  elif self.path.startswith('/assets/'):
   p=OUT/self.path.removeprefix('/assets/')
   if p.parent.resolve()!=OUT.resolve() or not p.is_file(): self.send_error(404); return
   data=p.read_bytes(); self.send_response(200); self.send_header('Content-Type',mimetypes.guess_type(p)[0] or 'application/octet-stream'); self.end_headers(); self.wfile.write(data); return
  else: self.send_error(404); return
  data=json.dumps(value,ensure_ascii=False).encode(); self.send_response(200); self.end_headers(); self.wfile.write(data)
 def do_POST(self):
  name=self.path.removeprefix('/')
  if not name or '/' in name or '..' in name: self.send_error(400); return
  (OUT/name).write_bytes(self.rfile.read(int(self.headers['Content-Length'])))
  self.send_response(200); self.end_headers(); self.wfile.write(b'OK')
 def log_message(self,*_): pass
HTTPServer(('127.0.0.1',18769),Handler).serve_forever()

