local player=game.Players.LocalPlayer
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Table=require(script.Parent:WaitForChild("StatsTable"))
local remotes=game.ReplicatedStorage.Crossgrounds:WaitForChild("Remotes")
local gui=Instance.new("ScreenGui") gui.Name="ProgressionPanel" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=80 gui.Enabled=false gui.Parent=player.PlayerGui
local browser=Cascade.new(gui,"Backdrop","PROGRESSO")
browser:AddPane("Profile","SEU PERFIL") browser:AddPane("Friends","AMIGOS") browser:AddPane("FriendDetail","PERFIL")
local function close() player:SetAttribute("ProgressionMenuOpen",false) Nav:OpenMenu("Main") end browser.OnClose=close
browser:Button("RootPane","Profile","Seu perfil  ›",function() browser:Push({"RootPane","Profile"}) end)
local loadFriends
local friendsButton=browser:Button("RootPane","Friends","Comparativo com amigos  ›",function() browser:Push({"RootPane","Friends"}) loadFriends() end)
browser:Button("RootPane","Close","Voltar ao menu",close)
local list=browser.Panes.Profile.List
local identity=Instance.new("Frame") identity.Name="IdentityCard" identity.LayoutOrder=1 identity.Size=UDim2.new(1,-8,0,82) identity.BackgroundColor3=Color3.fromRGB(25,29,37) identity.BorderSizePixel=0 identity.Parent=list
local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,10) c.Parent=identity
local portrait=Instance.new("ImageLabel") portrait.Name="Avatar" portrait.Size=UDim2.fromOffset(58,58) portrait.Position=UDim2.new(0,12,.5,-29) portrait.BackgroundColor3=Color3.fromRGB(39,45,56) portrait.BorderSizePixel=0 portrait.Parent=identity
local pc=Instance.new("UICorner") pc.CornerRadius=UDim.new(1,0) pc.Parent=portrait
local profileName=Instance.new("TextLabel") profileName.Name="DisplayName" profileName.Position=UDim2.new(0,82,0,12) profileName.Size=UDim2.new(1,-94,0,26) profileName.BackgroundTransparency=1 profileName.Font=Enum.Font.GothamBold profileName.TextSize=18 profileName.TextXAlignment=Enum.TextXAlignment.Left profileName.TextColor3=Color3.fromRGB(242,246,252) profileName.Parent=identity
local summary=Instance.new("TextLabel") summary.Name="Level" summary.Position=UDim2.new(0,82,0,42) summary.Size=UDim2.new(1,-94,0,22) summary.BackgroundTransparency=1 summary.Font=Enum.Font.Gotham summary.TextSize=13 summary.TextXAlignment=Enum.TextXAlignment.Left summary.TextColor3=Color3.fromRGB(165,179,198) summary.Parent=identity
local bar=Instance.new("Frame") bar.Name="ProgressBar" bar.LayoutOrder=2 bar.Size=UDim2.new(1,-8,0,8) bar.BackgroundColor3=Color3.fromRGB(78,81,90) bar.BorderSizePixel=0 bar.Parent=browser.Panes.Profile.List
local fill=Instance.new("Frame") fill.Name="Fill" fill.BackgroundColor3=Color3.fromRGB(218,225,239) fill.BorderSizePixel=0 fill.Size=UDim2.fromScale(0,1) fill.Parent=bar
local modeSection=Instance.new("Frame") modeSection.Name="ModeStatistics" modeSection.LayoutOrder=3 modeSection.Size=UDim2.new(1,-8,0,154) modeSection.BackgroundTransparency=1 modeSection.Parent=browser.Panes.Profile.List
local grid=Instance.new("UIGridLayout") grid.CellPadding=UDim2.fromOffset(8,8) grid.CellSize=UDim2.new(.5,-4,0,72) grid.SortOrder=Enum.SortOrder.LayoutOrder grid.Parent=modeSection
local modeCards={}
for index,mode in ipairs({"ARENA","GET OUT","DUELS","CTF"}) do
 local card=Instance.new("Frame") card.Name=mode card.LayoutOrder=index card.BackgroundColor3=Color3.fromRGB(25,29,37) card.BorderSizePixel=0 card.Parent=modeSection
 local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,9) corner.Parent=card
 local title=Instance.new("TextLabel") title.Name="Title" title.Position=UDim2.new(0,10,0,8) title.Size=UDim2.new(1,-20,0,18) title.BackgroundTransparency=1 title.Font=Enum.Font.GothamBold title.TextSize=12 title.TextXAlignment=Enum.TextXAlignment.Left title.TextColor3=Color3.fromRGB(71,211,228) title.Text=mode title.Parent=card
 local detail=Instance.new("TextLabel") detail.Name="Detail" detail.Position=UDim2.new(0,10,0,30) detail.Size=UDim2.new(1,-20,0,34) detail.BackgroundTransparency=1 detail.Font=Enum.Font.Gotham detail.TextSize=12 detail.TextWrapped=true detail.TextXAlignment=Enum.TextXAlignment.Left detail.TextYAlignment=Enum.TextYAlignment.Top detail.TextColor3=Color3.fromRGB(205,214,226) detail.Text="Estatísticas por modo indisponíveis" detail.Parent=card
 modeCards[mode]=detail
end
local columns={{id="stat",label="ESTATÍSTICA",width=.68},{id="value",label="TOTAL",width=.32,align=Enum.TextXAlignment.Right}}
local stats=Table.new(browser.Panes.Profile.List,"Stats",columns) stats.Holder.LayoutOrder=4
local friendStatus=browser:Info("Friends","Status","Escolha o comparativo para carregar amigos.",64) friendStatus.LayoutOrder=-1
local friendName=browser:Info("FriendDetail","Name","",52)
local friendStats=Table.new(browser.Panes.FriendDetail.List,"Stats",columns) friendStats.Holder.LayoutOrder=1
local function populate(tableView,data)
 tableView:Clear()
 local deaths=data.Deaths or 0 local kills=data.Kills or 0
 local values={{"XP total",data.XP},{"Nível",data.Level},{"Moedas",data.Coins},{"Eliminações em partidas",kills},{"Dessas, contra bots",data.BotKills},{"Alvos de treino",data.TrainingKills},{"Mortes",deaths},{"Relação E/M",string.format("%.2f",kills/math.max(1,deaths))},{"Bandeiras capturadas",data.Captures},{"Tempo jogado",math.floor((data.PlaySeconds or 0)/60).." min"}}
 for i,v in values do tableView:Add({stat=v[1],value=v[2] or 0},i) end
end
local function refresh()
 local data={}
 for _,key in {"ArenaKills","ArenaDeaths","XP","Level","Coins","Kills","Deaths","Captures","PlaySeconds","BotKills","TrainingKills"} do data[key]=player:GetAttribute("Progress"..key) or (key=="Level" and 1 or 0) end
 local xp,level=data.XP,data.Level local previous=math.floor(250*((level-1)^1.45)) local nextXP=math.floor(250*(level^1.45))
 profileName.Text=player.DisplayName summary.Text="Nível "..level.."  ·  "..xp.." XP  ·  "..math.max(0,nextXP-xp).." XP para o próximo nível" portrait.Image="rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=150&h=150"
 modeCards.ARENA.Text="Eliminações: "..tostring(player:GetAttribute("ArenaKills") or "—").."  ·  Mortes: "..tostring(player:GetAttribute("ArenaDeaths") or "—")
 modeCards["GET OUT"].Text="Estatísticas por modo indisponíveis" modeCards.DUELS.Text="Estatísticas por modo indisponíveis" modeCards.CTF.Text="Bandeiras capturadas: "..tostring(data.Captures or 0)
 fill.Size=UDim2.fromScale(math.clamp((xp-previous)/math.max(1,nextXP-previous),0,1),1) populate(stats,data)
end
for _,key in {"XP","Level","Coins","Kills","Deaths","Captures","PlaySeconds","BotKills","TrainingKills"} do player:GetAttributeChangedSignal("Progress"..key):Connect(refresh) end
for _,key in {"ArenaKills","ArenaDeaths"} do player:GetAttributeChangedSignal(key):Connect(refresh) end
local generation=0 local rows={} local loadedAt=-100 local loading=false
loadFriends=function()
 if loading or os.clock()-loadedAt<20 then return end
 loading=true friendStatus.Text="Carregando amigos que já jogaram..."
 local token=generation
 task.spawn(function()
  local remote=remotes:WaitForChild("GetFriendProgress",10)
  local ok,data,message=false,nil,nil
  if remote then ok,data,message=pcall(function() return remote:InvokeServer() end) end
  loading=false if token~=generation then return end
  if not ok or typeof(data)~="table" then friendStatus.Text=message or "Comparativo indisponível no momento." return end
  loadedAt=os.clock()
  for _,row in rows do row:Destroy() end rows={}
  local count=0
  for i,row in data do
   if not row.self then count+=1 end
   local b=browser:Button("Friends","Friend"..i,"#"..i.."  "..row.name..(row.self and " (você)" or "").."\nNível "..row.Level.."  ·  "..row.XP.." XP",function()
    friendName.Text=row.name..(row.self and " (você)" or "") populate(friendStats,row)
    browser:Push({"RootPane","Friends","FriendDetail"})
   end,64) b.LayoutOrder=i table.insert(rows,b)
  end
  friendStatus.Text=(count==0 and "Nenhum amigo com histórico disponível." or "Amigos que já jogaram · ordenados por XP")..(message and "\n"..message or "")
 end)
end
local function show(on)
 generation+=1 gui.Enabled=on browser:SetOpen(on)
 if on then browser:Push({"RootPane","Profile"}) refresh() end
end
script:SetAttribute("Initialized",true)
Nav:SetBack(browser.Panel,function() if #browser.Stack>1 then browser:Push({"RootPane"}) else close() end end,friendsButton)
player:GetAttributeChangedSignal("ProgressionMenuOpen"):Connect(function() show(player:GetAttribute("ProgressionMenuOpen")==true) end)
Nav.MenuRequested:Connect(function(id)
 if table.find({"Main","Hub","Settings","Resume","Playlist"},id) then player:SetAttribute("ProgressionMenuOpen",false) end
end)
refresh() show(player:GetAttribute("ProgressionMenuOpen")==true)

