-- Original isolated P0 test map. Does not modify imported Facility geometry.
local Author={}
function Author.Build()
 local physics=game:GetService("PhysicsService")
 if not physics:IsCollisionGroupRegistered("GetOutVent") then physics:RegisterCollisionGroup("GetOutVent") end
 local library=game.ServerStorage.CrossgroundsMaps.GetOut
 if library:FindFirstChild("pursuit_lab") then return library.pursuit_lab end
 local map=Instance.new("Model") map.Name="pursuit_lab"
 map:SetAttribute("Sanitized",true) map:SetAttribute("Enabled",true) map:SetAttribute("DisplayName","Laboratório de perseguição") map:SetAttribute("SortOrder",1)
 local function folder(parent,name) local f=Instance.new("Folder") f.Name=name f.Parent=parent return f end
 local geometry=folder(map,"Geometry") local room=folder(geometry,"Structure")
 local origin=Vector3.new(2600,100,0)
 local function part(parent,name,pos,size,color,collide)
  local p=Instance.new("Part") p.Name=name p.Size=size p.Position=origin+pos p.Anchored=true p.Color=color or Color3.fromRGB(47,60,68) p.Material=Enum.Material.Concrete p.CanCollide=collide~=false p.Parent=parent return p
 end
 local function mark(parent,name,id,pos,size)
  local p=part(parent,name,pos,size or Vector3.new(1,1,1),nil,false) p.Transparency=1 p.CanTouch=false if id then p:SetAttribute("ObjectiveId",id) end return p
 end
 local function label(p,text)
  local g=Instance.new("BillboardGui") g.Size=UDim2.fromOffset(180,34) g.StudsOffset=Vector3.new(0,2,0) g.MaxDistance=24 g.Parent=p
  local l=Instance.new("TextLabel") l.Size=UDim2.fromScale(1,1) l.BackgroundTransparency=.25 l.BackgroundColor3=Color3.fromRGB(17,28,34) l.TextColor3=Color3.new(1,1,1) l.TextSize=14 l.Font=Enum.Font.GothamMedium l.Text=text l.Parent=g
 end
 part(room,"Floor",Vector3.new(0,-1,0),Vector3.new(126,2,104),Color3.fromRGB(82,87,88))
 part(room,"North",Vector3.new(0,7,-50),Vector3.new(120,14,2)) part(room,"South",Vector3.new(0,7,50),Vector3.new(120,14,2))
 for _,x in {-60,60} do
  part(room,"OuterWall",Vector3.new(x,7,-29),Vector3.new(2,14,42)) part(room,"OuterWall",Vector3.new(x,7,29),Vector3.new(2,14,42))
  part(room,"ExitHeader",Vector3.new(x,12,0),Vector3.new(2,4,16))
  part(room,"ExitApron",Vector3.new(x+(x<0 and -8 or 8),-1,0),Vector3.new(18,2,18))
 end
 -- Central partition: door at z=-30, crawl tunnel at z=0, jump window at z=30.
 for _,range in {{-49,-35},{-25,-3.5},{3.5,25},{35,49}} do
  part(room,"Partition",Vector3.new(0,6,(range[1]+range[2])/2),Vector3.new(2,12,range[2]-range[1]))
 end
 part(room,"DoorHeader",Vector3.new(0,11,-30),Vector3.new(2,2,10))
 part(room,"VentHeader",Vector3.new(0,7.5,0),Vector3.new(14,9,7))
 part(room,"VentSide",Vector3.new(0,1.5,-3.5),Vector3.new(14,3,1)) part(room,"VentSide",Vector3.new(0,1.5,3.5),Vector3.new(14,3,1))
 part(room,"WindowSill",Vector3.new(0,1.25,30),Vector3.new(2,2.5,10),Color3.fromRGB(118,159,165))
 part(room,"WindowHeader",Vector3.new(0,11,30),Vector3.new(2,2,10))
 local root=folder(map,"GetOut") root:SetAttribute("Authored",true) root:SetAttribute("SupportedRoutes","locks") root:SetAttribute("TraversalVersion",1)
 local traversal=folder(root,"Traversal")
 local door=part(room,"RegularDoor",Vector3.new(0,5,-30),Vector3.new(1,10,10),Color3.fromRGB(115,83,53)) door:SetAttribute("RegularDoorId","central")
 local dm=mark(traversal,"DoorCentral",nil,Vector3.new(0,5,-30)) dm:SetAttribute("Kind","RegularDoor") dm:SetAttribute("DoorId","central") dm:SetAttribute("Hinge",CFrame.new(origin+Vector3.new(0,5,-35)))
 local vent=mark(traversal,"Vent",nil,Vector3.new(0,1.5,0),Vector3.new(14,3,6)) vent:SetAttribute("Kind","Vent") vent:SetAttribute("HumanOnly",true) vent:SetAttribute("RequiresCrawl",true)
 vent:SetAttribute("Entrance",origin+Vector3.new(-9,1.5,0)) vent:SetAttribute("Exit",origin+Vector3.new(9,1.5,0)) vent:SetAttribute("MinimumClearance",3)
 local barrier=part(room,"BeastVentBarrier",Vector3.new(0,1.5,0),Vector3.new(1,3,6),nil,true) barrier.Transparency=1 barrier.CollisionGroup="GetOutVent" barrier:SetAttribute("VentBarrier",true)
 local window=mark(traversal,"Window",nil,Vector3.new(0,6,30),Vector3.new(2,7,10)) window:SetAttribute("Kind","Window") label(window,"JANELA · SALTE") label(vent,"DUTO · RASTEJE")
 -- Physical walk-in cabinet: no teleport, no invisibility, one narrow occupancy volume.
 local hide=mark(traversal,"Cabinet",nil,Vector3.new(-40,3,30),Vector3.new(4,6,4)) hide:SetAttribute("Kind","HideSpot")
 for _,x in {-43,-37} do part(room,"CabinetSide",Vector3.new(x,3.5,30),Vector3.new(1,7,6),Color3.fromRGB(58,79,82)) end
 part(room,"CabinetBack",Vector3.new(-40,3.5,33),Vector3.new(7,7,1)) part(room,"CabinetRoof",Vector3.new(-40,7,30),Vector3.new(7,1,7))
 label(hide,"ARMÁRIO · ENTRE A PÉ")
 local spawns=folder(map,"Spawns") local survivors=folder(root,"SurvivorSpawns")
 for i,pos in {Vector3.new(-35,3.6,-35),Vector3.new(-45,3.6,-25),Vector3.new(-35,3.6,15),Vector3.new(-20,3.6,25)} do mark(spawns,"Spawn"..i,nil,pos) mark(survivors,"Survivor"..i,"survivor"..i,pos) end
 mark(root,"BeastSpawn",nil,Vector3.new(40,3.6,30))
 local computers=folder(root,"Computers")
 for i,pos in {Vector3.new(-38,3,-15),Vector3.new(-22,3,38),Vector3.new(35,3,-35),Vector3.new(38,3,15)} do
  local pc=mark(computers,"PC"..i,"pc"..i,pos,Vector3.new(4,2,1)) pc.Transparency=0 pc.Color=Color3.fromRGB(59,136,173) label(pc,"TERMINAL "..i)
  part(room,"Desk",pos+Vector3.new(0,-1.8,1),Vector3.new(10,2,4))
  for slot=1,3 do local a=Instance.new("Attachment") a.Name="HackSlot"..slot a.Position=Vector3.new((slot-2)*3,0,4) a.Parent=pc end
 end
 local doors=folder(root,"ExitDoors") local zones=folder(root,"ExitZones") local cranks=folder(root,"Cranks") local locks=folder(root,"Locks")
 for i,x in {-60,60} do
  local id="door"..i local d=mark(doors,"Exit"..i,id,Vector3.new(x,5,0),Vector3.new(2,10,15)) d.Transparency=.25 d.Color=Color3.fromRGB(177,63,57)
  local physical=part(room,"ExitSlab",Vector3.new(x,5,0),Vector3.new(2,10,15),d.Color) physical:SetAttribute("GetOutExitDoorId",id)
  local z=mark(zones,"Escape"..i,id,Vector3.new(x+(x<0 and -7 or 7),4,0),Vector3.new(5,8,14)) z.CanTouch=true
  local crank=mark(cranks,"Crank"..i,id,Vector3.new(x+(x<0 and 4 or -4),3,6),Vector3.new(1,2,2)) crank.Transparency=0 crank.Color=Color3.fromRGB(222,171,69) label(crank,"SAÍDA "..i)
 end
 for i=1,4 do local p=mark(locks,"Lock"..i,"lock"..i,Vector3.new(-58,6+i*.6,0),Vector3.new(.5,.4,.8)) p.Transparency=0 p.Color=Color3.fromRGB(177,63,57) end
 local pods=folder(root,"FreezePods")
 for i,pos in {Vector3.new(-45,0,40),Vector3.new(45,0,-40)} do
  local p=mark(pods,"Pod"..i,"pod"..i,pos+Vector3.new(0,3,0),Vector3.new(4,6,4)) p.Transparency=.65 p.Color=Color3.fromRGB(93,184,208) label(p,"CÁPSULA "..i)
  local a=Instance.new("Attachment") a.Name="RescueExit" a.Position=Vector3.new(0,0,-6) a.Parent=p
 end
 local panels=folder(root,"ContainmentPanels")
 for i,pos in {Vector3.new(-18,3,-45),Vector3.new(20,3,45)} do local p=mark(panels,"Panel"..i,"panel"..i,pos,Vector3.new(2,3,1)) p.Transparency=0 p.Color=Color3.fromRGB(128,77,52) end
 local chamber=mark(root,"ContainmentChamber",nil,Vector3.new(38,4,0),Vector3.new(12,8,12))
 local light=Instance.new("PointLight") light.Enabled=false light.Color=Color3.fromRGB(245,153,68) light.Range=20 light.Parent=chamber
 local lever=mark(root,"ContainmentLever",nil,Vector3.new(27,3,0),Vector3.new(1,2,1)) lever.Transparency=0
 mark(root,"ContainmentDoor",nil,Vector3.new(31,4,0),Vector3.new(1,8,12))
 for _,pos in {Vector3.new(38,4,-7),Vector3.new(38,4,7)} do part(room,"ChamberWall",pos,Vector3.new(14,8,1)) end
 part(room,"ChamberBack",Vector3.new(45,4,0),Vector3.new(1,8,14))
 map.Parent=library return map
end
return Author

