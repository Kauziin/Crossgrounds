local Players=game:GetService("Players")
local player=Players.LocalPlayer
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local S=require(game.ReplicatedStorage.Crossgrounds:WaitForChild("ProgressionSchema"))
local Prestige=require(script.Parent:WaitForChild("PrestigeStyle"))
local remotes=game.ReplicatedStorage.Crossgrounds:WaitForChild("Remotes")
local gui=Instance.new("ScreenGui") gui.Name="ProgressionPanel" gui.ResetOnSpawn=false gui.DisplayOrder=80 gui.Enabled=false gui.Parent=player.PlayerGui
local browser=Cascade.new(gui,"Backdrop","PROGRESSO")
for id,title in {Profile="ESTATÍSTICAS PESSOAIS",Leaders="PLACAR DE LÍDERES",Friends="COMPARATIVO COM AMIGOS"} do browser:AddPane(id,title) end
local cyan=Color3.fromRGB(32,224,229)
local function frame(parent,name,height)
 local f=Instance.new("Frame") f.Name=name f.Size=UDim2.new(1,-6,0,height) f.BackgroundColor3=Color3.fromRGB(16,26,33) f.BackgroundTransparency=.12 f.BorderSizePixel=0 f.Parent=parent
 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,10) c.Parent=f
 local stroke=Instance.new("UIStroke") stroke.Color=Color3.fromRGB(73,97,105) stroke.Transparency=.45 stroke.Parent=f
 return f
end
local function text(parent,value,x,y,w,h,size)
 local t=Instance.new("TextLabel") t.BackgroundTransparency=1 t.Text=value t.Position=UDim2.new(x,8,0,y) t.Size=UDim2.new(w,-16,0,h) t.Font=Enum.Font.GothamMedium t.TextSize=size or 14 t.TextColor3=Theme.Colors.Text t.TextXAlignment=Enum.TextXAlignment.Left t.TextWrapped=true t.Parent=parent return t
end
local function area(parent,name,order)
 local f=Instance.new("Frame") f.Name=name f.Size=UDim2.new(1,-6,0,0) f.AutomaticSize=Enum.AutomaticSize.Y f.BackgroundTransparency=1 f.LayoutOrder=order f.Parent=parent
 local l=Instance.new("UIListLayout") l.Padding=UDim.new(0,7) l.SortOrder=Enum.SortOrder.LayoutOrder l.Parent=f return f
end
local function clear(f) for _,v in f:GetChildren() do if v:IsA("GuiObject") then v:Destroy() end end end
local popup
local function dismiss() if popup then popup:Destroy() popup=nil end end
local function dropdown(parent,name,label,options,get,set,width,x)
 local b=Instance.new("TextButton") b.Name=name b.Text=label b.TextSize=13 b.Size=UDim2.new(width or 1,-6,1,0) b.Position=UDim2.new(x or 0,0,0,0) b.Parent=parent Theme.Button(b)
 Nav:Connect(b,function()
  dismiss()
  local shade=Instance.new("TextButton") shade.Name="FilterPopup" shade.Text="" shade.BackgroundTransparency=1 shade.Size=UDim2.fromScale(1,1) shade.ZIndex=50 shade.Parent=browser.Panel popup=shade
  local ratio=browser.Panel.AbsoluteSize.X/math.max(1,browser.Panel.Size.X.Offset)
  local width=math.max(150,b.AbsoluteSize.X/ratio) local height=math.min(240,#options*40)
  local list=Instance.new("ScrollingFrame") list.BackgroundColor3=Color3.fromRGB(13,24,33) list.BorderSizePixel=0 list.Size=UDim2.fromOffset(width,height)
  local position=(b.AbsolutePosition-browser.Panel.AbsolutePosition)/ratio
  list.Position=UDim2.fromOffset(math.max(0,math.min(position.X,browser.Panel.Size.X.Offset-width)),math.max(0,math.min(position.Y+b.AbsoluteSize.Y/ratio,browser.Panel.Size.Y.Offset-height))) list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new() list.ScrollBarThickness=3 list.ZIndex=51 list.Parent=shade
  local layout=Instance.new("UIListLayout") layout.Parent=list
  Nav:Connect(shade,function() dismiss() Nav:Focus(b) end)
  local firstOption
  for _,option in options do
   local item=Instance.new("TextButton") item.Text=option.label item.Size=UDim2.new(1,-4,0,40) item.TextSize=13 item.ZIndex=52 item.Parent=list Theme.Button(item)
   firstOption=firstOption or item
   Nav:Connect(item,function() set(option.id) b.Text=get().."  v" dismiss() Nav:Focus(b) end)
  end
  task.defer(function() if firstOption and firstOption.Parent then Nav:Focus(firstOption) end end)
 end)
 return b
end
local function modeOptions()
 local o={} for _,m in S.Modes do table.insert(o,{id=m,label=S.Names[m]}) end return o
end
local mine={}
local function readLocal()
 local d={userId=player.UserId,name=player.DisplayName}
 for _,m in S.Modes do for _,k in S.Fields do local key=S.Key(m,k) d[key]=player:GetAttribute("Progress"..key) or 0 end end
 return d
end
local profileMode,compareMode,rankMode,metric,scope="general","general","general","XP","global"
local profileList=browser.Panes.Profile.List
local filter=frame(profileList,"Filter",36) filter.LayoutOrder=0
local profileBody=area(profileList,"PersonalStatistics",1)
local function identity(parent,data,width,x)
 local f=frame(parent,"Profile",112) f.Size=UDim2.new(width or 1,-6,0,112) f.Position=UDim2.fromScale(x or 0,0)
 local avatar=Instance.new("ImageLabel") avatar.BackgroundTransparency=1 avatar.Size=UDim2.fromOffset(64,64) avatar.Position=UDim2.fromOffset(10,12) avatar.Image="rbxthumb://type=AvatarHeadShot&id="..data.userId.."&w=150&h=150" avatar.Parent=f
 local name=text(f,data.name,0,10,1,24,18) name.Position=UDim2.fromOffset(82,10) name.Size=UDim2.new(1,-90,0,24) name.TextTruncate=Enum.TextTruncate.AtEnd name.TextWrapped=false
 local xp=data.XP or 0 local level=S.Level(xp)
 local detail=text(f,"Nível "..level.."  ·  "..(data.Coins or 0).." moedas",0,39,1,22,12) detail.Position=UDim2.fromOffset(82,39) detail.Size=UDim2.new(1,-90,0,22)
 local prev=math.floor(250*((level-1)^1.45)) local nextXP=math.floor(250*(level^1.45))
 text(f,xp.." XP  ·  faltam "..math.max(0,nextXP-xp).." XP",0,76,1,18,11)
 local bar=Instance.new("Frame") bar.BorderSizePixel=0 bar.BackgroundColor3=Color3.fromRGB(49,63,71) bar.Position=UDim2.new(0,10,1,-9) bar.Size=UDim2.new(1,-20,0,4) bar.Parent=f
 local fill=Instance.new("Frame") fill.BorderSizePixel=0 fill.BackgroundColor3=cyan fill.Size=UDim2.fromScale(math.clamp((xp-prev)/math.max(1,nextXP-prev),0,1),1) fill.Parent=bar
 return f
end
local function renderProfile()
 local scroll=profileList.CanvasPosition
 mine=readLocal() clear(profileBody)
 if player:GetAttribute("ProgressionReady")~=true then
  text(profileBody,player:GetAttribute("ProgressionLoadError") and "Não foi possível carregar seu progresso. Reconecte para tentar novamente; os dados salvos foram preservados." or "Carregando seu progresso...",0,0,1,72,14)
  return
 end
 identity(profileBody,mine).LayoutOrder=0
 local gridHolder=frame(profileBody,"Metrics",200) gridHolder.LayoutOrder=1 gridHolder.BackgroundTransparency=1
 local grid=Instance.new("UIGridLayout") grid.CellPadding=UDim2.fromOffset(8,8) grid.SortOrder=Enum.SortOrder.LayoutOrder grid.Parent=gridHolder
 for i,key in S.Display[profileMode] do
  local card=frame(gridHolder,key,74) card.LayoutOrder=i
  text(card,S.Labels[key],0,8,1,22,12).TextColor3=Theme.Colors.Muted
  local v=text(card,S.Format(key,S.Value(mine,profileMode,key)),0,31,1,31,23) v.Font=Enum.Font.GothamBold
 end
 local function sizeGrid()
  local cols=gridHolder.AbsoluteSize.X>=650 and 4 or gridHolder.AbsoluteSize.X>=420 and 3 or 2
  grid.CellSize=UDim2.new(1/cols,-8,0,78) gridHolder.Size=UDim2.new(1,-6,0,math.ceil(#S.Display[profileMode]/cols)*86)
 end
 gridHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(sizeGrid) sizeGrid()
 local title=text(profileBody,"POR MODALIDADE",0,0,1,28,14) title.LayoutOrder=2 title.TextColor3=cyan
 local modes=frame(profileBody,"ModeCards",152) modes.LayoutOrder=3 modes.BackgroundTransparency=1
 local mg=Instance.new("UIGridLayout") mg.CellPadding=UDim2.fromOffset(8,8) mg.CellSize=UDim2.new(.5,-5,0,68) mg.SortOrder=Enum.SortOrder.LayoutOrder mg.Parent=modes
 for i,m in S.Modes do if m~="general" then
  local mode=m local b=Instance.new("TextButton") b.LayoutOrder=i b.TextSize=14 b.TextWrapped=true b.Text=S.Names[m].."\n"..S.Labels[S.Primary[m]]..": "..S.Value(mine,m,S.Primary[m]) b.Parent=modes Theme.Button(b)
  Nav:Connect(b,function() profileMode=mode renderProfile() end)
 end end
 local note=text(profileBody,"Dados por modo registrados a partir desta atualização. Totais históricos no Geral. Duels depende de partidas desse modo para registrar resultados.",0,0,1,46,11) note.LayoutOrder=20 note.TextColor3=Theme.Colors.Muted
 task.defer(function() profileList.CanvasPosition=scroll end)
end
dropdown(filter,"Mode","Geral  v",modeOptions(),function() return S.Names[profileMode] end,function(v) profileMode=v renderProfile() end)
local leaderList=browser.Panes.Leaders.List
local rankFilters=frame(leaderList,"Filters",40) rankFilters.LayoutOrder=0
local rankStatus=text(leaderList,"Carregando classificação...",0,0,1,48,12) rankStatus.LayoutOrder=1
local rankBody=area(leaderList,"Ranking",2)
local own=frame(browser.Panes.Leaders.Frame,"PersonalPosition",48) own.Position=UDim2.new(0,10,1,-58) own.Size=UDim2.new(1,-20,0,48)
local ownText=text(own,"",0,0,1,48,14) ownText.TextColor3=cyan
leaderList.Size=UDim2.new(1,-20,1,-124)
local rankingToken=0
local function loadRanking()
 rankingToken+=1 local token=rankingToken clear(rankBody) rankStatus.Text="Carregando classificação..." ownText.Text="Consultando sua posição..."
 task.spawn(function()
  local remote=remotes:WaitForChild("GetProgressRanking",10)
  local ok,data,message=pcall(function() if remote then return remote:InvokeServer(rankMode,metric,scope) end end)
  if token~=rankingToken then return end
  if not ok or not data then rankStatus.Text=message or "Ranking indisponível no momento." ownText.Text="Posição indisponível" return end
  rankStatus.Text=(scope=="global" and "CLASSIFICAÇÃO GLOBAL" or "CLASSIFICAÇÃO ENTRE AMIGOS").." · "..S.Labels[metric].." / "..S.Names[rankMode].."\n"..(data.message or "")
  for i,entry in data.entries do
   local row=frame(rankBody,"Rank"..i,42) row.LayoutOrder=i
   local badge=text(row,"#"..entry.rank,0,0,.12,42,15)
   if i<=3 then badge.TextColor3=({Color3.fromRGB(255,218,104),Color3.fromRGB(211,227,240),Color3.fromRGB(222,161,111)})[i] end
   local name=text(row,entry.name,.12,0,.61,42,14)
   if i<=3 and scope=="global" and S.Primary[rankMode]==metric then Prestige.Apply(name,i) end
   local value=text(row,S.Format(metric,entry.value),.73,0,.27,42,14) value.TextXAlignment=Enum.TextXAlignment.Right
  end
  local personal=data.personal
  ownText.Text=personal and ((personal.rank and "#"..personal.rank or personal.label or "Posição ainda indisponível").."  ·  Você  ·  "..S.Format(metric,personal.value)) or "Ainda sem classificação"
 end)
end
local metricButton
local function metricOptions() local o={} for _,m in S.Metrics[rankMode] do table.insert(o,{id=m,label=S.Labels[m]}) end return o end
-- Rebuild metric selector when the mode changes, so incompatible filters cannot be sent.
local function rebuildMetric()
 if metricButton then metricButton:Destroy() end
 metricButton=dropdown(rankFilters,"Metric",S.Labels[metric].."  v",metricOptions(),function() return S.Labels[metric] end,function(v) metric=v loadRanking() end,.34,0)
end
rebuildMetric()
dropdown(rankFilters,"Scope","Global  v",{{id="global",label="Global"},{id="friends",label="Amigos"}},function() return scope=="global" and "Global" or "Amigos" end,function(v) scope=v loadRanking() end,.26,.34)
dropdown(rankFilters,"Mode","Geral  v",modeOptions(),function() return S.Names[rankMode] end,function(v) rankMode=v metric=S.Metrics[v][1] rebuildMetric() loadRanking() end,.4,.6)
local friendList=browser.Panes.Friends.List
local compareFilters=frame(friendList,"Filters",40) compareFilters.LayoutOrder=0
local friendStatus=text(friendList,"Carregando amigos...",0,0,1,42,12) friendStatus.LayoutOrder=1
local comparison=area(friendList,"Comparison",2)
local friendRecords,selected,friendButton={},nil,nil
local function renderComparison()
 clear(comparison) if not selected then return end
 local mine=readLocal()
 local pair=frame(comparison,"Profiles",112) pair.LayoutOrder=0 pair.BackgroundTransparency=1
 identity(pair,mine,.5,0) identity(pair,selected,.5,.5)
 for i,key in S.Display[compareMode] do
  local a,b=S.Value(mine,compareMode,key),S.Value(selected,compareMode,key)
  local row=frame(comparison,key,66) row.LayoutOrder=i
  text(row,S.Labels[key],0,4,.38,23,12)
  text(row,S.Format(key,a),.38,4,.2,23,13)
  text(row,S.Format(key,b),.58,4,.2,23,13)
  local delta=a-b local d=text(row,(delta>0 and "+" or "")..S.Format(key,delta),.78,4,.22,23,12)
  if key=="Deaths" or key=="Losses" then d.TextColor3=delta<0 and Color3.fromRGB(68,220,167) or delta>0 and Color3.fromRGB(242,119,119) or Theme.Colors.Muted
  elseif key=="PlaySeconds" or key=="Coins" then d.TextColor3=Theme.Colors.Muted
  else d.TextColor3=delta>0 and Color3.fromRGB(68,220,167) or delta<0 and Color3.fromRGB(242,119,119) or Theme.Colors.Muted end
  for j,value in {a,b} do
   local bar=Instance.new("Frame") bar.BorderSizePixel=0 bar.Position=UDim2.new(.04,0,0,32+(j-1)*13) bar.Size=UDim2.new(.92*value/math.max(1,a,b),0,0,6) bar.BackgroundColor3=j==1 and cyan or Color3.fromRGB(206,219,237) bar.Parent=row
  end
 end
end
local loadedAt=-100 local loading=false
local function loadFriends()
 if loading or os.clock()-loadedAt<20 then return end loading=true friendStatus.Text="Carregando amigos com histórico..."
 task.spawn(function()
  local remote=remotes:WaitForChild("GetFriendProgress",10)
  local ok,data,message=pcall(function() if remote then return remote:InvokeServer() end end) loading=false
  if not ok or not data then friendStatus.Text=message or "Amigos indisponíveis no momento." return end
  loadedAt=os.clock() friendRecords={} local options={}
  for _,row in data do if not row.self then friendRecords[row.userId]=row table.insert(options,{id=row.userId,label=row.name}) end end
  friendStatus.Text=message or (#options==0 and "Nenhum amigo com histórico disponível." or "Você à esquerda · amigo à direita · diferenças em relação ao amigo")
  if friendButton then friendButton:Destroy() end
  selected=options[1] and friendRecords[options[1].id] or nil
  if #options>0 then friendButton=dropdown(compareFilters,"Friend",selected.name.."  v",options,function() return selected.name end,function(id) selected=friendRecords[id] renderComparison() end,.6,0) end
  renderComparison()
 end)
end
dropdown(compareFilters,"Mode","Geral  v",modeOptions(),function() return S.Names[compareMode] end,function(v) compareMode=v renderComparison() end,.4,.6)
local function close() dismiss() player:SetAttribute("ProgressionMenuOpen",false) Nav:OpenMenu("Main") end
browser.OnClose=close
local buttons={}
for _,entry in {{"Profile","Estatísticas pessoais"},{"Leaders","Placar de líderes"},{"Friends","Comparativo com amigos"}} do
 local id=entry[1] buttons[id]=browser:Button("RootPane",id,entry[2],function() dismiss() browser:Push({"RootPane",id}) if id=="Profile" then renderProfile() elseif id=="Leaders" then loadRanking() else loadFriends() end end)
end
browser:Button("RootPane","Close","Voltar ao menu",close)
Nav:SetBack(browser.Panel,function() if popup then dismiss() else close() end end,buttons.Profile)
local refreshPending=false
player.AttributeChanged:Connect(function(key)
 if not gui.Enabled or key:sub(1,8)~="Progress" or refreshPending then return end
 refreshPending=true task.defer(function() refreshPending=false renderProfile() renderComparison() end)
end)
local function show()
 local on=player:GetAttribute("ProgressionMenuOpen")==true gui.Enabled=on browser:SetOpen(on) dismiss()
 if on then browser:Push({"RootPane","Profile"}) profileList.CanvasPosition=Vector2.zero renderProfile() end
end
player:GetAttributeChangedSignal("ProgressionMenuOpen"):Connect(show)
Nav.MenuRequested:Connect(function(id) if table.find({"Main","Hub","Settings","Resume","Playlist"},id) then player:SetAttribute("ProgressionMenuOpen",false) end end)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(dismiss)
script:SetAttribute("Initialized",true) show()
