local player=game.Players.LocalPlayer
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Bridge=require(script.Parent:WaitForChild("HubBridge"))
local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Catalog=require(game.ReplicatedStorage.Crossgrounds.GameCatalog)
local gui=Instance.new("ScreenGui") gui.Name="CrossgroundsHub" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=60 gui.Parent=player.PlayerGui
local browser=Cascade.new(gui,"BrowserBackdrop","CROSSGROUNDS")
browser:AddPane("Modes","MODALIDADES") browser:AddPane("ModeDetails","SOBRE O MODO")
local selected="ctf" local catalogOpen=true local quickEntry local lastMode=Scope:Get() local cards={}
local refresh
local function stay()
 local data=Bridge:Get() local q=data and data.queue
 quickEntry=nil
 if q and (q.state=="joining" or q.state=="ready") then Bridge:Send("cancel",nil,q.ticket) end
 catalogOpen=false player:SetAttribute("LobbyMenuDismissed",true)
 if refresh then refresh() end
end
browser.OnClose=stay
local resume=browser:Button("RootPane","StayLobby","Permanecer no lobby",stay)
browser:Button("RootPane","Modes","Jogar  ›",function() browser:Push({"RootPane","Modes"}) end)
browser:Button("RootPane","Progress","Progresso",function() player:SetAttribute("ProgressionMenuOpen",true) end)
browser:Button("RootPane","Settings","Ajustes",function() Nav:OpenMenu("Settings") end)
browser:Button("RootPane","Music","Música / Playlist",function() Nav:OpenMenu("Playlist") end)
local function definition()
 local data=Bridge:Get() for _,v in data and data.catalog or {} do if v.id==selected then return v end end
end
local description=browser:Info("ModeDetails","Description","Carregando...",150)
local primary=browser:Button("ModeDetails","Primary","Jogar",function()
 local data=Bridge:Get() local item=definition() if not data or not item or Bridge.Pending then return end
 local q=data.queue
 if q.state=="ready" then Bridge:Send("enter",nil,q.ticket)
 elseif (q.state=="idle" or q.state=="failed") and item.canEnter then quickEntry=selected Bridge:Send("join",selected) end
end)
local cancel=browser:Button("ModeDetails","CancelEntry","Cancelar entrada",function()
 local data=Bridge:Get() if data and (data.queue.state=="ready" or data.queue.state=="joining") then quickEntry=nil Bridge:Send("cancel",nil,data.queue.ticket) end
end)
local status=browser:Info("ModeDetails","Status","",62)
browser:Button("ModeDetails","StayLobby","Permanecer no lobby",stay)
for _,v in Catalog:List() do
 local id=v.id
 local b=browser:Button("Modes",id,v.name,function() selected=id browser:Push({"RootPane","Modes","ModeDetails"}) if refresh then refresh() end end,60)
 b.Text=""
 local title=Theme.Text(b,"ModeName",v.name,24,16) title.Position=UDim2.fromOffset(12,8) title.Size=UDim2.new(1,-24,0,24) title.TextTruncate=Enum.TextTruncate.AtEnd title.TextWrapped=false
 local stateText=Theme.Text(b,"State","Carregando...",22,12) stateText.Position=UDim2.fromOffset(12,36) stateText.Size=UDim2.new(1,-24,0,22) stateText.TextWrapped=false stateText.TextTruncate=Enum.TextTruncate.AtEnd
 cards[id]={Button=b,Title=title,State=stateText}
end
local overlay=Instance.new("Frame") overlay.Name="StatusPanel" overlay.AnchorPoint=Vector2.new(.5,.5) overlay.Position=UDim2.fromScale(.5,.5) overlay.Size=UDim2.fromOffset(360,220) overlay.Visible=false overlay.Parent=gui Theme.Surface(overlay)
local message=Theme.Text(overlay,"Message","",120,16) message.Position=UDim2.fromOffset(16,16) message.Size=UDim2.new(1,-32,0,128)
local acknowledge=Instance.new("TextButton") acknowledge.Name="Continue" acknowledge.Text="Voltar ao lobby" acknowledge.Position=UDim2.new(0,16,1,-64) acknowledge.Size=UDim2.new(1,-32,0,48) acknowledge.Parent=overlay Theme.Button(acknowledge)
Nav:Connect(acknowledge,function() Bridge:Send("dismiss") end) Nav:SetBack(overlay,function() Bridge:Send("dismiss") end,acknowledge)
local reopen=Instance.new("TextButton") reopen.Name="OpenModes" reopen.Text="Jogar / Modalidades" reopen.AnchorPoint=Vector2.new(0,1) reopen.Position=UDim2.new(0,20,1,-22) reopen.Size=UDim2.fromOffset(214,42) reopen.TextSize=15 reopen.Parent=gui Theme.Button(reopen)
Nav:Connect(reopen,function() catalogOpen=true browser:Push({"RootPane","Modes"}) refresh() end)
refresh=function()
 local data=Bridge:Get() local mode=Scope:Get() local q=data and data.queue or {state="idle"}
 local open=mode=="hub" and catalogOpen and not player:GetAttribute("ExperienceMenuOpen") and not player:GetAttribute("ProgressionMenuOpen") and not player:GetAttribute("LobbyMusicMenuOpen")
 if browser.Backdrop.Visible~=open then browser:SetOpen(open) end
 player:SetAttribute("LobbyBrowserOpen",open)
 reopen.Visible=mode=="hub" and not open and not player:GetAttribute("ExperienceMenuOpen") and not player:GetAttribute("ProgressionMenuOpen") and not player:GetAttribute("LobbyMusicMenuOpen")
 local attention=mode~="hub" and (q.state=="failed" or q.state=="entering" or q.state=="travelling" or data and data.error or Bridge.LocalError)
 overlay.Visible=attention and true or false message.Text=Bridge.LocalError or data and data.error or q.message or ""
 acknowledge.Visible=q.state~="entering" and q.state~="travelling"
 if not data then return end
 if q.state=="ready" and q.route=="local" and quickEntry==q.gameId and not Bridge.Pending then quickEntry=nil task.defer(function() Bridge:Send("enter",nil,q.ticket) end) end
 local item=definition()
 for index,v in data.catalog do
  local card=cards[v.id]
  if card then
   local playable=v.canEnter==true
   card.Button.LayoutOrder=(playable and 0 or 1000)+index
   card.Button.Size=UDim2.new(1,-4,0,playable and 74 or 50)
   card.Button.BackgroundTransparency=playable and .22 or .6
   card.Button:SetAttribute("Playable",playable)
   card.Title.Text=v.name card.Title.TextSize=playable and 16 or 13
   card.Title.TextColor3=playable and Theme.Colors.Text or Color3.fromRGB(149,151,159)
   card.Title.Position=UDim2.fromOffset(12,playable and 9 or 5)
   card.State.Text=playable and "Disponível para jogar" or v.status=="planned" and "Em breve" or "Indisponível"
   card.State.TextColor3=playable and Color3.fromRGB(121,228,157) or Color3.fromRGB(137,140,149)
   card.State.Position=UDim2.fromOffset(12,playable and 40 or 27)
  end
 end
 description.Text=item and (item.name.."\n\n"..item.description.."\n\n"..(item.canEnter and "Escolha Jogar para entrar. Você pode permanecer no lobby pelo menu." or item.reason or "Em desenvolvimento.")) or "Carregando o catálogo..."
 primary.Text=Bridge.Pending and "Aguarde..." or q.state=="ready" and "Confirmar entrada" or item and item.canEnter and "Jogar "..item.name or "Em desenvolvimento"
 cancel.Visible=q.state=="joining" or q.state=="ready"
 status.Text=Bridge.LocalError or data.error or (q.state~="idle" and q.message) or ""
end
Nav:SetBack(browser.Panel,function() if #browser.Stack>1 then browser:Push({"RootPane"}) else stay() end end,resume)
Nav.MenuRequested:Connect(function(id)
 if id=="Hub" and Scope:IsHub() then catalogOpen=true browser:Push({"RootPane","Modes"}) refresh()
 elseif id=="Resume" and Scope:IsHub() then stay() end
end)
Scope.Changed:Connect(function()
 local mode=Scope:Get() if mode=="hub" and lastMode~="hub" then catalogOpen=false end lastMode=mode refresh()
end)
Bridge.Changed:Connect(refresh)
player:GetAttributeChangedSignal("ExperienceMenuOpen"):Connect(refresh)
player:GetAttributeChangedSignal("ProgressionMenuOpen"):Connect(refresh)
player:GetAttributeChangedSignal("LobbyMusicMenuOpen"):Connect(refresh)
browser:Push({"RootPane"}) refresh()

