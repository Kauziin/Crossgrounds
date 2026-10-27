local Damage={}
local Players=game:GetService("Players")
local Teams=game:GetService("Teams")
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Progress=require(game.ServerScriptService.Crossgrounds.ProgressionService)
local practice=setmetatable({},{__mode="k"})
local events=game.ReplicatedStorage.Events
local function remote(name)
 local r=events:FindFirstChild(name) or Instance.new("RemoteEvent")
 r.Name=name r.Parent=events return r
end
local feedback=remote("CombatFeedback")
local feed=remote("KillFeed")
local credits=setmetatable({},{__mode="k"})
local watched=setmetatable({},{__mode="k"})
function Damage:Team(model)
 if not model then return end
 local p=Players:GetPlayerFromCharacter(model)
 if p and p:GetAttribute("InArena") then return p.Team end
 if model:GetAttribute("CTFBot") then
  local team=model:GetAttribute("CTFTeam")
  if typeof(team)=="string" then return Teams:FindFirstChild(team) end
 end
end
function Damage:ShotRelation(attacker,model)
 if model==attacker then return "ignore" end
 local h=model:FindFirstChildOfClass("Humanoid") if h and h.Health<=0 then return "ignore" end
 local own=self:Team(attacker) local other=self:Team(model)
 if own and other==own then return "ignore" end
 if attacker:GetAttribute("AtLobby") and model:GetAttribute("PracticeDummy") then return "target" end
 return own and other and "target" or "block"
end
function Damage:ModelFromPart(part)
 local node=part
 while node and node~=workspace do
  if node:IsA("Model") and node:FindFirstChildOfClass("Humanoid") then return node end
  node=node.Parent
 end
end
local function name(model)
 local p=Players:GetPlayerFromCharacter(model)
 return p and p.DisplayName or (model:GetAttribute("BotAlias") or model.Name).." · IA"
end
function Damage:Watch(model)
 local h=model:FindFirstChildOfClass("Humanoid")
 if not h or watched[h] then return end
 local watch={connections={},stopped=false} watched[h]=watch
 local health=h.Health local hurt=os.clock()
 table.insert(watch.connections,h.HealthChanged:Connect(function(v) if v<health then hurt=os.clock() end health=v end))
 task.spawn(function() while not watch.stopped and model.Parent and h.Health>0 do task.wait(1) if not watch.stopped and model.Parent and h.Health>0 and os.clock()-hurt>8 then h.Health=math.min(h.MaxHealth,h.Health+4) end end end)
 table.insert(watch.connections,h.Died:Connect(function()
  local team=Damage:Team(model)
  if not team then return end
  local victimPlayer=Players:GetPlayerFromCharacter(model)
  if victimPlayer and victimPlayer:FindFirstChild("leaderstats") and victimPlayer.leaderstats:FindFirstChild("Deaths") then victimPlayer.leaderstats.Deaths.Value+=1 end
  local c=credits[h]
  local killer=c and os.clock()-c.time<=10 and c.model
  local killerTeam=killer and Damage:Team(killer)
  if killer and killerTeam and killerTeam~=team then
   local p=Players:GetPlayerFromCharacter(killer)
   local xp=p and Progress.CTFKill(p,model:GetAttribute("CTFBot")==true) or 0
   if p and p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Kills") then p.leaderstats.Kills.Value+=1 end
   local data=Kits.Weapons[c.weapon]
   feed:FireAllClients({killer=name(killer),victim=name(model),weapon=data and data.Name or c.weapon,killerTeam=killerTeam.Name,victimTeam=team.Name,headshot=c.headshot})
   if victimPlayer then feedback:FireClient(victimPlayer,{kind="Eliminated",character=model,killer=killer,killerName=name(killer),weapon=data and data.Name or c.weapon}) end
   if p then feedback:FireClient(p,{kind="Kill",victim=name(model),weapon=data and data.Name or c.weapon,xp=xp,headshot=c.headshot}) end
  else
   feed:FireAllClients({victim=name(model),victimTeam=team.Name,weapon="Eliminado"})
  end
  credits[h]=nil
 end))
end
function Damage:Practice(player,model,amount,weapon,headshot)
 if not model:GetAttribute("PracticeDummy") or not (amount>0 and amount<10000) then return false end
 local now=workspace:GetServerTimeNow()
 local record=practice[model] or {health=200,ready=0} practice[model]=record
 if now<record.ready then return false end
 record.health-=amount
 model:SetAttribute("PracticeMaxHealth",200) model:SetAttribute("PracticeHealth",math.max(0,record.health))
 local data=Kits.Weapons[weapon]
 if record.health<=0 then
  record.ready=now+3 record.health=200 model:SetAttribute("PracticeReadyAt",record.ready)
  local xp=Progress.Kill(player,"training",false)
  feedback:FireClient(player,{kind="Kill",victim="Alvo de treino",weapon=data and data.Name or weapon,xp=xp,training=true,headshot=headshot})
  task.delay(3,function() if model.Parent and practice[model]==record then model:SetAttribute("PracticeHealth",200) model:SetAttribute("PracticeReadyAt",0) end end)
 else feedback:FireClient(player,{kind="Hit",damage=math.floor(amount+.5),headshot=headshot}) end
 return true
end
function Damage:Unwatch(model)
 local h=model and model:FindFirstChildOfClass("Humanoid") local watch=h and watched[h]
 if watch then watch.stopped=true for _,c in watch.connections do c:Disconnect() end watched[h]=nil end
 if h then credits[h]=nil end
end
function Damage:BreakProtection(model)
 if not model then return end
 model:SetAttribute("SpawnProtectedUntil",0)
 local shield=model:FindFirstChild("SpawnShield")
 if shield then shield:Destroy() end
end
function Damage:Deal(attacker,victim,amount,weapon,headshot)
 if not attacker or not attacker.Parent or not victim or victim.Health<=0 or not (amount>0 and amount<10000) then return false end
 local a=attacker:FindFirstChildOfClass("Humanoid")
 local target=victim.Parent
 if not a or a.Health<=0 or not target or self:Team(attacker)==nil or self:Team(target)==nil or self:Team(attacker)==self:Team(target) then return false end
 if (target:GetAttribute("SpawnProtectedUntil") or 0)>workspace:GetServerTimeNow() then return false end
 self:Watch(target)
 credits[victim]={model=attacker,time=os.clock(),weapon=weapon,headshot=headshot}
 local actual=math.min(amount,victim.Health)
 victim:TakeDamage(amount)
 local player=Players:GetPlayerFromCharacter(attacker)
 if player then
  local root=target:FindFirstChild("HumanoidRootPart")
  feedback:FireClient(player,{kind="Hit",damage=math.floor(actual+.5),headshot=headshot,position=root and root.Position})
 end
 return true
end
return Damage