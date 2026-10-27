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
local gui=Instance.new("ScreenGui") gui.Name="MobileCombatHUD" gui.ResetOnSpawn=false gui.DisplayOrder=72 gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets gui.Parent=player:WaitForChild("PlayerGui")
local surface=Instance.new("Frame") surface.Name="Controls" surface.Size=UDim2.fromScale(1,1) surface.BackgroundTransparency=1 surface.Parent=gui
local editor=Instance.new("Frame") editor.Name="Editor" editor.Size=UDim2.fromScale(1,1) editor.BackgroundColor3=Color3.fromRGB(5,15,25) editor.BackgroundTransparency=.5 editor.Visible=false editor.Active=true editor.Parent=gui
local editing=false local draft local selected="Fire" local drag local active={} local aimToggle=false
local buttons={} local fields={} local nativeJump local oldJumpVisible
local function round(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=p end
local function label(p,name,text,x,y,w,h,size)
 local t=Instance.new("TextLabel") t.Name=name t.Text=text t.Position=UDim2.fromOffset(x,y) t.Size=UDim2.fromOffset(w,h) t.BackgroundTransparency=1 t.TextColor3=white t.Font=Enum.Font.GothamMedium t.TextSize=size or 14 t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=p return t
end
local function button(p,name,text,x,y,w,h)
 local b=Instance.new("TextButton") b.Name=name b.Text=text b.Position=UDim2.fromOffset(x,y) b.Size=UDim2.fromOffset(w,h) b.BackgroundColor3=Color3.fromRGB(32,53,70) b.BorderSizePixel=0 b.TextColor3=white b.Font=Enum.Font.GothamBold b.TextSize=13 b.Parent=p round(b,8) return b
end
local function get(key) local v=player:GetAttribute("Setting"..key) return v==nil and Settings.Rules[key].Default or v end
local function cancelInputs()
 for action,input in active do Router:Dispatch(action,Enum.UserInputState.Cancel,input) end
 active={} aimToggle=false Router:Dispatch("Aim",Enum.UserInputState.Cancel)
end
local panel=Instance.new("Frame") panel.Name="Tools" panel.AnchorPoint=Vector2.new(0,1) panel.Position=UDim2.new(0,8,1,-8) panel.Size=UDim2.fromOffset(370,318) panel.BackgroundColor3=Color3.fromRGB(14,25,38) panel.BorderSizePixel=0 panel.Parent=editor round(panel,12)
local scale=Instance.new("UIScale") scale.Parent=panel
label(panel,"Title","EDITAR HUD MOBILE",14,8,340,26,19)
local name=label(panel,"Selected","",14,37,340,23)
label(panel,"Help","Arraste um botão ou edite os valores abaixo.",14,61,340,24,12)
local function refreshFields()
 if not editing then return end
 name.Text=Layout.Buttons[selected].Label
 for field,box in fields do if UIS:GetFocusedTextBox()~=box then box.Text=string.format("%.0f",draft[selected][field]*(field=="Size" and 1 or 100)) end end
end
local function change(field,value)
 if not editing then return end
 local clean=Settings:Sanitize(Layout.Key(selected,field),value)
 if clean~=nil then draft[selected][field]=clean refreshFields() end
end
for i,field in {"X","Y","Size","Opacity"} do
 local y=88+(i-1)*42
 local row=Instance.new("Frame") row.Name=field row.Position=UDim2.fromOffset(12,y) row.Size=UDim2.fromOffset(346,38) row.BackgroundTransparency=1 row.Parent=panel
 label(row,"Label",({X="Horizontal (%)",Y="Vertical (%)",Size="Tamanho",Opacity="Opacidade (%)"})[field],0,0,150,36,13)
 local minus=button(row,"Minus","−",155,0,38,36)
 local box=Instance.new("TextBox") box.Name="Value" box.ClearTextOnFocus=false box.Position=UDim2.fromOffset(198,0) box.Size=UDim2.fromOffset(100,36) box.BackgroundColor3=Color3.fromRGB(27,43,59) box.TextColor3=white box.Font=Enum.Font.GothamBold box.TextSize=15 box.Parent=row round(box,7) fields[field]=box
 local plus=button(row,"Plus","+",303,0,38,36)
 local factor=field=="Size" and 1 or 100
 box.Focused:Connect(function() task.defer(function() if UIS:GetFocusedTextBox()==box then box.CursorPosition=#box.Text+1 box.SelectionStart=1 end end) end)
 box.FocusLost:Connect(function() local v=tonumber((box.Text:gsub(",","."))) if v then change(field,v/factor) end refreshFields() end)
 local function adjust(d) change(field,draft[selected][field]+d*(field=="Size" and 2 or .01)) end
 Nav:Register(row,function() box:CaptureFocus() end,adjust)
 minus.Activated:Connect(function() adjust(-1) end) plus.Activated:Connect(function() adjust(1) end)
 local left=Icons:Glyph(minus,"DPad","DPadLeft",26) left.Position=UDim2.fromOffset(6,5) left.Visible=false
 local right=Icons:Glyph(plus,"DPad","DPadRight",26) right.Position=UDim2.fromOffset(6,5) right.Visible=false
 local function hints(focus) local on=editing and Mode:Get()==Enum.PreferredInput.Gamepad and focus==row left.Visible=on right.Visible=on minus.Text=on and "" or "−" plus.Text=on and "" or "+" end
 Nav.FocusChanged:Connect(hints) Mode.Changed:Connect(function() hints(Nav:GetFocus()) end)
end
local inspector=button(editor,"ToggleInspector","OCULTAR AJUSTES",8,8,174,34)
inspector.ZIndex=20
Nav:Connect(inspector,function() panel.Visible=not panel.Visible inspector.Text=panel.Visible and "OCULTAR AJUSTES" or "MOSTRAR AJUSTES" end)
local save=button(panel,"Save","SALVAR",12,268,108,36)
local cancel=button(panel,"Cancel","CANCELAR",130,268,108,36)
local reset=button(panel,"Reset","PADRÃO",248,268,108,36)
local function close(keep)
 if not editing then return end
 if keep then
  local values={}
  for action,fields in draft do for field,value in fields do local key=Layout.Key(action,field) player:SetAttribute("Setting"..key,value) values[key]=value end end
  update:FireServer("MobileHUDLayout",values)
 end
 editing=false drag=nil editor.Visible=false player:SetAttribute("HUDLayoutEditing",false)
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
 local symbol=label(b,"Symbol",data.Glyph,0,0,1,1,27) symbol.Size=UDim2.fromScale(1,.63) symbol.TextXAlignment=Enum.TextXAlignment.Center
 local title=label(b,"Label",data.Label,0,0,1,1,10) title.Size=UDim2.fromScale(1,.28) title.Position=UDim2.fromScale(0,.64) title.TextXAlignment=Enum.TextXAlignment.Center title.TextScaled=true
 local limit=Instance.new("UITextSizeConstraint") limit.MinTextSize=6 limit.MaxTextSize=11 limit.Parent=title
 buttons[action]=b
 local function select() selected=action refreshFields() end
 Nav:Register(b,select)
 b.InputBegan:Connect(function(input)
  if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
  if editing then select() drag={input=input,action=action,start=Vector2.new(input.Position.X,input.Position.Y),position=Vector2.new(draft[action].X,draft[action].Y)} return end
  if Router:IsBlocked() or active[action] then return end
  if action=="Aim" then aimToggle=not aimToggle Router:Dispatch(action,aimToggle and Enum.UserInputState.Begin or Enum.UserInputState.End,input)
  else active[action]=input Router:Dispatch(action,Enum.UserInputState.Begin,input) end
 end)
end
UIS.InputChanged:Connect(function(input)
 if not drag or not editing then return end
 if input~=drag.input and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
 local delta=Vector2.new(input.Position.X,input.Position.Y)-drag.start local size=editor.AbsoluteSize
 local d=draft[drag.action]
 d.X=Settings:Sanitize(Layout.Key(drag.action,"X"),drag.position.X+delta.X/math.max(size.X,1))
 d.Y=Settings:Sanitize(Layout.Key(drag.action,"Y"),drag.position.Y+delta.Y/math.max(size.Y,1))
 refreshFields()
end)
UIS.InputEnded:Connect(function(input)
 if drag and (input==drag.input or input.UserInputType==Enum.UserInputType.MouseButton1) then drag=nil end
 for action,held in active do if held==input then active[action]=nil Router:Dispatch(action,Enum.UserInputState.End,input) end end
end)
UIS.WindowFocusReleased:Connect(cancelInputs)
Scope.Changed:Connect(function() cancelInputs() if editing then close(false) end end)
Nav.MenuRequested:Connect(function(id)
 if id~="MobileHUD" then return end
 cancelInputs() draft={}
 for action in Layout.Buttons do draft[action]=Layout.Read(action,get) buttons[action].Parent=editor end
 panel.Visible=true inspector.Text="OCULTAR AJUSTES"
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
 local show=Scope:IsCombat() and Mode:Get()==Enum.PreferredInput.Touch and not Router:IsBlocked()
 if not show and next(active) or not show and aimToggle then cancelInputs() end
 surface.Visible=show
 scale.Scale=math.min(1,(editor.AbsoluteSize.Y-16)/318,(editor.AbsoluteSize.X-16)/370)
 for action,b in buttons do
  local data=editing and draft[action] or Layout.Read(action,get)
  local point,diameter=Layout.Pixels(data,(editing and editor or surface).AbsoluteSize)
  b.Position=UDim2.fromOffset(point.X,point.Y) b.Size=UDim2.fromOffset(diameter,diameter)
  -- Store the displayed normalized position for resolution-independent dragging.
  if editing and not drag then b.Position=UDim2.fromScale(point.X/math.max(editor.AbsoluteSize.X,1),point.Y/math.max(editor.AbsoluteSize.Y,1)) end
  b.Visible=editing or allowed(action,kind)
  local pressed=active[action]~=nil or action=="Aim" and aimToggle
  b.BackgroundColor3=pressed and Color3.fromRGB(36,119,136) or Color3.fromRGB(19,32,45)
  b.BackgroundTransparency=1-data.Opacity*.48
  b.Outline.Color=editing and selected==action and accent or white b.Outline.Transparency=1-data.Opacity
  b.Symbol.TextTransparency=1-data.Opacity b.Label.TextTransparency=1-data.Opacity
 end
 local touchGui=player.PlayerGui:FindFirstChild("TouchGui")
 local jump=touchGui and touchGui:FindFirstChild("JumpButton",true)
 if jump~=nativeJump then nativeJump=jump oldJumpVisible=nil end
 if nativeJump then
  if show then if oldJumpVisible==nil then oldJumpVisible=nativeJump.Visible end nativeJump.Visible=false
  elseif oldJumpVisible~=nil then nativeJump.Visible=oldJumpVisible oldJumpVisible=nil end
 end
end)
player:SetAttribute("HUDLayoutEditing",false)
