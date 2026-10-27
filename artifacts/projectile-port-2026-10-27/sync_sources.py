from pathlib import Path
import shutil,difflib
T=Path(__file__).resolve().parent;R=T.parents[1]
def normal(s):return s.replace('\r\n','\n').rstrip()
entries=[]
for p in (T/'work/src').rglob('*.luau'):
 rel=p.relative_to(T/'work/src')
 if rel.parts[0]=='ServerStorage':continue
 target=R/'src'/rel;baseline=T/'baseline'/rel
 if baseline.exists():assert target.exists() and normal(target.read_text(encoding='utf-8-sig'))==normal(baseline.read_text(encoding='utf-8-sig')),f'Concurrent local source changed: {rel}'
 else:assert not target.exists(),f'New source collision: {rel}'
 entries.append((p,rel,target))
diff=[]
for p,rel,target in entries:
 before=target.read_text(encoding='utf-8-sig') if target.exists() else ''
 after=p.read_text(encoding='utf-8-sig')
 if target.exists():
  b=T/'local-before-merge'/rel;b.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(target,b)
 target.parent.mkdir(parents=True,exist_ok=True);target.write_text(after,encoding='utf-8')
 diff+=difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='before/'+str(rel),tofile='after/'+str(rel))
(T/'changes.diff').write_text(''.join(diff),encoding='utf-8')
print(f'Merged {len(entries)} local sources')
