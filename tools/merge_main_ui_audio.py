"""Prepare a three-way source merge; never writes to Roblox Studio."""
from pathlib import Path
import difflib
import json
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/main-ui-audio-2026-10-27'
base = json.loads((ROOT / 'artifacts/ui-audio-2026-10-26/studio-before.json').read_text(encoding='utf-8-sig'))
base['StarterPlayer.StarterPlayerScripts.HubController'] = (ROOT / 'artifacts/home-screen-2026-10-27/before/HubController.luau').read_text(encoding='utf-8-sig')
paths = [
 'StarterPlayer.StarterPlayerScripts.ExperienceMenu',
 'StarterPlayer.StarterPlayerScripts.MenuTheme',
 'StarterPlayer.StarterPlayerScripts.MenuNavigation',
 'StarterPlayer.StarterPlayerScripts.LobbyPlaylist',
 'StarterPlayer.StarterPlayerScripts.LobbyMusicMenu',
 'ReplicatedStorage.Crossgrounds.LobbyMusicCatalog',
 'StarterPlayer.StarterPlayerScripts.HubController',
]
result = []
patch = []
for name in paths:
 relative = Path(*name.split('.')).with_suffix('.luau')
 current = (OUT / 'before' / relative).read_text(encoding='utf-8-sig').rstrip() + '\n'
 local = (ROOT / 'src' / relative).read_text(encoding='utf-8-sig').rstrip() + '\n'
 with tempfile.TemporaryDirectory() as tmp:
  inputs = [Path(tmp) / p for p in ('current.luau', 'base.luau', 'local.luau')]
  for file, source in zip(inputs, (current, base[name], local)):
   file.write_text(source.replace('\r\n', '\n').rstrip()+'\n', encoding='utf-8', newline='\n')
  merged = subprocess.run(['git', '-c', 'core.autocrlf=false', 'merge-file', '-p', '--diff3', '-L', 'main', '-L', 'baseline', '-L', 'local', *map(str, inputs)], capture_output=True)
  source = merged.stdout.decode('utf-8').replace('\r\n', '\n')
  if name.endswith('.ExperienceMenu'):
   start = 'local function settingRow(key)\n'
   end = 'local function dev(actionName,payload)\n'
   assert current.count(start) == local.count(start) == 1
   assert current.count(end) == local.count(end) == 1
   source = current[:current.index(start)] + local[local.index(start):local.index(end)] + current[current.index(end):]
   old_y = 'local x=narrow and 0 or (i-1)*step local y=narrow and 38 or 38+(i-1)*5'
   old_h = 'f.Size=UDim2.fromOffset(width,h-70-(i-1)*5)'
   assert source.count(old_y) == source.count(old_h) == 1
   source = source.replace(old_y, old_y.replace('and 38', 'and 32'))
   source = source.replace(old_h, 'f.Size=UDim2.fromOffset(width,narrow and h-54 or h-70-(i-1)*5)')
   assert source.count('AdminMaps') == current.count('AdminMaps')
  elif name.endswith('.MenuTheme'):
   old = next(line for line in current.splitlines() if 'v:IsA("TextButton") and v.Name=="Slider"' in line)
   new = next(line for line in local.splitlines() if 'v:IsA("TextButton") and v.Name=="Slider"' in line)
   assert current.count(old) == 1
   source = current.replace(old, new)
  target = OUT / 'after' / relative
  target.parent.mkdir(parents=True, exist_ok=True)
  target.write_text(source, encoding='utf-8', newline='\n')
  conflict = any(marker in source for marker in ('<<<<<<< main','||||||| baseline','>>>>>>> local'))
  result.append({'path': name, 'conflict': conflict, 'mainDiffersFromBaseline': current != base[name].replace('\r\n','\n'), 'bytes': len(source.encode('utf-8'))})
  patch.extend(difflib.unified_diff(current.splitlines(True), source.splitlines(True), fromfile='main/'+str(relative), tofile='merged/'+str(relative)))
(OUT / 'merge.diff').write_text(''.join(patch), encoding='utf-8')
(OUT / 'merge-status.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
print(json.dumps(result, indent=2))
raise SystemExit(1 if any(r['conflict'] for r in result) else 0)
