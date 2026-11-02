-- Weapon rendering has its own camera/depth buffer. World walls cannot twist or clip it.
local Renderer={} Renderer.__index=Renderer
local Probe=require(script.Parent:WaitForChild("LocalLightingProbe"))
local Reload=require(game.ReplicatedStorage.Crossgrounds.WeaponReloadMotion)
local player=game.Players.LocalPlayer
local Motion=require(game.ReplicatedStorage.Crossgrounds.MotionPreferences)
local Hold=require(game.ReplicatedStorage.Crossgrounds.WeaponHold)
local ADS=require(game.ReplicatedStorage.Crossgrounds.ADSTransition)
local AX50=require(game.ReplicatedStorage.Crossgrounds.AX50Motion)
local AXOptics=require(script.Parent.AX50Optics)
local function safePart(p)
 p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false p.LocalTransparencyModifier=0
end
function Renderer.new(tool)
 if tool:GetAttribute("SourcePack")=="ProjectileTest" then return require(script.Parent.BlasterRenderer).new(tool) end
 local self=setmetatable({parts={},arms={},wall=0,flashUntil=0,tool=tool},Renderer)
 local gui=Instance.new("ScreenGui") gui.Name="FirstPersonDisplay" gui.DisplayOrder=-10 gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.Parent=player.PlayerGui self.gui=gui
 local viewport=Instance.new("ViewportFrame") viewport.Name="WeaponViewport" viewport.Size=UDim2.fromScale(1,1) viewport.BackgroundTransparency=1 viewport.Ambient=Color3.fromRGB(170,180,190) viewport.LightColor=Color3.fromRGB(255,244,223) viewport.LightDirection=Vector3.new(-1,-2,-3) viewport.Parent=gui self.viewport=viewport
 local camera=Instance.new("Camera") camera.CFrame=CFrame.new() camera.FieldOfView=70 camera.Parent=viewport viewport.CurrentCamera=camera self.camera=camera
 local world=Instance.new("WorldModel") world.Parent=viewport
 local model=Instance.new("Model") model.Name="FirstPersonWeapon" model.Parent=world self.Model=model
 local original=tool:FindFirstChild("Handle") if not original then self:Destroy() return end
 for _,v in tool:GetChildren() do if v:IsA("BasePart") then
  local p=v:Clone()
  for _,child in p:GetDescendants() do
   if child:IsA("BaseScript") or child:IsA("Sound") or child:IsA("WeldConstraint") or child:IsA("JointInstance") or child:IsA("Trail") or child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Light") then child:Destroy() end
  end
  safePart(p) p.CFrame=original.CFrame:ToObjectSpace(v.CFrame) p.Parent=model
 end end
 local handle=model:FindFirstChild("Handle") model.PrimaryPart=handle
 model:ScaleTo(Hold.IsPistol(tool) and .9 or tool:GetAttribute("WeaponKind")=="Gun" and .72 or .65)
 for _,p in model:GetChildren() do if p:IsA("BasePart") then table.insert(self.parts,{part=p,rest=p.CFrame,group=p:GetAttribute("ReloadGroup"),reloadOnly=p:GetAttribute("ReloadOnly")}) end end
 self.handle=handle self.scale=model:GetScale() self.reloadMotion=Reload.new()
 self.ax50=tool:GetAttribute("WeaponId")=="ax_50"
 if self.ax50 then self.cycleEffects=require(script.Parent:WaitForChild("AX50CycleEffects")).new(tool,world) end
 if self.ax50 and not tool:GetAttribute("OpticalAttachmentId") then self.optic=AXOptics.Build(model,self.parts) end
 local skin=Instance.new("Model") skin.Name="BlockyAvatarArms" skin.Parent=world self.skin=skin
 local humanoid=Instance.new("Humanoid") humanoid.RequiresNeck=false humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None humanoid.Parent=skin
 local character=player.Character
 for _,class in {"Shirt","BodyColors"} do local v=character and character:FindFirstChildOfClass(class) if v then v:Clone().Parent=skin end end
 local function part(name,size,color)
  local p=Instance.new("Part") p.Name=name p.Size=size p.Color=color p.Material=Enum.Material.SmoothPlastic safePart(p) p.Parent=skin return p
 end
 for _,name in {"Torso","Head","Left Leg","Right Leg","HumanoidRootPart"} do local p=part(name,Vector3.one,Color3.new()) p.Transparency=1 end
 for _,side in {"Right","Left"} do
  local source=character and (character:FindFirstChild(side.." Arm") or character:FindFirstChild(side.."UpperArm") or character:FindFirstChild(side.."LowerArm"))
  local color=source and source.Color or Color3.fromRGB(234,184,146)
  local arm=part(side.." Arm",Vector3.new(.43,1.5,.46),color)
  -- Classic shirt is applied by the R6-named parts; source meshes are intentionally absent.
  local grip=handle:FindFirstChild(side=="Right" and "RightHandGrip" or "SupportGrip")

  if grip then table.insert(self.arms,{part=arm,side=side,hand=grip.Position}) else arm.Transparency=1 end
 end
 local flash=Instance.new("Part") flash.Name="MuzzleFlash" flash.Size=Vector3.new(.18,.18,.55) flash.Color=Color3.fromRGB(255,222,123) flash.Material=Enum.Material.Neon flash.Transparency=1 safePart(flash) flash.Parent=model self.flash=flash
 return self
end
function Renderer:SetVisible(on) if self.gui then self.gui.Enabled=on end end
function Renderer:Flash() self.flashUntil=os.clock()+.045 end
function Renderer:Render(dt,camera,character,params)
 self:SetVisible(true)
 local transition=ADS.Sample(params.sight and params.ads or 0,params.sight)
 transition.reticle=params.sightActive and 1 or 0
 transition.lens=params.sightActive and 1 or 0
 if self.ocular then for _,v in self.ocular do v.part.Transparency=1-transition.lens end end
 local weight=Motion.WeaponWeight(player)
 local projection,depth=Motion.WeaponProjection(camera.FieldOfView,Motion.Get(player,"WeaponFOVScale",1))
 self.camera.FieldOfView=projection
 local function softened(cf) return Motion.Transform(cf,weight) end
 self.lightElapsed=(self.lightElapsed or 0)+dt
 if self.lightElapsed>.15 then
  self.lightElapsed=0 self.ambient,self.sunTint,self.sunDirection=Probe.Sample(camera,character)
 end
 if self.ambient then
  self.viewport.Ambient=self.optic and Color3.new(math.max(.30,self.ambient.R),math.max(.30,self.ambient.G),math.max(.30,self.ambient.B)) or self.ambient
  self.viewport.LightColor=self.optic and Color3.fromRGB(210,214,219) or self.sunTint
 end
 self.viewport.LightDirection=camera.CFrame:VectorToObjectSpace(-game.Lighting:GetSunDirection())
 local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={character}
 local hit=workspace:Raycast(camera.CFrame.Position,camera.CFrame.LookVector*3,rp)
 local proximity=hit and math.clamp((2.4-hit.Distance)/1.6,0,1) or 0
 self.wall+=(proximity-self.wall)*(1-math.exp(-dt*13))
 local reloading=self.tool:GetAttribute("Reloading")
 local duration=self.tool:GetAttribute("ReloadDuration") or .9
 local t=reloading and math.clamp((workspace:GetServerTimeNow()-(self.tool:GetAttribute("ReloadStartedAt") or workspace:GetServerTimeNow()))/duration,0,1) or 0
 local reload=self.reloadMotion:Update(self.tool,dt,workspace:GetServerTimeNow())
 for key,value in reload do if typeof(value)=="CFrame" then reload[key]=softened(value) elseif typeof(value)=="Vector3" then reload[key]=value*weight end end
 local pistol=Hold.IsPistol(self.tool) local gun=self.tool:GetAttribute("WeaponKind")=="Gun"
 local lower=pistol and -.98 or gun and -1.18 or -1.30
 -- Counter the shared ADS lift only in the FP display, keeping the sightline open.
 local base=CFrame.new(pistol and .55 or .65,lower-.24*(params.ads or 0),(pistol and -1.7 or -2.1)*depth)
 local arc=(params.arc or 0)*weight
 local action=params.action or {weapon=CFrame.new(),slide=CFrame.new(),support=Vector3.zero}
 local cf=base*softened(action.weapon)*softened(params.runPose or CFrame.new())*reload.weapon*CFrame.new(-arc*.7,self.wall*.12-arc*.35,self.wall*.45+(params.recoil or 0)*weight)*CFrame.Angles(math.rad((params.pitch or 0)*weight+self.wall*55-arc*65),0,math.rad((params.roll or 0)*weight-arc*55))
 local shotStamp=self.tool:GetAttribute("PresentationShotAt")
 local rejected=shotStamp~=nil and self.tool:GetAttribute("AX50RejectedShotStamp")==shotStamp
 local bolt=self.ax50 and AX50.Bolt(params.firedAgo or 100,params.cooldown,reloading or rejected) or nil
 local axialKick=self.ax50 and AX50.Kick(params.firedAgo or 100,params.ads,params.recoilStrength) or CFrame.identity
 if params.sight and params.sight.reticle=="RedDot" then
  for _,entry in self.parts do
   if entry.part:GetAttribute("VisualAttachmentSlot")=="optic" and entry.part.Name:find("Lens",1,true) then
    local eye=entry.rest.Position
    cf=cf:Lerp(CFrame.new(-eye.X,-eye.Y,-eye.Z-.65),transition.alignment)
    break
   end
  end
 end
 if bolt then cf*=softened(bolt.weapon) end
 if self.optic then
  local aligned=AXOptics.Alignment(self.optic,projection)
  local settle=transition.alignment*(1-reload.active)
  local kick=CFrame.new(0,0,(params.recoil or 0)*.12*weight)*CFrame.Angles(math.rad((params.pitch or 0)*.13*weight),0,math.rad((params.roll or 0)*.2*weight))
  local breath=math.sin(os.clock()*1.4)*.0015*weight*math.clamp(params.adsMotionMultiplier or 1,0,2)
  local tilt=math.rad(-4)*transition.alignment
  aligned=aligned*CFrame.new(self.optic.center)*CFrame.Angles(tilt,0,0)*CFrame.new(-self.optic.center)
  aligned=aligned*CFrame.new(breath,breath*.55,0)*softened(bolt.weapon)*kick
  cf=cf:Lerp(aligned,settle)
 end
 cf*=softened(axialKick)
 self.opticalAperture=self.optic and params.sight and AXOptics.Project(self.optic,cf,projection,camera.ViewportSize) or nil
 if self.opticalAperture then self.opticalAperture.visible=transition.reticle*(1-reload.active)*(1-bolt.active*.9) end
 if self.optic then for _,p in self.optic.parts do p.part.CFrame=cf*p.rest p.part.Transparency=1-transition.lens end end
 for _,entry in self.parts do
  local pivot=self.handle:FindFirstChild('ReloadPivot_'..tostring(entry.group))
  local transform=Reload.PartTransform(reload,entry.group,pivot and pivot.Position)
  if entry.group=='Slide' then transform*=softened(action.slide) end
  local cap=entry.part.Name=="Lens" or entry.part.Name=="Scope Base" or entry.part.Name=="Scope Base Pt 2"
  if self.ax50 and entry.part.Name=='Bolt' and not reloading then
   local pivot=Vector3.new(0,entry.rest.Y,entry.rest.Z)
   transform=CFrame.new(pivot)*softened(bolt.bolt)*CFrame.new(-pivot)
  end
  local bore=self.optic and (entry.part.Name=='Bolt' or entry.part.Name=='Base' or entry.part.Name=='Barrel' or entry.part.Name=='Muzzle' or entry.part.Name=='Rails' or entry.part.Name=='Handguard' or entry.part.Name=='Bullet')
  local reloadTransparency=reload.visibility and reload.visibility[entry.group] or 0
  local reflexLens=params.sight and params.sight.reticle=="RedDot" and entry.part:GetAttribute("VisualAttachmentSlot")=="optic" and entry.part.Name:find("Lens",1,true)
  entry.part.LocalTransparencyModifier=math.max(reloadTransparency*weight,reflexLens and transition.lens or entry.closedOptic and transition.lens or self.optic and 0 or params.sight and params.sight.hideWeapon and transition.lens or cap and transition.lens or 0)
  entry.part.CFrame=cf*transform*entry.rest
  if entry.reloadOnly then entry.part.Transparency=reload.active>.02 and 0 or 1 end
 end
 for _,arm in self.arms do
  arm.part.LocalTransparencyModifier=self.optic and 0 or transition.arms
  local side=arm.side=="Right" and 1 or -1
  local hand=arm.hand+(side<0 and reload.hand+(action.support or Vector3.zero)*weight or bolt and bolt.hand*weight or Vector3.zero)
  local elbow=Vector3.new(side*(.9+(.18+.36*math.sin(params.runPhase or 0))*(params.runWeight or 0)*weight),-.65,1.25)

  local a=cf:PointToWorldSpace(hand) local b=cf:PointToWorldSpace(elbow*self.scale)
  arm.part.Size=Vector3.new(.43,(a-b).Magnitude,.46)
  arm.part.CFrame=CFrame.lookAt((a+b)*.5,a)*CFrame.Angles(math.pi/2,0,0)
 end
 local muzzle=self.handle:FindFirstChild("Muzzle")
 if self.cycleEffects then
  local ejectFrame=cf*CFrame.new(Vector3.new(.25,.70,-1.1)*self.scale)
  self.cycleEffects:Update(dt,params.firedAgo or 100,self.tool:GetAttribute("PresentationShotAt"),params.cooldown,reloading,ejectFrame,self.scale)
 end
 if muzzle then
  self.flash.CFrame=muzzle.WorldCFrame*CFrame.new(0,0,-.2)
  self.flash.Transparency=os.clock()<self.flashUntil and .1 or 1
 end
 player:SetAttribute("WeaponWallRaise",self.wall) player:SetAttribute("WeaponRenderer","ViewportFrame")
end
function Renderer:ShotOrigin(worldCamera)
 local muzzle=self.handle and self.handle:FindFirstChild("Muzzle") if not muzzle then return end
 local p=self.camera.CFrame:PointToObjectSpace(muzzle.WorldPosition) local depth=-p.Z
 if depth<=.1 then return end
 local v=worldCamera.ViewportSize local tan=math.tan(math.rad(self.camera.FieldOfView*.5))
 local x=.5+p.X/(depth*2*tan*v.X/math.max(1,v.Y)) local y=.5-p.Y/(depth*2*tan)
 local ray=worldCamera:ViewportPointToRay(x*v.X,y*v.Y)
 return worldCamera.CFrame.Position+ray.Direction*math.min(depth,3)
end
function Renderer:Destroy() if self.cycleEffects then self.cycleEffects:Destroy() end if self.gui then self.gui:Destroy() end self.gui=nil end
return Renderer
