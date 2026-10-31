local Factory={}
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Effects=require(game.ReplicatedStorage.Crossgrounds.WeaponEffects)
local dark=Color3.fromRGB(37,43,49) local steel=Color3.fromRGB(103,115,124)
local polymer=Color3.fromRGB(53,60,64) local edge=Color3.fromRGB(203,215,220)
local function piece(tool,handle,name,size,offset,color,material,class)
 local p=Instance.new(class or "Part") p.Name=name p.Size=size p.CFrame=handle.CFrame*offset p.Color=color or dark
 p.Material=material or Enum.Material.Metal p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Massless=true p.CastShadow=false p.Parent=tool
 local weld=Instance.new("WeldConstraint") weld.Part0=handle weld.Part1=p weld.Parent=p return p
end
local function cylinder(tool,handle,name,length,diameter,offset,color)
 local p=piece(tool,handle,name,Vector3.new(length,diameter,diameter),offset*CFrame.Angles(0,math.pi/2,0),color) p.Shape=Enum.PartType.Cylinder return p
end
local function attachment(handle,name,cf) local a=Instance.new("Attachment") a.Name=name a.CFrame=cf a.Parent=handle return a end
local function screw(tool,h,name,position,side)
 local cf=CFrame.new(position)*CFrame.Angles(0,side and math.pi/2 or 0,0)
 cylinder(tool,h,name,.035,.10,cf,edge)
 piece(tool,h,name.."Slot",side and Vector3.new(.006,.02,.065) or Vector3.new(.065,.02,.006),CFrame.new(position+(side and Vector3.new(side*.022,0,0) or Vector3.new(0,0,.022))),dark)
end
local function refine(tool,h,id,visual)
 if id=="ArenaPistol" then
  local revolver=visual=="Magnum" local classic=visual=="M1911"
  local length=classic and 1.55 or 1.38 local muzzleZ=revolver and -2.35 or classic and -1.43 or -1.28
  for _,side in {-1,1} do
   for _,y in {-.31,.04} do screw(tool,h,"GripScrew"..side.."_"..y,Vector3.new(side*.196,y,.075),side) end
   for i=1,4 do piece(tool,h,"GripCheckering"..side.."_"..i,Vector3.new(.015,.018,.25),CFrame.new(side*.194,-.34+i*.075,.095)*CFrame.Angles(0,0,math.rad(-12)),Color3.fromRGB(35,30,25)) end
  end
  piece(tool,h,"Backstrap",Vector3.new(.26,.55,.075),CFrame.new(0,-.12,.29)*CFrame.Angles(math.rad(-15),0,0),dark)
  piece(tool,h,"Beavertail",Vector3.new(.29,.11,.30),CFrame.new(0,.27,.24)*CFrame.Angles(math.rad(-12),0,0),steel)
  if revolver then
   for i=1,6 do
    local a=i*math.pi/3
    piece(tool,h,"CylinderFlute"..i,Vector3.new(.06,.025,.57),CFrame.new(math.cos(a)*.231,.46+math.sin(a)*.231,-.48)*CFrame.Angles(0,0,a-math.pi/2),dark)
   end
   cylinder(tool,h,"CylinderFrontRim",.035,.48,CFrame.new(0,.46,-.87),edge)
   cylinder(tool,h,"CylinderRearRim",.035,.48,CFrame.new(0,.46,-.09),dark)
   -- Small black chambers stay in front of the rim.
   for i=1,6 do local c=tool:FindFirstChild("Chamber"..i) if c then c.CFrame*=CFrame.new(.045,0,0) end end
   cylinder(tool,h,"EjectorRod",1.20,.065,CFrame.new(.07,.25,-1.48),dark)
   piece(tool,h,"BarrelRib",Vector3.new(.11,.065,1.49),CFrame.new(0,.58,-1.59),steel)
   piece(tool,h,"RevolverHammer",Vector3.new(.12,.22,.22),CFrame.new(0,.57,.15)*CFrame.Angles(math.rad(-25),0,0),dark)
   piece(tool,h,"HammerSpur",Vector3.new(.22,.055,.15),CFrame.new(0,.69,.19),edge)
   screw(tool,h,"CylinderPivot",Vector3.new(-.26,.30,-.57),-1)
  else
   local slide=tool:FindFirstChild("Slide") slide.Size=Vector3.new(.29,.26,length-.04)
   local top=tool:FindFirstChild("SlideTop") top.Size=Vector3.new(.24,.045,length-.09)
   top.CFrame=h.CFrame*CFrame.new(0,.66,-.59)
   for _,side in {-1,1} do
    piece(tool,h,"SlideSide"..side,Vector3.new(.03,.19,length-.10),CFrame.new(side*.16,.49,-.59),classic and steel or dark)
    piece(tool,h,"SlideBevel"..side,Vector3.new(length-.05,.09,.075),CFrame.new(side*.15,.60,-.59)*CFrame.Angles(0,side*math.pi/2,0),classic and edge or polymer,Enum.Material.Metal,"WedgePart")
    for i=1,3 do piece(tool,h,"FrontSerration"..side.."_"..i,Vector3.new(.02,.16,.022),CFrame.new(side*.18,.48,muzzleZ+.18+i*.07),classic and dark or steel) end
   end
   piece(tool,h,"SlideNose",Vector3.new(.29,.10,.12),CFrame.new(0,.58,muzzleZ+.13)*CFrame.Angles(0,math.pi,0),classic and steel or dark,Enum.Material.Metal,"WedgePart")
   piece(tool,h,"Extractor",Vector3.new(.025,.06,.17),CFrame.new(.185,.51,-.36),edge)
   piece(tool,h,"TakedownLever",Vector3.new(.05,.10,.13),CFrame.new(-.2,.27,-.32),steel)
   if classic then piece(tool,h,"ThumbSafety",Vector3.new(.07,.07,.24),CFrame.new(-.22,.30,.11)*CFrame.Angles(0,math.rad(-12),0),dark)
   else
    piece(tool,h,"TriggerSafety",Vector3.new(.025,.12,.025),CFrame.new(0,.07,-.39),Color3.fromRGB(83,90,86))
    for i=1,3 do piece(tool,h,"RailNotch"..i,Vector3.new(.28,.035,.035),CFrame.new(0,.04,-.59-i*.08),steel) end
   end
  end
  local rear=tool:FindFirstChild("RearSight") if rear then rear:Destroy() end
  piece(tool,h,"RearSightBase",Vector3.new(.29,.05,.14),CFrame.new(0,.69,.04),dark)
  for _,side in {-1,1} do
   piece(tool,h,"RearSightPost"..side,Vector3.new(.075,.10,.12),CFrame.new(side*.105,.75,.04),dark)
   cylinder(tool,h,"RearSightDot"..side,.012,.035,CFrame.new(side*.105,.765,.108),edge)
  end
  cylinder(tool,h,"MuzzleCrown",.035,revolver and .21 or .19,CFrame.new(0,.46,muzzleZ+.01),edge)
  cylinder(tool,h,"DeepBore",.02,.105,CFrame.new(0,.46,muzzleZ-.035),Color3.fromRGB(6,8,10))
 elseif id=="SMG" or id=="Rifle" or id=="Sniper" then
  local smg=id=="SMG" local sniper=id=="Sniper" local accent=sniper and Color3.fromRGB(135,124,94) or Color3.fromRGB(82,104,111)
  local receiver=tool:FindFirstChild("DustCover") receiver.Size=Vector3.new(.37,.16,receiver.Size.Z)
  for _,side in {-1,1} do
   piece(tool,h,"ReceiverBevel"..side,Vector3.new(receiver.Size.Z,.10,.10),CFrame.new(side*.19,.84,-.6)*CFrame.Angles(0,side*math.pi/2,0),steel,Enum.Material.Metal,"WedgePart")
   for i=1,2 do screw(tool,h,"ReceiverPin"..side.."_"..i,Vector3.new(side*.284,.48,.06-i*.58),side) end
   for i=1,3 do piece(tool,h,"MagazineGroove"..side.."_"..i,Vector3.new(.025,.045,.35),CFrame.new(side*.18,-.01-i*.19,-.68-i*.035)*CFrame.Angles(math.rad(-12),0,0),dark) end
  end
  local mz=smg and -2.35 or sniper and -4.45 or -3.35
  for i=1,4 do local a=i*math.pi/2 piece(tool,h,"BrakePort"..i,Vector3.new(.05,.045,.13),CFrame.new(math.cos(a)*.13,.64+math.sin(a)*.13,mz+.04)*CFrame.Angles(0,0,a),Color3.fromRGB(8,11,13)) end
  cylinder(tool,h,"BarrelCrown",.04,sniper and .26 or .22,CFrame.new(0,.64,mz-.06),edge)
  cylinder(tool,h,"FrontBore",.02,.12,CFrame.new(0,.64,mz-.12),Color3.fromRGB(7,9,11))
  piece(tool,h,"StockLowerBevel",Vector3.new(.36,.24,.62),CFrame.new(0,.24,1.10)*CFrame.Angles(0,math.pi,0),accent,Enum.Material.SmoothPlastic,"WedgePart")
  for i=1,3 do piece(tool,h,"ButtPadRib"..i,Vector3.new(.48,.045,.035),CFrame.new(0,.12+i*.15,1.56),dark) end
  if smg then
   tool.StockBody.Size=Vector3.new(.30,.24,.70)
   piece(tool,h,"FoldingStockHinge",Vector3.new(.37,.35,.22),CFrame.new(0,.49,.63),steel)
  elseif sniper then
   cylinder(tool,h,"ScopeRearGlass",.025,.36,CFrame.new(0,1.43,.49),Color3.fromRGB(64,113,121)).Material=Enum.Material.Glass
   for i,z in {-.99,.02} do
    cylinder(tool,h,"ScopeRing"..i,.12,.49,CFrame.new(0,1.43,z),steel)
    screw(tool,h,"ScopeRingScrew"..i,Vector3.new(.25,1.43,z),1)
   end
   for i=1,8 do local a=i*math.pi/4 piece(tool,h,"TurretKnurl"..i,Vector3.new(.05,.12,.05),CFrame.new(math.cos(a)*.18,1.76,-.5+math.sin(a)*.18),dark) end
   piece(tool,h,"AdjustableCheek",Vector3.new(.32,.10,.5),CFrame.new(0,.88,1.07),accent,Enum.Material.SmoothPlastic)
  end
 else
  if id=="Knife" then
   for _,y in {-.25,.28} do screw(tool,h,"KnifePin"..y,Vector3.new(0,y,.17)) end
   piece(tool,h,"KnifeFuller",Vector3.new(.055,1.1,.018),CFrame.new(-.015,1.4,.067),dark)
   for i=1,3 do piece(tool,h,"SpineNotch"..i,Vector3.new(.08,.035,.13),CFrame.new(-.12,.65+i*.10,0),dark) end
  elseif id=="Sword" then
   for _,side in {-1,1} do local cap=piece(tool,h,"GuardTip"..side,Vector3.new(.24,.26,.28),CFrame.new(side*.74,.5,0),steel) cap.Shape=Enum.PartType.Ball end
   for i=1,3 do screw(tool,h,"HiltRivet"..i,Vector3.new(0,-.35+i*.22,.17)) end
   piece(tool,h,"BladeShoulder",Vector3.new(.58,.38,.16),CFrame.new(0,.76,0),edge,Enum.Material.Metal,"WedgePart")
  elseif id=="Axe" then
   tool.AxeHead.Size=Vector3.new(2.6,1.35,.42)
   for _,side in {-1,1} do
    piece(tool,h,"AxeShoulder"..side,Vector3.new(.7,1.7,.42),CFrame.new(side*1.5+.25,2.6,0)*CFrame.Angles(0,0,side*math.pi/2),steel,Enum.Material.Metal,"WedgePart")
    for i=1,2 do screw(tool,h,"HeadRivet"..side.."_"..i,Vector3.new(side*.25,2.0+i*.4,.29)) end
    piece(tool,h,"HeadInset"..side,Vector3.new(.85,.08,.025),CFrame.new(side*.9+.25,2.6,.235)*CFrame.Angles(0,0,side*.25),dark)
   end
   for i=1,3 do piece(tool,h,"ShaftRing"..i,Vector3.new(.43,.07,.43),CFrame.new(0,.75+i*.2,0),steel) end
  end
 end
 for _,v in tool:GetChildren() do if v:IsA("BasePart") and v.Material==Enum.Material.Metal then v.Reflectance=.07 end end
end
local function specialPistol(tool,h,visual)
 if not table.find({"DesertEagle","Luger","Beretta"},visual) then return end
 -- Rebuild the complete upper assembly; each option has a different silhouette.
 local keep={Handle=true,PistolGrip=true,GripBase=true,Frame=true,Trigger=true,TriggerGuardFront=true,TriggerGuardBase=true,GripPanel1=true,["GripPanel-1"]=true}
 for _,v in tool:GetChildren() do if v:IsA("BasePart") and not keep[v.Name] then v:Destroy() end end
 local eagle=visual=="DesertEagle" local luger=visual=="Luger"
 local color=eagle and Color3.fromRGB(168,175,180) or luger and Color3.fromRGB(64,68,72) or Color3.fromRGB(77,87,96)
 local muzzleZ=eagle and -1.95 or luger and -2.3 or -1.8
 if luger then
  for _,name in {"PistolGrip","GripPanel1","GripPanel-1"} do
   local v=tool:FindFirstChild(name) v.CFrame=h.CFrame*CFrame.new(name=="PistolGrip" and 0 or name=="GripPanel1" and .17 or -.17,-.17,.15)*CFrame.Angles(math.rad(-33),0,0)
   v.Color=Color3.fromRGB(117,69,39) v.Material=Enum.Material.Wood
  end
  tool.GripBase.CFrame=h.CFrame*CFrame.new(0,-.46,.34)*CFrame.Angles(math.rad(-18),0,0)
  piece(tool,h,"Receiver",Vector3.new(.34,.22,1.0),CFrame.new(0,.43,-.31),color)
  cylinder(tool,h,"TaperedBarrel",1.35,.18,CFrame.new(0,.46,-1.63),color)
  cylinder(tool,h,"BarrelRoot",.24,.27,CFrame.new(0,.46,-.95),steel)
  for _,side in {-1,1} do
   piece(tool,h,"ToggleLink"..side,Vector3.new(.075,.10,.46),CFrame.new(side*.10,.59,-.33),steel):SetAttribute("ReloadGroup","Toggle")
   cylinder(tool,h,"ToggleKnob"..side,.10,.18,CFrame.new(side*.20,.61,-.11)*CFrame.Angles(0,math.pi/2,0),color):SetAttribute("ReloadGroup","Toggle")
   for i=1,8 do piece(tool,h,"WoodCheckering"..side.."_"..i,Vector3.new(.015,.018,.30),CFrame.new(side*.195,-.40+i*.045,.20)*CFrame.Angles(math.rad(-33),0,math.rad(20)),dark) end
  end
  piece(tool,h,"SafetyLever",Vector3.new(.07,.08,.28),CFrame.new(-.22,.30,.16)*CFrame.Angles(0,0,-.3),steel)
 elseif eagle then
  piece(tool,h,"FixedBarrel",Vector3.new(.36,.34,1.18),CFrame.new(0,.48,-1.38),color)
  for _,side in {-1,1} do
   piece(tool,h,"BarrelBevel"..side,Vector3.new(1.13,.14,.11),CFrame.new(side*.18,.64,-1.38)*CFrame.Angles(0,side*math.pi/2,0),edge,Enum.Material.Metal,"WedgePart")
   piece(tool,h,"SlideShoulder"..side,Vector3.new(.08,.31,.78),CFrame.new(side*.21,.46,-.38),color):SetAttribute("ReloadGroup","Slide")
   for i=1,6 do piece(tool,h,"RearSerration"..side.."_"..i,Vector3.new(.02,.24,.025),CFrame.new(side*.258,.48,.01-i*.075),dark):SetAttribute("ReloadGroup","Slide") end
  end
  piece(tool,h,"SlideRoof",Vector3.new(.34,.12,.78),CFrame.new(0,.66,-.38),color):SetAttribute("ReloadGroup","Slide")
  piece(tool,h,"EjectionPort",Vector3.new(.24,.06,.23),CFrame.new(0,.71,-.46),dark):SetAttribute("ReloadGroup","Slide")
  tool.PistolGrip.Size=Vector3.new(.37,.73,.48) tool.PistolGrip.Color=Color3.fromRGB(37,39,42)
  piece(tool,h,"Hammer",Vector3.new(.15,.23,.16),CFrame.new(0,.54,.16),steel)
  piece(tool,h,"BarrelUnderlug",Vector3.new(.26,.16,.85),CFrame.new(0,.20,-1.28),dark)
 else
  -- Open-top slide leaves a visible steel barrel, characteristic of the M9.
  cylinder(tool,h,"ExposedBarrel",1.8,.18,CFrame.new(0,.48,-.92),edge)
  for _,side in {-1,1} do
   piece(tool,h,"OpenSlideSide"..side,Vector3.new(.065,.25,1.73),CFrame.new(side*.18,.46,-.84),color):SetAttribute("ReloadGroup","Slide")
   for i=1,7 do piece(tool,h,"RearSerration"..side.."_"..i,Vector3.new(.02,.20,.025),CFrame.new(side*.221,.47,-.02-i*.06),dark):SetAttribute("ReloadGroup","Slide") end
   piece(tool,h,"GripInset"..side,Vector3.new(.035,.45,.31),CFrame.new(side*.19,-.17,.08)*CFrame.Angles(math.rad(-15),0,0),Color3.fromRGB(21,24,27))
   cylinder(tool,h,"GripMedallion"..side,.02,.12,CFrame.new(side*.215,-.12,.08)*CFrame.Angles(0,math.pi/2,0),steel)
   piece(tool,h,"SafetyLever"..side,Vector3.new(.07,.07,.22),CFrame.new(side*.24,.50,.03),steel):SetAttribute("ReloadGroup","Slide")
  end
  piece(tool,h,"SlideRearBridge",Vector3.new(.33,.25,.4),CFrame.new(0,.47,-.10),color):SetAttribute("ReloadGroup","Slide")
  piece(tool,h,"SlideFrontBridge",Vector3.new(.33,.11,.18),CFrame.new(0,.60,-1.61),color):SetAttribute("ReloadGroup","Slide")
  piece(tool,h,"Hammer",Vector3.new(.13,.22,.16),CFrame.new(0,.53,.22),dark)
  piece(tool,h,"TakedownLever",Vector3.new(.07,.10,.24),CFrame.new(-.24,.24,-.43),steel)
 end
 local muzzle=h:FindFirstChild("Muzzle") if muzzle then muzzle.CFrame=CFrame.new(0,.46,muzzleZ-.05) end
 cylinder(tool,h,"MuzzleCrown",.04,eagle and .29 or .20,CFrame.new(0,.46,muzzleZ),edge)
 cylinder(tool,h,"Bore",.02,eagle and .16 or .10,CFrame.new(0,.46,muzzleZ-.025),Color3.fromRGB(4,6,8))
 piece(tool,h,"FrontSight",Vector3.new(.07,.11,.08),CFrame.new(0,.72,muzzleZ+.12),dark)
 for _,side in {-1,1} do piece(tool,h,"RearSight"..side,Vector3.new(.07,.10,.12),CFrame.new(side*.11,.73,.02),dark) end
end
local function shotgun(tool,h,id)
 local double=id=="Shotgun725" local wood=Color3.fromRGB(116,70,38)
 local receiverColor=double and Color3.fromRGB(151,158,162) or dark
 local function add(name,size,cf,color,material,group,class)
  local part=piece(tool,h,name,size,cf,color,material,class)
  if group then part:SetAttribute("ReloadGroup",group) end return part
 end
 local function tube(name,length,width,cf,color,group)
  local part=cylinder(tool,h,name,length,width,cf,color)
  if group then part:SetAttribute("ReloadGroup",group) end return part
 end
 add("Receiver",Vector3.new(.48,.52,1.40),CFrame.new(0,.43,-.46),receiverColor)
 for _,side in {-1,1} do
  add("ReceiverBevel"..side,Vector3.new(1.30,.11,.08),CFrame.new(side*.23,.69,-.46)*CFrame.Angles(0,side*math.pi/2,0),steel,nil,nil,"WedgePart")
  screw(tool,h,"ActionPin"..side,Vector3.new(side*.26,.43,-.82),side)
  add("TriggerGuardSide"..side,Vector3.new(.055,.28,.07),CFrame.new(side*.10,.0,-.25),dark)
 end
 add("TriggerGuard",Vector3.new(.22,.055,.43),CFrame.new(0,-.13,-.14),dark)
 add("Trigger",Vector3.new(.055,.20,.07),CFrame.new(0,.06,-.12)*CFrame.Angles(-.3,0,0),steel)
 add("PistolGrip",Vector3.new(.33,.72,.44),CFrame.new(0,-.14,.24)*CFrame.Angles(-.38,0,0),double and wood or polymer,double and Enum.Material.Wood or Enum.Material.SmoothPlastic)
 add("StockNeck",Vector3.new(.31,.30,.60),CFrame.new(0,.32,.47),double and wood or polymer,double and Enum.Material.Wood or Enum.Material.SmoothPlastic)
 add("ButtPad",Vector3.new(.45,.82,.12),CFrame.new(0,.02,1.9),dark,Enum.Material.Rubber)
 for i=1,6 do add("ButtRib"..i,Vector3.new(.46,.035,.025),CFrame.new(0,-.35+i*.11,1.97),polymer) end
 local muzzleZ=double and -4.20 or -3.75
 if double then
  add("WoodStock",Vector3.new(.41,.59,1.17),CFrame.new(0,.13,1.30)*CFrame.Angles(-.13,0,0),wood,Enum.Material.Wood)
  add("StockComb",Vector3.new(.35,.15,.93),CFrame.new(0,.44,1.29),wood,Enum.Material.Wood)
  add("TopLever",Vector3.new(.12,.07,.39),CFrame.new(.07,.75,.02)*CFrame.Angles(0,-.3,0),dark)
  add("Safety",Vector3.new(.09,.04,.15),CFrame.new(0,.64,.36),steel)
  for barrel,y in { .59,.30 } do
   tube("Barrel"..barrel,3.05,.235,CFrame.new(0,y,-2.68),dark,"BreakAction")
   tube("ChamberSleeve"..barrel,.43,.28,CFrame.new(0,y,-1.31),steel,"BreakAction")
   tube("MuzzleRim"..barrel,.04,.245,CFrame.new(0,y,muzzleZ),edge,"BreakAction")
   tube("Bore"..barrel,.02,.16,CFrame.new(0,y,muzzleZ-.025),Color3.fromRGB(5,7,9),"BreakAction")
   tube("Shell"..barrel,.25,.17,CFrame.new(0,y,-1.10),Color3.fromRGB(151,37,31),"Shell")
   tube("ShellBrass"..barrel,.035,.19,CFrame.new(0,y,-.96),Color3.fromRGB(188,143,61),"Shell")
  end
  add("ForeEnd",Vector3.new(.39,.28,1.35),CFrame.new(0,.17,-1.99),wood,Enum.Material.Wood,"BreakAction")
  for _,side in {-1,1} do
   for i=1,9 do add("Checkering"..side.."_"..i,Vector3.new(.015,.14,.018),CFrame.new(side*.201,.18,-1.40-i*.12)*CFrame.Angles(0,0,side*.4),dark,nil,"BreakAction") end
   add("EngravedLine"..side,Vector3.new(.012,.025,.73),CFrame.new(side*.247,.44,-.40),dark)
  end
  add("SightRib",Vector3.new(.095,.055,2.95),CFrame.new(0,.75,-2.65),steel,nil,"BreakAction")
  for i=1,6 do add("RibBridge"..i,Vector3.new(.07,.07,.06),CFrame.new(0,.69,-1.17-i*.42),dark,nil,"BreakAction") end
  add("FrontBead",Vector3.new(.055,.065,.06),CFrame.new(0,.81,-4.06),Color3.fromRGB(207,170,85),nil,"BreakAction")
 else
  -- Tubular magazine, vented shield and wire stock; firing remains semi automatic.
  tube("Barrel",2.75,.23,CFrame.new(0,.56,-2.38),dark)
  tube("MagazineTube",2.25,.25,CFrame.new(0,.25,-2.10),steel)
  tube("MagazineCap",.11,.30,CFrame.new(0,.25,-3.27),dark)
  tube("MuzzleRim",.04,.25,CFrame.new(0,.56,muzzleZ),steel)
  tube("Bore",.02,.15,CFrame.new(0,.56,muzzleZ-.025),Color3.fromRGB(4,6,8))
  add("ForeEnd",Vector3.new(.52,.39,1.20),CFrame.new(0,.21,-1.99),polymer,Enum.Material.SmoothPlastic)
  for i=1,10 do add("PumpRib"..i,Vector3.new(.55,.04,.045),CFrame.new(0,.20,-1.35-i*.12),dark) end
  add("HeatShield",Vector3.new(.42,.10,1.90),CFrame.new(0,.77,-2.18),steel)
  for _,side in {-1,1} do
   add("HeatShieldSide"..side,Vector3.new(.045,.23,1.90),CFrame.new(side*.22,.65,-2.18),dark)
   for i=1,9 do add("Vent"..side.."_"..i,Vector3.new(.01,.11,.08),CFrame.new(side*.247,.66,-1.20-i*.19),Color3.fromRGB(7,10,12)) end
   add("StockRail"..side,Vector3.new(.065,.08,1.3),CFrame.new(side*.19,.29,1.21),steel)
  end
  add("StockBrace",Vector3.new(.43,.08,.12),CFrame.new(0,.27,1.73),steel)
  add("StockHinge",Vector3.new(.58,.32,.28),CFrame.new(0,.42,.39),steel)
  add("EjectionPort",Vector3.new(.013,.21,.60),CFrame.new(.248,.50,-.51),Color3.fromRGB(8,10,12))
  add("Bolt",Vector3.new(.025,.15,.32),CFrame.new(.26,.50,-.43),steel,nil,"Slide")
  tube("BoltHandle",.23,.09,CFrame.new(.35,.49,-.46)*CFrame.Angles(0,math.pi/2,0),dark,"Slide")
  tube("LoadingShell",.32,.18,CFrame.new(.23,.03,-.55)*CFrame.Angles(.3,0,0),Color3.fromRGB(144,34,27),"TubeShell")
  tube("ShellBrass",.04,.19,CFrame.new(.23,.08,-.38)*CFrame.Angles(.3,0,0),Color3.fromRGB(194,147,63),"TubeShell")
  add("FrontSightBase",Vector3.new(.14,.26,.18),CFrame.new(0,.76,-3.41),dark)
  add("FrontSight",Vector3.new(.055,.10,.08),CFrame.new(0,.92,-3.41),edge)
  for _,side in {-1,1} do add("RearSight"..side,Vector3.new(.07,.12,.15),CFrame.new(side*.12,.81,.05),dark) end
 end
 attachment(h,"Muzzle",CFrame.new(0,double and .59 or .56,muzzleZ-.06))
 attachment(h,"RightHandGrip",CFrame.new(.015,.02,.17)*CFrame.Angles(-math.pi/2,0,0))
 attachment(h,"SupportGrip",CFrame.new(-.22,.16,-1.86)*CFrame.Angles(-math.pi/2,0,math.pi/2))
 tool:SetAttribute("TwoHanded",true) tool.Grip=CFrame.new(0,-.15,-.2)
end
function Factory:Create(id,visual)
 local data=Kits.Weapons[id] if not data then return end
 local tool=Instance.new("Tool") tool.Name=data.Name tool.ToolTip=data.Name tool.CanBeDropped=false
 tool:SetAttribute("ShotSeed",Random.new():NextInteger(1,2147483646)) tool:SetAttribute("ShotAmmoVersion",1)
 tool:SetAttribute("WeaponId",id) tool:SetAttribute("WeaponKind",data.Kind) tool:SetAttribute("ModelVersion",5)
 local handle=Instance.new("Part") handle.Name="Handle" handle.Size=Vector3.new(.25,.65,.35) handle.Transparency=1
 handle.CanCollide=false handle.CanTouch=false handle.CanQuery=false handle.Massless=true handle.Parent=tool
 if id=="ArenaPistol" then
  visual=Kits:IsPistolVisual(visual) and visual or "M1911"
  tool.Name=Kits.ArenaPistolNames[visual] tool.ToolTip=tool.Name.." · visual de pistola da Arena" tool:SetAttribute("CosmeticId",visual)
  local revolver=visual=="Magnum" local classic=visual=="M1911"
  local gripColor=classic and Color3.fromRGB(106,66,40) or revolver and Color3.fromRGB(69,46,34) or Color3.fromRGB(39,46,44)
  piece(tool,handle,"PistolGrip",Vector3.new(.3,.67,.4),CFrame.new(0,-.12,.06)*CFrame.Angles(math.rad(-15),0,0),gripColor,classic and Enum.Material.Wood or Enum.Material.SmoothPlastic)
  for _,side in {-1,1} do piece(tool,handle,"GripPanel"..side,Vector3.new(.035,.44,.3),CFrame.new(side*.17,-.14,.07)*CFrame.Angles(math.rad(-15),0,0),gripColor) end
  piece(tool,handle,"GripBase",Vector3.new(.34,.1,.44),CFrame.new(0,-.48,.15),dark)
  piece(tool,handle,"Frame",Vector3.new(.3,.24,.87),CFrame.new(0,.24,-.25),polymer)
  piece(tool,handle,"Trigger",Vector3.new(.05,.21,.08),CFrame.new(0,.08,-.34)*CFrame.Angles(math.rad(-18),0,0),steel)
  piece(tool,handle,"TriggerGuardFront",Vector3.new(.09,.29,.09),CFrame.new(0,.03,-.56),dark)
  piece(tool,handle,"TriggerGuardBase",Vector3.new(.1,.07,.44),CFrame.new(0,-.1,-.35),dark)
  local muzzleZ=revolver and -2.35 or classic and -1.43 or -1.28
  if revolver then
   cylinder(tool,handle,"RevolverCylinder",.74,.46,CFrame.new(0,.46,-.48),steel)
   for i=1,6 do local a=i*math.pi/3 cylinder(tool,handle,"Chamber"..i,.025,.09,CFrame.new(math.cos(a)*.145,.46+math.sin(a)*.145,-.87),dark) end
   cylinder(tool,handle,"LongBarrel",1.52,.17,CFrame.new(0,.46,-1.59),steel)
   piece(tool,handle,"Underlug",Vector3.new(.17,.14,1.47),CFrame.new(0,.30,-1.59),steel)
   piece(tool,handle,"CylinderLatch",Vector3.new(.06,.12,.18),CFrame.new(-.26,.45,-.23),dark)
  else
   piece(tool,handle,"Slide",Vector3.new(.37,.34,classic and 1.55 or 1.38),CFrame.new(0,.47,-.59),classic and steel or dark)
   piece(tool,handle,"SlideTop",Vector3.new(.29,.045,1.1),CFrame.new(0,.66,-.58),classic and edge or polymer)
   piece(tool,handle,"EjectionPort",Vector3.new(.022,.13,.3),CFrame.new(.192,.51,-.47),Color3.fromRGB(12,16,18))
   for i=1,5 do for _,side in {-1,1} do piece(tool,handle,"SlideSerration"..i.."_"..side,Vector3.new(.02,.25,.025),CFrame.new(side*.194,.48,.05-i*.07),classic and dark or steel) end end
   cylinder(tool,handle,"Barrel",.45,.15,CFrame.new(0,.46,muzzleZ+.18),steel)
   piece(tool,handle,"SlideCatch",Vector3.new(.06,.06,.27),CFrame.new(-.2,.32,-.1),steel)
   if classic then piece(tool,handle,"Hammer",Vector3.new(.13,.22,.14),CFrame.new(0,.5,.29)*CFrame.Angles(math.rad(25),0,0),dark)
   else piece(tool,handle,"AccessoryRail",Vector3.new(.23,.07,.48),CFrame.new(0,.08,-.73),dark) end
  end
  cylinder(tool,handle,"Bore",.02,.12,CFrame.new(0,.46,muzzleZ-.02),Color3.fromRGB(7,9,10))
  piece(tool,handle,"RearSight",Vector3.new(.3,.1,.1),CFrame.new(0,.72,.02),dark)
  piece(tool,handle,"FrontSight",Vector3.new(.07,.12,.08),CFrame.new(0,.69,muzzleZ+.13),dark)
  attachment(handle,"Muzzle",CFrame.new(0,.46,muzzleZ-.04))
  attachment(handle,"RightHandGrip",CFrame.new(.015,.02,.02)*CFrame.Angles(-math.pi/2,0,0))
  attachment(handle,"SupportGrip",CFrame.new(-.22,-.12,.04)*CFrame.Angles(-math.pi/2,0,math.pi/2))
  tool:SetAttribute("TwoHanded",true) tool.Grip=CFrame.new(0,-.15,-.2)
 elseif id=="Shotgun725" or id=="SPAS12" then
  shotgun(tool,handle,id)
 elseif data.Kind=="Gun" then
  local smg=id=="SMG" local sniper=id=="Sniper"
  local bodyLength=smg and 1.45 or sniper and 2.15 or 1.9
  local muzzleZ=smg and -2.35 or sniper and -4.45 or -3.35
  local barrelLength=smg and .8 or sniper and 2.45 or 1.55
  local accent=smg and Color3.fromRGB(69,131,127) or sniper and Color3.fromRGB(125,116,91) or Color3.fromRGB(92,111,118)
  piece(tool,handle,"PistolGrip",Vector3.new(.32,.72,.42),CFrame.new(0,-.07,.02)*CFrame.Angles(math.rad(-13),0,0),polymer,Enum.Material.SmoothPlastic)
  piece(tool,handle,"GripHeel",Vector3.new(.36,.12,.46),CFrame.new(0,-.46,.09),dark)
  piece(tool,handle,"LowerReceiver",Vector3.new(.48,.35,bodyLength),CFrame.new(0,.42,-.58),dark)
  piece(tool,handle,"UpperReceiver",Vector3.new(.44,.29,bodyLength*.94),CFrame.new(0,.72,-.61),steel)
  piece(tool,handle,"DustCover",Vector3.new(.5,.18,bodyLength*.78),CFrame.new(0,.86,-.6),dark)
  piece(tool,handle,"LeftReceiverPanel",Vector3.new(.045,.34,.9),CFrame.new(-.26,.55,-.45),accent,Enum.Material.SmoothPlastic)
  piece(tool,handle,"EjectionPort",Vector3.new(.035,.13,.46),CFrame.new(.26,.74,-.48),Color3.fromRGB(15,20,24))
  piece(tool,handle,"Bolt",Vector3.new(.045,.045,.3),CFrame.new(.28,.72,-.45),edge)
  piece(tool,handle,"ChargingHandle",Vector3.new(.25,.075,.12),CFrame.new(.37,.73,-.15),steel)
  piece(tool,handle,"TriggerGuardFront",Vector3.new(.08,.3,.08),CFrame.new(0,.06,-.43),dark)
  piece(tool,handle,"TriggerGuardBottom",Vector3.new(.09,.07,.48),CFrame.new(0,-.09,-.22),dark)
  piece(tool,handle,"Trigger",Vector3.new(.07,.23,.08),CFrame.new(0,.12,-.22)*CFrame.Angles(math.rad(-22),0,0),steel)
  for i=1,3 do
   piece(tool,handle,"Magazine"..i,Vector3.new(.34,.29,.44),CFrame.new(0,.16-i*.25,-.65-i*.035)*CFrame.Angles(math.rad(-7-i*5),0,0),i==3 and polymer or steel)
  end
  piece(tool,handle,"MagazineLip",Vector3.new(.39,.12,.51),CFrame.new(0,-.65,-.77),dark)
  local handguardLength=smg and .65 or sniper and 1.2 or .95
  local guardZ=smg and -1.33 or sniper and -1.9 or -1.6
  piece(tool,handle,"Handguard",Vector3.new(.5,.45,handguardLength),CFrame.new(0,.55,guardZ),polymer,Enum.Material.SmoothPlastic)
  piece(tool,handle,"LowerRail",Vector3.new(.3,.09,handguardLength),CFrame.new(0,.27,guardZ),dark)
  for i=1,3 do
   for _,side in {-1,1} do piece(tool,handle,"Vent"..i.."_"..side,Vector3.new(.025,.1,.12),CFrame.new(side*.26,.61,guardZ-handguardLength*.32+(i-1)*handguardLength*.31),Color3.fromRGB(13,18,22)) end
  end
  cylinder(tool,handle,"Barrel",barrelLength,.16,CFrame.new(0,.64,muzzleZ+barrelLength*.48),steel)
  cylinder(tool,handle,"GasBlock",.22,.26,CFrame.new(0,.65,muzzleZ+.4),dark)
  cylinder(tool,handle,"MuzzleBrake",.27,sniper and .28 or .25,CFrame.new(0,.64,muzzleZ+.04),dark)
  cylinder(tool,handle,"Bore",.015,.12,CFrame.new(0,.64,muzzleZ-.105),Color3.fromRGB(7,9,10))
  local railLength=bodyLength+handguardLength*.5
  piece(tool,handle,"OpticRail",Vector3.new(.24,.08,railLength),CFrame.new(0,.99,-.9),steel)
  for i=1,5 do piece(tool,handle,"RailTooth"..i,Vector3.new(.32,.06,.08),CFrame.new(0,1.05,-.25-i*.25),dark) end
  piece(tool,handle,"StockTube",Vector3.new(.22,.22,.75),CFrame.new(0,.57,.65),steel)
  piece(tool,handle,"StockBody",Vector3.new(.4,.43,smg and .65 or .85),CFrame.new(0,.48,1.03),polymer,Enum.Material.SmoothPlastic)
  piece(tool,handle,"StockCheek",Vector3.new(.39,.14,.65),CFrame.new(0,.76,1.05),accent,Enum.Material.SmoothPlastic)
  piece(tool,handle,"ButtPad",Vector3.new(.46,.73,.13),CFrame.new(0,.4,1.48),Color3.fromRGB(22,27,30),Enum.Material.SmoothPlastic)
  piece(tool,handle,"RearSight",Vector3.new(.24,.18,.16),CFrame.new(0,1.14,.07),dark)
  piece(tool,handle,"FrontSight",Vector3.new(.13,.28,.13),CFrame.new(0,.94,muzzleZ+.5),dark)
  if sniper then
   piece(tool,handle,"ScopeMount",Vector3.new(.3,.25,.85),CFrame.new(0,1.18,-.6),dark)
   cylinder(tool,handle,"ScopeBody",1.65,.42,CFrame.new(0,1.43,-.55),dark)
   cylinder(tool,handle,"ScopeObjective",.35,.58,CFrame.new(0,1.43,-1.4),polymer)
   cylinder(tool,handle,"ScopeEyepiece",.3,.46,CFrame.new(0,1.43,.33),polymer)
   local lens=cylinder(tool,handle,"ScopeGlass",.02,.49,CFrame.new(0,1.43,-1.58),Color3.fromRGB(76,146,159)) lens.Material=Enum.Material.Glass lens.Transparency=.22
   piece(tool,handle,"ElevationDial",Vector3.new(.27,.23,.27),CFrame.new(0,1.76,-.5),steel)
   piece(tool,handle,"WindageDial",Vector3.new(.2,.22,.22),CFrame.new(.31,1.44,-.5),steel)
  end
  attachment(handle,"Muzzle",CFrame.new(0,.64,muzzleZ-.11))
  attachment(handle,"RightHandGrip",CFrame.new(.015,.02,.02)*CFrame.Angles(-math.pi/2,0,0))
  local support=smg and -.55 or sniper and -.7 or -.6
  attachment(handle,"SupportGrip",CFrame.new(-.25,.37,support)*CFrame.Angles(-math.pi/2,0,math.pi/2))
  tool:SetAttribute("TwoHanded",true)
  tool.Grip=CFrame.new(0,-.15,-.2)
 else
  local hitbox
  if id=="Knife" then
   piece(tool,handle,"KnifeHandle",Vector3.new(.31,.95,.3),CFrame.new(0,.05,0),polymer,Enum.Material.SmoothPlastic)
   for i=1,4 do piece(tool,handle,"GripBand"..i,Vector3.new(.34,.045,.33),CFrame.new(0,-.35+i*.16,0),dark) end
   piece(tool,handle,"Pommel",Vector3.new(.36,.14,.35),CFrame.new(0,-.47,0),steel)
   piece(tool,handle,"Guard",Vector3.new(.66,.13,.32),CFrame.new(0,.55,0),dark)
   hitbox=piece(tool,handle,"Hitbox",Vector3.new(.28,1.9,.18),CFrame.new(0,1.5,0),steel) hitbox.Transparency=1
   piece(tool,handle,"BladeSpine",Vector3.new(.21,1.45,.11),CFrame.new(-.06,1.32,0),steel)
   piece(tool,handle,"BladeEdge",Vector3.new(.18,1.6,.085),CFrame.new(.09,1.4,0),edge,Enum.Material.Metal,"WedgePart")
   piece(tool,handle,"KnifeTip",Vector3.new(.26,.48,.11),CFrame.new(0,2.22,0),edge,Enum.Material.Metal,"WedgePart")
   tool.Grip=CFrame.new(0,-.45,0)*CFrame.Angles(math.rad(8),0,0)
  elseif id=="Sword" then
   piece(tool,handle,"SwordGrip",Vector3.new(.32,.95,.3),CFrame.new(0,0,0),Color3.fromRGB(34,58,79),Enum.Material.Fabric)
   for i=1,5 do piece(tool,handle,"GripWrap"..i,Vector3.new(.36,.04,.34),CFrame.new(0,-.4+i*.15,0)*CFrame.Angles(0,0,math.rad(12)),steel) end
   piece(tool,handle,"Pommel",Vector3.new(.5,.3,.4),CFrame.new(0,-.6,0),steel)
   piece(tool,handle,"Guard",Vector3.new(1.5,.18,.35),CFrame.new(0,.5,0),Color3.fromRGB(95,142,177))
   hitbox=piece(tool,handle,"Hitbox",Vector3.new(.55,3.5,.18),CFrame.new(0,2.35,0),steel) hitbox.Transparency=1
   piece(tool,handle,"Blade",Vector3.new(.42,3.1,.13),CFrame.new(0,2.13,0),steel)
   for _,side in {-1,1} do piece(tool,handle,"Edge"..side,Vector3.new(.1,3.1,.16),CFrame.new(side*.25,2.13,0),edge) end
   piece(tool,handle,"Fuller",Vector3.new(.09,2.7,.145),CFrame.new(0,2.08,0),Color3.fromRGB(62,87,103))
   piece(tool,handle,"SwordTip",Vector3.new(.51,.55,.13),CFrame.new(0,3.94,0),edge,Enum.Material.Metal,"WedgePart")
   tool.Grip=CFrame.new(0,-.5,0)
  elseif id=="Baton" or id=="Hammer" then
   local hammer=id=="Hammer"
   local length=hammer and 2.7 or 3.3
   cylinder(tool,handle,"Shaft",length,.22,CFrame.new(0,1.0,0)*CFrame.Angles(math.pi/2,0,0),hammer and Color3.fromRGB(115,78,43) or polymer).Material=hammer and Enum.Material.Wood or Enum.Material.SmoothPlastic
   for i=1,7 do cylinder(tool,handle,"GripRing"..i,.045,.28,CFrame.new(0,-.28+i*.10,0)*CFrame.Angles(math.pi/2,0,0),dark) end
   cylinder(tool,handle,"EndCap",.11,.33,CFrame.new(0,-.40,0)*CFrame.Angles(math.pi/2,0,0),steel)
   if hammer then
    piece(tool,handle,"HammerHead",Vector3.new(1.50,.68,.66),CFrame.new(0,2.15,0),steel)
    for _,side in {-1,1} do
     piece(tool,handle,"StrikingFace"..side,Vector3.new(.12,.73,.71),CFrame.new(side*.8,2.15,0),edge)
     piece(tool,handle,"HeadBevel"..side,Vector3.new(.27,.59,.63),CFrame.new(side*.63,2.15,0)*CFrame.Angles(0,0,side*math.pi/2),dark,Enum.Material.Metal,"WedgePart")
    end
    piece(tool,handle,"HeadCollar",Vector3.new(.38,.85,.73),CFrame.new(0,2.15,0),dark)
    hitbox=piece(tool,handle,"Hitbox",Vector3.new(1.8,.8,.8),CFrame.new(0,2.15,0),steel)
   else
    cylinder(tool,handle,"TipCap",.12,.28,CFrame.new(0,2.68,0)*CFrame.Angles(math.pi/2,0,0),dark)
    cylinder(tool,handle,"GripStop",.12,.44,CFrame.new(0,.52,0)*CFrame.Angles(math.pi/2,0,0),steel)
    hitbox=piece(tool,handle,"Hitbox",Vector3.new(.38,2.2,.38),CFrame.new(0,1.64,0),steel)
   end
   hitbox.Transparency=1
   attachment(handle,"RightHandGrip",CFrame.new(0,.0,0)*CFrame.Angles(-math.pi/2,0,0))
   tool.Grip=CFrame.new(0,-.35,0)
  else
   handle.Size=Vector3.new(.38,5.5,.38)
   piece(tool,handle,"AxeShaft",Vector3.new(.36,5.45,.36),CFrame.new(),Color3.fromRGB(94,70,49),Enum.Material.Wood)
   for i=1,7 do piece(tool,handle,"LeatherBinding"..i,Vector3.new(.44,.09,.44),CFrame.new(0,-1.65+i*.22,0),dark,Enum.Material.Fabric) end
   piece(tool,handle,"EndCap",Vector3.new(.55,.24,.55),CFrame.new(0,-2.7,0),steel)
   hitbox=piece(tool,handle,"Hitbox",Vector3.new(4.5,2.3,.45),CFrame.new(.3,2.6,0),steel) hitbox.Transparency=1
   piece(tool,handle,"AxeHead",Vector3.new(3.8,1.8,.42),CFrame.new(.25,2.6,0),steel)
   piece(tool,handle,"BladeBevel",Vector3.new(.8,2.4,.46),CFrame.new(2.17,2.6,0)*CFrame.Angles(0,0,math.pi/2),edge,Enum.Material.Metal,"WedgePart")
   piece(tool,handle,"RearSpike",Vector3.new(.65,1.2,.4),CFrame.new(-1.9,2.6,0)*CFrame.Angles(0,0,-math.pi/2),dark,Enum.Material.Metal,"WedgePart")
   piece(tool,handle,"HeadBand",Vector3.new(.8,2,.53),CFrame.new(0,2.6,0),dark)
   piece(tool,handle,"Collar",Vector3.new(.65,.5,.65),CFrame.new(0,1.62,0),Color3.fromRGB(158,125,72))
   attachment(handle,"RightHandGrip",CFrame.new(0,-.55,0)*CFrame.Angles(-math.pi/2,0,0))
   attachment(handle,"SupportGrip",CFrame.new(0,.05,0)*CFrame.Angles(-math.pi/2,0,0))
   tool:SetAttribute("TwoHanded",true)
   tool.Grip=CFrame.new(0,-1.2,0)*CFrame.Angles(0,math.rad(90),0)
  end
  if hitbox then
   local a=attachment(hitbox,"TrailTop",CFrame.new(0,hitbox.Size.Y/2,0))
   local b=attachment(hitbox,"TrailBottom",CFrame.new(0,-hitbox.Size.Y/2,0))
   local trail=Instance.new("Trail") trail.Attachment0=a trail.Attachment1=b trail.Enabled=false trail.Lifetime=.12 trail.Transparency=NumberSequence.new(.5,1) trail.Color=ColorSequence.new(Color3.fromRGB(214,230,243)) trail.Parent=hitbox
  end
 end
 refine(tool,handle,id,visual)
 if id=="ArenaPistol" then
  specialPistol(tool,handle,visual)
  if visual~="Magnum" then piece(tool,handle,"Magazine",Vector3.new(.23,.60,.27),CFrame.new(0,-.17,.10)*CFrame.Angles(math.rad(-15),0,0),steel):SetAttribute("ReloadGroup","Magazine") end
  for _,v in tool:GetChildren() do if v:IsA("BasePart") then
   if visual=="Magnum" and (v.Name:find("Cylinder") or v.Name:find("Chamber")) then v:SetAttribute("ReloadGroup","Cylinder")
   elseif v.Name=="GripBase" and visual~="Magnum" then v:SetAttribute("ReloadGroup","Magazine")
   elseif v.Name:find("Slide") or v.Name:find("Serration") then v:SetAttribute("ReloadGroup","Slide") end
  end end
 elseif data.Kind=="Gun" then
  for _,v in tool:GetChildren() do if id~="SPAS12" and id~="Shotgun725" and v.Name:find("Magazine") then v:SetAttribute("ReloadGroup","Magazine") end end
 end
 if id=="SPAS12" then for _,part in tool:GetChildren() do if part:GetAttribute("ReloadGroup")=="TubeShell" then part.Transparency=1 part:SetAttribute("ReloadOnly",true) end end end
 if data.Kind=="Gun" then Effects.Attach(tool,(id=="Sniper" or id=="Shotgun725" or id=="SPAS12") and 1.4 or id=="ArenaPistol" and .7 or 1) end
 local sound=Instance.new("Sound") sound.Name="FireSound" sound.SoundId=data.FireSound sound.Volume=data.FireVolume or (data.Kind=="Gun" and .42 or .55) sound.PlaybackSpeed=data.FirePlaybackSpeed or 1 sound.RollOffMaxDistance=data.FireRange or 100 sound.Parent=handle
 if data.PunchyAudio then
  local eq=Instance.new("EqualizerSoundEffect") eq.LowGain=3 eq.MidGain=1 eq.HighGain=2 eq.Parent=sound
  local compressor=Instance.new("CompressorSoundEffect") compressor.Threshold=-12 compressor.Ratio=3 compressor.Attack=.005 compressor.Release=.1 compressor.Parent=sound
 end
 if data.Kind=="Gun" then local reload=Instance.new("Sound") reload.Name="ReloadSound" reload.SoundId=Kits.ReloadSound reload.Volume=.3 reload.RollOffMaxDistance=35 reload.Parent=handle end
 tool:SetAttribute("RestGrip",tool.Grip) return tool
end
return Factory
