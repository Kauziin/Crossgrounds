local Players=game:GetService("Players")local player=Players.LocalPlayer
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Clan=require(script.Parent:WaitForChild("ClanBridge"))
local Catalog=require(game.ReplicatedStorage.Crossgrounds.ClanCatalog)
local gui=Instance.new("ScreenGui")gui.Name="ClanMenu"gui.ResetOnSpawn=false gui.DisplayOrder=81 gui.Enabled=false gui.Parent=player.PlayerGui
local browser=Cascade.new(gui,"Backdrop","CLÃS")
for id,title in {Create="FUNDAR CLÃ",Overview="CLÃ",Members="INTEGRANTES",Member="GERENCIAR INTEGRANTE",Invites="CONVITES RECEBIDOS",Invite="CONVIDAR AMIGOS DO LOBBY",Ranking="RANKING DE CLÃS",Lookup="BUSCAR CLÃ",Confirm="CONFIRMAR AÇÃO"}do browser:AddPane(id,title)end
browser:Button("RootPane","ProgressionTrack","Progressão da guilda  ›",function() gui.Enabled=false browser:SetOpen(false) player:SetAttribute("ClanMenuOpen",false) Nav:OpenMenu("GuildProgress") end)
local status=browser:Info("RootPane","Status","",90)
local overview=browser:Info("Overview","Summary","",134)
local currentStats=browser:Info("Overview","Current","",114)
local earnedStats=browser:Info("Overview","Earned","",114)
local memberInfo=browser:Info("Member","Summary","",80)
local rankInfo=browser:Info("Ranking","Summary","",80)
local inviteInfo=browser:Info("Invites","Summary","Convites de amigos. Ao aceitar, você entra nesse clã.",64)
local confirmation=browser:Info("Confirm","Summary","",110)
local createInfo=browser:Info("Create","Summary","Nome: 3–40 caracteres. Tag: 2–5 letras ou números.\nO nome e a tag são verificados pelo Roblox.",82)
local lookupInfo=browser:Info("Lookup","Summary","Cole o ID completo do clã, compartilhado por um integrante.",68)
local function field(pane,name,placeholder)
 local box=Instance.new("TextBox")box.Name=name box.PlaceholderText=placeholder box.Text=""box.ClearTextOnFocus=false box.TextSize=15 box.TextWrapped=true box.Size=UDim2.new(1,-4,0,46)box.Parent=browser.Panes[pane].List
 Theme.Surface(box)box.Font=Enum.Font.GothamMedium box.TextColor3=Theme.Colors.Text box.PlaceholderColor3=Theme.Colors.Muted
 Nav:Register(box,function()box:CaptureFocus()end)return box
end
local nameField=field("Create","ClanName","Nome do clã")
local tagField=field("Create","ClanTag","Tag")
local idField=field("Lookup","ClanId","ID completo do clã")
local selectedClan,selectedMember,refresh,paintOverview
local emblem,color="star","teal"
local dynamic={}
local function clear(key)for _,row in dynamic[key]or{}do row:Destroy()end dynamic[key]={}end
local function row(pane,name,text,callback,height)
 dynamic[pane]=dynamic[pane]or{}local button=browser:Button(pane,name,text,callback,height)table.insert(dynamic[pane],button)return button
end
local function send(action,payload)
 local ok,value=Clan:Send(action,payload)
 if not ok then status.Text=Clan.Status createInfo.Text=Clan.Status memberInfo.Text=Clan.Status lookupInfo.Text=Clan.Status inviteInfo.Text=Clan.Status confirmation.Text=Clan.Status end
 return ok,value
end
local function reload()task.wait(.55)local ok=send("get")if ok and refresh then refresh()end end
local function close()gui.Enabled=false browser:SetOpen(false)player:SetAttribute("ClanMenuOpen",false)Nav:OpenMenu("Social")end
browser.OnClose=close
local function own()return Clan:Get().clan end
local function show(record)selectedClan=record paintOverview()browser:Push({"RootPane","Overview"})end
local function confirm(message,callback)
 confirmation.Text=message clear("Confirm")
 row("Confirm","Accept","Confirmar",function()local ok=callback()if ok then reload()browser:Push({"RootPane"})end end)
 row("Confirm","Cancel","Voltar",function()browser:Push({"RootPane"})end)
 browser:Push({"RootPane","Confirm"})
end
local mine=browser:Button("RootPane","MyClan","Meu clã  ›",function()if own()then show(own())end end)
local create=browser:Button("RootPane","Create","Fundar clã  ›",function()browser:Push({"RootPane","Create"})end)
local retry=browser:Button("RootPane","Retry","Repetir confirmação pendente",function()if send("reconcile")then reload()end end)
local cancelPending=browser:Button("RootPane","CancelPending","Cancelar filiação pendente",function()confirm("Cancelar a filiação pendente? A operação será encerrada antes de liberar seu perfil.",function()return send("cancelPending")end)end)
browser:Button("RootPane","Invites","Convites recebidos  ›",function()
 clear("Invites")local invites=Clan:Get().invites or{}inviteInfo.Text=#invites==0 and"Nenhum convite válido no momento."or"Aceite um convite para se tornar integrante."
 for _,entry in invites do local invitation=entry
  row("Invites","Accept_"..entry.clanId,"Entrar em ["..entry.tag.."] "..entry.name,function()if send("accept",invitation)then reload()browser:Push({"RootPane"})end end,58)
  row("Invites","Decline_"..entry.clanId,"Recusar convite de "..entry.name,function()if send("decline",invitation)then reload()browser:Push({"RootPane"})end end)
 end
 browser:Push({"RootPane","Invites"})
end)
local function ranking(scope)
 browser:Push({"RootPane","Ranking"})clear("Ranking")
 local ok,data=send("leaderboard",scope)if not ok then rankInfo.Text=Clan.Status return end
 rankInfo.Text=data.label.."\n"..data.message..(data.sessionOnly and"\nPrévia desta sessão do Studio."or"")
 for _,entry in data.rows do local item=entry
  row("Ranking","Clan_"..item.id,item.rank..". ["..item.tag.."] "..item.name.."\n"..item.score.." XP · nível "..item.level.." · "..item.members.." integrantes",function()local accepted,value=send("view",item.id)if accepted then show(value)end end,76)
 end
 if #data.rows==0 then rankInfo.Text..="\nNenhum clã disponível ainda."end
end
browser:Button("RootPane","RosterRanking","Ranking: histórico do elenco  ›",function()ranking("roster")end,56)
browser:Button("RootPane","EarnedRanking","Ranking: conquistas do clã  ›",function()ranking("earned")end,56)
browser:Button("RootPane","Lookup","Buscar por ID  ›",function()browser:Push({"RootPane","Lookup"})end)
browser:Button("Lookup","Search","Consultar clã",function()local id=idField.Text:match("^%s*(.-)%s*$")local ok,data=send("view",id)if ok then show(data)end end)
browser:Button("RootPane","Close","Voltar",close).LayoutOrder=1000
local emblemButton,colorButton
local function choices()
 emblemButton.Text="Brasão: "..Catalog.Emblems[emblem].glyph.." "..Catalog.Emblems[emblem].name
 colorButton.Text="Cor: "..Catalog.Colors[color].name
end
local function nextKey(map,key)local keys={}for k in map do table.insert(keys,k)end table.sort(keys)return keys[(table.find(keys,key)or 0)%#keys+1]end
emblemButton=browser:Button("Create","Emblem","",function()emblem=nextKey(Catalog.Emblems,emblem)choices()end)
colorButton=browser:Button("Create","Color","",function()color=nextKey(Catalog.Colors,color)choices()end)
choices()
browser:Button("Create","Submit","Fundar clã",function()
 if send("create",{name=nameField.Text,tag=tagField.Text,emblem=emblem,color=color})then nameField.Text=""tagField.Text=""reload()if own()then show(own())end end
end)
local members=browser:Button("Overview","Members","Integrantes  ›",function()
 clear("Members")if not selectedClan then return end
 for _,entry in selectedClan.members do local member=entry local roles={leader="Líder",officer="Oficial",member="Integrante"}
  row("Members","Member_"..member.userId,member.name.." · "..roles[member.role].."\nContribuição: "..member.contributionXP.." XP",function()
   selectedMember=member memberInfo.Text=member.name.."\n"..roles[member.role]clear("Member")
   local localClan=own()local authority=localClan and localClan.id==selectedClan.id and localClan.role
   if member.userId~=player.UserId and authority and(authority=="leader"or authority=="officer"and member.role=="member")then
    local function payload(role)return{userId=member.userId,epoch=member.epoch,role=role}end
    row("Member","Kick","Remover integrante",function()confirm("Remover "..member.name.." do clã?",function()return send("kick",payload())end)end)
    if authority=="leader"then
     row("Member","Role",member.role=="officer"and"Rebaixar para integrante"or"Promover a oficial",function()if send("role",payload(member.role=="officer"and"member"or"officer"))then reload()browser:Push({"RootPane"})end end)
     row("Member","Leader","Transferir liderança",function()confirm("Transferir a liderança para "..member.name.."? Você passará a oficial.",function()return send("leader",payload())end)end)
    end
   end
   browser:Push({"RootPane","Members","Member"})
  end,62)
 end browser:Push({"RootPane","Members"})
end)
local invite=browser:Button("Overview","Invite","Convidar amigo do lobby  ›",function()
 clear("Invite")for _,target in Players:GetPlayers()do if target~=player and target:GetAttribute("CrossgroundsMode")=="hub"then local id=target.UserId
  row("Invite","Player_"..id,target.DisplayName.."  @"..target.Name,function()local ok,value=send("invite",id)status.Text=tostring(value)if ok then browser:Push({"RootPane"})end end)
 end end browser:Push({"RootPane","Invite"})
end)
local leave=browser:Button("Overview","Leave","Sair do clã",function()confirm("Sair do clã? Sua contribuição permanecerá na história dele. O líder deve transferir o cargo antes de sair; o último integrante encerra o clã.",function()return send("leave")end)end)
local share=field("Overview","ShareId","ID do clã")share.TextEditable=false
paintOverview=function()
 local c=selectedClan if not c then return end
 local definition=Catalog.Emblems[c.emblem]or Catalog.Emblems.star
 overview.Text=definition.glyph.." ["..c.tag.."] "..c.name.."\nNível "..c.level.." · "..#c.members.." / "..c.capacity.." integrantes\n"..c.xp.." / "..Catalog.Threshold(c.level+1).." XP\nRecompensa no nível 3: contribua com 1.000 XP para conquistar cosméticos permanentes."
 local function stats(title,s)return title.."\n"..s.XP.." XP · "..s.Wins.." vitórias\n"..s.Kills.." eliminações · "..s.BotKills.." contra bots\n"..s.Captures.." capturas · "..s.Deaths.." mortes"end
 currentStats.Text=stats("HISTÓRICO DO ELENCO ATUAL",c.current)
 earnedStats.Text=stats("CONQUISTAS ENQUANTO NO CLÃ",c.earned)
 local localClan=own()local isOwn=localClan and localClan.id==c.id
 leave.Visible=isOwn==true invite.Visible=isOwn and(c.role=="leader"or c.role=="officer")or false
 share.Text=c.id
end
refresh=function()
 local data=Clan:Get()local c=data.clan
 status.Text=Clan.Busy and"Consultando clã..."or Clan.Status~=""and Clan.Status or data.pending and"Filiação pendente: repita a confirmação ou cancele para liberar seu perfil."or c and("["..c.tag.."] "..c.name.."\nNível "..c.level)or"Crie um clã ou aceite um convite de um amigo."
 if data.sessionOnly then status.Text..="\nStudio: dados apenas desta sessão."end
 mine.Visible=c~=nil and not data.pending create.Visible=not c and not data.pending retry.Visible=data.pending==true cancelPending.Visible=data.pending==true
 if c and selectedClan and c.id==selectedClan.id then selectedClan=c paintOverview()end
end
Clan.Changed:Connect(function()if gui.Enabled then refresh()end end)
Nav.MenuRequested:Connect(function(id)
 if id=="Clan"then
  for _,key in {"SocialMenuOpen","CareerMenuOpen","ProgressionMenuOpen","LobbyMusicMenuOpen"}do player:SetAttribute(key,false)end
  player:SetAttribute("ClanMenuOpen",true)gui.Enabled=true browser:Push({"RootPane"})browser:SetOpen(true)refresh()task.spawn(function()send("get")end)
 elseif table.find({"Main","Hub","Settings","Resume","Playlist","Progress","Pause","Career","Social"},id)then gui.Enabled=false browser:SetOpen(false)player:SetAttribute("ClanMenuOpen",false)end
end)
Scope.Changed:Connect(function()gui.Enabled=false browser:SetOpen(false)player:SetAttribute("ClanMenuOpen",false)end)
