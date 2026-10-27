from pathlib import Path
import json,subprocess,tempfile,difflib
R=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio');O=R/'artifacts/ctf-main-2026-10-27';T=R/'artifacts/ctf-flow-2026-10-27'
main=json.loads((O/'before.json').read_text(encoding='utf-8'));norm=lambda s:s.replace('\r\n','\n').rstrip()+'\n';report=[];diff=[]
for p in (T/'src').rglob('*.luau'):
 rel=p.relative_to(T/'src');name='.'.join(rel.with_suffix('').parts);current=norm(main[name]);base=norm((T/'baseline'/rel).read_text(encoding='utf-8'));ours=norm(p.read_text(encoding='utf-8'))
 if current==base:merged=ours;code=0
 elif current==ours:merged=current;code=0
 else:
  with tempfile.TemporaryDirectory() as tmp:
   f=[Path(tmp)/x for x in ['main','base','ctf']]
   for dest,s in zip(f,[current,base,ours]):dest.write_text(s,encoding='utf-8',newline='\n')
   r=subprocess.run(['git','-c','core.autocrlf=false','merge-file','-p','--diff3','-L','main','-L','base','-L','ctf',*map(str,f)],capture_output=True);merged=r.stdout.decode('utf-8');code=r.returncode
 dest=O/'merged'/rel;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(merged,encoding='utf-8',newline='\n')
 report.append({'name':name,'mainChanged':current!=base,'conflict':code!=0,'changed':current!=merged})
 diff.extend(difflib.unified_diff(current.splitlines(True),merged.splitlines(True),fromfile='main/'+str(rel),tofile='ctf-merged/'+str(rel)))
(O/'merge.diff').write_text(''.join(diff),encoding='utf-8');(O/'merge-status.json').write_text(json.dumps(report,indent=2),encoding='utf-8');print(json.dumps(report,indent=2));raise SystemExit(any(x['conflict']for x in report))
