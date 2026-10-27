from pathlib import Path
import difflib,json,hashlib
r=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27')
changes=[];files=[]
for p in sorted((r/'src').rglob('*.luau')):
 rel=p.relative_to(r/'src'); before=r/'baseline'/rel
 a=before.read_text(encoding='utf-8').splitlines(True);b=p.read_text(encoding='utf-8').splitlines(True)
 if a!=b:
  changes.extend(difflib.unified_diff(a,b,fromfile='before/'+str(rel),tofile='after/'+str(rel)))
  files.append(str(rel))
(r/'changes.diff').write_text(''.join(changes),encoding='utf-8')
(r/'source-manifest.json').write_text(json.dumps({'file':'CrossgroundsAlphaCopy-CTF.rbxl','sources':files,'backupSHA256':hashlib.sha256((r/'before.rbxl').read_bytes()).hexdigest()},indent=2),encoding='utf-8')
print('Changed sources:',len(files))
