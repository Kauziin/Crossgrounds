local H=game.HttpService
local rows=H:JSONDecode(H:GetAsync('http://127.0.0.1:18778/assets',false,{['X-Task-Token']='Vlhk8SGsKRveGQ2if21XU8CtJSeT-z_N'}))
local target=game.ReplicatedStorage.Crossgrounds
assert(not target:FindFirstChild('ProjectileTest'),'Asset folder already exists')
local root=Instance.new('Folder') root.Name='ProjectileTest'
local tools=Instance.new('Folder') tools.Name='Tools' tools.Parent=root
local objects={} local meshes={} local errors={}
local function decode(v)
 if typeof(v)~='table' then return v end
 local t,a=v.t,v.v
 if t=='ref' then return objects[a] end
 if t=='Vector3' then return Vector3.new(unpack(a)) end
 if t=='Vector2' then return Vector2.new(unpack(a)) end
 if t=='Color3' then return Color3.new(unpack(a)) end
 if t=='CFrame' then return CFrame.new(unpack(a)) end
 if t=='EnumItem' then local _,enum,name=a:match('([^%.]+)%.([^%.]+)%.([^%.]+)') return Enum[enum][name] end
 if t=='NumberRange' then return NumberRange.new(unpack(a)) end
 if t=='NumberSequence' then local k={} for _,v in a do table.insert(k,NumberSequenceKeypoint.new(v.time,v.value,v.envelope or 0))end return NumberSequence.new(k) end
 if t=='ColorSequence' then local k={}for _,v in a do table.insert(k,ColorSequenceKeypoint.new(v.time,decode(v.value)))end return ColorSequence.new(k)end
end
for _,r in rows do
 local v
 if r.class=='MeshPart' then
  local id=r.props.MeshId
  if not meshes[id] then meshes[id]=game.AssetService:CreateMeshPartAsync(Content.fromUri(id)) end
  v=meshes[id]:Clone()
 else v=Instance.new(r.class) end
 v.Name=r.name objects[r.id]=v
 if r.parent then v.Parent=objects[r.parent] else v.Parent=r.class=='Tool' and tools or root end
end
for _,r in rows do
 local v=objects[r.id]
 for key,value in r.props do if key~='MeshId' then
  local ok,err=pcall(function() v[key]=decode(value) end)
  if not ok then table.insert(errors,r.name..'.'..key..': '..tostring(err))end
 end end
 for key,value in r.attributes do v:SetAttribute(key,decode(value))end
end
for _,v in meshes do v:Destroy()end
if #errors>0 then root:Destroy() error(table.concat(errors,'\n'))end
root.Parent=target
local previews=target:FindFirstChild('LoadoutPreviews') or Instance.new('Folder',target) previews.Name='LoadoutPreviews'
for _,id in {'Blaster','AutoBlaster'} do
 assert(not previews:FindFirstChild(id),'Preview collision: '..id)
 local preview=tools[id].Blaster:Clone() preview.Name=id
 for _,v in preview:GetDescendants() do if v:IsA('BasePart') then v.Anchored=true v.CanCollide=false v.CanQuery=false end end
 preview.Parent=previews
end
return 'Imported '..#rows..' nodes into '..root:GetFullName()
