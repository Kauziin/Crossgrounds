"""Local-only source bridge for the isolated UI/audio Studio copy."""
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts' / 'ui-audio-2026-10-26'
OUT.mkdir(parents=True, exist_ok=True)
FILES = {
    'StarterPlayer.StarterPlayerScripts.' + name: 'src/StarterPlayer/StarterPlayerScripts/' + name + '.luau'
    for name in ('ExperienceMenu', 'MenuTheme', 'MenuNavigation', 'LobbyPlaylist', 'LobbyMusicMenu')
}
FILES['ReplicatedStorage.Crossgrounds.LobbyMusicCatalog'] = 'src/ReplicatedStorage/Crossgrounds/LobbyMusicCatalog.luau'

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != '/bundle':
            self.send_error(404)
            return
        body = json.dumps({k: (ROOT / v).read_text(encoding='utf-8-sig') for k, v in FILES.items()}).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        names = {'/before': 'studio-before.json', '/evidence': 'validation.json', '/patch': 'crossgrounds-ui-audio.rbxm'}
        if self.path not in names:
            self.send_error(404)
            return
        path = OUT / names[self.path]
        if self.path == '/before' and path.exists():
            self.send_error(409)
            return
        path.write_bytes(self.rfile.read(int(self.headers['Content-Length'])))
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK')

HTTPServer(('127.0.0.1', 18764), Handler).serve_forever()
