
local Http=game:GetService("HttpService")
local Damage=require(game.ServerScriptService.MainGameScript.GameManager.DamageService)
local Stats=require(game.ServerScriptService.Crossgrounds.CTFMatchStats)
local player=game.Players:GetPlayers()[1]
local results={}
local function check(name,condition,detail)
 table.insert(results,{case=name,passed=condition==true,detail=detail})
 assert(condition,name.." failed")
end
local function prepare(model)
 model:SetAttribute("SpawnProtectedUntil",0)
 for _,v in model:GetChildren()do if v:IsA("ForceField")then v:Destroy()end end
end
local function pause(model)
 local root=model:FindFirstChild("HumanoidRootPart")if root then root.Anchored=true end
 model:SetAttribute("SpawnProtectedUntil",workspace:GetServerTimeNow()+600)
end
local function alive(model)local h=model:FindFirstChildOfClass("Humanoid")return h and h.Health>0 end
local function row(model)
 local team=model:GetAttribute("CTFTeam")local slot=model:GetAttribute("CTFSlot")
 local id=-(team=="Blue"and 100 or 200)-slot
 for _,r in Stats.Snapshot()do if r.userId==id then return r end end
end
local added=workspace.CTFBots.ChildAdded:Connect(function(model)task.delay(.1,function()if model.Parent then pause(model)end end)end)
local ok,err=xpcall(function()
 local enemies={}local friends={}
 for _,b in workspace.CTFBots:GetChildren()do pause(b)if alive(b)then table.insert(b:GetAttribute("CTFTeam")==player.Team.Name and friends or enemies,b)end end
 pause(player.Character)
 check("roster",#Stats.Snapshot()==11,{botRows=#Stats.Snapshot()})
 local target=enemies[1]
 local kills=player.leaderstats.Kills.Value
 local lifetime=player:GetAttribute("ProgressKills")
 local botKills=player:GetAttribute("ProgressBotKills")
 local modeKills=player:GetAttribute("Progressctf_Kills")
 local deaths=row(target).deaths
 prepare(target)
 check("human-hit-bot",Damage:Deal(player.Character,target.Humanoid,9999,"Rifle",false))
 task.wait(.25)
 check("human-bot-credit",player.leaderstats.Kills.Value==kills+1 and player:GetAttribute("ProgressKills")==lifetime+1 and player:GetAttribute("ProgressBotKills")==botKills+1 and player:GetAttribute("Progressctf_Kills")==modeKills+1)
 check("bot-death-recorded",row(target).deaths==deaths+1)
 Damage:ResolveDeath(target,target.Humanoid)Damage:Unwatch(target)Damage:Unwatch(target)
 task.wait(.1)
 check("duplicate-death-guard",player.leaderstats.Kills.Value==kills+1 and row(target).deaths==deaths+1 and player:GetAttribute("ProgressBotKills")==botKills+1)
 local friendly=friends[1]prepare(friendly)local health=friendly.Humanoid.Health
 check("friendly-fire-rejected",Damage:Deal(player.Character,friendly.Humanoid,9999,"Rifle",false)==false and friendly.Humanoid.Health==health)
 local attacker=enemies[2]
 local attackerKills=row(attacker).kills
 local friendlyDeaths=row(friendly).deaths
 prepare(friendly)
 check("bot-hit-bot",Damage:Deal(attacker,friendly.Humanoid,9999,"Rifle",false))
 task.wait(.25)
 check("bot-bot-credit",row(attacker).kills==attackerKills+1 and row(friendly).deaths==friendlyDeaths+1)
 local playerDeaths=player.leaderstats.Deaths.Value
 local progressDeaths=player:GetAttribute("Progressctf_Deaths")
 prepare(player.Character)
 check("bot-hit-player",Damage:Deal(attacker,player.Character.Humanoid,9999,"Rifle",false))
 task.wait(.25)
 check("bot-player-credit",row(attacker).kills==attackerKills+2 and player.leaderstats.Deaths.Value==playerDeaths+1 and player:GetAttribute("Progressctf_Deaths")==progressDeaths+1)
 local victim=player.Character
 Damage:ResolveDeath(victim,victim.Humanoid)
 check("player-death-once",player.leaderstats.Deaths.Value==playerDeaths+1)
 local team=attacker:GetAttribute("CTFTeam")local slot=attacker:GetAttribute("CTFSlot")
 local savedKills=row(attacker).kills local savedDeaths=row(attacker).deaths
 prepare(attacker)
 check("killer-can-die",Damage:Deal(friends[2],attacker.Humanoid,9999,"Rifle",false))
 local deadline=os.clock()+16 local replacement
 repeat
  for _,b in workspace.CTFBots:GetChildren()do if b~=attacker and b:GetAttribute("CTFTeam")==team and b:GetAttribute("CTFSlot")==slot and alive(b)then replacement=b break end end
  if not replacement then task.wait(.2)end
 until replacement or os.clock()>deadline
 check("bot-respawn",replacement~=nil)
 check("score-survives-respawn",row(replacement).kills==savedKills and row(replacement).deaths==savedDeaths+1 and replacement:GetAttribute("CTFKills")==savedKills)
end,debug.traceback)
added:Disconnect()
for _,b in workspace.CTFBots:GetChildren()do
 local root=b:FindFirstChild("HumanoidRootPart")if root then root.Anchored=false end
 b:SetAttribute("SpawnProtectedUntil",workspace:GetServerTimeNow()+2)
end
if player.Character then
 local root=player.Character:FindFirstChild("HumanoidRootPart")if root then root.Anchored=false end
 player.Character:SetAttribute("SpawnProtectedUntil",workspace:GetServerTimeNow()+10)
end
local report={passed=ok,error=not ok and tostring(err)or nil,checks=results}
workspace:SetAttribute("CTFKillsValidation",Http:JSONEncode(report))
Http:PostAsync("http://127.0.0.1:18772/validation",Http:JSONEncode(report),Enum.HttpContentType.ApplicationJson)
if not ok then warn(err)end

