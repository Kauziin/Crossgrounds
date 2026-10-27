-- Classic/Locks prototype. All timings in GetOutRules.Prototype are temporary test values.
local Adapter = {} Adapter.__index = Adapter
local Players = game:GetService("Players")
local Run = game:GetService("RunService")
local Rules = require(game.ReplicatedStorage.Crossgrounds.GetOutRules)
local Round = require(script.Parent.GetOutRound)
local Maps = require(script.Parent.GetOutMaps)
local MapLoadGate = require(script.Parent.MapLoadGate)
local Gameplay = require(script.Parent.GetOutGameplay)
local T = require(game.ReplicatedStorage.Crossgrounds.GetOutPrototype)
local P = Rules.Prototype

local function count(dictionary)
 local n=0 for _ in dictionary do n+=1 end return n
end
local function rootOf(player)
 local c=player.Character
 local h=c and c:FindFirstChildOfClass("Humanoid")
 local root=c and c:FindFirstChild("HumanoidRootPart")
 if c and c:IsDescendantOf(workspace) and h and h.Health>0 and root then return root,h end
end

function Adapter.new(context,config)
 local changed=Instance.new("BindableEvent")
 local self=setmetatable({id="get_out",version="0.5-p0",context=context,config=config,
  maps=Maps.new(),members={},roles={},pods={},connections={},objectConnections={},characters={},
  deathConnections={},phase="waiting",endsAt=0,serial=0,round=nil,world=nil,
  panelDone={},hackerReadyAt=0,Changed=changed.Event,changed=changed},Adapter)
 local remotes=game.ReplicatedStorage.Crossgrounds:FindFirstChild("GetOutRemotes") or Instance.new("Folder")
 remotes.Name="GetOutRemotes" remotes.Parent=game.ReplicatedStorage.Crossgrounds
 local function remote(name)
  local value=remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
  assert(value:IsA("RemoteEvent"),"Remote inválido: "..name)
  value.Name=name value.Parent=remotes return value
 end
 self.stateRemote=remote("State")
 self.abilityRemote=remote("UseHacker")
 self.actionRemote=remote("Action") self.feedbackRemote=remote("Feedback") self.loadRemote=remote("LoadReady")
 self.gameplay=Gameplay.new(self) self.loadAcks={} self.spawned={} self.actionRates={}
 return self
end

function Adapter:IsAvailable()
 if not self.config.EnableLocalGetOutPrototype or typeof(self.config.GetOutPrototypeMapId)~="string" then return false end
 for _,entry in self.maps:Catalog({locks=true}) do if entry.id==self.config.GetOutPrototypeMapId then return true end end
 return false
end

function Adapter:Snapshot(player)
 local now=workspace:GetServerTimeNow()
 local round=self.round
 local data=round and round:Snapshot(player,now) or nil
 return {id=self.id,version=self.version,state=self.phase,role=self.roles[player] or "waiting",
  map=round and round.mapId or self.config.GetOutPrototypeMapId,
  routeId=round and round.routeId or nil,roundId=round and round.id or nil,
  remaining=(self.phase=="results" or self.phase=="intermission" or self.phase=="loading") and math.max(0,self.endsAt-now) or round and data.remaining or 0,
  computers=round and data.computers or 0,result=round and round.status[player] or nil,
  results=data and data.results or nil,ending=round and round.ending or nil,
  podRemaining=self.pods[player] and math.max(0,T.PodSeconds*(1-(player:GetAttribute("GetOutFreeze") or 0))) or nil,
  gameplay=self.gameplay:Snapshot(player),
  alliesInPods=count(self.pods),
  hackerReadyIn=player==self.beast and math.max(0,self.hackerReadyAt-now) or nil,
  message=self.message,prototype=true}
end

function Adapter:Publish()
 for player in self.members do if player.Parent then self.stateRemote:FireClient(player,self:Snapshot(player)) end end
 self.changed:Fire()
end

function Adapter:EnsureStaging()
 if self.staging and self.staging.Parent then return end
 local floor=Instance.new("Part") floor.Name="GetOutStaging" floor.Size=Vector3.new(64,2,64)
 floor.CFrame=CFrame.new(1800,180,340) floor.Anchored=true floor.Color=Color3.fromRGB(31,43,54)
 floor:SetAttribute("CrossgroundsOwned",true) floor.Parent=workspace self.staging=floor
 for _,edge in {{Vector3.new(-32,5,0),Vector3.new(1,8,64)},{Vector3.new(32,5,0),Vector3.new(1,8,64)},{Vector3.new(0,5,-32),Vector3.new(64,8,1)},{Vector3.new(0,5,32),Vector3.new(64,8,1)}} do
  local wall=Instance.new("Part") wall.Name="StagingGuard" wall.Anchored=true wall.Size=edge[2] wall.CFrame=floor.CFrame*CFrame.new(edge[1]) wall.Color=floor.Color wall.Transparency=.35 wall.Parent=floor
 end
end

function Adapter:ClearObjectConnections()
 for _,c in self.objectConnections do c:Disconnect() end table.clear(self.objectConnections)
 table.clear(self.panelDone)
end

function Adapter:ClearCharacterPrompt(player)
 local root=rootOf(player)
 local prompt=root and root:FindFirstChild("GetOutCapture")
 if prompt then prompt:Destroy() end
end

function Adapter:StripTools(player)
 for _,container in {player.Character,player:FindFirstChild("Backpack")} do
  if container then for _,item in container:GetChildren() do if item:IsA("Tool") then item:Destroy() end end end
 end
end

function Adapter:CharacterPosition(player)
 if self.round and (self.phase=="playing" or self.phase=="enraged" or self.phase=="deploying") then
  if player==self.beast then return self.maps.manifest.beastSpawn.CFrame end
  if self.roles[player]=="survivor" and self.round.status[player]=="active" then
   local points={}
   for _,point in self.maps.manifest.survivorSpawns do table.insert(points,point) end
   table.sort(points,function(a,b)return a.Name<b.Name end)
   local index=self.members[player].spawnIndex or 1
   return points[(index-1)%#points+1].CFrame
  end
 end
 self:EnsureStaging()
 return self:StagingPosition(player)
end

function Adapter:StagingPosition(player)
 local players={} for p in self.members do table.insert(players,p) end
 table.sort(players,function(a,b)return a.UserId<b.UserId end)
 local index=table.find(players,player) or 1
 return self.staging.CFrame*CFrame.new((index-1)*7-14,5,0)
end

function Adapter:Configure(player,character)
 if not self.members[player] or self.context:GetMode(player)~="get_out" or player.Character~=character then return end
 local root,h=rootOf(player) if not root then return end
 self:StripTools(player)
 player.Neutral=true player.Team=nil
 player:SetAttribute("InMatch",false) player:SetAttribute("InArena",false)
 player:SetAttribute("ArenaPlaying",false) player:SetAttribute("SprintActive",false)
 player:SetAttribute("GetOutRole",self.roles[player] or "waiting")
 player:SetAttribute("GetOutRoundId",self.round and self.round.id or 0)
 player:SetAttribute("GetOutPodState",false)
 player:SetAttribute("GetOutUnstable",player==self.beast and self.phase=="enraged")
 character:SetAttribute("AtLobby",false)
 for _,shield in character:GetChildren() do if shield:IsA("ForceField") then shield:Destroy() end end
 h.MaxHealth=100 h.Health=100 h.WalkSpeed=player==self.beast and (self.phase=="enraged" and P.EnragedWalkSpeed or P.BeastWalkSpeed) or P.SurvivorWalkSpeed
 h.UseJumpPower=false h.JumpHeight=7.2 h.AutoRotate=true root.Anchored=false
 character:PivotTo(self:CharacterPosition(player)*CFrame.new(0,3,0))
 root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
 self.gameplay:Bind(player,h.WalkSpeed)
 h:MoveTo(root.Position)
 root.Anchored=self.phase=="deploying"
 self.spawned[player]=character
 if self.deathConnections[player] then self.deathConnections[player]:Disconnect() end
 self.deathConnections[player]=h.Died:Once(function()
  player:SetAttribute("ModeCharacterReady",false)
  if self.round and (self.phase=="playing" or self.phase=="enraged") then
   if player==self.beast then self.round:Finish("technical_beast_death") self:BeginResults()
   else self.gameplay:CleanPlayer(player) if self.round:Capture(player) then self:ReleasePod(player) self:CheckRoundFinished() end end
  end
  task.delay(2,function()
   if player.Parent and self.members[player] and self.context:GetMode(player)=="get_out" and player.Character==character then self:Spawn(player) end
  end)
 end)
 if self.roles[player]=="survivor" and self.round and self.round.status[player]=="active" then self:AttachCapture(player) end
 self.context:MarkReady(player)
end

function Adapter:Spawn(player)
 if not player.Parent or not self.members[player] then return end
 local root=rootOf(player)
 if root then self:Configure(player,player.Character) return end
 if self.loading and self.loading[player] then return end
 self.loading=self.loading or {} self.loading[player]=true
 player:SetAttribute("ModeCharacterReady",false)
 local ok,err=pcall(function() player:LoadCharacterAsync() end)
 self.loading[player]=nil
 if not ok then warn("Get Out character: "..tostring(err)) end
end

function Adapter:ValidInteraction(player,part,role)
 if not self.round or (self.phase~="playing" and self.phase~="enraged")
  or not self.members[player] or self.roles[player]~=role or player:GetAttribute("CrossgroundsTransition") then return false end
 if not self.gameplay:CanAct(player) then return false end
 if role=="survivor" and (not self.round:IsActive(player) or self.pods[player]) then return false end
 local root=rootOf(player)
 return root~=nil and part:IsDescendantOf(workspace) and (root.Position-part.Position).Magnitude<=12
end

function Adapter:Prompt(part,text,hold,role,callback)
 local prompt=Instance.new("ProximityPrompt") prompt.Name="GetOutPrompt" prompt.ActionText=text
 prompt.ObjectText="Get Out" prompt.HoldDuration=hold prompt.MaxActivationDistance=9
 prompt:SetAttribute("GetOutRole",role)
 prompt.RequiresLineOfSight=false prompt.Parent=part
 local holds={}
 table.insert(self.objectConnections,prompt.PromptButtonHoldBegan:Connect(function(player) holds[player]=workspace:GetServerTimeNow() end))
 table.insert(self.objectConnections,prompt.PromptButtonHoldEnded:Connect(function(player) holds[player]=nil end))
 table.insert(self.objectConnections,prompt.Triggered:Connect(function(player)
  local now=workspace:GetServerTimeNow()
  local began=holds[player] holds[player]=nil
  if not began or now-began<hold-.15 or not self:ValidInteraction(player,part,role) then return end
  callback(player,prompt,now)
 end))
 return prompt
end

function Adapter:AttachCapture(target)
 self:ClearCharacterPrompt(target)
 self.gameplay:Attach(target)
end

function Adapter:ReleasePod(player)
 local state=self.pods[player] if not state then return end
 self.pods[player]=nil player:SetAttribute("GetOutPodState",false)
 local root=rootOf(player)
 if root then root.Anchored=false end
end

function Adapter:OpenDoor(id)
 local marker=self.maps.manifest.routes.locks.doors[id]
 marker.Color=Color3.fromRGB(68,195,129)
 for _,part in self.maps.world.Geometry:GetDescendants() do
  if part:IsA("BasePart") and part:GetAttribute("GetOutExitDoorId")==id then
   part.CanCollide=false part.Transparency=1
  end
 end
end

function Adapter:BuildObjectives()
 self:ClearObjectConnections()
 local data=self.maps.manifest.routes.locks
 self.crankPrompts={}
 self.gameplay:Build()
 for id,marker in data.cranks do
  local p=self:Prompt(marker,"Girar manivela",P.CrankHoldSeconds,"survivor",function(player,prompt)
   if self.round:Crank(player,id) then prompt.Enabled=false self:OpenDoor(id) self:Publish() end
  end)
  p.Enabled=false self.crankPrompts[id]=p
 end
 for id,zone in data.zones do
  table.insert(self.objectConnections,zone.Touched:Connect(function(hit)
   local model=hit:FindFirstAncestorOfClass("Model")
   local player=model and Players:GetPlayerFromCharacter(model)
   if not player or not self:ValidInteraction(player,zone,"survivor") then return end
   if self.round:Escape(player,id) then
    self.gameplay:CleanPlayer(player)
    self:ReleasePod(player) player:SetAttribute("GetOutResult","escaped")
    self:ClearCharacterPrompt(player)
    player.Character:PivotTo(self:StagingPosition(player))
    player.Character:FindFirstChildOfClass("Humanoid"):MoveTo(player.Character.HumanoidRootPart.Position)
    self:Publish() self:CheckRoundFinished()
   end
  end))
 end
 self.containmentPrompts={}
 for id,marker in data.containmentPanels do
  local prompt=self:Prompt(marker,"Rearmar quadro",P.ContainmentPanelHoldSeconds,"survivor",function(player,p)
   if self.phase~="enraged" or self.panelDone[id] then return end
   self.panelDone[id]=true p.Enabled=false marker.Color=Color3.fromRGB(215,169,68)
   if count(self.panelDone)==2 then self.containmentLever.Enabled=true end
  end)
  prompt.Enabled=false self.containmentPrompts[id]=prompt
 end
 self.containmentLever=self:Prompt(data.lever,"Acionar alavanca",P.ContainmentLeverHoldSeconds,"survivor",function()
  if self.phase~="enraged" or count(self.panelDone)~=2 then return end
  local beastRoot=rootOf(self.beast)
  local inside=false
  if beastRoot then
   local offset=data.chamber.CFrame:PointToObjectSpace(beastRoot.Position)
   local half=data.chamber.Size*.5
   inside=math.abs(offset.X)<half.X and math.abs(offset.Y)<half.Y and math.abs(offset.Z)<half.Z
  end
  if self.round:Contain(inside) then
   data.containmentDoor.CanCollide=true data.containmentDoor.Transparency=.2
   self:BeginResults()
  else
   table.clear(self.panelDone) self.containmentLever.Enabled=false
   for id,prompt in self.containmentPrompts do prompt.Enabled=true data.containmentPanels[id].Color=Color3.fromRGB(175,74,66) end
   self:Publish()
  end
 end)
 self.containmentLever.Enabled=false
end

function Adapter:CheckRoundFinished()
 if self.round and self.round.phase=="results" then self:BeginResults() end
end

function Adapter:BeginResults()
 if self.phase=="results" then return end
 self.phase="results" self.endsAt=workspace:GetServerTimeNow()+P.ResultsSeconds
 self.gameplay:Reset()
 for player in self.members do
  self:ReleasePod(player) self:ClearCharacterPrompt(player)
  player:SetAttribute("GetOutResult",self.round and self.round.status[player] or nil)
  local root=rootOf(player)
  if root then root.Anchored=false root.AssemblyLinearVelocity=Vector3.zero player.Character:PivotTo(self:StagingPosition(player)) player.Character:FindFirstChildOfClass("Humanoid"):MoveTo(root.Position) end
 end
 self:Publish()
end

function Adapter:BeginIntermission()
 self.message=nil
 self.gameplay:Reset()
 self:ClearObjectConnections() self.maps:Clear() self.round=nil self.beast=nil
 table.clear(self.roles) table.clear(self.pods)
 for player in self.members do
  player:SetAttribute("GetOutRole","waiting") player:SetAttribute("GetOutPodState",false)
  player:SetAttribute("GetOutUnstable",false)
  self:Spawn(player)
 end
 self.phase=count(self.members)>=P.MinPlayers and "intermission" or "waiting"
 self.endsAt=self.phase=="intermission" and workspace:GetServerTimeNow()+P.IntermissionSeconds or 0
 self:Publish()
end

function Adapter:StartRound()
 if count(self.members)<P.MinPlayers then self:BeginIntermission() return end
 self.phase="loading" self.endsAt=0 self:Publish()
 self.serial+=1 local serial=self.serial
 local players={} for p in self.members do if p.Parent then table.insert(players,p) end end
 local function valid()
  if self.serial~=serial then return false end
  for _,p in players do if not self.members[p] or not p.Parent then return false end end
  return #players>=P.MinPlayers
 end
 local function abort(message)
  if self.serial~=serial then return end
  self.gameplay:Reset() self.round=nil self.beast=nil table.clear(self.roles)
  self.phase="failed" self.endsAt=0 self.message=message
  for p in self.members do self:Spawn(p) end
  self:Publish()
 end
 local ok,manifest,routeId=self.maps:Load(self.config.GetOutPrototypeMapId,nil,{locks=true},valid)
 if self.serial~=serial then return end
 if not valid() then self:BeginIntermission() return end
 if not ok then abort(tostring(manifest)) return end
 local parts=0 for _,v in self.maps.world:GetDescendants() do if v:IsA("BasePart") then parts+=1 end end
 self.maps.world:SetAttribute("LoadToken",serial)
 self.message="Carregando cenário..." self.endsAt=workspace:GetServerTimeNow()+MapLoadGate.Seconds self:Publish()
 local deadline=workspace:GetServerTimeNow()+T.SpawnTimeout
 local sent=0
 repeat
  if not valid() then if self.serial==serial then self:BeginIntermission() end return end
  local time=workspace:GetServerTimeNow()
  if time-sent>=1 then
   sent=time
   for _,p in players do if self.loadAcks[p]~=serial then self.loadRemote:FireClient(p,serial,self.maps.world.Name,parts) end end
  end
  local ready=time>=self.endsAt
  for _,p in players do if self.loadAcks[p]~=serial then ready=false end end
  if ready then break end
  if time>=deadline then abort("O mapa não terminou de carregar para todos. Volte ao hub e tente novamente.") return end
  task.wait(.1)
 until false
 table.sort(players,function(a,b)return a.UserId<b.UserId end)
 self.beast=players[math.random(#players)] local survivors={}
 for _,p in players do if p==self.beast then self.roles[p]="beast" else self.roles[p]="survivor" table.insert(survivors,p) end end
 for i,p in survivors do self.members[p].spawnIndex=i end
 self.round=Round.new(serial,self.maps.mapId,routeId,manifest.routes[routeId],self.beast,survivors,workspace:GetServerTimeNow())
 self.phase="deploying" self.message="Posicionando jogadores..." self.endsAt=0 self:Publish()
 for _,p in players do self.spawned[p]=nil p:SetAttribute("ModeCharacterReady",false) task.spawn(function() self:Spawn(p) end) end
 deadline=workspace:GetServerTimeNow()+T.SpawnTimeout
 repeat
  if not valid() then if self.serial==serial then self:BeginIntermission() end return end
  local ready=true
  for _,p in players do if not rootOf(p) or self.spawned[p]~=p.Character then ready=false end end
  if ready then break end
  if workspace:GetServerTimeNow()>=deadline then abort("Não foi possível preparar os personagens. Volte ao hub e tente novamente.") return end
  task.wait(.1)
 until false
 self.round.startedAt=workspace:GetServerTimeNow()
 self.phase="playing" self.message=nil self.endsAt=self.round.startedAt+Rules.TotalSeconds self.hackerReadyAt=0
 for _,p in players do local root=rootOf(p) if root then root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero root.Anchored=false end end
 self:BuildObjectives()
 for _,p in survivors do self:AttachCapture(p) end
 self:Publish()
end

function Adapter:Enter(player)
 if not self:IsAvailable() then return false,"Get Out ainda não tem mapa Clássico validado neste Place." end
 if self.members[player] then return false,"Você já está no Get Out." end
 if count(self.members)>=P.MaxPlayers then return false,"O protótipo Clássico está cheio." end
 self.members[player]={protectedUntil=0}
 self.context:SetMode(player,"get_out")
 player:SetAttribute("GetOutResult",nil) self:EnsureStaging() self:Spawn(player)
 if self.phase=="waiting" and count(self.members)>=P.MinPlayers then self:BeginIntermission() end
 self:Publish()
 local deadline=os.clock()+12
 repeat
  if not player.Parent or self.context:GetMode(player)~="get_out" then return false,"Entrada interrompida." end
  if player:GetAttribute("ModeCharacterReady") then return true end
  task.wait(.05)
 until os.clock()>deadline
 return false,"Personagem indisponível."
end

function Adapter:Forget(player)
 if not self.members[player] then return end
 self.gameplay:CleanPlayer(player) self.loadAcks[player]=nil self.spawned[player]=nil self.actionRates[player]=nil
 self:ReleasePod(player) self:ClearCharacterPrompt(player)
 if self.round then self.round:Disconnect(player) end
 self.members[player]=nil self.roles[player]=nil
 if self.deathConnections[player] then self.deathConnections[player]:Disconnect() self.deathConnections[player]=nil end
 player:SetAttribute("GetOutRole",nil) player:SetAttribute("GetOutRoundId",nil)
 player:SetAttribute("GetOutPodState",false)
 if count(self.members)==0 then
  self.serial+=1 self:ClearObjectConnections() self.maps:Clear() self.round=nil self.beast=nil
  self.phase="waiting" self.endsAt=0
 elseif self.round and self.round.phase=="results" then self:BeginResults()
 elseif (self.phase=="intermission" or self.phase=="loading" or self.phase=="deploying") and count(self.members)<P.MinPlayers then
  self.serial+=1 self:BeginIntermission()
 end
 self:Publish()
end

function Adapter:Leave(player)
 self:Forget(player)
 self.context:SetMode(player,"hub")
 local root=rootOf(player) if root then root.Anchored=false end
 if self.playerManager then self.playerManager:Spawn(player)
 else self.context:ApplyHubCharacter(player,player.Character) end
 local deadline=os.clock()+12
 repeat
  if not player.Parent then return false,"Saída interrompida." end
  if player:GetAttribute("ModeCharacterReady") then return true end
  task.wait(.05)
 until os.clock()>deadline
 return false,"O personagem do hub não ficou pronto."
end

function Adapter:Start(playerManager)
 if self.started then return end self.started=true self.playerManager=playerManager
 self:EnsureStaging()
 local function added(player)
  self.characters[player]=player.CharacterAdded:Connect(function(character)
   if self.context:GetMode(player)~="get_out" then return end
   character:WaitForChild("Humanoid",10) character:WaitForChild("HumanoidRootPart",10)
   task.defer(function()
    while self.loading and self.loading[player] and player.Parent do task.wait() end
    if player.Parent then self:Configure(player,character) end
   end)
  end)
 end
 table.insert(self.connections,Players.PlayerAdded:Connect(added))
 table.insert(self.connections,Players.PlayerRemoving:Connect(function(player)
  self:Forget(player)
  if self.characters[player] then self.characters[player]:Disconnect() self.characters[player]=nil end
 end))
 for _,player in Players:GetPlayers() do added(player) end
 table.insert(self.connections,self.loadRemote.OnServerEvent:Connect(function(player,token)
  if token==0 then player:SetAttribute("GetOutClientReady",true) return end
  if self.phase=="loading" and token==self.serial and self.members[player] then self.loadAcks[player]=token end
 end))
 table.insert(self.connections,self.actionRemote.OnServerEvent:Connect(function(player,roundId,action,value)
  if not self.round or roundId~=self.round.id or typeof(action)~="string" then return end
  local now=workspace:GetServerTimeNow() local key=action=="CrawlMove" and "movement" or "action"
  local rates=self.actionRates[player] or {} self.actionRates[player]=rates
  if now-(rates[key] or 0)<.08 then return end rates[key]=now
  self.gameplay:Action(player,action,value)
 end))
 table.insert(self.connections,self.abilityRemote.OnServerEvent:Connect(function(player,roundId)
  if typeof(roundId)~="number" or not self.round or roundId~=self.round.id
   or player~=self.beast or self.context:GetMode(player)~="get_out"
   or self.phase~="playing" and self.phase~="enraged" then return end
  local now=workspace:GetServerTimeNow()
  if now<self.hackerReadyAt then return end
  local done=self.round:RollbackLastComputer()
  if not done then return end
  self.gameplay:Rollback()
  self.hackerReadyAt=now+P.HackerRollbackCooldownSeconds
  for id,marker in self.maps.manifest.routes.locks.computers do
   if not self.round.completedPCs[id] then
    marker.Color=Color3.fromRGB(73,130,177)
    local prompt=marker:FindFirstChild("GetOutPrompt") if prompt then prompt.Enabled=true end
   end
  end
  for _,lock in self.maps.manifest.routes.locks.locks do lock.Color=Color3.fromRGB(183,72,65) end
  for _,prompt in self.crankPrompts or {} do prompt.Enabled=false end
  self:Publish()
 end))
 local elapsed=0
 table.insert(self.connections,Run.Heartbeat:Connect(function(dt)
  elapsed+=dt if elapsed<.25 then return end local step=elapsed elapsed=0
  local now=workspace:GetServerTimeNow()
  if self.phase=="intermission" and now>=self.endsAt then task.spawn(function() if self.phase=="intermission" then self:StartRound() end end)
  elseif self.phase=="results" and now>=self.endsAt then self:BeginIntermission()
  elseif self.round and (self.phase=="playing" or self.phase=="enraged") then
   local prior=self.round.phase
   if self.round:Advance(now) then
    if self.round.phase=="results" then self:BeginResults()
    elseif prior~="enraged" and self.round.phase=="enraged" then
     self.phase="enraged"
     local _,h=rootOf(self.beast)
     local movement=self.gameplay.traversal.records[self.beast] if movement then movement.speed=P.EnragedWalkSpeed end
     if h then h.WalkSpeed=self.gameplay.dragged and T.DragWalkSpeed or P.EnragedWalkSpeed end
     if self.beast then self.beast:SetAttribute("GetOutUnstable",true) end
     for _,prompt in self.containmentPrompts or {} do prompt.Enabled=true end
     self.maps.manifest.routes.locks.chamber.Color=Color3.fromRGB(237,137,68)
     local light=self.maps.manifest.routes.locks.chamber:FindFirstChildOfClass("PointLight")
     if light then light.Enabled=true end
    end
   end
   self.gameplay:Tick(step)
  end
  self.publishElapsed=(self.publishElapsed or 0)+step
  if self.publishElapsed>=(next(self.gameplay.jobs) and .25 or 1) then self.publishElapsed=0 if count(self.members)>0 then self:Publish() end end
 end))
end

return Adapter
