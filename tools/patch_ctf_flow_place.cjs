// Preserve every original RBXL chunk except the Source properties being updated.
// The resulting file must be reopened and checked with Roblox Studio before delivery.
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');
const crypto = require('node:crypto');
const root = path.resolve(__dirname, '..');
const homeOnly = false;
const input = fs.readFileSync(path.join(root,'artifacts/ctf-flow-2026-10-27/before.rbxl'));
const classes = new Map(), objects = new Map(), chunks = [];
function str(buf, offset) {
 const n = buf.readUInt32LE(offset);
 return [buf.toString('utf8', offset + 4, offset + 4 + n), offset + 4 + n];
}
function refs(buf, offset, n) {
 const out = []; let last = 0;
 for (let i = 0; i < n; i++) {
  const v = ((buf[offset+i]*0x1000000) + (buf[offset+n+i]<<16) + (buf[offset+2*n+i]<<8) + buf[offset+3*n+i]) >>> 0;
  last += (v >>> 1) ^ -(v & 1); out.push(last);
 }
 return out;
}
for (let offset = 32; offset < input.length;) {
 const type = input.toString('ascii', offset, offset + 4);
 const compressed = input.readUInt32LE(offset+4), size = input.readUInt32LE(offset+8);
 const end = offset+16+(compressed || size);
 const raw = input.subarray(offset,end), body = input.subarray(offset+16,end);
 const data = compressed ? zlib.zstdDecompressSync(body) : body;
 if (data.length !== size) throw Error('Chunk size mismatch');
 const chunk = {type, raw, data}; chunks.push(chunk);
 if (type === 'INST') {
  const id = data.readUInt32LE(0), [name, pos] = str(data, 4);
  const n = data.readUInt32LE(pos+1), ids = refs(data,pos+5,n);
  classes.set(id,{name,ids});
  for (const ref of ids) objects.set(ref,{className:name});
 }
 if (type === 'PROP') {
  const id = data.readUInt32LE(0), [name, pos] = str(data,4);
  chunk.prop = {id,name,pos,type:data[pos]};
  if (name === 'Name') {
   if (data[pos] !== 1) throw Error('Unsupported Name encoding');
   let cursor = pos+1;
   for (const ref of classes.get(id).ids) {
    const result = str(data,cursor); objects.get(ref).name=result[0]; cursor=result[1];
   }
  }
 }
 if (type === 'PRNT') {
  const n=data.readUInt32LE(1), children=refs(data,5,n), parents=refs(data,5+4*n,n);
  children.forEach((ref,i)=>{objects.get(ref).parent=parents[i];});
 }
 offset=end;
}
function objectPath(ref, seen = new Set()) {
 const o=objects.get(ref); if (!o) return '';
 if (seen.has(ref)) throw Error('Parent cycle'); seen.add(ref);
 const parent=objectPath(o.parent,seen); return (parent ? parent+'.' : '')+o.name;
}
if (process.argv.includes('--inspect')) {
 console.log(chunks.filter(c=>c.prop?.name==='Source').map(c=>({className:classes.get(c.prop.id).name,type:c.prop.type,instances:classes.get(c.prop.id).ids.length})));
 process.exit(0);
}
const files = ['ReplicatedFirst.CrossgroundsLoading', 'StarterPlayer.StarterPlayerScripts.CTFFlagLabels', 'StarterPlayer.StarterPlayerScripts.JoinMenu', 'ServerScriptService.Crossgrounds.CTFAdapter', 'ServerScriptService.Crossgrounds.ProgressionBalance', 'ServerScriptService.Crossgrounds.ProgressionService', 'ServerScriptService.Crossgrounds.SceneLoadService', 'ServerScriptService.MainGameScript.GameManager', 'ServerScriptService.MainGameScript.GameManager.FlagService', 'ServerScriptService.MainGameScript.GameManager.MapManager', 'ServerScriptService.MainGameScript.GameManager.PlayerManager', 'ServerScriptService.MainGameScript.GameManager.SettingsService'];
const pending=new Set(files), updated=[];
for (const chunk of chunks) {
 if (chunk.prop?.name !== 'Source') continue;
 const {id,pos,type}=chunk.prop;
 if (type!==1) throw Error('Unsupported Source encoding: '+type);
 let cursor=pos+1; const values=[]; let changed=false;
 for (const ref of classes.get(id).ids) {
  const [source,next]=str(chunk.data,cursor); cursor=next;
  const name=objectPath(ref);
  const value=pending.has(name) ? fs.readFileSync(path.join(root,'artifacts/ctf-flow-2026-10-27/src',...name.split('.'))+'.luau','utf8') : source;
  if (pending.has(name)) {pending.delete(name);updated.push(name);changed=true;}
  const bytes=Buffer.from(value,'utf8'), len=Buffer.alloc(4);len.writeUInt32LE(bytes.length);
  values.push(len,bytes);
 }
 if (cursor!==chunk.data.length) throw Error('Trailing Source data');
 if (!changed) continue;
 const data=Buffer.concat([chunk.data.subarray(0,pos+1),...values]);
 const header=Buffer.alloc(16);header.write('PROP',0,'ascii');header.writeUInt32LE(data.length,8);
 chunk.raw=Buffer.concat([header,data]);
 chunk.modified=true;
}
if (pending.size) throw Error('Missing sources: '+[...pending]);
const out=path.join(root,'CrossgroundsAlphaCopy-CTF.rbxl');
const output=Buffer.concat([input.subarray(0,32),...chunks.map(c=>c.raw)]);
if (process.argv.includes('--manifest')) {
 if (!fs.readFileSync(out).equals(output)) throw Error('Saved place differs from generated result');
} else fs.writeFileSync(out,output);
if (homeOnly) {
 const modified=chunks.filter(c=>c.modified);
 if (modified.length!==1 || classes.get(modified[0].prop.id).name!=='LocalScript') throw Error('Unexpected binary changes');
 const hash=data=>crypto.createHash('sha256').update(data).digest('hex');
 fs.writeFileSync(path.join(root,'artifacts/home-screen-2026-10-27/build-manifest.json'),JSON.stringify({
  input:'artifacts/ui-audio-2026-10-26/Crossgrounds-UI-Audio.rbxl',output:out,
  runtimeSources:updated,headerPreserved:true,totalChunks:chunks.length,preservedChunks:chunks.length-modified.length,
  changedChunks:modified.map(c=>({chunk:c.type,property:c.prop.name,className:classes.get(c.prop.id).name})),
  sha256:hash(fs.readFileSync(out)),sourceSHA256:hash(fs.readFileSync(path.join(root,'src/StarterPlayer/StarterPlayerScripts/HubController.luau')))
 },null,2));
}
fs.writeFileSync(path.join(root,'artifacts/ctf-flow-2026-10-27/build-manifest.json'),JSON.stringify({
 input:'artifacts/ctf-flow-2026-10-27/before.rbxl',output:out,sources:updated,
 headerPreserved:output.subarray(0,32).equals(input.subarray(0,32)),
 totalChunks:chunks.length,preservedChunks:chunks.filter(c=>!c.modified).length,
 changedChunks:chunks.filter(c=>c.modified).map(c=>({type:c.type,property:c.prop.name,className:classes.get(c.prop.id).name})),
 inputSHA256:crypto.createHash('sha256').update(input).digest('hex'),
 outputSHA256:crypto.createHash('sha256').update(output).digest('hex')
},null,2));
console.log(JSON.stringify({out,updated}));
