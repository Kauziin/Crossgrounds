from pathlib import Path
import json,subprocess,tempfile,shutil
R=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio');O=R/'artifacts/ctf-main-2026-10-27';base=json.loads((O/'before.json').read_text(encoding='utf-8'));norm=lambda s:s.replace('\r\n','\n').rstrip()+'\n';report=[]
for p in (O/'merged').rglob('*.luau'):
 rel=p.relative_to(O/'merged');name='.'.join(rel.with_suffix('').parts);dest=R/'src'/rel;ours=norm(p.read_text(encoding='utf-8'));old=norm(base[name]);current=norm(dest.read_text(encoding='utf-8-sig'))if dest.exists() else old
 backup=O/'local-before'/rel;backup.parent.mkdir(parents=True,exist_ok=True)
 if dest.exists():shutil.copy2(dest,backup)
 if current==old or current==ours:result=ours;code=0
 else:
  with tempfile.TemporaryDirectory()as tmp:
   f=[Path(tmp)/s for s in ['local','base','ctf']]
   for q,s in zip(f,[current,old,ours]):q.write_text(s,encoding='utf-8',newline='\n')
   ret=subprocess.run(['git','-c','core.autocrlf=false','merge-file','-p','--diff3','-L','local','-L','base','-L','ctf',*map(str,f)],capture_output=True);result=ret.stdout.decode('utf-8');code=ret.returncode
 target=O/'local-merged'/rel;target.parent.mkdir(parents=True,exist_ok=True);target.write_text(result,encoding='utf-8',newline='\n');report.append({'name':name,'conflict':code!=0})
(O/'local-status.json').write_text(json.dumps(report,indent=2),encoding='utf-8');print(json.dumps(report,indent=2))
if any(x['conflict']for x in report):raise SystemExit(1)
for p in(O/'local-merged').rglob('*.luau'):
 dest=R/'src'/p.relative_to(O/'local-merged');dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
