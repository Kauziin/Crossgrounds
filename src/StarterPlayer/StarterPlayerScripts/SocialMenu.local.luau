local Players=game:GetService("Players") local player=Players.LocalPlayer
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local Party=require(script.Parent:WaitForChild("PartyBridge"))
local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Identity=require(script.Parent:WaitForChild("PlayerIdentityView"))
local socialRemote=game.ReplicatedStorage.Crossgrounds:WaitForChild("Remotes"):WaitForChild("SocialCommand")
local gui=Instance.new("ScreenGui") gui.Name="SocialMenu" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=80 gui.Enabled=false gui.Parent=player.PlayerGui
local browser=Cascade.new(gui,"Backdrop","SOCIAL E GRUPO")
browser:AddPane("Members","INTEGRANTES") browser:AddPane("Players","CONVIDAR AMIGOS DO LOBBY") browser:AddPane("Member","GERENCIAR INTEGRANTE")
browser:AddPane("Friends","AMIGOS DO ROBLOX")browser:AddPane("Recent","JOGADORES RECENTES")browser:AddPane("Profile","PERFIL DO JOGADOR")browser:AddPane("Preferences","PREFERÊNCIAS SOCIAIS")
local status=browser:Info("RootPane","Status","",90)
local membersInfo=browser:Info("Members","Status","",72)
local playerInfo=browser:Info("Players","Status","Convide amigos do Roblox presentes no lobby.",60)
local memberInfo=browser:Info("Member","Status","",70)
local selected,refresh
local friendsInfo=browser:Info("Friends","Status","",60)
local recentInfo=browser:Info("Recent","Status","Participantes encontrados em partidas nesta sessão.",60)
local profileHolder=browser:Info("Profile","IdentityHolder","",138)profileHolder.Text=""
local profileView=Identity.new(profileHolder)
local profileInfo=browser:Info("Profile","Statistics","",128)
local preferencesInfo=browser:Info("Preferences","Status","",62)
local prefs={invites="friends",publicStats=true}
local socialBusy=false
local function social(action,payload)
 if socialBusy then return false end socialBusy=true
 local ok,success,value=pcall(function()return socialRemote:InvokeServer(action,payload)end)socialBusy=false
 if not ok or not success then
  local message=ok and tostring(value)or"Consulta social indisponível. Tente novamente."
  friendsInfo.Text=message recentInfo.Text=message preferencesInfo.Text=message profileInfo.Text=message
  return false
 end
 return true,value
end
local function openProfile(row)
 if socialBusy then return end
 local ok,data=social("profile",row.userId)
 if not ok then return end
 selected=row
 profileView:Render(data)
 local stats=data.stats
 profileInfo.Text=stats and("XP de carreira: "..stats.XP.."\nVitórias: "..stats.Wins.." · Capturas: "..stats.Captures.."\nEliminações: "..stats.Kills.." · Contra bots: "..stats.BotKills.."\nMortes: "..stats.Deaths.." · Tempo: "..math.floor(stats.PlaySeconds/60).." min")or"Estatísticas ocultas ou indisponíveis."
 browser:Push({"RootPane","Profile"})
end
local function send(action,payload) local ok=Party:Send(action,payload) if refresh then refresh() end return ok end
local function close()gui.Enabled=false browser:SetOpen(false) player:SetAttribute("SocialMenuOpen",false) Nav:OpenMenu(Scope:IsHub()and"Hub"or"Main")end
browser.OnClose=close
local create=browser:Button("RootPane","Create","Criar grupo",function()send("create")end)
browser:Button("RootPane","Members","Ver integrantes  ›",function()browser:Push({"RootPane","Members"})end)
browser:Button("RootPane","Players","Convidar amigos  ›",function()browser:Push({"RootPane","Players"})end)
local accept=browser:Button("RootPane","Accept","Aceitar convite",function()local invite=Party:Get().invite if invite then send("accept",invite.id)end end)
local decline=browser:Button("RootPane","Decline","Recusar convite",function()local invite=Party:Get().invite if invite then send("decline",invite.id)end end)
local teams=browser:Button("RootPane","Teams","",function()local group=Party:Get().group if group then send("teams",not group.sameTeam)end end)
local leave=browser:Button("RootPane","Leave","Sair do grupo",function()send("leave")end)
browser:Button("RootPane","Clan","Clãs  ›",function()Nav:OpenMenu("Clan")end).LayoutOrder=4
browser:Button("RootPane","Close","Voltar",close).LayoutOrder=1000
browser:Button("Member","Profile","Abrir perfil",function()if selected then openProfile(selected)end end)
local transfer=browser:Button("Member","Leader","Transferir liderança",function()if selected then send("leader",selected.userId)end end)
local kick=browser:Button("Member","Kick","Remover do grupo",function()if selected then local ok=send("kick",selected.userId)if ok then browser:Push({"RootPane","Members"})end end end)
browser:Button("Profile","Invite","Convidar para o grupo",function()if selected then send("invite",selected.userId)profileInfo.Text=Party.Status end end)
browser:Button("Profile","Favorite","Alternar favorito privado",function()
 if not selected then return end local ok=social("favorite",{userId=selected.userId,value=not selected.favorite})
 if ok then selected.favorite=not selected.favorite profileInfo.Text=selected.favorite and"Amigo adicionado aos favoritos."or"Favorito removido."end
end)
local friendRows,recentRows={},{}
local loadFriends
local previous=browser:Button("Friends","Previous","Página anterior",function()loadFriends("previous")end)
local nextPage=browser:Button("Friends","Next","Próxima página",function()loadFriends("next")end)
browser:Button("Friends","Refresh","Atualizar lista",function()loadFriends("refresh")end)
loadFriends=function(action)
 local ok,data=social("friends",action)if not ok then return end
 friendsInfo.Text="Página "..data.page.." · presença informada pelo Roblox.\nFavoritos aparecem primeiro."
 previous.Visible=data.hasPrevious nextPage.Visible=data.hasNext
 for _,row in friendRows do row:Destroy()end table.clear(friendRows)
 for _,entry in data.rows do local row=entry
  local presence=row.here and(row.mode=="hub"and"Neste lobby"or"Nesta sessão")or row.online==true and"Online"or row.online==false and"Offline"or"Presença indisponível"
  local button=browser:Button("Friends","Friend_"..row.userId,(row.favorite and"★ "or"")..row.name.."\n"..presence,function()openProfile(row)end,60)
  Identity.decorateButton(button,row.public or row)table.insert(friendRows,button)
 end
end
browser:Button("RootPane","Friends","Amigos do Roblox  ›",function()browser:Push({"RootPane","Friends"})loadFriends("first")end).LayoutOrder=1
browser:Button("RootPane","Recent","Jogadores recentes  ›",function()
 browser:Push({"RootPane","Recent"})local ok,data=social("recent")if not ok then return end
 for _,row in recentRows do row:Destroy()end table.clear(recentRows)
 recentInfo.Text=#data.rows==0 and"Ainda não há participantes recentes nesta sessão."or"Participantes de partidas nesta sessão; bots não entram na lista."
 for _,entry in data.rows do local row=entry local button=browser:Button("Recent","Recent_"..row.userId,row.name,function()openProfile(row)end,52)Identity.decorateButton(button,row.public or row)table.insert(recentRows,button)end
end).LayoutOrder=2
local invitePreference,statsPreference
local function paintPreferences()
 invitePreference.Text=prefs.invites=="none"and"Convites sociais: desativados"or"Convites sociais: amigos"
 statsPreference.Text=prefs.publicStats and"Estatísticas do perfil: públicas"or"Estatísticas do perfil: ocultas"
end
browser:Button("RootPane","Preferences","Preferências sociais  ›",function()
 browser:Push({"RootPane","Preferences"})local ok,data=social("preferences")if ok then prefs=data paintPreferences()end
end).LayoutOrder=3
invitePreference=browser:Button("Preferences","Invites","",function()
 local value=prefs.invites=="none"and"friends"or"none"local ok=social("invitePreference",value)
 if ok then prefs.invites=value paintPreferences()preferencesInfo.Text="Preferência salva para novos convites."end
end)
statsPreference=browser:Button("Preferences","Stats","",function()
 local value=not prefs.publicStats local ok=social("statsPreference",value)
 if ok then prefs.publicStats=value paintPreferences()preferencesInfo.Text="Preferência de perfil salva."end
end)
browser:Button("Friends","InviteExperience","Convidar amigos para a experiência",function()
 local service=game:GetService("SocialService")local ok,allowed=pcall(function()return service:CanSendGameInviteAsync(player)end)
 if not ok or not allowed then friendsInfo.Text="Convites do Roblox indisponíveis neste momento."return end
 local prompted=pcall(function()service:PromptGameInvite(player)end)
 if not prompted then friendsInfo.Text="Não foi possível abrir o convite do Roblox."end
end)
paintPreferences()
local memberRows,playerRows={},{}
refresh=function()
 local data=Party:Get() local group=data.group local leader=group and group.leader==player.UserId
 status.Text=Party.Busy and "Atualizando grupo..." or Party.Status~="" and Party.Status or group and (#group.members.." / 12 integrantes\n"..(leader and "Você é o líder."or"O líder escolhe a modalidade."))or"Forme um grupo com seus amigos."
 if data.invite then status.Text..="\nConvite de "..data.invite.name end
 create.Visible=not group accept.Visible=data.invite~=nil decline.Visible=data.invite~=nil leave.Visible=group~=nil
 teams.Visible=leader==true teams.Text=group and(group.sameTeam and"Equipes: permanecer juntos"or"Equipes: permitir divisão")or"Equipes"
 membersInfo.Text=group and(group.locked and"Entrada coletiva em andamento. Aguarde o líder."or"Mesmo time: Conflict até 6. Dividindo times: até 12.\nTreino e testes continuam individuais.")or"Você ainda não está em um grupo."
 local focus=Nav:GetFocus() local wanted=focus and focus.Name
 local scroll=browser.Panes.Members.List.CanvasPosition
 for _,row in memberRows do row:Destroy()end table.clear(memberRows)
 for _,row in group and group.members or{}do
  local member=row
  local b=browser:Button("Members","Member_"..row.userId,row.name..(row.userId==group.leader and" · Líder"or"").."\n"..(row.mode=="hub"and"No lobby"or row.mode=="ctf"and"Conflict"or row.mode=="arena"and"Arena"or"Em outra atividade"),function()
   selected=member memberInfo.Text=member.name
   transfer.Visible=leader and member.userId~=player.UserId kick.Visible=transfer.Visible
   browser:Push({"RootPane","Members","Member"})
  end,62)Identity.decorateButton(b,row.public or row)table.insert(memberRows,b)
  if b.Name==wanted then task.defer(function()if b.Parent then Nav:Focus(b)end end)end
 end
 browser.Panes.Members.List.CanvasPosition=scroll
 for _,row in playerRows do row:Destroy()end table.clear(playerRows)
 for _,target in Players:GetPlayers()do if target~=player and target:GetAttribute("CrossgroundsMode")=="hub"then
  local id=target.UserId
  table.insert(playerRows,browser:Button("Players","Player_"..id,target.DisplayName.."  @"..target.Name,function()
   local ok=send("invite",id) playerInfo.Text=Party.Status
   if ok then playerInfo.Text="Convite enviado. A pessoa precisa aceitar para entrar."end
  end))
 end end
end
local noticeGui=Instance.new("ScreenGui") noticeGui.Name="PartyInvitationNotice"noticeGui.ResetOnSpawn=false noticeGui.DisplayOrder=70 noticeGui.Parent=player.PlayerGui
local notice=Instance.new("TextButton")notice.Name="Invitation"notice.AnchorPoint=Vector2.new(1,0)notice.Position=UDim2.new(1,-18,0,80)notice.Size=UDim2.fromOffset(270,48)notice.TextSize=14 notice.TextWrapped=true notice.Visible=false notice.Parent=noticeGui Theme.Button(notice)
Nav:Connect(notice,function()Nav:OpenMenu("Social")end)
local pending=false
local function update()
 local invite=Party:Get().invite notice.Visible=invite~=nil notice.Text=invite and("Convite de "..invite.name.." · abrir grupo")or""
 if pending or not gui.Enabled then return end pending=true task.defer(function()pending=false if gui.Enabled then refresh()end end)
end
Party.Changed:Connect(update)
Players.PlayerAdded:Connect(update)Players.PlayerRemoving:Connect(update)
Nav.MenuRequested:Connect(function(id)
 if id=="Social"then
  player:SetAttribute("SocialMenuOpen",true)player:SetAttribute("CareerMenuOpen",false)player:SetAttribute("ProgressionMenuOpen",false)player:SetAttribute("LobbyMusicMenuOpen",false)
  gui.Enabled=true browser:Push({"RootPane"})browser:SetOpen(true)refresh()
 elseif table.find({"Clan","Main","Hub","Settings","Resume","Playlist","Progress","Pause","Career"},id)then gui.Enabled=false browser:SetOpen(false)player:SetAttribute("SocialMenuOpen",false)end
end)
Scope.Changed:Connect(function()gui.Enabled=false browser:SetOpen(false)player:SetAttribute("SocialMenuOpen",false)end)
update()
