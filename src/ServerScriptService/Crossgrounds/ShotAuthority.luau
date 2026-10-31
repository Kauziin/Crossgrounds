-- One authoritative firearm path. Mode adapters retain ownership and damage rules.
local Shot=require(game.ReplicatedStorage.Crossgrounds.ShotMath)
local Query=require(script.Parent.Ballistics)
local History=require(script.Parent.ShotHistory)
local Ledger=require(game.ReplicatedStorage.Crossgrounds.ShotLedger)
local Simulation=require(game.ReplicatedStorage.Crossgrounds.ProjectileSimulation)
local Shots=require(script.Parent.ShotEffects)
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local remote=game.ReplicatedStorage.Events:FindFirstChild("ShotResult") or Instance.new("RemoteEvent")
remote.Name="ShotResult" remote.Parent=game.ReplicatedStorage.Events
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Noise=require(script.Parent.CombatNoise)
local npcLedgers=setmetatable({},{__mode="k"})
local Authority={}
History.Start()
local ledgers={} local active={} local connection
function Authority.NoteMelee(player,now)
 local ledger=ledgers[player] if not ledger then ledger=Ledger.new() ledgers[player]=ledger end
 ledger.last.any=now
end
local function reply(player,tool,id,accepted,reason,endpoint)
 remote:FireClient(player,{tool=tool,shotId=id,accepted=accepted,reason=reason,endpoint=endpoint,
  ammo=tool and tool:GetAttribute("Ammo"),version=tool and tool:GetAttribute("ShotAmmoVersion") or 0})
end
local function schedule(sim,finish,valid)
 active[sim]={finish=finish,valid=valid}
 if connection then return end
 connection=Run.Heartbeat:Connect(function(dt)
  for projectile,entry in active do
   if not entry.valid() then projectile:Cancel("owner") else projectile:Step(dt) end
   if not projectile.active then active[projectile]=nil entry.finish(projectile) end
  end
  if next(active)==nil and connection then connection:Disconnect() connection=nil end
 end)
end
local function resolve(o,config,origin,blocked,directions,ping,historicalTime)
 local player,tool,id,c,data=o.player,o.tool,o.shotId,o.character,o.data
 local h=c:FindFirstChildOfClass("Humanoid")
 tool:SetAttribute("Ammo",tool:GetAttribute("Ammo")-1)
 tool:SetAttribute("ShotAmmoVersion",(tool:GetAttribute("ShotAmmoVersion") or 0)+1)
 if o.accept then o.accept() end
 Noise.Emit(c,origin,data.FireRange or 100)
 local rays={}
 local function visual(result,direction,phase)
  Shots.Emit(c,tool,origin,result.endpoint,nil,id,{phase=phase,shotType=config.kind,direction=direction,
   speed=config.speed,acceleration=config.acceleration,lifetime=config.lifetime,range=config.range,
   visual=config.visual,reason=result.reason,normal=result.result and result.result.Normal})
 end
 for _,direction in directions do
  local options={origin=origin,direction=direction,range=config.range,shooter=c,radius=config.radius,maxTargets=data.MaxTargets,
   penetrationLoss=data.PenetrationLoss,classify=o.classify,onHit=o.onHit}
  if blocked then
   local result={endpoint=blocked.Position,reason="wall",result=blocked} table.insert(rays,result) visual(result,direction,"blocked")
  elseif config.kind=="projectile" then
   options.speed=config.speed options.lifetime=config.lifetime options.acceleration=config.acceleration options.radius=config.radius
   local sim=Simulation.new(options)
   visual({endpoint=origin+direction*config.range},direction,"launch")
   schedule(sim,function(done) visual(done.result or {endpoint=done.position,reason=done.reason},direction,"impact") end,
    function() return c.Parent and h.Health>0 and (not player or player.Character==c) and tool.Parent==c and o.valid() end)
  else
   local result=historicalTime and History.Trace(options,historicalTime) or Query.Trace(options)
   table.insert(rays,result) visual(result,direction,"impact")
  end
 end
 return rays[1] and rays[1].endpoint
end
function Authority.Fire(o)
 local player,tool,id=o.player,o.tool,o.shotId
 local ledger=ledgers[player] if not ledger then ledger=Ledger.new() ledgers[player]=ledger end
 local now=os.clock() local received,reason=ledger:Receive(id,now)
 -- Floods and replayed packets do not generate reflection traffic.
 if not received then return false,reason end
 local function reject(why) reply(player,tool,id,false,why) return false,why end
 local c,data=o.character,o.data
 local h=c and c:FindFirstChildOfClass("Humanoid")
 if not h or h.Health<=0 or not tool or tool.Parent~=c or not o.valid() then return reject("state") end
 local request=o.request
 if typeof(request)~="table" or request.version~=1 or typeof(request.time)~="number" or request.time~=request.time
  or math.abs(workspace:GetServerTimeNow()-request.time)>1.5 then return reject("timestamp") end
 if not Shot.Finite(o.aim) or not Shot.Finite(request.cameraOrigin) or not Shot.Finite(request.cameraDirection)
  or math.abs(request.cameraDirection.Magnitude-1)>.01 then return reject("vector") end
 local ping=player:GetNetworkPing()
 -- Account for bounded movement during transit without accepting a remote origin.
 local cameraLimit=12+math.min(6,math.max(0,ping)*.5*h.WalkSpeed)
 local head=c:FindFirstChild("Head") if not head or (request.cameraOrigin-head.Position).Magnitude>cameraLimit then return reject("camera") end
 if tool:GetAttribute("Reloading") then return reject("reload") end
 if not ledger:Ready(o.weapon,now,o.cooldown or data.Cooldown) then return reject("cadence") end
 if (tool:GetAttribute("Ammo") or 0)<=0 then return reject("ammo") end
 local config=Shot.Config(data)
 local cameraPath=request.cameraOrigin-head.Position
 local cover
 local function obstacle(model)
  local relation=o.classify(model) return (relation=="ignore" or relation=="target") and "ignore" or "block"
 end
 if cameraPath.Magnitude>.01 then cover=Query.Trace({origin=head.Position,direction=cameraPath,range=cameraPath.Magnitude,shooter=c,classify=obstacle}).result end
 -- Recompute camera intent on the server. No client-supplied hit/model/damage is used.
 local depth=(o.aim-request.cameraOrigin):Dot(request.cameraDirection)
 if depth<.05 or (o.aim-request.cameraOrigin-request.cameraDirection*depth).Magnitude>.25 then return reject("aim") end
 local camera=Query.Trace({origin=request.cameraOrigin,direction=request.cameraDirection,range=math.min(depth,config.range+12),shooter=c,
  classify=function(model)
   local relation=o.classify(model) return (relation=="ignore" or relation=="target") and "ignore" or "block"
  end})
 local aim=camera.endpoint
 local origin,blocked=Query.ResolveOrigin(c,tool,aim,o.requestedOrigin,o.classify)
 if not origin or (aim-origin).Magnitude<.05 then return reject("direction") end
 local blockedModel=blocked and Query.ModelFromPart(blocked.Instance)
 if blockedModel and o.classify(blockedModel)=="target" then origin=head.Position blocked=nil end
 blocked=cover or blocked
 local directions={} for pellet=1,config.pellets do directions[pellet]=Shot.Direction(aim-origin,data.Spread,tool:GetAttribute("ShotSeed"),id,pellet,config.pellets) end
 ledger:Commit(o.weapon,now,o.cooldown or data.Cooldown)
 local historicalTime,aligned=History.ResolveTime(workspace:GetServerTimeNow(),request.time,ping,request.view,request.cameraOrigin,request.cameraDirection,o.classify)
 tool:SetAttribute("LastShotViewAligned",aligned)
 local endpoint=resolve(o,config,origin,blocked,directions,ping,historicalTime)
 reply(player,tool,id,true,nil,endpoint)
 return true
end
-- Internal NPC entry: same resolver/ammo/cadence/config, no spoofed player remote.
function Authority.FireNPC(o)
 local c,tool=o.character,o.tool
 local h=c and c:FindFirstChildOfClass("Humanoid")
 if not c or c.Parent~=workspace:FindFirstChild("CTFBots") or not c:GetAttribute("CTFBot") or not h or h.Health<=0 or not tool or tool.Parent~=c or not o.valid() then return false,"state" end
 local id=tool:GetAttribute("WeaponId") local data=Kits.Weapons[id]
 if not data or data.Kind~="Gun" or not Shot.Finite(o.direction) or o.direction.Magnitude<.01 then return false,"weapon" end
 local ledger=npcLedgers[c] if not ledger then ledger=Ledger.new() npcLedgers[c]=ledger end
 local now=os.clock()
 if tool:GetAttribute("Reloading") then return false,"reload" end
 if not ledger:Ready(id,now,data.Cooldown) then return false,"cadence" end
 if (tool:GetAttribute("Ammo") or 0)<=0 then return false,"ammo" end
 local config=Shot.Config(data) local head=c:FindFirstChild("Head") if not head then return false,"head" end
 local aim=Shot.Finite(o.aim) and o.aim or head.Position+o.direction.Unit*config.range
 local origin,blocked=Query.ResolveOrigin(c,tool,aim,nil,o.classify) if not origin then return false,"origin" end
 local blockedModel=blocked and Query.ModelFromPart(blocked.Instance)
 if blockedModel and o.classify(blockedModel)=="target" then origin=head.Position blocked=nil end
 local sequence=ledger.sequence+1 ledger:Receive(sequence,now) ledger:Commit(id,now,data.Cooldown)
 o.data=data o.shotId=sequence
 local directions={} for pellet=1,config.pellets do directions[pellet]=Shot.Direction(aim-origin,data.Spread,tool:GetAttribute("ShotSeed"),sequence,pellet,config.pellets) end
 resolve(o,config,origin,blocked,directions,0,nil)
 return true
end
function Authority.ReloadNPC(c,tool,valid)
 local data=Kits.Weapons[tool:GetAttribute("WeaponId")]
 if not data or data.Kind~="Gun" or tool:GetAttribute("Reloading") or tool.Parent~=c or not valid() then return false end
 local ammo,reserve=tool:GetAttribute("Ammo") or 0,tool:GetAttribute("ReserveAmmo") or 0
 if ammo>=data.Magazine or reserve<=0 then return false end
 tool:SetAttribute("Reloading",true) tool:SetAttribute("ReloadStartedAt",workspace:GetServerTimeNow()) tool:SetAttribute("ReloadDuration",data.ReloadTime)
 local sound=tool.Handle:FindFirstChild("ReloadSound") if sound then sound:Play() end
 task.delay(data.ReloadTime,function()
  if tool.Parent~=c or not valid() then if tool.Parent then tool:SetAttribute("Reloading",false) end return end
  local amount=math.min(data.Magazine-(tool:GetAttribute("Ammo") or 0),tool:GetAttribute("ReserveAmmo") or 0)
  tool:SetAttribute("Ammo",(tool:GetAttribute("Ammo") or 0)+amount) tool:SetAttribute("ReserveAmmo",(tool:GetAttribute("ReserveAmmo") or 0)-amount)
  tool:SetAttribute("ShotAmmoVersion",(tool:GetAttribute("ShotAmmoVersion") or 0)+1) tool:SetAttribute("Reloading",false)
 end)
 return true
end
Players.PlayerRemoving:Connect(function(player) ledgers[player]=nil end)
return Authority
