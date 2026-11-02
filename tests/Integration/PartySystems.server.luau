if not game:GetService("RunService"):IsStudio()or game:GetService("StudioTestService"):GetTestArgs()~="PartySystemsIntegration"then return end
local Players=game:GetService("Players")local Test=game:GetService("StudioTestService")
local event=Instance.new("RemoteEvent")event.Name="PartySystemsIntegration"event.Parent=game.ReplicatedStorage
local replies,ready={},{}local sequence=0 local checks={}local observations={}
event.OnServerEvent:Connect(function(p,id,value)if id==0 then ready[p]=value else replies[id]={player=p,value=value}end end)
local function waitFor(fn,seconds)local deadline=os.clock()+seconds repeat if fn()then return true end task.wait(.05)until os.clock()>deadline return false end
local function check(value,name)assert(value,name)table.insert(checks,name)end
local function rpc(p,action,payload)
 sequence+=1 local id=sequence event:FireClient(p,id,action,payload)
 assert(waitFor(function()return replies[id]~=nil end,12),"client timeout: "..action)
 local reply=replies[id]replies[id]=nil assert(reply.player==p,"wrong client")assert(reply.value.ok,tostring(reply.value.error))return reply.value.result
end
task.spawn(function()
 local ok,err=xpcall(function()
  check(waitFor(function()
   if not workspace:GetAttribute("CrossgroundsBootReady")or #Players:GetPlayers()<2 then return false end
   for _,p in Players:GetPlayers()do if not p:GetAttribute("ModeCharacterReady")or not ready[p]then return false end end return true
  end,100),"two real clients ready")
  local list=Players:GetPlayers()table.sort(list,function(a,b)return a.UserId<b.UserId end)local leader,member=list[1],list[2]
  local Party=require(game.ServerScriptService.Crossgrounds.PartyService)
  local coordinator=require(game.ServerScriptService.Crossgrounds.HubBootstrap).Coordinator
  local Career=require(game.ServerScriptService.Crossgrounds.CareerService)
  local Progress=require(game.ServerScriptService.Crossgrounds.ProgressionService)
  local Balance=require(game.ServerScriptService.Crossgrounds.ProgressionBalance)
  local result=rpc(leader,"party",{action="create"})check(result.success,"leader creates through normal remote")
  -- Studio clients are not Roblox friends. Seed only the invitation on the server;
  -- acceptance, leadership, session entry and XP all use the normal game contracts.
  check(Party.Roster:Invite(leader.UserId,member.UserId),"fixture seeds invitation without platform friendship")
  local invitation=Party.Roster.invites[member.UserId]
  result=rpc(member,"party",{action="accept",payload=invitation.id})check(result.success,"member accepts through normal remote")
  check(#Party.Get(leader).members==2,"formation has two members")
  result=rpc(member,"menu")check(result.open,"social menu opens on member client")
  rpc(member,"session",{action="join",gameId="ctf",variant="practice"})
  check(waitFor(function()return coordinator.queue:Get(member).state=="ready"end,5),"practice request ready")
  rpc(member,"session",{action="enter",ticket=coordinator.queue:Get(member).ticket})
  check(waitFor(function()return member:GetAttribute("CTFPracticeRange")==true and member:GetAttribute("CrossgroundsTransition")==false end,20),"member enters practice alone")
  check(leader:GetAttribute("CrossgroundsMode")=="hub","practice does not drag leader")
  check(Party.BonusMembers(member,"ctf")==0,"practice has no bonus members")
  rpc(member,"session",{action="returnHub"})
  check(waitFor(function()return member:GetAttribute("CrossgroundsMode")=="hub"and member:GetAttribute("CrossgroundsTransition")==false end,20),"practice member returns to hub")
  rpc(member,"session",{action="join",gameId="ctf"})
  check(waitFor(function()return coordinator.errors[member]~=nil end,3),"nonleader cannot drag group")
  rpc(leader,"session",{action="join",gameId="ctf"})
  check(waitFor(function()return coordinator.queue:Get(leader).state=="ready"and coordinator.queue:Get(member).state=="ready"end,5),"both collective tickets ready")
  rpc(leader,"session",{action="cancel",ticket=coordinator.queue:Get(leader).ticket})
  check(waitFor(function()return not Party.Get(leader).lock end,3),"cancel releases group lock")
  check(coordinator.queue:Get(member).state=="failed","cancel reaches member ticket")
  rpc(leader,"session",{action="join",gameId="ctf"})
  check(waitFor(function()return coordinator.queue:Get(leader).state=="ready"end,5),"group can retry after cancel")
  rpc(leader,"session",{action="enter",ticket=coordinator.queue:Get(leader).ticket})
  check(waitFor(function()return leader:GetAttribute("InMatch")and member:GetAttribute("InMatch")and not leader:GetAttribute("CrossgroundsTransition")and not member:GetAttribute("CrossgroundsTransition")end,35),"leader enters Conflict with both real clients")
  check(leader.Team==member.Team,"same-team choice respected")
  check(waitFor(function()return workspace:GetAttribute("RoundState")=="Playing"end,65),"Conflict round starts")
  coordinator.adapters.ctf.bots:StopRound()
  local before=Career.Get(leader).lifetimeXP local weaponBefore=Career.Get(leader).weapons.m4a1 or 0
  local base=Balance.Get("CTFKillXP")local granted=Progress.CTFKill(leader,false,"m4a1")
  check(granted==math.floor(base*1.05),"duo receives five percent account XP")
  check(Career.Get(leader).lifetimeXP-before==granted,"career records boosted account XP")
  check(Career.Get(leader).weapons.m4a1-weaponBefore==granted,"weapon records boosted XP")
  observations.xp={base=base,granted=granted}
  before=Career.Get(leader).lifetimeXP
  Progress.Kill(leader,"training",true,"m4a1")
  check(Career.Get(leader).lifetimeXP-before==Balance.Get("TrainingKillXP"),"training reward does not receive group bonus")
  member.Character:FindFirstChildOfClass("Humanoid").Health=0
  check(Party.BonusMembers(leader,"ctf")==1,"normal death preserves bonus eligibility")
  result=rpc(member,"party",{action="leave"})check(result.success,"member can leave group during round")
  check(member:GetAttribute("InMatch"),"leaving group does not force match exit")
  check(Party.BonusMembers(leader,"ctf")==0,"leaving removes social bonus immediately")
  rpc(leader,"session",{action="returnHub"})
  check(waitFor(function()return leader:GetAttribute("CrossgroundsMode")=="hub"and not leader:GetAttribute("CrossgroundsTransition")end,20),"leader returns to hub")
  check(member:GetAttribute("CrossgroundsMode")=="ctf","leader exit does not force another participant out")
  rpc(member,"session",{action="returnHub"})
  check(waitFor(function()return member:GetAttribute("CrossgroundsMode")=="hub"and not member:GetAttribute("CrossgroundsTransition")end,20),"second member returns for arrival fixture")
  Party.Roster:Forget(leader.UserId)Party.Roster:Forget(member.UserId)
  local restored,group=Party.Roster:Restore({id="verified-arrival-fixture",leader=leader.UserId,members={leader.UserId,member.UserId},sameTeam=false})
  check(restored,"verified arrival restores formation")
  -- Tests destination admission with two actual clients. MemoryStore/teleport remains a published-only check.
  for _,p in {leader,member}do p:SetAttribute("CrossgroundsTransition",true)end
  local admitted,reason=coordinator.partyAdmission:Receive(group,{leader,member},"arena")check(admitted,"arrival collectively enters Arena: "..tostring(reason))
  for _,p in {leader,member}do p:SetAttribute("CrossgroundsTransition",false)end
  check(leader:GetAttribute("CrossgroundsMode")=="arena"and member:GetAttribute("CrossgroundsMode")=="arena","both arrival clients reach Arena")
  check(not group.lock,"arrival releases formation lock")
  check(coordinator.adapters.arena.members[leader]~=nil and coordinator.adapters.arena.members[member]~=nil,"Arena retains both admitted seats")
  for _,p in {leader,member}do rpc(p,"session",{action="returnHub"})end
  check(waitFor(function()return leader:GetAttribute("CrossgroundsMode")=="hub"and member:GetAttribute("CrossgroundsMode")=="hub"and not leader:GetAttribute("CrossgroundsTransition")and not member:GetAttribute("CrossgroundsTransition")end,25),"arrival clients can return to hub")

 end,debug.traceback)
 Test:EndTest({ok=ok,error=not ok and tostring(err)or nil,checks=checks,observations=observations})
end)
