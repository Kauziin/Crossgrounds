local player=game.Players.LocalPlayer
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local Playlist=require(script.Parent:WaitForChild("LobbyPlaylist")) Playlist:Start()
local gui=Instance.new("ScreenGui") gui.Name="LobbyMusicMenu" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=78 gui.Enabled=false gui.Parent=player.PlayerGui
local browser=Cascade.new(gui,"Backdrop","MÚSICA DO LOBBY")
browser:AddPane("Tracks","PLAYLIST") browser:AddPane("Track","EDITAR FAIXA")
local selected=Playlist.Tracks[1].id
local function close()
 gui.Enabled=false browser:SetOpen(false) player:SetAttribute("LobbyMusicMenuOpen",false)
 Nav:OpenMenu(Scope:IsHub() and "Hub" or "Main")
end
browser.OnClose=close
local now=browser:Info("RootPane","NowPlaying","",78) now.LayoutOrder=-1
local pause=browser:Button("RootPane","Pause","Pausar",function() Playlist:TogglePause() end)
browser:Button("RootPane","Previous","Faixa anterior",function() Playlist:Next(-1,false) end)
browser:Button("RootPane","Next","Próxima faixa",function() Playlist:Next(1,false) end)
local shuffle=browser:Button("RootPane","Shuffle","Aleatório: desligado",function() Playlist:ToggleShuffle() end)
browser:Button("RootPane","Tracks","Editar playlist  ›",function() browser:Push({"RootPane","Tracks"}) end)
browser:Button("RootPane","Close","Voltar ao menu",close)
local note=browser:Info("Tracks","Note","Escolha uma faixa para ouvir, retirar ou mudar a ordem. Alterações valem nesta sessão.",64) note.LayoutOrder=-1
local detail=browser:Info("Track","Description","",72)
local status=browser:Info("Track","Status","",40)
browser:Button("Track","Play","Ouvir agora",function() Playlist:Select(selected,false) end)
local include=browser:Button("Track","Include","",function()
 local ok,message=Playlist:ToggleTrack(selected) status.Text=ok and "" or message
end)
browser:Button("Track","MoveUp","Mover para cima",function() Playlist:Move(selected,-1) end)
browser:Button("Track","MoveDown","Mover para baixo",function() Playlist:Move(selected,1) end)
local rows={}
local function refresh()
 local state=Playlist:Snapshot() local playing=state.tracks[state.index]
 now.Text=(playing and playing.title or "Sem faixa").."\n"..state.state
 pause.Text=state.paused and "Retomar música" or "Pausar música"
 shuffle.Text="Aleatório: "..(state.shuffle and "ligado" or "desligado")
 for i,t in state.tracks do
  if not rows[t.id] then
   local id=t.id
   rows[id]=browser:Button("Tracks",id,"",function() selected=id status.Text="" browser:Push({"RootPane","Tracks","Track"}) refresh() end,68)
  end
  local row=rows[t.id] row.LayoutOrder=i
  row.Text=i..". "..t.title.."\n"..(t.enabled and "Na playlist" or "Desativada")..(state.index==i and " · selecionada" or "")
  if t.id==selected then detail.Text=t.title.."\n"..t.artist include.Text=t.enabled and "Retirar da playlist" or "Incluir na playlist" end
 end
end
Playlist.Changed:Connect(refresh)
Nav.MenuRequested:Connect(function(id)
 if id=="Playlist" then
  player:SetAttribute("ProgressionMenuOpen",false) player:SetAttribute("LobbyMusicMenuOpen",true)
  gui.Enabled=true browser:Push({"RootPane"}) browser:SetOpen(true) refresh()
 elseif table.find({"Main","Hub","Settings","Resume","ArenaVote","CTFKits"},id) then
  gui.Enabled=false browser:SetOpen(false) player:SetAttribute("LobbyMusicMenuOpen",false)
 end
end)
Scope.Changed:Connect(function() gui.Enabled=false browser:SetOpen(false) player:SetAttribute("LobbyMusicMenuOpen",false) end)
refresh()

