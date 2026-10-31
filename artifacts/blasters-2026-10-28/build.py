from pathlib import Path
R=Path(__file__).resolve().parents[2];T=Path(__file__).resolve().parent
s=(R/'artifacts/projectile-port-2026-10-27/build.cjs').read_text(encoding='utf-8')
s=s.replace('artifacts/projectile-port-2026-10-27','artifacts/blasters-2026-10-28')
s=s.replace("path.join(root,'CrossgroundsAlphaCopy-CTF.rbxl')","path.join(root,'artifacts/projectile-port-2026-10-27/Crossgrounds-Projectile-Port-Final.rbxl')")
s=s.replace('Crossgrounds-Projectile-Port-Final.rbxl','Crossgrounds-Blasters-Work.rbxl') if False else s
s=s.replace("const target=path.join(task,'Crossgrounds-Projectile-Port-Final.rbxl')","const target=path.join(task,'Crossgrounds-Blasters-Work.rbxl')")
(T/'build.cjs').write_text(s,encoding='utf-8')
