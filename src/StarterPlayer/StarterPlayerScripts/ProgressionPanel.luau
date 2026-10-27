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
local summary=browser:Info("Profile","Summary","",56) summary.LayoutOrder=1
local bar=Instance.new("Frame") bar.Name="ProgressBar" bar.LayoutOrder=2 bar.Size=UDim2.new(1,-8,0,8) bar.BackgroundColor3=Color3.fromRGB(78,81,90) bar.BorderSizePixel=0 bar.Parent=browser.Panes.Profile.List
local fill=Instance.new("Frame") fill.Name="Fill" fill.BackgroundColor3=Color3.fromRGB(218,225,239) fill.BorderSizePixel=0 fill.Size=UDim2.fromScale(0,1) fill.Parent=bar
local columns={{id="stat",label="ESTATÍSTICA",width=.68},{id="value",label="TOTAL",width=.32,align=Enum.TextXAlignment.Right}}
local stats=Table.new(browser.Panes.Profile.List,"Stats",columns) stats.Holder.LayoutOrder=3
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
 for _,key in {"XP","Level","Coins","Kills","Deaths","Captures","PlaySeconds","BotKills","TrainingKills"} do data[key]=player:GetAttribute("Progress"..key) or (key=="Level" and 1 or 0) end
 local xp,level=data.XP,data.Level local previous=math.floor(250*((level-1)^1.45)) local nextXP=math.floor(250*(level^1.45))
 summary.Text=player.DisplayName.."\nNível "..level.." · "..xp.." XP\n"..math.max(0,nextXP-xp).." XP para o próximo nível"
 fill.Size=UDim2.fromScale(math.clamp((xp-previous)/math.max(1,nextXP-previous),0,1),1) populate(stats,data)
end
for _,key in {"XP","Level","Coins","Kills","Deaths","Captures","PlaySeconds","BotKills","TrainingKills"} do player:GetAttributeChangedSignal("Progress"..key):Connect(refresh) end
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
