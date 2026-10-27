-- Bounded reusable lines and one updater, disconnected when idle. No damage.
local Run=game:GetService("RunService")
local Simulation=require(script.Parent.ProjectileSimulation)
local Cosmetics={} local pool={} local active={} local connection local created=0
local function line()
 local part=table.remove(pool)
 if part then return part end
 if created>=128 then return end
 created+=1 part=Instance.new("Part") part.Name="ShotTrace"
 part.Anchored=true part.CanCollide=false part.CanTouch=false part.CanQuery=false part.CastShadow=false
 part.Material=Enum.Material.Neon return part
end
local function release(entry)
 if entry.part then entry.part.Parent=nil table.insert(pool,entry.part) entry.part=nil end
 active[entry]=nil
end
local function draw(entry,start,finish)
 local delta=finish-start
 if not entry.part or delta.Magnitude<.001 then return end
 entry.part.Size=Vector3.new(entry.width,entry.width,delta.Magnitude)
 entry.part.CFrame=CFrame.lookAt(start+delta*.5,finish)
end
local function update(dt)
 for entry in active do
  entry.age+=dt
  if entry.sim then
   local before=entry.sim.position entry.sim:Step(dt)
   draw(entry,before,entry.sim.position)
   if not entry.sim.active then release(entry) end
  else
   local delta=entry.endpoint-entry.origin local distance=delta.Magnitude
   local head=math.min(distance,entry.age*entry.speed) local tail=math.max(0,head-entry.length)
   if distance>.001 then draw(entry,entry.origin+delta.Unit*tail,entry.origin+delta.Unit*head) end
   if entry.age>=distance/entry.speed+.045 then release(entry) end
  end
 end
 if next(active)==nil and connection then connection:Disconnect() connection=nil end
end
local function start(entry,color)
 local part=line() if not part then return end
 entry.part=part entry.width=entry.width or .035 entry.age=0
 part.Color=color or Color3.fromRGB(255,220,140) part.Transparency=.12 part.Size=Vector3.new(.035,.035,.035)
 part.CFrame=CFrame.new(entry.origin) part.Parent=workspace active[entry]=true
 if not connection then connection=(Run:IsClient() and Run.RenderStepped or Run.Heartbeat):Connect(update) end
 return entry
end
function Cosmetics.Trace(origin,endpoint,color,visual)
 visual=visual or {} return start({origin=origin,endpoint=endpoint,speed=math.clamp(visual.Speed or 3000,1,20000),length=visual.Length or 18,width=visual.Width},color)
end
function Cosmetics.Cancel(entry)
 if entry and active[entry] then if entry.sim then entry.sim:Cancel() end release(entry) end
end
function Cosmetics.Correct(entry,endpoint)
 if entry and active[entry] then
  if entry.sim then entry.sim.position=endpoint entry.sim:Cancel("confirmed") else entry.endpoint=endpoint end
 end
end
function Cosmetics.Projectile(actor,id,origin,direction,options)
 local sim=Simulation.new({origin=origin,direction=direction,speed=options.speed,lifetime=options.lifetime,range=options.range,
  acceleration=options.acceleration,radius=options.radius,shooter=options.shooter or actor,
  classify=options.classify or function() return "block" end,maxTargets=options.maxTargets,penetrationLoss=options.penetrationLoss})
 return start({origin=origin,sim=sim,actor=actor,id=id,width=options.visual and options.visual.Width})
end
function Cosmetics.Finish(actor,id,endpoint)
 for entry in active do if entry.actor==actor and entry.id==id then Cosmetics.Correct(entry,endpoint) end end
end
function Cosmetics.Stats() local n=0 for _ in active do n+=1 end return {active=n,pooled=#pool,created=created,connected=connection~=nil} end
return Cosmetics
