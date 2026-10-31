-- Shared Arena/CTF presentation. Selection is delegated to the existing pending-loadout remote.
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
 if config.Mode=="ctf" then return require(script.Parent.GunsmithView).new(parent,config) end
 local player,nav,definitions=config.Player,config.Navigation,config.Definitions
 local mode=config.Mode or "arena"
  config=table.clone(config) local visible={}
 for _,entry in config.Loadouts do if entry.class=="PISTOLA" then table.insert(visible,entry) end end
 if #visible>0 then config.Loadouts=visible end
 local function primaryAsset(entry) return entry.primaryAsset or entry.id end
 local assets=game.ReplicatedStorage.Crossgrounds:FindFirstChild("LoadoutPreviews")
 local originalParentSize=parent.Size
 local root=object("Frame",mode=="arena" and "ArenaLoadout" or "CTFLoadout",parent) root.Size=UDim2.new(1,-8,0,500)
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
  local fallback=text(holder,name.."Unavailable","Modelo indisponível",11,false) fallback.Visible=false fallback.Size=UDim2.new(1,0,0,24)
  local frame=object("ViewportFrame",name,holder) frame.Ambient=Color3.fromRGB(161,178,192) frame.LightColor=Color3.fromRGB(255,246,231) frame.LightDirection=Vector3.new(-1,-2,-3)
  local camera=Instance.new("Camera") camera.FieldOfView=32 camera.Parent=frame frame.CurrentCamera=camera
  local world=Instance.new("WorldModel") world.Parent=frame
  local record={Frame=frame,Camera=camera,World=world,Melee=melee}
  local function setAsset(id)
   if record.Model and frame:GetAttribute("PreviewAsset")==id then return end
   world:ClearAllChildren() record.Model=nil
   local template=assets and assets:FindFirstChild(id)
   if template then
    local model=template:Clone() model.Parent=world
    if melee then model:PivotTo(CFrame.Angles(0,0,math.rad(-28))*model:GetPivot()) end
    record.Model=model fit(record)
   end
   fallback.Visible=not record.Model
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
 local layout=Instance.new("UIGridLayout") layout.FillDirectionMaxCells=1 layout.SortOrder=Enum.SortOrder.LayoutOrder layout.CellPadding=UDim2.fromOffset(12,12) layout.Parent=grid
 local preview=object("Frame","EquipmentPreview",body) surface(preview)
 local details=object("Frame","LoadoutDetails",body) surface(details)
 local detailsTitle=text(details,"WeaponName","",24,true) detailsTitle.Position=UDim2.fromOffset(16,16) detailsTitle.Size=UDim2.new(1,-32,0,60)
 local detailsKind=text(details,"Category","PISTOLA",12,false) detailsKind.TextColor3=accent detailsKind.Position=UDim2.fromOffset(16,80) detailsKind.Size=UDim2.new(1,-32,0,24)
 local description=text(details,"Description","Loadout predefinido da Arena. Confirme na lista para usar esta pistola no próximo nascimento.",14,false) description.TextColor3=muted description.TextYAlignment=Enum.TextYAlignment.Top description.Position=UDim2.fromOffset(16,118) description.Size=UDim2.new(1,-32,0,104)
 local detailState=text(details,"SelectionStatus","",13,true) detailState.TextColor3=accent detailState.Position=UDim2.fromOffset(16,236) detailState.Size=UDim2.new(1,-32,0,110)
 local function stateText(id)
  local active=player:GetAttribute(definitions.ActiveAttribute(mode)) local pending=player:GetAttribute(definitions.PendingAttribute(mode))
  if id==active and id==pending then return "Equipado nesta vida · mantido para o próximo nascimento" end
  if id==pending then return "Agendado para o próximo nascimento" end
  if id==active then return "Equipado nesta vida" end
  return "Somente inspeção · A ou clique para selecionar"
 end
 local number=text(preview,"Number","1",20,true) number.Position=UDim2.fromOffset(18,18) number.Size=UDim2.fromOffset(36,36) number.TextXAlignment=Enum.TextXAlignment.Center number.BackgroundColor3=Color3.fromRGB(53,69,82) number.BackgroundTransparency=.15 round(number,8)
 local caption=text(preview,"LoadoutName","LOADOUT 1",12,true) caption.Position=UDim2.fromOffset(66,16) caption.Size=UDim2.new(1,-82,0,24) caption.TextColor3=muted
 local weaponName=text(preview,"WeaponName","",28,true) weaponName.Position=UDim2.fromOffset(66,40) weaponName.Size=UDim2.new(1,-82,0,40)
 local kind=text(preview,"WeaponClass","PISTOLA",11,false) kind.Position=UDim2.fromOffset(20,86) kind.Size=UDim2.fromOffset(90,22) kind.TextColor3=muted
 local large=viewport(preview,"PrimaryModel",primaryAsset(config.Loadouts[1]),false)
 local melee=object("Frame","Melee",preview) surface(melee)
 local meleeView=viewport(melee,"ExecutorModel","Sword",true)
 local meleeClass=text(melee,"Class","CORPO A CORPO",10,false) meleeClass.TextColor3=muted meleeClass.Position=UDim2.fromOffset(14,10) meleeClass.Size=UDim2.new(.55,-14,0,20)
 local meleeName=text(melee,"Name","Executor",19,true) meleeName.Position=UDim2.fromOffset(14,30) meleeName.Size=UDim2.new(.55,-14,0,26)
 local meleeNote=text(melee,"Description","Equipamento corpo a corpo do loadout.",11,false) meleeNote.TextColor3=muted meleeNote.Position=UDim2.fromOffset(14,58) meleeNote.Size=UDim2.new(.55,-14,1,-64)
 meleeView.Frame.Position=UDim2.fromScale(.56,.08) meleeView.Frame.Size=UDim2.fromScale(.42,.84)
 local function show(entry)
  focusedId=entry.id
  if previewId==entry.id then return end previewId=entry.id
  number.Text=tostring(entry.number) caption.Text="ARMA PRINCIPAL · LOADOUT "..entry.number weaponName.Text=entry.primary kind.Text=entry.class large.SetAsset(primaryAsset(entry))
  meleeView.SetAsset(entry.secondaryAsset or "Sword") meleeName.Text=entry.secondary meleeNote.Text="Equipamento corpo a corpo do loadout."
  detailsTitle.Text=entry.primary detailsKind.Text=entry.class detailState.Text=stateText(entry.id)
  preview:SetAttribute("LoadoutId",entry.id)
 end
 for i,entry in config.Loadouts do
  local b=object("TextButton",entry.id,grid) b.Text="" b.AutoButtonColor=false b.LayoutOrder=i b:SetAttribute("LoadoutId",entry.id) b:SetAttribute("AccessibleLabel",entry.primary.." e "..entry.secondary..", corpo a corpo") surface(b)
  local selectedEdge=edge(b,accent,2.5,1) local glow=edge(b,accent,7,1)
  local model=viewport(b,"WeaponModel",primaryAsset(entry),false) model.Frame.Position=UDim2.fromScale(.30,.04) model.Frame.Size=UDim2.fromScale(.68,.68)
  local badge=text(b,"Number",tostring(entry.number),16,true) badge.Position=UDim2.fromOffset(12,10) badge.Size=UDim2.fromOffset(28,28) badge.TextXAlignment=Enum.TextXAlignment.Center badge.BackgroundColor3=Color3.fromRGB(54,66,80) badge.BackgroundTransparency=.16 round(badge,7)
  local class=text(b,"Class",entry.class,10,false) class.Position=UDim2.new(0,12,.44,0) class.Size=UDim2.new(1,-24,0,16) class.TextColor3=muted
  local name=text(b,"WeaponName",entry.primary,18,true) name.Position=UDim2.new(0,12,.59,0) name.Size=UDim2.new(1,-24,0,24)
  local stateLabel=text(b,"SelectionState","",10,true) stateLabel.Position=UDim2.new(.35,0,0,10) stateLabel.Size=UDim2.new(.65,-12,0,24)
  local secondary=text(b,"Melee",entry.secondary.." · corpo a corpo",11,false) secondary.Position=UDim2.new(0,12,1,-25) secondary.Size=UDim2.new(1,-24,0,18) secondary.TextColor3=muted
  rows[i]={Button=b,Entry=entry,Edge=selectedEdge,Glow=glow,Name=name,State=stateLabel,Model=model.Frame,Badge=badge,Class=class,Melee=secondary}
   nav:Connect(b,function() show(entry) if os.clock()-(self.LastRequest or -1)<.2 then return end self.LastRequest=os.clock() config.Select(entry.id) end)
 end
 for i,row in rows do
  row.Button.NextSelectionUp=rows[i-1] and rows[i-1].Button or row.Button
  row.Button.NextSelectionDown=rows[i+1] and rows[i+1].Button or row.Button
  row.Button.NextSelectionLeft=row.Button row.Button.NextSelectionRight=row.Button
 end
 local function selected()
  return player:GetAttribute(definitions.PendingAttribute(mode)) or player:GetAttribute(definitions.ActiveAttribute(mode)) or config.Loadouts[1].id
 end
 local function refresh()
  local id=selected() local pending=player:GetAttribute(definitions.PendingAttribute(mode))
  local highContrast=player:GetAttribute("SettingHighContrast")==true
  for _,block in {preview,melee,details} do block.BackgroundTransparency=highContrast and 0 or .12 end
  for _,row in rows do
   row.State.Text=row.Entry.id==pending and (row.Entry.id==player:GetAttribute(definitions.ActiveAttribute(mode)) and "ATIVA · PRÓXIMA VIDA" or "PRÓXIMA VIDA") or row.Entry.id==player:GetAttribute(definitions.ActiveAttribute(mode)) and "ATIVA" or "PRESET"
   local on=row.Entry.id==id row.Button.BackgroundTransparency=highContrast and 0 or on and .02 or .16
   row.Button:SetAttribute("MenuSelected",on)
   if on and not focusedId then show(row.Entry) end
  end
  if focusedId then detailState.Text=stateText(focusedId) end
  notice.Text=pending and "Loadout agendado para o próximo nascimento. O equipamento desta vida foi preservado." or "Escolha seu equipamento. A seleção entra em vigor somente no próximo nascimento."
 end
 function self:DefaultFocus()
  for _,row in rows do if row.Entry.id==selected() then return row.Button end end return rows[1].Button
 end
 hook(player:GetAttributeChangedSignal(definitions.PendingAttribute(mode)),refresh)
 hook(player:GetAttributeChangedSignal(definitions.ActiveAttribute(mode)),refresh)
 hook(nav.FocusChanged,function(focus)
  for _,row in rows do local focused=row.Button==focus row.Edge.Transparency=focused and .04 or 1 row.Glow.Transparency=focused and .85 or 1 if focused then show(row.Entry) end end
 end)
 local function reflow()
  if dead or not root.Parent then return end
  local s=scale() local width=math.max(220,parent.AbsoluteSize.X/s-8)
  local height=parent.Parent.AbsoluteSize.Y/s-parent.Position.Y.Offset-8
  local admin=player.PlayerGui:FindFirstChild("AdminCameraHelp") local hint=admin and admin:FindFirstChildWhichIsA("TextLabel")
  if admin and admin.Enabled and hint and hint.Visible then height=math.min(height,(hint.AbsolutePosition.Y-parent.AbsolutePosition.Y)/s-12) end
  height=math.max(100,height)
  parent.Size=UDim2.new(originalParentSize.X.Scale,originalParentSize.X.Offset,0,height)
  local available=math.max(100,height-4)
  local threeColumns=width>=940 local compact=width<520
  local fontScale=player:GetAttribute("SettingFontScale") or 1
  local noticeHeight=fontScale>1.15 and 56 or 42 local gap=12
  local listWidth=math.clamp(width*.23,compact and 114 or 154,218)
  local detailWidth=threeColumns and math.clamp(width*.24,210,270) or 0
  local centerWidth=width-listWidth-gap-(threeColumns and detailWidth+gap or 0)
  local primaryHeight=math.max(compact and 230 or 280,available-noticeHeight-152)
  if not threeColumns then primaryHeight=math.min(primaryHeight,360) end
  local meleeHeight=128 local detailsHeight=threeColumns and primaryHeight+gap+meleeHeight or (fontScale>1.15 and 410 or 350)
  local total=noticeHeight+primaryHeight+gap+meleeHeight+(threeColumns and 0 or gap+detailsHeight)
  root.Size=UDim2.new(1,-8,0,math.max(total,noticeHeight+#rows*88))
  notice.Size=UDim2.new(1,0,0,noticeHeight-4) body.Position=UDim2.fromOffset(0,noticeHeight) body.Size=UDim2.new(1,0,1,-noticeHeight)
  grid.Position=UDim2.new() grid.Size=UDim2.fromOffset(listWidth,math.max(100,available-noticeHeight))
  layout.CellSize=UDim2.new(1,-14,0,compact and (fontScale>1.15 and 122 or 100) or (fontScale>1.15 and 104 or 80)) layout.CellPadding=UDim2.fromOffset(0,8)
  preview.Position=UDim2.fromOffset(listWidth+gap,0) preview.Size=UDim2.fromOffset(centerWidth,primaryHeight+gap+meleeHeight)
  details.Position=UDim2.fromOffset(threeColumns and listWidth+gap+centerWidth+gap or listWidth+gap,threeColumns and 0 or primaryHeight+gap+meleeHeight+gap)
  details.Size=UDim2.fromOffset(threeColumns and detailWidth or centerWidth,detailsHeight)
  number.Position=UDim2.fromOffset(14,14) number.Size=UDim2.fromOffset(30,30)
  caption.Position=UDim2.fromOffset(54,12) caption.Size=UDim2.new(1,-66,0,28) caption.TextSize=10
  weaponName.Position=UDim2.fromOffset(16,48) weaponName.Size=UDim2.new(1,-32,0,42) weaponName.TextSize=compact and 20 or 28
  kind.Position=UDim2.fromOffset(16,94)
  large.Frame.Position=UDim2.fromOffset(10,120) large.Frame.Size=UDim2.new(1,-20,0,math.max(90,primaryHeight-130))
  melee.Position=UDim2.fromOffset(10,primaryHeight+gap) melee.Size=UDim2.new(1,-20,0,meleeHeight-10)
  meleeName.TextSize=compact and 15 or 19 meleeClass.TextSize=compact and 9 or 10
  meleeNote.Visible=not compact
  for _,row in rows do
   row.Badge.Position=UDim2.fromOffset(8,10) row.Badge.Size=UDim2.fromOffset(24,24)
   row.Model.Position=UDim2.new(1,-50,0,8) row.Model.Size=UDim2.fromOffset(42,32)
   row.Name.Position=UDim2.fromOffset(8,38) row.Name.Size=UDim2.new(1,-16,0,compact and 34 or 22) row.Name.TextSize=compact and 12 or 14
   row.Class.Visible=false row.Melee.Visible=false
   local stateHeight=fontScale>1.15 and 30 or 18
   row.State.Position=UDim2.new(0,8,1,-stateHeight-3) row.State.Size=UDim2.new(1,-16,0,stateHeight) row.State.TextSize=9
  end
  for _,record in cameras do fit(record) end
 end
 hook(parent:GetPropertyChangedSignal("AbsoluteSize"),reflow)
 hook(root:GetPropertyChangedSignal("AbsoluteSize"),reflow)
 hook(player:GetAttributeChangedSignal("SettingMenuScale"),reflow)
 hook(player:GetAttributeChangedSignal("SettingFontScale"),reflow)
 hook(player:GetAttributeChangedSignal("SettingHighContrast"),refresh)
 hook(player:GetAttributeChangedSignal("CrossgroundsAdmin"),reflow)
 refresh() reflow() return self
end
return View
