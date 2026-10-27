local Run=game:GetService("RunService")
local Profiles=require(script.Parent.BotProfiles)
local Navigation=require(script.Parent.BotNavigation)
local Perception=require(script.Parent.BotPerception)
local Decision=require(script.Parent.BotDecision)
local Combat=require(script.Parent.BotCombat)
local Objectives=require(script.Parent.CTFBotObjectives)
local Damage=require(game.ServerScriptService.MainGameScript.GameManager.DamageService)
local Runtime={} local agents={} local connection local accumulator=0 local vision=24 local visionAt=os.clock()
local metrics={ticks=0,cpu=0,decisions=0,vision=0,peakTick=0,activeSeconds=0,decisionDelay=0,started=os.clock()}
local function spendVision()
 if vision<1 then return false end vision-=1 metrics.vision+=1 return true
end
local function diagnose(agent,now)
 if not Run:IsStudio() or not workspace:GetAttribute("BotDiagnosticsEnabled") then return end
 local bot,memory,nav=agent.bot,agent.sensor.memory,agent.nav
 bot:SetAttribute("BotDecision",agent.state) bot:SetAttribute("BotDecisionAge",now-agent.since)
 bot:SetAttribute("BotDecisionReason",agent.reason) bot:SetAttribute("BotGoal",nav.goal)
 bot:SetAttribute("BotLastSeen",memory.position) bot:SetAttribute("BotLastHeard",memory.heard) bot:SetAttribute("BotConfidence",memory.confidence)
 bot:SetAttribute("BotLOS",memory.visible) bot:SetAttribute("BotTarget",memory.target and memory.target.Name)
 bot:SetAttribute("BotRouteReason",nav.reason) bot:SetAttribute("BotWaypoint",nav.index) bot:SetAttribute("BotTravel",nav.travel)
 bot:SetAttribute("BotWaypointPosition",nav.waypoints and nav.waypoints[nav.index] and nav.waypoints[nav.index].Position)
 bot:SetAttribute("BotMoveCommand",nav.command) bot:SetAttribute("BotPathPending",nav.pending==true)
 bot:SetAttribute("BotIdleSeconds",nav.idleSeconds) bot:SetAttribute("BotStuckCount",nav.stuckCount) bot:SetAttribute("BotTargetChanges",memory.changes or 0)
 bot:SetAttribute("BotFOV",140) bot:SetAttribute("BotWeapon",agent.combat.tool:GetAttribute("WeaponId")) bot:SetAttribute("BotReloading",agent.combat.tool:GetAttribute("Reloading"))
 bot:SetAttribute("BotRecovery",nav.recovery) bot:SetAttribute("BotFireReason",agent.combat.denied)
 bot:SetAttribute("BotShots",agent.combat.shots) bot:SetAttribute("BotHits",agent.combat.hits) bot:SetAttribute("BotFirstShotDelay",agent.combat.firstShotDelay)
 bot:SetAttribute("BotUtility",game.HttpService:JSONEncode(agent.scores or {}))
end
local function decide(agent,now)
 local memory=agent.sensor.memory local root=agent.bot.HumanoidRootPart local h=agent.bot.Humanoid
 local objective=agent.adapter:Objective(memory,now)
 local resources={health=h.Health/h.MaxHealth,ammo=agent.combat.tool:GetAttribute("Ammo") or 0,reserve=agent.combat.tool:GetAttribute("ReserveAmmo") or 0,distance=memory.position and (memory.position-root.Position).Magnitude or 1000}
 local state,scores,reason=Decision.Choose(memory,resources,agent.personality,objective,now,agent.state,agent.since)
 if state~=agent.state then agent.state=state agent.since=now end agent.scores=scores agent.reason=reason metrics.decisions+=1
 local destination,label
 if state=="Objective" and objective then destination=objective.position label=objective.label
 elseif state=="Search" then
  local offset=now-(memory.seenAt or memory.heardAt or now)>1 and Vector3.new(math.sin(now+agent.phase)*4,0,math.cos(now+agent.phase)*4) or Vector3.zero
  destination=memory.position and memory.position+offset label="Investigating"
 elseif state=="Retreat" and memory.position then
  destination=agent.adapter:Cover(memory.position)
  if not destination then local delta=root.Position-memory.position if delta.Magnitude>.01 then destination=root.Position+delta.Unit*10 end end label="TakingCover"
 elseif state=="Engage" and memory.position then
  local delta=memory.position-root.Position local preferred=agent.combat.data.Range>400 and 75 or agent.combat.data.Range>250 and 45 or 28
  if delta.Magnitude<preferred*.55 then destination=root.Position-delta.Unit*8
  elseif delta.Magnitude>preferred*1.4 then destination=memory.position
  else
   local side=Vector3.new(-delta.Z,0,delta.X)
   if side.Magnitude>.1 then destination=root.Position+side.Unit*math.sin(now*.7+agent.phase)*6 end
  end label="Engaging"
 else destination=objective and objective.position label="Patrol" end
 if destination then
  if not agent.nav:SetGoal(destination,now) then local alternate=agent.adapter:Alternate() if alternate then agent.nav:SetGoal(alternate,now) end label="Recovering" end
 elseif agent.nav.goal then agent.nav:Pause() end
 agent.bot:SetAttribute("CTFState",label or state) agent.bot:SetAttribute("CTFLane",agent.adapter.lane)
 agent.bot:SetAttribute("BotAlert",memory.visible or memory.confidence>.1)
end
local function tick(dt)
 local at=os.clock() local now=at
 metrics.activeSeconds+=dt
 vision=math.min(24,vision+(now-visionAt)*Profiles.Budget.VisionPerSecond) visionAt=now
 Navigation.Pump(now)
 for bot,agent in agents do
  if not bot.Parent or agent.h.Health<=0 or not agent.active() then Runtime:Stop(bot)
  else
   local ok,err=xpcall(function()
   if now>=agent.nextSense then
    local before=agent.sensor.memory.changes or 0 agent.sensor:Scan(now)
    metrics.targetChanges=(metrics.targetChanges or 0)+(agent.sensor.memory.changes or 0)-before
    agent.nextSense=now+agent.profile.Scan+agent.rng:NextNumber(0,.05)
   end
   if now>=agent.nextDecision then metrics.decisionDelay+=now-agent.nextDecision decide(agent,now) agent.nextDecision=now+Profiles.Budget.DecisionInterval+agent.rng:NextNumber(0,.12) end
   agent.combat:Update(agent.sensor.memory,dt,now,agent.state=="Engage" or agent.state=="Retreat" or agent.state=="Objective")
   if now>=agent.nextMove then agent.flags:TryInteract(bot) agent.nav:Update(now) agent.nextMove=now+.1 end
   if agent.bot.HumanoidRootPart.Position.Y<15 then agent.h.Health=0 end
   if now>=agent.nextDebug then diagnose(agent,now) agent.nextDebug=now+.5 end
   end,debug.traceback)
   if not ok then metrics.errors=(metrics.errors or 0)+1 warn("BotRuntime: "..tostring(err)) Runtime:Stop(bot) end
  end
 end
 local elapsed=os.clock()-at metrics.ticks+=1 metrics.cpu+=elapsed metrics.peakTick=math.max(metrics.peakTick,elapsed)
 if next(agents)==nil and connection then connection:Disconnect() connection=nil end
end
function Runtime:Start(bot,team,slot,flags,active)
 self:Stop(bot)
 local difficulty=workspace:GetAttribute("BotDifficulty") or bot:GetAttribute("BotDifficulty") or Profiles.Default
 local rng=Random.new((bot:GetAttribute("CTFSlot") or slot)*97+math.floor(os.clock()*1000)%100000)
 local personalityName=bot:GetAttribute("BotPersonality") or Profiles.PersonalityOrder[rng:NextInteger(1,#Profiles.PersonalityOrder)]
 local profile,personality=Profiles.Resolve(difficulty,personalityName) local combat=Combat.new(bot,profile,rng) if not combat then return end
 local now=os.clock() local adapter=Objectives.new(bot,team,slot,flags)
 local role=bot:GetAttribute("CTFRole") bot.Humanoid.WalkSpeed=role=="Runner" and 21 or role=="Guardian" and 14 or 18 bot.Humanoid.UseJumpPower=false bot.Humanoid.JumpHeight=7.5
 bot:SetAttribute("BotDifficulty",difficulty) bot:SetAttribute("BotPersonality",personalityName) bot:SetAttribute("BotReaction",combat.reaction)
 local agent={bot=bot,h=bot.Humanoid,active=active,flags=flags,profile=profile,personality=personality,combat=combat,rng=rng,adapter=adapter,nav=Navigation.new(bot),state="Patrol",since=now,
  nextSense=now+slot*.05,nextDecision=now+slot*.06,nextMove=now,nextDebug=now,phase=rng:NextNumber(0,math.pi*2)}
 agent.sensor=Perception.new(bot,profile,function(model) return Damage:ShotRelation(bot,model) end,function() return adapter:Candidates() end,spendVision)
 agents[bot]=agent
 agent.dead=agent.h.Died:Connect(function() self:Stop(bot) end)
 agent.ancestry=bot.AncestryChanged:Connect(function() if not bot:IsDescendantOf(workspace) then self:Stop(bot) end end)
 if not connection then accumulator=0 connection=Run.Heartbeat:Connect(function(dt) accumulator+=dt if accumulator>=Profiles.Budget.Tick then local step=accumulator accumulator=0 tick(step) end end) end
 return agent
end
function Runtime:Stop(bot)
 local agent=agents[bot] if not agent then return end agents[bot]=nil
 agent.combat.alive=false agent.nav:Destroy() if agent.dead then agent.dead:Disconnect() end if agent.ancestry then agent.ancestry:Disconnect() end
 agent.h.AutoRotate=true
end
function Runtime:Snapshot()
 local count,shots,hits,idle=0,0,0,0 for _,agent in agents do count+=1 shots+=agent.combat.shots hits+=agent.combat.hits idle+=agent.nav.idleSeconds end
 local nav=Navigation.Stats()
 local bands={} for name,values in Combat.Metrics.bands do bands[name]=table.clone(values) end
 return {active=count,connected=connection~=nil,vision=metrics.vision,decisions=metrics.decisions,meanTickMs=metrics.cpu/math.max(1,metrics.ticks)*1000,peakTickMs=metrics.peakTick*1000,
  errors=metrics.errors or 0,decisionDelayMs=metrics.decisionDelay/math.max(1,metrics.decisions)*1000,activeSeconds=metrics.activeSeconds,pathsPerMinute=nav.computations*60/math.max(1,metrics.activeSeconds),
  targetChanges=metrics.targetChanges or 0,targetChangesPerMinute=(metrics.targetChanges or 0)*60/math.max(1,metrics.activeSeconds),activeIdleSeconds=idle,
  meanFirstShotDelay=Combat.Metrics.firstShotTotal/math.max(1,Combat.Metrics.firstShotCount),
  elapsed=os.clock()-metrics.started,shots=Combat.Metrics.shots,hits=Combat.Metrics.hits,activeShots=shots,activeHits=hits,bands=bands,navigation=nav}
end
workspace:GetAttributeChangedSignal("BotDiagnosticsEnabled"):Connect(function()
 if not workspace:GetAttribute("BotDiagnosticsEnabled") then for _,agent in agents do
  if agent.nav.debugFolder then agent.nav.debugFolder:Destroy() agent.nav.debugFolder=nil end
 end end
end)
return Runtime
