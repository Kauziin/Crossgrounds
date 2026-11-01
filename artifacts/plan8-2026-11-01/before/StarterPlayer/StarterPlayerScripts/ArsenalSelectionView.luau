-- One vertical catalog and one optional shared viewport. All gameplay stays in GunsmithView.
local View={}
local names={['ASSAULT RIFLES']='Fuzis de Assalto',['LIGHT MACHINE GUNS']='Metralhadoras',['MARKSMAN RIFLES']='Atirador',['SNIPER RIFLES']='Precisão',LEGACY='Clássicas',SPECIAL='Especiais',SMGS='Submetralhadoras',PISTOLS='Pistolas',SHOTGUNS='Escopetas',MELEE='Corpo a corpo',optic='Mira',muzzle='Boca',barrel='Cano',underbarrel='Acoplamento',magazine='Carregador',stock='Coronha',laser='Laser',fireControl='Disparo'}
local function object(class,name,parent)
 local o=Instance.new(class) o.Name=name o:SetAttribute('CascadeDecoration',true) if o:IsA('GuiObject') then o.BackgroundTransparency=1 o.BorderSizePixel=0 end o.Parent=parent return o
end
local function label(parent,name,value,size)
 local t=object('TextLabel',name,parent) t.Text=value t.TextSize=size t.Font=Enum.Font.GothamMedium t.TextColor3=Color3.fromRGB(232,244,248) t.TextWrapped=true t.TextXAlignment=Enum.TextXAlignment.Left t.TextYAlignment=Enum.TextYAlignment.Center return t
end
local function surface(o)
 o.BackgroundColor3=Color3.fromRGB(10,23,30) o.BackgroundTransparency=.06 Instance.new('UICorner',o).CornerRadius=UDim.new(0,12)
 local e=Instance.new('UIStroke',o) e.ApplyStrokeMode=Enum.ApplyStrokeMode.Border e.Color=Color3.fromRGB(95,135,151) e.Transparency=.55 return e
end
function View.new(parent,options)
 local self={} local nav=options.Navigation local player=options.Player local current local category=options.Category local rows={} local controls={} local connections={} local dead=false local width=1000 local reflow
 local previewOn=not options.Accessories or options.PreviewEnabled==true
 local function fontScale() return math.clamp(player and player:GetAttribute('SettingFontScale') or 1,.8,1.6) end
 local root=object('Frame','ArsenalSelection',parent) root.Size=UDim2.fromScale(1,1) self.Root=root
 local left=object('Frame','Categories',root) surface(left) local center=object('Frame','Catalog',root) surface(center) local right=object('Frame','Details',root) surface(right)
 local heading=label(center,'Heading','',20) heading.Font=Enum.Font.GothamBold heading.Position=UDim2.fromOffset(16,10) heading.Size=UDim2.new(1,-32,0,42)
 local detailName=label(right,'Name','',22) detailName.Font=Enum.Font.GothamBold detailName.Position=UDim2.fromOffset(16,14) detailName.Size=UDim2.new(1,-32,0,72)
 local detailText=label(right,'Description','',14) detailText.TextYAlignment=Enum.TextYAlignment.Top
 local function scrolling(holder,name)
  local f=object('ScrollingFrame',name,holder) f.AutomaticCanvasSize=Enum.AutomaticSize.Y f.CanvasSize=UDim2.new() f.ScrollBarThickness=5 f.ScrollBarImageColor3=Color3.fromRGB(65,220,229)
  local l=Instance.new('UIListLayout',f) l.Padding=UDim.new(0,8) l.SortOrder=Enum.SortOrder.LayoutOrder return f
 end
 local items=scrolling(center,'Items') local categories=scrolling(left,'List')
 local description=scrolling(right,'DescriptionScroll') detailText.Parent=description detailText.Position=UDim2.new() detailText.Size=UDim2.new(1,-8,0,0) detailText.AutomaticSize=Enum.AutomaticSize.Y
 local context=label(left,'Context',options.Accessories and options.WeaponName or 'CATEGORIAS',16) context.Font=Enum.Font.GothamBold context.Position=UDim2.fromOffset(14,8) context.Size=UDim2.new(1,-28,0,50)
 local footer=label(root,'Controls','',13) footer.TextColor3=Color3.fromRGB(179,210,222)
 local previewButton local categoryButtons={}
 local function toggle()
  if not options.Accessories then return end previewOn=not previewOn if reflow then reflow() end if options.PreviewChanged then options.PreviewChanged(previewOn) end
 end
 local function button(holder,name,title,subtitle,callback,entry)
  local b=object('TextButton',name,holder) b:SetAttribute('ArsenalFocus',true) b.Text='' b.AutoButtonColor=false b.Selectable=true local edge=surface(b)
  local t=label(b,'Name',title,16) t.Font=Enum.Font.GothamBold local sub=label(b,'Status',subtitle,12) sub.TextColor3=Color3.fromRGB(168,201,214)
  local diamond=object('Frame','FocusDiamond',b) diamond.Rotation=45 diamond.BackgroundColor3=Color3.fromRGB(40,230,235) diamond.Size=UDim2.fromOffset(7,7) diamond.Position=UDim2.new(0,7,.5,-3) diamond.Visible=false
  nav:Connect(b,callback) nav:SetActions(b,{custom=entry and options.Custom and function() options.Custom(entry) end or nil,reset=options.Accessories and toggle or nil})
  local r={Button=b,Edge=edge,Name=t,Status=sub,Diamond=diamond,Entry=entry} table.insert(controls,r) return r
 end
 local function inspect(entry) if current==entry then return end current=entry detailName.Text=entry.name detailText.Text=entry.description or '' options.Inspect(entry) end
 local function paint(focus)
  local contrast=player and player:GetAttribute('SettingHighContrast')
  for _,r in controls do if r.Button.Parent then local on=focus==r.Button local selected=r.Category==category or r.Entry and r.Entry.status:find('Equipado')~=nil
   r.Diamond.Visible=on r.Edge.Color=on and Color3.fromRGB(40,230,235) or Color3.fromRGB(106,148,162) r.Edge.Thickness=on and 2 or 1 r.Edge.Transparency=on and 0 or contrast and .25 or .65 r.Button.BackgroundColor3=on and Color3.fromRGB(14,63,72) or selected and Color3.fromRGB(13,46,54) or Color3.fromRGB(15,35,43)
  end end
 end
 local function renderItems()
  for _,r in rows do r.Button:Destroy() end rows={} current=nil
  local live={} for _,r in controls do if r.Button.Parent then table.insert(live,r) end end controls=live
  heading.Text=names[category] or category or 'ARMAS'
  for i,entry in options.Entries(category) do
   local r=button(items,'Item_'..entry.id,entry.name,entry.status,function() inspect(entry) options.Select(entry) end,entry) r.Button.LayoutOrder=i table.insert(rows,r)
  end
  for i,r in rows do r.Button.NextSelectionUp=rows[i-1] and rows[i-1].Button or nil r.Button.NextSelectionDown=rows[i+1] and rows[i+1].Button or nil r.Button.NextSelectionLeft=categoryButtons[category] end
  for _,b in categoryButtons do b.NextSelectionRight=rows[1] and rows[1].Button or nil end
  if rows[1] then inspect(rows[1].Entry) else detailName.Text='Nenhum item' detailText.Text='Não há itens neste slot.' end
  items.CanvasPosition=Vector2.zero if reflow then reflow() end paint(nav:GetFocus())
 end
 for i,key in options.Categories do local r=button(categories,'Category_'..key,names[key] or key,'',function() category=key renderItems() end) r.Category=key r.Button.LayoutOrder=i categoryButtons[key]=r.Button end
 if options.ChangeWeapon then button(categories,'ChangeWeapon','Trocar arma','Abrir catálogo',options.ChangeWeapon).Button.LayoutOrder=100 end
 if options.Apply then button(categories,'Apply','Confirmar acessórios','Atualizar classe',options.Apply).Button.LayoutOrder=101 end
 for i,t in options.Tools or {} do button(categories,'Tool'..i,t[1],t[2],t[3]).Button.LayoutOrder=102+i end
 if options.Accessories then previewButton=button(right,'TogglePreview','Y  Mostrar arma','',toggle) end
 table.insert(connections,nav.FocusChanged:Connect(function(focus) if dead then return end for _,r in rows do if r.Button==focus then inspect(r.Entry) break end end paint(focus) end))
 reflow=function()
  local scale=fontScale() local compact=width<650 local side=compact and width or math.clamp(width*.21,190,245) local gap=12 local rightWidth=width>=980 and math.clamp(width*.29,280,380) or 0
  local top=options.Top and options.Top() or 64
  local x=compact and 0 or side+gap local contentY=top+(compact and 184 or 0) local centerWidth=width-x-(rightWidth>0 and rightWidth+gap or 0) local height=math.max(380,options.Height and options.Height() or 530)
  left.Position=UDim2.fromOffset(0,top) left.Size=UDim2.fromOffset(side,compact and 172 or height)
  context.Size=UDim2.new(1,-28,0,compact and 34 or 50) categories.Position=UDim2.fromOffset(8,compact and 42 or 64) categories.Size=UDim2.new(1,-16,1,compact and -50 or -76)
  center.Position=UDim2.fromOffset(x,contentY) center.Size=UDim2.fromOffset(centerWidth,height) items.Position=UDim2.fromOffset(8,60) items.Size=UDim2.new(1,-16,1,-70)
  right.Position=UDim2.fromOffset(rightWidth>0 and width-rightWidth or x,rightWidth>0 and contentY or contentY+height+gap) right.Size=UDim2.fromOffset(rightWidth>0 and rightWidth or centerWidth,height)
  local previewY=options.Accessories and 100+math.ceil(48*scale) or 96 local previewHeight=math.max(110,math.min(height*.38,height-previewY-106))
  self.PreviewPosition=right.Position+UDim2.fromOffset(12,previewY) self.PreviewSize=UDim2.fromOffset(right.Size.X.Offset-24,previewHeight)
  description.Position=UDim2.fromOffset(16,previewOn and previewY+previewHeight+12 or previewY+8) description.Size=UDim2.new(1,-32,1,-description.Position.Y.Offset-16)
  if previewButton then previewButton.Button.Position=UDim2.fromOffset(12,88) previewButton.Button.Size=UDim2.new(1,-24,0,math.ceil(48*scale)) previewButton.Name.Text=previewOn and 'Y  Ocultar arma' or 'Y  Mostrar arma' end
  for _,r in controls do local subtitle=r.Status.Text~='' r.Button.Size=previewButton==r and r.Button.Size or UDim2.new(1,-8,0,math.ceil((subtitle and 84 or 58)*scale))
   -- InterfaceThemeController applies the font preference; scale geometry only here.
   r.Name.TextSize=16 r.Status.TextSize=12 r.Name.Position=UDim2.fromOffset(22,7) r.Name.Size=UDim2.new(1,-34,0,math.ceil(40*scale))
   r.Status.Position=UDim2.new(0,22,1,-math.ceil(28*scale)) r.Status.Size=UDim2.new(1,-34,0,math.ceil(24*scale)) r.Status.Visible=subtitle
  end
  detailName.TextSize=22 detailText.TextSize=14
  footer.Text=options.Accessories and 'A  Equipar    Y  Mostrar / ocultar arma    B  Voltar' or 'A  Equipar    X  Ação da arma    B  Voltar'
  self.TotalHeight=right.Position.Y.Offset+height+46 footer.Position=UDim2.fromOffset(4,self.TotalHeight-34) footer.Size=UDim2.new(1,-8,0,28)
 end
 function self:Layout(value) width=value reflow() return self.TotalHeight end
 function self:PreviewVisible() return previewOn end
 function self:DefaultFocus() return rows[1] and rows[1].Button or categoryButtons[category] end
 function self:Destroy() if dead then return end dead=true for _,c in connections do c:Disconnect() end root:Destroy() end
 root.Destroying:Connect(function() dead=true for _,c in connections do c:Disconnect() end end)
 if player then for _,a in {'SettingFontScale','SettingHighContrast'} do table.insert(connections,player:GetAttributeChangedSignal(a):Connect(function() reflow() paint(nav:GetFocus()) if options.LayoutChanged then options.LayoutChanged() end end)) end end
 renderItems() reflow() return self
end
return View
