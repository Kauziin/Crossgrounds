-- Weapon rendering has its own camera/depth buffer. World walls cannot twist or clip it.
local Renderer={} Renderer.__index=Renderer
local Probe=require(script.Parent:WaitForChild("LocalLightingProbe"))
local Reload=require(game.ReplicatedStorage.Crossgrounds.WeaponReloadMotion)
local player=game.Players.LocalPlayer
local Motion=require(game.ReplicatedStorage.Crossgrounds.MotionPreferences)
local function safePart(p)
 p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false p.LocalTransparencyModifier=0
end
function Renderer.new(tool)
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
 model:ScaleTo(tool:GetAttribute("WeaponId")=="ArenaPistol" and .9 or tool:GetAttribute("WeaponKind")=="Gun" and .72 or .65)
 for _,p in model:GetChildren() do if p:IsA("BasePart") then table.insert(self.parts,{part=p,rest=p.CFrame,group=p:GetAttribute("ReloadGroup"),reloadOnly=p:GetAttribute("ReloadOnly")}) end end
 self.handle=handle self.scale=model:GetScale()
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
 local weight=Motion.WeaponWeight(player)
 local projection,depth=Motion.WeaponProjection(camera.FieldOfView,Motion.Get(player,"WeaponFOVScale",1))
 self.camera.FieldOfView=projection
 local function softened(cf) return Motion.Transform(cf,weight) end
 self.lightElapsed=(self.lightElapsed or 0)+dt
 if self.lightElapsed>.15 then
  self.lightElapsed=0 self.ambient,self.sunTint,self.sunDirection=Probe.Sample(camera,character)
 end
 if self.ambient then self.viewport.Ambient=self.ambient self.viewport.LightColor=self.sunTint end
 self.viewport.LightDirection=camera.CFrame:VectorToObjectSpace(-game.Lighting:GetSunDirection())
 local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances={character}
 local hit=workspace:Raycast(camera.CFrame.Position,camera.CFrame.LookVector*3,rp)
 local proximity=hit and math.clamp((2.4-hit.Distance)/1.6,0,1) or 0
 self.wall+=(proximity-self.wall)*(1-math.exp(-dt*13))
 local reloading=self.tool:GetAttribute("Reloading")
 local duration=self.tool:GetAttribute("ReloadDuration") or .9
 local t=reloading and math.clamp((workspace:GetServerTimeNow()-(self.tool:GetAttribute("ReloadStartedAt") or workspace:GetServerTimeNow()))/duration,0,1) or 0
 local reload=Reload.Sample(t,self.tool:GetAttribute("CosmeticId") or self.tool:GetAttribute("WeaponId"))
 for key,value in reload do if typeof(value)=="CFrame" then reload[key]=softened(value) elseif typeof(value)=="Vector3" then reload[key]=value*weight end end
 local pistol=self.tool:GetAttribute("WeaponId")=="ArenaPistol" local gun=self.tool:GetAttribute("WeaponKind")=="Gun"
 local lower=pistol and -.98 or gun and -1.18 or -1.30
 -- Counter the shared ADS lift only in the FP display, keeping the sightline open.
 local base=CFrame.new(pistol and .55 or .65,lower-.24*(params.ads or 0),(pistol and -1.7 or -2.1)*depth)
 local arc=(params.arc or 0)*weight
 local action=params.action or {weapon=CFrame.new(),slide=CFrame.new(),support=Vector3.zero}
 local cf=base*softened(action.weapon)*softened(params.runPose or CFrame.new())*reload.weapon*CFrame.new(-arc*.7,self.wall*.12-arc*.35,self.wall*.45+(params.recoil or 0)*weight)*CFrame.Angles(math.rad((params.pitch or 0)*weight+self.wall*55-arc*65),0,math.rad((params.roll or 0)*weight-arc*55))
 for _,entry in self.parts do
  local transform=entry.group=="Magazine" and reload.magazine or entry.group=="Cylinder" and reload.cylinder or entry.group=="Slide" and reload.slide*softened(action.slide) or entry.group=="Toggle" and reload.toggle or entry.group=="BreakAction" and reload.breakAction or entry.group=="Shell" and reload.breakAction*reload.shell or entry.group=="TubeShell" and reload.tubeShell or CFrame.new()
  entry.part.CFrame=cf*transform*entry.rest
  if entry.reloadOnly then entry.part.Transparency=reload.active>.02 and 0 or 1 end
 end
 for _,arm in self.arms do
  local side=arm.side=="Right" and 1 or -1
  local hand=arm.hand+(side<0 and reload.hand+(action.support or Vector3.zero)*weight or Vector3.zero)
  local elbow=Vector3.new(side*(.9+(.18+.36*math.sin(params.runPhase or 0))*(params.runWeight or 0)*weight),-.65,1.25)

  local a=cf:PointToWorldSpace(hand) local b=cf:PointToWorldSpace(elbow*self.scale)
  arm.part.Size=Vector3.new(.43,(a-b).Magnitude,.46)
  arm.part.CFrame=CFrame.lookAt((a+b)*.5,a)*CFrame.Angles(math.pi/2,0,0)
 end
 local muzzle=self.handle:FindFirstChild("Muzzle")
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
function Renderer:Destroy() if self.gui then self.gui:Destroy() end self.gui=nil end
return Renderer
