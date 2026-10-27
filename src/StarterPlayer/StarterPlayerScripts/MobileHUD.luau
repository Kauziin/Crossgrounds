-- One touch layer for all combat actions. Desktop also exposes the layout preview.
local player=game.Players.LocalPlayer
local UIS=game:GetService("UserInputService") local Run=game:GetService("RunService")
local Scope=require(script.Parent:WaitForChild("ModeScope")) local Mode=require(script.Parent:WaitForChild("InputMode"))
local Router=require(script.Parent:WaitForChild("ControlRouter")) local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Icons=require(script.Parent:WaitForChild("InputIcons"))
local Settings=require(game.ReplicatedStorage:WaitForChild("ExperienceSettings"))
local Layout=require(game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("MobileLayout"))
local update=game.ReplicatedStorage.Events:WaitForChild("UpdateExperienceSetting")
local white=Color3.fromRGB(239,246,255) local accent=Color3.fromRGB(99,210,224)
local gui=Instance.new("ScreenGui") gui.Name="MobileCombatHUD" gui.ResetOnSpawn=false gui.DisplayOrder=72 gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=player:WaitForChild("PlayerGui")
local surface=Instance.new("Frame") surface.Name="Controls" surface.Size=UDim2.fromScale(1,1) surface.BackgroundTransparency=1 surface.Parent=gui
local editor=Instance.new("Frame") editor.Name="Editor" editor.Size=UDim2.fromScale(1,1) editor.BackgroundColor3=Color3.fromRGB(5,15,25) editor.BackgroundTransparency=.5 editor.Visible=false editor.Active=true editor.Parent=gui
local editing=false local draft local selected local drag local active={} local aimToggle=false
local Art=require(script.Parent:WaitForChild("TouchActionIcons"))
local gamepadDrag
local buttons={} local artwork={} local fields={} local nativeJump local oldJumpVisible
local function round(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=p end
local function label(p,name,text,x,y,w,h,size)
 local t=Instance.new("TextLabel") t.Name=name t.Text=text t.Position=UDim2.fromOffset(x,y) t.Size=UDim2.fromOffset(w,h) t.BackgroundTransparency=1 t.TextColor3=white t.Font=Enum.Font.GothamMedium t.TextSize=size or 14 t.TextXAlignment=Enum.TextXAlignment.Left t:SetAttribute("CascadeDecoration",true) t.Parent=p return t
end
local function button(p,name,text,x,y,w,h)
 local b=Instance.new("TextButton") b.Name=name b.Text=text b.Position=UDim2.fromOffset(x,y) b.Size=UDim2.fromOffset(w,h) b.BackgroundColor3=Color3.fromRGB(32,53,70) b.BorderSizePixel=0 b.TextColor3=white b.Font=Enum.Font.GothamBold b.TextSize=13 b:SetAttribute("CascadeDecoration",true) b.Parent=p round(b,8) return b
end
local function get(key) local v=player:GetAttribute("Setting"..key) return v==nil and Settings.Rules[key].Default or v end
local function cancelInputs()
 for action,input in active do Router:Dispatch(action,Enum.UserInputState.Cancel,input) end
 active={} aimToggle=false Router:Dispatch("Aim",Enum.UserInputState.Cancel)
end
-- Properties live independently of the persistent save/cancel toolbar.
local canvas=button(editor,"Canvas","",0,0,1,1) canvas.Size=UDim2.fromScale(1,1) canvas.BackgroundTransparency=1 canvas.AutoButtonColor=false canvas.ZIndex=1
local panel=Instance.new("Frame") panel.Name="Tools" panel.Size=UDim2.fromOffset(232,132) panel.BackgroundColor3=Color3.fromRGB(14,25,38) panel.BackgroundTransparency=.12 panel.BorderSizePixel=0 panel.Visible=false panel.ZIndex=30 panel.Parent=editor round(panel,12)
local scale=Instance.new("UIScale") scale.Parent=panel
local name=label(panel,"Selected","",12,6,208,26,13)
local function refreshFields()
 panel.Visible=editing and selected~=nil
 if not editing or not selected then return end
 name.Text=Layout.Buttons[selected].Label
 for field,box in fields do if UIS:GetFocusedTextBox()~=box then box.Text=string.format("%.0f",draft[selected][field]*(field=="Size" and 1 or 100)) end end
end
local function change(field,value,action)
 action=action or selected
 if not editing or not action then return end
 local clean=Settings:Sanitize(Layout.Key(action,field),value)
 if clean~=nil then draft[action][field]=clean refreshFields() end
end
for i,field in {"Size","Opacity"} do
 local row=Instance.new("Frame") row.Name=field row.Position=UDim2.fromOffset(12,34+(i-1)*44) row.Size=UDim2.fromOffset(208,40) row.BackgroundTransparency=1 row.Parent=panel
 label(row,"Label",field=="Size" and "Tamanho" or "Opacidade",0,0,76,36,11)
 local minus=button(row,"Minus","−",78,0,36,36)
 local box=Instance.new("TextBox") box.Name="Value" box.ClearTextOnFocus=false box.Position=UDim2.fromOffset(118,0) box.Size=UDim2.fromOffset(50,36) box.BackgroundColor3=Color3.fromRGB(27,43,59) box.TextColor3=white box.Font=Enum.Font.GothamBold box.TextSize=13 box.Parent=row round(box,7) fields[field]=box
 local plus=button(row,"Plus","+",172,0,36,36)
 local editingAction
 box.Focused:Connect(function() editingAction=selected end)
 box.FocusLost:Connect(function() local v=tonumber((box.Text:gsub(",","."))) if v then change(field,v/(field=="Size" and 1 or 100),editingAction) end refreshFields() end)
 local function adjust(d) if selected then change(field,draft[selected][field]+d*(field=="Size" and 2 or .01)) end end
 Nav:Register(row,function() box:CaptureFocus() end,adjust)
 minus.Activated:Connect(function() adjust(-1) end) plus.Activated:Connect(function() adjust(1) end)
end
local toolbar=Instance.new("Frame") toolbar.Name="Toolbar" toolbar.AnchorPoint=Vector2.new(.5,0) toolbar.Position=UDim2.new(.5,0,0,8) toolbar.Size=UDim2.fromOffset(264,38) toolbar.BackgroundTransparency=1 toolbar.ZIndex=40 toolbar.Parent=editor
local save=button(toolbar,"Save","SALVAR",0,0,84,38)
local cancel=button(toolbar,"Cancel","CANCELAR",90,0,84,38)
local reset=button(toolbar,"Reset","PADRÃO",180,0,84,38)
local function inside(object,point)
 local p,z=object.AbsolutePosition,object.AbsoluteSize
 return object.Visible and point.X>=p.X and point.X<=p.X+z.X and point.Y>=p.Y and point.Y<=p.Y+z.Y
end
canvas.InputBegan:Connect(function(input)
 if not editing or drag or input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
 local point=Vector2.new(input.Position.X,input.Position.Y)
 if inside(toolbar,point) or inside(panel,point) then return end
 for _,b in buttons do if inside(b,point) then return end end
 selected=nil refreshFields() Nav:Focus(nil)
end)
local function move(action,point)
 local d=draft[action] local size=editor.AbsoluteSize
 local _,diameter=Layout.Pixels(d,size)
 point=Layout.ClampPoint(point,diameter,size)
 d.X=point.X/math.max(size.X,1) d.Y=point.Y/math.max(size.Y,1)
end
local function positionPanel()
 if not selected then return end
 local size=editor.AbsoluteSize
 scale.Scale=math.max(.4,math.min(1,(size.X-16)/232,(size.Y-70)/132))
 local width,height=232*scale.Scale,132*scale.Scale
 local center=Layout.Pixels(draft[selected],size)
 local best,score
 for _,p in {Vector2.new(8,54),Vector2.new(math.max(8,size.X-width-8),54),Vector2.new(8,math.max(54,size.Y-height-8)),Vector2.new(math.max(8,size.X-width-8),math.max(54,size.Y-height-8))} do
  local distance=(p+Vector2.new(width/2,height/2)-center).Magnitude
  if not score or distance>score then best=p score=distance end
 end
 panel.Position=UDim2.fromOffset(best.X,best.Y)
end
local function close(keep)
 if not editing then return end
 if keep then
  local values={}
  for action,fields in draft do for field,value in fields do local key=Layout.Key(action,field) value=Settings:Sanitize(key,value) player:SetAttribute("Setting"..key,value) values[key]=value end end
  update:FireServer("MobileHUDLayout",values)
 end
 editing=false selected=nil gamepadDrag=nil drag=nil panel.Visible=false editor.Visible=false player:SetAttribute("HUDLayoutEditing",false)
 for _,b in buttons do b.Parent=surface end
 cancelInputs() Nav:OpenMenu("HUDSettings")
end
Nav:Connect(save,function() close(true) end) Nav:Connect(cancel,function() close(false) end)
Nav:Connect(reset,function()
 for action,data in Layout.Buttons do for _,field in {"X","Y","Size","Opacity"} do draft[action][field]=data[field] end end
 refreshFields()
end)
Nav:SetBack(editor,function() close(false) end,save)
for _,action in Layout.Order do
 local data=Layout.Buttons[action]
 local b=button(surface,action,"",0,0,data.Size,data.Size) b.AnchorPoint=Vector2.new(.5,.5) b:FindFirstChildOfClass("UICorner").CornerRadius=UDim.new(.5,0)
 b:SetAttribute("TouchLookSurface",action=="Fire")
 local stroke=Instance.new("UIStroke") stroke.Name="Outline" stroke.Thickness=2 stroke.Color=white stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Parent=b
 b.ZIndex=5 b:SetAttribute("AccessibleLabel",data.Label) artwork[action]=Art.Create(b,action)
 buttons[action]=b
 local function select() selected=action refreshFields() end
 Nav:Register(b,select)
 b.InputBegan:Connect(function(input)
  if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
  if editing then select() drag={input=input,action=action,start=Vector2.new(input.Position.X,input.Position.Y),position=b.AbsolutePosition+b.AbsoluteSize/2-editor.AbsolutePosition} return end
  if (not data.AdminOnly and Router:IsBlocked()) or active[action] then return end
  if action=="Aim" then aimToggle=not aimToggle Router:Dispatch(action,aimToggle and Enum.UserInputState.Begin or Enum.UserInputState.End,input)
  else active[action]=input Router:Dispatch(action,Enum.UserInputState.Begin,input) end
 end)
end
game:GetService("ContextActionService"):BindActionAtPriority("HUDLayoutDrag",function(_,state)
 if not editing then return Enum.ContextActionResult.Pass end
 local focused=Nav:GetFocus()
 if state==Enum.UserInputState.Begin then
  for action,b in buttons do if b==focused then
   selected=action refreshFields()
   gamepadDrag={action=action,cursor=player:GetAttribute("MenuCursorPosition"),position=b.AbsolutePosition+b.AbsoluteSize/2-editor.AbsolutePosition}
   return Enum.ContextActionResult.Sink
  end end
 elseif gamepadDrag then gamepadDrag=nil return Enum.ContextActionResult.Sink end
 return Enum.ContextActionResult.Pass
end,false,6500,Enum.KeyCode.ButtonA)
UIS.InputChanged:Connect(function(input)
 if not drag or not editing then return end
 if input~=drag.input and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
 if input.UserInputType==Enum.UserInputType.MouseMovement and drag.input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
 local delta=Vector2.new(input.Position.X,input.Position.Y)-drag.start
 move(drag.action,drag.position+delta)
 refreshFields()
end)
UIS.InputEnded:Connect(function(input)
 if drag and (input==drag.input or input.UserInputType==Enum.UserInputType.MouseButton1 and drag.input.UserInputType==Enum.UserInputType.MouseButton1) then drag=nil end
 for action,held in active do if held==input then active[action]=nil Router:Dispatch(action,Enum.UserInputState.End,input) end end
end)
UIS.WindowFocusReleased:Connect(function() drag=nil gamepadDrag=nil cancelInputs() end)
Scope.Changed:Connect(function() cancelInputs() if editing then close(false) end end)
Nav.MenuRequested:Connect(function(id)
 if id~="MobileHUD" then return end
 cancelInputs() draft={}
 for action in Layout.Buttons do draft[action]=Layout.Read(action,get) buttons[action].Parent=editor end
 selected=nil panel.Visible=false
 editing=true editor.Visible=true player:SetAttribute("HUDLayoutEditing",true) refreshFields()
end)
local function allowed(action,kind)
 if action=="Fire" or action=="SwitchWeapon" then return kind~=nil end
 if action=="Aim" then return kind=="Gun" end
 if action=="ShiftLock" then return kind~=nil and kind~="Gun" and not Scope:IsArena() end
 if action=="Perspective" then return kind~=nil and not Scope:IsArena() end
 if action=="Shoulder" then return kind~=nil and not player:GetAttribute("FirstPerson") end
 return true
end
Run.RenderStepped:Connect(function()
 local c=player.Character local tool=c and c:FindFirstChildOfClass("Tool") local kind=tool and tool:GetAttribute("WeaponKind")
 if kind~="Gun" and aimToggle then aimToggle=false Router:Dispatch("Aim",Enum.UserInputState.Cancel) end
 local admin=player:GetAttribute("CrossgroundsAdmin")==true
 local freecam=admin and player:GetAttribute("AdminFreecam")==true
 local show=Mode:Get()==Enum.PreferredInput.Touch and not player:GetAttribute("ExperienceMenuOpen") and not game:GetService("GuiService").MenuIsOpen and (admin or Scope:IsCombat() and not Router:IsBlocked())
 if not show and next(active) or not show and aimToggle then cancelInputs() end
 surface.Visible=show
 if editing then
  if gamepadDrag then
   local cursor=player:GetAttribute("MenuCursorPosition")
   if cursor and gamepadDrag.cursor then move(gamepadDrag.action,gamepadDrag.position+cursor-gamepadDrag.cursor) end
  end
  positionPanel()
 end
 for action,b in buttons do
  local data=editing and draft[action] or Layout.Read(action,get)
  local point,diameter=Layout.Pixels(data,(editing and editor or surface).AbsoluteSize)
  b.Position=UDim2.fromScale(point.X/math.max((editing and editor or surface).AbsoluteSize.X,1),point.Y/math.max((editing and editor or surface).AbsoluteSize.Y,1)) b.Size=UDim2.fromOffset(diameter,diameter)
  -- Store the displayed normalized position for resolution-independent dragging.
  if editing and not drag then b.Position=UDim2.fromScale(point.X/math.max(editor.AbsoluteSize.X,1),point.Y/math.max(editor.AbsoluteSize.Y,1)) end
  local adminButton=Layout.Buttons[action].AdminOnly
  b.Visible=adminButton and admin and (editing or (not player:GetAttribute("AdminCaptureClean") and (action=="AdminMode" or freecam))) or not adminButton and (editing or Scope:IsCombat() and not Router:IsBlocked() and not freecam and allowed(action,kind))
  local pressed=active[action]~=nil or action=="Aim" and aimToggle
  b.BackgroundColor3=pressed and Color3.fromRGB(36,119,136) or Color3.fromRGB(19,32,45)
  local opacity=data.Opacity*(adminButton and not editing and not pressed and .55 or 1)
  b.BackgroundTransparency=1-opacity*(adminButton and .24 or .48)
  b.Outline.Color=editing and selected==action and accent or white b.Outline.Transparency=1-opacity b.Outline.Thickness=adminButton and not editing and 1 or 2
  artwork[action]:SetOpacity(opacity)
 end
 local touchGui=player.PlayerGui:FindFirstChild("TouchGui")
 local jump=touchGui and touchGui:FindFirstChild("JumpButton",true)
 if jump~=nativeJump then nativeJump=jump oldJumpVisible=nil end
 if nativeJump then
  if show and not freecam then if oldJumpVisible==nil then oldJumpVisible=nativeJump.Visible end nativeJump.Visible=false
  elseif oldJumpVisible~=nil then nativeJump.Visible=oldJumpVisible oldJumpVisible=nil end
 end
end)
player:SetAttribute("HUDLayoutEditing",false)


for _,v in panel:GetDescendants() do if v:IsA("GuiObject") then v:SetAttribute("CascadeDecoration",true) end end

for _,v in toolbar:GetDescendants() do if v:IsA("GuiObject") then v:SetAttribute("CascadeDecoration",true) end end
