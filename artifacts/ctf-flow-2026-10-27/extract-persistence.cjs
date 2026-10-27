// Preserve every original RBXL chunk except the Source properties being updated.
// The resulting file must be reopened and checked with Roblox Studio before delivery.
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');
const crypto = require('node:crypto');
const root = path.resolve(__dirname, '../..');
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
const wanted=new Set(['ServerScriptService.MainGameScript.GameManager.SettingsService','ServerScriptService.Crossgrounds.ProgressionService']);
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
