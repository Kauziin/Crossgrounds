local Service={}
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local P=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
local Cosmetics=require(game.ReplicatedStorage.Crossgrounds.IdentityCatalog)
local Repository=require(script.Parent.CareerRepository)
local records={} local rates={}
local changed=Instance.new("BindableEvent") Service.Changed=changed.Event
local committed=Instance.new("BindableEvent")Service.Committed=committed.Event
function Service.Enabled() return Run:IsStudio() or game.ServerStorage:GetAttribute("CareerCutoverApproved")==true end
local function memory()
 local data={} local store={}
 function store:GetAsync(k) return P.Copy(data[k]) end
 function store:UpdateAsync(k,fn) local v=fn(P.Copy(data[k])) if v then data[k]=P.Copy(v) end return P.Copy(v) end
 return store
end
local repo
local function repository()
 if not repo then
  local dss=game:GetService("DataStoreService")
  repo=Repository.new(Run:IsStudio() and memory() or dss:GetDataStore("CrossgroundsCareer_v2"),Run:IsStudio() and memory() or dss:GetDataStore("CrossgroundsProgression_v1"),game.JobId..Http:GenerateGUID(false))
 end
 return repo
end
local function publish(player,r)
 if not player.Parent then return end
 local p=r.profile
 player:SetAttribute("CareerReady",p~=nil and not r.error)
 player:SetAttribute("CareerSaveState",r.error or (Run:IsStudio() and "StudioSessionOnly" or r.pending and "RetryPending" or "Saved"))
 if not p then return end
 player:SetAttribute("CareerPhase",p.phase) player:SetAttribute("CareerPrestige",p.prestige)
 player:SetAttribute("CareerLevel",P.Level(p.cycleXP,p.phase)) player:SetAttribute("CareerCycleXP",p.cycleXP)
 player:SetAttribute("CareerIdentity",Http:JSONEncode(P.Public(p,player.UserId,player.DisplayName)))
 changed:Fire(player)
end
local function applyAwards(r)
 for _,a in r.queue do
  if a.mutate then local nextProfile=P.Copy(r.profile)local ok,accepted=pcall(a.mutate,nextProfile)if ok and accepted then r.profile=nextProfile elseif not ok then warn("Career staged mutation: "..tostring(accepted))end
  else P.Award(r.profile,a.amounts,a.mode,a.weapon,a.weaponXP)end
 end
 Cosmetics.Grant(r.profile)
 table.clear(r.queue)
end
function Service.Stage(player,fn)
 local r=records[player]if not r or not r.profile or r.error then return false end
 if r.saving or r.pending then table.insert(r.queue,{mutate=fn})return true end
 local candidate=P.Copy(r.profile)local ok,accepted=pcall(fn,candidate)
 if not ok or not accepted then return false end
 r.profile=candidate publish(player,r)return true
end
function Service.Open(player)
 if not Service.Enabled() then return nil,"Migração publicada ainda não ativada." end
 local r=records[player]
 if r and r.error=="Perfil ativo em outro servidor."and not r.profile then records[player]=nil r=nil end
 if r then return r.profile,r.error end
 r={queue={},saving=false,pending=false} records[player]=r
 local p,err=repository():Open(player.UserId)
 if not player.Parent then if p then repository():Close(player.UserId) end records[player]=nil return nil,"Jogador saiu." end
 if p then Cosmetics.Grant(p) end
 r.profile=p r.error=err publish(player,r) return p,err
end
function Service.Get(player) local r=records[player] return r and r.profile end
function Service.Stats(profile)
 local data=P.Copy(profile.stats)
 data.HasPlayed=true data.CareerLevel=P.Level(profile.cycleXP,profile.phase)
 data.CareerCycleXP=profile.cycleXP data.CareerPhase=profile.phase data.CareerPrestige=profile.prestige
 return data
end
function Service.ReadStats(id)
 local online=Players:GetPlayerByUserId(id) local p=online and Service.Get(online)
 if p then return Service.Stats(p) end
 if Run:IsStudio() then return nil end
 local r=repository()
 local ok,envelope=pcall(function() return r.store:GetAsync("u"..id) end)
 if not ok then return nil end
 if envelope then p=P.Migrate(envelope.profile)
 else
  local read,legacy=pcall(function() return r.legacy:GetAsync("u"..id) end)
  if read and require(script.Parent.ProgressionPolicy).HasPlayed(legacy) then p=P.Migrate(legacy) end
 end
 return p and Service.Stats(p)
end
function Service.Award(player,amounts,mode,weapon,weaponXP)
 local r=records[player] if not r or not r.profile or r.error then return false end
 if r.saving or r.pending then table.insert(r.queue,{amounts=P.Copy(amounts),mode=mode,weapon=weapon,weaponXP=weaponXP})
 else P.Award(r.profile,amounts,mode,weapon,weaponXP) Cosmetics.Grant(r.profile) end
 publish(player,r) return true
end
function Service.Flush(player)
 local r=records[player] if not r or not r.profile or r.error then return false,"Perfil indisponível." end
 if r.saving then return false,"Gravação em andamento." end
 r.saving=true
 local ok,result=repository():Commit(player.UserId,r.profile)
 r.saving=false r.pending=not ok
 if ok then r.profile=P.Copy(result) r.dirty=#r.queue>0 applyAwards(r) end
 publish(player,r)
 if ok then committed:Fire(player,P.Copy(result))end
 return ok,result
end
function Service.Mutate(player,fn)
 local r=records[player]
 if not r or not r.profile or r.error or r.saving or r.pending then return false,"Aguarde a confirmação do perfil." end
 local candidate=P.Copy(r.profile)
 local ok,why=fn(candidate) if not ok then return false,why end
 Cosmetics.Grant(candidate)
 r.profile=candidate
 local saved,err=Service.Flush(player)
 return saved,saved and "Alteração confirmada." or "Confirmação pendente; não repita a operação."
end
function Service.Public(player)
 local p=Service.Get(player) return p and P.Public(p,player.UserId,player.DisplayName)
end
function Service.ReadPublic(id,name)
 local online=Players:GetPlayerByUserId(id) local p=online and Service.Get(online)
 if not p then
  if not Service.Enabled() or Run:IsStudio() then return nil end
  local r=repository() local ok,envelope=pcall(function()return r.store:GetAsync("u"..id)end)
  if not ok or not envelope or type(envelope.profile)~="table" then return nil end
  p=P.Migrate(envelope.profile)
 end
 if not p then return nil end
 local public=P.Public(p,id,online and online.DisplayName or name or "Jogador")
 if not p.social or p.social.publicStats~=false then
  public.stats={}
  for _,key in {"XP","Kills","Deaths","Captures","Wins","PlaySeconds","BotKills","TrainingKills"}do public.stats[key]=P.Number(p.stats[key])end
 end
 return public
end
function Service.Close(player)
 local r=records[player]
 if r and r.profile then
  for _=1,3 do local ok=Service.Flush(player) if ok and not r.dirty then break end task.wait(.1) end
  if r.pending or r.saving or r.dirty then return false end
  if not repository():Close(player.UserId) then return false end
 end
 records[player]=nil rates[player]=nil return true
end
function Service.Start()
 if Service.started then return end Service.started=true
 local remotes=game.ReplicatedStorage.Crossgrounds:WaitForChild("Remotes")
 local command=remotes:FindFirstChild("CareerCommand") or Instance.new("RemoteFunction") command.Name="CareerCommand" command.Parent=remotes
 command.OnServerInvoke=function(player,action,payload)
  local now=os.clock() local bucket=(action=="get" or action=="public") and "read" or "write"
  local budget=rates[player] or {} rates[player]=budget
  if now-(budget[bucket] or -10)<(bucket=="read" and .1 or .25) then return false,"Aguarde um instante." end budget[bucket]=now
  if not Service.Enabled() then return false,"Migração publicada ainda não ativada." end
  local p=Service.Get(player) if not p then return false,"Perfil não carregado." end
  if action=="get" then return true,P.Copy(p) end
  if action=="public" then
   local target=type(payload)=="number" and Players:GetPlayerByUserId(payload)
   return target~=nil,target and Service.Public(target) or "Jogador indisponível."
  end
  if player:GetAttribute("CrossgroundsMode")~="hub" or player:GetAttribute("CrossgroundsTransition") or player:GetAttribute("InMatch") or player:GetAttribute("InArena") then return false,"Volte ao lobby para alterar sua carreira." end
  if action=="finish"and type(payload)=="table"then
   local weapon=payload.weapon local mode=payload.mode
   local kits=require(game.ReplicatedStorage.KitDefinitions)local finishes=require(game.ReplicatedStorage.Crossgrounds.WeaponFinishCatalog)
   if not table.find({"arena","ctf"},mode)or type(weapon)~="string"or not kits.Weapons[weapon]or kits.Weapons[weapon].Kind~="Gun"or not finishes.Items[payload.id]then return false,"Acabamento ou arma inválido."end
   if not require(game.ReplicatedStorage.Crossgrounds.UnlockCatalog).FinishWeapon(mode,weapon)then return false,"Arma indisponível nessa modalidade."end
   return Service.Mutate(player,function(nextProfile)
    if not finishes.Allows(nextProfile,weapon,payload.id,mode,P.WeaponLevel(nextProfile.weapons[weapon]))then return false,"Requer arma nível "..finishes.Items[payload.id].level end
    nextProfile.weaponFinishes=nextProfile.weaponFinishes or{}nextProfile.weaponFinishes[weapon]=payload.id return true
   end)
  end
  if action=="frameLayers"then return Service.Mutate(player,function(profile)return require(game.ReplicatedStorage.Crossgrounds.ProfileFramePolicy).Set(profile,payload)end)end
  if action=="rankStyle"then return Service.Mutate(player,function(profile)return P.SetRankStyle(profile,payload)end)end
  if action=="prestige" then
   if payload~=p.transitions then return false,"Prévia expirada. Atualize o perfil." end
   return Service.Mutate(player,P.Transition)
  end
  if action=="identity" and type(payload)=="table" then return Service.Mutate(player,function(nextProfile) return P.EquipIdentity(nextProfile,payload.slot,payload.id) end) end
  if action=="unlock" and type(payload)=="table" and type(payload.mode)=="string" and type(payload.item)=="string" then
   if not require(game.ReplicatedStorage.Crossgrounds.UnlockCatalog).Get(payload.mode,payload.item) then return false,"Item indisponível para token." end
   return Service.Mutate(player,function(nextProfile) return P.Unlock(nextProfile,payload.mode,payload.item) end)
  end
  return false,"Comando inválido."
 end
 task.spawn(function()
  while true do task.wait(45) for player,r in records do
   if r.profile and not r.saving then if player.Parent then Service.Flush(player) else Service.Close(player) end end
  end end
 end)
 game:BindToClose(function()
  local count=0
  for player in records do count+=1 task.spawn(function() Service.Close(player) count-=1 end) end
  local deadline=os.clock()+20 while count>0 and os.clock()<deadline do task.wait(.1) end
 end)
end
return Service
