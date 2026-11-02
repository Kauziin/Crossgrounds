"""Loopback bridge for this task's sources and isolated Studio evidence."""
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/social-systems-2026-11-02'
OUT.mkdir(parents=True, exist_ok=True)

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path not in ('/foundation', '/bundle'):
            self.send_error(404)
            return
        paths = {
            'CareerPolicy': 'src/ReplicatedStorage/Crossgrounds/CareerPolicy.luau',
            'CareerRepository': 'src/ServerScriptService/Crossgrounds/CareerRepository.luau',
            'Case': 'tests/Unit/Cases/CareerFoundation_Test.luau',
        }
        if self.path == '/bundle':
            names = [
                'ReplicatedStorage/Crossgrounds/' + n for n in ('CareerPolicy', 'IdentityCatalog', 'ProgressionSchema')
            ] + ['ServerScriptService/Crossgrounds/' + n for n in ('CareerRepository', 'CareerService', 'ProgressionService', 'ProgressionRanking', 'StandingsService')]
            names += ['StarterPlayer/StarterPlayerScripts/' + n for n in ('PlayerIdentityView', 'CareerMenu.local', 'HubController.local', 'ExperienceMenu.local', 'LobbyMusicMenu.local', 'ProgressionPanel.local', 'PrestigePresentation.local', 'ProgressionView')]
            names += ['StarterPlayer/StarterPlayerScripts/CareerClient', 'StarterPlayer/StarterPlayerScripts/GunsmithView', 'ReplicatedStorage/Crossgrounds/UnlockCatalog', 'ServerScriptService/Crossgrounds/UnlockService', 'ServerScriptService/Crossgrounds/ArsenalLoadouts', 'ServerScriptService/Crossgrounds/ArenaAdapter', 'ServerScriptService/Crossgrounds/ArenaCombat', 'ServerScriptService/Crossgrounds/ArenaRewards', 'ServerScriptService/MainGameScript/GameManager/DamageService', 'StarterPlayer/StarterPlayerScripts/EliminationSpectator.local']
            data = {}
            for name in names:
                relative = name + '.luau'
                baseline = OUT / 'before' / relative
                data[name.replace('/', '.').removesuffix('.local')] = {
                    'source': (ROOT / 'src' / relative).read_text(encoding='utf-8-sig'),
                    'baseline': baseline.read_text(encoding='utf-8-sig') if baseline.exists() else None,
                    'class': 'LocalScript' if name.endswith('.local') else 'ModuleScript',
                }
        else:
            data = {key: (ROOT / value).read_text(encoding='utf-8-sig') for key, value in paths.items()}
        body = json.dumps(data, ensure_ascii=False).encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if self.path not in ('/foundation-result.json', '/studio-before.json', '/runtime-result.json'):
            self.send_error(404)
            return
        (OUT / self.path[1:]).write_bytes(self.rfile.read(int(self.headers['Content-Length'])))
        self.send_response(200)
        self.end_headers()

    def log_message(self, *_args):
        pass

HTTPServer(('127.0.0.1', 18793), Handler).serve_forever()
