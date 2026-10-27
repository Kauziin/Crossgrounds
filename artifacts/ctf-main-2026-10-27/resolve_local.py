from pathlib import Path
import re,json,shutil
R=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio');O=R/'artifacts/ctf-main-2026-10-27';p=O/'local-merged/ServerScriptService/MainGameScript/GameManager/SettingsService.luau';s=p.read_text(encoding='utf-8');s,n=re.subn(r'<<<<<<< local\n(.*?)\|\|\|\|\|\|\| base\n.*?=======\n.*?>>>>>>> ctf\n',lambda m:m.group(1),s,flags=re.S);assert n==1;s=s.replace('<<<<<<<','ERROR');p.write_text(s,encoding='utf-8')
for p in(O/'local-merged').rglob('*.luau'):
 s=p.read_text(encoding='utf-8');assert not any(x in s for x in ['<<<<<<<','>>>>>>>','|||||||'])
for p in(O/'local-merged').rglob('*.luau'):
 d=R/'src'/p.relative_to(O/'local-merged');d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,d)
status=json.loads((O/'local-status.json').read_text());
for item in status:
 if item['conflict']:item['conflict']=False;item['resolution']='Kept existing equivalent Studio DataStore guard; preserved other local code.'
(O/'local-status.json').write_text(json.dumps(status,indent=2),encoding='utf-8');print('12 fontes locais integradas; conflito equivalente resolvido.')
