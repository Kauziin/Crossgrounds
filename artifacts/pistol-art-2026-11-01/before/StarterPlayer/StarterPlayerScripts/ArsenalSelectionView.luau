-- Approved plan 8: vertical catalog, wide attachment list, separate preview/statistics.
local View={}
local Accent=require(script.Parent:WaitForChild('AccentTheme'))
local names={['ASSAULT RIFLES']='Fuzis de Assalto',['LIGHT MACHINE GUNS']='Metralhadoras',['MARKSMAN RIFLES']='Atirador',['SNIPER RIFLES']='Precisão',['SUBMACHINE GUNS']='Submetralhadoras',LEGACY='Clássicas',SPECIAL='Especiais',PISTOLS='Pistolas',SHOTGUNS='Escopetas',MELEE='Corpo a corpo',optic='Mira',muzzle='Boca',barrel='Cano',underbarrel='Acoplamento',magazine='Carregador',stock='Coronha',laser='Laser',fireControl='Disparo',ammunition='Munição',mount='Montagem',auxiliary='Auxiliares'}
local function object(class,name,parent)
 local o=Instance.new(class) o.Name=name o:SetAttribute('CascadeDecoration',true)
 if o:IsA('GuiObject') then o.BackgroundTransparency=1 o.BorderSizePixel=0 end o.Parent=parent return o
end
local function label(parent,name,value,size)
 local t=object('TextLabel',name,parent) t.Text=value t.TextSize=size t.Font=Enum.Font.GothamMedium t.TextColor3=Color3.fromRGB(232,244,248) t.TextWrapped=true t.TextXAlignment=Enum.TextXAlignment.Left return t
end
local function surface(o)
 o.BackgroundColor3=Color3.fromRGB(8,23,29) o.BackgroundTransparency=.06 Instance.new('UICorner',o).CornerRadius=UDim.new(0,12)
 local e=Instance.new('UIStroke',o) e.ApplyStrokeMode=Enum.ApplyStrokeMode.Border e.Color=Color3.fromRGB(95,135,151) e.Transparency=.55 return e
end
local function scrolling(holder,name,horizontal)
 local f=object('ScrollingFrame',name,holder) f.AutomaticCanvasSize=horizontal and Enum.AutomaticSize.X or Enum.AutomaticSize.Y f.CanvasSize=UDim2.new() f.ScrollBarThickness=4 f.ScrollBarImageColor3=Color3.fromRGB(65,220,229)
 local l=Instance.new('UIListLayout',f) l.Padding=UDim.new(0,8) l.SortOrder=Enum.SortOrder.LayoutOrder l.FillDirection=horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical return f
end
function View.new(parent,options)
 local self={} local nav=options.Navigation local player=options.Player local category=options.Category
 local rows={} local controls={} local connections={} local dead=false local width=1000 local reflow local currentId
 local accessories=options.Accessories local categoryButtons={} local toolButtons={}
 local root=object('Frame','ArsenalSelection',parent) root.Size=UDim2.fromScale(1,1) self.Root=root
 local left=object('Frame','Categories',root) surface(left) left.Visible=not accessories
 local center=object('Frame','Catalog',root) surface(center)
 local right=object('Frame','WeaponPanel',root) surface(right)
 local statsPanel=object('Frame','StatisticsPanel',root) surface(statsPanel)
 local heading=label(center,'Heading','',20) heading.Font=Enum.Font.GothamBold
 local detailName=label(right,'Name',options.WeaponName or '',22) detailName.Font=Enum.Font.GothamBold detailName.Position=UDim2.fromOffset(16,10) detailName.Size=UDim2.new(1,-32,0,44)
 local context=label(left,'Context','CATEGORIAS',15) context.Position=UDim2.fromOffset(14,8) context.Size=UDim2.new(1,-28,0,32)
 local categories=scrolling(accessories and center or left,'Slots',accessories)
 local items=scrolling(center,'Items')
 local description=scrolling(statsPanel,'DescriptionScroll')
 local detailText=label(description,'Description','',13) detailText.TextYAlignment=Enum.TextYAlignment.Top detailText.Size=UDim2.new(1,-8,0,0) detailText.AutomaticSize=Enum.AutomaticSize.Y
 local statsTitle=label(statsPanel,'Selection','ATRIBUTOS EFETIVOS',18) statsTitle.Font=Enum.Font.GothamBold statsTitle.Position=UDim2.fromOffset(14,8) statsTitle.Size=UDim2.new(1,-28,0,40)
 local statsList=scrolling(statsPanel,'Attributes') local statRows={}
 for i,v in {{'damage','Dano',''},{'rpm','Cadência',' RPM'},{'spreadDegrees','Dispersão','°'},{'controlRollDegrees','Recuo lateral','°'},{'movementMultiplier','Movimento','×'},{'range','Alcance',' studs'}} do
  local row=object('Frame',v[1],statsList) row.LayoutOrder=i row.Size=UDim2.new(1,-4,0,25)
  local text=label(row,'Value','',13) text.Size=UDim2.fromScale(1,1) statRows[v[1]]={text=text,title=v[2],suffix=v[3]}
 end
 local tools=scrolling(root,'Utilities',true)
 local footer=label(root,'Information','',13) footer.TextColor3=Color3.fromRGB(179,210,222)
 local function scale() return math.clamp(player and player:GetAttribute('SettingFontScale') or 1,.8,1.6) end
 local function button(holder,name,title,subtitle,callback,entry)
  local b=object('TextButton',name,holder) b:SetAttribute('ArsenalFocus',true) b.Text='' b.AutoButtonColor=false b.Selectable=true local edge=surface(b)
  local t=label(b,'Name',title,16) t.Font=Enum.Font.GothamBold local sub=label(b,'Status',subtitle or '',12) sub.TextColor3=Color3.fromRGB(168,201,214)
  local icon=label(b,'Icon',entry and (entry.id=='none' and '—' or accessories and '◇' or '') or '',24) icon.TextXAlignment=Enum.TextXAlignment.Center
  if entry and not accessories then
   -- Small vector silhouettes avoid unsupported glyphs and extra viewport models.
   local function shape(x,y,w,h)
    local p=object('Frame','Silhouette',icon) p.BackgroundTransparency=0 p.BackgroundColor3=Color3.fromRGB(168,201,214) p.Position=UDim2.new(0,x,.5,y) p.Size=UDim2.fromOffset(w,h)
   end
   if category=='PISTOLS' then shape(4,-6,25,5) shape(20,-2,7,13)
   else shape(1,-3,12,8) shape(12,-5,14,6) shape(24,-4,11,3) shape(17,0,5,9) end
  end
  local diamond=object('Frame','FocusDiamond',b) diamond.Rotation=45 diamond.BackgroundColor3=Color3.fromRGB(226,252,255) diamond.Size=UDim2.fromOffset(7,7) diamond.Position=UDim2.new(0,5,.5,-3) diamond.Visible=false
  nav:Connect(b,callback) nav:SetActions(b,{custom=entry and options.Custom and function() options.Custom(entry) end or nil})
  local r={Button=b,Edge=edge,Name=t,Status=sub,Icon=icon,Diamond=diamond,Entry=entry} table.insert(controls,r) return r
 end
 local function inspect(entry)
  if currentId==entry.id then return end currentId=entry.id
  if not accessories then detailName.Text=entry.name end
  statsTitle.Text=accessories and entry.name or 'ATRIBUTOS EFETIVOS' detailText.Text=entry.description or '' options.Inspect(entry)
 end
 local function paint(focus)
  local contrast=player and player:GetAttribute('SettingHighContrast')
  for _,r in controls do if r.Button.Parent then
   local on=focus==r.Button local selected=r.Category==category or r.Entry and r.Entry.equipped
   r.Diamond.Visible=on r.Edge.Color=on and Color3.fromRGB(226,252,255) or selected and Color3.fromRGB(40,230,235) or Color3.fromRGB(106,148,162)
   r.Edge.Thickness=on and 2 or 1 r.Edge.Transparency=on and 0 or selected and .15 or contrast and .25 or .65
   r.Button.BackgroundColor3=on and Color3.fromRGB(14,63,72) or selected and Color3.fromRGB(13,46,54) or Color3.fromRGB(15,35,43)
   if r.Entry then r.Status.TextColor3=r.Entry.equipped and Color3.fromRGB(91,234,199) or r.Entry.available==false and Color3.fromRGB(160,176,184) or Color3.fromRGB(168,201,214) end
  end end
 end
 local function renderItems()
  local oldFocus=nav:GetFocus() local wanted
  for _,r in rows do if r.Button==oldFocus then wanted=r.Entry.id end r.Button:Destroy() end rows={} currentId=nil
  local live={} for _,r in controls do if r.Button.Parent then table.insert(live,r) end end controls=live
  heading.Text=names[category] or category or 'ARMAS'
  for i,entry in options.Entries(category) do
   local r
   r=button(items,'Item_'..entry.id,entry.name,entry.status,function() inspect(r.Entry) options.Select(r.Entry) end,entry)
   r.Button.LayoutOrder=i table.insert(rows,r)
  end
  for i,r in rows do
   r.Button.NextSelectionUp=rows[i-1] and rows[i-1].Button or categoryButtons[category]
   r.Button.NextSelectionDown=rows[i+1] and rows[i+1].Button or toolButtons[1]
   if not accessories then r.Button.NextSelectionLeft=categoryButtons[category] end
  end
  for _,b in categoryButtons do if accessories then b.NextSelectionDown=rows[1] and rows[1].Button else b.NextSelectionRight=rows[1] and rows[1].Button end end
  local initial=rows[1] for _,r in rows do if r.Entry.id==wanted or not wanted and r.Entry.equipped then initial=r end end
  if initial then inspect(initial.Entry) end items.CanvasPosition=Vector2.zero
  if reflow then reflow() end if wanted and initial then nav:Focus(initial.Button) end paint(nav:GetFocus())
 end
 for i,key in options.Categories do
  local r=button(categories,'Category_'..key,names[key] or key,'',function() category=key renderItems() end) r.Category=key r.Button.LayoutOrder=i categoryButtons[key]=r.Button
 end
 if options.ChangeWeapon then table.insert(toolButtons,button(tools,'ChangeWeapon','↔  Trocar arma','',options.ChangeWeapon).Button) end
 for i,t in options.Tools or {} do local b=button(tools,'Tool'..i,t[1],'',t[3]).Button b.LayoutOrder=i table.insert(toolButtons,b) end
 function self:Refresh()
  -- Acknowledgments update rows in place: focus, slot and scroll survive.
  local entries={} for _,e in options.Entries(category) do entries[e.id]=e end
  for _,r in rows do local e=entries[r.Entry.id] if e then r.Entry=e r.Name.Text=e.name r.Status.Text=e.status if e.id==currentId then detailText.Text=e.description or '' end end end paint(nav:GetFocus())
 end
 function self:SetStatistics(value,baseline)
  for key,row in statRows do
   local v=value and value[key] local base=baseline and baseline[key]
   local function fmt(n) return string.format(n%1==0 and '%.0f' or '%.2f',n) end
   row.text.Text=row.title..'   '..(typeof(v)=='number' and fmt(v)..row.suffix or '—')..(typeof(v)=='number' and typeof(base)=='number' and math.abs(v-base)>.0001 and '  ('..string.format('%+.2f',v-base)..')' or '')
  end
 end
 function self:Cycle(step)
  if #options.Categories==0 then return end local i=table.find(options.Categories,category) or 1 category=options.Categories[(i-1+step)%#options.Categories+1] renderItems() if rows[1] then nav:Focus(rows[1].Button) end
 end
 table.insert(connections,nav.FocusChanged:Connect(function(focus) if dead then return end for _,r in rows do if r.Button==focus then inspect(r.Entry) break end end paint(focus) end))
 reflow=function()
  local s=scale() local gap=12 local compact=width<650 local top=options.Top and options.Top() or 64
  local height=math.max(420,options.Height and options.Height() or 530)
  local rightWidth=width>=900 and math.clamp(width*(accessories and .33 or .29),270,380) or 0
  local side=accessories and 0 or compact and width or math.clamp(width*.22,170,240)
  local x=(accessories or compact) and 0 or side+gap local y=top+(compact and not accessories and 174 or 0)
  local centerWidth=width-x-(rightWidth>0 and rightWidth+gap or 0)
  left.Position=UDim2.fromOffset(0,top) left.Size=UDim2.fromOffset(side,compact and 162 or height)
  center.Position=UDim2.fromOffset(x,y) center.Size=UDim2.fromOffset(centerWidth,height)
  local stripHeight=math.ceil(46*s)
  if accessories then categories.Position=UDim2.fromOffset(12,10) categories.Size=UDim2.new(1,-24,0,stripHeight) heading.Visible=false
  else categories.Position=UDim2.fromOffset(8,46) categories.Size=UDim2.new(1,-16,1,-54) heading.Visible=true heading.Position=UDim2.fromOffset(16,8) heading.Size=UDim2.new(1,-32,0,40) end
  local itemY=accessories and stripHeight+22 or 54 items.Position=UDim2.fromOffset(10,itemY) items.Size=UDim2.new(1,-20,1,-itemY-10)
  local rx=rightWidth>0 and width-rightWidth or x local ry=rightWidth>0 and y or y+height+gap local rw=rightWidth>0 and rightWidth or centerWidth
  local previewHeight=math.max(180,math.floor(height*.43))
  right.Position=UDim2.fromOffset(rx,ry) right.Size=UDim2.fromOffset(rw,previewHeight)
  statsPanel.Position=UDim2.fromOffset(rx,ry+previewHeight+gap) statsPanel.Size=UDim2.fromOffset(rw,math.max(210,height-previewHeight-gap))
  self.PreviewPosition=right.Position+UDim2.fromOffset(12,60) self.PreviewSize=UDim2.fromOffset(rw-24,previewHeight-68)
  local descriptionHeight=math.ceil(30*s)
  description.Position=UDim2.fromOffset(14,42) description.Size=UDim2.new(1,-28,0,descriptionHeight)
  statsList.Position=UDim2.fromOffset(14,46+descriptionHeight) statsList.Size=UDim2.new(1,-28,1,-54-descriptionHeight)
  statsList.UIListLayout.Padding=UDim.new(0,2) for _,v in statsList:GetChildren() do if v:IsA('Frame') then v.Size=UDim2.new(1,-4,0,math.ceil(22*s)) end end
  for _,r in controls do
   local utility=table.find(toolButtons,r.Button) local cat=r.Category~=nil
   r.Button.Size=utility and UDim2.fromOffset(math.ceil((r.Name.Text:find('Restaurar') and 204 or 174)*s),math.ceil(36*s)) or cat and accessories and UDim2.fromOffset(math.ceil((#r.Name.Text>8 and 150 or 112)*s),stripHeight-5) or UDim2.new(1,-8,0,math.ceil((cat and 60 or 64)*s))
   local inset=r.Entry and 58 or 20 r.Icon.Position=UDim2.fromOffset(15,0) r.Icon.Size=UDim2.new(0,36,1,0)
   r.Name.Position=UDim2.fromOffset(inset,(utility or cat and accessories) and 0 or 5)
   r.Name.Size=UDim2.new(1,-inset-12,0,math.ceil((utility and 36 or cat and 48 or 31)*s)) r.Name.TextSize=utility and 13 or 16
   r.Status.Position=UDim2.fromOffset(inset,math.ceil(34*s)) r.Status.Size=UDim2.new(1,-inset-12,0,math.ceil(23*s)) r.Status.Visible=r.Status.Text~=''
  end
  local bottom=math.max(y+height,statsPanel.Position.Y.Offset+statsPanel.Size.Y.Offset)
  tools.Visible=#toolButtons>0 tools.Position=UDim2.fromOffset(x,bottom+8) tools.Size=UDim2.fromOffset(width-x,math.ceil(44*s))
  footer.Position=UDim2.fromOffset(4,bottom+(#toolButtons>0 and math.ceil(54*s) or 12)) footer.Size=UDim2.new(1,-8,0,math.ceil(34*s))
  footer.Text=options.Information and options.Information() or 'A  Confirmar   B  Voltar   LB / RB  Categorias'
  self.TotalHeight=footer.Position.Y.Offset+footer.Size.Y.Offset+8
 end
 function self:Layout(value) width=value reflow() return self.TotalHeight end
 function self:PreviewVisible() return true end
 function self:DefaultFocus() for _,r in rows do if r.Entry.equipped then return r.Button end end return rows[1] and rows[1].Button or categoryButtons[category] end
 function self:Destroy() if dead then return end dead=true for _,c in connections do c:Disconnect() end root:Destroy() end
 root.Destroying:Connect(function() dead=true for _,c in connections do c:Disconnect() end end)
 if player then for _,a in {'SettingFontScale','SettingHighContrast'} do table.insert(connections,player:GetAttributeChangedSignal(a):Connect(function() reflow() paint(nav:GetFocus()) if options.LayoutChanged then options.LayoutChanged() end end)) end end
 renderItems() reflow() return self
end
return View
