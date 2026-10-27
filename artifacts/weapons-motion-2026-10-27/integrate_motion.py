exec((__import__('pathlib').Path(__file__).parent/'prepare.py').read_text().split("put('StarterPlayer.StarterPlayerScripts.InputMode'")[0])

edit('ReplicatedStorage.ControlDefinitions','local Controls={}','Policy.Contexts.Slide={"ctf","arena"}\nlocal Controls={}')
edit('ReplicatedStorage.ControlDefinitions',' Sprint={Label="Alternar corrida",Gamepad="ButtonL3",Keyboard="LeftControl"},',' Slide={Label="Deslizar durante corrida",Gamepad="ButtonB",Keyboard="C"},\n Sprint={Label="Alternar corrida",Gamepad="ButtonL3",Keyboard="LeftControl"},')
# ButtonB already leaves the match; keep leave available on a separate physical key.
edit('ReplicatedStorage.ControlDefinitions','Leave={Label="Voltar ao lobby",Gamepad="ButtonB",Keyboard="L"}','Leave={Label="Voltar ao lobby",Gamepad="DPadLeft",Keyboard="L"}')
# DPadLeft was admin toggle; use a context-aware chord-free alternative only out of matches.
edit('ReplicatedStorage.ControlDefinitions','"AdminMode","Sprint"','"AdminMode","Slide","Sprint"')
edit('ReplicatedStorage.Crossgrounds.MobileLayout','"Jump","Sprint"','"Jump","Slide","Sprint"')
edit('ReplicatedStorage.Crossgrounds.MobileLayout',' Sprint={Label="CORRER"',' Slide={Label="DESLIZAR",Glyph="↘",X=.80,Y=.85,Size=54,Opacity=.8},\n Sprint={Label="CORRER"')
edit('ServerScriptService.Crossgrounds.HubBootstrap','require(script.Parent.SpawnProtectionService):Start()','require(script.Parent.CombatMovementService):Start()\n require(script.Parent.SpawnProtectionService):Start()')
edit('StarterPlayer.StarterPlayerScripts.SprintController','h.Jump=true','if player:GetAttribute("SlideActive") then game.ReplicatedStorage.Events.CombatSlide:FireServer(false) end\n h.Jump=true')

name='StarterPlayer.StarterPlayerScripts.CombatPresentation'
edit(name,'local swingAt=-100','local swingAt=-100\nlocal ActionMotion=require(game.ReplicatedStorage.Crossgrounds.WeaponActionMotion)\nlocal Locomotion=require(game.ReplicatedStorage.Crossgrounds.LocomotionMotion)\nlocal locomotion=Locomotion.new()\nlocal equippedAt=0 local firedAt=-100 local adsWeight=0')
edit(name,'if data.Kind=="Gun" then\n  if firstPerson and renderer then renderer:Flash() end','if data.Kind=="Gun" then\n  firedAt=os.clock()\n  if firstPerson and renderer then renderer:Flash() end')
edit(name,'currentTool=tool removeViewmodel()','currentTool=tool equippedAt=os.clock() firedAt=-100 adsWeight=0 locomotion=Locomotion.new() removeViewmodel()')
edit(name,'local focus=root.Position+Vector3.new(0,1.6,0)',r'''
 local localMove=rotation:VectorToObjectSpace(root.AssemblyLinearVelocity)
 local loco=locomotion:Update(dt,localMove,humanoid.FloorMaterial~=Enum.Material.Air,player:GetAttribute("SlideActive")==true)
 player:SetAttribute("CombatMovementState",loco.state)
 adsWeight+=((aiming and 1 or 0)-adsWeight)*(1-math.exp(-dt*18))
 local focus=root.Position+Vector3.new(0,1.6+loco.cameraY,0)''')
edit(name,'local swing=data.Kind~="Gun" and math.clamp((os.clock()-swingAt)/.42,0,1) or 1',r'''
  local arc=data.Kind~="Gun" and ActionMotion.Melee(os.clock()-swingAt,data) or 0
  local action=ActionMotion.Sample({equippedFor=os.clock()-equippedAt,ads=adsWeight,slide=loco.slide,land=loco.land,vertical=localMove.Y,firedAgo=os.clock()-firedAt})
  action.weapon=loco.weapon*action.weapon''')
edit(name,'arc=swing<1 and math.sin(swing*math.pi) or 0','arc=arc,action=action')

name='StarterPlayer.StarterPlayerScripts.FirstPersonRenderer'
edit(name,'local cf=base*(params.runPose or CFrame.new())*reload.weapon', 'local action=params.action or {weapon=CFrame.new(),slide=CFrame.new(),support=Vector3.zero}\n local cf=base*action.weapon*(params.runPose or CFrame.new())*reload.weapon')
edit(name,'entry.group=="Slide" and reload.slide','entry.group=="Slide" and reload.slide*action.slide')
edit(name,'local hand=arm.hand+(side<0 and reload.hand or Vector3.zero)','local hand=arm.hand+(side<0 and reload.hand+(action.support or Vector3.zero) or Vector3.zero)')
# Give blocky arms a real elbow silhouette, retaining classic shirt-compatible arm pieces.
edit(name,'if grip then table.insert(self.arms,{part=arm,side=side,hand=grip.Position}) else arm.Transparency=1 end',r'''
  if grip then
   local forearm=part(side.."Forearm",Vector3.new(.39,.7,.42),color)
   table.insert(self.arms,{part=arm,forearm=forearm,side=side,hand=grip.Position})
  else arm.Transparency=1 end''')
edit(name,r'''local a=cf:PointToWorldSpace(hand) local b=cf:PointToWorldSpace(elbow*self.scale)
  arm.part.Size=Vector3.new(.43,(a-b).Magnitude,.46)
  arm.part.CFrame=CFrame.lookAt((a+b)*.5,a)*CFrame.Angles(math.pi/2,0,0)''',r'''
  local a=cf:PointToWorldSpace(hand) local shoulder=Vector3.new(side*.78,-1.18,.25)
  local b=cf:PointToWorldSpace(elbow*self.scale)
  b=b:Lerp((a+shoulder)*.5,.32)
  arm.forearm.Size=Vector3.new(.39,math.max(.05,(a-b).Magnitude),.42)
  arm.forearm.CFrame=CFrame.lookAt((a+b)*.5,a)*CFrame.Angles(math.pi/2,0,0)
  arm.part.Size=Vector3.new(.43,math.max(.05,(b-shoulder).Magnitude),.46)
  arm.part.CFrame=CFrame.lookAt((b+shoulder)*.5,b)*CFrame.Angles(math.pi/2,0,0)''')

name='StarterPlayer.StarterPlayerScripts.WeaponPose'
edit(name,'local Carry=require(game.ReplicatedStorage.Crossgrounds.WeaponLocomotion)','local Carry=require(game.ReplicatedStorage.Crossgrounds.WeaponLocomotion)\nlocal Action=require(game.ReplicatedStorage.Crossgrounds.WeaponActionMotion)\nlocal Reload=require(game.ReplicatedStorage.Crossgrounds.WeaponReloadMotion)\nlocal Locomotion=require(game.ReplicatedStorage.Crossgrounds.LocomotionMotion)')
edit(name,'carry=Carry.new(),player=','carry=Carry.new(),equippedAt=os.clock(),locomotion=Locomotion.new(),kick=0,player=')
edit(name,'local desired\n   if mount','local desired local reload\n   if mount')
edit(name,'mount.Transform=pose desired=torso.CFrame*mount.C0*pose*mount.C1:Inverse()',r'''
    local now=workspace:GetServerTimeNow()
    local duration=math.max(.1,tool:GetAttribute("ReloadDuration") or 1)
    local t=tool:GetAttribute("Reloading") and math.clamp((now-(tool:GetAttribute("ReloadStartedAt") or now))/duration,0,1) or 0
    reload=Reload.Sample(t,tool:GetAttribute("CosmeticId") or tool:GetAttribute("WeaponId"))
    local loco=r.locomotion:Update(dt,velocity,r.humanoid.FloorMaterial~=Enum.Material.Air,r.character:GetAttribute("SlideActive")==true)
    local action=Action.Sample({equippedFor=os.clock()-r.equippedAt,slide=loco.slide,land=loco.land})
    local shot=tool:GetAttribute("PresentationShotAt") or -100
    local kick=math.exp(-math.max(0,now-shot)*22)
    local pitch=r.character:GetAttribute("CombatAimPitch") or 0
    pose=CFrame.Angles(math.clamp(pitch,-1.15,1.15)*.8,0,0)*pose*action.weapon*reload.weapon*CFrame.new(0,0,kick*.10)*CFrame.Angles(kick*.04,0,0)
    mount.Transform=pose desired=torso.CFrame*mount.C0*pose*mount.C1:Inverse()''')
edit(name,'Pose.Solve(r.left,r.support,desired and desired*r.support.CFrame)', 'Pose.Solve(r.left,r.support,desired and desired*(r.support.CFrame+CFrame.new().Position+(reload and reload.hand or Vector3.zero)))')
# Correct attachment-space hand offset with explicit CFrame composition.
edit(name,'desired*(r.support.CFrame+CFrame.new().Position+(reload and reload.hand or Vector3.zero))','desired*CFrame.new(reload and reload.hand or Vector3.zero)*r.support.CFrame')
print('Integrated movement and action presentation')
