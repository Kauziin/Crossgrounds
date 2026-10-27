from pathlib import Path
root=Path(__file__).resolve().parents[1]
base=root/'artifacts/mobile-hud-2026-10-27/current'
out=root/'artifacts/mobile-hud-2026-10-27/after'
out.mkdir(exist_ok=True)
s=(base/'MobileHUD.luau').read_text(encoding='utf-8')
s=s.replace('local editing=false local draft local selected="Fire"','local editing=false local draft local selected')
s=s.replace('local buttons={} local fields={}', 'local Art=require(script.Parent:WaitForChild("TouchActionIcons"))\nlocal buttons={} local artwork={} local fields={}')
s=s.replace('t.Parent=p return t','t:SetAttribute("CascadeDecoration",true) t.Parent=p return t').replace('b.Parent=p round(b,8)','b:SetAttribute("CascadeDecoration",true) b.Parent=p round(b,8)')
s=s.replace('gui.Parent=player:WaitForChild("PlayerGui")','gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=player:WaitForChild("PlayerGui")')
start=s.index('local panel=Instance.new')
end=s.index('local function close(keep)')
s=s[:start]+'''-- Properties live independently of the persistent save/cancel toolbar.
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
''' +s[end:]
s=s.replace('player:SetAttribute("Setting"..key,value) values[key]=value','value=Settings:Sanitize(key,value) player:SetAttribute("Setting"..key,value) values[key]=value')
s=s.replace('editing=false drag=nil editor.Visible=false','editing=false selected=nil drag=nil panel.Visible=false editor.Visible=false')
a=s.index(' local symbol=label(b,"Symbol"')
b=s.index(' buttons[action]=b',a)
s=s[:a]+' b.ZIndex=5 b:SetAttribute("AccessibleLabel",data.Label) artwork[action]=Art.Create(b,action)\n'+s[b:]
s=s.replace('position=Vector2.new(draft[action].X,draft[action].Y)','position=b.AbsolutePosition+b.AbsoluteSize/2-editor.AbsolutePosition')
a=s.index(' local delta=Vector2.new(input.Position.X,input.Position.Y)-drag.start')
b=s.index('\n refreshFields()',a)
s=s[:a]+''' if input.UserInputType==Enum.UserInputType.MouseMovement and drag.input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
 local delta=Vector2.new(input.Position.X,input.Position.Y)-drag.start
 move(drag.action,drag.position+delta)'''+s[b:]
s=s.replace('input==drag.input or input.UserInputType==Enum.UserInputType.MouseButton1','input==drag.input or input.UserInputType==Enum.UserInputType.MouseButton1 and drag.input.UserInputType==Enum.UserInputType.MouseButton1')
s=s.replace('UIS.WindowFocusReleased:Connect(cancelInputs)','UIS.WindowFocusReleased:Connect(function() drag=nil cancelInputs() end)')
s=s.replace('drag=nil cancelInputs() end)', 'drag=nil gamepadDrag=nil cancelInputs() end)')
s=s.replace(' panel.Visible=true inspector.Text="OCULTAR AJUSTES"',' selected=nil panel.Visible=false')
s=s.replace(' scale.Scale=math.min(1,(editor.AbsoluteSize.Y-16)/318,(editor.AbsoluteSize.X-16)/370)',' if editing then positionPanel() end')
s=s.replace('  b.BackgroundTransparency=1-data.Opacity*.48','  local opacity=data.Opacity*(adminButton and not editing and not pressed and .55 or 1)\n  b.BackgroundTransparency=1-opacity*(adminButton and .24 or .48)')
s=s.replace('b.Outline.Transparency=1-data.Opacity','b.Outline.Transparency=1-opacity b.Outline.Thickness=adminButton and not editing and 1 or 2')
s=s.replace('  b.Symbol.TextTransparency=1-data.Opacity b.Label.TextTransparency=1-data.Opacity','  artwork[action]:SetOpacity(opacity)')
s=s.replace('b.Position=UDim2.fromOffset(point.X,point.Y)', 'b.Position=UDim2.fromScale(point.X/math.max((editing and editor or surface).AbsoluteSize.X,1),point.Y/math.max((editing and editor or surface).AbsoluteSize.Y,1))')
# Keep gamepad cursor movement as the positioning gesture; A continues to activate other controls.
a=s.index('UIS.InputChanged:Connect')
s=s[:a]+'''local gamepadDrag
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
''' +s[a:]
s=s.replace(' if editing then positionPanel() end',''' if editing then
  if gamepadDrag then
   local cursor=player:GetAttribute("MenuCursorPosition")
   if cursor and gamepadDrag.cursor then move(gamepadDrag.action,gamepadDrag.position+cursor-gamepadDrag.cursor) end
  end
  positionPanel()
 end''')
s=s.replace('editing=false selected=nil drag=nil','editing=false selected=nil gamepadDrag=nil drag=nil')
# gamepadDrag must be in lexical scope of close.
s=s.replace('local buttons={} local artwork={}', 'local gamepadDrag\nlocal buttons={} local artwork={}')
s=s.replace('\nlocal gamepadDrag\ngame:GetService', '\ngame:GetService')
for obj in ['panel','toolbar']:
 s+=f'\nfor _,v in {obj}:GetDescendants() do if v:IsA("GuiObject") then v:SetAttribute("CascadeDecoration",true) end end\n'
(out/'MobileHUD.luau').write_text(s,encoding='utf-8')
s=(base/'MobileLayout.luau').read_text(encoding='utf-8')
a=s.index('function Layout.Pixels')
s=s[:a]+'''function Layout.ClampPoint(point,diameter,viewport)
 local half=diameter*.5+2
 return Vector2.new(math.clamp(point.X,half,math.max(half,viewport.X-half)),math.clamp(point.Y,half,math.max(half,viewport.Y-half)))
end
function Layout.Pixels(layout,viewport)
 local diameter=math.clamp(math.min(viewport.X/900,viewport.Y/480),.72,1.5)*layout.Size
 return Layout.ClampPoint(Vector2.new(viewport.X*layout.X,viewport.Y*layout.Y),diameter,viewport),diameter
end
return Layout
'''
(out/'MobileLayout.luau').write_text(s,encoding='utf-8')
s=(base/'ExperienceSettings.luau').read_text(encoding='utf-8').replace('or {.04,.96}','or {0,1}').replace('Step=field=="Size" and 1 or .01','Step=field=="Size" and 1 or field=="Opacity" and .01 or .0001')
(out/'ExperienceSettings.luau').write_text(s,encoding='utf-8')
s=(base/'AdminCameraController.luau').read_text(encoding='utf-8')
a=s.index('local help=Instance.new')
b=s.index('local function hideGui',a)
s=s[:a]+'''local help=Instance.new("TextLabel") help.AnchorPoint=Vector2.new(1,1) help.Position=UDim2.new(1,-12,1,-12)
help.Size=UDim2.fromOffset(210,26) help.BackgroundColor3=Color3.fromRGB(18,27,37) help.BackgroundTransparency=.6
help.TextColor3=Color3.fromRGB(181,199,208) help.TextSize=11 help.TextWrapped=true help.Font=Enum.Font.GothamMedium help.Parent=gui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,8) corner.Parent=help
local function hint(message)
 gui.Enabled=player:GetAttribute("CrossgroundsAdmin")==true and not clean and not player:GetAttribute("HUDLayoutEditing")
 local width=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 800
 help.Size=UDim2.fromOffset(math.min(width-24,message and 300 or active and 300 or 210),message and 48 or active and 42 or 26)
 help.Text=message or (active and ("Espectador · "..math.floor(speed).." studs/s\\n"..adminKey("AdminClean").." captura · "..adminKey().." sair") or "Admin · "..adminKey().." espectador")
end
player:GetAttributeChangedSignal("HUDLayoutEditing"):Connect(function() hint() end)
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() hint() end) end
''' +s[b:]
(out/'AdminCameraController.luau').write_text(s,encoding='utf-8')
print('Prepared four targeted sources')
