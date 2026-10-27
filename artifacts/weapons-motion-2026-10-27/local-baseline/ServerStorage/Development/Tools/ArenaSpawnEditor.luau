-- Manual Studio workspace. Geometry is a reference; Apply saves spawns and regions only.
local Editor={}
local Storage=game:GetService("ServerStorage")
local Run=game:GetService("RunService")
local Validator=require(game.ServerScriptService.Crossgrounds.MapSpawns)
local ROOT="ArenaSpawnEditor"
local OWNER="CrossgroundsArenaSpawnEditor"
local function editOnly() assert(not Run:IsRunning(),"Use com Play parado.") end
local function folder(parent,name)
 local f=parent:FindFirstChild(name)
 if not f then f=Instance.new("Folder") f.Name=name f.Parent=parent end
 return f
end
local function root()
 local r=workspace:FindFirstChild(ROOT)
 assert(r and r:GetAttribute(OWNER)==true,"Abra a área de edição primeiro.")
 return r
end
local function bounds(geometry)
 local lo=Vector3.new(math.huge,math.huge,math.huge) local hi=-lo local count=0
 for _,p in geometry:GetDescendants() do if p:IsA("BasePart") then
  for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
   local point=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)*.5)
   lo=lo:Min(point) hi=hi:Max(point)
  end end end
  count+=1 if count%500==0 then task.wait() end
 end end
 assert(count>0,"Mapa sem geometria.") return lo,hi,count
end
-- Bound the cost of each DataModel insertion, including older large geometry batches.
local function publish(node,parent)
 if #node:GetDescendants()>300 then
  local children=node:GetChildren()
  local primary=node:IsA("Model") and node.PrimaryPart
  local pivot=node:IsA("Model") and node.WorldPivot
  for _,child in children do child.Parent=nil end
  node.Parent=parent
  for _,child in children do publish(child,node) end
  if node:IsA("Model") then node.PrimaryPart=primary node.WorldPivot=pivot end
 else node.Parent=parent end
 task.wait()
end
local function displayPart(p,offset,region)
 p.CFrame+=offset p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
 p.Locked=false p.Material=Enum.Material.Neon p.CastShadow=false
 p.Color=region and Color3.fromRGB(74,150,255) or Color3.fromRGB(40,235,170)
 p.Transparency=region and .92 or .25
 if not region then
  p.Size=Vector3.new(2,1,3)
  local face=Instance.new("SurfaceGui") face.Name="EditorDirection" face.Face=Enum.NormalId.Top
  face.CanvasSize=Vector2.new(120,180) face.LightInfluence=0 face.Parent=p
  local arrow=Instance.new("TextLabel") arrow.Size=UDim2.fromScale(1,1) arrow.BackgroundTransparency=1
  arrow.Text="FRONT\n↑" arrow.TextScaled=true arrow.TextColor3=Color3.new(0,0,0) arrow.Parent=face
 else
  local floor=p:GetAttribute("FloorY") if typeof(floor)=="number" then p:SetAttribute("FloorY",floor+offset.Y) end
 end
end
function Editor.Open()
 editOnly()
 assert(not workspace:FindFirstChild(ROOT),"Área já existe; edite-a ou use Close() antes de reabrir.")
 local library=Storage.CrossgroundsMaps.Arena local sources=library:GetChildren()
 table.sort(sources,function(a,b)return a.Name<b.Name end)
 local plans={} local maxX,maxZ=0,0
 for _,source in sources do
  local lo,hi,count=bounds(source.Geometry)
  table.insert(plans,{source=source,lo=lo,hi=hi,count=count})
  maxX=math.max(maxX,hi.X-lo.X) maxZ=math.max(maxZ,hi.Z-lo.Z)
 end
 -- Put the entire grid beyond the current scene, including existing workshops.
 local sceneMaxZ=0
 for i,p in workspace:GetDescendants() do
  if p:IsA("BasePart") then sceneMaxZ=math.max(sceneMaxZ,p.Position.Z+p.Size.Magnitude*.5) end
  if i%1000==0 then task.wait() end
 end
 local r=Instance.new("Folder") r.Name=ROOT r:SetAttribute(OWNER,true) r:SetAttribute("EditorOnly",true) r.Parent=workspace
 local gap=140 local columns=4 local origin=Vector3.new(1000,0,sceneMaxZ+1000)
 local report={}
 for index,plan in plans do
  local source=plan.source local col=(index-1)%columns local row=math.floor((index-1)/columns)
  local target=origin+Vector3.new(col*(maxX+gap),0,row*(maxZ+gap))
  local center=(plan.lo+plan.hi)*.5
  -- These imports have their actual play floors below zero, under other maps' ocean dressing.
  local elevation=(source.Name=="beach" or source.Name=="glacier")and 400 or 0
  local offset=Vector3.new(target.X-center.X,elevation,target.Z-center.Z)
  local map=Instance.new("Model") map.Name=source.Name map:SetAttribute("MapId",source.Name)
  map:SetAttribute("EditorOffset",offset) map:SetAttribute("DisplayName",source:GetAttribute("DisplayName") or source.Name)
  map.Parent=r
  local geometry=source.Geometry:Clone()
  for i,obj in geometry:GetDescendants() do
   if obj:IsA("BasePart") then obj.CFrame+=offset obj.Locked=true
   elseif obj:IsA("BlockMesh") and obj.Parent:IsA("BasePart") and obj.Parent.Name:lower():find("water",1,true) then
    local size=obj.Parent.Size
    obj.Scale=Vector3.new(math.min(obj.Scale.X,(maxX+30)/size.X),obj.Scale.Y,math.min(obj.Scale.Z,(maxZ+30)/size.Z))
   elseif obj:IsA("SurfaceGui") and obj.Parent:IsA("BasePart") and obj.Parent.Name:lower():find("water",1,true) then obj.Enabled=false
   elseif obj:IsA("Sound") then obj.Playing=false end
   if i%500==0 then task.wait() end
  end
  publish(geometry,map)
  local points=source.Spawns:Clone()
  for _,p in points:GetChildren() do if p:IsA("BasePart") then displayPart(p,offset,false) end end
  publish(points,map)
  local regions=source:FindFirstChild("SpawnRegions")
  if regions then
   regions=regions:Clone()
   for _,p in regions:GetChildren() do if p:IsA("BasePart") then displayPart(p,offset,true) end end
   publish(regions,map)
  end
  local anchor=Instance.new("Part") anchor.Name="MapLabel" anchor.Anchored=true
  anchor.CanCollide=false anchor.CanTouch=false anchor.CanQuery=false anchor.Transparency=1 anchor.Locked=true
  anchor.Position=Vector3.new(target.X,plan.hi.Y+offset.Y+15,target.Z) anchor.Parent=map
  local gui=Instance.new("BillboardGui") gui.Size=UDim2.fromOffset(300,60) gui.MaxDistance=3500 gui.AlwaysOnTop=true gui.Parent=anchor
  local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1) text.BackgroundColor3=Color3.fromRGB(17,26,40)
  text.BackgroundTransparency=.15 text.TextColor3=Color3.new(1,1,1) text.TextScaled=true
  text.Text=map:GetAttribute("DisplayName").."\n"..source.Name text.Parent=gui
  table.insert(report,{id=source.Name,parts=plan.count,spawns=#points:GetChildren(),offset=tostring(offset)})
 end
 game:GetService("Selection"):Set({r:FindFirstChild("shipment") or r:GetChildren()[1]})
 return report
end
local function selected(id)
 local r=root() local maps={}
 if id then local map=r:FindFirstChild(id) assert(map,"ID de mapa não encontrado.") table.insert(maps,map)
 else for _,map in r:GetChildren() do if map:IsA("Model") then table.insert(maps,map) end end end
 table.sort(maps,function(a,b)return a.Name<b.Name end) return maps
end
function Editor.Validate(id)
 editOnly() local reports={}
 for _,map in selected(id) do
  local report={id=map:GetAttribute("MapId"),points=0,valid=0,invalid={}}
  assert(map:FindFirstChild("Geometry") and map:FindFirstChild("Spawns"),"Geometria/Spawns ausentes em "..map.Name)
  for _,p in map.Spawns:GetChildren() do if p:IsA("BasePart") then
   report.points+=1
   local inRegion=Validator.InRegions(p.CFrame,map:FindFirstChild("SpawnRegions"))
   local clear=Validator.Validate(map.Geometry,p.CFrame)
   if inRegion and clear then report.valid+=1 p.Color=Color3.fromRGB(40,235,170)
   else
    p.Color=Color3.fromRGB(255,80,70)
    table.insert(report.invalid,{name=p.Name,reason=not inRegion and "Fora de SpawnRegions" or "Sem piso ou sem espaço livre"})
   end
  end end
  report.canApply=report.valid>=4 and #report.invalid==0 table.insert(reports,report)
 end
 return reports
end
function Editor.Apply(id,options)
 editOnly() local reports=Editor.Validate(id)
 for _,report in reports do
  assert(report.canApply or options and options.PreserveInvalid==true and report.valid>=4,"Corrija os spawns de "..report.id.." antes de salvar (mínimo 4; todos válidos).")
 end
 local prepared={}
 for _,map in selected(id) do
  local mapId=map:GetAttribute("MapId") local source=Storage.CrossgroundsMaps.Arena:FindFirstChild(mapId)
  assert(source,"Template removido: "..tostring(mapId))
  local offset=map:GetAttribute("EditorOffset") assert(typeof(offset)=="Vector3","Deslocamento ausente.")
  local points=Instance.new("Folder") points.Name="Spawns" local count=0
  for _,p in map.Spawns:GetChildren() do if p:IsA("BasePart") then
   count+=1 local copy=Instance.new("Part") copy.Name=string.format("Spawn%03d",count)
   for key,value in p:GetAttributes() do copy:SetAttribute(key,value) end
   copy:SetAttribute("SpawnRole",p:GetAttribute("SpawnRole") or "Player")
   copy.Size=Vector3.one copy.CFrame=p.CFrame-offset copy.Anchored=true copy.Transparency=1
   copy.CanCollide=false copy.CanTouch=false copy.CanQuery=false copy.Parent=points
  end end
  local regions=map:FindFirstChild("SpawnRegions") local savedRegions
  if regions then
   savedRegions=Instance.new("Folder") savedRegions.Name="SpawnRegions"
   for _,p in regions:GetChildren() do if p:IsA("BasePart") then
    local copy=Instance.new("Part") copy.Name=p.Name copy.Size=p.Size copy.CFrame=p.CFrame-offset
    for key,value in p:GetAttributes() do copy:SetAttribute(key,value) end
    local floor=copy:GetAttribute("FloorY") if typeof(floor)=="number" then copy:SetAttribute("FloorY",floor-offset.Y) end
    copy.Anchored=true copy.Transparency=1 copy.CanCollide=false copy.CanTouch=false copy.CanQuery=false copy.Parent=savedRegions
   end end
  end
  table.insert(prepared,{source=source,points=points,regions=savedRegions})
 end
 local revisions=folder(folder(folder(Storage,"Development"),"Revisions"),"Maps")
 game:GetService("ChangeHistoryService"):SetWaypoint("Before Arena spawn edits")
 for _,item in prepared do
  local backup=Instance.new("Folder") backup.Name=item.source.Name.."_spawns_"..os.date("!%Y%m%d_%H%M%S").."_"..#revisions:GetChildren()
  backup:SetAttribute("MapId",item.source.Name) backup:SetAttribute("RevisionType","SpawnsOnly") backup.Parent=revisions
  backup:SetAttribute("PreviousSpawnCount",item.source:GetAttribute("SpawnCount"))
  item.source.Spawns.Parent=backup
  local oldRegions=item.source:FindFirstChild("SpawnRegions") if oldRegions then oldRegions.Parent=backup end
  item.points.Parent=item.source if item.regions then item.regions.Parent=item.source end
  item.source:SetAttribute("SpawnCount",#item.points:GetChildren())
  -- Keep hand-authored source markers current when this map uses explicit authoring.
  for _,original in Storage.Development.MapSources.Arena:GetChildren() do
   if original:GetAttribute("CrossgroundsMapId")==item.source.Name and original:FindFirstChild("AuthoredSpawns") then
    local offset=item.source:GetAttribute("SourceOffset")
    assert(typeof(offset)=="Vector3","SourceOffset ausente.")
    original.AuthoredSpawns.Name="SourceAuthoredSpawns" original.SourceAuthoredSpawns.Parent=backup
    local authored=item.points:Clone()authored.Name="AuthoredSpawns"
    for _,p in authored:GetChildren()do if p:IsA("BasePart")then p.CFrame-=offset end end authored.Parent=original
    local previous=original:FindFirstChild("SpawnRegions")if previous then previous.Name="SourceRegions"previous.Parent=backup end
    if item.regions then
     local regions=item.regions:Clone()
     for _,p in regions:GetChildren()do if p:IsA("BasePart")then p.CFrame-=offset local floor=p:GetAttribute("FloorY")if typeof(floor)=="number"then p:SetAttribute("FloorY",floor-offset.Y)end end end
     regions.Parent=original
    end
   end
  end
 end
 game:GetService("ChangeHistoryService"):SetWaypoint("Arena spawn edits saved")
 return reports
end
local function relocate(node,parent)
 local work=0
 local function move(item,destination)
  local count=#item:GetDescendants()+1
  if count>250 then
   local children=item:GetChildren()local primary=item:IsA("Model")and item.PrimaryPart local pivot=item:IsA("Model")and item.WorldPivot
   for _,child in children do child.Parent=nil end item.Parent=destination
   for _,child in children do move(child,item)end
   if item:IsA("Model")then item.PrimaryPart=primary item.WorldPivot=pivot end
  else item.Parent=destination work+=count end
  if work>=500 then work=0 task.wait()end
 end
 move(node,parent)
end
function Editor.ParkForPlay()
 assert(Run:IsRunning(),"Usado somente pela inicialização da simulação.")
 local r=workspace:FindFirstChild(ROOT)if not r then return end
 assert(r:GetAttribute(OWNER)==true,"Área externa de edição preservada.")
 relocate(r,folder(folder(folder(Storage,"Development"),"Editors"),"RuntimePreviews"))
end
function Editor.Store()
 editOnly()local r=root()
 local editors=folder(folder(Storage,"Development"),"Editors")
 assert(not editors:FindFirstChild(ROOT),"Já existe uma edição guardada; preserve-a antes de substituir.")
 local report=Editor.Apply(nil,{PreserveInvalid=true})
 local total,invalid=0,0
 for _,row in report do
  total+=row.points invalid+=#row.invalid
  local map=Storage.CrossgroundsMaps.Arena[row.id]
  map:SetAttribute("ValidatedSpawnCount",row.valid)map:SetAttribute("SpawnsNeedReview",#row.invalid>0)
 end
 r:SetAttribute("StoredSpawnCount",total)r:SetAttribute("InvalidStoredSpawnCount",invalid)
 relocate(r,editors)
 return {maps=#report,spawns=total,invalid=invalid,reports=report,path=r:GetFullName()}
end
function Editor.Restore()
 editOnly()assert(not workspace:FindFirstChild(ROOT),"Área já está aberta.")
 local editors=Storage.Development:FindFirstChild("Editors")local r=editors and editors:FindFirstChild(ROOT)
 assert(r and r:GetAttribute(OWNER)==true,"Nenhuma edição guardada.")
 relocate(r,workspace)return {path=r:GetFullName(),maps=#r:GetChildren()}
end
function Editor.Close()
 editOnly() local r=root()
 -- Only removes this tool's explicit preview; templates and editable originals stay stored.
 local function dispose(node)
  if #node:GetDescendants()>300 then
   for _,child in node:GetChildren() do dispose(child) end
  end
  node:Destroy() task.wait()
 end
 dispose(r)
end
return Editor
