local PlayerManager={}
local Players=game:GetService("Players") Players.CharacterAutoLoads=false
local Context=require(game.ServerScriptService.Crossgrounds.PlayerContext)
local Damage=require(script.Parent.DamageService)
local Config=require(game.ServerStorage.Configurations)
local Events=game.ReplicatedStorage.Events
local function remote(name) local r=Events:FindFirstChild(name) or Instance.new("RemoteEvent") r.Name=name r.Parent=Events return r end
local join=remote("JoinMatch") local result=remote("JoinMatchResult") local leave=remote("LeaveMatch") local preview=remote("PreviewKit")
local TeamManager=require(script.Parent.TeamManager)
local Kit=require(script.Parent.KitService)
local Movement=require(script.Parent.MovementService)
local Spawn=require(script.Parent.SpawnService)
local Flags=require(script.Parent.FlagService)
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local running=false local loading={} local lastRequest={} local lastPreview={}
local function configure(player,character)
 if player.Character~=character or not character.Parent then return end
 if Context:GetMode(player)=="arena" or Context:GetMode(player)=="get_out" then return end
 if not Context:IsCTF(player) then
  Flags:DropCarrier(character) Damage:Unwatch(character) Movement:Reset(player)
  for _,container in {player.Backpack,player.StarterGear,character} do for _,tool in container:GetChildren() do if tool:IsA("Tool") and Kits.Weapons[tool:GetAttribute("WeaponId")] then tool:Destroy() end end end
  Context:ApplyHubCharacter(player,character) return
 end
 local hubShield=character:FindFirstChild("HubProtection") if hubShield then hubShield:Destroy() end
 local inArena=running and player:GetAttribute("InMatch")==true
 player:SetAttribute("InArena",inArena)
 character:SetAttribute("AtLobby",not inArena)
 require(game.ServerScriptService.Crossgrounds.LoadoutService).ApplyPending(player,"ctf")
 Kit:ApplyToCharacter(player,character)
 Movement:ApplyToCharacter(player)
 if inArena and player.Team then Spawn:Place(character,player.Team) else Spawn:Lobby(character) end
 player:SetAttribute("RespawnAt",0)
 Context:MarkReady(player)
end
local function load(player)
 if loading[player] or not player.Parent then return end
 loading[player]=true
 player:SetAttribute("ModeCharacterReady",false)
 local ok,err=pcall(function() player:LoadCharacterAsync() end)
 loading[player]=nil
 if not ok then warn("Character load: "..tostring(err)) end
end
function PlayerManager:Spawn(player)
 player:SetAttribute("ModeCharacterReady",false)
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 if c and c.Parent and h and h.Health>0 then configure(player,c) else task.spawn(load,player) end
end
local function added(player)
 local stats=Instance.new("Folder") stats.Name="leaderstats" stats.Parent=player
 for _,name in {"Captures","Kills","Deaths"} do local s=Instance.new("IntValue") s.Name=name s.Parent=stats end
 player:SetAttribute("InMatch",false) player:SetAttribute("InArena",false) player:SetAttribute("SelectedKit","Regular")
 player.Neutral=true
 player.CharacterAdded:Connect(function(c)
  local h=c:WaitForChild("Humanoid") c:WaitForChild("HumanoidRootPart")
  local function disableDefaultRegen(v) if v.Name=="Health" and v:IsA("BaseScript") then v.Enabled=false end end
  for _,v in c:GetChildren() do disableDefaultRegen(v) end c.ChildAdded:Connect(disableDefaultRegen)
  if not c.Parent then c.AncestryChanged:Wait() end
  task.defer(configure,player,c)
  h.Died:Connect(function()
   if Context:GetMode(player)=="arena" or Context:GetMode(player)=="get_out" then return end
   Flags:DropCarrier(c)
   local delay=player:GetAttribute("InArena") and Config.RESPAWN_TIME or 2
   player:SetAttribute("RespawnAt",workspace:GetServerTimeNow()+delay)
   task.delay(delay,function() if player.Parent and player.Character==c then load(player) end end)
  end)
 end)
 task.spawn(load,player)
end
join.OnServerEvent:Connect(function(player,id)
 if not Context:IsCTF(player) or player:GetAttribute("CrossgroundsTransition") or player:GetAttribute("ModeCharacterReady")==false then result:FireClient(player,false,"Entre na preparação do CTF e aguarde o personagem.") return end
 if typeof(id)~="string" or not Kits.Profiles[id] then result:FireClient(player,false,"Escolha um kit válido.") return end
 if player:GetAttribute("InArena") or loading[player] then return end
 if os.clock()-(lastRequest[player] or -10)<.4 then return end
 lastRequest[player]=os.clock()
 if not player:GetAttribute("InMatch") and not TeamManager:AssignPlayerToTeam(player) then result:FireClient(player,false,"Equipes cheias. Explore o lobby enquanto aguarda.") return end
 player:SetAttribute("SelectedKit",Kits.Profiles[id] and id or "Regular")
 if running then
  local maps=require(script.Parent.MapManager)local mapId=workspace:GetAttribute("CurrentMapId")
  loading[player]=true player:SetAttribute("ModeCharacterReady",false)
  local ready,message=require(game.ServerScriptService.Crossgrounds.SceneLoadService):Wait({player},maps:SceneRoots(),maps:SceneAnchors(),function()return player.Parent and Context:IsCTF(player)and running and workspace:GetAttribute("CurrentMapId")==mapId end,.3,true)
  loading[player]=nil
  if not ready then
   if player.Parent and Context:IsCTF(player)then TeamManager:RemovePlayer(player)PlayerManager:Spawn(player)result:FireClient(player,false,message or"A rodada mudou. Tente entrar novamente.")end
   return
  end
 end
 player:SetAttribute("InMatch",true)
 PlayerManager:Spawn(player)
 result:FireClient(player,true,running and "Boa partida!" or "Pronto! A rodada começa em instantes.")
end)
preview.OnServerEvent:Connect(function(player,id)
 if not Context:IsCTF(player) or player:GetAttribute("CrossgroundsTransition") or typeof(id)~="string" then return end
 if player:GetAttribute("InArena") or not Kits.Profiles[id] or os.clock()-(lastPreview[player] or -10)<.35 then return end
 lastPreview[player]=os.clock() player:SetAttribute("SelectedKit",id)
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 if c and h and h.Health>0 then Kit:ApplyToCharacter(player,c) Movement:ApplyToCharacter(player) end
end)
function PlayerManager:LeaveMatch(player)
 if player.Character then Flags:DropCarrier(player.Character) end
 player:SetAttribute("InMatch",false) player:SetAttribute("InArena",false)
 TeamManager:RemovePlayer(player) player.Neutral=true player.Team=nil Movement:Reset(player)
end
leave.OnServerEvent:Connect(function(player)
 if not Context:IsCTF(player) or player:GetAttribute("CrossgroundsTransition") or not player:GetAttribute("InMatch") then return end
 PlayerManager:LeaveMatch(player) PlayerManager:Spawn(player)
end)
function PlayerManager:SetGameRunning(value) running=value end
function PlayerManager:LoadPlayers() for _,p in Players:GetPlayers() do if p:GetAttribute("InMatch") then self:Spawn(p) end end end
function PlayerManager:SendToLobby() for _,p in Players:GetPlayers() do if Context:IsCTF(p) then self:Spawn(p) end end end
function PlayerManager:GetJoinedCount() local n=0 for _,p in Players:GetPlayers() do if p:GetAttribute("InMatch") then n+=1 end end return n end
function PlayerManager:AllowPlayerSpawn() end
function PlayerManager:DestroyPlayers() self:SendToLobby() end
function PlayerManager:ClearPlayerScores()
 for _,p in Players:GetPlayers() do local s=p:FindFirstChild("leaderstats") if s then for _,v in s:GetChildren() do if v:IsA("IntValue") then v.Value=0 end end end end
end
function PlayerManager:AddPlayerScore(p,n) if p and p:FindFirstChild("leaderstats") then p.leaderstats.Captures.Value+=n end end
Players.PlayerAdded:Connect(added)
Players.PlayerRemoving:Connect(function(p) if p.Character then Flags:DropCarrier(p.Character) Damage:Unwatch(p.Character) end TeamManager:RemovePlayer(p) Movement:Reset(p) loading[p]=nil lastRequest[p]=nil lastPreview[p]=nil end)
for _,p in Players:GetPlayers() do task.spawn(added,p) end
return PlayerManager
