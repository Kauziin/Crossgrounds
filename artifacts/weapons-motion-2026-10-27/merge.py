"""Prepare a scoped three-way merge, without editing main sources or Studio."""
from pathlib import Path
import json,subprocess,tempfile,difflib
R=Path(__file__).resolve().parent
base=json.loads((R/'baseline.json').read_text(encoding='utf-8-sig'))
main=json.loads((R/'main-before-merge.json').read_text(encoding='utf-8-sig'))
normalize=lambda x:x.replace('\r\n','\n').rstrip()+'\n'
report=[]; patch=[]
for p in (R/'work/src').rglob('*.luau'):
 rel=p.relative_to(R/'work/src'); name='.'.join(rel.with_suffix('').parts)
 ours=normalize(p.read_text(encoding='utf-8-sig'))
 old=normalize(base[name]['source']) if name in base else ''
 current=normalize(main[name]['source']) if main.get(name) else ''
 if ours==old: continue
 if name=='ReplicatedStorage.ControlDefinitions':
  merged=current.replace('local Controls={}','Policy.Contexts.Slide={"ctf","arena"}\nlocal Controls={}',1)
  merged=merged.replace('"AdminMode","Sprint"','"AdminMode","Slide","Sprint"',1)
  merged=merged.replace(' Sprint={Label="Alternar corrida"',' Slide={Label="Deslizar durante corrida",Gamepad="ButtonB",Keyboard="C"},\n Sprint={Label="Alternar corrida"',1)
  assert 'Slide={Label=' in merged
  code=0
 elif name=='ReplicatedStorage.Crossgrounds.MobileLayout':
  merged=current.replace('"Jump","Sprint"','"Jump","Slide","Sprint"',1)
  merged=merged.replace(' Sprint={Label="CORRER"',' Slide={Label="DESLIZAR",Glyph="↘",X=.80,Y=.85,Size=54,Opacity=.8},\n Sprint={Label="CORRER"',1)
  assert 'Slide={Label=' in merged
  code=0
 elif current==old or not current: merged=ours; code=0
 elif ours==current: merged=current; code=0
 else:
  with tempfile.TemporaryDirectory() as d:
   files=[Path(d)/n for n in ('current','base','ours')]
   for f,s in zip(files,(current,old,ours)): f.write_text(s,encoding='utf-8',newline='\n')
   result=subprocess.run(['git','-c','core.autocrlf=false','merge-file','-p','--diff3','-L','main','-L','base','-L','weapons',*map(str,files)],capture_output=True)
   code=result.returncode; merged=result.stdout.decode('utf-8')
 target=R/'merged/src'/rel; target.parent.mkdir(parents=True,exist_ok=True); target.write_text(merged,encoding='utf-8',newline='\n')
 report.append({'path':name,'new':not current,'mainChanged':current!=old,'conflict':code!=0})
 patch.extend(difflib.unified_diff(current.splitlines(True),merged.splitlines(True),fromfile='main/'+str(rel),tofile='merged/'+str(rel)))
(R/'merge.diff').write_text(''.join(patch),encoding='utf-8')
(R/'merge-status.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print(json.dumps(report,indent=2))
raise SystemExit(1 if any(r['conflict'] for r in report) else 0)
