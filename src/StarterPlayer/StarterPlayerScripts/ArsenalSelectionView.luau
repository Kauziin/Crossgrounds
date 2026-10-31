-- Shared, event-driven shell for weapon and accessory selection. No card ViewportFrames.
local View={}
local accent=Color3.fromRGB(36,224,232)
local names={['ASSAULT RIFLES']='Fuzis de Assalto',['LIGHT MACHINE GUNS']='Metralhadoras',['MARKSMAN RIFLES']='Atirador',['SNIPER RIFLES']='Precisão',LEGACY='Clássicas',SPECIAL='Especiais',SMGS='Submetralhadoras',PISTOLS='Pistolas',SHOTGUNS='Escopetas',SNIPER_RIFLES='Atirador',MELEE='Corpo a corpo',optic='Mira',muzzle='Boca / Cano',underbarrel='Acoplamento',magazine='Carregador',stock='Coronha',laser='Laser',fireControl='Disparo'}
local function panel(parent,name)
 local f=Instance.new('Frame') f.Name=name f:SetAttribute('CascadeDecoration',true) f.BackgroundColor3=Color3.fromRGB(9,22,29) f.BackgroundTransparency=.08 f.BorderSizePixel=0 f.Parent=parent
 Instance.new('UICorner',f).CornerRadius=UDim.new(0,12) local edge=Instance.new('UIStroke',f) edge.Color=Color3.fromRGB(78,115,130) edge.Transparency=.5 return f
end
local function label(parent,name,value,size)
 local t=Instance.new('TextLabel') t.Name=name t:SetAttribute('CascadeDecoration',true) t.Text=value t.TextSize=size t.Font=Enum.Font.GothamMedium t.TextWrapped=true t.TextXAlignment=Enum.TextXAlignment.Left t.TextYAlignment=Enum.TextYAlignment.Top t.TextColor3=Color3.fromRGB(225,241,246) t.BackgroundTransparency=1 t.Parent=parent return t
end
function View.new(parent,options)
 local self={} local alive=true local rows={} local connections={} local category=options.Category local nav=options.Navigation local current
 local root=Instance.new('Frame') root.Name='ArsenalSelection' root.BackgroundTransparency=1 root:SetAttribute('CascadeDecoration',true) root.Size=UDim2.fromScale(1,1) root.Parent=parent self.Root=root
 local left=panel(root,'Categories') local center=panel(root,'Catalog') local right=panel(root,'Details')
 local heading=label(center,'Heading',options.Accessories and 'ACESSÓRIOS' or 'ESCOLHA DE ARMAS',18) heading.Font=Enum.Font.GothamBold heading.Position=UDim2.fromOffset(14,12) heading.Size=UDim2.new(1,-28,0,30)
 local detailName=label(right,'Name','',23) detailName.Font=Enum.Font.GothamBold detailName.Position=UDim2.fromOffset(16,16) detailName.Size=UDim2.new(1,-32,0,68)
 local detailText=label(right,'Description','',13) detailText.Position=UDim2.fromOffset(16,310) detailText.Size=UDim2.new(1,-32,0,182)
 local itemList=Instance.new('ScrollingFrame') itemList.Name='Items' itemList.BackgroundTransparency=1 itemList.BorderSizePixel=0 itemList.AutomaticCanvasSize=Enum.AutomaticSize.Y itemList.CanvasSize=UDim2.new() itemList.ScrollBarThickness=3 itemList.Parent=center
 local grid=Instance.new('UIGridLayout',itemList) grid.SortOrder=Enum.SortOrder.LayoutOrder grid.CellPadding=UDim2.fromOffset(8,8)
 local categoryList=Instance.new('ScrollingFrame') categoryList.Name='List' categoryList.BackgroundTransparency=1 categoryList.BorderSizePixel=0 categoryList.Position=UDim2.fromOffset(8,8) categoryList.Size=UDim2.new(1,-16,1,-16) categoryList.AutomaticCanvasSize=Enum.AutomaticSize.Y categoryList.CanvasSize=UDim2.new() categoryList.ScrollBarThickness=3 categoryList.Parent=left
 local layout=Instance.new('UIListLayout',categoryList) layout.Padding=UDim.new(0,8) layout.SortOrder=Enum.SortOrder.LayoutOrder
 local slotStrip
 if options.Accessories then
  slotStrip=Instance.new('ScrollingFrame') slotStrip.Name='Slots' slotStrip.BackgroundTransparency=1 slotStrip.BorderSizePixel=0 slotStrip.AutomaticCanvasSize=Enum.AutomaticSize.X slotStrip.CanvasSize=UDim2.new() slotStrip.ScrollBarThickness=3 slotStrip.Parent=center
  local flow=Instance.new('UIListLayout',slotStrip) flow.FillDirection=Enum.FillDirection.Horizontal flow.Padding=UDim.new(0,8) flow.SortOrder=Enum.SortOrder.LayoutOrder
  local context=label(left,'WeaponContext',options.WeaponName..'\n\nArma em edição\n\nAcessórios visuais; conversões de disparo são indicadas separadamente.',14) context.Position=UDim2.fromOffset(16,20) context.Size=UDim2.new(1,-32,0,200)
  categoryList.Position=UDim2.fromOffset(8,240) categoryList.Size=UDim2.new(1,-16,1,-248)
 end
 local function button(parent,name,title,subtitle,callback)
  local b=Instance.new('TextButton') b.Name=name b:SetAttribute('CascadeDecoration',true) b.Text='' b.AutoButtonColor=false b.BackgroundColor3=Color3.fromRGB(14,32,40) b.Size=UDim2.new(1,-4,0,64) b.Parent=parent
  Instance.new('UICorner',b).CornerRadius=UDim.new(0,10) local edge=Instance.new('UIStroke',b) edge.Color=accent edge.Transparency=.8
  local t=label(b,'Name',title,14) t.Font=Enum.Font.GothamBold t.Position=UDim2.fromOffset(12,12) t.Size=UDim2.new(1,-24,0,38)
  local sub=label(b,'Status',subtitle,10) sub.TextColor3=Color3.fromRGB(147,182,195) sub.Position=UDim2.new(0,12,1,-26) sub.Size=UDim2.new(1,-24,0,22)
  nav:Connect(b,callback) return b,edge
 end
 local categoryButtons={} local renderItems
 local function inspect(entry)
  if current==entry then return end current=entry
  detailName.Text=entry.name detailText.Text=entry.description or ''
  options.Inspect(entry)
 end
 renderItems=function()
  for _,row in rows do row.Button:Destroy() end rows={} current=nil
  for key,b in categoryButtons do b.BackgroundColor3=key==category and Color3.fromRGB(12,64,70) or Color3.fromRGB(14,32,40) end
  heading.Text=options.Accessories and ('ACESSÓRIOS / '..(names[category] or category)) or (names[category] or category)
  for _,entry in options.Entries(category) do
   local b,edge=button(itemList,'Item_'..entry.id,entry.name,entry.status,function() inspect(entry) options.Select(entry) end)
   b.LayoutOrder=#rows+1
   local symbol=Instance.new('Frame') symbol.Name='SchematicIcon' symbol.BackgroundTransparency=1 symbol.Position=UDim2.fromOffset(14,54) symbol.Size=UDim2.fromOffset(92,24) symbol.Parent=b
   for i,rect in (options.Accessories and {{8,5,28,18},{38,9,26,10},{68,8,14,12}} or {{0,6,72,8},{64,2,26,14},{26,14,10,10}}) do
    local part=Instance.new('Frame') part.BackgroundColor3=Color3.fromRGB(143,177,191) part.BackgroundTransparency=.2 part.BorderSizePixel=0 part.Position=UDim2.fromOffset(rect[1],rect[2]) part.Size=UDim2.fromOffset(rect[3],rect[4]) part:SetAttribute('CascadeDecoration',true) part.Parent=symbol
   end
   nav:SetActions(b,{custom=function() inspect(entry) if options.Custom then options.Custom(entry) end end})
   table.insert(rows,{Button=b,Entry=entry,Edge=edge})
  end
  if rows[1] then inspect(rows[1].Entry) end
  itemList.CanvasPosition=Vector2.zero
 end
 for i,key in options.Categories do
  local b=button(slotStrip or categoryList,'Category_'..key,names[key] or key,options.Accessories and '' or 'Abrir categoria',function() category=key renderItems() end)
  b.LayoutOrder=i if slotStrip then b.Size=UDim2.fromOffset(112,54) b.Name='Category_'..key end
  categoryButtons[key]=b
 end
 if options.ChangeWeapon then button(categoryList,'ChangeWeapon','Trocar arma','Abrir catálogo',options.ChangeWeapon).LayoutOrder=100 end
 if options.Apply then button(categoryList,'Apply','Confirmar acessórios','Atualizar classe em edição',options.Apply).LayoutOrder=101 end
 for i,tool in options.Tools or {} do button(categoryList,'Tool'..i,tool[1],tool[2],tool[3]).LayoutOrder=101+i end
 table.insert(connections,nav.FocusChanged:Connect(function(object)
  for _,row in rows do
   local selected=object==row.Button row.Edge.Thickness=selected and 2 or 1 row.Edge.Transparency=selected and 0 or .8
   if selected then inspect(row.Entry) end
  end
 end))
 function self:Layout(width)
  local narrow=width<680 local side=narrow and 140 or math.clamp(width*.19,165,220) local gap=10 local rightWidth=width>=930 and math.clamp(width*.28,240,340) or 0
  local centerWidth=width-side-gap-(rightWidth>0 and rightWidth+gap or 0) local top=64 local centerHeight=530
  left.Position=UDim2.fromOffset(0,top) left.Size=UDim2.fromOffset(side,centerHeight)
  center.Position=UDim2.fromOffset(side+gap,top) center.Size=UDim2.fromOffset(centerWidth,centerHeight)
  local accessoryTop=options.Accessories and 292 or 54
  if slotStrip then slotStrip.Position=UDim2.fromOffset(10,220) slotStrip.Size=UDim2.new(1,-20,0,62) end
  itemList.Position=UDim2.fromOffset(10,accessoryTop) itemList.Size=UDim2.new(1,-20,1,-accessoryTop-10)
  local columns=centerWidth>=390 and 2 or 1 grid.CellSize=UDim2.new(1/columns,-(columns==2 and 14 or 8),0,options.Accessories and 112 or 134)
  local below=rightWidth==0
  right.Position=UDim2.fromOffset(below and side+gap or width-rightWidth,below and 604 or top) right.Size=UDim2.fromOffset(below and centerWidth or rightWidth,530)
  if options.Accessories then
   detailText.Position=UDim2.fromOffset(16,110)
   self.PreviewPosition=UDim2.fromOffset(side+gap+14,top+48) self.PreviewSize=UDim2.fromOffset(centerWidth-28,155)
  else
   self.PreviewPosition=UDim2.fromOffset((below and side+gap or width-rightWidth)+12,(below and 604 or top)+96) self.PreviewSize=UDim2.fromOffset((below and centerWidth or rightWidth)-24,195)
  end
  return below and 1144 or 610
 end
 function self:DefaultFocus() return rows[1] and rows[1].Button or categoryButtons[category] end
 function self:Destroy() if not alive then return end alive=false for _,c in connections do c:Disconnect() end root:Destroy() end
 root.Destroying:Connect(function() if alive then alive=false for _,c in connections do c:Disconnect() end end end)
 renderItems() return self
end
return View
