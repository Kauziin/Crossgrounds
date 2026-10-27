local Service = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Balance = require(script.Parent.ProgressionBalance)
local Policy = require(script.Parent.ProgressionPolicy)
local store = not RunService:IsStudio() and game:GetService("DataStoreService"):GetDataStore("CrossgroundsProgression_v1") or nil
local fields = {"XP","Coins","Kills","Deaths","Captures","PlaySeconds","BotKills","TrainingKills"}
local Schema=require(game.ReplicatedStorage.Crossgrounds.ProgressionSchema)
for _,key in Schema.Fields do if not table.find(fields,key) then table.insert(fields,key) end end
for _,mode in Schema.Modes do if mode~="general" then for _,key in Schema.Fields do table.insert(fields,Schema.Key(mode,key)) end end end
local Ranking=require(script.Parent.ProgressionRanking)
local savedFriends={}
local friendResults={}
local state = {}
local friendRate = {}
local function blank()
 local result = {}
 for _, key in fields do result[key] = 0 end
 return result
end
local function clean(source)
 local result = blank()
 if type(source) == "table" then
  for _, key in fields do
   local value = source[key]
   if type(value) == "number" and value == value and value >= 0 then result[key] = math.floor(math.min(value, 2^50)) end
  end
 end
 return result
end
local function level(xp)
 return math.floor((xp / 250) ^ (1 / 1.45)) + 1
end
local function publish(player, record)
 if not player.Parent then return end
 for _, key in fields do player:SetAttribute("Progress"..key, record.base[key] + record.pending[key]) end
 player:SetAttribute("ProgressLevel", level(record.base.XP + record.pending.XP))
 player:SetAttribute("ProgressionReady", record.loaded)
end
local function award(player, amounts, mode)
 local record = state[player]
 if not record then return end
 for key, value in pairs(amounts) do
  if record.pending[key] and type(value) == "number" and value > 0 then
   record.pending[key] += math.floor(value)
   local modeKey=mode and Schema.Key(mode,key)
   if modeKey and mode~="general" and record.pending[modeKey] then record.pending[modeKey]+=math.floor(value) end
  end
 end
 publish(player, record)
end
local function tick(player)
 local record=state[player] if not record then return end
 local time=os.clock() local elapsed=math.max(0,math.floor(time-record.lastTick))
 record.lastTick+=elapsed
 if elapsed>0 then award(player,{PlaySeconds=elapsed},record.mode) end
 record.mode=player:GetAttribute("CrossgroundsMode")
end
function Service.Kill(player,kind,headshot)
 local amounts=Policy.Reward(kind,headshot)
 award(player,amounts,kind=="arena" and "arena" or (kind=="ctf" or kind=="bot") and "ctf" or nil)
 return amounts.XP
end
function Service.ArenaDeath(player) award(player,{Deaths=1},"arena") end
function Service.ArenaKill(player,headshot) return Service.Kill(player,"arena",headshot) end
function Service.CTFKill(player,isBot) return Service.Kill(player,isBot and "bot" or "ctf",false) end
local function save(player)
 local record = state[player]
 if not record or not record.loaded or record.saving or RunService:IsStudio() or player.UserId <= 0 then return end
 local delta = {}
 local dirty = false
 for _, key in fields do delta[key] = record.pending[key] if delta[key] > 0 then dirty = true end end
 if not dirty and record.visitSaved then Ranking.Index(player.UserId,record.base) return end
 record.saving = true
 local ok, saved = pcall(function()
  return store:UpdateAsync("u" .. player.UserId, function(previous)
   local merged = clean(previous)
   for _, key in fields do merged[key] += delta[key] end
   merged.HasPlayed=true
   return merged
  end)
 end)
 if ok then
  record.visitSaved=true
  record.base = clean(saved)
  for _, key in fields do record.pending[key] = math.max(0, record.pending[key] - delta[key]) end
  publish(player, record)
  Ranking.Index(player.UserId,record.base)
 else
  warn("Crossgrounds progression save: " .. tostring(saved))
 end
 record.saving = false
end
local function watchStats(player, record, folder)
 if not folder or not folder:IsA("Folder") or record.watched[folder] then return end
 record.watched[folder] = true
 local map = {
  Deaths = {Deaths = 1},
  Captures = {XP = "CTFCaptureXP", Coins = "CTFCaptureCoins", Captures = 1},
 }
 for name, rule in pairs(map) do
  local value = folder:FindFirstChild(name)
  if value and value:IsA("IntValue") then
   local previous = value.Value
   table.insert(record.connections, value.Changed:Connect(function(newValue)
    local gained = math.max(0, newValue - previous)
    previous = newValue
    if gained == 0 or player:GetAttribute("CrossgroundsMode") ~= "ctf" then return end
    local amounts = {}
    for key, amount in pairs(rule) do
     amounts[key] = type(amount) == "string" and Balance.Get(amount) * gained or amount * gained
    end
    award(player, amounts,"ctf")
   end))
  end
 end
end
local function added(player)
 if state[player] then return end
 local record = {lastTick=os.clock(),lastSave=os.clock(),mode=player:GetAttribute("CrossgroundsMode"),base = blank(), pending = blank(), loaded = false, saving = false, watched = {}, connections = {}}
 state[player] = record
 table.insert(record.connections,player:GetAttributeChangedSignal("CrossgroundsMode"):Connect(function() tick(player) end))
 publish(player, record)
 table.insert(record.connections, player.ChildAdded:Connect(function(child)
  if child.Name == "leaderstats" then watchStats(player, record, child) end
 end))
 watchStats(player, record, player:FindFirstChild("leaderstats"))
 task.spawn(function()
  if not RunService:IsStudio() and player.UserId > 0 then
   local ok, data = pcall(function() return store:GetAsync("u" .. player.UserId) end)
   if ok then record.base = clean(data) record.visitSaved=Policy.HasPlayed(data)
   else
    warn("Crossgrounds progression load: " .. tostring(data))
    player:SetAttribute("ProgressionLoadError",true)
    return -- Never overwrite an unread profile with a blank record.
   end
  end
  if state[player] == record then record.loaded = true publish(player, record) Ranking.Index(player.UserId,record.base) end
 end)
end
function Service.Snapshot(player)
 local record=state[player] if not record then return nil end
 local data={userId=player.UserId,name=player.DisplayName,ready=record.loaded}
 for _,key in fields do data[key]=record.base[key]+record.pending[key] end
 data.Level=level(data.XP) return data
end
function Service.Result(player,mode,won,extra)
 if not Schema.Primary[mode] then return end
 local amounts=table.clone(extra or {})
 amounts[won and "Wins" or "Losses"]=1
 award(player,amounts,mode)
end
function Service.GetOutResult(round)
 if not round or round.progressRecorded then return end
 round.progressRecorded=true
 if round.ending and round.ending:find("technical",1,true) then return end
 local escaped=0
 for p,result in round.status do
  local won=result=="escaped" or result=="beast_contained"
  if won then escaped+=1 end
  if result~="disconnected" then Service.Result(p,"get_out",won,won and {SurvivorWins=1,Escapes=result=="escaped" and 1 or 0} or nil) end
 end
 if round.beast and round.beast.Parent then Service.Result(round.beast,"get_out",escaped==0,escaped==0 and {BeastWins=1} or nil) end
end
local function friends(player)
 local cached=friendResults[player]
 if cached and os.clock()-cached.at<120 then return cached.rows,cached.message end
 local rows={}
 local function row(userId,name,data,isSelf)
  data=clean(data)
  data.userId=userId data.name=name data.self=isSelf==true data.Level=level(data.XP)
  table.insert(rows,data)
 end
 local function live(record)
  local data={HasPlayed=true}
  for _,key in fields do data[key]=record.base[key]+record.pending[key] end
  return data
 end
 if state[player] and state[player].loaded then row(player.UserId,player.DisplayName,live(state[player]),true) end
 local ok,pages=pcall(function() return Players:GetFriendsAsync(player.UserId) end)
 local candidates={}
 if ok then
  repeat
   for _,friend in pages:GetCurrentPage() do
    table.insert(candidates,friend) if #candidates>=60 then break end
   end
   if #candidates>=60 or pages.IsFinished then break end
   local advanced=pcall(function() pages:AdvanceToNextPageAsync() end)
   if not advanced then break end
  until false
 end
 local function resolve(id)
  local online=Players:GetPlayerByUserId(id)
  if online and state[online] and state[online].loaded then return live(state[online]) end
  if RunService:IsStudio() then return nil end
  local cached=savedFriends[id]
  if cached and os.clock()-cached.at<120 then return cached.data end
  local read,saved=pcall(function() return store:GetAsync("u"..id) end)
  if not read then return nil end
  local data=Policy.HasPlayed(saved) and saved or nil
  savedFriends[id]={at=os.clock(),data=data}
  return data
 end
 for _,match in Policy.CollectFriends(candidates,resolve,8) do
  row(match.friend.Id,match.friend.DisplayName or match.friend.Username,match.data,false)
 end
 table.sort(rows,function(a,b) if a.XP~=b.XP then return a.XP>b.XP end return a.userId<b.userId end)
 local message="Até 8 amigos com histórico, entre os 60 contatos consultados."
 if not ok then message="Lista de amigos indisponível no momento."
 elseif RunService:IsStudio() then message="Studio: somente amigos presentes nesta sessão. Dados offline exigem servidor publicado."
 elseif #candidates>=60 then message="Até 8 amigos com histórico, entre os 60 contatos consultados." end
 friendResults[player]={at=os.clock(),rows=rows,message=message}
 return rows,message
end
function Service:Start()
 if self.started then return end
 self.started = true
 local remotes = game.ReplicatedStorage.Crossgrounds.Remotes
 Ranking.Start(Service.Snapshot,friends)
 local profile=remotes:FindFirstChild("GetProgressProfile") or Instance.new("RemoteFunction")
 profile.Name="GetProgressProfile" profile.Parent=remotes
 profile.OnServerInvoke=function(player) return Service.Snapshot(player) end
 local compare = remotes:FindFirstChild("GetFriendProgress") or Instance.new("RemoteFunction")
 compare.Name = "GetFriendProgress"
 compare.Parent = remotes
 compare.OnServerInvoke = function(player)
  local now = os.clock()
  if now - (friendRate[player] or -100) < 20 then return nil, "Aguarde para atualizar o comparativo." end
  friendRate[player] = now
  return friends(player)
 end
 Players.PlayerAdded:Connect(added)
 Players.PlayerRemoving:Connect(function(player)
  tick(player) save(player)
  local record = state[player]
  if record then for _, connection in ipairs(record.connections) do connection:Disconnect() end end
  state[player] = nil friendRate[player] = nil friendResults[player]=nil
 end)
 for _, player in Players:GetPlayers() do added(player) end
 task.spawn(function()
  while true do
   task.wait(2)
   local hub = workspace:FindFirstChild("CrossgroundsPrototype")
   local zone = hub and hub:FindFirstChild("AFKZone")
   for _, player in Players:GetPlayers() do
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local inside = false
    if zone and root and player:GetAttribute("CrossgroundsMode") == "hub" then
     local p = zone.CFrame:PointToObjectSpace(root.Position)
     inside = math.abs(p.X) <= zone.Size.X/2 and math.abs(p.Y) <= zone.Size.Y/2 and math.abs(p.Z) <= zone.Size.Z/2
    end
    if player:GetAttribute("IsAFK") ~= inside then player:SetAttribute("IsAFK", inside) end
   end
  end
 end)
 task.spawn(function()
  while true do
   task.wait(10)
   for _, player in Players:GetPlayers() do
    tick(player)
    local record=state[player]
    if record and os.clock()-record.lastSave>=60 then record.lastSave=os.clock() save(player) end
   end
  end
 end)
 game:BindToClose(function()
  for _, player in Players:GetPlayers() do tick(player) save(player) end
 end)
end
return Service
