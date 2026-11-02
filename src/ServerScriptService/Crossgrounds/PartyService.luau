local Party={}
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Balance=require(script.Parent.ProgressionBalance)
local Roster=require(script.Parent.PartyRoster)
local XP=require(script.Parent.PartyXPPolicy)
local changed=Instance.new("BindableEvent") Party.Changed=changed.Event
local stateRemote,command,rates,removing=nil,nil,{},nil
local eligible=function()return false end
local fractions={}
local appearances={}
local function emit(ids)
 for _,id in ids do local p=Players:GetPlayerByUserId(id) if p and stateRemote then
  stateRemote:FireClient(p,Party.Snapshot(p))
  if Party.BonusMembers then p:SetAttribute("PartyXPBonusPercent",Party.BonusMembers(p,p:GetAttribute("CrossgroundsMode"))*math.clamp(Balance.Get("PartyMemberXPPercent"),0,100)) end
 end end
 changed:Fire(ids)
end
local roster=Roster.new({id=function()return Http:GenerateGUID(false)end,inviteSeconds=function()return Balance.Get("PartyInviteSeconds")end,changed=emit})
Party.Roster=roster
function Party.Get(player) return roster:Get(player.UserId) end
function Party.Members(group)
 local members={} for _,id in group.members do local p=Players:GetPlayerByUserId(id) if p then table.insert(members,p) end end return members
end
function Party.Snapshot(player)
 local result=roster:Snapshot(player.UserId)
 local ids=result.group and result.group.members or {}
 local rows={}
 for _,id in ids do local p=Players:GetPlayerByUserId(id) table.insert(rows,{userId=id,name=p and p.DisplayName or "Reconectando",username=p and p.Name or "",mode=p and p:GetAttribute("CrossgroundsMode"),online=p~=nil,public=p and require(script.Parent.CareerService).Public(p)or nil}) end
 if result.group then result.group.members=rows end
 if result.invite then local leader=Players:GetPlayerByUserId(result.invite.leader) result.invite.name=leader and leader.DisplayName or "Líder" end
 return result
end
local function inLobby(player)
 return player.Parent==Players and player:GetAttribute("CrossgroundsMode")=="hub" and not player:GetAttribute("CrossgroundsTransition")
end
function Party.SetRemovalHandler(callback) removing=callback end
function Party.SetEligibility(callback) eligible=callback end
function Party.Session(player,mode)return eligible(player,mode)end
function Party.BonusMembers(player,mode)
 local group=Party.Get(player) if not group then return 0 end
 local active,match=eligible(player,mode) if not active then return 0 end
 local n=0
 for _,other in Party.Members(group) do
  if other~=player then local present,key=eligible(other,mode) if present and key==match then n+=1 end end
 end
 return n
end
function Party.RewardXP(player,base,mode,weapon,training)
 if training or not base or base<=0 then player:SetAttribute("PartyXPBonusPercent",0) return base or 0,weapon and base or nil,0 end
 local others=Party.BonusMembers(player,mode)
 local percent=math.clamp(Balance.Get("PartyMemberXPPercent"),0,100)
 local r=fractions[player] or {account=0,weapons={}} fractions[player]=r
 local account,remainder=XP.Boost(base,others,percent,r.account) r.account=remainder
 local weaponXP
 if weapon then weaponXP,remainder=XP.Boost(base,others,percent,r.weapons[weapon] or 0) r.weapons[weapon]=remainder end
 player:SetAttribute("PartyXPBonusPercent",others*percent)
 return account,weaponXP,account-base
end
function Party.Command(player,action,payload)
 if action=="get" then return true,Party.Snapshot(player) end
 local group=Party.Get(player)
 if action=="leave" then
  if group and group.lock and removing then local ok,why=removing(group,player,false) if not ok then return false,why end end
  return roster:Remove(player.UserId,player.UserId)
 end
 if not inLobby(player) then return false,"Volte ao lobby para gerenciar o grupo." end
 if action=="create" then local ok,result=roster:Create(player.UserId) return ok,ok and "Grupo criado." or result end
 if action=="accept" and type(payload)=="string" then
  local invite=roster.invites[player.UserId] local leader=invite and Players:GetPlayerByUserId(invite.actor)
  if not leader or not inLobby(leader) then return false,"O líder precisa estar no lobby para receber integrantes." end
  return roster:Accept(player.UserId,payload)
 end
 if action=="decline" and type(payload)=="string" then return roster:Decline(player.UserId,payload) end
 if action=="teams" then return roster:SetTeamPolicy(player.UserId,payload) end
 if type(payload)~="number" or payload%1~=0 then return false,"Escolha uma pessoa válida." end
 local target=Players:GetPlayerByUserId(payload) if not target or target==player then return false,"Pessoa indisponível." end
 if action=="kick" then return roster:Remove(player.UserId,payload) end
 if action=="leader" then return roster:SetLeader(player.UserId,payload) end
 if action=="invite" then
  if not inLobby(target) then return false,"Essa pessoa precisa estar no lobby." end
  local allowed,reason=require(script.Parent.SocialDirectory).InviteAllowed(target)if not allowed then return false,reason end
  local ok,friends=pcall(function()return player:IsFriendsWithAsync(target.UserId)end)
  if not ok or not friends then return false,"Convide um amigo do Roblox presente no lobby." end
  if not inLobby(player) or not inLobby(target) then return false,"O lobby mudou durante o convite." end
  return roster:Invite(player.UserId,payload)
 end
 return false,"Comando de grupo inválido."
end
function Party.Start()
 if Party.started then return end Party.started=true
 local remotes=game.ReplicatedStorage.Crossgrounds:WaitForChild("Remotes")
 stateRemote=remotes:FindFirstChild("PartyState") or Instance.new("RemoteEvent") stateRemote.Name="PartyState" stateRemote.Parent=remotes
 command=remotes:FindFirstChild("PartyCommand") or Instance.new("RemoteFunction") command.Name="PartyCommand" command.Parent=remotes
 command.OnServerInvoke=function(player,action,payload)
  if type(action)~="string" then return false,"Comando inválido." end
  local budget=rates[player] or {} rates[player]=budget local bucket=action=="get" and "get" or "write" local now=os.clock()
  if now-(budget[bucket] or -10)<.3 then return false,"Aguarde um instante." end budget[bucket]=now
  local ok,result=Party.Command(player,action,payload)
  return ok,result or (ok and "Grupo atualizado." or "Não foi possível alterar o grupo.")
 end
 Players.PlayerRemoving:Connect(function(player)
  local group=Party.Get(player) if group and group.lock and removing then removing(group,player,true) end
  roster:Forget(player.UserId) rates[player]=nil fractions[player]=nil appearances[player]=nil
 end)
 local function added(player)
  for _,key in {"CrossgroundsMode","CrossgroundsTransition"} do player:GetAttributeChangedSignal(key):Connect(function()local group=Party.Get(player) if group then emit(group.members) end end) end
 end
 Players.PlayerAdded:Connect(added) for _,p in Players:GetPlayers()do added(p)end
 require(script.Parent.CareerService).Changed:Connect(function(player)
  local public=require(script.Parent.CareerService).Public(player)if not public then return end
  local key=Http:JSONEncode({identity=public.identity,layers=public.frameLayers,rank=public.rankStyle})
  if appearances[player]~=key then appearances[player]=key local group=Party.Get(player)if group then emit(group.members)end end
 end)
 task.spawn(function()while true do task.wait(5)roster:Expire()end end)
end
return Party
