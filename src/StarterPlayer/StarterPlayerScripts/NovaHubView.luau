-- New presentation; callbacks and authoritative catalog stay in HubController.
local View={}
local Theme=require(script.Parent.MenuTheme)
local Accent=require(script.Parent.AccentTheme)
local Nav=require(script.Parent.MenuNavigation)
local Icons=require(game.ReplicatedStorage.Crossgrounds.InterfaceIcons)
local player=game.Players.LocalPlayer
function View.new(options)
 local gui=Instance.new('ScreenGui')gui.Name='NovaHub'gui.Enabled=false gui.ResetOnSpawn=false gui.DisplayOrder=60 gui.IgnoreGuiInset=false gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets gui.Parent=player.PlayerGui
 local function make(class,parent,name)local o=Instance.new(class)o.Name=name o.Parent=parent if o:IsA('GuiObject')then o.BorderSizePixel=0 end return o end
 local panel=make('Frame',gui,'Panel')panel.Size=UDim2.fromScale(1,1)panel.BackgroundColor3=Color3.fromRGB(3,12,18)panel.BackgroundTransparency=.12
 local gradient=make('UIGradient',panel,'WorldFade')gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.02),NumberSequenceKeypoint.new(1,.6)})gradient.Rotation=15
 local backdrop=Instance.new('ScreenGui')backdrop.Name='NeoPlayBackdrop'backdrop.ResetOnSpawn=false backdrop.IgnoreGuiInset=true backdrop.ScreenInsets=Enum.ScreenInsets.None backdrop.DisplayOrder=gui.DisplayOrder-1 backdrop.Enabled=false backdrop.Parent=gui.Parent
 local scrim=make('Frame',backdrop,'FullViewport')scrim.Size=UDim2.fromScale(1,1)scrim.BackgroundColor3=Color3.new()scrim.BackgroundTransparency=.07
 gradient.Parent=scrim gradient.Rotation=0 gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.6,.08),NumberSequenceKeypoint.new(1,.28)})panel.BackgroundTransparency=1
 gui:GetPropertyChangedSignal('Enabled'):Connect(function()backdrop.Enabled=gui.Enabled end)gui.Destroying:Once(function()backdrop:Destroy()end)
 local help=require(script.Parent:WaitForChild('NeoNavigationHints')).new(panel)panel:SetAttribute('NeoIconHints',true)
 local function refreshHelp()help:Refresh(Theme.Mobile()and Enum.PreferredInput.Touch or nil,Nav:GetHintContext(panel))end
 local content=make('Frame',panel,'Content')content.BackgroundTransparency=1
 local scale=make('UIScale',content,'Fit')
 local function text(parent,name,value,size)
  local t=make('TextLabel',parent,name)t.BackgroundTransparency=1 t.Font=Enum.Font.GothamMedium t.TextSize=size t.Text=value t.TextXAlignment=Enum.TextXAlignment.Left t.TextYAlignment=Enum.TextYAlignment.Center t.TextWrapped=true Accent.Role(t,'TextColor3','Text')return t
 end
 local brand=text(content,'Brand','CROSSGROUNDS',15)brand.Font=Enum.Font.GothamBold
 local title=text(content,'Title','CROSSGROUNDS',60)title.Font=Enum.Font.GothamBlack
 local description=text(content,'Description','',15)Accent.Role(description,'TextColor3','Muted')
 local page='home'local selected='ctf'local buttons={}local data local rows={}local selectedEntry local height=600 local width=1000
 local self={Gui=gui,Panel=panel}local connections={}
 local function hook(signal,fn)local c=signal:Connect(fn)table.insert(connections,c)end
 local function paint(b)
  local on=Nav:GetFocus()==b or b:GetAttribute('Chosen')or b:GetAttribute('NeoHover')
  local home=b:GetAttribute('NeoHome')==true
  local primary=b:GetAttribute('NovaPrimary')
  Accent.Role(b,'BackgroundColor3',on and 'Selected' or 'Card')b.BackgroundTransparency=on and .35 or 1
  Accent.Role(b,'TextColor3','Text')
  local edge=b:FindFirstChildOfClass('UIStroke')if edge then Accent.Role(edge,'Color',on and 'Accent' or 'Border')edge.Transparency=on and .05 or 1 end
  local marker=b:FindFirstChild('Diamond')if marker then marker.Visible=Nav:GetFocus()==b end
 end
 local function button(parent,name,label,fn,primary)
  local b=make('TextButton',parent,name)b.Text=label b.Font=Enum.Font.GothamMedium b.TextSize=16 b.TextWrapped=true b.AutoButtonColor=false b:SetAttribute('NovaPrimary',primary==true)
  Accent.Role(b,'TextColor3',primary and 'Surface' or 'Text')
  local corner=make('UICorner',b,'Corner')corner.CornerRadius=UDim.new(0,10)
  local edge=make('UIStroke',b,'Edge')edge.ApplyStrokeMode=Enum.ApplyStrokeMode.Border edge.Thickness=1.5
  local marker=make('Frame',b,'Diamond')marker.Size=UDim2.fromOffset(8,8)marker.AnchorPoint=Vector2.new(.5,.5)marker.Position=UDim2.fromScale(0,.5)marker.Rotation=45 marker.Visible=false Accent.Role(marker,'BackgroundColor3','Accent')
  b.MouseEnter:Connect(function()b:SetAttribute('NeoHover',true)paint(b)end)
  b.MouseLeave:Connect(function()b:SetAttribute('NeoHover',false)paint(b)end)
  Nav:Connect(b,fn)table.insert(buttons,b)paint(b)return b
 end
 local backButton local show
 local list=make('ScrollingFrame',content,'Destinations')list.BackgroundTransparency=1 list.ScrollBarThickness=3 list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new()Accent.Role(list,'ScrollBarImageColor3','Accent')
 local grid=make('UIGridLayout',list,'Grid')grid.CellPadding=UDim2.fromOffset(12,12)grid.SortOrder=Enum.SortOrder.LayoutOrder
 local modeCards
 local rule=make('Frame',content,'TitleRule')rule.Size=UDim2.fromOffset(64,3)Accent.Role(rule,'BackgroundColor3','Accent')
 local detail=text(content,'ModeDetails','',14)Accent.Role(detail,'TextColor3','Muted')
 local primary=button(content,'Enter','Entrar',function()if page=='home'then show('modes',true)return end if selectedEntry and selectedEntry.canEnter then options.Play(selected,false)end end,true)
 local practice=button(content,'PracticeRange','Practice Range',function()options.Play('ctf',true)end)
 local cancel=button(content,'CancelEntry','Cancelar entrada',options.Cancel)
 local entryStatus=make('Frame',content,'EntryStatus')
 entryStatus.BackgroundTransparency=.25
 Accent.Role(entryStatus,'BackgroundColor3','Surface')
 make('UICorner',entryStatus,'Corner').CornerRadius=UDim.new(0,8)
 local status=text(entryStatus,'Status','',14)
 status.TextTruncate=Enum.TextTruncate.AtEnd
 cancel.Parent=entryStatus
  local function focusFirst()task.delay(.08,function()if gui.Enabled then Nav:Focus(page=='modes'and modeCards and modeCards:DefaultFocus()or page=='home'and primary or rows[1]or backButton)end end)end
 local function clear()for _,b in rows do b:Destroy()end rows={}local live={}for _,b in buttons do if b.Parent then table.insert(live,b)end end buttons=live end
 local function refreshData()
  selectedEntry=nil
  for _,entry in data and data.catalog or {}do if entry.id==selected then selectedEntry=entry end end
  local q=data and data.queue or {state='idle'}
  detail.Text=selectedEntry and selectedEntry.description or 'Selecione uma modalidade.'
  local available=selectedEntry and selectedEntry.canEnter==true
  primary.Text=page=='home'and 'Jogar  →'or options.Pending()and 'Aguarde…'or available and 'Entrar em '..selectedEntry.name or 'Em desenvolvimento'
  primary.Active=page=='home'or available==true and not options.Pending()primary.Selectable=primary.Active primary.TextTransparency=primary.Active and 0 or .45
  practice.Visible=false practice.Active=available==true and not options.Pending()practice.Selectable=practice.Active
  cancel.Visible=page=='modes'and(q.state=='joining'or q.state=='ready')
  local message=options.Error()or data and data.error or (q.state~='idle'and q.message)or ''
  if message=='' then
   message=({joining='Preparando entrada…',ready='Entrada pronta. Confirme pelo card.',entering='Entrando na modalidade…',travelling='Conectando ao servidor…',failed='Não foi possível entrar. Tente novamente.'})[q.state] or (options.Pending() and 'Preparando entrada…' or '')
  end
  status.Text=message
  entryStatus.Visible=page=='modes' and (message~='' or cancel.Visible)
  for _,b in rows do b:SetAttribute('Chosen',page=='modes'and b.Name==selected)paint(b)end
 end
 function self:Layout()
  refreshHelp()
  local v=Theme.MenuBounds(panel.AbsoluteSize)if v.X<100 then return end
  local desired=math.clamp(player:GetAttribute('SettingMenuScale')or 1,.8,1.3)
  scale.Scale=math.min(desired,math.max(.8,(v.X-32)/600))
  width=math.min(1400,(v.X-80)/scale.Scale) height=math.min(850,(v.Y-16)/scale.Scale)
  content.AnchorPoint=Vector2.new(.5,.5)content.Position=UDim2.fromScale(.5,.5)content.Size=UDim2.fromOffset(width,height)
  local compact=height<480 local fs=player:GetAttribute('SettingFontScale')or 1
  brand.Position=UDim2.fromOffset(0,0)brand.Size=UDim2.new(1,-130,0,30)brand.TextSize=14*fs
  backButton.Position=UDim2.new(1,-120,0,0)backButton.Size=UDim2.fromOffset(120,44)
  local top=compact and 46 or 90
  title.Position=UDim2.fromOffset(0,top)title.Size=UDim2.new(1,0,0,compact and 48 or 80)title.TextSize=math.min(compact and 32 or page=='home'and 64 or 42,math.max(24,width/(page=='home'and 11 or 15)))*fs
  description.Position=UDim2.fromOffset(0,top+(compact and 50 or 82))description.Size=UDim2.new(1,0,0,compact and 36 or 44)description.TextSize=14*fs
  description.Visible=not(compact and page=='modes')
  local y=compact and (page=='modes'and 96 or 128)or top+140
  local homeY=y if page=='home'then y+=compact and 64 or 88 end
  local bottom=page=='modes'and(compact and 120 or 164)or 12
  list.Position=UDim2.fromOffset(4,y)list.Size=UDim2.new(1,-8,0,math.max(60,height-y-bottom))
  local homeWidth=math.min(width,660)
  if page=='home'then list.Size=UDim2.fromOffset(homeWidth,math.max(60,height-y-bottom))end
  local columns=page=='modes'and (width>=1050 and 3 or width>=640 and 2 or 1)or width>=700 and 2 or 1
  grid.CellSize=UDim2.new(1/columns,-12,0,(page=='modes'and(compact and 64 or 96)or compact and 50 or 70)*math.max(1,fs))grid.FillDirectionMaxCells=columns
  for _,b in rows do b.TextSize=16*fs end
  detail.Position=UDim2.new(0,4,1,compact and -116 or -156)detail.Size=UDim2.new(1,-8,0,compact and 34 or 48)detail.TextSize=13*fs
  primary.Position=page=='home'and UDim2.fromOffset(4,homeY)or UDim2.new(0,4,1,compact and -76 or -100)primary.Size=page=='home'and UDim2.fromOffset(math.min(width-8,550),compact and 52 or 64)or UDim2.new(.45,-10,0,52)
  practice.Position=UDim2.new(.45,4,1,compact and -76 or -100)practice.Size=UDim2.new(.32,-10,0,52)
  if page=='modes'then
   brand.Text='CROSSGROUNDS  /  JOGAR'
   title.Text='JOGAR'title.Position=UDim2.fromOffset(4,compact and 36 or 44)title.Size=UDim2.new(1,-8,0,44)title.TextSize=compact and 27 or 34
   description.Position=UDim2.fromOffset(4,90)description.Size=UDim2.new(1,-8,0,28)
   y=compact and 86 or 126
   local cancelWidth=width<520 and 126 or 168
   entryStatus.Position=UDim2.fromOffset(4,y)
   entryStatus.Size=UDim2.new(1,-8,0,52)
   status.Position=UDim2.fromOffset(12,0)
   status.Size=UDim2.new(1,cancel.Visible and -cancelWidth-24 or -24,1,0)
   status.TextSize=13*fs
   cancel.AnchorPoint=Vector2.new(1,0)
   cancel.Position=UDim2.new(1,-4,0,4)
   cancel.Size=UDim2.fromOffset(cancelWidth,44)
   cancel.TextSize=13*fs
   if entryStatus.Visible then y+=60 end
   list.Position=UDim2.fromOffset(4,y)
   list.Size=UDim2.new(1,-8,0,math.max(120,height-y-(compact and 36 or 48)))
   primary.Visible=false detail.Visible=false
   if modeCards then modeCards:Resize()end
  end
  local home=page=='home'
  brand.Visible=not home backButton.Visible=not home rule.Visible=home
  if home then
   local inset=v.X*.06/scale.Scale local insetY=compact and 10 or v.Y*.04/scale.Scale
   content.AnchorPoint=Vector2.zero content.Position=UDim2.fromOffset(inset,insetY)
   local topY=compact and 4 or 38 local titleH=compact and 44 or 80
   title.Position=UDim2.fromOffset(0,topY)title.Size=UDim2.fromOffset(math.min(width,760),titleH)
   Accent.Role(title,'TextColor3','Accent')description.Visible=false
   rule.Position=UDim2.fromOffset(4,topY+titleH+8)
   local start=topY+titleH+(compact and 24 or 46)local rowH=math.max(44,(compact and 46 or 54)*fs)
   local menuWidth=math.min(width-12,compact and 350 or 420)
   primary.Position=UDim2.fromOffset(4,start)primary.Size=UDim2.fromOffset(menuWidth,rowH)primary.Text='Jogar'
   list.Position=UDim2.fromOffset(4,start+rowH+4)list.Size=UDim2.fromOffset(menuWidth+4,math.max(44,height-insetY-start-rowH-12))
   grid.FillDirectionMaxCells=1 grid.CellPadding=UDim2.fromOffset(0,4)grid.CellSize=UDim2.new(1,-4,0,rowH)
  else Accent.Role(title,'TextColor3',page=='modes'and 'Accent'or 'Text')end
  for _,b in buttons do if b.Parent then
   local isHome=home and(b==primary or b.Parent==list)
   b:SetAttribute('NeoHome',isHome)b.TextXAlignment=(isHome or b.Parent==list)and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
   local pad=b:FindFirstChild('HomeInset')if not pad then pad=make('UIPadding',b,'HomeInset')end pad.PaddingLeft=UDim.new(0,isHome and 54 or b.Parent==list and 16 or 0)pad.PaddingRight=UDim.new(0,isHome and 32 or 0)
   local icon=b:FindFirstChild('HomeIcon')
   if isHome and not icon then local role=({Enter='Play',Armaments='Weapons',Career='Career',Social='Social',Settings='Settings',Music='Music',Explore='StayLobby'})[b.Name]if role then icon=Icons.Image(b,role,22,Accent.Color())if icon then icon.Name='HomeIcon'icon.AnchorPoint=Vector2.new(0,.5)icon.Position=UDim2.new(0,-36,.5,0)Accent.Role(icon,'ImageColor3','Muted')end end end
   if icon then icon.Visible=isHome end
   local line=b:FindFirstChild('HomeDivider')if not line then line=make('Frame',b,'HomeDivider')line.Position=UDim2.new(0,-50,1,-1)line.Size=UDim2.new(1,78,0,1)Accent.Role(line,'BackgroundColor3','Border')line.BackgroundTransparency=.75 end line.Visible=isHome and Nav:GetFocus()~=b
   paint(b)
  end end
 end
 show=function(id,focus)
  if id=='home'then options.Home()return end
  page=id clear()list.CanvasPosition=Vector2.zero
  if modeCards then modeCards:SetVisible(id=='modes')end
  title.Text=({home='CROSSGROUNDS',modes='Escolha seu confronto',career='Carreira',social='Social',armaments='Armamentos'})[id]
  description.Text=({home='Seu próximo confronto começa aqui.',modes='Escolha uma modalidade para jogar ou entrar no treino.',career='Sua identidade, evolução e conquistas.',social='Amigos, grupo e guilda.',armaments='O equipamento pertence à modalidade. Entre para escolher e editar sua classe.'})[id]
  local function add(name,label,fn,isPrimary)local b=button(list,name,label,fn,isPrimary)b.LayoutOrder=#rows+1 table.insert(rows,b)end
  if id=='home'then
   add('Armaments','Armamentos',function()show('armaments',true)end)
   add('Career','Carreira',function()show('career',true)end)
   add('Social','Social',function()show('social',true)end)
   add('Settings','Configurações',function()Nav:OpenMenu('Settings')end)
   add('Music','Música / Playlist',function()Nav:OpenMenu('Playlist')end)
   add('Explore','Explorar o lobby',options.Stay)
  elseif id=='modes'then
   -- Cards own their shortcuts; no second row of large external actions.
  elseif id=='career'then
   for _,entry in {{'Career','Perfil e identidade'},{'Progress','Estatísticas e progressão'},{'GuildProgress','Progresso da guilda'}}do add(entry[1],entry[2],function()Nav:OpenMenu(entry[1])end)end
  elseif id=='social'then
   add('Social','Amigos e grupo',function()Nav:OpenMenu('Social')end)add('Clan','Guilda',function()Nav:OpenMenu('Clan')end)
  else add('Modes','Escolher modalidade',function()show('modes',true)end,true)end
  primary.Visible=id=='modes'or id=='home'detail.Visible=id=='modes'
  refreshData()self:Layout()
  if self.Transition then self.Transition:Cancel()end
  if gui.Enabled and not Theme.ReducedMotion()then local target=content.Position content.Position=target+UDim2.fromOffset(10,0)self.Transition=game:GetService('TweenService'):Create(content,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=target})self.Transition:Play()end
  if focus then focusFirst()end
 end
 backButton=button(content,'Back','Voltar',function()if page=='home'then options.Stay()else show('home',true)end end)
 modeCards=require(script.Parent.ModeSelectGrid).new(list,Nav,{
  Play=function(id)options.Play(id,false)end,
  Practice=function(id)options.Play(id,true)end,
  Details=function(id)
   local entry for _,e in data and data.catalog or {}do if e.id==id then entry=e break end end
   require(script.Parent.MenuDialog).new({Navigation=Nav,Title=entry and entry.name or id,Message=entry and(entry.description..'\n\n'..(entry.reason or ''))or 'Carregando catálogo.',Actions={{Text='Voltar'}}})
  end,
 })
 Nav:SetBack(panel,function()if page=='home'then options.Stay()else show('home',true)end end,primary)
 hook(Nav.FocusChanged,function()if gui.Enabled then refreshHelp()for _,b in buttons do if b.Parent then paint(b)end end end end)
 hook(Nav.HintContextChanged,refreshHelp)
 hook(game:GetService('UserInputService').TextBoxFocused,refreshHelp)
 hook(game:GetService('UserInputService').TextBoxFocusReleased,function()task.defer(refreshHelp)end)
 hook(game:GetService('GuiService').MenuOpened,refreshHelp)
 hook(game:GetService('GuiService').MenuClosed,function()task.defer(refreshHelp)end)
 hook(panel:GetPropertyChangedSignal('AbsoluteSize'),function()self:Layout()end)
 for _,key in {'SettingMenuScale','SettingFontScale','SettingHighContrast'}do hook(player:GetAttributeChangedSignal(key),function()self:Layout()end)end
 Theme.ObserveMobile(function()self:Layout()end)
 hook(require(script.Parent.InputMode).Changed,refreshHelp)
 hook(require(script.Parent.InputIcons).Changed,refreshHelp)
 Accent.Bind(gui)
 function self:Update(value)
  local rebuild=page=='modes'and data==nil and value~=nil
  data=value
  modeCards:Update(data and data.catalog or {})
  if rebuild then show(page,false)return end
  local wasVisible,wasCancelable=entryStatus.Visible,cancel.Visible
  refreshData()
  if wasVisible~=entryStatus.Visible or wasCancelable~=cancel.Visible then self:Layout() end
 end
 function self:SetOpen(on)local changed=gui.Enabled~=on gui.Enabled=on if changed and on then self:Layout()focusFirst()end end
 function self:Home()show('home',gui.Enabled)end
 function self:Modes()show('modes',gui.Enabled)end
 show('modes',false)return self
end
return View
