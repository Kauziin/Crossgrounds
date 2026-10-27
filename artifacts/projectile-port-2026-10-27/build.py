from pathlib import Path
R=Path(__file__).resolve().parents[2];T=Path(__file__).resolve().parent
s=(R/'artifacts/weapons-motion-2026-10-27/build_place.cjs').read_text(encoding='utf-8')
s=s.replace("artifacts/weapons-motion-2026-10-27","artifacts/projectile-port-2026-10-27")
s=s.replace("gather(path.join(task,'merged/src'));","gather(path.join(root,'src'));\ngather(path.join(task,'work/src'));")
s=s.replace("gather(path.join(task,'work/tests/Unit'),'ServerStorage.WeaponsMovementTests.');","")
s=s.replace("/CombatMovementController$|CombatLocomotionPose$/","/GraphicsController$|CombatMovementController$|CombatLocomotionPose$/")
s=s.replace('Crossgrounds-Weapons-Movement-v2.rbxl','Crossgrounds-Projectile-Port-Final.rbxl')
s=s.replace("ensure(name,localScript?'LocalScript':'ModuleScript');", "const actual=JSON.parse(fs.readFileSync(path.join(task,'script-classes.json'),'utf8')); ensure(name,actual[name] || (localScript?'LocalScript':'ModuleScript'));")
(T/'build.cjs').write_text(s,encoding='utf-8')
