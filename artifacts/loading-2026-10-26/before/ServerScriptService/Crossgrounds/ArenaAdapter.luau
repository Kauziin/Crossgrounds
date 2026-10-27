local Adapter={} Adapter.__index=Adapter
local Players=game:GetService("Players") local Run=game:GetService("RunService")
local Def=require(game.ReplicatedStorage.Crossgrounds.ArenaDefinitions)
local Sprint=require(game.ReplicatedStorage.Crossgrounds.SprintDefinitions)
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Ballot=require(script.Parent.MapBallot)
local MapLoadGate=require(script.Parent.MapLoadGate)
function Adapter.new(context,ctfRoot,config)
 local event=Instance.new("BindableEvent")
 local self=setmetatable({id="arena",version=Def.Version,state="prototype",context=context,config=config,members={},loading={},deathConnections={},characterConnections={},connections={},generation=0,phase="idle",endsAt=0,changed=event,Changed=event.Event,maps=require(script.Parent.ArenaMaps).new(),lastVote={}},Adapter)
 self.combat=require(script.Parent.ArenaCombat).new(self,require(ctfRoot.WeaponFactory))
 local root=game.ReplicatedStorage.Crossgrounds local remotes=root:FindFirstChild("ArenaRemotes") or Instance.new("Folder") remotes.Name="ArenaRemotes" remotes.Parent=root
 local function remote(name,class) local r=remotes:FindFirstChild(name) or Instance.new(class) r.Name=name r.Parent=remotes return r end
 self.stateRemote=remote("State","RemoteEvent")
 table.insert(self.connections,remote("VoteMap","RemoteEvent").OnServerEvent:Connect(function(player,id)
  if typeof(id)~="string" or #id>40 or not self.members[player] or context:GetMode(player)~="arena" or player:GetAttribute("CrossgroundsTransition") or self.phase~="voting" or workspace:GetServerTimeNow()>self.endsAt then return end
  local now=os.clock() if now-(self.lastVote[player] or -10)<.15 then return end self.lastVote[player]=now
  if self.ballot:Vote(player,id) then self:Publish() end
 end))
 table.insert(self.connections,remote("SelectPistolVisual","RemoteEvent").OnServerEvent:Connect(function(player,id)
  if typeof(id)~="string" or not Kits:IsPistolVisual(id) or not self.members[player] or context:GetMode(player)~="arena" or player:GetAttribute("CrossgroundsTransition") then return end
  local member=self.members[player] local now=os.clock() if now-(member.lastCosmetic or -10)<.25 then return end
  member.lastCosmetic=now player:SetAttribute("PendingArenaLoadout",id) self:Publish()
 end))
 return self
end
function Adapter:IsAvailable() return #self.maps:Catalog()>=2 end
function Adapter:IsPlaying(player) return self.members[player]~=nil and self.context:GetMode(player)=="arena" and self.phase=="playing" and player:GetAttribute("ArenaPlaying")==true end
function Adapter:Snapshot(player)
 local counts=self.ballot and self.ballot:Counts() or {}
 return {id="arena",version=self.version,state=self.phase,endsAt=self.endsAt,paused=self.paused==true,remaining=self.paused and self.remaining or math.max(0,self.endsAt-workspace:GetServerTimeNow()),map=self.mapId,options=self.maps:Catalog(),counts=counts,vote=self.ballot and self.ballot.votes[player],prototype=true,message=self.message or "Arena · 20 HP · pistola + Executor",health=Def.Health,sessionXP=player:GetAttribute("ArenaSessionXP") or 0,kills=player:GetAttribute("ArenaKills") or 0,deaths=player:GetAttribute("ArenaDeaths") or 0}
end
function Adapter:Publish()
 for player in self.members do if player.Parent then self.stateRemote:FireClient(player,self:Snapshot(player)) end end
 self.changed:Fire()
end
function Adapter:EnsureStaging()
 if self.staging then return end
 local folder=Instance.new("Folder") folder.Name="CrossgroundsArenaStaging" folder:SetAttribute("CrossgroundsOwned",true)
 local function part(name,size,offset) local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=CFrame.new(Def.Staging+offset) p.Anchored=true p.Color=Color3.fromRGB(36,52,71) p.Parent=folder return p end
 part("Floor",Vector3.new(70,1,70),Vector3.zero)
 for _,a in {{Vector3.new(70,9,2),Vector3.new(0,4.5,35)},{Vector3.new(70,9,2),Vector3.new(0,4.5,-35)},{Vector3.new(2,9,70),Vector3.new(35,4.5,0)},{Vector3.new(2,9,70),Vector3.new(-35,4.5,0)}} do part("Barrier",a[1],a[2]) end
 folder.Parent=workspace self.staging=folder
end
function Adapter:Configure(player,character)
 if not self.members[player] or self.context:GetMode(player)~="arena" or player.Character~=character then return end
 local h=character:FindFirstChildOfClass("Humanoid") local root=character:FindFirstChild("HumanoidRootPart") if not h or not root then return end
 require(script.Parent.LoadoutService).ApplyPending(player,"arena")
 self:EnsureStaging() self.combat:Strip(player)
 player.Neutral=true player.Team=nil player:SetAttribute("InMatch",false) player:SetAttribute("InArena",false)
 character:SetAttribute("AtLobby",false) character:SetAttribute("SpawnProtectedUntil",nil)
 for _,f in character:GetChildren() do if f:IsA("ForceField") then f:Destroy() end end
 local profile=Kits.Profiles.Regular
 local member=self.members[player] member.displayModes=member.displayModes or setmetatable({},{__mode="k"})
 if member.displayModes[h]==nil then member.displayModes[h]=h.HealthDisplayType end
 h.MaxHealth=Def.Health h.Health=Def.Health h.HealthDisplayType=Enum.HumanoidHealthDisplayType.AlwaysOff h.UseJumpPower=false h.JumpHeight=profile.JumpHeight h.AutoRotate=true h.WalkSpeed=profile.WalkSpeed
 player:SetAttribute("KitWalkSpeed",profile.WalkSpeed) player:SetAttribute("KitSprintSpeed",profile.SprintSpeed) player:SetAttribute("KitJumpHeight",profile.JumpHeight)
 player:SetAttribute("SprintActive",false) player:SetAttribute("Stamina",100)
 member.stamina=100 member.lastDrain=0
 local playing=self.phase=="playing" and #self.maps.spawns>0 player:SetAttribute("ArenaPlaying",playing)
 local cf=playing and self.maps:ChooseSpawn(player,self.members) or CFrame.new(Def.Staging+Vector3.new(0,4,0))
 character:PivotTo(cf)
 character:SetAttribute("ArenaProtectedUntil",workspace:GetServerTimeNow()+(playing and Def.ProtectionDuration or 1e8))
 local shield=Instance.new("ForceField") shield.Name="ArenaShield" shield.Visible=false shield.Parent=character
 self.combat:Equip(player)
 player:SetAttribute("ArenaRespawnAt",0) self.context:MarkReady(player)
 if self.deathConnections[player] then self.deathConnections[player]:Disconnect() end
 self.deathConnections[player]=h.Died:Once(function()
  if not self.members[player] or self.context:GetMode(player)~="arena" then return end
  require(script.Parent.ProgressionService).ArenaDeath(player)
  player:SetAttribute("ArenaDeaths",(player:GetAttribute("ArenaDeaths") or 0)+1) player:SetAttribute("ArenaPlaying",false) player:SetAttribute("ModeCharacterReady",false)
  local token=member.life or 0 member.life=token+1
  player:SetAttribute("ArenaRespawnAt",workspace:GetServerTimeNow()+Def.RespawnDelay) self:Publish()
  task.delay(Def.RespawnDelay,function() if self.members[player]==member and member.life==token+1 and player.Character==character and player.Parent then self:Spawn(player) end end)
 end)
end
function Adapter:Spawn(player)
 if self.loading[player] or not self.members[player] or not player.Parent then return end
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 if h and h.Health>0 then self:Configure(player,c) return end
 self.loading[player]=true local ok,err=pcall(function() player:LoadCharacterAsync() end) self.loading[player]=nil
 if not ok then self.message="Falha ao carregar personagem: tente voltar ao hub." warn(err) self:Publish() end
end
function Adapter:BeginVote()
 self.paused=false self.remaining=nil
 self.phase="voting" self.message=nil self.ballot=Ballot.new(self.maps:Catalog()) self.endsAt=workspace:GetServerTimeNow()+Def.VoteDuration
 for player in self.members do self:Spawn(player) end self:Publish()
end
function Adapter:Targets()
 local world=self.maps.world local token=self.generation
 local function target(index,cf)
  if self.generation~=token or self.phase~="playing" or self.maps.world~=world then return end
  local model=Instance.new("Model") model.Name="Alvo de treino "..index model:SetAttribute("ArenaTarget",true)
  local function part(name,size,offset,color) local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf*CFrame.new(offset) p.Anchored=true p.Color=color p.Parent=model return p end
  local root=part("HumanoidRootPart",Vector3.new(2,2,1),Vector3.zero,Color3.new(0,0,0)) root.Transparency=1 root.CanCollide=false
  part("Torso",Vector3.new(2,2,1),Vector3.zero,Color3.fromRGB(204,137,55))
  for _,side in {-1,1} do
   part(side<0 and "Left Arm" or "Right Arm",Vector3.new(1,2,1),Vector3.new(side*1.5,0,0),Color3.fromRGB(238,202,131))
   part(side<0 and "Left Leg" or "Right Leg",Vector3.new(1,2,1),Vector3.new(side*.5,-2,0),Color3.fromRGB(55,74,92))
  end
  local head=part("Head",Vector3.new(1.25,1.25,1.25),Vector3.new(0,1.65,0),Color3.fromRGB(238,202,131))
  local h=Instance.new("Humanoid") h.RequiresNeck=false h.MaxHealth=Def.Health h.Health=Def.Health h.HealthDisplayType=Enum.HumanoidHealthDisplayType.AlwaysOff h.DisplayName="ALVO DE TREINO" h.Parent=model model.PrimaryPart=root model.Parent=world
  h.Died:Once(function() task.delay(1,function() if model.Parent then model:Destroy() end end) task.delay(Def.RespawnDelay,function() target(index,cf) end) end)
 end
 for i=1,3 do
  local index=math.clamp(math.floor(#self.maps.spawns*(i/4)),1,#self.maps.spawns)
  local cf=table.remove(self.maps.spawns,index) target(i,cf)
 end
end
function Adapter:FinishVote()
 return self:StartMap(self.ballot:Winner(self.mapId))
end
function Adapter:StartMap(id)
 self.generation+=1
 self.phase="loading" self.endsAt=0 self:Publish()
 local generation=self.generation
 local called,ok,err=pcall(self.maps.Load,self.maps,id,function() return self.generation==generation and next(self.members)~=nil end)
 if not called then err="Falha ao carregar o mapa." ok=false end
 if self.generation~=generation or not next(self.members) then return end
 if not ok then self.phase="failed" self.message=err self:Publish() return end
 self.message="Carregando cenário..." self.endsAt=workspace:GetServerTimeNow()+MapLoadGate.Seconds self:Publish()
 if not MapLoadGate.Wait(function() return self.generation==generation and self.phase=="loading" and next(self.members)~=nil end) then return end
 self.mapId=id self.phase="playing" self.paused=false self.remaining=nil self.endsAt=workspace:GetServerTimeNow()+Def.RoundDuration
 self.message=nil
 self:Targets()
 for player in self.members do player:SetAttribute("ArenaKills",0) player:SetAttribute("ArenaDeaths",0) self:Spawn(player) end
 self:Publish()
end
function Adapter:Enter(player)
 if not self:IsAvailable() then return false,"Os mapas de teste da Arena não estão instalados." end
 if self.members[player] then return false,"Você já está na Arena." end
 self.members[player]={stamina=100,lastDrain=0,life=0}
 if not Kits:IsPistolVisual(player:GetAttribute("ArenaPistolVisual")) then player:SetAttribute("ArenaPistolVisual",Kits.ArenaPistolVisuals[math.random(#Kits.ArenaPistolVisuals)]) end
 self.context:SetMode(player,"arena") player:SetAttribute("ArenaSessionXP",0) player:SetAttribute("ArenaKills",0) player:SetAttribute("ArenaDeaths",0)
 if self.phase=="idle" then self.generation+=1 self:BeginVote() else self:Spawn(player) end
 self:Publish()
 local deadline=os.clock()+12
 repeat if not player.Parent or self.context:GetMode(player)~="arena" then return false,"Entrada interrompida." end if player:GetAttribute("ModeCharacterReady") then return true end task.wait(.05) until os.clock()>deadline
 return false,"Personagem indisponível. Tente novamente."
end
function Adapter:Forget(player)
 local member=self.members[player]
 if member and member.displayModes then for h,mode in member.displayModes do if h.Parent then h.HealthDisplayType=mode end end end
 self.members[player]=nil self.lastVote[player]=nil self.loading[player]=nil self.combat:Strip(player)
 if self.deathConnections[player] then self.deathConnections[player]:Disconnect() self.deathConnections[player]=nil end
 if self.ballot then self.ballot:Remove(player) end
 player:SetAttribute("ArenaPlaying",false) player:SetAttribute("ArenaRespawnAt",0) player:SetAttribute("SprintActive",false) player:SetAttribute("Stamina",100)
 if not next(self.members) then self.generation+=1 self.phase="idle" self.endsAt=0 self.maps:Clear() self.ballot=nil end
 self:Publish()
end
function Adapter:Leave(player)
 self:Forget(player) self.context:SetMode(player,"hub")
 local character=player.Character local shield=character and character:FindFirstChild("ArenaShield") if shield then shield:Destroy() end
 if self.playerManager then self.playerManager:Spawn(player) else self.context:ApplyHubCharacter(player,character) end
 local deadline=os.clock()+12
 repeat if not player.Parent then return false,"Saída interrompida." end if player:GetAttribute("ModeCharacterReady") then return true end task.wait(.05) until os.clock()>deadline
 return false,"Não foi possível preparar o personagem do hub."
end
function Adapter:Start(playerManager)
 if self.started then return end self.started=true self.playerManager=playerManager
 workspace:SetAttribute("ArenaRuntimeStartCount",(workspace:GetAttribute("ArenaRuntimeStartCount") or 0)+1)
 local function added(player)
  self.characterConnections[player]=player.CharacterAdded:Connect(function(character)
   if self.context:GetMode(player)~="arena" then return end
   character:WaitForChild("Humanoid",10) character:WaitForChild("HumanoidRootPart",10)
   task.defer(function() while self.loading[player] and player.Parent do task.wait() end if player.Parent then self:Configure(player,character) end end)
  end)
  if self.config.PlaceRole=="arena" then task.spawn(function()
   local ok,reason=self:Enter(player)
   if not ok then workspace:SetAttribute("ArenaStartupError",tostring(reason)) warn("Arena startup: "..tostring(reason)) end
  end) end
 end
 table.insert(self.connections,Players.PlayerAdded:Connect(added))
 table.insert(self.connections,Players.PlayerRemoving:Connect(function(player)
  self:Forget(player) if self.characterConnections[player] then self.characterConnections[player]:Disconnect() self.characterConnections[player]=nil end
 end))
 for _,player in Players:GetPlayers() do added(player) end
 local toggle=game.ReplicatedStorage.Events:FindFirstChild("ToggleSprint") or Instance.new("RemoteEvent") toggle.Name="ToggleSprint" toggle.Parent=game.ReplicatedStorage.Events
 local requested=game.ReplicatedStorage.Events:FindFirstChild("SetSprint") or Instance.new("RemoteEvent") requested.Name="SetSprint" requested.Parent=game.ReplicatedStorage.Events
 local function sprint(player,on)
  local member=self.members[player]
  if not member or not self:IsPlaying(player) or player:GetAttribute("CrossgroundsTransition") then return end
  local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if not h or h.Health<=0 then return end
  if on==nil then on=not player:GetAttribute("SprintActive") end
  local active=on==true and member.stamina>=20
  player:SetAttribute("SprintActive",active) h.WalkSpeed=active and Kits.Profiles.Regular.SprintSpeed or Kits.Profiles.Regular.WalkSpeed
 end
 table.insert(self.connections,toggle.OnServerEvent:Connect(function(p) sprint(p) end))
 table.insert(self.connections,requested.OnServerEvent:Connect(function(p,on) if typeof(on)=="boolean" then sprint(p,on) end end))
 local elapsed=0
 table.insert(self.connections,Run.Heartbeat:Connect(function(dt)
  elapsed+=dt if elapsed<.1 then return end local step=elapsed elapsed=0
  for player,member in self.members do
   local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
   if h and h.Health>0 then
    if self:IsPlaying(player) and player:GetAttribute("SprintActive") and h.MoveDirection.Magnitude>.05 then
     member.stamina=math.max(0,member.stamina-step*Sprint.DrainPerSecond) member.lastDrain=os.clock()
     if member.stamina<=0 then player:SetAttribute("SprintActive",false) h.WalkSpeed=Kits.Profiles.Regular.WalkSpeed end
    elseif os.clock()-member.lastDrain>=1 then member.stamina=math.min(100,member.stamina+step*15) end
    player:SetAttribute("Stamina",math.floor(member.stamina+.5))
    if self:IsPlaying(player) and player.Character:GetPivot().Position.Y<(self.maps.killPlaneY or 30) then h.Health=0 end
   end
  end
  if next(self.members) and not self.paused and self.endsAt>0 and workspace:GetServerTimeNow()>=self.endsAt then
   if self.phase=="voting" then task.spawn(function() self:FinishVote() end)
   elseif self.phase=="playing" then self.phase="results" self.endsAt=workspace:GetServerTimeNow()+Def.ResultsDuration for player in self.members do self:Spawn(player) end self:Publish()
   elseif self.phase=="results" then self:BeginVote() end
  end
 end))
end
return Adapter

