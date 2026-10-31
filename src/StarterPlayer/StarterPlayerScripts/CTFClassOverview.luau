-- Presentation only. All selections and edits are delegated to GunsmithView.
local View={}
local cyan=Color3.fromRGB(36,224,232)
local muted=Color3.fromRGB(164,188,198)
local function box(parent,name)
 local f=Instance.new('Frame') f.Name=name f.BackgroundColor3=Color3.fromRGB(10,22,28) f.BackgroundTransparency=.12 f.BorderSizePixel=0 f:SetAttribute('CascadeDecoration',true) f.Parent=parent
 local c=Instance.new('UICorner',f) c.CornerRadius=UDim.new(0,12)
 local s=Instance.new('UIStroke',f) s.Color=Color3.fromRGB(90,123,139) s.Transparency=.55
 return f
end
local function text(parent,name,value,size,x,y,w,h)
 local t=Instance.new('TextLabel') t.Name=name t.Text=value t.Font=Enum.Font.GothamMedium t.TextSize=size t.TextColor3=Color3.fromRGB(235,245,249) t.BackgroundTransparency=1 t.TextWrapped=true t.TextXAlignment=Enum.TextXAlignment.Left t.TextYAlignment=Enum.TextYAlignment.Center t.Position=UDim2.fromOffset(x,y) t.Size=UDim2.new(w, -x-12,0,h) t:SetAttribute('CascadeDecoration',true) t.Parent=parent return t
end
local function header(parent,value)
 local stripe=box(parent,'Accent') stripe.BackgroundColor3=cyan stripe.BackgroundTransparency=0 stripe.Position=UDim2.fromOffset(10,12) stripe.Size=UDim2.fromOffset(3,16)
 return text(parent,'Heading',value,13,23,5,1,30)
end
function View.new(root,options)
 local self={} local nav=options.Navigation local connections={} local records={} local alive=true local revision=0 local rows={}
 local function hook(signal,fn) table.insert(connections,signal:Connect(fn)) end
 local home=Instance.new('Frame') home.Name='CreateAClass' home.BackgroundTransparency=1 home.Size=UDim2.fromScale(1,1) home:SetAttribute('CascadeDecoration',true) home.Parent=root self.Root=home
 local primary=box(home,'PrimarySlot') header(primary,'ARMA PRINCIPAL')
 local primaryName=text(primary,'WeaponName','',21,14,35,1,30) primaryName.Font=Enum.Font.GothamBold
 local attachmentRow=Instance.new('Frame',primary) attachmentRow.Name='AttachmentSlots' attachmentRow.BackgroundTransparency=1 attachmentRow.Position=UDim2.new(0,10,1,-55) attachmentRow.Size=UDim2.new(1,-20,0,45)
 local attachmentLabels={}
 for i,key in {'Mira','Cano','Acoplamento','Carregador','Coronha'} do
  local tile=box(attachmentRow,'Slot'..i) tile.Position=UDim2.new((i-1)/5,2,0,0) tile.Size=UDim2.new(1/5,-4,1,0)
  attachmentLabels[i]=text(tile,'Value',key..'\nPadrão',10,7,0,1,45)
 end
 local secondary=box(home,'SecondarySlot') header(secondary,'ARMA SECUNDÁRIA')
  local secondaryName=text(secondary,'WeaponName','',17,14,35,.55,44)
 local secondaryInfo=text(secondary,'SlotInfo','Mira · Cano · Carregador\nPadrão',11,14,76,.55,32) secondaryInfo.TextColor3=muted
 local melee=box(home,'MeleeSlot') header(melee,'CORPO A CORPO') local meleeName=text(melee,'WeaponName','Executor',15,12,36,.62,35)
 local ability1=box(home,'Ability1') header(ability1,'HABILIDADE 1') text(ability1,'Future','+\nEm breve',14,12,34,1,48).TextColor3=muted
 local ability2=box(home,'Ability2') header(ability2,'HABILIDADE 2') text(ability2,'Future','+\nEm breve',14,12,34,1,48).TextColor3=muted
 local appearance=box(home,'Appearance') header(appearance,'APARÊNCIA')
 text(appearance,'Future','◈   ◇   ◇   ◇     Personalização · Em breve',12,132,2,1,44).TextColor3=muted
 local right=box(home,'WeaponDetails')
 local rightName=text(right,'WeaponName','',22,16,12,1,40) rightName.Font=Enum.Font.GothamBold
 local category=text(right,'Category','',11,16,52,1,28) category.TextColor3=cyan
 local progression=text(right,'Progression','PROGRESSÃO DE ARMA\nEm breve',11,16,86,1,42) progression.TextColor3=muted
 local description=text(right,'Description','',12,16,140,1,62) description.TextColor3=muted
 local statLabels={}
 for i,name in {'Dano','Cadência','Precisão','Controle','Mobilidade','Alcance'} do
  local y=218+(i-1)*31
  text(right,'Stat'..i,name,11,16,y,.55,24)
  local track=box(right,'Track'..i) track.Position=UDim2.new(.53,0,0,y+9) track.Size=UDim2.new(.28,0,0,5) track.BackgroundColor3=Color3.fromRGB(62,82,92)
  statLabels[i]=text(right,'Value'..i,'—',11,0,y,1,24) statLabels[i].Position=UDim2.new(.83,0,0,y) statLabels[i].Size=UDim2.new(.15,0,0,24) statLabels[i].TextXAlignment=Enum.TextXAlignment.Right
 end
 local status=text(right,'Status','A · Escolher   X · Editar\nAplicado no próximo nascimento.',11,16,422,1,54) status.TextColor3=cyan
 local function button(parent,name,value,callback)
  local b=Instance.new('TextButton') b.Name=name b.Text=value b.Font=Enum.Font.GothamMedium b.TextSize=11 b.TextColor3=Color3.fromRGB(229,244,247) b.BackgroundColor3=Color3.fromRGB(26,43,51) b.Parent=parent b:SetAttribute('CascadeDecoration',true) b.AutoButtonColor=false
  Instance.new('UICorner',b).CornerRadius=UDim.new(0,8) nav:Connect(b,callback) return b
 end
 local edit=button(primary,'EditPrimary','X  Editar',function() options.Edit('primary') end) edit.Position=UDim2.new(1,-98,0,7) edit.Size=UDim2.fromOffset(86,28)
 local editSecondary=button(secondary,'EditSecondary','X  Editar',function() options.Edit('secondary') end) editSecondary.Position=UDim2.new(1,-98,0,7) editSecondary.Size=UDim2.fromOffset(86,28)
 local footer=text(home,'Controls','A  Escolher     X  Editar     B  Voltar  ·  Seleção válida no próximo nascimento.',11,0,0,1,28) footer.TextColor3=muted
 local function viewport(parent,name)
  local f=Instance.new('ViewportFrame') f.Name=name f.BackgroundTransparency=1 f.Ambient=Color3.fromRGB(175,192,203) f.LightColor=Color3.fromRGB(255,242,219) f.LightDirection=Vector3.new(-1,-2,-3) f.Parent=parent
  local c=Instance.new('Camera',f) c.FieldOfView=32 f.CurrentCamera=c local world=Instance.new('WorldModel',f)
  local rec={Frame=f,Camera=c,World=world} table.insert(records,rec)
  return rec
 end
 local secondaryPreview=viewport(secondary,'SecondaryPreview') secondaryPreview.Frame.Position=UDim2.new(.5,0,0,36) secondaryPreview.Frame.Size=UDim2.new(.48,0,1,-42)
 local meleePreview=viewport(melee,'MeleePreview') meleePreview.Frame.Position=UDim2.new(.58,0,0,32) meleePreview.Frame.Size=UDim2.new(.4,0,1,-36)
 local function fit(rec)
  if not rec.Model then return end local cf,size=rec.Model:GetBoundingBox() local aspect=math.max(.15,rec.Frame.AbsoluteSize.X/math.max(1,rec.Frame.AbsoluteSize.Y))
  local direction=Vector3.new(-1,.1,.16).Unit local basis=CFrame.lookAt(Vector3.zero,-direction) local tangent=math.tan(math.rad(16)) local distance=0
  for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do local p=basis:VectorToObjectSpace(cf:PointToWorldSpace(size*Vector3.new(x,y,z)*.5)-cf.Position) distance=math.max(distance,math.abs(p.X)/(tangent*aspect)+p.Z,math.abs(p.Y)/tangent+p.Z) end end end
  rec.Camera.CFrame=CFrame.lookAt(cf.Position+direction*math.max(.5,distance*1.1),cf.Position)
 end
 for _,rec in records do hook(rec.Frame:GetPropertyChangedSignal('AbsoluteSize'),function() fit(rec) end) end
 function self:Inspect(n,preset)
  revision+=1 local token=revision self.Index=n
  local catalog=options.Catalog local w=catalog.Get(preset.primaryWeaponId) local s=catalog.Get(preset.secondaryWeaponId)
  primaryName.Text=w and w.name or preset.primaryWeaponId rightName.Text=primaryName.Text
  local categories={['ASSAULT RIFLES']='FUZIL DE ASSALTO',PISTOLS='PISTOLA',SMGS='SUBMETRALHADORA',SHOTGUNS='ESCOPETA',SNIPERS='FUZIL DE PRECISÃO'}
  category.Text=w and (categories[w.category] or w.category) or 'ARMAMENTO'
  secondaryName.Text=s and s.name or preset.secondaryWeaponId meleeName.Text='Executor'
  description.Text='Equipamento da classe '..n..'. Acessórios visuais preservam os atributos base da arma.'
  local stats=options.Stats.Get(preset.primaryWeaponId).baseStats
  local values={stats.damage,stats.rpm and math.floor(stats.rpm+.5),stats.spreadDegrees and stats.spreadDegrees..'°',nil,nil,stats.range}
  for i,t in statLabels do t.Text=tostring(values[i] or '—') end
  local keys={'optic','muzzle','underbarrel','magazine','stock'} local names={'Mira','Boca / Cano','Acoplamento','Carregador','Coronha'}
  for i,t in attachmentLabels do local id=(preset.primaryAttachments or {})[keys[i]] local a=id and options.Attachments[id] local supported=w and table.find(w.slots,keys[i]) t.Text=names[i]..'\n'..(a and a.name or supported and 'Padrão' or 'Em breve') end
  for _,rec in records do rec.World:ClearAllChildren() rec.Model=nil end
  for i,rec in records do
   local id=i==1 and preset.secondaryWeaponId or preset.meleeWeaponId
   options.Preview(id,i==1 and preset.secondaryAttachments or {},function(asset)
    if not alive or token~=revision then return end rec.World:ClearAllChildren() rec.Model=asset:Clone() rec.Model.Parent=rec.World
    if i==2 then rec.Model:PivotTo(CFrame.Angles(0,0,math.rad(-70))*rec.Model:GetPivot()) end fit(rec)
   end,function() return alive and token==revision and home.Visible end)
  end
 end
 function self:StyleRow(b,n,preset)
  b.Text='' b.Size=UDim2.new(1,-8,0,76) b.BackgroundColor3=Color3.fromRGB(13,28,35) b.AutoButtonColor=false b:SetAttribute('CascadeDecoration',true)
  Instance.new('UICorner',b).CornerRadius=UDim.new(0,12) local edge=Instance.new('UIStroke',b) edge.Color=cyan edge.Thickness=1 edge.Transparency=.8
  text(b,'Number',string.format('%02d',n),22,12,10,.24,40).TextColor3=cyan
  text(b,'ClassName',preset.name,15,48,8,1,25).Font=Enum.Font.GothamBold
  local w=options.Catalog.Get(preset.primaryWeaponId) text(b,'PrimaryName',w and w.name or '',10,48,32,1,22).TextColor3=muted
  local stateLabel=text(b,'State','PERSONALIZADA',9,48,53,1,15) stateLabel.TextColor3=muted
  rows[n]={Button=b,Edge=edge,Label=stateLabel,Preset=preset}
 end
 function self:RefreshState(state)
  for n,row in rows do if row.Button.Parent then
   local focused=self.Index==n row.Edge.Thickness=focused and 2 or 1 row.Edge.Transparency=focused and 0 or .8 row.Button.BackgroundColor3=focused and Color3.fromRGB(10,46,54) or Color3.fromRGB(13,28,35)
   local p=row.Preset local function matches(v)
    if not v or v.name~=p.name or v.primaryWeaponId~=p.primaryWeaponId or v.secondaryWeaponId~=p.secondaryWeaponId or v.meleeWeaponId~=p.meleeWeaponId then return false end
    for _,slot in {'primaryAttachments','secondaryAttachments'} do
     for k,id in v[slot] or {} do if (p[slot] or {})[k]~=id then return false end end
     for k,id in p[slot] or {} do if (v[slot] or {})[k]~=id then return false end end
    end
    return true
   end
   row.Label.Text=matches(state.pending) and 'PRÓXIMO NASCIMENTO' or matches(state.active) and 'EQUIPADA' or 'PERSONALIZADA'
  end end
 end
 function self:Layout(width)
  local wide=width>=900 local mid=width>=650 local left=mid and math.clamp(width*.22,175,235) or width local gap=10
  local rightWidth=wide and math.clamp(width*.245,220,280) or 0 local centerX=mid and left+gap or 0 local centerW=width-centerX-(wide and rightWidth+gap or 0)
  primary.Position=UDim2.fromOffset(centerX,62) primary.Size=UDim2.fromOffset(centerW,210)
  secondary.Position=UDim2.fromOffset(centerX,282) secondary.Size=UDim2.fromOffset(centerW,120)
  local third=(centerW-16)/3
  for i,f in {melee,ability1,ability2} do f.Position=UDim2.fromOffset(centerX+(i-1)*(third+8),412) f.Size=UDim2.fromOffset(third,84) end
  appearance.Position=UDim2.fromOffset(centerX,506) appearance.Size=UDim2.fromOffset(centerW,48)
  right.Position=wide and UDim2.fromOffset(width-rightWidth,62) or UDim2.fromOffset(centerX,564) right.Size=UDim2.fromOffset(wide and rightWidth or centerW,490)
  local offset=mid and 0 or 210
  if offset>0 then for _,f in {primary,secondary,melee,ability1,ability2,appearance,right} do f.Position+=UDim2.fromOffset(0,offset) end end
  local height=(wide and 590 or 1094)+offset footer.Position=UDim2.fromOffset(0,height-30)
  return left,centerX,centerW,height,offset
 end
 hook(nav.FocusChanged,function(object) for n,row in rows do if object==row.Button and self.Index~=n and home.Visible then options.Inspect(n) break end end end)
 function self:Destroy() alive=false revision+=1 for _,c in connections do c:Disconnect() end home:Destroy() end
 home.Destroying:Connect(function() alive=false revision+=1 for _,c in connections do c:Disconnect() end end)
 return self
end
return View
