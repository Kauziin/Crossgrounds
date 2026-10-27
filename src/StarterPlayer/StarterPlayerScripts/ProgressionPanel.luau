local Players=game:GetService("Players")
local player=Players.LocalPlayer
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local V=require(script.Parent:WaitForChild("ProgressionView"))
local S=require(game.ReplicatedStorage.Crossgrounds:WaitForChild("ProgressionSchema"))
local Prestige=require(script.Parent:WaitForChild("PrestigeStyle"))
local remotes=game.ReplicatedStorage.Crossgrounds:WaitForChild("Remotes")
local C=V.C
local gui=Instance.new("ScreenGui") gui.Name="ProgressionPanel" gui.ResetOnSpawn=false gui.DisplayOrder=80 gui.Enabled=false
-- Build before parenting so the global theme sees the intended typography.
local view=V.new(gui)
local function text(parent,value,height,size)
 local t=V.Text(parent,"Status",value,0,0,view.Width,height,size or 13,C.Muted) t.Size=UDim2.new(1,-4,0,height) return t
end
local popup,popupReturn
local function dismiss() if popup then popup:Destroy() popup=nil end end
local function dropdown(parent,name,label,options,get,set,width,x)
 local b=V.Button(parent,name,label.."   ﹀",nil) b.Size=UDim2.new(width or 1,-6,1,0) b.Position=UDim2.fromScale(x or 0,0) b.TextSize=13
 Nav:Connect(b,function()
  dismiss() popupReturn=b
  local shade=Instance.new("TextButton") shade.Name="FilterPopup" shade:SetAttribute("SettingsStyled",true) shade.Text="" shade.BackgroundColor3=Color3.new(0,0,0) shade.BackgroundTransparency=.55 shade.Size=UDim2.fromScale(1,1) shade.ZIndex=50 shade.Parent=view.Panel popup=shade
  local ratio=view.Panel.AbsoluteSize.X/math.max(1,view.Panel.Size.X.Offset)
  local w=math.max(170,b.AbsoluteSize.X/ratio) local height=math.min(264,#options*42)
  local list=Instance.new("ScrollingFrame") list.Name="Choices" list:SetAttribute("SettingsStyled",true) list.BackgroundColor3=C.Surface list.BorderSizePixel=0 list.Size=UDim2.fromOffset(w,height)
  local pos=(b.AbsolutePosition-view.Panel.AbsolutePosition)/ratio
  list.Position=UDim2.fromOffset(math.clamp(pos.X,0,math.max(0,view.Panel.Size.X.Offset-w)),math.clamp(pos.Y+b.AbsoluteSize.Y/ratio+4,0,math.max(0,view.Panel.Size.Y.Offset-height))) list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new() list.ScrollBarThickness=3 list.ZIndex=51 list.Parent=shade V.Round(list,10) V.Edge(list,C.Accent)
  local layout=Instance.new("UIListLayout") layout.Parent=list
  Nav:Connect(shade,function() dismiss() Nav:Focus(b) end)
  local first
  for i,option in options do
   local item=V.Button(list,"Option"..i,option.label,function() set(option.id) b.Text=get().."   ﹀" dismiss() if b.Parent then Nav:Focus(b) end end)
   item.Size=UDim2.new(1,-4,0,42) item.TextSize=13 item.ZIndex=52 first=first or item
  end
  task.defer(function() if first and first.Parent then Nav:Focus(first) end end)
 end)
 return b
end
local function modeOptions()
 local o={} for _,m in S.Modes do table.insert(o,{id=m,label=m=="general" and "Geral (Todos os Modos)" or S.Names[m]}) end return o
end
local function readLocal()
 local d={userId=player.UserId,name=player.DisplayName}
 for _,m in S.Modes do for _,k in S.Fields do local key=S.Key(m,k) d[key]=player:GetAttribute("Progress"..key) or 0 end end return d
end
local profileMode,compareMode,rankMode,metric,scope="general","general","general","XP","global"
local profileList=view.Panes.Profile.List
local profileBody=V.Area(profileList,"PersonalStatistics",1,14)
local profileFilter
local function renderProfile()
 local scroll=profileList.CanvasPosition local focus=Nav:GetFocus() local focusName=focus and focus:IsDescendantOf(profileBody) and focus.Name
 V.Clear(profileBody)
 if player:GetAttribute("ProgressionReady")~=true then
  text(profileBody,player:GetAttribute("ProgressionLoadError") and "Não foi possível carregar seu progresso. Reconecte para tentar novamente; os dados salvos foram preservados." or "Carregando seu progresso...",100,16) return
 end
 local data=readLocal() local width=view.Width-4
 V.Identity(profileBody,data,width,S,false).LayoutOrder=0
 V.Metrics(profileBody,data,profileMode,width,S).LayoutOrder=1
 local heading=text(profileBody,"      POR MODALIDADE",28,16) heading.LayoutOrder=2 heading.TextColor3=C.Text heading.Font=Enum.Font.GothamBold V.Icon(heading,"general",3,4,20)
 V.ModeCards(profileBody,data,profileMode,width,S,function(mode)
  profileMode=mode profileFilter.Text=S.Names[mode].."   ﹀" renderProfile()
  local target=profileBody.ModeCards:FindFirstChild(mode) if target then Nav:Focus(target) end
 end).LayoutOrder=3
 local note=text(profileBody,"Estatísticas por modalidade registradas a partir da atualização. O Geral preserva seu histórico. Duels aguarda resultados de partidas.",32,11) note.LayoutOrder=4
 task.defer(function()
  if not profileList.Parent then return end profileList.CanvasPosition=scroll
  if focusName then local target=profileBody:FindFirstChild(focusName,true) if target and target:IsA("GuiButton") then Nav:Focus(target) end end
 end)
end
profileFilter=dropdown(view.Panes.Profile.Filters,"Mode","Geral (Todos os Modos)",modeOptions(),function() return S.Names[profileMode] end,function(v) profileMode=v renderProfile() end)
local leaderList=view.Panes.Leaders.List
local banner=V.Box(leaderList,"RankingBanner",74) banner.LayoutOrder=0 banner.BackgroundColor3=Color3.fromRGB(8,37,43) V.Edge(banner,C.Accent).Transparency=.6 V.Icon(banner,"Leaders",18,17,40)
local rankTitle=V.Text(banner,"Title","Classificação Global",78,7,500,32,25)
local rankSubtitle=V.Text(banner,"Description","Jogadores com mais XP no Crossgrounds.",78,40,500,23,13,C.Muted)
local columns=Instance.new("Frame") columns.Name="Columns" columns:SetAttribute("SettingsStyled",true) columns.BackgroundTransparency=1 columns.Size=UDim2.new(1,-4,0,23) columns.LayoutOrder=1 columns.Parent=leaderList
V.Text(columns,"Rank","#",18,0,70,23,12,C.Muted) V.Text(columns,"Player","JOGADOR",144,0,180,23,12,C.Muted)
local metricHeader=V.Text(columns,"Metric","XP TOTAL",0,0,180,23,12,C.Muted) metricHeader.AnchorPoint=Vector2.new(1,0) metricHeader.Position=UDim2.new(1,-12,0,0) metricHeader.TextXAlignment=Enum.TextXAlignment.Right
local rankStatus=text(leaderList,"Carregando classificação...",46) rankStatus.LayoutOrder=2
local rankBody=V.Area(leaderList,"Ranking",3,6)
local own=V.Box(view.Panes.Leaders.Frame,"PersonalPosition",58) own.Position=UDim2.new(0,20,1,-74) own.Size=UDim2.new(1,-40,0,58) own.BackgroundColor3=Color3.fromRGB(8,39,46) V.Edge(own,C.Accent,2).Transparency=0
local ownRank=V.Text(own,"Rank","—",14,0,90,58,18,C.Text) ownRank.Font=Enum.Font.GothamBold
V.Avatar(own,readLocal(),106,8,42,C.Accent)
local ownName=V.Text(own,"Name",player.DisplayName,164,5,300,27,18) ownName.Font=Enum.Font.GothamBold
local ownStatus=V.Text(own,"Status","Consultando sua posição...",164,31,400,20,12,C.Muted)
local ownValue=V.Text(own,"Value","—",0,0,190,58,20,C.Accent) ownValue.AnchorPoint=Vector2.new(1,0) ownValue.Position=UDim2.new(1,-16,0,0) ownValue.TextXAlignment=Enum.TextXAlignment.Right ownValue.Font=Enum.Font.GothamBold
local rankingToken=0 local rankData,rankError
local function renderRanking()
 V.Clear(rankBody)
 rankTitle.Text=scope=="global" and "Classificação Global" or "Classificação entre Amigos"
 rankTitle.Size=UDim2.new(1,-90,0,32) rankSubtitle.Size=UDim2.new(1,-90,0,23)
 rankSubtitle.Text=S.Names[rankMode].."  ·  "..S.Labels[metric] metricHeader.Text=string.upper(S.Labels[metric])
 if not rankData then rankStatus.Visible=true rankStatus.Text=rankError or "Carregando classificação..." ownStatus.Text=rankError and "Posição indisponível" or "Consultando sua posição..." ownRank.Text="—" ownValue.Text="—" return end
 rankStatus.Text=rankData.message or (#rankData.entries==0 and "Nenhum jogador classificado neste filtro." or "") rankStatus.Visible=rankStatus.Text~=""
 for _,entry in rankData.entries do V.RankRow(rankBody,entry,metric,view.Width-4,S,Prestige,scope,rankMode) end
 local personal=rankData.personal
 ownRank.Text=personal and personal.rank and "#"..personal.rank or "—"
 ownStatus.Text=personal and (personal.label or (scope=="global" and "Sua posição global" or "Sua posição entre amigos")) or "Ainda sem classificação"
 ownValue.Text=personal and V.Format(metric,personal.value,S) or "—"
end
local function loadRanking()
 rankingToken+=1 local token=rankingToken rankData=nil rankError=nil renderRanking()
 task.spawn(function()
  local remote=remotes:WaitForChild("GetProgressRanking",10)
  local ok,data,message=pcall(function() if remote then return remote:InvokeServer(rankMode,metric,scope) end end)
  if token~=rankingToken then return end
  rankData=ok and data or nil rankError=not rankData and (message or "Ranking indisponível no momento.") or nil renderRanking()
 end)
end
local metricButton
local function rebuildMetric()
 if metricButton then metricButton:Destroy() end
 local options={} for _,m in S.Metrics[rankMode] do table.insert(options,{id=m,label=S.Labels[m]}) end
 metricButton=dropdown(view.Panes.Leaders.Filters,"Metric",S.Labels[metric],options,function() return S.Labels[metric] end,function(v) metric=v loadRanking() end,.33,0)
end
rebuildMetric()
dropdown(view.Panes.Leaders.Filters,"Scope","Global",{{id="global",label="Global"},{id="friends",label="Amigos"}},function() return scope=="global" and "Global" or "Amigos" end,function(v) scope=v loadRanking() end,.25,.33)
dropdown(view.Panes.Leaders.Filters,"Mode","Geral (Todos os Modos)",modeOptions(),function() return S.Names[rankMode] end,function(v) rankMode=v metric=S.Metrics[v][1] rebuildMetric() loadRanking() end,.42,.58)
local friendList=view.Panes.Friends.List
local friendStatus=text(friendList,"Carregando amigos...",42) friendStatus.LayoutOrder=5
local comparison=V.Area(friendList,"Comparison",0,6)
local friendPlaceholder=V.Button(view.Panes.Friends.Filters,"FriendUnavailable","Selecionar amigo",nil) friendPlaceholder.Size=UDim2.new(1,-6,1,0) friendPlaceholder.TextSize=13 friendPlaceholder.Active=false friendPlaceholder.Selectable=false
local friendRecords,selected,friendButton={},nil,nil
local function renderComparison()
 local scroll=friendList.CanvasPosition local focused=Nav:GetFocus() local restore=focused and focused:IsDescendantOf(comparison) and focused.Name
 V.Clear(comparison) local mine=readLocal() local width=view.Width-4 local wide=width>=620
 local profiles=Instance.new("Frame") profiles.Name="Profiles" profiles:SetAttribute("SettingsStyled",true) profiles.BackgroundTransparency=1 profiles.Size=UDim2.new(1,-4,0,wide and 138 or 280) profiles.LayoutOrder=0 profiles.Parent=comparison
 local cardWidth=wide and (width-90)/2 or width
 V.Identity(profiles,mine,cardWidth,S,true)
 local versus=V.Text(profiles,"Versus","VS",wide and cardWidth+12 or 0,wide and 36 or 114,wide and 66 or width,40,30,C.Accent) versus.Font=Enum.Font.GothamBold versus.TextXAlignment=Enum.TextXAlignment.Center
 if selected then
  local peer=V.Identity(profiles,selected,cardWidth,S,true,true) peer.Name="FriendIdentity" peer.Position=UDim2.fromOffset(wide and cardWidth+90 or 0,wide and 0 or 144)
 else
  local empty=text(profiles,"Selecione um amigo com histórico para comparar.",100,15) empty.Position=UDim2.fromOffset(wide and cardWidth+90 or 0,wide and 12 or 154) empty.Size=UDim2.fromOffset(cardWidth,80)
 end
 local tabs=Instance.new("Frame") tabs.Name="ModeTabs" tabs:SetAttribute("SettingsStyled",true) tabs.BackgroundTransparency=1 tabs.Size=UDim2.new(1,-4,0,wide and 44 or 84) tabs.LayoutOrder=1 tabs.Parent=comparison
 for i,m in S.Modes do
  local b=V.Button(tabs,"Compare_"..m,m=="general" and "Resumo" or S.Names[m],function() compareMode=m renderComparison() local nextTab=comparison.ModeTabs:FindFirstChild("Compare_"..m) if nextTab then Nav:Focus(nextTab) end end)
  b.TextSize=width<500 and 11 or 14
  if wide then b.Position=UDim2.new((i-1)/5,0,0,0) b.Size=UDim2.new(.2,-5,0,44)
  else b.Position=UDim2.new(((i-1)%3)/3,0,0,math.floor((i-1)/3)*42) b.Size=UDim2.new(1/3,-5,0,38) end V.Select(b,compareMode==m)
 end
 local compareFields=compareMode=="general" and {"Kills","Deaths","Ratio","Wins","Captures","PlaySeconds","Coins"} or S.Display[compareMode]
 if selected then for i,key in compareFields do V.CompareRow(comparison,key,S.Value(mine,compareMode,key),S.Value(selected,compareMode,key),width,S).LayoutOrder=i+1 end end
 task.defer(function() if friendList.Parent then friendList.CanvasPosition=scroll if restore then local target=comparison:FindFirstChild(restore,true) if target and target:IsA("GuiButton") then Nav:Focus(target) end end end end)
end
local loadedAt=-100 local loading=false
local function loadFriends()
 renderComparison()
 if loading or os.clock()-loadedAt<20 then return end loading=true friendStatus.Text="Carregando amigos com histórico..."
 task.spawn(function()
  local remote=remotes:WaitForChild("GetFriendProgress",10)
  local ok,data,message=pcall(function() if remote then return remote:InvokeServer() end end) loading=false
  if not ok or not data then friendStatus.Text=message or "Amigos indisponíveis no momento." friendPlaceholder.Text="Amigos indisponíveis" return end
  loadedAt=os.clock() friendRecords={} local options={} local previous=selected and selected.userId
  for _,row in data do if not row.self then friendRecords[row.userId]=row table.insert(options,{id=row.userId,label=row.name}) end end
  friendStatus.Text=message or (#options==0 and "Nenhum amigo com histórico disponível." or "Você em turquesa · amigo em branco · diferenças em relação ao amigo")
  if friendButton then friendButton:Destroy() end
  selected=previous and friendRecords[previous] or options[1] and friendRecords[options[1].id] or nil
  friendPlaceholder.Visible=#options==0 friendPlaceholder.Text="Nenhum amigo disponível"
  if #options>0 then friendButton=dropdown(view.Panes.Friends.Filters,"Friend",selected.name,options,function() return selected.name end,function(id) selected=friendRecords[id] renderComparison() end) end
  renderComparison()
 end)
end
local function close() dismiss() player:SetAttribute("ProgressionMenuOpen",false) Nav:OpenMenu("Main") end
local function selectPage(id)
 dismiss() if id=="Close" then close() return end
 view:Select(id)
 if id=="Profile" then renderProfile() elseif id=="Leaders" then loadRanking() else loadFriends() end
end
view.OnSelect=selectPage
view.OnResize=function()
 dismiss()
 ownName.Size=UDim2.new(1,-350,0,27) ownStatus.Size=UDim2.new(1,-350,0,20)
 if view.Width<620 then ownName.Visible=false ownStatus.Visible=false ownValue.Size=UDim2.new(1,-168,1,0) else ownName.Visible=true ownStatus.Visible=true ownValue.Size=UDim2.fromOffset(170,58) end
 if gui.Enabled then renderProfile() renderComparison() renderRanking() end
end
Nav:SetBack(view.Panel,function() if popup then dismiss() if popupReturn and popupReturn.Parent then Nav:Focus(popupReturn) end else close() end end,view.Buttons.Profile)
Nav:SetCategories(view.Panel,function(step)
 if popup then return end local ids={"Profile","Leaders","Friends"} local index=table.find(ids,view.Selected) or 1 local id=ids[(index-1+step)%#ids+1] selectPage(id) Nav:Focus(view.Buttons[id])
end)
local refreshPending=false
player.AttributeChanged:Connect(function(key)
 if not gui.Enabled or key:sub(1,8)~="Progress" or refreshPending then return end
 refreshPending=true task.defer(function() refreshPending=false renderProfile() renderComparison() end)
end)
local function show()
 local on=player:GetAttribute("ProgressionMenuOpen")==true gui.Enabled=on view.Backdrop.Visible=on dismiss()
 if on then view:Resize() selectPage("Profile") profileList.CanvasPosition=Vector2.zero task.delay(.05,function() if gui.Enabled then Nav:Focus(view.Buttons.Profile) end end) end
end
player:GetAttributeChangedSignal("ProgressionMenuOpen"):Connect(show)
Nav.MenuRequested:Connect(function(id) if table.find({"Main","Hub","Settings","Resume","Playlist","Pause"},id) then player:SetAttribute("ProgressionMenuOpen",false) end end)
gui.Parent=player.PlayerGui
script:SetAttribute("Initialized",true) show()
