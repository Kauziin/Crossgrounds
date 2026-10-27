from pathlib import Path
import json,subprocess,tempfile,shutil,difflib
R=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio');O=R/'artifacts/ctf-kills-alerts-2026-10-27';report=[];diff=[]
for p in(O/'src').rglob('*.luau'):
 rel=p.relative_to(O/'src');old=O/'before'/rel;dest=R/'src'/rel
 norm=lambda s:s.replace('\r\n','\n').rstrip()+'\n'
 base=norm(old.read_text(encoding='utf-8-sig'))if old.exists()else'';ours=norm(p.read_text(encoding='utf-8-sig'));current=norm(dest.read_text(encoding='utf-8-sig'))if dest.exists()else base
 backup=O/'local-before'/rel;backup.parent.mkdir(parents=True,exist_ok=True)
 if dest.exists():shutil.copy2(dest,backup)
 if current==base or current==ours:merged=ours;code=0
 else:
  with tempfile.TemporaryDirectory()as d:
   files=[Path(d)/x for x in ['current','base','ctf']]
   for f,s in zip(files,[current,base,ours]):f.write_text(s,encoding='utf-8',newline='\n')
   result=subprocess.run(['git','-c','core.autocrlf=false','merge-file','-p','--diff3',*map(str,files)],capture_output=True);merged=result.stdout.decode('utf-8');code=result.returncode
 target=O/'local-merged'/rel;target.parent.mkdir(parents=True,exist_ok=True);target.write_text(merged,encoding='utf-8',newline='\n')
 report.append({'path':str(rel),'conflict':code!=0});diff.extend(difflib.unified_diff(current.splitlines(True),merged.splitlines(True),fromfile='before/'+str(rel),tofile='after/'+str(rel)))
(O/'changes.diff').write_text(''.join(diff),encoding='utf-8');(O/'merge-status.json').write_text(json.dumps(report,indent=2),encoding='utf-8');print(json.dumps(report,indent=2))
if any(x['conflict']for x in report):raise SystemExit(1)
for p in(O/'local-merged').rglob('*.luau'):
 dest=R/'src'/p.relative_to(O/'local-merged');dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
