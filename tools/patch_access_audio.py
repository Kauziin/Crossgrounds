from pathlib import Path
root=Path(__file__).resolve().parents[1]
base=root/'artifacts/access-audio-2026-10-27/before'
out=root/'artifacts/access-audio-2026-10-27/after'
def read(path):return (base/path).read_text(encoding='utf-8')
def write(path,text):
 p=out/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text.rstrip()+'\n',encoding='utf-8')
def replace(s,a,b):
 assert a in s,a[:120]
 return s.replace(a,b)
p='ReplicatedStorage/ExperienceSettings.luau';s=read(p)
s=replace(s,'local extra={','''local extra={
 SimpleAnimations={Label="Animações simples",Default=false,Category="Accessibility"},
 WeaponAnimationIntensity={Label="Movimento das armas",Default=1,Min=0,Max=1,Step=.05,Percent=true,Category="Accessibility"},
 FOVTransitionSpeed={Label="Velocidade do FOV",Default=1,Min=.15,Max=1,Step=.05,Percent=true,Category="Accessibility"},
 WeaponFOVScale={Label="FOV das armas",Default=1,Choices={.75,1,1.25},Labels={[.75]="MENOS INTENSO",[1]="NORMAL",[1.25]="MAIS INTENSO"},Category="Camera"},
 GameSFXVolume={Label="Sons da partida",Default=.5,Min=0,Max=1,Step=.05,Percent=true,Category="Audio"},
 BeastProximityVolume={Label="Proximidade da Besta",Default=.35,Min=0,Max=1,Step=.05,Percent=true,Category="Audio"},''')
s=replace(s,'Camera={"FieldOfView","FirstPerson"','Camera={"FieldOfView","WeaponFOVScale","FirstPerson"')
s=replace(s,'Audio={"MenuVolume","MenuSFXVolume"}','Audio={"MenuVolume","MenuSFXVolume","GameSFXVolume","BeastProximityVolume"}')
s=replace(s,'Accessibility={"FontScale","HighContrast","ReducedMenuMotion","DamageFlash"}','Accessibility={"FontScale","HighContrast","ReducedMenuMotion","SimpleAnimations","WeaponAnimationIntensity","FOVTransitionSpeed","DamageFlash"}')
write(p,s)
p='StarterPlayer/StarterPlayerScripts/CombatPresentation.luau';s=read(p)
s=replace(s,'local motion=require(', 'local MotionPreferences=require(game.ReplicatedStorage.Crossgrounds.MotionPreferences)\nlocal motion=require(')
s=replace(s,'math.min(1,deltaTime*10)','MotionPreferences.FOVAlpha(deltaTime,setting("FOVTransitionSpeed"),10)')
s=replace(s,'math.min(1,dt*12)','MotionPreferences.FOVAlpha(dt,setting("FOVTransitionSpeed"),12)')
s=replace(s,'local bob,lean,nod=motion:Update','local cameraAmount=setting("CameraMotion")*(setting("SimpleAnimations") and .15 or 1)\n local bob,lean,nod=motion:Update')
s=replace(s,'aiming,setting("CameraMotion"),turnRate)','aiming,cameraAmount,turnRate)')
# Weapon intensity is applied once, centrally in the renderer. Camera shake remains separate.
write(p,s)
p='StarterPlayer/StarterPlayerScripts/FirstPersonRenderer.luau';s=read(p)
s=replace(s,'local player=game.Players.LocalPlayer','local player=game.Players.LocalPlayer\nlocal Motion=require(game.ReplicatedStorage.Crossgrounds.MotionPreferences)')
s=replace(s,' self:SetVisible(true)',''' self:SetVisible(true)
 local weight=Motion.WeaponWeight(player)
 local projection,depth=Motion.WeaponProjection(camera.FieldOfView,Motion.Get(player,"WeaponFOVScale",1))
 self.camera.FieldOfView=projection
 local function softened(cf) return Motion.Transform(cf,weight) end''')
s=replace(s,'local reload=Reload.Sample(t,self.tool:GetAttribute("CosmeticId") or self.tool:GetAttribute("WeaponId"))','''local reload=Reload.Sample(t,self.tool:GetAttribute("CosmeticId") or self.tool:GetAttribute("WeaponId"))
 for key,value in reload do if typeof(value)=="CFrame" then reload[key]=softened(value) elseif typeof(value)=="Vector3" then reload[key]=value*weight end end''')
s=replace(s,'pistol and -1.7 or -2.1)','(pistol and -1.7 or -2.1)*depth)')
s=replace(s,'local arc=params.arc or 0','local arc=(params.arc or 0)*weight')
s=replace(s,'base*action.weapon*(params.runPose or CFrame.new())','base*softened(action.weapon)*softened(params.runPose or CFrame.new())')
s=replace(s,'(params.recoil or 0)','(params.recoil or 0)*weight')
s=replace(s,'(params.pitch or 0)','(params.pitch or 0)*weight')
s=replace(s,'(params.roll or 0)','(params.roll or 0)*weight')
s=replace(s,'reload.slide*action.slide','reload.slide*softened(action.slide)')
s=replace(s,'(action.support or Vector3.zero)','(action.support or Vector3.zero)*weight')
s=replace(s,'*(params.runWeight or 0)','*(params.runWeight or 0)*weight')
write(p,s)
p='StarterPlayer/StarterPlayerScripts/WeaponPose.luau';s=read(p)
s=replace(s,'local active={} local pending={}', 'local Preferences=require(game.ReplicatedStorage.Crossgrounds.MotionPreferences)\nlocal viewer=Players.LocalPlayer\nlocal active={} local pending={}')
s=replace(s,'   local phase=os.clock()*.7','   local simple=Preferences.CharacterWeight(viewer)\n   local phase=os.clock()*.7')
s=replace(s,'for _,bot in bots:GetChildren() do','for _,bot in bots:GetChildren() do\n  local simple=Preferences.CharacterWeight(viewer)')
s=s.replace('   local simple=Preferences.CharacterWeight(viewer)\n   local phase','   local phase')
s=replace(s,'neck.Transform=CFrame.Angles(math.sin(phase*1.8)*.025,alert and 0 or math.sin(phase)*.18,math.sin(phase*.6)*.025)','neck.Transform=Preferences.Transform(CFrame.Angles(math.sin(phase*1.8)*.025,alert and 0 or math.sin(phase)*.18,math.sin(phase*.6)*.025),simple)')
s=replace(s,'local swing=math.sin(g.phase+(side=="Left" and 0 or math.pi))*weight','local swing=math.sin(g.phase+(side=="Left" and 0 or math.pi))*weight*simple')
s=replace(s,'if g.Waist then g.Waist.Transform=CFrame.new(0,math.sin(g.phase*2)*.025*weight,0)*CFrame.Angles(weight*.07,math.sin(g.phase)*.035*weight,0) end','if g.Waist then g.Waist.Transform=Preferences.Transform(CFrame.new(0,math.sin(g.phase*2)*.025*weight,0)*CFrame.Angles(weight*.07,math.sin(g.phase)*.035*weight,0),simple) end')
s=replace(s,'    local pose=r.carry:Update','    local visualWeight=Preferences.WeaponWeight(viewer)\n    local pose=r.carry:Update')
s=replace(s,'mount.Transform=pose desired=','pose=CFrame.Angles(math.clamp(pitch,-1.15,1.15)*.8,0,0)*Preferences.Transform(CFrame.Angles(-math.clamp(pitch,-1.15,1.15)*.8,0,0)*pose,visualWeight)\n    mount.Transform=pose desired=')
s=replace(s,'CFrame.new(reload and reload.hand or Vector3.zero)','CFrame.new(reload and reload.hand*Preferences.WeaponWeight(viewer) or Vector3.zero)')
write(p,s)
p='StarterPlayer/StarterPlayerScripts/CombatLocomotionPose.luau';s=read(p)
s=replace(s,'local Motion=require(', 'local Preferences=require(game.ReplicatedStorage.Crossgrounds.MotionPreferences)\nlocal Motion=require(')
s=replace(s,' local r=c and records[c]', ' local simple=Preferences.CharacterWeight(Players.LocalPlayer)\n local getOut=p:GetAttribute("CrossgroundsMode")=="get_out"\n if getOut and simple<1 and (p:GetAttribute("GetOutPosture")==nil or p:GetAttribute("GetOutPosture")=="Standing") then active=true end\n local r=c and records[c]')
s=replace(s,' or h.RigType~=Enum.HumanoidRigType.R15','')
s=replace(s,'{"LeftHip","RightHip","LeftKnee","RightKnee","LeftAnkle","RightAnkle","Waist"}', '{"LeftHip","RightHip","LeftKnee","RightKnee","LeftAnkle","RightAnkle","Waist","LeftShoulder","RightShoulder","LeftElbow","RightElbow","Neck","Left Hip","Right Hip","Left Shoulder","Right Shoulder"}')
s=replace(s,'e.base=e.joint.Transform e.applied=replace and offset or e.base*offset e.joint.Transform=e.applied','e.base=e.applied and e.base or e.joint.Transform\n    local base=Preferences.Transform(e.base,simple) local delta=Preferences.Transform(offset,simple)\n    e.applied=replace and delta or base*delta e.joint.Transform=e.applied e.applied=e.joint.Transform')
s=replace(s,'   if m.slide>.01 then','   if simple<1 then for name in r.joints do apply(name,CFrame.identity) end end\n   if getOut then continue end\n   if m.slide>.01 then')
write(p,s)
p='StarterPlayer/StarterPlayerScripts/GetOutCrawlAnimation.luau';s=read(p)
s=replace(s,'local T=require(', 'local Preferences=require(game.ReplicatedStorage.Crossgrounds.MotionPreferences)\nlocal T=require(')
s=replace(s,'    local posture=player:GetAttribute','    local intensity=Preferences.CharacterWeight(Players.LocalPlayer)\n    local posture=player:GetAttribute')
s=replace(s,'*.045*rig.movement*weight','*.045*rig.movement*weight*intensity')
s=replace(s,'sample(name,rig.phase,rig.movement)','sample(name,rig.phase,rig.movement*intensity)')
s=replace(s,'*6*rig.movement,0)','*6*rig.movement*intensity,0)')
s=replace(s,'*12+phase)*5)','*12+phase)*5*intensity)')
write(p,s)
p='StarterPlayer/StarterPlayerScripts/MenuNavigation.luau';s=read(p)
s=replace(s,'Focus={id="75458150587771",gain=.6}','Focus={id="10066931761",gain=.6}')
# Register-only controls also have activation feedback; Connect already owns its audio.
s=replace(s,' registered[object]={activate=callback,adjust=adjust}',''' registered[object]={activate=callback and function()
  if not object:GetAttribute("MenuAudioConnected") then Audio:Play(adjust and "Step" or "Confirm") end
  callback()
 end,adjust=adjust}''')
s=replace(s,'function Navigation:Connect(object,callback)','function Navigation:Connect(object,callback)\n object:SetAttribute("MenuAudioConnected",true)')
write(p,s)
print('Prepared eight targeted existing sources')
