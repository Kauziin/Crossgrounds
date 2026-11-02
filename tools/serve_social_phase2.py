"""Loopback source bridge for the local validation copy; never deploys a place."""
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
import json
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/social-phase2-2026-11-02'
OUT.mkdir(parents=True, exist_ok=True)

def sources():
    result = []
    for service in ('ReplicatedStorage', 'ServerScriptService', 'StarterPlayer', 'ServerStorage'):
        for path in (ROOT / 'src' / service).rglob('*.luau'):
            if 'Development' in path.parts:
                continue
            rel = path.relative_to(ROOT / 'src')
            parts = list(rel.parts)
            name = path.stem
            cls = 'ModuleScript'
            if name.endswith(('.local', '.client')):
                cls, name = 'LocalScript', name.rsplit('.', 1)[0]
            elif name.endswith('.server'):
                cls, name = 'Script', name.rsplit('.', 1)[0]
            parts[-1] = name
            if name == 'init':
                parts.pop()
            result.append({'parts': parts, 'source': path.read_text(encoding='utf-8-sig'), 'class': cls})
    return sorted(result, key=lambda item: (len(item['parts']), item['parts']))

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/runtime':
            value = sources()
        elif self.path == '/task':
            modified = subprocess.check_output(['git', 'diff', '--name-only', '--', 'src'], cwd=ROOT, text=True).splitlines()
            added = subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '--', 'src'], cwd=ROOT, text=True).splitlines()
            value = []
            for name in sorted(set(modified + added)):
                path = ROOT / name
                if path.suffix != '.luau' or not path.exists():
                    continue
                parts = list(path.relative_to(ROOT / 'src').parts)
                stem = path.stem
                cls = 'LocalScript' if stem.endswith(('.local', '.client')) else 'Script' if stem.endswith('.server') else 'ModuleScript'
                parts[-1] = stem.rsplit('.', 1)[0] if stem.endswith(('.local', '.client', '.server')) else stem
                if parts[-1] == 'init':
                    parts.pop()
                before = subprocess.run(['git', 'show', 'HEAD:' + name], cwd=ROOT, capture_output=True)
                value.append({'parts': parts, 'source': path.read_text(encoding='utf-8-sig'), 'baseline': before.stdout.decode('utf-8-sig') if before.returncode == 0 else None, 'class': cls})
        elif self.path == '/fixtures':
            value = {kind: (ROOT / 'tests/Integration' / ('PartySystems.' + kind + '.luau')).read_text(encoding='utf-8-sig') for kind in ('server', 'client')}
        elif self.path == '/tests':
            names = ['PartyRoster', 'PartyXPPolicy', 'TeamAdmissionPolicy', 'PartyAdmission', 'QueueProvider']
            value = {n: (ROOT / 'src/ServerScriptService/Crossgrounds' / (n + '.luau')).read_text(encoding='utf-8-sig') for n in names}
            value['Case'] = (ROOT / 'tests/Unit/Cases/PartySystems_Test.luau').read_text(encoding='utf-8-sig')
        elif self.path == '/clan-tests':
            value = {n: (ROOT / 'src/ServerScriptService/Crossgrounds' / (n + '.luau')).read_text(encoding='utf-8-sig') for n in ('ClanPolicy', 'ClanRepository')}
            value.update({n: (ROOT / 'src/ReplicatedStorage/Crossgrounds' / (n + '.luau')).read_text(encoding='utf-8-sig') for n in ('ClanCatalog', 'CareerPolicy')})
            value['Case'] = (ROOT / 'tests/Unit/Cases/ClanSystems_Test.luau').read_text(encoding='utf-8-sig')
        else:
            self.send_error(404)
            return
        body = json.dumps(value, ensure_ascii=False).encode()
        self.send_response(200)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if self.path not in ('/edit-before.json', '/main-before.json', '/tests-result.json', '/clan-tests-result.json', '/runtime-result.json'):
            self.send_error(404)
            return
        body = self.rfile.read(int(self.headers['Content-Length']))
        target = OUT / self.path[1:]
        if self.path in ('/edit-before.json', '/main-before.json'):
            previous = json.loads(target.read_text(encoding='utf-8')) if target.exists() else {}
            for name, source in json.loads(body).items():
                previous.setdefault(name, source)
            target.write_text(json.dumps(previous, ensure_ascii=False), encoding='utf-8')
        else:
            target.write_bytes(body)
        self.send_response(200)
        self.end_headers()

    def log_message(self, *_args):
        pass

HTTPServer(('127.0.0.1', 18794), Handler).serve_forever()
