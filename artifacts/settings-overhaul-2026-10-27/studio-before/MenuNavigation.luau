local Navigation={}
local UIS=game:GetService("UserInputService") local CAS=game:GetService("ContextActionService")
local Run=game:GetService("RunService") local Gui=game:GetService("GuiService") local Gamepad=game:GetService("GamepadService")
local Filter=require(game.ReplicatedStorage.Crossgrounds.AnalogFilter)
local Settings=require(game.ReplicatedStorage.ExperienceSettings)
local function zone(key) local value=game.Players.LocalPlayer:GetAttribute("Setting"..key) return value~=nil and value or Settings.Rules[key].Default end
local Mode=require(script.Parent:WaitForChild("InputMode")) local Icons=require(script.Parent:WaitForChild("InputIcons"))
local player=game.Players.LocalPlayer
-- Reuse four local voices and give action feedback priority over focus sounds.
local Audio={}
local soundDefinitions={
 Focus={id="10066931761",gain=.6},
 Confirm={id="10066968815",gain=.75}, -- Roblox: RBLX UI Select 02
 Back={id="10066914500",gain=.65}, -- Roblox: RBLX UI Back
 Step={id="10066936758",gain=.4}, -- Roblox: RBLX UI Hover 02
}
local voices={} local lastSound={} local actionSoundAt=-100
for kind,data in soundDefinitions do
 local sound=Instance.new("Sound") sound.Name="CrossgroundsMenu"..kind
 sound.SoundId="rbxassetid://"..data.id sound.Volume=0 sound.Parent=game:GetService("SoundService") voices[kind]=sound
 task.spawn(function() pcall(function() game:GetService("ContentProvider"):PreloadAsync({sound}) end) end)
end
function Audio:Play(kind)
 local sound=voices[kind] if not sound then return end
 local volume=zone("MenuSFXVolume") local now=os.clock()
 if volume<=0 or not sound.IsLoaded or Gui.MenuIsOpen then return end
 if now-(lastSound[kind] or -100)<(kind=="Step" and .08 or .075) then return end
 if kind=="Focus" and now-actionSoundAt<.08 then return end
 if kind~="Focus" then actionSoundAt=now for _,voice in voices do voice:Stop() end end
 lastSound[kind]=now sound.Volume=volume*soundDefinitions[kind].gain sound.TimePosition=0 sound:Play()
 player:SetAttribute("LastMenuSound",kind)
 if kind=="Focus" then player:SetAttribute("MenuNavigationSoundCount",(player:GetAttribute("MenuNavigationSoundCount") or 0)+1) end
end
player:GetAttributeChangedSignal("SettingMenuSFXVolume"):Connect(function()
 if zone("MenuSFXVolume")<=0 then for _,voice in voices do voice:Stop() end end
end)
-- Our cursor owns PlayerGui input. CoreGui keeps its normal navigation when open.
local nativeDefaults={navigation=Gui.GuiNavigationEnabled,autoSelect=Gui.AutoSelectGuiEnabled}
local suppressingNative=false
local function disableNative()
 if Gui.MenuIsOpen or suppressingNative then return end
 suppressingNative=true
 -- Do not gate this on GamepadCursorEnabled: reads may be unavailable on clients.
 pcall(function() Gamepad:DisableGamepadCursor() end)
 suppressingNative=false
end
local function nativePolicy()
 local core=Gui.MenuIsOpen
 local navigation=core and nativeDefaults.navigation or false
 local autoSelect=core and nativeDefaults.autoSelect or false
 if Gui.GuiNavigationEnabled~=navigation then Gui.GuiNavigationEnabled=navigation end
 if Gui.AutoSelectGuiEnabled~=autoSelect then Gui.AutoSelectGuiEnabled=autoSelect end
 if not core then
  -- A non-nil SelectedObject still draws Roblox's button selector even when
  -- automatic navigation is disabled. Our focus is rendered independently.
  if Gui.SelectedObject~=nil then Gui.SelectedObject=nil end
  disableNative()
 end
end
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local registered={} local back={} local defaults={} local categoryHandlers={}
local focused local root local point=Vector2.zero local stick=Vector2.zero local scrollStick=0 local keyboardStick=Vector2.zero
local keyboardNavigation=false
local dragging=false local repeatAt=0 local heldDirection local analog=false
local controls local movementDisabled=false
local savedPlayerList
task.spawn(function() local module=player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule") controls=require(module):GetControls() end)
local menuRequested=Instance.new("BindableEvent") Navigation.MenuRequested=menuRequested.Event
function Navigation:OpenMenu(id) menuRequested:Fire(id) end
local changed=Instance.new("BindableEvent") Navigation.FocusChanged=changed.Event
local screen=Instance.new("ScreenGui") screen.Name="AccessibleMenuCursor" screen.IgnoreGuiInset=true screen.ResetOnSpawn=false screen.DisplayOrder=95 screen.Parent=player:WaitForChild("PlayerGui")
local cursor=Instance.new("Frame") cursor.Name="Cursor" cursor.Size=UDim2.fromOffset(12,12) cursor.AnchorPoint=Vector2.new(.5,.5) cursor.Rotation=45 cursor.BackgroundColor3=Color3.fromRGB(235,247,255) cursor.BorderSizePixel=0 cursor.Visible=false cursor.Active=false cursor.ZIndex=4 cursor.Parent=screen
local stroke=Instance.new("UIStroke") stroke.Thickness=2 stroke.Color=Color3.fromRGB(27,90,135) stroke.Parent=cursor
local footer=Instance.new("Frame") footer.Name="Instructions" footer.AnchorPoint=Vector2.new(.5,1) footer.Position=UDim2.new(.5,0,1,-8) footer.Size=UDim2.fromOffset(340,32) footer.BackgroundColor3=Color3.fromRGB(12,21,35) footer.BackgroundTransparency=.1 footer.Visible=false footer.Parent=screen
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,7) corner.Parent=footer
Icons:Glyph(footer,"Confirm","ButtonA",26).Position=UDim2.fromOffset(8,3)
Icons:Glyph(footer,"Back","ButtonB",26).Position=UDim2.fromOffset(178,3)
for _,item in {{"CONFIRMAR",40},{"VOLTAR",210}} do local label=Instance.new("TextLabel") label.BackgroundTransparency=1 label.Position=UDim2.fromOffset(item[2],0) label.Size=UDim2.fromOffset(125,32) label.Font=Enum.Font.GothamMedium label.TextSize=13 label.TextColor3=Color3.fromRGB(228,238,250) label.Text=item[1] label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=footer end
local focusGlow=Instance.new("Frame") focusGlow.Name="FocusGlow" focusGlow.BackgroundTransparency=1 focusGlow.Visible=false focusGlow.Active=false focusGlow.ZIndex=1 focusGlow.Parent=screen
local glowCorner=Instance.new("UICorner") glowCorner.Parent=focusGlow
local glowStroke=Instance.new("UIStroke") glowStroke.Thickness=10 glowStroke.Transparency=.82 glowStroke.Color=Color3.fromRGB(116,193,255) glowStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border glowStroke.Parent=focusGlow
local focusFrame=Instance.new("Frame") focusFrame.Name="FocusOutline" focusFrame.BackgroundTransparency=1 focusFrame.Visible=false focusFrame.Active=false focusFrame.ZIndex=2 focusFrame.Parent=screen
local focusCorner=Instance.new("UICorner") focusCorner.Parent=focusFrame
local focusStroke=Instance.new("UIStroke") focusStroke.Parent=focusFrame focusStroke.Name="AccessibleFocus" focusStroke.Thickness=4 focusStroke.Transparency=.04 focusStroke.Color=Color3.fromRGB(220,243,255) focusStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
-- Contextual category help follows the same remapped bindings as the dispatcher.
local previousGlyph=Icons:Glyph(footer,"PreviousCategory",function() return Router:Key("MenuPrevious","Gamepad") end,26)
previousGlyph.Position=UDim2.fromOffset(340,3)
local nextGlyph=Icons:Glyph(footer,"NextCategory",function() return Router:Key("MenuNext","Gamepad") end,26)
nextGlyph.Position=UDim2.fromOffset(370,3)
local categoryHelp=Instance.new("TextLabel")
categoryHelp.BackgroundTransparency=1 categoryHelp.Position=UDim2.fromOffset(402,0) categoryHelp.Size=UDim2.fromOffset(120,32)
categoryHelp.Font=Enum.Font.GothamMedium categoryHelp.TextSize=13 categoryHelp.TextColor3=Color3.fromRGB(228,238,250)
categoryHelp.Text="CATEGORIAS" categoryHelp.TextXAlignment=Enum.TextXAlignment.Left categoryHelp.Parent=footer
local function navigationSound(object)
 local entry=registered[object]
 if not object or not root or Gui.MenuIsOpen or not (object:IsA("GuiButton") or object:IsA("TextBox") or entry and entry.adjust) then return end
 Audio:Play("Focus")
end
function Navigation:PlaySound(kind) Audio:Play(kind) end
local function dockCursor(object)
 local pos,size=object.AbsolutePosition,object.AbsoluteSize
 local origin,bounds=screen.AbsolutePosition,screen.AbsolutePosition+screen.AbsoluteSize
 if pos.X-18>=origin.X+10 then return Vector2.new(pos.X-18,pos.Y+size.Y*.5) end
 if pos.X+size.X+18<=bounds.X-10 then return Vector2.new(pos.X+size.X+18,pos.Y+size.Y*.5) end
 if pos.Y-18>=origin.Y+10 then return Vector2.new(pos.X+size.X*.5,pos.Y-18) end
 return nil
end
local function modal()
 local p=player.PlayerGui local experience=p:FindFirstChild("ExperienceMenu") local join=p:FindFirstChild("JoinMenu") local hud=p:FindFirstChild("CombatHUD")
 local mobile=p:FindFirstChild("MobileCombatHUD")
 if mobile and mobile.Enabled and mobile.Editor.Visible then return mobile.Editor end
 local music=p:FindFirstChild("LobbyMusicMenu")
 if music and music.Enabled and music.Backdrop.Visible then return music.Backdrop.Panel end
 local progress=p:FindFirstChild("ProgressionPanel")
 if progress and progress.Enabled then return progress:FindFirstChildOfClass("Frame").Panel end
 local hub=p:FindFirstChild("CrossgroundsHub")
 if hub and hub.Enabled and hub.StatusPanel.Visible then return hub.StatusPanel end
 if experience and experience.Enabled and experience.Shade.Visible then return experience.Shade.Panel end
 local hubBackdrop=hub and hub:FindFirstChild("BrowserBackdrop")
 if hubBackdrop and hubBackdrop.Visible then return hubBackdrop.Panel end
 local hubPanel=hub and hub:FindFirstChild("Panel")
 if hubPanel and hub.Enabled and hubPanel.Visible then return hubPanel end
 local arena=p:FindFirstChild("ArenaHUD")
 if arena and arena.Enabled and arena.VoteShade.Visible then return arena.VoteShade.Panel end
 if join and join.Enabled and join.Backdrop.Visible then return join.Backdrop.Panel end
 if hud and hud.LeaveShade.Visible then return hud.LeaveShade.Dialog end
end
local function visible(object,clipping)
 if not object or not object.Parent or not root or not object:IsDescendantOf(root) then return false end
 local center=object.AbsolutePosition+object.AbsoluteSize*.5 local v=object
 while v and v~=player.PlayerGui do
  if v:IsA("GuiObject") then
   if not v.Visible then return false end
   if clipping and v:IsA("ScrollingFrame") then local pos,size=v.AbsolutePosition,v.AbsoluteSize if center.Y<pos.Y or center.Y>pos.Y+size.Y then return false end end
  elseif v:IsA("ScreenGui") and not v.Enabled then return false end
  v=v.Parent
 end
 return true
end
local function reveal(object)
 local ancestor=object.Parent
 while ancestor and ancestor~=root do
  if ancestor:IsA("ScrollingFrame") then
   local pos=object.AbsolutePosition.Y-ancestor.AbsolutePosition.Y local bottom=pos+object.AbsoluteSize.Y
   if pos<0 then ancestor.CanvasPosition+=Vector2.new(0,pos-4)
   elseif bottom>ancestor.AbsoluteSize.Y then ancestor.CanvasPosition+=Vector2.new(0,bottom-ancestor.AbsoluteSize.Y+4) end
  end ancestor=ancestor.Parent
 end
end
function Navigation:Focus(object,moveCursor)
 if object and not visible(object,false) then return end
 if focused~=object then focused=object changed:Fire(object) if object then navigationSound(object) end end
 if object and moveCursor~=false then
  reveal(object) point=object.AbsolutePosition+Vector2.new(math.min(20,object.AbsoluteSize.X*.5),object.AbsoluteSize.Y*.5) analog=false
 end
end
function Navigation:GetFocus() return focused end
function Navigation:SetCategories(container,callback)
 categoryHandlers[container]=callback
 container.Destroying:Connect(function() categoryHandlers[container]=nil end)
end
function Navigation:SetBack(container,callback,default) back[container]=callback defaults[container]=default end
function Navigation:Register(object,callback,adjust)
 registered[object]={activate=callback and function()
  if not object:GetAttribute("MenuAudioConnected") then Audio:Play(adjust and "Step" or "Confirm") end
  callback()
 end,adjust=adjust}
 object.Destroying:Connect(function() registered[object]=nil if focused==object then Navigation:Focus(nil,false) end end)
 object.MouseEnter:Connect(function() if root and Mode:Get()~=Enum.PreferredInput.Gamepad then self:Focus(object,false) end end)
 return object
end
function Navigation:Connect(object,callback)
 object:SetAttribute("MenuAudioConnected",true)
 local function activate()
  local kind=object:GetAttribute("MenuSoundKind") or ((object.Name=="Back" or object.Name=="Close" or object.Name=="Cancel") and "Back" or "Confirm")
  if kind~="Silent" then Audio:Play(kind) end
  callback()
 end
 self:Register(object,activate)
 return object.Activated:Connect(activate)
end
function Navigation:Activate()
 local entry=focused and registered[focused]
 if entry and entry.activate then entry.activate() end
end
local function first()
 local preferred=defaults[root]
 if preferred and visible(preferred,false) then return preferred end
 local best local score=math.huge
 for object in pairs(registered) do if visible(object,false) then local p=object.AbsolutePosition local value=p.Y*10000+p.X if value<score then score=value best=object end end end
 return best
end
local function direction(key)
 if not focused or not visible(focused,false) then Navigation:Focus(first()) return end
 local entry=registered[focused]
 if (key==Enum.KeyCode.DPadLeft or key==Enum.KeyCode.DPadRight) and entry and entry.adjust then entry.adjust(key==Enum.KeyCode.DPadRight and 1 or -1) return end
 local links={[Enum.KeyCode.DPadLeft]="NextSelectionLeft",[Enum.KeyCode.DPadRight]="NextSelectionRight",[Enum.KeyCode.DPadUp]="NextSelectionUp",[Enum.KeyCode.DPadDown]="NextSelectionDown"}
 local linked=focused[links[key]]
 if linked and visible(linked,false) then Navigation:Focus(linked) return end
 local axis=key==Enum.KeyCode.DPadRight and Vector2.new(1,0) or key==Enum.KeyCode.DPadLeft and Vector2.new(-1,0) or key==Enum.KeyCode.DPadDown and Vector2.new(0,1) or Vector2.new(0,-1)
 local from=focused.AbsolutePosition+focused.AbsoluteSize*.5 local best local score=math.huge
 for object in pairs(registered) do
  if object~=focused and visible(object,false) then
   local delta=object.AbsolutePosition+object.AbsoluteSize*.5-from local forward=delta:Dot(axis)
   local side=math.abs(delta.X*axis.Y-delta.Y*axis.X)
   local pos,size=object.AbsolutePosition,object.AbsoluteSize
   local overlap=axis.Y~=0 and from.X>=pos.X and from.X<=pos.X+size.X or axis.X~=0 and from.Y>=pos.Y and from.Y<=pos.Y+size.Y
   if overlap then side=0 end
   if forward>5 and (overlap or side<=forward*.85) then local value=forward+side*3 if value<score then score=value best=object end end
  end
 end
 if best then Navigation:Focus(best) end
end
local function syncRoot()
 local nextRoot=modal()
 if nextRoot~=root then root=nextRoot Navigation:Focus(nil) heldDirection=nil if root then Navigation:Focus(first()) end end
end
for action,step in {MenuPrevious=-1,MenuNext=1} do
 Router:Register(action,function(state)
  if state~=Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end
  syncRoot()
  local handler=root and categoryHandlers[root]
  if handler then Audio:Play("Focus") handler(step) end
  return Enum.ContextActionResult.Sink
 end,{scope="menu"})
end
CAS:BindActionAtPriority("CTFAccessibleMenu",function(_,state,input)
 syncRoot()
 if not root or player:GetAttribute("Rebinding") or Gui.MenuIsOpen or UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
 local original=input.KeyCode
 if original==Enum.KeyCode.Thumbstick1 then stick=Vector2.new(input.Position.X,input.Position.Y) return Enum.ContextActionResult.Sink end
 if original==Enum.KeyCode.Thumbstick2 then scrollStick=input.Position.Y return Enum.ContextActionResult.Sink end
 local keyboard=original==Enum.KeyCode.Up or original==Enum.KeyCode.Down or original==Enum.KeyCode.Left or original==Enum.KeyCode.Right or original==Enum.KeyCode.Return or original==Enum.KeyCode.KeypadEnter or original==Enum.KeyCode.Escape or original==Enum.KeyCode.Tab
 if keyboard then keyboardNavigation=true end
 local aliases={[Enum.KeyCode.Up]=Enum.KeyCode.DPadUp,[Enum.KeyCode.Down]=Enum.KeyCode.DPadDown,[Enum.KeyCode.Left]=Enum.KeyCode.DPadLeft,[Enum.KeyCode.Right]=Enum.KeyCode.DPadRight,[Enum.KeyCode.Return]=Enum.KeyCode.ButtonA,[Enum.KeyCode.KeypadEnter]=Enum.KeyCode.ButtonA,[Enum.KeyCode.Escape]=Enum.KeyCode.ButtonB}
 local key=aliases[original] or original
 if state==Enum.UserInputState.Begin then
  player:SetAttribute("LastMenuInput",key.Name)
  if key==Enum.KeyCode.Tab then
   local ordered={} for object in pairs(registered) do if visible(object,false) then table.insert(ordered,object) end end
   table.sort(ordered,function(a,b) local x,y=a.AbsolutePosition,b.AbsolutePosition return math.abs(x.Y-y.Y)<3 and x.X<y.X or math.abs(x.Y-y.Y)>=3 and x.Y<y.Y end)
   if #ordered>0 then local index=table.find(ordered,focused) or 0 local step=(UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) and -1 or 1 Navigation:Focus(ordered[(index-1+step)%#ordered+1]) end
  elseif key==Enum.KeyCode.ButtonA then Navigation:Activate()
  elseif key==Enum.KeyCode.ButtonB then local callback=back[root] if callback then Audio:Play("Back") callback() end
  else direction(key) heldDirection=key repeatAt=os.clock()+.4 end
 elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then heldDirection=nil end
 return Enum.ContextActionResult.Sink
end,false,6000,Enum.KeyCode.ButtonA,Enum.KeyCode.ButtonB,Enum.KeyCode.Thumbstick1,Enum.KeyCode.Thumbstick2,Enum.KeyCode.DPadLeft,Enum.KeyCode.DPadRight,Enum.KeyCode.DPadUp,Enum.KeyCode.DPadDown,Enum.KeyCode.Up,Enum.KeyCode.Down,Enum.KeyCode.Left,Enum.KeyCode.Right,Enum.KeyCode.Return,Enum.KeyCode.KeypadEnter,Enum.KeyCode.Escape,Enum.KeyCode.Tab)
local fake={Thumbstick1Right=Vector2.new(1,0),Thumbstick1Left=Vector2.new(-1,0),Thumbstick1Up=Vector2.new(0,1),Thumbstick1Down=Vector2.new(0,-1)}
local textFocusAt=0
UIS.TextBoxFocused:Connect(function() textFocusAt=os.clock() end)
UIS.InputBegan:Connect(function(input)
 local box=UIS:GetFocusedTextBox()
 if box and box:IsDescendantOf(player.PlayerGui) then
  local key=input.KeyCode
  if key==Enum.KeyCode.ButtonB or key==Enum.KeyCode.Escape then box:ReleaseFocus(false)
  elseif key==Enum.KeyCode.Return or key==Enum.KeyCode.KeypadEnter or key==Enum.KeyCode.ButtonA and os.clock()-textFocusAt>.25 then box:ReleaseFocus(true) end
 end
 if fake[input.KeyCode.Name] then keyboardStick=fake[input.KeyCode.Name] end
end)
UIS.InputEnded:Connect(function(input) if fake[input.KeyCode.Name] then keyboardStick=Vector2.zero end end)
UIS.InputChanged:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseMovement and input.Delta.Magnitude>1 then keyboardNavigation=false Gui.SelectedObject=nil end
 if input.KeyCode==Enum.KeyCode.Thumbstick1 then stick=Vector2.new(input.Position.X,input.Position.Y)
 elseif input.KeyCode==Enum.KeyCode.Thumbstick2 then scrollStick=input.Position.Y end
end)
UIS.WindowFocusReleased:Connect(function() stick=Vector2.zero keyboardStick=Vector2.zero scrollStick=0 heldDirection=nil end)
pcall(function() Gamepad:GetPropertyChangedSignal("GamepadCursorEnabled"):Connect(disableNative) end)
Gui:GetPropertyChangedSignal("GuiNavigationEnabled"):Connect(nativePolicy)
Gui:GetPropertyChangedSignal("AutoSelectGuiEnabled"):Connect(nativePolicy)
Gui:GetPropertyChangedSignal("SelectedObject"):Connect(nativePolicy)
Gui.MenuOpened:Connect(function()
 heldDirection=nil stick=Vector2.zero keyboardStick=Vector2.zero scrollStick=0
 Gui.SelectedObject=nil nativePolicy()
end)
Gui.MenuClosed:Connect(function()
 nativePolicy() task.defer(function() syncRoot() Navigation:Focus(focused or first()) end)
end)
nativePolicy()
Run:BindToRenderStep("CTFMenuCursor",Enum.RenderPriority.Last.Value,function(dt)
 nativePolicy()
 syncRoot() local gamepad=Mode:Get()==Enum.PreferredInput.Gamepad
 player:SetAttribute("GameMenuOpen",root~=nil)
 player:SetAttribute("MenuRoot",root and root.Parent.Name or "")
 if root and savedPlayerList==nil then
  local ok,v=pcall(function() return game.StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) end)
  if ok then savedPlayerList=v pcall(function() game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false) end) end
 elseif not root and savedPlayerList~=nil then local previous=savedPlayerList savedPlayerList=nil pcall(function() game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,previous) end) end
 local disableMovement=not Router:CanMove()
 if controls and movementDisabled~=disableMovement then movementDisabled=disableMovement if movementDisabled then controls:Disable() else controls:Enable() end end
 local hasCategories=root~=nil and categoryHandlers[root]~=nil
 footer.Size=UDim2.fromOffset(hasCategories and 530 or 340,32)
 previousGlyph.Visible=hasCategories nextGlyph.Visible=hasCategories categoryHelp.Visible=hasCategories
 cursor.Visible=gamepad and root~=nil and not Gui.MenuIsOpen footer.Visible=cursor.Visible and not player:GetAttribute("Rebinding")
 focusStroke.Enabled=(cursor.Visible or root~=nil and keyboardNavigation) and not Gui.MenuIsOpen
 focusFrame.Visible=focusStroke.Enabled and focused~=nil and visible(focused,true)
 focusGlow.Visible=focusFrame.Visible
 if focusFrame.Visible then
  local position=focused.AbsolutePosition-screen.AbsolutePosition
  focusFrame.Position=UDim2.fromOffset(position.X-3,position.Y-3)
  focusFrame.Size=UDim2.fromOffset(focused.AbsoluteSize.X+6,focused.AbsoluteSize.Y+6)
  focusGlow.Position=focusFrame.Position-UDim2.fromOffset(2,2) focusGlow.Size=focusFrame.Size+UDim2.fromOffset(4,4)
  local rounding=focused:FindFirstChildOfClass("UICorner")
  local radius=rounding and rounding.CornerRadius or UDim.new(0,10)
  focusCorner.CornerRadius=UDim.new(radius.Scale,radius.Offset+3)
  glowCorner.CornerRadius=UDim.new(radius.Scale,radius.Offset+5)
 end
 if not Gui.MenuIsOpen then
  if gamepad then UIS.MouseIconEnabled=false
  elseif root or not player:GetAttribute("CombatCameraActive") then UIS.MouseIconEnabled=true end
 end
 if not root or not gamepad or Gui.MenuIsOpen or player:GetAttribute("Rebinding") then return end
 if focused and not visible(focused,false) or not focused and not analog then Navigation:Focus(first()) end
 if heldDirection and os.clock()>=repeatAt then direction(heldDirection) repeatAt=os.clock()+.12 end
 local movement=Filter.Radial(keyboardStick.Magnitude>0 and keyboardStick or stick,zone("LeftStickDeadzone"))
 if movement.Magnitude>0 then
  local v=workspace.CurrentCamera.ViewportSize
  point+=Vector2.new(movement.X,-movement.Y)*math.min(dt,.05)*v.Y*.95
  local origin=screen.AbsolutePosition local size=screen.AbsoluteSize
  point=Vector2.new(math.clamp(point.X,origin.X+4,origin.X+size.X-4),math.clamp(point.Y,origin.Y+4,origin.Y+size.Y-4)) analog=true
  local hovered local area=math.huge
  for object in pairs(registered) do
   if visible(object,true) then local p,size=object.AbsolutePosition,object.AbsoluteSize if point.X>=p.X and point.X<=p.X+size.X and point.Y>=p.Y and point.Y<=p.Y+size.Y and size.X*size.Y<area then hovered=object area=size.X*size.Y end end
  end
  Navigation:Focus(hovered,false)
 end
 local filteredScroll=Filter.Axis(scrollStick,zone("RightStickDeadzone"))
 if math.abs(filteredScroll)>0 and focused then local ancestor=focused.Parent while ancestor and ancestor~=root do if ancestor:IsA("ScrollingFrame") then ancestor.CanvasPosition+=Vector2.new(0,-filteredScroll*dt*350) break end ancestor=ancestor.Parent end end
 local visual=point
 if focused and visible(focused,true) then
  visual=dockCursor(focused)
  if not visual then cursor.Visible=false end
 end
 if visual then
  local localPoint=visual-screen.AbsolutePosition
  cursor.Position=UDim2.fromOffset(localPoint.X,localPoint.Y)
  player:SetAttribute("MenuCursorVisualPosition",visual)
 end
 player:SetAttribute("MenuCursorPosition",point)
 player:SetAttribute("MenuFocusedControl",focused and focused.Name or "")
end)
return Navigation

