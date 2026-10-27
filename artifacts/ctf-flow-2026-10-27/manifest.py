from pathlib import Path
r=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio')
p=r/'tools/patch_ctf_flow_place.cjs';s=p.read_text(encoding='utf-8');anchor='console.log(JSON.stringify({out,updated}));';assert anchor in s
s=s.replace(anchor,'''fs.writeFileSync(path.join(root,'artifacts/ctf-flow-2026-10-27/build-manifest.json'),JSON.stringify({
 input:'artifacts/ctf-flow-2026-10-27/before.rbxl',output:out,sources:updated,
 headerPreserved:output.subarray(0,32).equals(input.subarray(0,32)),
 totalChunks:chunks.length,preservedChunks:chunks.filter(c=>!c.modified).length,
 changedChunks:chunks.filter(c=>c.modified).map(c=>({type:c.type,property:c.prop.name,className:classes.get(c.prop.id).name})),
 inputSHA256:crypto.createHash('sha256').update(input).digest('hex'),
 outputSHA256:crypto.createHash('sha256').update(output).digest('hex')
},null,2));
'''+anchor)
p.write_text(s,encoding='utf-8')
