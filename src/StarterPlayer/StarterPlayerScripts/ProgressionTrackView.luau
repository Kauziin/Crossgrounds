-- Shared bounded presentation for account, weapon and collective tracks.
local V=require(script.Parent.ProgressionView)
local Nav=require(script.Parent.MenuNavigation)
local Art=require(game.ReplicatedStorage.Crossgrounds.AttachmentArt)
local Theme=require(script.Parent.MenuTheme)
local T={}
function T.new(parent,options)
 local root=Instance.new('Frame') root.Name='ProgressionTrack' root.BackgroundTransparency=1 root.Size=UDim2.new(1,-4,0,610) root.Parent=parent
 local function inheritedScale() local total=1 local node=parent while node do local fit=node:FindFirstChildOfClass('UIScale') if fit then total*=fit.Scale end node=node.Parent end return math.clamp(total,.2,3) end
 local widthFactor=inheritedScale() local scale=Instance.new('UIScale') scale.Name='TrackLegibility' scale.Scale=1/widthFactor scale.Parent=root
 root:SetAttribute('MenuContextHelp','X FILTROS · Y ATUAL · LT/RT GRUPOS')
 local self={Root=root,Level=nil,Reward=1,Category='all',Mode='all'} local connections={} local cards={} local data local repaint local lastWidth=0 local alive=true local popup local openFilters
 local accent=options.Accent or Color3.fromRGB(161,120,255)
 local function neoTrack() return data and Theme.Style.IsNova() end
 local function text(p,n,t,x,y,w,h,size) local l=V.Text(p,n,t,x,y,w,h,size or 14) l.Size=UDim2.new(1,x and -x-12 or -24,0,h) return l end
 local header=V.Box(root,'Identity',140) header.Position=UDim2.fromOffset(0,0)
 local image=Instance.new('ImageLabel') image.Name='Avatar' image.BackgroundTransparency=1 image.Position=UDim2.fromOffset(14,14) image.Size=UDim2.fromOffset(80,80) image.Parent=header V.Round(image,12)
 local emblem=V.Text(header,'GuildEmblem','',14,14,80,80,46) emblem.TextXAlignment=Enum.TextXAlignment.Center emblem.Visible=false
 local previewArea=Instance.new('Frame') previewArea.Name='PreviewArea' previewArea.BackgroundTransparency=1 previewArea.Size=UDim2.new(.32,-12,1,-18) previewArea.Position=UDim2.fromOffset(8,8) previewArea.Parent=header self.PreviewArea=previewArea
 local name=text(header,'Name','',110,10,0,34,24) name.Font=Enum.Font.GothamBold name.TextWrapped=false name.TextTruncate=Enum.TextTruncate.AtEnd
 local subtitle=text(header,'Subtitle','',110,45,0,26,15)
 local xp=text(header,'XPValue','',110,75,0,24,13)
 local bar=V.Bar(header,'XP',110,112,300,10,0,accent)
 local filters=Instance.new('Frame') filters.Name='Filters' filters.BackgroundTransparency=1 filters.Position=UDim2.fromOffset(0,150) filters.Size=UDim2.new(1,0,0,42) filters.Parent=root
 local category=V.Button(filters,'Category','Todas as recompensas',nil) category.Size=UDim2.new(.5,-5,1,0)
 local mode=V.Button(filters,'Mode','Todos os modos',nil) mode.Position=UDim2.new(.5,5,0,0) mode.Size=UDim2.new(.5,-5,1,0)
 local strip=Instance.new('Frame') strip.Name='Levels' strip.BackgroundTransparency=1 strip.Position=UDim2.fromOffset(0,204) strip.Size=UDim2.new(1,0,0,196) strip.Parent=root
 local rail=Instance.new('Frame') rail.Name='ProgressLine' rail.BackgroundColor3=Color3.fromRGB(62,65,80) rail.Position=UDim2.fromOffset(12,410) rail.Size=UDim2.new(1,-24,0,3) rail.Parent=root
 local fill=Instance.new('Frame') fill.Name='Fill' fill.BackgroundColor3=accent fill.BorderSizePixel=0 fill.Size=UDim2.fromScale(0,1) fill.Parent=rail
 local controls=Instance.new('Frame') controls.Name='Paging' controls.BackgroundTransparency=1 controls.Position=UDim2.fromOffset(0,430) controls.Size=UDim2.new(1,0,0,40) controls.Parent=root
 local prev=V.Button(controls,'Previous','‹ Anteriores',nil) prev.Size=UDim2.new(.33,-4,1,0)
 local current=V.Button(controls,'Current','Y · Ir ao atual',nil) current.Position=UDim2.fromScale(.33,0) current.Size=UDim2.new(.34,-4,1,0)
 local next=V.Button(controls,'Next','Próximos ›',nil) next.Position=UDim2.fromScale(.67,0) next.Size=UDim2.new(.33,0,1,0)
 local detail=V.Box(root,'RewardDetails',156) detail.Position=UDim2.fromOffset(0,482)
 local rewardName=text(detail,'Name','',16,10,0,32,20) rewardName.Font=Enum.Font.GothamBold
 local rewardText=text(detail,'Description','',16,46,0,66,14)
 local action=V.Button(detail,'Equip','Equipar',nil) action.Position=UDim2.new(0,16,1,-46) action.Size=UDim2.fromOffset(175,36) action.Visible=options.Equip~=nil
 local more=V.Button(detail,'NextReward','Outra recompensa',nil) more.Position=UDim2.new(1,-205,1,-46) more.Size=UDim2.fromOffset(189,36)
 local note=text(root,'Notes','',4,650,0,56,13)
 local extra=V.Box(root,'GuildSections',200) extra.Position=UDim2.fromOffset(0,716) extra.Visible=false
 local weekly=V.Box(root,'WeeklyMissions',220) weekly.Visible=false
 local missions=text(weekly,'Missions','MISSÕES SEMANAIS\nServiço semanal ainda não disponível.',14,10,0,52,14)
 local contributors=Instance.new('ScrollingFrame') contributors.Name='Contributions' contributors.BackgroundTransparency=1 contributors.BorderSizePixel=0 contributors.Position=UDim2.fromOffset(14,70) contributors.Size=UDim2.new(1,-28,0,120) contributors.AutomaticCanvasSize=Enum.AutomaticSize.Y contributors.CanvasSize=UDim2.new() contributors.ScrollBarThickness=3 contributors.Parent=extra
 local contributionLayout=Instance.new('UIListLayout') contributionLayout.SortOrder=Enum.SortOrder.LayoutOrder contributionLayout.Padding=UDim.new(0,4) contributionLayout.Parent=contributors
 local footer=text(root,'ControllerHints','A Selecionar · B Voltar · X Filtros · Y Atual · LB/RB Categorias · LT/RT Grupos',4,716,0,40,12)
 local function count() local width=root.AbsoluteSize.X if data and data.kind=='guild' and width>=800 and not neoTrack() then width*=.66 end return math.clamp(math.floor((width+10)/142),2,8) end
 local function selectedReward() local rewards=data and data.rows[self.Level] or {} return rewards[self.Reward],rewards end
 local function details()
  local reward,rewards=selectedReward()
  rewardName.Text=reward and reward.name or 'Nível '..tostring(self.Level or '—')..' · Sem recompensa'
  rewardText.Text=reward and ((not data.ready and 'Estado indisponível · ' or reward.available==true and 'Desbloqueado · ' or 'Bloqueado · ')..(reward.description or '')) or 'Nenhuma recompensa configurada neste nível. Você pode consultar os demais níveis.'
  more.Visible=#rewards>1 more.Text='Recompensa '..self.Reward..' / '..#rewards
  local allowed=reward and reward.available==true local reason
  if reward and options.CanEquip then allowed,reason=options.CanEquip(reward) end
  action.Visible=options.Equip~=nil and reward~=nil action.Text=allowed and (neoTrack() and 'Equipar' or 'A · Equipar') or reason or 'Indisponível'
  action.Active=allowed==true action.Selectable=action.Active
  if allowed and reward and reward.available~=true then rewardText.Text='Disponível neste contexto de treino · '..(reward.description or '') end
  if options.Inspect then local comparison=options.Inspect(reward) if comparison then rewardText.Text..='\n'..comparison end end
 end
 function self:Refresh(reset)
  data=options.Data(self.Category,self.Mode) self.Data=data
  if not self.Level or reset then self.Level=data.current self.Reward=1 end
  self.Level=math.clamp(self.Level,1,data.max)
  self.Reward=math.clamp(self.Reward or 1,1,math.max(1,#(data.rows[self.Level] or {})))
  name.Text=options.Name and options.Name() or data.title
  subtitle.Text=data.subtitle or ''
  xp.Text=data.ready and (tostring(data.xp or 0)..' XP · '..math.max(0,(data.upper or 0)-(data.xp or 0))..' XP para o próximo nível'..(data.totalXP and ' · Total '..data.totalXP or '')) or 'XP indisponível'
  bar.Visible=data.ready bar.Fill.Size=UDim2.fromScale(data.upper==data.lower and 1 or math.clamp(((data.xp or 0)-(data.lower or 0))/math.max(1,(data.upper or 0)-(data.lower or 0)),0,1),1)
  image.Visible=data.kind=='account' image.Image='rbxthumb://type=AvatarHeadShot&id='..game.Players.LocalPlayer.UserId..'&w=150&h=150'
  emblem.Visible=data.clan~=nil if data.clan then local e=require(game.ReplicatedStorage.Crossgrounds.ClanCatalog).Emblems[data.clan.emblem] emblem.Text=e and e.glyph or '◆' end
  previewArea.Visible=data.kind=='weapon'
  category.Visible=options.Categories~=nil mode.Visible=options.Modes~=nil
  note.Text=data.note or 'Desbloqueios consultados na carreira existente. Permanências por token continuam válidas.'
  extra.Visible=data.kind=='guild' footer.Position=UDim2.fromOffset(4,extra.Visible and 928 or 716)
  if extra.Visible then
   local c=data.clan V.Clear(contributors)
   local heading=V.Text(contributors,'Period','CONTRIBUIÇÕES · DESDE A ENTRADA',0,0,600,24,12) heading.Size=UDim2.new(1,-8,0,24) heading.LayoutOrder=0
   if c then local rows=table.clone(c.members) table.sort(rows,function(a,b) return a.contributionXP==b.contributionXP and a.userId<b.userId or a.contributionXP>b.contributionXP end)
    for i,m in rows do local row=V.Button(contributors,'Member'..m.userId,i..'   '..m.name..'   '..m.contributionXP..' XP',function() end) row.Size=UDim2.new(1,-8,0,36) row.LayoutOrder=i end
   else local empty=V.Text(contributors,'Empty','Nenhuma associação ativa confirmada.',0,0,600,40,13) empty.Size=UDim2.new(1,-8,0,40) end
  end
  root.Size=UDim2.new(widthFactor,-4,0,extra.Visible and 972 or 760)
  repaint()
 end
 function self:Go(level,focus)
  self.Level=math.clamp(level,1,data.max) self.Reward=1 repaint()
  if focus then for _,b in cards do if b:GetAttribute('Level')==self.Level then Nav:Focus(b) break end end end
 end
 openFilters=function(values,selected,set)
  if popup then popup:Destroy() popup=nil end
  if not values then return end
  local gui=Instance.new('ScreenGui') gui.Name='TrackFilters' gui.DisplayOrder=91 gui.IgnoreGuiInset=true gui.Parent=game.Players.LocalPlayer.PlayerGui popup=gui
  local shade=Instance.new('TextButton') shade.Text='' shade.BackgroundColor3=Color3.new() shade.BackgroundTransparency=.4 shade.Size=UDim2.fromScale(1,1) shade.Parent=gui
  local height=#values*48+16
  local frame
  if neoTrack() then
   frame=Instance.new('ScrollingFrame')
   frame.Name='Choices'
   frame.BackgroundColor3=V.C.Surface
   frame.BorderSizePixel=0
   frame.ScrollBarThickness=3
   frame.CanvasSize=UDim2.fromOffset(0,height)
   frame.ScrollingDirection=Enum.ScrollingDirection.Y
   frame.Size=UDim2.new(1,-32,1,-44)
   local limit=Instance.new('UISizeConstraint',frame)
   limit.MaxSize=Vector2.new(320,height)
   frame.Parent=shade
   V.Round(frame)
   V.Edge(frame)
  else
   frame=V.Box(shade,'Choices',height)
   frame.Size=UDim2.fromOffset(300,height)
  end
  frame.AnchorPoint=Vector2.new(.5,.5) frame.Position=UDim2.fromScale(.5,.5)
  local first
  local function close() gui:Destroy() popup=nil task.delay(.05,function() if alive and root.Parent then Nav:Focus(category.Visible and category or current) end end) end
  Nav:Connect(shade,close)
  for i,v in values do local b=V.Button(frame,'Filter'..i,v.label,function() set(v) close() end) b.Position=UDim2.fromOffset(8,8+(i-1)*48) b.Size=UDim2.new(1,-16,0,44) V.Select(b,v.id==selected) first=first or b end
  Nav:SetFloatingRoot(frame,close,first) task.defer(function() if first.Parent then Nav:Focus(first) end end)
 end
 local function cycle(step)
  local values=options.Categories if not values then return end
  local n=1 for i,v in values do if v.id==self.Category then n=i end end
  local v=values[(n-1+step)%#values+1] self.Category=v.id category.Text=v.label self:Refresh()
 end
 local function trackActions(b,level)
  b:SetAttribute('MenuCustomLabel','Filtrar recompensas')
  b:SetAttribute('MenuResetLabel','Ir ao nível atual')
  Nav:SetActions(b,{
   custom=options.Categories and function() openFilters(options.Categories,self.Category,function(v) self.Category=v.id category.Text=v.label self:Refresh() end) end or nil,
   reset=function() self:Go(data.current,true) end,
   group=function(step) self:Go((level or self.Level)+step*count(),true) end,
  })
 end
 local function bind(b,fn) Nav:Connect(b,fn) trackActions(b) end
 bind(category,function() openFilters(options.Categories,self.Category,function(v) self.Category=v.id category.Text=v.label self:Refresh() end) end)
 bind(mode,function() openFilters(options.Modes,self.Mode,function(v) self.Mode=v.id mode.Text=v.label self:Refresh() end) end)
 bind(prev,function() self:Go(self.Level-count(),true) end) bind(next,function() self:Go(self.Level+count(),true) end) bind(current,function() self:Go(data.current,true) end)
 bind(more,function() local _,rs=selectedReward() self.Reward=self.Reward%math.max(1,#rs)+1 details() end)
 bind(action,function() local reward=selectedReward() if reward and action.Active and options.Equip then options.Equip(reward,function(message) if alive then self:Refresh() if message and message~='' then rewardText.Text..='\n'..message end end end) end end)
 repaint=function()
  footer.Visible=not neoTrack()
  if not neoTrack() then
   for _,box in {header,detail} do
    box.BackgroundTransparency=.12
    box.Edge.Transparency=.3
   end
   filters.Size=UDim2.new(1,0,0,42)
   category.Size=UDim2.new(.5,-5,1,0)
   rewardText.Size=UDim2.new(1,-28,0,66)
  end
  widthFactor=inheritedScale() scale.Scale=1/widthFactor root.Size=UDim2.new(widthFactor,-4,0,root.Size.Y.Offset)
  local focused=Nav:GetFocus() local restore=focused and focused:IsDescendantOf(strip)
  for _,b in cards do b:Destroy() end cards={}
  for _,d in rail:GetChildren() do if d~=fill then d:Destroy() end end
  local width=math.max(280,root.AbsoluteSize.X) local n=count() local first=math.clamp(self.Level-math.floor(n/2),1,math.max(1,data.max-n+1)) local trackWidth=data.kind=='guild' and width>=800 and not neoTrack() and width*.66 or width local cell=(trackWidth-(n-1)*8)/n
  for i=1,n do local level=first+i-1 if level<=data.max then
   local rewards=data.rows[level] or {} local firstReward=rewards[1]
   local b=V.Button(strip,'Level'..level,'',nil) b:SetAttribute('Level',level) b.Position=UDim2.fromOffset((i-1)*(cell+8),0) b.Size=UDim2.fromOffset(cell,196)
   local any=false for _,r in rewards do if r.available==true then any=true end end
   local state=not data.ready and '—' or level==data.current and 'ATUAL' or any and 'DESBLOQUEADO' or level<data.current and #rewards==0 and 'CONCLUÍDO' or 'BLOQUEADO'
   local dot=Instance.new('Frame') dot.Name='LevelMark' dot.Size=UDim2.fromOffset(10,10) dot.AnchorPoint=Vector2.new(.5,.5) dot.Position=UDim2.new((i-.5)/n,0,.5,0) dot.BackgroundColor3=level<=data.current and accent or V.C.Edge dot.BorderSizePixel=0 dot.Parent=rail V.Round(dot,100)
   local l=V.Text(b,'Level','NÍVEL '..level,10,10,cell-20,26,16) l.Font=Enum.Font.GothamBold
   V.Text(b,'State',state,10,40,cell-20,20,10).TextColor3=level<=data.current and accent or V.C.Muted
   local art
   if firstReward and firstReward.kind=='attachment' then art=Instance.new('ImageLabel') art.Name='AttachmentArt' art.Parent=b Art.Apply(art,firstReward.id) end
   if art then art.Position=UDim2.fromOffset(8,65) art.Size=UDim2.fromOffset(cell-16,65) else
    local icon=firstReward and V.Icon(b,firstReward.kind=='finish' and 'Identity' or firstReward.kind=='guild' and 'Clan' or 'sword',math.floor(cell/2-24),72,48,firstReward.color and Color3.fromRGB(table.unpack(firstReward.color)) or accent) if not icon then local empty=V.Text(b,'RewardIcon','—',8,65,cell-16,65,38) empty.TextXAlignment=Enum.TextXAlignment.Center end
   end
   local label=V.Text(b,'Reward',firstReward and firstReward.name or 'Sem recompensa',10,134,cell-20,48,13) label.TextXAlignment=Enum.TextXAlignment.Center
   if #rewards>1 then V.Text(b,'Count','+'..(#rewards-1),cell-32,65,28,20,12) end
   local mark=Instance.new('Frame') mark.Name='Diamond' mark.Size=UDim2.fromOffset(10,10) mark.Position=UDim2.new(.5,-5,0,-5) mark.Rotation=45 mark.BackgroundColor3=accent mark.BorderSizePixel=0 mark.Visible=level==self.Level mark.Parent=b
   if level==self.Level then local edge=V.Edge(b,accent,2) edge.Transparency=0 local outer=Instance.new('UIStroke') outer.Name='Glow' outer.Color=accent outer.Thickness=7 outer.Transparency=.78 outer.Parent=b end
   Nav:Connect(b,function() self.Level=level self.Reward=1 repaint() end)
   Nav:Register(b,function() self.Level=level self.Reward=1 repaint() end,function(step) self:Go(level+step,true) end)
   trackActions(b,level)
   b.NextSelectionUp=category.Visible and category or current b.NextSelectionDown=action.Visible and action or current
   table.insert(cards,b)
  end end
  fill.Size=UDim2.fromScale(math.clamp((data.current-first+.5)/n,0,1),1)
  local x=data.kind=='weapon' and math.floor(width*.34) or (data.kind=='account' or data.clan) and 110 or 16
  for _,l in {name,subtitle,xp} do l.Position=UDim2.fromOffset(x,l.Position.Y.Offset) l.Size=UDim2.new(1,-x-12,0,l.Size.Y.Offset) end
  bar.Position=UDim2.fromOffset(x,112) bar.Size=UDim2.new(1,-x-16,0,10)
  local wide=width>=800
  local cardHeight=wide and 164 or math.clamp(parent.AbsoluteSize.Y-12,110,196)
  header.Size=UDim2.new(1,0,0,wide and 128 or 140)
  filters.Position=UDim2.fromOffset(0,wide and 136 or 150)
  strip.Position=UDim2.fromOffset(0,wide and 190 or 204) strip.Size=UDim2.new(1,0,0,cardHeight)
  rail.Position=UDim2.fromOffset(12,wide and 366 or 410)
  controls.Position=UDim2.fromOffset(0,wide and 382 or 430)
  detail.Position=UDim2.fromOffset(0,wide and 432 or 482) detail.Size=UDim2.new(1,0,0,156)
  note.Position=UDim2.fromOffset(4,wide and 598 or 650)
  for _,b in cards do b.Size=UDim2.fromOffset(b.Size.X.Offset,cardHeight) if wide then b.Reward.Position=UDim2.fromOffset(10,112) b.Reward.Size=UDim2.fromOffset(b.Size.X.Offset-20,44) if b:FindFirstChild('Icon') then b.Icon.Position=UDim2.fromOffset(b.Size.X.Offset/2-20,62) b.Icon.Size=UDim2.fromOffset(40,40) end end end
  if cardHeight<180 then for _,b in cards do
   b.Level.Position=UDim2.fromOffset(10,6) b.Level.TextSize=14 b.State.Position=UDim2.fromOffset(10,32)
   b.Reward.Position=UDim2.fromOffset(10,cardHeight-42) b.Reward.Size=UDim2.fromOffset(b.Size.X.Offset-20,38)
   local icon=b:FindFirstChild('Icon') or b:FindFirstChild('RewardIcon')
   if icon then icon.Position=UDim2.fromOffset(b.Size.X.Offset/2-16,54) icon.Size=UDim2.fromOffset(32,32) end
  end end
  local guild=data.kind=='guild'
  weekly.Visible=guild note.Visible=not guild
  strip.Visible=not guild or data.ready rail.Visible=strip.Visible controls.Visible=strip.Visible detail.Visible=strip.Visible
  strip.Size=UDim2.new(guild and wide and .66 or 1,0,0,cardHeight)
  rail.Size=UDim2.new(guild and wide and .66 or 1,-24,0,3)
  controls.Size=UDim2.new(guild and wide and .66 or 1,0,0,40)
  detail.Size=UDim2.new(guild and wide and .66 or 1,0,0,guild and wide and 74 or 156)
  if guild then
   strip.Position=UDim2.fromOffset(0,150) rail.Position=UDim2.fromOffset(12,wide and 326 or 358) controls.Position=UDim2.fromOffset(0,wide and 344 or 380)
   detail.Position=UDim2.fromOffset(0,wide and 394 or 432)
   rewardName.Position=UDim2.fromOffset(16,wide and 4 or 10) rewardName.Size=UDim2.new(1,-28,0,wide and 25 or 32) rewardName.TextSize=wide and 16 or 20
   rewardText.Position=UDim2.fromOffset(16,wide and 30 or 46) rewardText.Size=UDim2.new(1,-28,0,wide and 40 or 66) rewardText.TextSize=wide and 12 or 14
   weekly.Position=wide and UDim2.new(.68,0,0,150) or UDim2.fromOffset(0,600) weekly.Size=wide and UDim2.new(.32,0,0,222) or UDim2.new(1,0,0,120)
   missions.Size=UDim2.new(1,-28,1,-20) missions.TextYAlignment=Enum.TextYAlignment.Top
   extra.Position=UDim2.fromOffset(0,wide and 480 or 734) extra.Size=UDim2.new(1,0,0,wide and 142 or 200)
   contributors.Position=UDim2.fromOffset(14,10) contributors.Size=UDim2.new(1,-28,1,-20)
   footer.Position=UDim2.fromOffset(4,wide and 632 or 944) root.Size=UDim2.new(widthFactor,-4,0,wide and 676 or 990)
  end
  if data.kind=='weapon' or neoTrack() then
   local neo=neoTrack()
   local headerEdge=header:FindFirstChild('Edge')
   local detailEdge=detail:FindFirstChild('Edge')
   header.BackgroundTransparency=neo and 1 or .12
   detail.BackgroundTransparency=neo and 1 or .12
   headerEdge.Transparency=neo and 1 or .3
   detailEdge.Transparency=neo and 1 or .3
   footer.Visible=not neo
   current.Text=neo and 'Ir ao nível atual' or 'Y · Ir ao atual'
   category.Size=UDim2.new(neo and not options.Modes and 1 or .5,-5,1,0)
   action.Size=neo and UDim2.new(.5,-24,0,44) or UDim2.fromOffset(175,36)
   more.Size=neo and UDim2.new(.5,-24,0,44) or UDim2.fromOffset(189,36)
   more.Position=neo and UDim2.new(.5,8,1,-46) or UDim2.new(1,-205,1,-46)
   if neo then
    local trackY=(options.Categories or options.Modes) and 176 or 128
    local levelHeight=146
    local pagingY=trackY+levelHeight+20
    local detailY=pagingY+54
    local detailHeight=width<600 and 220 or 176
    header.Size=UDim2.new(1,0,0,120)
    filters.Position=UDim2.fromOffset(0,124)
    filters.Size=UDim2.new(1,0,0,44)
    strip.Position=UDim2.fromOffset(0,trackY)
    strip.Size=UDim2.new(1,0,0,levelHeight)
    rail.Position=UDim2.fromOffset(12,trackY+levelHeight+8)
    controls.Position=UDim2.fromOffset(0,pagingY)
    controls.Size=UDim2.new(1,0,0,44)
    detail.Position=UDim2.fromOffset(0,detailY)
    detail.Size=UDim2.new(1,0,0,detailHeight)
    rewardName.Position=UDim2.fromOffset(16,10)
    rewardName.Size=UDim2.new(1,-28,0,32)
    rewardText.Position=UDim2.fromOffset(16,46)
    rewardText.Size=UDim2.new(1,-28,0,detailHeight-98)
    note.Position=UDim2.fromOffset(4,detailY+detailHeight)
    root.Size=UDim2.new(widthFactor,-4,0,detailY+detailHeight+58)
    if guild then
     local sectionsY=data.ready and detailY+detailHeight+12 or 128
     weekly.Position=UDim2.fromOffset(0,sectionsY)
     weekly.Size=UDim2.new(1,0,0,96)
     extra.Position=UDim2.fromOffset(0,sectionsY+108)
     extra.Size=UDim2.new(1,0,0,180)
     contributors.Position=UDim2.fromOffset(14,10)
     contributors.Size=UDim2.new(1,-28,1,-20)
     root.Size=UDim2.new(widthFactor,-4,0,sectionsY+296)
    end
    for _,b in cards do
     local selected=b:GetAttribute('Level')==self.Level
     b.Size=UDim2.fromOffset(cell,levelHeight)
     b.BackgroundTransparency=selected and .42 or .88
     if not selected then b.Edge.Transparency=.76 end
     b.Reward.Position=UDim2.fromOffset(10,104)
     b.Reward.Size=UDim2.fromOffset(cell-20,38)
     local icon=b:FindFirstChild('AttachmentArt') or b:FindFirstChild('Icon') or b:FindFirstChild('RewardIcon')
     if icon then icon.Position=UDim2.fromOffset(cell/2-20,60) icon.Size=UDim2.fromOffset(40,40) end
    end
   else
    filters.Size=UDim2.new(1,0,0,42)
    rewardText.Size=UDim2.new(1,-28,0,66)
    root.Size=UDim2.new(widthFactor,-4,0,760)
   end
  end
  details()
  if restore then self:Focus() end
 end
 function self:Height() return root.Size.Y.Offset*scale.Scale end
 function self:Focus() for _,b in cards do if b:GetAttribute('Level')==self.Level then Nav:Focus(b) return end end end
 function self:DefaultFocus() for _,b in cards do if b:GetAttribute('Level')==self.Level then return b end end return cards[1] end
 local cleaned=false local function cleanup() if cleaned then return end cleaned=true alive=false if popup then popup:Destroy() popup=nil end for _,c in connections do c:Disconnect() end end
 function self:Destroy() cleanup() root:Destroy() end
 root.Destroying:Connect(cleanup)
 local owner=root:FindFirstAncestorOfClass('ScreenGui')
 if owner then table.insert(connections,owner:GetPropertyChangedSignal('Enabled'):Connect(function() if not owner.Enabled and popup then popup:Destroy() popup=nil end end)) end
 Nav:SetCategories(root,cycle)
 table.insert(connections,root:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() local w=math.floor(root.AbsoluteSize.X) if w~=lastWidth and data then lastWidth=w repaint() end end))
 table.insert(connections,parent:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() if alive and data then repaint() end end))
 table.insert(connections,game.Players.LocalPlayer:GetAttributeChangedSignal('SettingInterfaceStyle'):Connect(function() if alive and data then self:Refresh() end end))
 self:Refresh(true) return self
end
return T
