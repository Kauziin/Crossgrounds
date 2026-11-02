local Renderer={} Renderer.__index=Renderer
local player=game.Players.LocalPlayer
local E=require(game.ReplicatedStorage.Crossgrounds.BlasterEffects)
local Probe=require(script.Parent.LocalLightingProbe)
local Preferences=require(game.ReplicatedStorage.Crossgrounds.MotionPreferences)
function Renderer.new(tool)
 local self=setmetatable({tool=tool,tracks={},connections={},arms={}},Renderer)
 local gui=Instance.new("ScreenGui") gui.Name="FirstPersonDisplay" gui.DisplayOrder=-10 gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.Parent=player.PlayerGui self.gui=gui
 local viewport=Instance.new("ViewportFrame") viewport.Name="WeaponViewport" viewport.Size=UDim2.fromScale(1,1) viewport.BackgroundTransparency=1 viewport.Parent=gui self.viewport=viewport
 local camera=Instance.new("Camera") camera.CFrame=CFrame.identity camera.FieldOfView=70 camera.Parent=viewport viewport.CurrentCamera=camera self.camera=camera
 local world=Instance.new("WorldModel") world.Parent=viewport
 local model=game.ReplicatedStorage.Crossgrounds.ProjectileTest.ViewModels[tool:GetAttribute("WeaponId")]:Clone()
 self.Model=model model.Parent=world self.root=model:FindFirstChild("Root") self.muzzle=model:FindFirstChild("MuzzleAttachment",true)
 for _,v in model:GetDescendants() do if v:IsA("BasePart") then
  v.Anchored=v==self.root v.CanCollide=false v.CanTouch=false v.CanQuery=false v.CastShadow=false
 end end
 -- Keep the source animation rig, and display square R6-named arms with the player's classic skin.
 local skin=Instance.new("Model") skin.Name="BlockyAvatarArms" skin.Parent=world self.skin=skin
 local humanoid=Instance.new("Humanoid") humanoid.RequiresNeck=false humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None humanoid.Parent=skin
 for _,class in {"Shirt","BodyColors"} do local v=player.Character and player.Character:FindFirstChildOfClass(class) if v then v:Clone().Parent=skin end end
 for _,name in {"Torso","Head","HumanoidRootPart","Left Leg","Right Leg"} do local p=Instance.new("Part") p.Name=name p.Transparency=1 p.Anchored=true p.CanCollide=false p.Parent=skin end
 for _,side in {"Left","Right"} do
  local source=model:FindFirstChild(side.."Arm") source.Transparency=1
  local arm=Instance.new("Part") arm.Name=side.." Arm" arm.Size=source.Size arm.Anchored=true arm.CanCollide=false arm.CanTouch=false arm.CanQuery=false arm.CastShadow=false arm.Material=Enum.Material.SmoothPlastic
  local original=player.Character and (player.Character:FindFirstChild(side.." Arm") or player.Character:FindFirstChild(side.."UpperArm"))
  arm.Color=original and original.Color or Color3.fromRGB(234,184,146) arm.Parent=skin table.insert(self.arms,{source=source,part=arm})
 end
 for _,animation in model.Animations:GetChildren() do
  local track=model.AnimationController.Animator:LoadAnimation(animation)
  track.Priority=animation.Name=="Idle" and Enum.AnimationPriority.Idle or Enum.AnimationPriority.Action
  track.Looped=animation.Name=="Idle" self.tracks[animation.Name]=track
  for _,c in E.Bind(track,tool,function()return workspace.CurrentCamera.CFrame.Position end) do table.insert(self.connections,c)end
 end
 self.tracks.Idle:Play(.1) self.tracks.Equip:Play(0)
 return self
end
function Renderer:SetVisible(on) self.gui.Enabled=on end
function Renderer:Flash()
 self.tracks.Shoot:Play(0,Preferences.WeaponWeight(player),1)
 if self.muzzle then for _,v in self.muzzle:GetChildren() do if v:IsA("ParticleEmitter") then v:Emit(1)end end end
 self.flashUntil=os.clock()+.045
end
function Renderer:Render(dt,camera,character,params)
 self:SetVisible(true)
 self.camera.FieldOfView=Preferences.WeaponProjection(camera.FieldOfView,Preferences.Get(player,"WeaponFOVScale",1))
 self.elapsed=(self.elapsed or 0)+dt
 if self.elapsed>.15 then self.elapsed=0 local ambient,tint=Probe.Sample(camera,character) self.viewport.Ambient=ambient self.viewport.LightColor=tint end
 self.viewport.LightDirection=camera.CFrame:VectorToObjectSpace(-game.Lighting:GetSunDirection())
 local reload=self.tool:GetAttribute("Reloading")==true
 if reload and not self.reloading then
  local track=self.tracks.Reload self.tracks.Shoot:Stop(0)
  track:Play(.1,Preferences.WeaponWeight(player),track.Length>0 and track.Length/math.max(.1,self.tool:GetAttribute("ReloadDuration") or 1)or 1)
 elseif not reload and self.reloading then self.tracks.Reload:Stop(.1) end
 self.reloading=reload
 if reload and self.tracks.Reload.Length>0 then self.tracks.Reload:AdjustSpeed(self.tracks.Reload.Length/math.max(.1,self.tool:GetAttribute("ReloadDuration")or 1))end
 local velocity=character.HumanoidRootPart.AssemblyLinearVelocity*Vector3.new(1,0,1)
 self.stride=(self.stride or 0)+velocity.Magnitude*.4*dt
 local amount=math.min(velocity.Magnitude*.4,1)*.05*Preferences.WeaponWeight(player)
 local offset=CFrame.new(.9,-1.3-.12*(params.ads or 0),-1.3)
 self.Model:PivotTo(offset*CFrame.new(math.sin(self.stride)*amount,math.sin(self.stride*2)*amount,0))
 for _,arm in self.arms do arm.part.CFrame=arm.source.CFrame end
 -- ViewportFrame particles are not rendered by Roblox; a short visible mesh flash supplies the FP cue.
 if not self.flash then
  local p=Instance.new("Part") p.Name="BlasterMuzzleFlash" p.Size=Vector3.new(.13,.13,.42) p.Material=Enum.Material.Neon p.Color=Color3.fromRGB(135,255,211) p.Anchored=true p.CanCollide=false p.Parent=self.Model self.flash=p
 end
 self.flash.Transparency=os.clock()<(self.flashUntil or 0) and .12 or 1
 if self.muzzle then self.flash.CFrame=self.muzzle.WorldCFrame*CFrame.new(0,0,-.2) end
end
function Renderer:ShotOrigin(camera)
 if not self.muzzle then return end
 local p=self.camera.CFrame:PointToObjectSpace(self.muzzle.WorldPosition) local depth=-p.Z
 if depth<=.1 then return end
 local v=camera.ViewportSize local tan=math.tan(math.rad(self.camera.FieldOfView*.5))
 local x=.5+p.X/(depth*2*tan*v.X/math.max(1,v.Y)) local y=.5-p.Y/(depth*2*tan)
 local ray=camera:ViewportPointToRay(x*v.X,y*v.Y)
 return camera.CFrame.Position+ray.Direction*math.min(depth,3)
end
function Renderer:Destroy()
 for _,c in self.connections do c:Disconnect()end
 for _,t in self.tracks do t:Stop(0)end
 self.gui:Destroy()
end
return Renderer
