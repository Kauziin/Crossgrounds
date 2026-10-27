from pathlib import Path
import json,shutil,difflib
R=Path(__file__).resolve().parent
ROOT=R.parents[1]
before=json.loads((R/'main-before-merge.json').read_text(encoding='utf-8-sig'))
normalize=lambda s:s.replace('\r\n','\n').rstrip()
changes=[]
for p in (R/'merged/src').rglob('*.luau'):
 rel=p.relative_to(R/'merged/src');name='.'.join(rel.with_suffix('').parts)
 source=p.read_text(encoding='utf-8-sig');prior=before.get(name)
 if prior and normalize(prior['source'])==normalize(source):continue
 target=ROOT/'src'/rel
 if target.exists():
  current=target.read_text(encoding='utf-8-sig');baseline=R/'local-baseline'/rel
  assert normalize(current)==normalize(source) or prior and normalize(current)==normalize(prior['source']) or baseline.exists() and normalize(current)==normalize(baseline.read_text(encoding='utf-8-sig')),f'Concurrent local change: {name}'
 changes.append((name,p,target))
for name,p,target in changes:
 if target.exists():
  backup=R/'local-before-merge'/target.relative_to(ROOT/'src');backup.parent.mkdir(parents=True,exist_ok=True)
  if not backup.exists():shutil.copy2(target,backup)
 target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target)
test=ROOT/'tests/Unit/Cases/WeaponMovement_Test.luau'
shutil.copyfile(R/'work/tests/Unit/Cases/WeaponMovement_Test.luau',test)
(R/'source-manifest.json').write_text(json.dumps({'sources':[name for name,_,_ in changes],'test':str(test)},indent=2),encoding='utf-8')
print(f'Synced {len(changes)} scoped runtime sources and 1 test case; concurrent mobile and CTF files preserved.')
