from pathlib import Path
r=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio')
s=(r/'tools/patch_ctf_flow_place.cjs').read_text(encoding='utf-8')
a=s.index("if (process.argv.includes('--inspect'))")
s=s[:a]+'''const wanted=new Set(['ServerScriptService.MainGameScript.GameManager.SettingsService','ServerScriptService.Crossgrounds.ProgressionService']);
for(const c of chunks) if(c.prop?.name==='Source') {
 let cursor=c.prop.pos+1;
 for(const ref of classes.get(c.prop.id).ids) {
  const [source,next]=str(c.data,cursor);cursor=next;
  const name=objectPath(ref);
  if(wanted.has(name)) {
   const dest=path.join(root,'artifacts/ctf-flow-2026-10-27/baseline',...name.split('.'))+'.luau';
   fs.mkdirSync(path.dirname(dest),{recursive:true}); if(!fs.existsSync(dest))fs.writeFileSync(dest,source);
  }
 }
}
'''
(r/'artifacts/ctf-flow-2026-10-27/extract-persistence.cjs').write_text(s.replace("const root = path.resolve(__dirname, '..');","const root = path.resolve(__dirname, '../..');"),encoding='utf-8')
