-- Arena presentation only. Selection is delegated to the existing pending-loadout remote.
local View={}
local accent=Color3.fromRGB(37,213,235)
local white=Color3.fromRGB(239,245,249)
local muted=Color3.fromRGB(169,192,205)

local function object(class,name,parent)
 local v=Instance.new(class) v.Name=name
 if v:IsA("GuiObject") then v:SetAttribute("CascadeDecoration",true) v.BackgroundTransparency=1 v.BorderSizePixel=0 end
 v.Parent=parent return v
end
local function text(parent,name,value,size,bold)
 local t=object("TextLabel",name,parent) t.Text=value t.Font=bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
 t.TextColor3=white t.TextSize=size t.TextXAlignment=Enum.TextXAlignment.Left t.TextYAlignment=Enum.TextYAlignment.Center t.TextWrapped=true return t
end
local function round(v,r)
 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=v
end
local function edge(v,color,width,alpha)
 local s=Instance.new("UIStroke") s.Color=color s.Thickness=width s.Transparency=alpha s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=v return s
end
local function surface(v)
 v.BackgroundColor3=Color3.fromRGB(16,22,29) v.BackgroundTransparency=.12 round(v,12) edge(v,Color3.fromRGB(129,155,174),1,.78)
 local tint=Instance.new("UIGradient") tint.Color=ColorSequence.new(Color3.fromRGB(126,159,190),Color3.fromRGB(33,39,47)) tint.Rotation=55 tint.Parent=v
end

function View.new(parent,config)
 local player,nav,definitions=config.Player,config.Navigation,config.Definitions
 local assets=game.ReplicatedStorage.Crossgrounds:FindFirstChild("LoadoutPreviews")
 local originalParentSize=parent.Size
 local root=object("Frame","ArenaLoadout",parent) root.Size=UDim2.new(1,-8,0,500)
 local connections={} local cameras={} local rows={} local focusedId local previewId local dead=false
 local function hook(signal,callback) local c=signal:Connect(callback) table.insert(connections,c) return c end
 local function cleanup() if dead then return end dead=true for _,c in connections do c:Disconnect() end table.clear(cameras) if parent.Parent then parent.Size=originalParentSize end end
 root.Destroying:Connect(cleanup)
 local self={Root=root}
 function self:Destroy() cleanup() if root.Parent then root:Destroy() end end
 local function scale()
  local at=parent
  while at do local s=at:FindFirstChild("PreferenceScale") if s and s:IsA("UIScale") then return s.Scale end at=at.Parent end
  return 1
 end
 local function fit(record)
  if not record.Model or record.Frame.AbsoluteSize.Y<1 then return end
  local cf,size=record.Model:GetBoundingBox()
  local direction=record.Melee and Vector3.new(.12,.1,1).Unit or Vector3.new(-1,.20,.46).Unit
  local basis=CFrame.lookAt(Vector3.zero,-direction)
  local tangent=math.tan(math.rad(record.Camera.FieldOfView*.5))
  local aspect=math.max(.1,record.Frame.AbsoluteSize.X/math.max(1,record.Frame.AbsoluteSize.Y))
  local distance=0
  for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
   local p=basis:VectorToObjectSpace(cf:PointToWorldSpace(size*Vector3.new(x,y,z)*.5)-cf.Position)
   distance=math.max(distance,math.abs(p.X)/(tangent*aspect)+p.Z,math.abs(p.Y)/tangent+p.Z)
  end end end
  record.Camera.CFrame=CFrame.lookAt(cf.Position+direction*math.max(.5,distance*1.13),cf.Position)
 end
 local function viewport(holder,name,assetName,melee)
  local frame=object("ViewportFrame",name,holder) frame.Ambient=Color3.fromRGB(161,178,192) frame.LightColor=Color3.fromRGB(255,246,231) frame.LightDirection=Vector3.new(-1,-2,-3)
  local camera=Instance.new("Camera") camera.FieldOfView=32 camera.Parent=frame frame.CurrentCamera=camera
  local world=Instance.new("WorldModel") world.Parent=frame
  local record={Frame=frame,Camera=camera,World=world,Melee=melee}
  local function setAsset(id)
   world:ClearAllChildren() record.Model=nil
   local template=assets and assets:FindFirstChild(id)
   if template then
    local model=template:Clone() model.Parent=world
    if melee then model:PivotTo(CFrame.Angles(0,0,math.rad(-28))*model:GetPivot()) end
    record.Model=model fit(record)
   end
   frame:SetAttribute("PreviewAsset",id)
  end
  record.SetAsset=setAsset table.insert(cameras,record)
  hook(frame:GetPropertyChangedSignal("AbsoluteSize"),function() fit(record) end)
  setAsset(assetName) return record
 end
 local notice=text(root,"Notice","Escolha seu equipamento. A seleção entra em vigor somente no próximo nascimento.",13,false)
 notice.TextColor3=muted notice.Size=UDim2.new(1,0,0,32)
 local body=object("Frame","Body",root)
 local grid=object("ScrollingFrame","Loadouts",body) grid.ScrollBarThickness=3 grid.ScrollBarImageColor3=accent grid.CanvasSize=UDim2.new() grid.AutomaticCanvasSize=Enum.AutomaticSize.Y
 local padding=Instance.new("UIPadding") padding.PaddingLeft=UDim.new(0,7) padding.PaddingTop=UDim.new(0,7) padding.PaddingBottom=UDim.new(0,7) padding.PaddingRight=UDim.new(0,7) padding.Parent=grid
 local layout=Instance.new("UIGridLayout") layout.FillDirectionMaxCells=2 layout.SortOrder=Enum.SortOrder.LayoutOrder layout.CellPadding=UDim2.fromOffset(12,12) layout.Parent=grid
 local preview=object("Frame","EquipmentPreview",body) surface(preview)
 local number=text(preview,"Number","1",20,true) number.Position=UDim2.fromOffset(18,18) number.Size=UDim2.fromOffset(36,36) number.TextXAlignment=Enum.TextXAlignment.Center number.BackgroundColor3=Color3.fromRGB(53,69,82) number.BackgroundTransparency=.15 round(number,8)
 local caption=text(preview,"LoadoutName","LOADOUT 1",12,true) caption.Position=UDim2.fromOffset(66,16) caption.Size=UDim2.new(1,-82,0,24) caption.TextColor3=muted
 local weaponName=text(preview,"WeaponName","",28,true) weaponName.Position=UDim2.fromOffset(66,40) weaponName.Size=UDim2.new(1,-82,0,40)
 local kind=text(preview,"WeaponClass","PISTOLA",11,false) kind.Position=UDim2.fromOffset(20,86) kind.Size=UDim2.fromOffset(90,22) kind.TextColor3=muted
 local large=viewport(preview,"PrimaryModel",config.Loadouts[1].id,false)
 local melee=object("Frame","Melee",preview) surface(melee)
 local meleeView=viewport(melee,"ExecutorModel","Sword",true)
 local meleeClass=text(melee,"Class","CORPO A CORPO",10,false) meleeClass.TextColor3=muted meleeClass.Position=UDim2.fromOffset(14,10) meleeClass.Size=UDim2.new(.55,-14,0,20)
 local meleeName=text(melee,"Name","Executor",19,true) meleeName.Position=UDim2.fromOffset(14,30) meleeName.Size=UDim2.new(.55,-14,0,26)
 local meleeNote=text(melee,"Description","Equipamento corpo a corpo do loadout.",11,false) meleeNote.TextColor3=muted meleeNote.Position=UDim2.fromOffset(14,58) meleeNote.Size=UDim2.new(.55,-14,1,-64)
 meleeView.Frame.Position=UDim2.fromScale(.56,.08) meleeView.Frame.Size=UDim2.fromScale(.42,.84)
 local function show(entry)
  focusedId=entry.id
  if previewId==entry.id then return end previewId=entry.id
  number.Text=tostring(entry.number) caption.Text="LOADOUT "..entry.number weaponName.Text=entry.primary kind.Text=entry.class large.SetAsset(entry.id)
  preview:SetAttribute("LoadoutId",entry.id)
 end
 for i,entry in config.Loadouts do
  local b=object("TextButton",entry.id,grid) b.Text="" b.AutoButtonColor=false b.LayoutOrder=i b:SetAttribute("LoadoutId",entry.id) b:SetAttribute("AccessibleLabel",entry.primary.." e Executor, corpo a corpo") surface(b)
  local selectedEdge=edge(b,accent,2.5,1) local glow=edge(b,accent,7,1)
  local model=viewport(b,"WeaponModel",entry.id,false) model.Frame.Position=UDim2.fromScale(.30,.04) model.Frame.Size=UDim2.fromScale(.68,.68)
  local badge=text(b,"Number",tostring(entry.number),16,true) badge.Position=UDim2.fromOffset(12,10) badge.Size=UDim2.fromOffset(28,28) badge.TextXAlignment=Enum.TextXAlignment.Center badge.BackgroundColor3=Color3.fromRGB(54,66,80) badge.BackgroundTransparency=.16 round(badge,7)
  local class=text(b,"Class",entry.class,10,false) class.Position=UDim2.new(0,12,.44,0) class.Size=UDim2.new(1,-24,0,16) class.TextColor3=muted
  local name=text(b,"WeaponName",entry.primary,18,true) name.Position=UDim2.new(0,12,.59,0) name.Size=UDim2.new(1,-24,0,24)
  local secondary=text(b,"Melee","Executor · corpo a corpo",11,false) secondary.Position=UDim2.new(0,12,1,-25) secondary.Size=UDim2.new(1,-24,0,18) secondary.TextColor3=muted
  rows[i]={Button=b,Entry=entry,Edge=selectedEdge,Glow=glow,Name=name}
  nav:Connect(b,function() show(entry) config.Select(entry.id) end)
 end
 for i,row in rows do
  row.Button.NextSelectionUp=rows[i-2] and rows[i-2].Button or row.Button
  row.Button.NextSelectionDown=rows[i+2] and rows[i+2].Button or row.Button
  if i%2==0 then row.Button.NextSelectionLeft=rows[i-1].Button elseif rows[i+1] then row.Button.NextSelectionRight=rows[i+1].Button end
 end
 local function selected()
  return player:GetAttribute(definitions.PendingAttribute("arena")) or player:GetAttribute(definitions.ActiveAttribute("arena")) or config.Loadouts[1].id
 end
 local function refresh()
  local id=selected() local pending=player:GetAttribute(definitions.PendingAttribute("arena"))
  for _,row in rows do
   local on=row.Entry.id==id row.Edge.Transparency=on and .04 or 1 row.Glow.Transparency=on and .85 or 1
   row.Button:SetAttribute("MenuSelected",on)
   if on and not focusedId then show(row.Entry) end
  end
  notice.Text=pending and "Loadout agendado para o próximo nascimento. O equipamento desta vida foi preservado." or "Escolha seu equipamento. A seleção entra em vigor somente no próximo nascimento."
 end
 function self:DefaultFocus()
  for _,row in rows do if row.Entry.id==selected() then return row.Button end end return rows[1].Button
 end
 hook(player:GetAttributeChangedSignal(definitions.PendingAttribute("arena")),refresh)
 hook(player:GetAttributeChangedSignal(definitions.ActiveAttribute("arena")),refresh)
 hook(nav.FocusChanged,function(focus) for _,row in rows do if row.Button==focus then show(row.Entry) break end end end)
 local function reflow()
  if dead or not root.Parent then return end
  local s=scale() local width=math.max(220,parent.AbsoluteSize.X/s-8)
  local height=parent.Parent.AbsoluteSize.Y/s-parent.Position.Y.Offset-8
  local admin=player.PlayerGui:FindFirstChild("AdminCameraHelp") local hint=admin and admin:FindFirstChildWhichIsA("TextLabel")
  if admin and admin.Enabled and hint and hint.Visible then height=math.min(height,(hint.AbsolutePosition.Y-parent.AbsolutePosition.Y)/s-12) end
  height=math.max(100,height)
  parent.Size=UDim2.new(originalParentSize.X.Scale,originalParentSize.X.Offset,0,height)
  local available=math.max(100,height-4)
  local stacked=width<780 local fontScale=player:GetAttribute("SettingFontScale") or 1
  local noticeHeight=fontScale>1.15 and 48 or 34
  local gap=14 local cardHeight=math.clamp((available-noticeHeight-38)/3,116,174)
  local gridHeight=cardHeight*3+24+14
  local previewHeight=stacked and math.max(340,math.min(420,width*.6)) or math.max(350,available-noticeHeight)
  local gridWidth=stacked and width or math.floor((width-gap)*.53)
  root.Size=UDim2.new(1,-8,0,stacked and noticeHeight+gridHeight+gap+previewHeight or math.max(available,noticeHeight+previewHeight))
  notice.Size=UDim2.new(1,0,0,noticeHeight-2) body.Position=UDim2.fromOffset(0,noticeHeight) body.Size=UDim2.new(1,0,1,-noticeHeight)
  grid.Size=UDim2.fromOffset(gridWidth,stacked and gridHeight or available-noticeHeight)
  layout.CellSize=UDim2.fromOffset(math.floor((gridWidth-26)/2),cardHeight)
  preview.Position=stacked and UDim2.fromOffset(0,gridHeight+gap) or UDim2.fromOffset(gridWidth+gap,0)
  preview.Size=UDim2.fromOffset(stacked and width or width-gridWidth-gap,previewHeight)
  weaponName.TextSize=width<500 and 23 or 28
  for _,row in rows do row.Name.TextSize=width<500 and 14 or 18 end
  local meleeHeight=math.clamp(previewHeight*.27,104,142)
  melee.Position=UDim2.new(0,10,1,-meleeHeight-10) melee.Size=UDim2.new(1,-20,0,meleeHeight)
  large.Frame.Position=UDim2.fromOffset(12,110) large.Frame.Size=UDim2.new(1,-24,1,-meleeHeight-128)
  for _,record in cameras do fit(record) end
 end
 hook(parent:GetPropertyChangedSignal("AbsoluteSize"),reflow)
 hook(root:GetPropertyChangedSignal("AbsoluteSize"),reflow)
 hook(player:GetAttributeChangedSignal("SettingMenuScale"),reflow)
 hook(player:GetAttributeChangedSignal("SettingFontScale"),reflow)
 hook(player:GetAttributeChangedSignal("CrossgroundsAdmin"),reflow)
 refresh() reflow() return self
end
return View

