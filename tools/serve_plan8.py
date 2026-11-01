"""Loopback-only source/evidence bridge for the plan 8 Studio session."""
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
import json
import shutil

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts' / 'plan8-2026-11-01'
OUT.mkdir(parents=True, exist_ok=True)
PATHS = [
    'ReplicatedStorage/Crossgrounds/' + n for n in (
        'AttachmentCatalog', 'AttachmentCompatibility', 'WeaponCatalog',
        'WeaponVisualConfiguration', 'WeaponStats', 'WeaponHold',
    )
] + [
    'ServerScriptService/Crossgrounds/' + n for n in ('ImportedWeaponVisuals', 'WeaponRig')
] + [
    'StarterPlayer/StarterPlayerScripts/' + n for n in (
        'GunsmithView', 'ArsenalSelectionView', 'ArsenalPreview', 'FirstPersonRenderer', 'ExperienceMenu.local',
    )
]
for name in PATHS:
    source = ROOT / 'src' / (name + '.luau')
    target = OUT / 'before' / (name + '.luau')
    if source.exists() and not target.exists():
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/bundle':
            value = {n.replace('/', '.').removesuffix('.local'): (ROOT / 'src' / (n + '.luau')).read_text(encoding='utf-8-sig')
                     for n in PATHS if (ROOT / 'src' / (n + '.luau')).exists()}
        elif self.path == '/tests':
            value = {'RunUnitTest': (ROOT / 'tests/Unit/RunUnitTest.luau').read_text(encoding='utf-8-sig')}
            for p in (ROOT / 'tests/Unit/Cases').glob('*.luau'):
                value['Cases.' + p.stem] = p.read_text(encoding='utf-8-sig')
        else:
            self.send_error(404)
            return
        body = json.dumps(value, ensure_ascii=False).encode()
        self.send_response(200)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        name = self.path.removeprefix('/')
        if not name or '/' in name or '..' in name or not name.endswith(('.json', '.jpg')):
            self.send_error(400)
            return
        (OUT / name).write_bytes(self.rfile.read(int(self.headers['Content-Length'])))
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')

    def log_message(self, *_args):
        pass


HTTPServer(('127.0.0.1', 18768), Handler).serve_forever()
