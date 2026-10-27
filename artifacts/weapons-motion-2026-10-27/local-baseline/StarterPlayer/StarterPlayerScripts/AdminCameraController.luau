local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local StarterGui=game:GetService("StarterGui")
local GuiService=game:GetService("GuiService")
local player=Players.LocalPlayer
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
 help.Text=message or (active and ("ADMIN · CÂMERA LIVRE · "..math.floor(speed).." studs/s\nWASD mover · Q/E descer/subir · Shift acelerar · Ctrl precisão · roda ajustar\nPageUp/PageDown mapa da Arena · F7 captura limpa · F6 sair") or "ADMIN · F6 câmera livre · sai da partida antes de ativar")
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
 if not active then return end active=false
 setClean(false)
 Run:UnbindFromRenderStep("AdminFreeCamera") CAS:UnbindAction("AdminCameraMovement")
 if controls then controls:Enable() end
 local camera=workspace.CurrentCamera
 if saved then
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
 saved={cameraType=camera.CameraType,subject=camera.CameraSubject,cf=camera.CFrame,focus=camera.Focus,fov=camera.FieldOfView,mouse=UIS.MouseBehavior,icon=UIS.MouseIconEnabled}
 position=camera.CFrame.Position
 local look=camera.CFrame.LookVector pitch=math.asin(math.clamp(look.Y,-1,1)) yaw=math.atan2(-look.X,-look.Z)
 local module=player.PlayerScripts:FindFirstChild("PlayerModule") if module then controls=require(module):GetControls() controls:Disable() end
 active=true
 CAS:BindActionAtPriority("AdminCameraMovement",function()return Enum.ContextActionResult.Sink end,false,20000,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Q,Enum.KeyCode.E,Enum.KeyCode.Space,Enum.KeyCode.LeftShift,Enum.KeyCode.LeftControl,Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2)
 Run:BindToRenderStep("AdminFreeCamera",Enum.RenderPriority.Camera.Value+100,function(dt)
  camera=workspace.CurrentCamera camera.CameraType=Enum.CameraType.Scriptable
  local blocked=UIS:GetFocusedTextBox()~=nil or GuiService.MenuIsOpen
  UIS.MouseIconEnabled=blocked UIS.MouseBehavior=blocked and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
  if not blocked then
   local delta=UIS:GetMouseDelta() yaw-=delta.X*.0025 pitch=math.clamp(pitch-delta.Y*.0025,-1.55,1.55)
   local function key(code)return UIS:IsKeyDown(code) and 1 or 0 end
   local move=Vector3.new(key(Enum.KeyCode.D)-key(Enum.KeyCode.A),key(Enum.KeyCode.E)-key(Enum.KeyCode.Q),key(Enum.KeyCode.S)-key(Enum.KeyCode.W))
   if move.Magnitude>1 then move=move.Unit end
   local rotation=CFrame.fromOrientation(pitch,yaw,0)
   local direction=rotation.RightVector*move.X+Vector3.yAxis*move.Y-rotation.LookVector*move.Z
   local multiplier=UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 4 or UIS:IsKeyDown(Enum.KeyCode.LeftControl) and .2 or 1
   position+=direction*speed*multiplier*math.min(dt,.1)
  end
  camera.CFrame=CFrame.new(position)*CFrame.fromOrientation(pitch,yaw,0) camera.Focus=camera.CFrame*CFrame.new(0,0,-32)
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
UIS.InputBegan:Connect(function(input,processed)
 if player:GetAttribute("CrossgroundsAdmin")~=true or UIS:GetFocusedTextBox() or GuiService.MenuIsOpen then return end
 if input.KeyCode==Enum.KeyCode.F6 and not pending then
  pending=true task.spawn(function()
   local ok,accepted,message=pcall(function()return remote:InvokeServer(not active)end)
   pending=false if not ok or not accepted then hint(message or "Câmera admin indisponível.") else sync() end
  end)
 elseif input.KeyCode==Enum.KeyCode.F7 and active then setClean(not clean)
 elseif active and not pending and #catalog>0 and (input.KeyCode==Enum.KeyCode.PageDown or input.KeyCode==Enum.KeyCode.PageUp) then
  photoIndex=((photoIndex-1+(input.KeyCode==Enum.KeyCode.PageDown and 1 or -1))%#catalog)+1
  pending=true task.spawn(function()
   local ok,allowed,data=pcall(function()return remote:InvokeServer("preview",catalog[photoIndex].id)end)
   pending=false
   if ok and allowed and active then
    position=data.position local look=(data.focus-data.position).Unit pitch=math.asin(look.Y) yaw=math.atan2(-look.X,-look.Z)
    hint("ADMIN · "..data.name.."\nF7 captura limpa · WASD/Q/E mover · PageUp/PageDown outro mapa · F6 sair")
   else hint(type(data)=="string" and data or "Não foi possível abrir o mapa.") end
  end)
 end
end)
UIS.InputChanged:Connect(function(input)
 if active and input.UserInputType==Enum.UserInputType.MouseWheel and not UIS:GetFocusedTextBox() then speed=math.clamp(speed*1.25^input.Position.Z,4,512) hint() end
end)
-- Request streaming near the detached camera only when this experience uses it.
task.spawn(function()while gui.Parent do
 task.wait(2)
 if active and workspace.StreamingEnabled then pcall(function()player:RequestStreamAroundAsync(position,1)end) end
end end)
sync()
