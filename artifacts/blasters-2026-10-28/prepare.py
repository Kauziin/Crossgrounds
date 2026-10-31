from pathlib import Path
import shutil,json
T=Path(__file__).resolve().parent;R=T.parents[1];W=T/'work/src'
def save(p,s):
 f=W/p;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(s,encoding='utf-8')
def edit(p,pairs):
 s=(T/'baseline'/p).read_text(encoding='utf-8-sig')
 for a,b in pairs:
  assert a in s,(p,a)
  s=s.replace(a,b,1)
 save(p,s)
edit('ReplicatedStorage/Crossgrounds/AimAssist.luau',[
 ('dt>.075','dt>.15'),
 ('local delta=state.velocity*dt*gain','local correctionDt=math.min(dt,.05)\n local delta=state.velocity*correctionDt*gain'),
 ('MaxYawRate)*strength*trackingRange*dt','MaxYawRate)*strength*trackingRange*correctionDt'),
 ('MaxPitchRate)*strength*trackingRange*dt','MaxPitchRate)*strength*trackingRange*correctionDt'),
 (' if state.health<=0',' if state.practiceShooter then return state.mode=="ctf" and state.targetPractice==true and state.health>0 and not state.protected end\n if state.health<=0')])
edit('StarterPlayer/StarterPlayerScripts/TargetingAssist.luau',[
 ('local models=setmetatable({},{__mode="k"})','local models={}'),
 ('workspace.DescendantAdded:Connect(track) for _,item in workspace:GetDescendants() do track(item) end','workspace.DescendantAdded:Connect(track)\nworkspace.DescendantRemoving:Connect(function(item) if item:IsA("Humanoid") then models[item.Parent]=nil end end)\nfor _,item in workspace:GetDescendants() do track(item) end'),
 (' local input=Mode:Get()', ' local input=Mode:Get()\n player:SetAttribute("AimAssistInput",input.Name)'),
 (' local ray=camera:ViewportPointToRay', ' player:SetAttribute("AimAssistEligibleTargets",#active)\n local ray=camera:ViewportPointToRay'),
 (' return Math.Eligible({mode=Scope:Get()', ' local lobby=workspace:FindFirstChild("CTFLobby")\n local practice=ctf and player.Character and player.Character:GetAttribute("AtLobby")==true\n return Math.Eligible({practiceShooter=practice,targetPractice=lobby and model:IsDescendantOf(lobby) and model:GetAttribute("PracticeDummy")==true,mode=Scope:Get()')])
edit('StarterPlayer/StarterPlayerScripts/CombatPresentation.luau',[
 (' touchIntent=touchRadians.Magnitude>0 and Vector2.new(-touchRadians.X,-touchRadians.Y)/(math.max(deltaTime,.001)*2.4) or Vector2.zero',' touchIntent=Intent.TouchLook(touchIntent,touchRadians,deltaTime,touchLook~=nil,os.clock()-touchSampleAt)'),
 (' if assisted and (locked or firstPerson) then\n  yaw+=tracking.X pitch=math.clamp(pitch+tracking.Y,-1.25,1.25)\n end', ' if assisted then\n  if locked or firstPerson then yaw+=tracking.X pitch=math.clamp(pitch+tracking.Y,-1.25,1.25)\n  else\n   local scale=camera.ViewportSize.Y/(2*math.tan(math.rad(camera.FieldOfView*.5)))\n   freePoint=(freePoint or camera.ViewportSize*.5)+Vector2.new(-tracking.X,-tracking.Y)*scale\n   freePoint=Vector2.new(math.clamp(freePoint.X,8,camera.ViewportSize.X-8),math.clamp(freePoint.Y,8,camera.ViewportSize.Y-8))\n  end\n end'),
 ('classify=classify,maxTargets=data.MaxTargets,penetrationLoss=data.PenetrationLoss}).endpoint','classify=classify,radius=config.radius,maxTargets=data.MaxTargets,penetrationLoss=data.PenetrationLoss}).endpoint'),
 ('Effects.Trace(origin,endpoint,nil,config.visual)', 'Effects.Trace(origin,endpoint,nil,config.visual)'),
 ('  spring:Kick(profile,math.random()<.5 and -1 or 1)', '  if data.SourcePack=="ProjectileTest" then\n   local low,high=data.CameraRecoilMin,data.CameraRecoilMax\n   sourceRecoil+=Vector2.new(math.rad(-(low.X+math.random()*(high.X-low.X))),math.rad(low.Y+math.random()*(high.Y-low.Y)))\n   sourceFovKick=1\n  end\n  spring:Kick(profile,math.random()<.5 and -1 or 1)'),
 ('local yaw,pitch=0,0','local sourceRecoil=Vector2.zero\nlocal sourceFovKick=0\nlocal yaw,pitch=0,0'),
 (' local own=message.actor==player.Character',' if message.visual and message.visual.SourcePack=="ProjectileTest" and message.phase~="launch" and message.reason~="range" then require(game.ReplicatedStorage.Crossgrounds.BlasterEffects).Impact(message.endpoint,message.normal,message.reason=="targets") end\n local own=message.actor==player.Character'),
 (' local rotation=CFrame.fromEulerAnglesYXZ(pitch,yaw,0)',' yaw+=sourceRecoil.X*dt pitch=math.clamp(pitch+sourceRecoil.Y*dt,-1.25,1.25)\n sourceRecoil=sourceRecoil:Lerp(Vector2.zero,math.min(dt*10,1))\n local rotation=CFrame.fromEulerAnglesYXZ(pitch,yaw,0)'),
 (' spring:Reset() carry:Reset() recoil=0 recoilPitch=0 roll=0',' sourceRecoil=Vector2.zero sourceFovKick=0\n spring:Reset() carry:Reset() recoil=0 recoilPitch=0 roll=0'),
 (' camera.FieldOfView+=(fov-camera.FieldOfView)', ' sourceFovKick*=math.exp(-deltaTime*20) fov+=sourceFovKick\n camera.FieldOfView+=(fov-camera.FieldOfView)')])
edit('ReplicatedStorage/Crossgrounds/AimAssistIntent.luau',[
 ('return table.freeze(Intent)','function Intent.TouchLook(previous,radians,dt,owned,age)\n if not owned or age<0 or age>Intent.TouchTimeout then return Vector2.zero end\n if radians.Magnitude==0 then return previous or Vector2.zero end\n local look=Vector2.new(-radians.X,-radians.Y)/(math.max(dt,.001)*2.4)\n return look.Magnitude>1 and look.Unit or look\nend\nreturn table.freeze(Intent)')])
edit('ServerScriptService/Crossgrounds/ShotAuthority.luau',[
 ('local options={origin=origin,direction=direction,range=config.range,shooter=c,maxTargets=data.MaxTargets,','local options={origin=origin,direction=direction,range=config.range,shooter=c,radius=config.radius,maxTargets=data.MaxTargets,')])
edit('ServerScriptService/Crossgrounds/ShotHistory.luau',[
 ('function History.Box(origin,direction,range,cf,size)','function History.Box(origin,direction,range,cf,size,radius)\n if (radius or 0)>0 then return require(game.ReplicatedStorage.Crossgrounds.SweptSphereBox)(origin,direction,range,cf,size,radius) end'),
 ('History.Box(origin,direction,range,pose.cf,pose.size)','History.Box(origin,direction,range,pose.cf,pose.size,options.radius)'),
 ('range=range,shooter=options.shooter,ignore=ignored,','range=range,shooter=options.shooter,ignore=ignored,radius=options.radius,')])
p='ReplicatedStorage/KitDefinitions.luau';s=(T/'baseline'/p).read_text(encoding='utf-8-sig')
at=s.index('-- All existing guns remain')
s=s[:at]+'''-- Original Projectile Test firearms; damage remains server authoritative.
Kits.Weapons.Blaster={Name="Blaster",Kind="Gun",SourcePack="ProjectileTest",Damage=35,Range=1000,Magazine=10,Reserve=100,ReloadTime=1,Cooldown=.1,Automatic=false,Spread=2,ProjectileRadius=.4,ShotVisual={Speed=200,Length=18,Width=.08,SourcePack="ProjectileTest"},FireSound="rbxassetid://17682716783",CameraRecoilMin=Vector2.new(0,15),CameraRecoilMax=Vector2.new(5,20),VisualRecoil={Push=0,Pitch=0,Roll=0}}
Kits.Weapons.AutoBlaster={Name="AutoBlaster",Kind="Gun",SourcePack="ProjectileTest",Damage=10,Range=1000,Magazine=30,Reserve=180,ReloadTime=1.5,Cooldown=.1,Automatic=true,Spread=2,ProjectileRadius=.4,ShotVisual={Speed=200,Length=18,Width=.08,SourcePack="ProjectileTest"},FireSound="rbxassetid://17682714653",CameraRecoilMin=Vector2.new(-2,5),CameraRecoilMax=Vector2.new(2,7),VisualRecoil={Push=0,Pitch=0,Roll=0}}
for _,id in {"Blaster","AutoBlaster"} do
 table.insert(Kits.Order,id)
 Kits.Profiles[id]={Title=id=="Blaster" and "BLASTER" or "AUTO BLASTER",Description="Projectile Test",WalkSpeed=18,SprintSpeed=25,JumpHeight=7.2,Weapons={"Sword",id}}
 table.insert(Kits.ArenaPistolVisuals,id) Kits.ArenaPistolNames[id]=id
end
function Kits.ArenaGunId(visual) return (visual=="Blaster" or visual=="AutoBlaster") and visual or "ArenaPistol" end
'''+s[at:];save(p,s)
edit('ReplicatedStorage/Crossgrounds/LoadoutDefinitions.luau',[
 ('or "ArenaPistol"','or Kits.ArenaGunId(id)'),
 ('or "PISTOLA",','or (first=="AutoBlaster" and "AUTOMÁTICA" or first=="Blaster" and "BLASTER" or "PISTOLA"),')])
edit('ServerScriptService/Crossgrounds/ArenaCombat.luau',[
 ('cooldown=math.max(1,data.Cooldown)', 'cooldown=data.SourcePack=="ProjectileTest" and data.Cooldown or math.max(1,data.Cooldown)'),
 ('if not table.find(Kits.ArenaWeapons,id) then return end','if id~="Sword" and id~=Kits.ArenaGunId(player:GetAttribute("ArenaPistolVisual")) then return end'),
 ('local data=Kits.Weapons[id] t:SetAttribute','local data=Kits.Weapons[t:GetAttribute("WeaponId")] t:SetAttribute')])
edit('StarterPlayer/StarterPlayerScripts/WeaponController.luau',[
 ('Scope:IsArena() and math.max(1,data.Cooldown) or data.Cooldown','Scope:IsArena() and data.SourcePack~="ProjectileTest" and math.max(1,data.Cooldown) or data.Cooldown'),
 ('and Kits.ArenaWeapons or profile and profile.Weapons','and {Kits.ArenaWeapons[1],Kits.ArenaGunId(player:GetAttribute("ArenaPistolVisual"))} or profile and profile.Weapons')])
edit('StarterPlayer/StarterPlayerScripts/LoadoutMenuView.luau',[
 ('weaponName.Text=entry.primary','weaponName.Text=entry.primary kind.Text=entry.class'),
 ('local class=text(b,"Class","PISTOLA",10,false)','local class=text(b,"Class",entry.class,10,false)')])
edit('ServerScriptService/MainGameScript/GameManager/WeaponFactory.luau',[
 ('function Factory:Create(id,visual)','function Factory:Create(id,visual)\n if id=="ArenaPistol" then id=Kits.ArenaGunId(visual) end\n if id=="Blaster" or id=="AutoBlaster" then return require(game.ReplicatedStorage.Crossgrounds.BlasterWeapons).Create(id) end')])
edit('StarterPlayer/StarterPlayerScripts/FirstPersonRenderer.luau',[
 ('function Renderer.new(tool)','function Renderer.new(tool)\n if tool:GetAttribute("SourcePack")=="ProjectileTest" then return require(script.Parent.BlasterRenderer).new(tool) end')])
edit('ReplicatedStorage/Crossgrounds/WeaponEffects.luau',[
 ('function Effects.Play(tool)','function Effects.Play(tool)\n if tool and tool:GetAttribute("SourcePack")=="ProjectileTest" then return require(script.Parent.BlasterEffects).Flash(tool) end'),
 ('function Effects.PlaySound(tool)','function Effects.PlaySound(tool)\n if tool and tool:GetAttribute("SourcePack")=="ProjectileTest" then return require(script.Parent.BlasterEffects).Sound(tool,"Shoot") end'),
 ('Effects.Trace=Cosmetics.Trace','Effects.Trace=function(origin,endpoint,color,visual)\n if visual and visual.SourcePack=="ProjectileTest" then return require(script.Parent.BlasterEffects).Trace(origin,endpoint) end\n return Cosmetics.Trace(origin,endpoint,color,visual)\nend'),
 ('Effects.CancelTrace=Cosmetics.Cancel','Effects.CancelTrace=function(entry) if entry and entry.blaster then entry.part:Destroy() else Cosmetics.Cancel(entry) end end'),
 ('Effects.CorrectTrace=Cosmetics.Correct','Effects.CorrectTrace=function(entry,endpoint) if entry and entry.blaster then if entry.part.Parent then entry.target.WorldPosition=endpoint end else Cosmetics.Correct(entry,endpoint) end end')])
print('Prepared 11 modified sources')
