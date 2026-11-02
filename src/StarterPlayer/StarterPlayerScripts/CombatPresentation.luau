-- Never acquire an editor camera if this module is inspected outside Play.
if not game:GetService("RunService"):IsRunning() then return {} end
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local InputMode=require(script.Parent:WaitForChild("InputMode"))
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local Presentation={}
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local GuiService=game:GetService("GuiService")
local Gamepad=game:GetService("GamepadService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local Kits=require(game.ReplicatedStorage:WaitForChild("KitDefinitions"))
local Stats=require(game.ReplicatedStorage.Crossgrounds.WeaponStats)
local Settings=require(game.ReplicatedStorage:WaitForChild("ExperienceSettings"))
local settingRemote=game.ReplicatedStorage.Events:WaitForChild("UpdateExperienceSetting")
local sourceRecoil=Vector2.zero
local sourceFovKick=0
local yaw,pitch=0,0
local stick=Vector2.zero
local stickGate={}
local touchDelta=Vector2.zero
local freePoint
local touchLook local touchPosition local lastTouchLook=0
local touchIntent=Vector2.zero local touchSampleAt=0
local aiming,firing=false,false
local SniperZoom=require(game.ReplicatedStorage.Crossgrounds.SniperZoom)
local zoomLevel=1
local InputIcons=require(script.Parent.InputIcons)
local zoomGlyphs={} local zoomGlyphLabels={}
local SightDefinitions=require(game.ReplicatedStorage.Crossgrounds.SightDefinitions)
local AttachmentEffects=require(game.ReplicatedStorage.Crossgrounds.AttachmentEffects)
local opticalSight=require(script.Parent.OpticalSight).new(player)
local zoomGui=Instance.new("ScreenGui")
zoomGui.Name="SniperZoomHUD" zoomGui.ResetOnSpawn=false zoomGui.DisplayOrder=-8
zoomGui.Parent=player:WaitForChild("PlayerGui")
local zoomButton=Instance.new("TextButton")
zoomButton.Name="Amplification" zoomButton.Size=UDim2.fromOffset(110,30)
zoomButton.AnchorPoint=Vector2.new(1,.5) zoomButton.Position=UDim2.new(.12,0,.5,0)
zoomButton.BackgroundColor3=Color3.fromRGB(16,27,41) zoomButton.BackgroundTransparency=1
zoomButton.TextColor3=Color3.fromRGB(235,242,255) zoomButton.Font=Enum.Font.GothamMedium
zoomButton.TextSize=12 zoomButton.Visible=false zoomButton.Selectable=false zoomButton.Parent=zoomGui
Instance.new("UICorner",zoomButton).CornerRadius=UDim.new(0,8)
for i,action in {"ScopeZoomIn","ScopeZoomOut"} do
 local glyph,refresh=InputIcons:Glyph(zoomButton,action,function() return Router:Key(action,InputMode:Get()==Enum.PreferredInput.Gamepad and "Gamepad" or "Keyboard") end,18)
 glyph.Position=UDim2.fromOffset(30+(i-1)*25,30) table.insert(zoomGlyphs,refresh) table.insert(zoomGlyphLabels,glyph)
end
local locked,firstPerson,shoulder=true,false,1
local practiceFirstPerson=player:GetAttribute("CTFPracticeRange")==true and true or nil
local CameraPolicy=require(game.ReplicatedStorage.Crossgrounds.CombatCameraPolicy)
local Intent=require(game.ReplicatedStorage.Crossgrounds.AimAssistIntent)
local windowFocused=true
local Analog=require(game.ReplicatedStorage.Crossgrounds.AnalogFilter)
local Assist=require(script.Parent:WaitForChild("TargetingAssist"))
local assistFriction=1
local MotionPreferences=require(game.ReplicatedStorage.Crossgrounds.MotionPreferences)
local motion=require(game.ReplicatedStorage.Crossgrounds.CameraMotion).new()
local Effects=require(game.ReplicatedStorage.Crossgrounds.WeaponEffects)
local Query=require(game.ReplicatedStorage.Crossgrounds.ShotQuery)
local Shot=require(game.ReplicatedStorage.Crossgrounds.ShotMath)
local carry=require(game.ReplicatedStorage.Crossgrounds.WeaponLocomotion).new()
local armRigs={} local previousYaw
local aimFrame
local initialized=false
local owned=false
local currentTool
local viewmodel
local Renderer=require(script.Parent:WaitForChild("FirstPersonRenderer")) local renderer
local saved={}
local predicted={} local protectionToken local protectionYaw,protectionPitch
local remoteShots=setmetatable({},{__mode="k"})
local protectionRemote=game.ReplicatedStorage.Events:WaitForChild("BreakSpawnProtection")
local hidden=setmetatable({},{__mode="k"})
local spring=require(game.ReplicatedStorage.Crossgrounds.WeaponRecoil).new()
local cameraSpring=require(game.ReplicatedStorage.Crossgrounds.WeaponRecoil).new()
local cameraRecoilProfile={Spring=170,Damping=26}
local recoil,recoilPitch,roll=0,0,0
local swingAt=-100
local ActionMotion=require(game.ReplicatedStorage.Crossgrounds.WeaponActionMotion)
local Locomotion=require(game.ReplicatedStorage.Crossgrounds.LocomotionMotion)
local locomotion=Locomotion.new()
local equippedAt=0 local firedAt=-100 local adsWeight=0
local poseRemote=game.ReplicatedStorage.Events:WaitForChild("CombatPose")
local lastPoseAt=-100 local sentPitch=0 local sentAiming=false
local function setting(key)
 local v=player:GetAttribute("Setting"..key)
 if v==nil then return Settings.Rules[key].Default end return v
end
local function persist(key,value)
 player:SetAttribute("Setting"..key,value)
 settingRemote:FireServer(key,value)
end
function Presentation:IsBlocked()
 local m=player.PlayerGui:FindFirstChild("JoinMenu")
 local h=player.PlayerGui:FindFirstChild("CombatHUD")
 return player:GetAttribute("SpectatingEliminator")==true or Router:IsBlocked()
end
local savedCameraMode
local function modeCamera()
 if Scope:IsArena() then
  if savedCameraMode==nil then savedCameraMode=player.CameraMode end
  player.CameraMode=Enum.CameraMode.LockFirstPerson
 elseif savedCameraMode~=nil then player.CameraMode=savedCameraMode savedCameraMode=nil end
end
Scope.Changed:Connect(modeCamera) modeCamera()
local function current()
 if not Scope:IsCombat() then return end
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 local t=c and c:FindFirstChildOfClass("Tool")
 local data = t and Stats.ResolveTool(t)
 if h and h.Health>0 and c:FindFirstChild("HumanoidRootPart") and data then return c,h,t,data end
end
local function cursorMode()
 if GuiService.MenuIsOpen then return end
 pcall(function() Gamepad:DisableGamepadCursor() end)
end
function Presentation:ToggleLock()
 if self:IsBlocked() or not current() then return end
 local _,_,_,data=current() if data.Kind=="Gun" or Scope:IsArena() then return end
 locked=not locked persist("ShiftLock",locked) cursorMode()
end
function Presentation:ToggleShoulder()
 if self:IsBlocked() or not current() then return end
 shoulder=-shoulder persist("Shoulder",shoulder)
end
function Presentation:TogglePerspective()
 if self:IsBlocked() or not current() then return end
 if Scope:IsArena() then return end
 firstPerson=not firstPerson
 if practiceFirstPerson~=nil then practiceFirstPerson=firstPerson else persist("FirstPerson",firstPerson) end
end
function Presentation:SetAiming(value) aiming=value and not self:IsBlocked() or false if not aiming then zoomLevel=1 end end
function Presentation:SetFiring(value) firing=value and not self:IsBlocked() or false player:SetAttribute("CombatFiring",firing) end
function Presentation:GetAimViewport()
 local v=workspace.CurrentCamera.ViewportSize
 if v.X<2 or v.Y<2 then return v*.5 end
 local point
 if locked then point=v*.5
 elseif InputMode:Get()==Enum.PreferredInput.Touch then point=freePoint or v*.5
 elseif InputMode:Get()==Enum.PreferredInput.Gamepad then
  point=freePoint or v*.5
 else point=UIS:GetMouseLocation() end
 if not point or point.X<0 or point.Y<0 then point=freePoint or v*.5 end
 return Vector2.new(math.clamp(point.X,1,v.X-1),math.clamp(point.Y,1,v.Y-1))
end
local clientRelation
local lastAimHit,lastAimOrigin
function Presentation:GetRangeTarget()
 return lastAimHit,lastAimOrigin
end
function Presentation:GetAimWorld(range)
 local camera=workspace.CurrentCamera
 local point=self:GetAimViewport()
 local ray=camera:ViewportPointToRay(point.X,point.Y)
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
 local ignore={} if player.Character then table.insert(ignore,player.Character) end if viewmodel then table.insert(ignore,viewmodel) end
 local function ignoreCharacter(c,allied)
  local h=c and c:FindFirstChildOfClass("Humanoid")
  if c and (allied or h and h.Health<=0) then table.insert(ignore,c) end
 end
 local team=Scope:IsCTF() and player:GetAttribute("InArena") and player.Team
 for _,other in Players:GetPlayers() do if other~=player then ignoreCharacter(other.Character,team and other.Team==team and other:GetAttribute("InArena")) end end
 local bots=workspace:FindFirstChild("CTFBots")
 if bots then for _,bot in bots:GetChildren() do ignoreCharacter(bot,team and bot:GetAttribute("CTFTeam")==team.Name) end end
 params.FilterDescendantsInstances=ignore
 local origin,direction=ray.Origin,ray.Direction
 if aimFrame and owned then
  origin=aimFrame:PointToWorldSpace(camera.CFrame:PointToObjectSpace(origin))
  direction=aimFrame:VectorToWorldSpace(camera.CFrame:VectorToObjectSpace(direction))
 end
 local result=Query.Trace({origin=origin,direction=direction,range=range or 850,shooter=player.Character,ignore=ignore,classify=clientRelation})
 lastAimHit=result.result lastAimOrigin=origin
 return result.endpoint,origin,direction,result.result
end
function Presentation:PointerOverButton()
 local p=UIS:GetMouseLocation()
 for _,object in player.PlayerGui:GetGuiObjectsAtPosition(p.X,p.Y) do
  if object:IsA("GuiButton") and object.Visible then return true end
 end
 return false
end
function Presentation:GetShotOrigin()
 if not firstPerson or not owned or self:IsBlocked() then return end
 return renderer and renderer:ShotOrigin(workspace.CurrentCamera)
end
clientRelation=function(model)
 local h=model:FindFirstChildOfClass("Humanoid")
 if h and h.Health<=0 then return "ignore" end
 if Scope:IsCTF() and player:GetAttribute("InArena") and player.Team then
  local other=Players:GetPlayerFromCharacter(model)
  if other and other.Team==player.Team and other:GetAttribute("InArena") or model:GetAttribute("CTFTeam")==player.Team.Name then return "ignore" end
 end
 return h and "target" or "block"
end
function Presentation:ClearShots()
 for _,entry in predicted do for _,effect in entry.effects do Effects.CancelTrace(effect) end end
 table.clear(predicted)
end
function Presentation:ConfirmShot(message)
 local entry=predicted[message.shotId]
 if not entry then return end
 if not message.accepted then
  if entry.tool and entry.tool:GetAttribute("WeaponId")=="ax_50" then entry.tool:SetAttribute("AX50RejectedShotStamp",entry.stamp) end
  for _,effect in entry.effects do Effects.CancelTrace(effect) end
  predicted[message.shotId]=nil
 elseif Shot.Finite(message.endpoint) then
  player:SetAttribute("AuthoritativeShotEndpoint",message.endpoint)
 end
end
function Presentation:RenderShot(message)
 if not Scope:IsCombat() or typeof(message)~="table" or not Shot.Finite(message.endpoint) or not Shot.Finite(message.origin) then return end
 if message.visual and message.visual.SourcePack=="ProjectileTest" and message.phase~="launch" and message.reason~="range" then require(game.ReplicatedStorage.Crossgrounds.BlasterEffects).Impact(message.endpoint,message.normal,message.reason=="targets") end
 local own=message.actor==player.Character
 local entry=own and predicted[message.shotId]
 if entry then
  if message.phase~="launch" then
   local index=(entry.confirmed or 0)+1 entry.confirmed=index
   local effect=entry.effects[index]
   Effects.CorrectTrace(effect,message.endpoint)
   player:SetAttribute("AuthoritativeShotEndpoint",message.endpoint)
   if index>=entry.pellets then predicted[message.shotId]=nil end
  end
  return
 end
 local tool=message.tool
 -- A late packet after switching/death must never kick or flash the new weapon.
 if own then return end
 if message.phase=="impact" and message.shotType=="projectile" then
  Effects.FinishProjectile(message.actor,message.shotId,message.endpoint) return
 end
 local already=message.actor and message.shotId and remoteShots[message.actor]==message.shotId
 if tool and tool.Parent and not already then tool:SetAttribute("PresentationShotAt",workspace:GetServerTimeNow()) Effects.Play(tool) Effects.PlaySound(tool) end
 if message.actor and message.shotId then remoteShots[message.actor]=message.shotId end
 if message.phase=="launch" then
  Effects.Projectile(message.actor,message.shotId,message.origin,message.direction,message)
 else Effects.Trace(message.origin,message.endpoint,message.color,message.visual) end
end
function Presentation:PredictShot(shotId,tool,target,request)
 if not tool or not tool.Parent then return end
 for id,entry in predicted do if os.clock()>entry.expires then for _,effect in entry.effects do Effects.CancelTrace(effect) end predicted[id]=nil end end
 local data = Stats.ResolveTool(tool)
 local config = Shot.Config(data)
 local classify=clientRelation
 local origin,blocked=Query.ResolveOrigin(player.Character,tool,target,self:GetShotOrigin(),classify)
 if not origin or (target-origin).Magnitude<.05 then return end
 local entry={at=os.clock(),expires=os.clock()+(config.kind=="projectile" and config.lifetime+1 or 3),effects={},pellets=config.pellets} predicted[shotId]=entry
 self:Kick(tool:GetAttribute("WeaponId"))
 entry.tool=tool entry.stamp=tool:GetAttribute("PresentationShotAt")
 Effects.PlaySound(tool) if not firstPerson then Effects.Play(tool) end
 for pellet=1,config.pellets do
  local direction=Shot.Direction(target-origin,AttachmentEffects.Spread(data,tool),tool:GetAttribute("ShotSeed"),shotId,pellet,config.pellets)
  local endpoint
  if blocked then endpoint=blocked.Position
  elseif config.kind=="projectile" then
   local effect=Effects.Projectile(player.Character,shotId,origin,direction,{speed=config.speed,acceleration=config.acceleration,lifetime=config.lifetime,range=config.range,visual=config.visual,
    shooter=player.Character,classify=classify,radius=config.radius,maxTargets=data.MaxTargets,penetrationLoss=data.PenetrationLoss})
   table.insert(entry.effects,effect) endpoint=origin+direction*config.range
  else
   endpoint=Query.Trace({origin=origin,direction=direction,range=config.range,shooter=player.Character,ignore=viewmodel and {viewmodel} or {},classify=classify,radius=config.radius,maxTargets=data.MaxTargets,penetrationLoss=data.PenetrationLoss}).endpoint
  end
  if blocked or config.kind~="projectile" then table.insert(entry.effects,Effects.Trace(origin,endpoint,nil,config.visual)) end
  player:SetAttribute("LastTraceOrigin",origin) player:SetAttribute("LastTraceEndpoint",endpoint)
 end
 player:SetAttribute("LastPredictedShotId",shotId) player:SetAttribute("LastPredictedShotAt",os.clock())
end
local function restoreVisibility()
 for part,value in pairs(hidden) do if part.Parent then part.LocalTransparencyModifier=0 end hidden[part]=nil end
end
local function hideCharacter(character,hide)
 if not hide then restoreVisibility() for _,p in character:GetDescendants() do if p:IsA("BasePart") then p.LocalTransparencyModifier=0 end end return end
 for _,p in character:GetDescendants() do
  if p:IsA("BasePart") then if hidden[p]==nil then hidden[p]=p.LocalTransparencyModifier end p.LocalTransparencyModifier=1 end
 end
end
local function removeViewmodel()
 if renderer then renderer:Destroy() renderer=nil end viewmodel=nil
 sourceRecoil=Vector2.zero sourceFovKick=0
 spring:Reset() cameraSpring:Reset() carry:Reset() recoil=0 recoilPitch=0 roll=0
end
local function buildViewmodel(tool)
 removeViewmodel()
 renderer=Renderer.new(tool) viewmodel=renderer and renderer.Model
end
function Presentation:Kick(id)
 local _,_,tool,data=current() if not tool or tool:GetAttribute("WeaponId")~=id then return end
 if data.Kind=="Gun" then
  firedAt=os.clock()
  tool:SetAttribute("PresentationShotAt",workspace:GetServerTimeNow())
  if firstPerson and renderer then renderer:Flash() end
  local profile=AttachmentEffects.Recoil(data,tool)
  local side=math.random()<.5 and -1 or 1
  if data.RecoverableRecoil then
   local base=Kits.Weapons[id].VisualRecoil
   cameraRecoilProfile={Push=0,Pitch=(profile.CameraRise or 0)*(profile.Pitch/math.max(.01,base.Pitch)),Roll=(profile.CameraSide or 0)*(profile.Roll/math.max(.01,base.Roll)),Spring=profile.Spring,Damping=profile.Damping,ReturnDelay=profile.ReturnDelay,Sustain=profile.Sustain}
   cameraSpring:Kick(cameraRecoilProfile,side)
  end
  local low = data.CameraRecoilMin
  local high = data.CameraRecoilMax
	if not data.RecoverableRecoil and typeof(low) == "Vector2" and typeof(high) == "Vector2" then
		local horizontal = low.X + math.random() * (high.X - low.X)
		local vertical = low.Y + math.random() * (high.Y - low.Y)

		sourceRecoil += Vector2.new(
			math.rad(-horizontal),
			math.rad(vertical)
		)

		sourceFovKick = 1
	end
  spring:Kick(profile,side)
 else swingAt=os.clock() end
end
local function acquire()
 local camera=workspace.CurrentCamera
 saved={cameraType=camera.CameraType,fov=camera.FieldOfView,mouse=UIS.MouseBehavior,icon=UIS.MouseIconEnabled}
 local direction=camera.CFrame.LookVector
 yaw=math.atan2(-direction.X,-direction.Z)
 pitch=math.asin(math.clamp(direction.Y,-.98,.98))
 if not initialized then locked=setting("ShiftLock") firstPerson=setting("FirstPerson") shoulder=setting("Shoulder") initialized=true end
 local _,_,_,data=current()
 locked,firstPerson=CameraPolicy.Resolve(Scope:Get(),data and data.Kind,setting("ShiftLock"),setting("FirstPerson"))
 if practiceFirstPerson~=nil then firstPerson=practiceFirstPerson end
 freePoint=camera.ViewportSize*.5
 owned=true camera.CameraType=Enum.CameraType.Scriptable cursorMode()
end
local function release()
 if not owned then return end
 Presentation:ClearShots()
 owned=false firing=false aiming=false aimFrame=nil previousYaw=nil assistFriction=1 Assist:Reset() motion:Reset() carry:Reset() player:SetAttribute("WeaponRunWeight",0) player:SetAttribute("CombatFiring",false) player:SetAttribute("CameraMotionPitch",0) player:SetAttribute("CameraMotionOffset",Vector3.zero) player:SetAttribute("CameraMotionRoll",0) restoreVisibility() removeViewmodel()
 local camera=workspace.CurrentCamera camera.CameraType=Enum.CameraType.Custom
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if h then h.AutoRotate=true camera.CameraSubject=h end
 camera.FieldOfView=setting("FieldOfView")
 UIS.MouseBehavior=saved.mouse or Enum.MouseBehavior.Default UIS.MouseIconEnabled=saved.icon~=false
 cursorMode()
 player:SetAttribute("CombatCameraActive",false) player:SetAttribute("CombatAiming",false) player:SetAttribute("VisualWeaponRecoil",0) player:SetAttribute("VisualWeaponPitch",0) player:SetAttribute("FirstPerson",false)
end
player:GetAttributeChangedSignal("CTFPracticeRange"):Connect(function()
 practiceFirstPerson=player:GetAttribute("CTFPracticeRange")==true and true or nil
 if owned then release() end
end)
local function turn(dx,dy)
 local ads=aiming and setting("AimSensitivity") or 1
 local delta=Vector2.new(dx,dy)
 if InputMode:Get()==Enum.PreferredInput.Touch then
  delta=Analog.TouchRadians(delta,workspace.CurrentCamera.ViewportSize.X,setting("LookSensitivity"),ads)
  local now=os.clock() local sampleDt=math.clamp(now-touchSampleAt,.008,.05) touchSampleAt=now
  touchIntent=Vector2.new(-delta.X,-delta.Y)/(sampleDt*2.4)
  if touchIntent.Magnitude>1 then touchIntent=touchIntent.Unit end
  delta*=assistFriction
 else delta*=.0026*setting("LookSensitivity")*ads end
 yaw-=delta.X pitch=math.clamp(pitch-delta.Y,math.rad(-72),math.rad(72))
end

local function clearLook()
 stick=Vector2.zero touchDelta=Vector2.zero touchIntent=Vector2.zero
 touchLook=nil touchPosition=nil lastTouchLook=0 touchSampleAt=0
 table.clear(stickGate) assistFriction=1 Assist:Reset()
end
UIS.InputChanged:Connect(function(input,processed)
 if input.KeyCode==Enum.KeyCode.Thumbstick2 then return end
 if not owned or Presentation:IsBlocked() then return end
 if input.UserInputType==Enum.UserInputType.MouseMovement and (locked or aiming) then turn(input.Delta.X,input.Delta.Y)
 elseif input.UserInputType==Enum.UserInputType.Touch and touchLook==input then
  local position=Vector2.new(input.Position.X,input.Position.Y)
  local delta=touchPosition and position-touchPosition or Vector2.zero touchPosition=position
  touchDelta+=delta touchSampleAt=os.clock()
 end
end)
UIS.TouchStarted:Connect(function(input,processed)
 if not owned or Presentation:IsBlocked() or touchLook then return end
 local overFire=false
 for _,object in player.PlayerGui:GetGuiObjectsAtPosition(input.Position.X,input.Position.Y) do
  if object:GetAttribute("TouchLookSurface") then overFire=true break end
 end
 if processed and not overFire then return end
 if input.Position.X>workspace.CurrentCamera.ViewportSize.X*.4 then touchLook=input touchPosition=Vector2.new(input.Position.X,input.Position.Y) touchDelta=Vector2.zero touchIntent=Vector2.zero touchSampleAt=os.clock() end
end)
UIS.TouchEnded:Connect(function(input) if touchLook==input then clearLook() end end)
UIS.TouchTapInWorld:Connect(function(point,processed) if not processed and not locked then freePoint=point end end)
UIS.GamepadDisconnected:Connect(clearLook)
UIS.WindowFocusReleased:Connect(function() windowFocused=false clearLook() aiming=false firing=false end)
UIS.WindowFocused:Connect(function() windowFocused=true clearLook() end)
GuiService.MenuOpened:Connect(function() clearLook() aiming=false firing=false end)
InputMode.Changed:Connect(function() clearLook() if owned then cursorMode() end end)
player.CharacterRemoving:Connect(clearLook)
for _,key in {"ShiftLock","FirstPerson","Shoulder"} do
 player:GetAttributeChangedSignal("Setting"..key):Connect(function()
  if key=="ShiftLock" then locked=setting(key) cursorMode()
  elseif key=="FirstPerson" then firstPerson=setting(key)
  else shoulder=setting(key) end
 end)
end
local function bind(name,callback)
 Router:Register(name,function(state)
  if Presentation:IsBlocked() or not current() then return Enum.ContextActionResult.Pass end
  if state==Enum.UserInputState.Begin then callback() end return Enum.ContextActionResult.Sink
 end)
end
bind("ShiftLock",function() Presentation:ToggleLock() end)
bind("Shoulder",function() Presentation:ToggleShoulder() end)
bind("Perspective",function() Presentation:TogglePerspective() end)
local function canZoom()
 local _,_,t=current()
 local profile=t and SightDefinitions.Get(t:GetAttribute("WeaponId"),t:GetAttribute("OpticalAttachmentId"))
 return aiming and not Presentation:IsBlocked() and profile~=nil and #profile.levels>1
end
local function toggleZoom() if canZoom() then zoomLevel=zoomLevel==1 and 2 or 1 end end
for action,level in {ScopeZoomIn=2,ScopeZoomOut=1} do
 Router:Register(action,function(state)
  if not canZoom() then return Enum.ContextActionResult.Pass end
  if state==Enum.UserInputState.Begin then zoomLevel=level end
  return Enum.ContextActionResult.Sink
 end,{scope="combat",enabled=canZoom,overridePriority=true})
end
zoomButton.Activated:Connect(toggleZoom)
RunService:BindToRenderStep("CTFCombatPresentation",Enum.RenderPriority.Camera.Value+1,function(deltaTime)
 local character,humanoid,tool,data=current()
 local blocked=Presentation:IsBlocked()
 opticalSight:Update(nil)
 zoomButton.Visible=false
 if not aiming or blocked or not character or tool~=currentTool then zoomLevel=1 end
 locked,firstPerson=CameraPolicy.Resolve(Scope:Get(),data and data.Kind,setting("ShiftLock"),setting("FirstPerson"))
 if not character then
  if owned then clearLook() end
  release() currentTool=nil
  local camera=workspace.CurrentCamera local target=setting("FieldOfView")
  camera.FieldOfView+=(target-camera.FieldOfView)*MotionPreferences.FOVAlpha(deltaTime,setting("FOVTransitionSpeed"),10)
  return
 end
 locked,firstPerson=CameraPolicy.Resolve(Scope:Get(),data.Kind,setting("ShiftLock"),setting("FirstPerson"))
 if practiceFirstPerson~=nil then firstPerson=practiceFirstPerson end
 local sightProfile=(aiming or adsWeight>.001) and SightDefinitions.Get(tool:GetAttribute("WeaponId"),tool:GetAttribute("OpticalAttachmentId")) or nil
 if sightProfile then firstPerson=true end
 if tool~=currentTool then
  clearLook()
  currentTool=tool equippedAt=os.clock() firedAt=-100 adsWeight=0 locomotion=Locomotion.new() removeViewmodel()
  if owned then buildViewmodel(tool) end
 end
 if blocked or not windowFocused then
  clearLook()
  motion:Reset() carry:Reset() previousYaw=nil assistFriction=1 Assist:Reset() player:SetAttribute("WeaponRunWeight",0) player:SetAttribute("CombatFiring",false) player:SetAttribute("CameraMotionPitch",0) player:SetAttribute("CameraMotionOffset",Vector3.zero) player:SetAttribute("CameraMotionRoll",0) if aimFrame then workspace.CurrentCamera.CFrame=aimFrame end
  firing=false aiming=false
  UIS.MouseBehavior=Enum.MouseBehavior.Default UIS.MouseIconEnabled=GuiService.MenuIsOpen or InputMode:Get()~=Enum.PreferredInput.Gamepad
  if renderer then renderer:SetVisible(false) end
  hideCharacter(character,firstPerson) return
 end
 if not owned then acquire() buildViewmodel(tool) end
 local dt=math.min(deltaTime,.04)
 local camera=workspace.CurrentCamera local root=character.HumanoidRootPart
 local input=InputMode:Get()

 -- Poll the selected physical controller. No synthesized direction can latch a turn.
 stick=Vector2.zero
 if input==Enum.PreferredInput.Gamepad then
  local ok,inputs=pcall(function() return UIS:GetGamepadState(InputMode.ActiveGamepad) end)
  if ok then for _,v in inputs do if v.KeyCode==Enum.KeyCode.Thumbstick2 then stick=Vector2.new(v.Position.X,v.Position.Y) break end end end
 end
 local clean=Analog.Stick(stickGate,stick,setting("RightStickDeadzone"))
 local movement=setting("StickCurve")==1 and Analog.Dynamic(clean,setting("StickCurveStrength")) or clean
 local pixels=os.clock()-touchSampleAt<=Intent.TouchTimeout and touchDelta or Vector2.zero touchDelta=Vector2.zero
 local touchRadians=input==Enum.PreferredInput.Touch and touchLook and Analog.TouchRadians(pixels,camera.ViewportSize.X,setting("LookSensitivity"),aiming and setting("AimSensitivity") or 1) or Vector2.zero
 touchIntent=Intent.TouchLook(touchIntent,touchRadians,deltaTime,touchLook~=nil,os.clock()-touchSampleAt)
 if touchIntent.Magnitude>1 then touchIntent=touchIntent.Unit end
 local assisted local tracking=Vector2.zero
 assistFriction=1
 local lookIntent=Intent.Resolve({device=input==Enum.PreferredInput.Gamepad and "gamepad" or input==Enum.PreferredInput.Touch and "touch" or "mouse",focused=windowFocused,blocked=blocked,look=input==Enum.PreferredInput.Gamepad and Vector2.new(-movement.X,movement.Y) or touchIntent,touchOwned=touchLook~=nil,touchAt=touchSampleAt,now=os.clock()})
 assisted,assistFriction,tracking=Assist:Target(aimFrame or camera.CFrame,Presentation:GetAimViewport(),camera,data.Range,setting("AimAssist"),setting("AimAssistStrength"),data.Kind=="Gun",viewmodel,aiming,{
  dt=deltaTime,look=lookIntent,strafe=humanoid.MoveDirection:Dot((aimFrame or camera.CFrame).RightVector),
  slowdown=setting("AimAssistSlowdown"),tracking=setting("AimAssistTracking"),
  centering=setting("AimAssistCentering"),aiming=aiming,
 })
 if input==Enum.PreferredInput.Gamepad then
  local speed=2.4*setting("LookSensitivity")*(aiming and setting("AimSensitivity") or 1)*assistFriction
  if not locked then
    freePoint=(freePoint or camera.ViewportSize*.5)+Vector2.new(movement.X,-movement.Y)*dt*camera.ViewportSize.Y*.9*setting("LookSensitivity")*(aiming and setting("AimSensitivity") or 1)*assistFriction
    freePoint=Vector2.new(math.clamp(freePoint.X,8,camera.ViewportSize.X-8),math.clamp(freePoint.Y,8,camera.ViewportSize.Y-8))
   local edge=(Presentation:GetAimViewport()-camera.ViewportSize*.5)/camera.ViewportSize.Y
   if math.abs(edge.X)>.35 then yaw-=edge.X*speed*dt end
   if math.abs(edge.Y)>.35 then pitch=math.clamp(pitch-edge.Y*speed*dt,-1.25,1.25) end
  else
   yaw-=movement.X*speed*dt pitch=math.clamp(pitch+movement.Y*speed*dt,-1.25,1.25)
  end
 end

 if input==Enum.PreferredInput.Touch then
  yaw-=touchRadians.X*assistFriction pitch=math.clamp(pitch-touchRadians.Y*assistFriction,-1.25,1.25)
 end
 if assisted then
  if locked or firstPerson then yaw+=tracking.X pitch=math.clamp(pitch+tracking.Y,-1.25,1.25)
  else
   local scale=camera.ViewportSize.Y/(2*math.tan(math.rad(camera.FieldOfView*.5)))
   freePoint=(freePoint or camera.ViewportSize*.5)+Vector2.new(-tracking.X,-tracking.Y)*scale
   freePoint=Vector2.new(math.clamp(freePoint.X,8,camera.ViewportSize.X-8),math.clamp(freePoint.Y,8,camera.ViewportSize.Y-8))
  end
 end
 player:SetAttribute("FilteredRightStick",movement)
 UIS.MouseBehavior=locked and input==Enum.PreferredInput.KeyboardAndMouse and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
 UIS.MouseIconEnabled=not locked and input~=Enum.PreferredInput.Gamepad
 local untilTime=math.max(character:GetAttribute("SpawnProtectedUntil") or 0,character:GetAttribute("ArenaProtectedUntil") or 0)
 if untilTime>workspace:GetServerTimeNow() and (player:GetAttribute("InArena") or player:GetAttribute("ArenaPlaying")) then
  if protectionToken~=untilTime then protectionToken=untilTime protectionYaw=yaw protectionPitch=pitch
  elseif math.abs(math.atan2(math.sin(yaw-protectionYaw),math.cos(yaw-protectionYaw)))>.025 or math.abs(pitch-protectionPitch)>.025 then
   protectionRemote:FireServer(character) protectionToken=nil
  end
 else protectionToken=nil end
 yaw+=sourceRecoil.X*dt pitch=math.clamp(pitch+sourceRecoil.Y*dt,-1.25,1.25)
 sourceRecoil=sourceRecoil:Lerp(Vector2.zero,math.min(dt*10,1))
 local _,cameraPitch,cameraYaw=cameraSpring:Update(deltaTime,cameraRecoilProfile)
 local cameraWeight=data.RecoverableRecoil and MotionPreferences.WeaponWeight(player) or 0
 local rotation=CFrame.fromEulerAnglesYXZ(pitch+math.rad(cameraPitch)*cameraWeight,yaw+math.rad(cameraYaw)*cameraWeight,0)

 local localMove=rotation:VectorToObjectSpace(root.AssemblyLinearVelocity)
 local loco=locomotion:Update(dt,localMove,humanoid.FloorMaterial~=Enum.Material.Air,player:GetAttribute("SlideActive")==true)
 player:SetAttribute("CombatMovementState",loco.state)
 local adsSpeed=math.clamp(data.AdsSpeedMultiplier or 1,.1,2)
 if tool:GetAttribute("WeaponId")=="ax_50" then adsSpeed*=.65 end
 adsWeight+=((aiming and 1 or 0)-adsWeight)*(1-math.exp(-dt*18*adsSpeed))
 local focus=root.Position+Vector3.new(0,1.6+loco.cameraY,0)
 local cameraPosition
 if firstPerson then
  cameraPosition=focus+Vector3.new(0,.12,0)
 else
  local desired=focus+rotation:VectorToWorldSpace(Vector3.new(shoulder*2.65,.85,aiming and 5.5 or 8.2))
  local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={character,viewmodel}
  local hit=workspace:Raycast(focus,desired-focus,params)
  cameraPosition=hit and hit.Position+hit.Normal*.4 or desired
 end

 aimFrame=CFrame.new(cameraPosition)*rotation
 character:SetAttribute("CombatAimPitch",pitch)
 if os.clock()-lastPoseAt>=.10 and (math.abs(pitch-sentPitch)>.012 or aiming~=sentAiming or os.clock()-lastPoseAt>1) then
  poseRemote:FireServer(pitch,aiming) lastPoseAt=os.clock() sentPitch=pitch sentAiming=aiming
 end
 local localVelocity=rotation:VectorToObjectSpace(root.AssemblyLinearVelocity)
 local turnRate=previousYaw and math.clamp((yaw-previousYaw)/math.max(dt,.001),-4,4) or 0 previousYaw=yaw
 local cameraAmount=setting("CameraMotion")*(setting("SimpleAnimations") and .15 or 1)
 local bob,lean,nod=motion:Update(dt,localVelocity,humanoid.FloorMaterial~=Enum.Material.Air,player:GetAttribute("SprintActive")==true,aiming,cameraAmount,turnRate,data.AdsMotionMultiplier)
 local runPose,runWeight,runPhase=carry:Update(dt,localVelocity,humanoid.FloorMaterial~=Enum.Material.Air,player:GetAttribute("SprintActive")==true,aiming,firing or tool:GetAttribute("Reloading") or tool:GetAttribute("Attacking"),setting("CameraMotion"))
 player:SetAttribute("WeaponRunWeight",runWeight) player:SetAttribute("CameraMotionPitch",nod)
 camera.CameraType=Enum.CameraType.Scriptable camera.CFrame=aimFrame*CFrame.new(bob)*CFrame.Angles(nod,0,lean) camera.Focus=CFrame.new(focus)
 player:SetAttribute("CameraMotionOffset",bob) player:SetAttribute("CameraMotionRoll",lean)
 local baseFov=setting("FieldOfView")
 local sprinting=player:GetAttribute("SprintActive")==true and humanoid.MoveDirection.Magnitude>.1
 local weaponId=tool:GetAttribute("WeaponId")
 local scoped=sightProfile~=nil
 -- Optical overlay is updated after the physical weapon pose below.
 zoomButton.Visible=scoped and #sightProfile.levels>1
 if scoped then
  local device=InputMode:Get()==Enum.PreferredInput.Gamepad and "Gamepad" or "Keyboard"
  zoomButton.Text=(zoomLevel==1 and "4×" or "8×")
  local viewport=camera.ViewportSize
  zoomButton.Position=UDim2.fromOffset(viewport.X*.5-math.min(viewport.X,viewport.Y)*.37-12,viewport.Y*.5)
  local axKeyboard=weaponId=='ax_50' and device=='Keyboard'
  for i,refresh in zoomGlyphs do refresh() zoomGlyphLabels[i].Visible=not axKeyboard end
  if axKeyboard then zoomButton.Text=(zoomLevel==1 and '4×' or '8×')..'  [+ / −]' end
 end
 player:SetAttribute("SniperZoomLevel",scoped and zoomLevel or 0)
 local fov=aiming and (sightProfile and SightDefinitions.FOV(baseFov,sightProfile,zoomLevel) or SniperZoom.FOV(baseFov,weaponId,zoomLevel)) or baseFov+(sprinting and 6 or 0)
 sourceFovKick*=math.exp(-deltaTime*20) fov+=sourceFovKick
 local fovSpeed=setting("FOVTransitionSpeed")*((aiming or adsWeight>.001) and adsSpeed or 1)
 camera.FieldOfView+=(fov-camera.FieldOfView)*MotionPreferences.FOVAlpha(dt,fovSpeed,12)
 local point=Presentation:GetAimViewport() player:SetAttribute("AimScreenPosition",point)
 local target=Presentation:GetAimWorld(math.max(850,data.Range+50))
 if locked or firstPerson or aiming or firing then
  local flat=Vector3.new(target.X,root.Position.Y,target.Z)-root.Position
  if flat.Magnitude>.1 then humanoid.AutoRotate=false root.CFrame=CFrame.lookAt(root.Position,root.Position+flat) end
 else humanoid.AutoRotate=true end
 hideCharacter(character,firstPerson)
 local recoilProfile=AttachmentEffects.Recoil(data,tool)
 recoil,recoilPitch,roll=spring:Update(deltaTime,recoilProfile)
 if firstPerson and renderer then

  local arc=data.Kind~="Gun" and ActionMotion.Melee(os.clock()-swingAt,data) or 0
  local action=ActionMotion.Sample({equippedFor=os.clock()-equippedAt,ads=adsWeight,slide=loco.slide,land=loco.land,vertical=localMove.Y,firedAgo=os.clock()-firedAt})
  local adsMotion=1+(math.clamp(data.AdsMotionMultiplier or 1,0,2)-1)*adsWeight
  action.weapon=CFrame.identity:Lerp(loco.weapon,adsMotion)*action.weapon
  renderer:Render(deltaTime,camera,character,{runPose=runPose,runWeight=runWeight,runPhase=runPhase,recoil=recoil,pitch=recoilPitch,roll=roll,arc=arc,action=action,ads=adsWeight,adsMotionMultiplier=data.AdsMotionMultiplier,sight=sightProfile,sightActive=aiming,firedAgo=os.clock()-firedAt,cooldown=data.Cooldown,recoilStrength=data.VisualRecoil and Kits.Weapons[weaponId].VisualRecoil and data.VisualRecoil.Push/math.max(.01,Kits.Weapons[weaponId].VisualRecoil.Push) or 1})
 elseif renderer then renderer:SetVisible(false) end
 opticalSight:Update(sightProfile,camera.ViewportSize,Presentation:GetAimViewport(),adsWeight,firstPerson and renderer and renderer.opticalAperture or nil,aiming)

 player:SetAttribute("CombatCameraActive",true) player:SetAttribute("CameraLocked",locked) player:SetAttribute("FirstPerson",firstPerson) player:SetAttribute("CameraShoulder",shoulder) player:SetAttribute("CombatAiming",aiming) player:SetAttribute("UsingXboxCursor",false)
 player:SetAttribute("VisualWeaponRecoil",recoil) player:SetAttribute("VisualWeaponPitch",recoilPitch)

end)
return Presentation
