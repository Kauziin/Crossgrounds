from pathlib import Path
import difflib,json
R=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-kills-alerts-2026-10-27')
diff=[]
for p in sorted((R/'src').rglob('*.luau')):
 rel=p.relative_to(R/'src');before=R/'before'/rel
 a=before.read_text(encoding='utf-8-sig').splitlines(True)if before.exists()else[]
 b=p.read_text(encoding='utf-8-sig').splitlines(True)
 diff.extend(difflib.unified_diff(a,b,fromfile='before/'+str(rel),tofile='after/'+str(rel)))
(R/'changes.diff').write_text(''.join(diff),encoding='utf-8')
v=json.loads((R/'validation.json').read_text(encoding='utf-8'))
v['visual']={'eventHeight':40,'previousMinimumHeight':110,'carrierHeight':18,'backgroundTransparency':1,'simulatedDevice':'Samsung Galaxy A06','viewport':'705 x 338','orientation':'LandscapeSensor','insets':'CoreUISafeInsets','botRowsReceived':11,'totalRowsReceived':12,'botRowsRenderedInControlledPreview':11}
(R/'validation.json').write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding='utf-8')
print('Estado e evidências atualizados.')
