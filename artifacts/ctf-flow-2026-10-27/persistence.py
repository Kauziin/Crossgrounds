from pathlib import Path
r=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27')
for name,guard in [('ServerScriptService.MainGameScript.GameManager.SettingsService','Run'),('ServerScriptService.Crossgrounds.ProgressionService','RunService')]:
 p=Path(*name.split('.')).with_suffix('.luau'); s=(r/'baseline'/p).read_text(encoding='utf-8')
 lines=s.splitlines()
 for i,line in enumerate(lines):
  if 'local store' in line and ':GetDataStore(' in line:
   before,after=line.split('=',1)
   lines[i]=before+'= not '+guard+':IsStudio() and '+after.strip()+' or nil'
 (r/'src'/p).write_text('\n'.join(lines)+'\n',encoding='utf-8')
