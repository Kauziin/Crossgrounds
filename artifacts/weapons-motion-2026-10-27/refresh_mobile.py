from pathlib import Path
import json
R=Path(__file__).resolve().parent
current=json.loads((R/'evidence.json').read_text(encoding='utf-8-sig'))
before=json.loads((R/'main-before-merge.json').read_text(encoding='utf-8-sig'))
base=json.loads((R/'baseline.json').read_text(encoding='utf-8-sig'))
before.update(current)
name='StarterPlayer.StarterPlayerScripts.TouchActionIcons'
base[name]=current[name]
source=current[name]['source']
old=' elseif action=="Sprint" then'
assert source.count(old)==1
source=source.replace(old,' elseif action=="Slide" then\n  rect(8,5,5,5,5) line(8,9,13,13) line(13,13,21,14) line(12,13,7,18) line(7,18,2,18) line(5,22,23,22)\n'+old)
p=R/'work/src'/Path(*name.split('.')).with_suffix('.luau')
p.write_text(source,encoding='utf-8')
(R/'main-before-merge.json').write_text(json.dumps(before,indent=2),encoding='utf-8')
(R/'baseline.json').write_text(json.dumps(base,indent=2),encoding='utf-8')
print('Preserved current mobile layout and added the vector slide icon')
