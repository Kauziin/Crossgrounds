-- Studio-only composition of a wider three-lane CTF map. Imported sources remain untouched.
local Author={}
local Storage=game:GetService("ServerStorage")
local ID="riverside_wide" local Y=80
local colors={ground=Color3.fromRGB(104,104,87),road=Color3.fromRGB(66,70,73),wall=Color3.fromRGB(125,121,108),blue=Color3.fromRGB(45,106,153),red=Color3.fromRGB(165,62,57),metal=Color3.fromRGB(77,87,83)}
local function folder(parent,name)local f=Instance.new("Folder") f.Name=name f.Parent=parent return f end
local function part(parent,name,size,position,color,material)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=position p.Color=color or colors.wall
 p.Material=material or Enum.Material.Concrete p.Anchored=true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
local publishWork=0
local function publish(node,parent)
 local count=#node:GetDescendants()+1
 if count>250 then
  local children=node:GetChildren() local pp=node:IsA("Model") and node.PrimaryPart local pivot=node:IsA("Model") and node.WorldPivot
  for _,c in children do c.Parent=nil end node.Parent=parent
  for _,c in children do publish(c,node) end
  if node:IsA("Model") then node.PrimaryPart=pp node.WorldPivot=pivot end
 else node.Parent=parent publishWork+=count end
 if publishWork>=500 then publishWork=0 task.wait() end
end
local function sanitize(model)
 for i,obj in model:GetDescendants() do
  if obj:IsA("LuaSourceContainer") or obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") or obj:IsA("TouchTransmitter") or obj:IsA("PackageLink") or obj:IsA("LayerCollector") then obj:Destroy()
  elseif obj:IsA("BasePart") then obj.Anchored=true obj.CanTouch=false if obj:IsA("Seat") or obj:IsA("VehicleSeat") then obj.Disabled=true end
  elseif obj:IsA("Sound") then obj.Playing=false end
  if i%500==0 then task.wait() end
 end
end
local function stamp(source,parent,name,x,z,floor,scale,rotation)
 local model=source:Clone() model.Name=name sanitize(model)
 model:ScaleTo(model:GetScale()*scale)
 local pivot=model:GetPivot() model:PivotTo(CFrame.new(pivot.Position)*CFrame.Angles(0,rotation or 0,0))
 local box,size=model:GetBoundingBox()
 model:PivotTo(model:GetPivot()+Vector3.new(x-box.X,floor-(box.Y-size.Y*.5),z-box.Z))
 publish(model,parent) return model
end
local function hall(parent,name,x,z,width,depth,height,tint)
 local model=Instance.new("Model") model.Name=name model.Parent=parent
 part(model,"Floor",Vector3.new(width,1,depth),Vector3.new(x,Y+.5,z),colors.road)
 part(model,"NorthWall",Vector3.new(width,height,2),Vector3.new(x,Y+height*.5,z-depth*.5),tint)
 part(model,"SouthWall",Vector3.new(width,height,2),Vector3.new(x,Y+height*.5,z+depth*.5),tint)
 for _,sign in {-1,1} do
  for _,side in {-1,1} do part(model,"EntryWall",Vector3.new(2,height,(depth-18)*.5),Vector3.new(x+sign*width*.5,Y+height*.5,z+side*(depth+18)*.25),tint) end
  part(model,"Lintel",Vector3.new(2,height-12,18),Vector3.new(x+sign*width*.5,Y+12+(height-12)*.5,z),tint)
 end
 part(model,"Roof",Vector3.new(width+3,2,depth+3),Vector3.new(x,Y+height+1,z),colors.metal,Enum.Material.CorrodedMetal)
 for _,sx in {-1,1} do part(model,"RoofVent",Vector3.new(8,4,8),Vector3.new(x+sx*width*.25,Y+height+4,z),colors.metal,Enum.Material.Metal) end
 return model
end
local function cover(parent,name,x,z,width,depth,height,team)
 local model=Instance.new("Model") model.Name=name model:SetAttribute("CoverTeam",team or "Neutral") model.Parent=parent
 part(model,"Barrier",Vector3.new(width,height,depth),Vector3.new(x,Y+height*.5,z),colors.wall)
 local node=part(model,"CoverNode",Vector3.one,Vector3.new(x+(team=="Blue" and -6 or 6),Y+3,z),colors.blue)
 node.Transparency=1 node.CanCollide=false node.CanQuery=false node.CanTouch=false
 return model
end
function Author.Build()
 assert(not game.RunService:IsRunning(),"Use com Play parado.")
 assert(not Storage.CTFMaps:FindFirstChild(ID),"Versão ampliada já existe; preserve suas edições.")
 local sources=Storage.Development.Assets.CTFExpansionSources
 local kit=sources["Modular Building Kit - Modern City"].PrefabBuildings
 local model=Instance.new("Model") model.Name=ID model:SetAttribute("Enabled",false)
 model:SetAttribute("DisplayName","Travessia Ampliada") model:SetAttribute("Description","Trincheiras, fábrica e distrito urbano · três rotas espaçadas")
 model:SetAttribute("LayoutVersion",2) model:SetAttribute("TerrainUnchanged",true)
 local geometry=folder(model,"Geometry") local world=folder(geometry,"CTFWideWorld")
 world:SetAttribute("CTFMapGeometry",true) world:SetAttribute("CrossgroundsOwned",true)
 local ground=folder(world,"Ground") local structures=folder(world,"Structures") local dressing=folder(world,"ImportedStructures")
 -- Raised foundations cover the old terrain without rewriting any terrain voxels.
 for _,range in {{-280,-215,Y},{-215,-145,Y-6},{-145,280,Y}} do
  part(ground,"Foundation",Vector3.new(940,8,range[2]-range[1]),Vector3.new(0,range[3]-4,(range[1]+range[2])*.5),colors.ground,Enum.Material.Ground)
 end
 part(ground,"FactoryRoadWest",Vector3.new(260,.15,62),Vector3.new(-220,Y+.08,0),colors.road,Enum.Material.Asphalt)
 part(ground,"FactoryRoadEast",Vector3.new(260,.15,62),Vector3.new(220,Y+.08,0),colors.road,Enum.Material.Asphalt)
 part(ground,"SouthStreet",Vector3.new(720,.15,74),Vector3.new(0,Y+.08,180),colors.road,Enum.Material.Asphalt)
 -- Wide pedestrian approaches and protected connections between lanes.
 for _,x in {-310,-240,-80,80,240,310} do
  for _,z in {-135,-90,-45,45,90,135} do
   local top=z<=-135 and Y-3 or Y
   local ramp=part(ground,"Crossover",Vector3.new(28,1,45),Vector3.new(x,top-.5,z),colors.ground)
   if z==-135 then ramp.CFrame=CFrame.new(x,Y-3.5,z)*CFrame.Angles(-math.atan2(6,45),0,0) end
  end
 end
 for _,x in {-430,430} do
  local ramp=part(ground,"TrenchBaseRamp",Vector3.new(70,1,65),Vector3.new(x,Y-3.5,-180),colors.ground)
  ramp.CFrame=CFrame.new(x,Y-3.5,-180)*CFrame.Angles(0,0,(x<0 and -1 or 1)*math.atan2(6,70))
 end
 -- Tall separators prevent a single firing line covering all three lanes.
 for _,z in {-95,95} do
  for _,x in {-320,0,320} do part(structures,"LaneScreen",Vector3.new(76,18,5),Vector3.new(x,Y+9,z),colors.wall,Enum.Material.Brick) end
  for _,x in {-160,160} do stamp(kit.C,dressing,"DistrictBlock_"..x.."_"..z,x,z,Y,.52,x<0 and 0 or math.pi) end
 end
 for _,x in {-320,320} do
  stamp(kit.G,dressing,"Depot_"..x,x,235,Y,.38,x<0 and 0 or math.pi)
 end
 local factory=hall(structures,"CentralFactory",0,0,92,62,22,Color3.fromRGB(139,127,103))
 part(factory,"ProcessingMachine",Vector3.new(14,11,24),Vector3.new(0,Y+6.5,0),colors.metal,Enum.Material.Metal)
 part(factory,"ConveyorWest",Vector3.new(18,3,10),Vector3.new(-16,Y+2.5,0),colors.road,Enum.Material.DiamondPlate)
 part(factory,"ConveyorEast",Vector3.new(18,3,10),Vector3.new(16,Y+2.5,0),colors.road,Enum.Material.DiamondPlate)
 for _,x in {-260,260} do hall(structures,"SideWorkshop_"..x,x,180,42,44,17,colors.wall) end
 -- Trench walls and alternating deflectors keep crossings generous but break long sightlines.
 for _,z in {-215,-145} do
  for _,x in {-365,-160,0,160,365} do
   if x~=0 then part(structures,"TrenchRevetment",Vector3.new(100,9,3),Vector3.new(x,Y-1.5,z),colors.wall,Enum.Material.WoodPlanks) end
  end
 end
 for index,x in {-240,-80,80,240} do
  local northSide=index%2==1 and -1 or 1
  part(structures,"TrenchTraverse",Vector3.new(5,9,36),Vector3.new(x,Y-1.5,-180+northSide*17),colors.wall,Enum.Material.WoodPlanks)
  cover(structures,"StreetChicane_"..index,x,180-northSide*19,6,38,10)
 end
 for _,x in {-150,150} do stamp(sources.trenches,dressing,"TrenchFortification_"..x,x,-246,Y,.55,x<0 and 0 or math.pi) end
 for _,x in {-330,330} do stamp(sources.Watchtower,dressing,"Watchtower_"..x,x,-248,Y,.56,x<0 and 0 or math.pi) end
 for _,x in {-290,-190,-110,110,190,290} do
  stamp(sources["SandBag War Barricade"],dressing,"Sandbag_"..x,x,x%3==0 and 43 or -43,Y,1.4,math.pi*.5)
 end
 for _,x in {-360,-280,-200,-120,120,200,280,360} do
  for _,z in {-50,50} do
   local team=x<0 and "Blue" or "Red"
   cover(structures,"RoadCover_"..x.."_"..z,x,z,12,8,8,team)
  end
 end
 -- Perimeter bounds; the existing lobby at Z=365 remains outside this map.
 for _,z in {-282,282} do part(structures,"Perimeter",Vector3.new(948,20,4),Vector3.new(0,Y+10,z),colors.wall,Enum.Material.Brick) end
 for _,x in {-472,472} do part(structures,"Perimeter",Vector3.new(4,20,564),Vector3.new(x,Y+10,0),colors.wall,Enum.Material.Brick) end
 local infrastructure=folder(model,"CTFInfrastructure") infrastructure:SetAttribute("NavigationSchema",2)
 infrastructure:SetAttribute("LaneSpacing",180) infrastructure:SetAttribute("NavigationFloorY",Y)
 infrastructure:SetAttribute("PlayRegionCenter",Vector3.new(0,Y+35,0)) infrastructure:SetAttribute("PlayRegionSize",Vector3.new(940,150,560))
 folder(infrastructure,"Bridges") folder(infrastructure,"BridgeMarkers") folder(infrastructure,"ThreeLanes")
 local tactical=folder(infrastructure,"TacticalCover")
 -- Tactical nodes and physical cover share one canonical container.
 for _,m in structures:GetChildren() do if m:GetAttribute("CoverTeam") then m.Parent=tactical end end
 for _,team in {"Blue","Red"} do
  local sign=team=="Blue" and -1 or 1 local tint=team=="Blue" and colors.blue or colors.red
  local base=Storage.CTFMaps.riverside.CTFInfrastructure[team.."Base"]:Clone() sanitize(base)
  for _,child in base:GetChildren() do if child.Name=="Spawns" then child:Destroy() end end
  local offset=Vector3.new(sign*360-base.FlagStand.Position.X,Y+0.5-base.FlagStand.Position.Y,0)
  for _,p in base:GetDescendants() do if p:IsA("BasePart") then p.CFrame+=offset end end
  -- sanitize strips labels; the label below is explicitly scoped by CTFFlagLabels.
  local gui=Instance.new("BillboardGui") gui.Name="FlagLabel" gui.Enabled=false gui.Size=UDim2.fromOffset(210,32) gui.StudsOffsetWorldSpace=Vector3.new(0,10,0) gui.MaxDistance=900 gui.AlwaysOnTop=true gui.Parent=base.FlagStand
  local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.TextColor3=tint label.TextStrokeTransparency=.25 label.TextSize=16 label.Font=Enum.Font.GothamBold label.Text=team=="Blue" and "BANDEIRA AZUL" or "BANDEIRA VERMELHA" label.Parent=gui
  local spawns=folder(base,"Spawns")
  for column=0,5 do for row=0,3 do
   local p=part(spawns,string.format("Spawn%02d",column*4+row+1),Vector3.new(4,.2,4),Vector3.new(sign*(398+column*8),Y+.1,-36+row*24),tint)
   p.Transparency=1 p.CanCollide=false p.CanTouch=false p.CanQuery=false
  end end
  base.Parent=infrastructure
  for _,z in {-30,30} do part(structures,"SpawnScreen",Vector3.new(5,12,24),Vector3.new(sign*383,Y+6,z),tint) end
  for _,z in {-65,65} do part(structures,"BaseSideCover",Vector3.new(75,12,5),Vector3.new(sign*415,Y+6,z),tint) end
 end
 local routes=folder(infrastructure,"BotRoutes")
 local xs={-330,-280,-240,-160,-80,0,80,160,240,280,330}
 local northZ={-180,-164,-164,-196,-196,-164,-164,-196,-196,-180,-180}
 local southZ={180,225,225,180,210,180,150,180,225,225,180}
 for _,lane in {{"North",-180},{"Center",0},{"South",180}} do
  local route=folder(routes,lane[1]) route:SetAttribute("LaneZ",lane[2])
  for i,x in xs do
   local z=lane[1]=="North" and northZ[i] or lane[1]=="Center" and (math.abs(x)<=80 and -58 or 0) or lane[1]=="South" and southZ[i] or lane[2]
   -- Keep side-workshop entry goals out of its walls.
   if lane[1]=="South" and math.abs(x)>=240 and math.abs(x)<=280 then z=225 end
   local p=part(route,string.format("Point%02d",i),Vector3.one,Vector3.new(x,lane[1]=="North" and Y-5 or Y+1,z),colors.blue)
   p.Transparency=1 p.CanCollide=false p.CanQuery=false p.CanTouch=false
  end
 end
 publish(model,Storage.CTFMaps)
 return {id=ID,descendants=#model:GetDescendants(),flagsDistance=720,laneSpacing=180,size="940 x 560",enabled=false}
end
function Author.Activate()
 assert(not game.RunService:IsRunning(),"Use com Play parado.")
 assert(typeof(workspace:GetAttribute("CTFExpansionBackupVerified"))=="string","Exporte e verifique a cena anterior antes de ativar.")
 local source=assert(Storage.CTFMaps:FindFirstChild(ID),"Construa a versão ampliada primeiro.")
 assert(workspace:GetAttribute("CurrentMapId")~=ID,"Mapa ampliado já está ativo; preserve edições manuais.")
 local function dispose(node)
  if #node:GetDescendants()>250 then for _,child in node:GetChildren() do dispose(child) end end node:Destroy() task.wait()
 end
 game.ChangeHistoryService:SetWaypoint("Before wide CTF layout")
 local old=workspace:FindFirstChild("CTFInfrastructure") if old then dispose(old) end
 for _,obj in workspace:GetChildren() do if obj:GetAttribute("CTFMapGeometry")==true then dispose(obj) end end
 publish(source.CTFInfrastructure:Clone(),workspace)
 for _,obj in source.Geometry:GetChildren() do local copy=obj:Clone() copy:SetAttribute("CTFMapGeometry",true) publish(copy,workspace) end
 source:SetAttribute("Enabled",true) workspace:SetAttribute("CurrentMapId",ID) workspace:SetAttribute("CurrentMapName",source:GetAttribute("DisplayName"))
 game.ChangeHistoryService:SetWaypoint("Wide CTF layout active")
 return {id=ID,active=true}
end
return Author
