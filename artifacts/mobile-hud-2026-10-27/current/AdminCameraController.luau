local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local StarterGui=game:GetService("StarterGui")
local GuiService=game:GetService("GuiService")
local player=Players.LocalPlayer
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local Icons=require(script.Parent:WaitForChild("InputIcons"))
local held={}
local spectatorSubject
local focusLost=false
local function adminKey(action)
 local device=UIS:GetLastInputType().Name:match("^Gamepad") and "Gamepad" or "Keyboard"
 return Icons:Name(Router:Key(action or "AdminMode",device))
end
local remote=game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("Remotes"):WaitForChild("AdminCamera",30)
if not remote then return end
local active=false local clean=false local pending=false local speed=64
local catalog={} local photoIndex=0
local position,yaw,pitch local saved local controls local savedGui={} local savedCore={}
local gui=Instance.new("ScreenGui") gui.Name="AdminCameraHelp" gui.ResetOnSpawn=false gui.DisplayOrder=1000 gui.Enabled=false gui.Parent=player:WaitForChild("PlayerGui")
local help=Instance.new("TextLabel") help.AnchorPoint=Vector2.new(.5,1) help.Position=UDim2.new(.5,0,1,-16)
help.Size=UDim2.fromOffset(840,78) help.BackgroundColor3=Color3.fromRGB(18,27,37) help.BackgroundTransparency=.15
help.TextColor3=Color3.fromRGB(235,245,250) help.TextSize=14 help.TextWrapped=true help.Font=Enum.Font.GothamMedium help.Parent=gui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,8) corner.Parent=help
local function hint(message)
 gui.Enabled=player:GetAttribute("CrossgroundsAdmin")==true and not clean
 help.Text=message or (active and ("ADMIN · ESPECTADOR · TEMPO ILIMITADO · "..math.floor(speed).." studs/s\nMovimento e câmera normais · voe na direção em que olha · pular sobe · Shift / B desce\n"..
 adminKey("AdminSpeedDown").."/"..adminKey("AdminSpeedUp").." velocidade · "..adminKey("AdminPreviousMap").."/"..adminKey("AdminNextMap").." mapa · "..adminKey("AdminClean").." captura limpa · "..adminKey().." sair") or "ADMIN · "..adminKey().." espectador · sai da partida antes de ativar")

end
local function hideGui(obj)
 if not clean or savedGui[obj] then return end
 if obj:IsA("ScreenGui") then
  local record={value=obj.Enabled} savedGui[obj]=record
  record.connection=obj:GetPropertyChangedSignal("Enabled"):Connect(function()
   if clean and obj.Enabled then record.value=true obj.Enabled=false end
  end)
  obj.Enabled=false
 elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
  local record={value=obj.Enabled} savedGui[obj]=record
  record.connection=obj:GetPropertyChangedSignal("Enabled"):Connect(function()
   if clean and obj.Enabled then record.value=true obj.Enabled=false end
  end)
  obj.Enabled=false
 end
end
local function setClean(value)
 clean=value
 player:SetAttribute("AdminCaptureClean",clean)
 if clean then
  for _,obj in player.PlayerGui:GetDescendants() do hideGui(obj) end
  for _,obj in workspace:GetDescendants() do hideGui(obj) end
  for _,kind in Enum.CoreGuiType:GetEnumItems() do if kind~=Enum.CoreGuiType.All then
   local ok,enabled=pcall(function()return StarterGui:GetCoreGuiEnabled(kind)end)
   if ok then savedCore[kind]=enabled pcall(function()StarterGui:SetCoreGuiEnabled(kind,false)end) end
  end end
 else
  for obj,record in savedGui do record.connection:Disconnect() if obj.Parent then obj.Enabled=record.value end end
  table.clear(savedGui)
  for kind,enabled in savedCore do pcall(function()StarterGui:SetCoreGuiEnabled(kind,enabled)end) end table.clear(savedCore)
 end
 hint()
end
player.PlayerGui.DescendantAdded:Connect(hideGui)
workspace.DescendantAdded:Connect(hideGui)
local function stop()
 if not active then return end active=false table.clear(held)
 setClean(false)
 Run:UnbindFromRenderStep("AdminFreeCamera") CAS:UnbindAction("AdminCameraMovement")
 if spectatorSubject then spectatorSubject:Destroy() spectatorSubject=nil end
 if controls then if Router:CanMove() then controls:Enable() else controls:Disable() end end
 local camera=workspace.CurrentCamera
 if saved then
  player.CameraMode=saved.cameraMode player.CameraMaxZoomDistance=saved.maxZoom player.CameraMinZoomDistance=saved.minZoom
  camera.CameraType=saved.cameraType camera.FieldOfView=saved.fov
  if saved.subject and saved.subject.Parent then camera.CameraSubject=saved.subject end
  camera.CFrame=saved.cf camera.Focus=saved.focus
  UIS.MouseBehavior=saved.mouse UIS.MouseIconEnabled=saved.icon
 end
 hint()
end
local function start()
 if active or player:GetAttribute("CrossgroundsAdmin")~=true then return end
 local camera=workspace.CurrentCamera
 saved={cameraMode=player.CameraMode,minZoom=player.CameraMinZoomDistance,maxZoom=player.CameraMaxZoomDistance,cameraType=camera.CameraType,subject=camera.CameraSubject,cf=camera.CFrame,focus=camera.Focus,fov=camera.FieldOfView,mouse=UIS.MouseBehavior,icon=UIS.MouseIconEnabled}
 position=camera.CFrame.Position
 local look=camera.CFrame.LookVector pitch=math.asin(math.clamp(look.Y,-1,1)) yaw=math.atan2(-look.X,-look.Z)
 local module=player.PlayerScripts:FindFirstChild("PlayerModule") if module then controls=require(module):GetControls() controls:Enable() end
 spectatorSubject=Instance.new("Part")
 spectatorSubject.Name="AdminSpectatorCamera" spectatorSubject.Size=Vector3.one spectatorSubject.Transparency=1
 spectatorSubject.Anchored=true spectatorSubject.CanCollide=false spectatorSubject.CanTouch=false spectatorSubject.CanQuery=false spectatorSubject.CastShadow=false
 spectatorSubject.CFrame=CFrame.new(position) spectatorSubject.Parent=workspace
 player.CameraMinZoomDistance=.5 player.CameraMaxZoomDistance=.5 player.CameraMode=Enum.CameraMode.LockFirstPerson
 camera.CameraType=Enum.CameraType.Custom camera.CameraSubject=spectatorSubject
 active=true
 Run:BindToRenderStep("AdminFreeCamera",Enum.RenderPriority.Camera.Value-1,function(dt)
  camera=workspace.CurrentCamera
  local blocked=focusLost or not Router:CanMove()
  if not spectatorSubject then return end
  camera.CameraType=Enum.CameraType.Custom camera.CameraSubject=spectatorSubject
  if not blocked and controls then
   local move=controls:GetMoveVector()
   local controller=controls.activeController
   local jumping=controller and controller.GetIsJumping and controller:GetIsJumping()
   local down=UIS:IsKeyDown(Enum.KeyCode.LeftShift)
   for _,input in UIS:GetGamepadState(Enum.UserInputType.Gamepad1) do
    if input.KeyCode==Enum.KeyCode.ButtonB and input.UserInputState~=Enum.UserInputState.End then down=true end
   end
   local vertical=(jumping and 1 or 0)-(down and 1 or 0)
   local direction=camera.CFrame.RightVector*move.X-camera.CFrame.LookVector*move.Z+Vector3.yAxis*vertical
   if direction.Magnitude>1 then direction=direction.Unit end
   position+=direction*speed*math.min(dt,.1)
  end
  spectatorSubject.CFrame=CFrame.new(position)
 end)

 hint()
 task.spawn(function()
  local ok,allowed,list=pcall(function()return remote:InvokeServer("catalog")end)
  if ok and allowed and type(list)=="table" then catalog=list photoIndex=0 end
 end)
end
local function sync()
 if player:GetAttribute("AdminFreecam")==true and player:GetAttribute("CrossgroundsAdmin")==true then start() else stop() hint() end
end
player:GetAttributeChangedSignal("AdminFreecam"):Connect(sync)
player:GetAttributeChangedSignal("CrossgroundsAdmin"):Connect(sync)
Router:Register("AdminMode",function(state)
 if state~=Enum.UserInputState.Begin or player:GetAttribute("CrossgroundsAdmin")~=true or pending or UIS:GetFocusedTextBox() or GuiService.MenuIsOpen or player:GetAttribute("ExperienceMenuOpen") then
  return Enum.ContextActionResult.Pass
 end
 pending=true task.spawn(function()
  local ok,accepted,message=pcall(function()return remote:InvokeServer(not active)end)
  pending=false if not ok or not accepted then hint(message or "Câmera admin indisponível.") else sync() end
 end)
 return Enum.ContextActionResult.Sink
end,{scope="global",allowMenus=true})
Router.Changed:Connect(function() hint() end)
UIS.LastInputTypeChanged:Connect(function() hint() end)
local function loadPhoto(key)
 if pending then return end
 pending=true
 task.spawn(function()
  if not active then
   local ok,allowed,message=pcall(function()return remote:InvokeServer(true)end)
   if not ok or not allowed then pending=false hint(message or "Não foi possível ativar o modo admin.") return end
   sync()
   task.wait(.35)
  end
  local ok,allowed,data=pcall(function()return remote:InvokeServer("preview",key)end)
  pending=false
  if ok and allowed and active then
   position=data.position
   if spectatorSubject then spectatorSubject.CFrame=CFrame.new(position) end
   workspace.CurrentCamera.CFrame=CFrame.lookAt(data.position,data.focus)
   for index,entry in catalog do if entry.id==key then photoIndex=index break end end
   hint()
  else hint(type(data)=="string" and data or "Não foi possível abrir o mapa.") end
 end)
end
player:GetAttributeChangedSignal("AdminMapSelection"):Connect(function()
 local key=player:GetAttribute("AdminMapSelection")
 if typeof(key)=="string" and player:GetAttribute("CrossgroundsAdmin")==true then loadPhoto(key) end
end)
local function adminCommand(action,state)
 if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then held[action]=nil return end
 if not active or player:GetAttribute("CrossgroundsAdmin")~=true or UIS:GetFocusedTextBox() or GuiService.MenuIsOpen or player:GetAttribute("ExperienceMenuOpen") or player:GetAttribute("HUDLayoutEditing") then return Enum.ContextActionResult.Pass end
 if state~=Enum.UserInputState.Begin then return end
 if action=="AdminClean" then setClean(not clean)
 elseif action=="AdminSpeedUp" or action=="AdminSpeedDown" then
  speed=math.clamp(speed*1.25^(action=="AdminSpeedUp" and 1 or -1),4,512) hint()
 elseif action=="AdminNextMap" or action=="AdminPreviousMap" then
  if pending or #catalog==0 then return end
  photoIndex=((photoIndex-1+(action=="AdminNextMap" and 1 or -1))%#catalog)+1
  loadPhoto(catalog[photoIndex].id)
 else held[action]=true end
 return Enum.ContextActionResult.Sink
end
for _,action in require(game.ReplicatedStorage.ControlDefinitions).Order do
 if action~="AdminMode" and action:match("^Admin") then
  Router:Register(action,function(state) return adminCommand(action,state) end,{scope="admin",allowMenus=true})
 end
end
UIS.WindowFocusReleased:Connect(function() focusLost=true table.clear(held) end)
UIS.WindowFocused:Connect(function() focusLost=false end)
local touchCount=0
UIS.TouchStarted:Connect(function()
 touchCount+=1
 if clean and touchCount>=3 then setClean(false) end
end)
UIS.TouchEnded:Connect(function() touchCount=math.max(0,touchCount-1) end)
UIS.InputChanged:Connect(function(input)
 if active and input.UserInputType==Enum.UserInputType.MouseWheel and not UIS:GetFocusedTextBox() then speed=math.clamp(speed*1.25^input.Position.Z,4,512) hint() end
end)
-- Request streaming near the detached camera only when this experience uses it.
task.spawn(function()while gui.Parent do
 task.wait(2)
 if active and workspace.StreamingEnabled then pcall(function()player:RequestStreamAroundAsync(position,1)end) end
end end)
sync()


