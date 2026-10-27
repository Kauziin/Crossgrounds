local Service = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Balance = require(script.Parent.ProgressionBalance)
local Policy = require(script.Parent.ProgressionPolicy)
local store = not RunService:IsStudio() and game:GetService("DataStoreService"):GetDataStore("CrossgroundsProgression_v1") or nil
local fields = {"XP","Coins","Kills","Deaths","Captures","PlaySeconds","BotKills","TrainingKills"}
local savedFriends={}
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
local function award(player, amounts)
 local record = state[player]
 if not record then return end
 for key, value in pairs(amounts) do
  if record.pending[key] and type(value) == "number" and value > 0 then
   record.pending[key] += math.floor(value)
  end
 end
 publish(player, record)
end
function Service.Kill(player,kind,headshot)
 local amounts=Policy.Reward(kind,headshot)
 award(player,amounts)
 return amounts.XP
end
function Service.ArenaDeath(player) award(player,{Deaths=1}) end
function Service.ArenaKill(player,headshot) return Service.Kill(player,"arena",headshot) end
function Service.CTFKill(player,isBot) return Service.Kill(player,isBot and "bot" or "ctf",false) end
local function save(player)
 local record = state[player]
 if not record or not record.loaded or record.saving or RunService:IsStudio() or player.UserId <= 0 then return end
 local delta = {}
 local dirty = false
 for _, key in fields do delta[key] = record.pending[key] if delta[key] > 0 then dirty = true end end
 if not dirty and record.visitSaved then return end
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
    award(player, amounts)
   end))
  end
 end
end
local function added(player)
 if state[player] then return end
 local record = {base = blank(), pending = blank(), loaded = false, saving = false, watched = {}, connections = {}}
 state[player] = record
 publish(player, record)
 table.insert(record.connections, player.ChildAdded:Connect(function(child)
  if child.Name == "leaderstats" then watchStats(player, record, child) end
 end))
 watchStats(player, record, player:FindFirstChild("leaderstats"))
 task.spawn(function()
  if not RunService:IsStudio() and player.UserId > 0 then
   local ok, data = pcall(function() return store:GetAsync("u" .. player.UserId) end)
   if ok then record.base = clean(data) record.visitSaved=Policy.HasPlayed(data) else warn("Crossgrounds progression load: " .. tostring(data)) end
  end
  if state[player] == record then record.loaded = true publish(player, record) end
 end)
end
local function friends(player)
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
 if state[player] then row(player.UserId,player.DisplayName,live(state[player]),true) end
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
  if online and state[online] then return live(state[online]) end
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
 local message
 if not ok then message="Lista de amigos indisponível no momento."
 elseif RunService:IsStudio() then message="Studio: somente amigos presentes nesta sessão. Dados offline exigem servidor publicado."
 elseif #candidates>=60 then message="Até 8 amigos com histórico, entre os 60 contatos consultados." end
 return rows,message
end
function Service:Start()
 if self.started then return end
 self.started = true
 local remotes = game.ReplicatedStorage.Crossgrounds.Remotes
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
  save(player)
  local record = state[player]
  if record then for _, connection in ipairs(record.connections) do connection:Disconnect() end end
  state[player] = nil friendRate[player] = nil
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
   task.wait(60)
   for _, player in Players:GetPlayers() do
    award(player, {PlaySeconds = 60})
    save(player)
   end
  end
 end)
 game:BindToClose(function()
  for _, player in Players:GetPlayers() do save(player) end
 end)
end
return Service
