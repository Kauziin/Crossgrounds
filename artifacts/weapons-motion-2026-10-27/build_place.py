from pathlib import Path
R=Path(__file__).resolve().parents[2]
s=(R/'tools/patch_ui_audio_place.cjs').read_text(encoding='utf-8')
s=s[:s.index('const files =')]
s=s.replace("const root = path.resolve(__dirname, '..');","const root = path.resolve(__dirname, '../..');")
a=s.index('const input ='); b=s.index('\nconst classes',a)
s=s[:a]+"const input=fs.readFileSync(path.join(root,'CrossgroundsAlphaCopy-CTF.rbxl'));"+s[b:]
s+=r'''
const task=path.join(root,'artifacts/weapons-motion-2026-10-27');
const files=new Map();
function gather(folder,prefix='') {
 for(const e of fs.readdirSync(folder,{withFileTypes:true})) {
  const full=path.join(folder,e.name);
  if(e.isDirectory()) gather(full,prefix+e.name+'.');
  else if(e.name.endsWith('.luau')) files.set(prefix+e.name.slice(0,-5),fs.readFileSync(full,'utf8'));
 }
}
gather(path.join(task,'merged/src'));
gather(path.join(task,'work/tests/Unit'),'ServerStorage.WeaponsMovementTests.');
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
 const localScript=/CombatMovementController$|CombatLocomotionPose$/.test(name);
 ensure(name,localScript?'LocalScript':'ModuleScript');
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
const target=path.join(task,'Crossgrounds-Weapons-Movement-v2.rbxl');fs.writeFileSync(target,out);
fs.writeFileSync(path.join(task,'place-manifest.json'),JSON.stringify({base:'CrossgroundsAlphaCopy-CTF.rbxl',output:target,bytes:out.length,updated,newObjects:newObjects.map(o=>o.path),sha256:crypto.createHash('sha256').update(out).digest('hex')},null,2));
console.log(JSON.stringify({target,updated:updated.length,added:newObjects.length,bytes:out.length}));
'''
(R/'artifacts/weapons-motion-2026-10-27/build_place.cjs').write_text(s,encoding='utf-8')
