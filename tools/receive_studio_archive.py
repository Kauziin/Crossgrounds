"""Receive engine-serialized Studio backups over loopback; never overwrite a file."""
import base64
import hashlib
import hmac
import json
import os
from pathlib import Path
import secrets
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer

WORKSPACE = Path(__file__).resolve().parent.parent
ARCHIVE = WORKSPACE / "artifacts" / "storage-organization-2026-10-26"
TARGETS = {
    "/baseline": ARCHIVE / "server-storage-before.rbxm",
    "/history": ARCHIVE / "historical-packages.rbxm",
    "/tests": WORKSPACE / "tests" / "studio-tests-before-organization.rbxm",
}
TOKEN = secrets.token_urlsafe(32)


class Handler(BaseHTTPRequestHandler):
    def respond(self, status, payload):
        data = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_POST(self):
        if not hmac.compare_digest(self.headers.get("X-Archive-Token", ""), TOKEN):
            self.respond(403, {"error": "invalid token"})
            return
        if self.path == "/finish":
            self.respond(200, {"stopped": True})
            threading.Thread(target=self.server.shutdown, daemon=True).start()
            return
        destination = TARGETS.get(self.path)
        if destination is None:
            self.respond(404, {"error": "unknown archive"})
            return
        length = int(self.headers.get("Content-Length", "0"))
        if length < 1 or length > 128 * 1024 * 1024:
            self.respond(413, {"error": "invalid archive size"})
            return
        try:
            content = base64.b64decode(self.rfile.read(length), validate=True)
            if not content.startswith(b"<roblox!"):
                raise ValueError("not an engine RBXM archive")
            digest = hashlib.sha256(content).hexdigest()
            destination.parent.mkdir(parents=True, exist_ok=True)
            if destination.exists():
                if hashlib.sha256(destination.read_bytes()).hexdigest() != digest:
                    self.respond(409, {"error": "destination exists with different content"})
                    return
            else:
                with destination.open("xb") as output:
                    output.write(content)
                    output.flush()
                    os.fsync(output.fileno())
            result = {"path": str(destination), "bytes": len(content), "sha256": digest}
            print(json.dumps(result), flush=True)
            self.respond(200, result)
        except (ValueError, OSError) as error:
            self.respond(400, {"error": str(error)})

    def log_message(self, *_args):
        pass


if __name__ == "__main__":
    server = HTTPServer(("127.0.0.1", 0), Handler)
    print(json.dumps({"port": server.server_port, "token": TOKEN}), flush=True)
    server.serve_forever()
    server.server_close()
