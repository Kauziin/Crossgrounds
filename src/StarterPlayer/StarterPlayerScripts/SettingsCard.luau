-- One navigation target per setting; pointer subcontrols never register focus.
local Card={}
local UIS=game:GetService("UserInputService")
local Theme=require(script.Parent:WaitForChild("MenuTheme")) local C=Theme.Settings
local Visual=require(script.Parent:WaitForChild("SettingsVisual"))
local function round(f,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=f end
local function label(p,name,size)
 local t=Instance.new("TextLabel") t.Name=name t:SetAttribute("SettingsStyled",true) t.BackgroundTransparency=1 t.Font=Enum.Font.GothamMedium t.TextSize=size t.TextColor3=C.Text t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=p return t
end
local function button(p,name,text)
 local b=Instance.new("TextButton") b.Name=name b:SetAttribute("SettingsStyled",true) b.Text=text b.BackgroundTransparency=1 b.Font=Enum.Font.GothamBold b.TextSize=19 b.TextColor3=C.Text b.Parent=p return b
end
function Card.new(parent,key,config)
 local rule=config.Settings.Rules[key] local numeric=rule.Min~=nil local Nav=config.Nav local Preferences=config.Preferences
 local row=Instance.new("Frame") row.Name=key row:SetAttribute("SettingsStyled",true) row:SetAttribute("SettingsCard",true) row.BackgroundColor3=C.Card row.BackgroundTransparency=.08 row.BorderSizePixel=0 round(row,13) row.Parent=parent
 local stroke=Instance.new("UIStroke") stroke.Color=C.Border stroke.Transparency=.55 stroke.Parent=row
 local icon=Visual.Icon(row,key:find("Stick") and (key:find("Curve") and "curve" or "target") or rule.Category=="Audio" and "audio" or "gear",30)
 local name=label(row,"Label",16) name.Text=rule.Label name.Font=Enum.Font.GothamBold name.TextWrapped=true
 local description=label(row,"Description",12) description.TextColor3=C.Muted description.TextWrapped=true
 local divider=Instance.new("Frame") divider:SetAttribute("SettingsStyled",true) divider.BackgroundColor3=C.Accent divider.BackgroundTransparency=.6 divider.BorderSizePixel=0 divider.Parent=row
 local value=Instance.new(numeric and "TextBox" or "TextButton") value.Name="Value" value:SetAttribute("SettingsStyled",true) value.BackgroundColor3=C.Surface value.BorderSizePixel=0 value.Font=Enum.Font.GothamBold value.TextWrapped=true value.TextSize=16 value.TextColor3=C.Text value.Parent=row round(value,9)
 if numeric then value.ClearTextOnFocus=false value.TextEditable=false end
 local left=button(row,"Previous","<") local right=button(row,"Next",">")
 local reset=button(row,"Default","")
 local resetIcon=Visual.Icon(reset,"reset",22) resetIcon.Position=UDim2.new(.5,-11,.5,-11) reset:SetAttribute("AccessibleLabel","Restaurar "..rule.Label.." ao padrão")
 local inherit=button(row,"Inheritance","") inherit.TextSize=11 inherit.TextColor3=C.Muted
 local slider,fill,thumb
 if numeric then
  slider=button(row,"Slider","") slider.Active=true
  local track=Instance.new("Frame") track.Name="Track" track:SetAttribute("SettingsStyled",true) track.BackgroundColor3=C.Track track.BorderSizePixel=0 track.Position=UDim2.new(0,0,.5,-4) track.Size=UDim2.new(1,0,0,8) track.Parent=slider round(track,5)
  fill=track:Clone() fill.Name="Fill" fill.BackgroundColor3=C.Accent fill.Position=UDim2.new() fill.Size=UDim2.fromScale(0,1) fill.Parent=track
  thumb=Instance.new("Frame") thumb:SetAttribute("SettingsStyled",true) thumb.BackgroundColor3=C.Accent thumb.BorderSizePixel=0 thumb.Size=UDim2.fromOffset(19,19) thumb.AnchorPoint=Vector2.new(.5,.5) thumb.Parent=track round(thumb,10)
 end
 local connections={} local function hook(signal,fn) table.insert(connections,signal:Connect(fn)) end
 local factor=(rule.Percent or table.find({"MenuVolume","MenuSFXVolume","DamageFlash","CameraMotion"},key)) and 100 or 1
 local read=function() return Preferences:Value(key,config.Context(key)) end
 local editing=false local function refresh()
  local v,custom,scope=read()
  if not editing then value.Text=numeric and string.format(factor==100 and "%.0f %%" or "%.2f",v*factor) or config.Settings:Format(key,v) end
  if fill then local ratio=math.clamp((v-rule.Min)/(rule.Max-rule.Min),0,1) fill.Size=UDim2.fromScale(ratio,1) thumb.Position=UDim2.fromScale(ratio,.5) end
  local mode=scope:match("^Mode:")~=nil
  inherit.Visible=mode inherit.Text=custom and "Herdar Global" or "Personalizar neste modo"
  description.Text=(Visual.Help[key] or (numeric and "Ajuste o valor conforme sua preferência." or "Escolha o comportamento desta opção."))..(mode and (custom and " · Personalizado" or " · Global herdado") or "")
 end
 local function adjust(step)
  local v=read()
  if numeric then v+=step*rule.Step elseif rule.Choices then local index=table.find(rule.Choices,v) or 1 v=rule.Choices[(index-1+step)%#rule.Choices+1] else v=not v end
  v=config.Settings:Sanitize(key,v) if v~=read() then Nav:PlaySound("Step") config.Commit(key,v) end refresh()
 end
 local function custom()
  if not numeric then return end
  editing=true value.TextEditable=true value.Text=tostring(read()*factor) value:CaptureFocus()
  task.defer(function() if value.Parent then value.CursorPosition=#value.Text+1 value.SelectionStart=1 end end)
 end
 local function restore() Preferences:Edit(key,config.Context(key),nil,"default") refresh() end
 local function inheritance()
  local v,customized=read() Preferences:Edit(key,config.Context(key),v,customized and "inherit" or "set") refresh()
 end
 Nav:Register(row,function() local _,_,scope=read() if scope:match("^Mode:") then inheritance() elseif numeric then custom() else adjust(1) end end,adjust)
 Nav:SetActions(row,{custom=numeric and custom or nil,reset=restore})
 hook(left.Activated,function() Nav:Focus(row,false) adjust(-1) end) hook(right.Activated,function() Nav:Focus(row,false) adjust(1) end)
 hook(inherit.Activated,inheritance)
 hook(reset.Activated,function() Nav:Focus(row,false) restore() end)
 if numeric then
  hook(value.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then custom() end end)
  hook(value.FocusLost,function(enter)
   local number=tonumber((value.Text:gsub(",","."))) editing=false value.TextEditable=false
   if enter and number and number==number and math.abs(number)<math.huge then config.Commit(key,config.Settings:Sanitize(key,number/factor)) end
   refresh() Nav:Focus(row,false)
  end)
  local dragging
  local function drag(input)
   if slider.AbsoluteSize.X<=0 then return end
   local a=math.clamp((input.Position.X-slider.AbsolutePosition.X)/slider.AbsoluteSize.X,0,1)
   config.Commit(key,config.Settings:Sanitize(key,rule.Min+a*(rule.Max-rule.Min))) refresh()
  end
  hook(slider.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=i Nav:Focus(row,false) drag(i) end end)
  hook(UIS.InputChanged,function(i) if dragging and (i==dragging or i.UserInputType==Enum.UserInputType.MouseMovement) then drag(i) end end)
  hook(UIS.InputEnded,function(i) if i==dragging then dragging=nil end end)
 else hook(value.Activated,function() Nav:Focus(row,false) adjust(1) end) end
 local function layout()
  local scale=config.Scale() local w=row.AbsoluteSize.X/math.max(.1,scale) local narrow=w<570
  local x=narrow and 16 or math.floor(w*.51) local y=narrow and 86 or 18
  local textWidth=narrow and w-80 or x-84
  local fontScale=game.Players.LocalPlayer:GetAttribute("SettingFontScale") or 1
  local titleHeight=math.max(24,game:GetService("TextService"):GetTextSize(rule.Label,name.TextSize,name.Font,Vector2.new(math.max(50,textWidth),1000)).Y+2)
  local descHeight=math.max(28,game:GetService("TextService"):GetTextSize(description.Text,description.TextSize,description.Font,Vector2.new(math.max(50,textWidth),1000)).Y+2)
  if narrow then y=math.max(80,20+titleHeight+descHeight) end
  local tiny=w<260
  local h=math.max(82,20+titleHeight+descHeight+(narrow and 58 or 0))+(inherit.Visible and 24 or 0)+(tiny and numeric and 44 or 0)
  row.Size=UDim2.new(1,-6,0,h) icon.Position=UDim2.fromOffset(14,19)
  name.Position=UDim2.fromOffset(58,12) name.Size=UDim2.fromOffset(textWidth,titleHeight)
  description.Position=UDim2.fromOffset(58,14+titleHeight) description.Size=UDim2.fromOffset(textWidth,descHeight)
  divider.Visible=not narrow divider.Position=UDim2.fromOffset(x-12,15) divider.Size=UDim2.fromOffset(1,h-30)
  local available=math.max(40,w-x-60)
  reset.Position=UDim2.fromOffset(w-48,y) reset.Size=UDim2.fromOffset(36,44)
  left.Visible=not numeric right.Visible=not numeric
  if numeric then
   slider.Position=UDim2.fromOffset(x+8,y) slider.Size=UDim2.fromOffset(math.max(48,available-100),44)
   value.Position=UDim2.fromOffset(w-130,y) value.Size=UDim2.fromOffset(72,44)
   if tiny then slider.Size=UDim2.fromOffset(math.max(48,w-48),44) value.Position=UDim2.fromOffset(16,y+44) value.Size=UDim2.fromOffset(w-76,40) reset.Position=UDim2.fromOffset(w-48,y+44) end
  else
   value.Position=UDim2.fromOffset(x,y) value.Size=UDim2.fromOffset(available,44) value.TextSize=narrow and 11 or 14
   local vp=value:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding") vp.PaddingLeft=UDim.new(0,32) vp.PaddingRight=UDim.new(0,32) vp.Parent=value
   left.Position=UDim2.fromOffset(x,y) left.Size=UDim2.fromOffset(34,44) left.ZIndex=2
   right.Position=UDim2.fromOffset(w-94,y) right.Size=UDim2.fromOffset(34,44) right.ZIndex=2
  end
  inherit.Position=UDim2.fromOffset(58,h-24) inherit.Size=UDim2.fromOffset(w-74,22)
 end
 hook(row:GetPropertyChangedSignal("AbsoluteSize"),layout) hook(description:GetPropertyChangedSignal("Text"),layout) hook(name:GetPropertyChangedSignal("TextSize"),layout) hook(description:GetPropertyChangedSignal("TextSize"),layout)
 hook(Preferences.Changed,function(changes) if not changes or changes[key] then refresh() layout() end end)
 hook(Nav.FocusChanged,function(focused) stroke.Color=focused==row and C.Accent or C.Border stroke.Transparency=focused==row and .1 or .55 end)
 row.Destroying:Connect(function() for _,c in connections do c:Disconnect() end end)
 refresh() layout() return row
end
return Card
