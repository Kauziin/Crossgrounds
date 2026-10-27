// Preserve every original RBXL chunk except the Source properties being updated.
// The resulting file must be reopened and checked with Roblox Studio before delivery.
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');
const crypto = require('node:crypto');
const root = path.resolve(__dirname, '../..');
const homeOnly = process.argv.includes('--home');
const input=fs.readFileSync(path.join(root,'CrossgroundsAlphaCopy-CTF.rbxl'));
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

const task=path.join(root,'artifacts/projectile-port-2026-10-27');
const files=new Map();
function gather(folder,prefix='') {
 for(const e of fs.readdirSync(folder,{withFileTypes:true})) {
  const full=path.join(folder,e.name);
  if(e.isDirectory()) gather(full,prefix+e.name+'.');
  else if(e.name.endsWith('.luau')) files.set(prefix+e.name.slice(0,-5),fs.readFileSync(full,'utf8'));
 }
}
gather(path.join(root,'src'));
gather(path.join(task,'work/src'));

const byPath=new Map([...objects.keys()].map(ref=>[objectPath(ref),ref]));
let nextRef=[...objects.keys()].reduce((a,b)=>Math.max(a,b),0)+1;
let nextClass=Math.max(...classes.keys())+1;
const newObjects=[];
function ensure(name,className) {
 if(byPath.has(name)) return byPath.get(name);
 const parts=name.split('.'), leaf=parts.pop(),parentName=parts.join('.');
 if(!parentName) throw Error('Missing service '+name);
 const parent=ensure(parentName,'Folder');
 const ref=nextRef++; byPath.set(name,ref);
 newObjects.push({ref,parent,name:leaf,className,path:name});
 return ref;
}
for(const name of files.keys()) {
 const localScript=/GraphicsController$|CombatMovementController$|CombatLocomotionPose$/.test(name);
 const actual=JSON.parse(fs.readFileSync(path.join(task,'script-classes.json'),'utf8')); ensure(name,actual[name] || (localScript?'LocalScript':'ModuleScript'));
}
function encodeString(value) {
 const b=Buffer.from(value,'utf8'),n=Buffer.alloc(4);n.writeUInt32LE(b.length);return Buffer.concat([n,b]);
}
function u32(value) {const b=Buffer.alloc(4);b.writeUInt32LE(value);return b;}
function encodeRefs(values) {
 const n=values.length,b=Buffer.alloc(n*4);let previous=0;
 values.forEach((value,i)=>{const d=value-previous,v=((d<<1)^(d>>31))>>>0;previous=value;
 b[i]=v>>>24;b[n+i]=v>>>16;b[2*n+i]=v>>>8;b[3*n+i]=v;});return b;
}
function chunk(type,data) {
 const h=Buffer.alloc(16);h.write(type,0,'ascii');h.writeUInt32LE(data.length,8);return Buffer.concat([h,data]);
}
const updated=[];
for(const c of chunks) {
 if(c.prop?.name!=='Source') continue;
 const {id,pos,type}=c.prop;if(type!==1) throw Error('Unknown Source encoding');
 let cursor=pos+1;const values=[];let modified=false;
 for(const ref of classes.get(id).ids) {
  const [source,next]=str(c.data,cursor);cursor=next;const name=objectPath(ref);
  if(files.has(name)) {values.push(encodeString(files.get(name)));files.delete(name);updated.push(name);modified=true;}
  else values.push(encodeString(source));
 }
 if(modified)c.raw=chunk('PROP',Buffer.concat([c.data.subarray(0,pos+1),...values]));
}
const additions=[];
for(const className of [...new Set(newObjects.map(o=>o.className))]) {
 const group=newObjects.filter(o=>o.className===className),id=nextClass++;
 additions.push(chunk('INST',Buffer.concat([u32(id),encodeString(className),Buffer.from([0]),u32(group.length),encodeRefs(group.map(o=>o.ref))])));
 additions.push(chunk('PROP',Buffer.concat([u32(id),encodeString('Name'),Buffer.from([1]),...group.map(o=>encodeString(o.name))])));
 if(className!=='Folder')additions.push(chunk('PROP',Buffer.concat([u32(id),encodeString('Source'),Buffer.from([1]),...group.map(o=>encodeString(files.get(o.path)))])));
 for(const o of group) files.delete(o.path);
}
if(files.size)throw Error('Unwritten source '+[...files.keys()]);
const prnt=chunks.find(c=>c.type==='PRNT');const n=prnt.data.readUInt32LE(1);
const children=refs(prnt.data,5,n),parents=refs(prnt.data,5+4*n,n);
for(const o of newObjects){children.push(o.ref);parents.push(o.parent);}
prnt.raw=chunk('PRNT',Buffer.concat([prnt.data.subarray(0,1),u32(children.length),encodeRefs(children),encodeRefs(parents)]));
const header=Buffer.from(input.subarray(0,32));
header.writeUInt32LE(header.readUInt32LE(16)+(nextClass-Math.max(...classes.keys())-1),16);
header.writeUInt32LE(header.readUInt32LE(20)+newObjects.length,20);
const out=Buffer.concat([header,...chunks.flatMap(c=>c.type==='PRNT'?[...additions,c.raw]:[c.raw])]);
const target=path.join(task,'Crossgrounds-Projectile-Port-Final.rbxl');fs.writeFileSync(target,out);
fs.writeFileSync(path.join(task,'place-manifest.json'),JSON.stringify({base:'CrossgroundsAlphaCopy-CTF.rbxl',output:target,bytes:out.length,updated,newObjects:newObjects.map(o=>o.path),sha256:crypto.createHash('sha256').update(out).digest('hex')},null,2));
console.log(JSON.stringify({target,updated:updated.length,added:newObjects.length,bytes:out.length}));
