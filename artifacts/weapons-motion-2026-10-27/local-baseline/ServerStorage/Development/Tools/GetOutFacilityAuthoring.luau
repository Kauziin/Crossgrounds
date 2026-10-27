-- Manual one-time authoring for the existing sanitized Facility template.
-- Run Apply() in edit mode only. Existing GetOut markers are never overwritten.
local Author={}
local function near(a,b) return (a-b).Magnitude<.3 end
local function blocker(map,position)
 local result
 for _,part in map.Geometry:GetDescendants() do
  if part:IsA("BasePart") and part.CanCollide and near(part.Position,position)
   and near(part.Size,Vector3.new(2,7,6)) then
   if result then error("Bloqueador de saída ambíguo em "..tostring(position)) end
   result=part
  end
 end
 assert(result,"Bloqueador de saída não encontrado em "..tostring(position))
 return result
end
local function wheelAssembly(map,position)
 local found={}
 for _,part in map.Geometry:GetDescendants() do
  if part:IsA("BasePart") and part.CanCollide and near(part.Position,position)
   and ((near(part.Size,Vector3.new(1,2,2))) or (near(part.Size,Vector3.new(4,1,2)))) then
   table.insert(found,part)
  end
 end
 assert(#found==3,"Conjunto da roda de saída incompleto em "..tostring(position))
 return found
end
local function folder(parent,name)
 local f=Instance.new("Folder") f.Name=name f.Parent=parent return f
end
local function label(part,text)
 local gui=Instance.new("BillboardGui") gui.Name="GetOutLabel" gui.Size=UDim2.fromOffset(130,32)
 gui.StudsOffset=Vector3.new(0,2,0) gui.MaxDistance=45 gui.AlwaysOnTop=false gui.Parent=part
 local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundColor3=Color3.fromRGB(19,29,38)
 t.BackgroundTransparency=.2 t.TextColor3=Color3.fromRGB(244,248,250)
 t.Font=Enum.Font.GothamBold t.TextSize=13 t.Text=text t.Parent=gui
 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,5) c.Parent=t
end
local function marker(parent,name,id,cf,size,color,transparency,visibleLabel)
 local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf p.Anchored=true
 p.CanCollide=false p.CanTouch=false p.CanQuery=true p.Material=Enum.Material.Metal
 p.Color=color p.Transparency=transparency or 0 p.Parent=parent
 if id then p:SetAttribute("ObjectiveId",id) end
 if visibleLabel then label(p,visibleLabel) end
 return p
end

function Author.Apply()
 local map=game.ServerStorage.CrossgroundsMaps.GetOut:FindFirstChild("facility")
 assert(map and map:GetAttribute("Sanitized")==true,"Template Facility sanitizado ausente")
 assert(not map:FindFirstChild("GetOut"),"GetOut já foi autorado; nada foi substituído")
 local first=blocker(map,Vector3.new(1730,84.5,237.5))
 local second=blocker(map,Vector3.new(1932,84.5,421.5))
 local firstWheel=wheelAssembly(map,Vector3.new(1730,84,239))
 local secondWheel=wheelAssembly(map,Vector3.new(1930.5,84,421.5))
 for _,id in {"Spawn01","Spawn03","Spawn05","Spawn07","Spawn11"} do
  assert(map.Spawns:FindFirstChild(id),"Spawn ausente: "..id)
 end
 local root=Instance.new("Folder") root.Name="GetOut"
 root:SetAttribute("SupportedRoutes","locks")
 root:SetAttribute("AuthoringVersion",1)
 local hidden=Color3.fromRGB(20,40,50)
 marker(root,"BeastSpawn",nil,map.Spawns.Spawn07.CFrame,Vector3.new(2,1,2),hidden,1)
 local survivors=folder(root,"SurvivorSpawns")
 for i,id in {"Spawn01","Spawn03","Spawn05","Spawn11"} do
  marker(survivors,"Survivor"..i,"survivor"..i,map.Spawns[id].CFrame,Vector3.new(2,1,2),hidden,1)
 end
 local pcs=folder(root,"Computers")
 for i,position in {
  Vector3.new(1924.7,83,459),Vector3.new(1840.3,83,218),
  Vector3.new(1740.5,83,260.8),Vector3.new(1734.7,83,438),
 } do
  marker(pcs,"PC"..i,"pc"..i,CFrame.new(position),Vector3.new(2.5,2,1.5),Color3.fromRGB(73,130,177),.15,"PC "..i)
 end
 local doors=folder(root,"ExitDoors")
 marker(doors,"Exit1","door1",CFrame.new(1730,84.5,237.5),Vector3.new(6,7,1),Color3.fromRGB(177,65,58),.65,"SAÍDA A")
 marker(doors,"Exit2","door2",CFrame.new(1932,84.5,421.5),Vector3.new(1,7,6),Color3.fromRGB(177,65,58),.65,"SAÍDA B")
 local zones=folder(root,"ExitZones")
 marker(zones,"Escape1","door1",CFrame.new(1730,84,231.5),Vector3.new(8,8,8),hidden,1).CanTouch=true
 marker(zones,"Escape2","door2",CFrame.new(1938,84,421.5),Vector3.new(8,8,8),hidden,1).CanTouch=true
 local cranks=folder(root,"Cranks")
 marker(cranks,"Crank1","door1",CFrame.new(1730,84,243),Vector3.new(2,2,2),Color3.fromRGB(199,145,66),.1,"MANIVELA A")
 marker(cranks,"Crank2","door2",CFrame.new(1927,84,421.5),Vector3.new(2,2,2),Color3.fromRGB(199,145,66),.1,"MANIVELA B")
 local locks=folder(root,"Locks")
 for i,position in {
  Vector3.new(1728,86,239),Vector3.new(1732,86,239),
  Vector3.new(1931,86,419),Vector3.new(1931,86,424),
 } do marker(locks,"Lock"..i,"lock"..i,CFrame.new(position),Vector3.new(1,1,1),Color3.fromRGB(183,72,65),0,"TRAVA "..i) end
 local pods=folder(root,"FreezePods")
 for i,position in {
  Vector3.new(1646,80,173.5),Vector3.new(1854,82,287.5),
  Vector3.new(1819,82,401.5),Vector3.new(1905,82,411.5),
 } do marker(pods,"Pod"..i,"pod"..i,CFrame.new(position),Vector3.new(2,2,2),Color3.fromRGB(89,154,185),.2,"POD "..i) end
 local panels=folder(root,"ContainmentPanels")
 marker(panels,"Panel1","panel1",CFrame.new(1790,84,241.5),Vector3.new(2,2,1),Color3.fromRGB(175,74,66),.1,"QUADRO")
 marker(panels,"Panel2","panel2",CFrame.new(1854,84,287.5),Vector3.new(2,2,1),Color3.fromRGB(175,74,66),.1,"QUADRO")
 local chamber=marker(root,"ContainmentChamber",nil,CFrame.new(1812.85,84,353.64),Vector3.new(12,8,12),Color3.fromRGB(162,80,58),.88)
 chamber.Material=Enum.Material.Neon
 local light=Instance.new("PointLight") light.Color=Color3.fromRGB(236,120,69)
 light.Brightness=2 light.Range=22 light.Enabled=false light.Parent=chamber
 marker(root,"ContainmentLever",nil,CFrame.new(1803,84,353.64),Vector3.new(2,3,2),Color3.fromRGB(183,137,77),.15,"ALAVANCA")
 marker(root,"ContainmentDoor",nil,CFrame.new(1818.8,84,353.64),Vector3.new(1,7,10),Color3.fromRGB(204,92,68),.8)
 root:SetAttribute("Authored",true)
 -- Physical blockers are tagged rather than inferred at runtime.
 first:SetAttribute("GetOutExitDoorId","door1")
 second:SetAttribute("GetOutExitDoorId","door2")
 for _,part in firstWheel do part:SetAttribute("GetOutExitDoorId","door1") end
 for _,part in secondWheel do part:SetAttribute("GetOutExitDoorId","door2") end
 root.Parent=map
 map:SetAttribute("PreparationState","get_out_locks_prototype")
 return {map=map.Name,pcs=4,locks=4,doors=2,pods=4,containment=true}
end

return Author
