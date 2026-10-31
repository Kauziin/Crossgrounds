from pathlib import Path
import shutil,subprocess,difflib
T=Path(__file__).resolve().parent;R=T.parents[1]
normal=lambda s:s.replace('\r\n','\n').rstrip()
entries=[]
for p in (T/'work/src').rglob('*.luau'):
 rel=p.relative_to(T/'work/src')
 if rel.parts[0]=='ServerStorage':continue
 target=R/'src'/rel;baseline=T/'baseline'/rel
 if baseline.exists():
  before=target.read_text(encoding='utf-8-sig')
  if normal(before)!=normal(baseline.read_text(encoding='utf-8-sig')):
   assert str(rel).replace('\\','/')=='StarterPlayer/StarterPlayerScripts/WeaponController.luau',f'Concurrent source: {rel}'
   committed=subprocess.check_output(['git','show','HEAD:src/'+rel.as_posix()],cwd=R).decode('utf-8-sig')
   assert normal(committed)==normal(before),'WeaponController changed locally after baseline'
   print('Preserved newer Studio reload interaction priority while aligning its unchanged local mirror')
 else:assert not target.exists(),f'New local source collision: {rel}'
 entries.append((p,rel,target))
diff=[]
for p,rel,target in entries:
 before=target.read_text(encoding='utf-8-sig')if target.exists()else''
 if target.exists():
  b=T/'local-before-merge'/rel;b.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(target,b)
 after=p.read_text(encoding='utf-8-sig');target.parent.mkdir(parents=True,exist_ok=True);target.write_text(after,encoding='utf-8')
 diff+=difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='before/'+str(rel),tofile='after/'+str(rel))
(T/'changes.diff').write_text(''.join(diff),encoding='utf-8')
print(f'Merged {len(entries)} production sources locally')
