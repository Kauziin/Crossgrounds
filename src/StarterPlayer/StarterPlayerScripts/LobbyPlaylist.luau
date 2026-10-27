local Playlist={}
local player=game.Players.LocalPlayer
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Settings=require(game.ReplicatedStorage.ExperienceSettings)
local Catalog=require(game.ReplicatedStorage.Crossgrounds.LobbyMusicCatalog)
local changed=Instance.new("BindableEvent") Playlist.Changed=changed.Event
Playlist.Tracks={} Playlist.Paused=false Playlist.Shuffle=false Playlist.Index=1 Playlist.State="Preparando"
for _,track in Catalog do local copy=table.clone(track) copy.enabled=track.enabled~=false table.insert(Playlist.Tracks,copy) end
local sound local retired={} local failed={} local loadingSince local lastAllowed
local function allowed() return Scope:IsHub() and not player:GetAttribute("InArena") and not player:GetAttribute("ArenaPlaying") end
local function emit()
 script:SetAttribute("CurrentTrack",Playlist.Tracks[Playlist.Index] and Playlist.Tracks[Playlist.Index].id)
 script:SetAttribute("PlaybackState",Playlist.State) changed:Fire()
end
function Playlist:Snapshot()
 return {tracks=self.Tracks,index=self.Index,paused=self.Paused,shuffle=self.Shuffle,state=self.State,active=allowed()}
end
function Playlist:Select(id,automatic)
 local index for i,t in self.Tracks do if t.id==id then index=i break end end
 if not index then return false end
 -- Listening to a disabled candidate is a preview; inclusion stays explicit.
 self.Index=index
 if not automatic then self.Paused=false failed[id]=nil end
 if sound then table.insert(retired,{sound=sound,started=os.clock()}) end
 sound=Instance.new("Sound") sound.Name="CrossgroundsLobbyTrack" sound.SoundId=self.Tracks[index].soundId sound.Volume=0 sound.Looped=false sound.Parent=game.SoundService self.Sound=sound loadingSince=nil
 local voice=sound
 sound.Ended:Connect(function() if self.Sound==voice then self:Next(1,true) end end)
 self.State=allowed() and "Carregando" or "Pausada durante a partida" emit()
 return true
end
function Playlist:Next(step,automatic)
 local options={}
 for offset=1,#self.Tracks do
  local i=(self.Index-1+(step or 1)*offset)%#self.Tracks+1 local t=self.Tracks[i]
  if t.enabled and (not automatic or not failed[t.id]) then table.insert(options,i) end
 end
 if #options==0 then self.Paused=true self.State="Nenhuma faixa disponível. Selecione uma faixa para tentar novamente." emit() return false end
 local index=options[1]
 if self.Shuffle and (step or 1)>0 and #options>1 then
  local choices={} for _,i in options do if i~=self.Index then table.insert(choices,i) end end
  index=choices[math.random(1,#choices)]
 end
 return self:Select(self.Tracks[index].id,automatic)
end
function Playlist:TogglePause()
 self.Paused=not self.Paused
 if not self.Paused then local track=self.Tracks[self.Index] if track then failed[track.id]=nil end end
 emit()
end
function Playlist:ToggleShuffle() self.Shuffle=not self.Shuffle emit() end
function Playlist:ToggleTrack(id)
 for _,track in self.Tracks do if track.id==id then
  local count=0 for _,t in self.Tracks do if t.enabled then count+=1 end end
  if track.enabled and count<=1 then return false,"Mantenha ao menos uma faixa na playlist." end
  track.enabled=not track.enabled
  if not track.enabled and self.Tracks[self.Index]==track then self:Next(1,false) end
  emit() return true
 end end
 return false
end
function Playlist:Move(id,direction)
 local current=self.Tracks[self.Index].id
 for i,t in self.Tracks do if t.id==id then
  local target=math.clamp(i+direction,1,#self.Tracks)
  table.remove(self.Tracks,i) table.insert(self.Tracks,target,t) break
 end end
 for i,t in self.Tracks do if t.id==current then self.Index=i end end emit()
end
function Playlist:Start()
 if self.Started then return end self.Started=true
 local legacy=game.SoundService:FindFirstChild("LocalMenuMusic") if legacy then legacy:Stop() end
 self:Select(self.Tracks[self.Index].id,true)
 game:GetService("RunService").Heartbeat:Connect(function(dt)
  local active=allowed()
  local volume=player:GetAttribute("SettingMenuVolume")
  if volume==nil then volume=Settings.Rules.MenuVolume.Default end
  local goal=active and not self.Paused and volume or 0
  for i=#retired,1,-1 do
   local old=retired[i] old.sound.Volume*=math.exp(-dt*8)
   if os.clock()-old.started>.8 then old.sound:Destroy() table.remove(retired,i) end
  end
  if sound then
   sound.Volume+=(goal-sound.Volume)*(1-math.exp(-dt*6))
   if goal>0 then
    if not sound.IsPlaying then sound:Resume() if not sound.IsPlaying then sound:Play() end end
    loadingSince=loadingSince or os.clock()
    if sound.IsLoaded and sound.TimeLength>0 then
     if self.State~="Tocando" then self.State="Tocando" emit() end
    elseif os.clock()-loadingSince>12 then
     failed[self.Tracks[self.Index].id]=true
     self:Next(1,true)
    end
   elseif sound.Volume<.002 then
    sound.Volume=0 if sound.IsPlaying then sound:Pause() end
    local state=not active and "Pausada durante a partida" or self.Paused and "Pausada" or "Volume em zero"
    if self.State~=state then self.State=state emit() end
   end
  end
  if lastAllowed~=active then lastAllowed=active emit() end
 end)
end
return Playlist
