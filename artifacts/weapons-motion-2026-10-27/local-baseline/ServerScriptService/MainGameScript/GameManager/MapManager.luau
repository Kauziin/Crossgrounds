local Maps={}
local storage=game.ServerStorage:FindFirstChild("CTFMaps") or Instance.new("Folder",game.ServerStorage) storage.Name="CTFMaps"
local owned={}
local current="riverside"
local publishWork=0 local disposeWork=0
local function publish(node,parent)
 local count=#node:GetDescendants()+1
 if count>250 then
  local children=node:GetChildren() local primary=node:IsA("Model") and node.PrimaryPart local pivot=node:IsA("Model") and node.WorldPivot
  for _,child in children do child.Parent=nil end node.Parent=parent
  for _,child in children do publish(child,node) end
  if node:IsA("Model") then node.PrimaryPart=primary node.WorldPivot=pivot end
 else node.Parent=parent publishWork+=count end
 if publishWork>=500 then publishWork=0 task.wait() end
end
local function dispose(node)
 local count=#node:GetDescendants()+1
 if count>250 then for _,child in node:GetChildren() do dispose(child) end count=1 end
 node:Destroy() disposeWork+=count
 if disposeWork>=500 then disposeWork=0 task.wait() end
end
local function valid(model)
 local arena=model:FindFirstChild("CTFInfrastructure")
 if not arena or not model:FindFirstChild("Geometry") then return false end
 for _,team in {"Blue","Red"} do
  local base=arena:FindFirstChild(team.."Base")
  if not base or not base:FindFirstChild("FlagStand") or not base:FindFirstChild("FlagPole") or not base:FindFirstChild("FlagBanner") or not base:FindFirstChild("Spawns") or #base.Spawns:GetChildren()==0 then return false end
 end
 return arena:FindFirstChild("TacticalCover")~=nil
end
function Maps:Catalog()
 local list={}
 for _,m in storage:GetChildren() do
  if (m:IsA("Model") or m:IsA("Folder")) and m:GetAttribute("Enabled")~=false and valid(m) then
   table.insert(list,{id=m.Name,name=m:GetAttribute("DisplayName") or m.Name,description=m:GetAttribute("Description") or "",thumbnail=m:GetAttribute("Thumbnail") or ""})
  end
 end
 table.sort(list,function(a,b) return a.id<b.id end)
 return list
end
function Maps:Initialize()
 if not storage:FindFirstChild("riverside") then
  local model=Instance.new("Model") model.Name="riverside" model:SetAttribute("DisplayName","Travessia") model:SetAttribute("Description","Três rotas entre duas bases") model:SetAttribute("TerrainOrigin",Vector3.new(-66,-16,-66))
  workspace.CTFInfrastructure:Clone().Parent=model
  local geometry=Instance.new("Folder") geometry.Name="Geometry" geometry.Parent=model
  for _,v in workspace:GetChildren() do if not v:IsA("Terrain") and (v:IsA("BasePart") or v:IsA("Model")) and not game.Players:GetPlayerFromCharacter(v) and not v:GetAttribute("CTFBot") then v:SetAttribute("CTFMapGeometry",true) v:Clone().Parent=geometry end end
  local region=workspace.Terrain:CopyRegion(Region3int16.new(Vector3int16.new(-66,-16,-66),Vector3int16.new(66,48,66))) region.Name="TerrainData" region.Parent=model model.Parent=storage
 end
 owned={}
 for _,v in workspace:GetChildren() do if v:GetAttribute("CTFMapGeometry") then table.insert(owned,v) end end
 current=workspace:GetAttribute("CurrentMapId") or "riverside"
 workspace:SetAttribute("CurrentMapId",current)
 local m=storage:FindFirstChild(current) workspace:SetAttribute("CurrentMapName",m and (m:GetAttribute("DisplayName") or m.Name) or current)
end
function Maps:SceneRoots()
 local roots={}local arena=workspace:FindFirstChild("CTFInfrastructure")if arena then table.insert(roots,arena)end
 for _,root in owned do if root.Parent==workspace then table.insert(roots,root)end end
 return roots
end
function Maps:SceneAnchors()
 local anchors={}local arena=workspace:FindFirstChild("CTFInfrastructure")
 if arena then for _,team in {"Blue","Red"}do local base=arena:FindFirstChild(team.."Base")local pads=base and base:FindFirstChild("Spawns")if pads then for _,pad in pads:GetChildren()do if pad:IsA("BasePart")then table.insert(anchors,pad.Position+Vector3.new(0,4,0))end end end end end
 return anchors
end
function Maps:Load(id)
 if id==current then return false end
 local source=storage:FindFirstChild(id)
 if not source or not valid(source) then return false,"Mapa inválido" end
 local stagedArena=source.CTFInfrastructure:Clone()
 local stagedGeometry=source.Geometry:Clone()
 local terrain=source:FindFirstChild("TerrainData") or storage.riverside:FindFirstChild("TerrainData")
 local origin=source:FindFirstChild("TerrainData") and source:GetAttribute("TerrainOrigin") or storage.riverside:GetAttribute("TerrainOrigin")
 if terrain and terrain:IsA("TerrainRegion") then
  local ok,err=pcall(function() workspace.Terrain:PasteRegion(terrain,Vector3int16.new(origin.X,origin.Y,origin.Z),true) end)
  if not ok then stagedArena:Destroy() stagedGeometry:Destroy() return false,tostring(err) end
 end
 for _,v in owned do if v.Parent then dispose(v) end end owned={}
 local old=workspace:FindFirstChild("CTFInfrastructure") if old then dispose(old) end
 publish(stagedArena,workspace)
 for _,v in stagedGeometry:GetChildren() do v:SetAttribute("CTFMapGeometry",true) publish(v,workspace) table.insert(owned,v) end stagedGeometry:Destroy()
 current=id workspace:SetAttribute("CurrentMapId",id) workspace:SetAttribute("CurrentMapName",source:GetAttribute("DisplayName") or id)
 return true
end
return Maps
