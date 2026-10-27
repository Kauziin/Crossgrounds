-- Studio authoring utility; never called by live game startup.
local Tools={}
local Run=game:GetService("RunService")
local Spawns=require(game.ServerScriptService.Crossgrounds.MapSpawns)
local function folder(parent,name)
 local found=parent:FindFirstChild(name) if found then return found end
 local f=Instance.new("Folder") f.Name=name f.Parent=parent return f
end
local function moveTree(node,parent)
 if #node:GetDescendants()>750 then
  local children=node:GetChildren() for _,child in children do child.Parent=nil end
  node.Parent=parent
  for _,child in children do moveTree(child,node) task.wait() end
 else node.Parent=parent end
end
local function inert(item)
 for _,d in item:GetDescendants() do
  if d:IsA("BasePart") or d:IsA("LuaSourceContainer") or d:IsA("JointInstance") or d:IsA("Constraint") or d:IsA("ProximityPrompt") or d:IsA("ClickDetector") or d:IsA("TouchTransmitter") then d:Destroy()
  elseif d:IsA("Sound") then d.Playing=false end
 end
end
function Tools.Import(mode,name,id)
 assert(not Run:IsRunning(),"Importe mapas com Play parado.")
 assert(mode=="Arena" or mode=="GetOut","Modalidade deve ser Arena ou GetOut.")
 local workshop=workspace:FindFirstChild("CrossgroundsMapWorkshop") local bucket=workshop and workshop:FindFirstChild(mode)
 local development=folder(game.ServerStorage,"Development")
 local sources=folder(folder(development,"MapSources"),mode)
 local source=(bucket and bucket:FindFirstChild(name)) or sources:FindFirstChild(name) or workspace:FindFirstChild(name)
 assert(source and (source:IsA("Model") or source:IsA("Folder")),"Coloque o Model/Folder no workshop da modalidade.")
 id=id or name:lower():gsub("[^%w]+","_"):gsub("^_+",""):gsub("_+$","")
 assert(#id>0 and #id<=40,"ID inválido.")
 local destination=folder(folder(game.ServerStorage,"CrossgroundsMaps"),mode)
 local template=Instance.new("Model") template.Name=id
 local geometry=folder(template,"Geometry") local markers=folder(template,"Spawns")
 local authored=source:FindFirstChild("SpawnRegions")
 local authoredSpawns=source:FindFirstChild("AuthoredSpawns")
 local reference,area,minimum,maximum=nil,-1,Vector3.new(math.huge,math.huge,math.huge),Vector3.new(-math.huge,-math.huge,-math.huge)
 local preferred={} local parts={}
 for _,d in source:GetDescendants() do if d:IsA("BasePart") and not (authored and d:IsDescendantOf(authored)) and not (authoredSpawns and d:IsDescendantOf(authoredSpawns)) then
  table.insert(parts,d)
  if d:IsA("SpawnLocation") then table.insert(preferred,d.CFrame) end
  local p=d.Position local half=d.Size*.5
  -- Bounds from oriented corners, including rotated meshes.
  for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
   local v=d.CFrame:PointToWorldSpace(half*Vector3.new(x,y,z)) minimum=minimum:Min(v) maximum=maximum:Max(v)
  end end end
  if d.CanCollide and d.Size.Y<8 and d.CFrame.UpVector.Y>.98 then
   local a=d.Size.X*d.Size.Z
   if a>area+1 or math.abs(a-area)<=1 and reference and p.Y<reference.Position.Y then reference=d area=a end
  end
 end end
 assert(reference and #parts>0,"Mapa sem piso sólido reconhecível.")
 local floorY=reference.Position.Y+reference.Size.Y*.5
 local center=Vector3.new((minimum.X+maximum.X)*.5,floorY,(minimum.Z+maximum.Z)*.5)
 local size=maximum-minimum
 local offset=Vector3.new(1800-center.X,80-center.Y,340-center.Z)
 local regions
 if authored then
  regions=folder(template,"SpawnRegions")
  for _,region in authored:GetChildren() do if region:IsA("BasePart") then
   local p=region:Clone() p.Anchored=true p.Transparency=1 p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CFrame=region.CFrame+offset p.Parent=regions
   local floor=region:GetAttribute("FloorY") if floor then p:SetAttribute("FloorY",floor+offset.Y) end
  end end
 end
 local count=0 local batch
 for _,part in parts do
  if count%100==0 then batch=Instance.new("Folder") batch.Name=string.format("Batch%03d",math.floor(count/100)+1) batch.Parent=geometry end
  local copy
  if part:IsA("SpawnLocation") or part:IsA("Seat") or part:IsA("VehicleSeat") then
   copy=Instance.new("Part") copy.Name=part.Name copy.Size=part.Size copy.Color=part.Color copy.Material=part.Material copy.Transparency=part.Transparency copy.CanCollide=part.CanCollide
  else copy=part:Clone() end
  inert(copy) copy.Anchored=true copy.CFrame=part.CFrame+offset copy.Parent=batch count+=1
  if count%100==0 then task.wait() end
 end
 local preview=Instance.new("Folder") preview.Name="CrossgroundsMapValidation" preview:SetAttribute("CrossgroundsOwned",true) preview.Parent=workspace
 local ok,result=pcall(function()
  for _,b in geometry:GetChildren() do b.Parent=preview task.wait() end
  local shifted={} for _,cf in preferred do table.insert(shifted,cf+offset) end
  local points={}
  if authoredSpawns then
   for _,point in authoredSpawns:GetChildren() do
    assert(point:IsA("BasePart"),"AuthoredSpawns deve conter somente marcadores BasePart.")
    local cf=point.CFrame+offset
    assert(Spawns.InRegions(cf,regions) and Spawns.Validate(preview,cf),"Spawn manual inválido: "..point.Name..". Corrija antes de reimportar.")
    table.insert(points,cf)
   end
  elseif regions and #regions:GetChildren()>0 then
   for _,region in regions:GetChildren() do if region:IsA("BasePart") then
    local level=region:GetAttribute("FloorY") or region.Position.Y-region.Size.Y*.5
    local generated=Spawns.Generate(preview,Vector3.new(region.Position.X,level,region.Position.Z),region.Size,shifted,24)
    for _,cf in generated do if Spawns.InRegions(cf,regions) then
     local unique=true for _,old in points do if (old.Position-cf.Position).Magnitude<7 then unique=false break end end
     if unique then table.insert(points,cf) end
    end end
   end end
  else points=Spawns.Generate(preview,center+offset,size,shifted,24) end
  assert(#points>=6,"Poucos spawns livres: "..#points..". Ajuste pisos/obstáculos antes de importar.")
  for i,cf in points do
   local p=Instance.new("Part") p.Name=string.format("Spawn%02d",i) p.Size=Vector3.new(1,1,1) p.CFrame=cf p.Anchored=true p.Transparency=1 p.CanCollide=false p.CanTouch=false p.CanQuery=false p:SetAttribute("SpawnRole","Player") p.Parent=markers
   if authoredSpawns then
    local authoredPoint=authoredSpawns:GetChildren()[i]
    for key,value in authoredPoint:GetAttributes()do p:SetAttribute(key,value)end
   end
  end
  return #points
 end)
 for _,b in preview:GetChildren() do b.Parent=geometry task.wait() end preview:Destroy()
 if not ok then template:Destroy() error(result,2) end
 template:SetAttribute("DisplayName",name) template:SetAttribute("Mode",mode) template:SetAttribute("SchemaVersion",1) template:SetAttribute("Enabled",true) template:SetAttribute("Sanitized",true)
 template:SetAttribute("FloorCenter",center+offset) template:SetAttribute("FloorSize",size) template:SetAttribute("SourceOffset",offset) template:SetAttribute("SpawnCount",result) template:SetAttribute("GeometryParts",count)
 template:SetAttribute("KillPlaneY",minimum.Y+offset.Y-25) template:SetAttribute("PreparationState",mode=="GetOut" and "geometry_only" or "arena_ready")
 if authoredSpawns then template:SetAttribute("SpawnAuthoring","manual") end
 local lighting=source:GetAttribute("LightingProfile")
 if typeof(lighting)=="string"then template:SetAttribute("LightingProfile",lighting)end
 local authoredKill=source:GetAttribute("AuthoredKillPlaneY")
 if typeof(authoredKill)=="number" then template:SetAttribute("KillPlaneY",authoredKill+offset.Y)end
 local old=destination:FindFirstChild(id)
 if old then moveTree(old,folder(folder(development,"Revisions"),"Maps")) old.Name=id.."_"..tostring(DateTime.now().UnixTimestampMillis) end
 moveTree(template,destination)
 source:SetAttribute("CrossgroundsMapId",id) source:SetAttribute("CrossgroundsMapMode",mode) moveTree(source,sources)
 return {id=id,mode=mode,parts=count,spawns=result}
end
return Tools
