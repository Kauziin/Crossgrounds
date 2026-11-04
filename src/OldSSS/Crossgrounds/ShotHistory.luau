-- Limited hitbox history; never moves live characters or accepts a client hit.
local Query=require(script.Parent.Ballistics)
local SharedQuery=require(game.ReplicatedStorage.Crossgrounds.ShotQuery)
local Shot=require(game.ReplicatedStorage.Crossgrounds.ShotMath)
local Run=game:GetService("RunService")
local History={} local records={} local started=false local accumulator=0
History.Window=.35
History.AlignmentWindow=.08
History.AlignmentError=.75
function History.Time(now,requested,ping)
 local transit=math.clamp(ping*.5,0,.15)
 local shot=math.clamp(requested,now-transit-.05,math.min(now,now-transit+.05))
 -- Include one snapshot of interpolation even on low-ping connections.
 return math.clamp(shot-math.clamp(transit+1/60,1/60,.16),now-History.Window,now)
end
-- Slab intersection against a server-captured oriented hitbox.
function History.Box(origin,direction,range,cf,size,radius)
 if (radius or 0)>0 then return require(game.ReplicatedStorage.Crossgrounds.SweptSphereBox)(origin,direction,range,cf,size,radius) end
 local o=cf:PointToObjectSpace(origin) local d=cf:VectorToObjectSpace(direction.Unit)
 local near,far=0,range local normal=Vector3.zero
 for _,axis in {Vector3.xAxis,Vector3.yAxis,Vector3.zAxis} do
  local position=o:Dot(axis) local velocity=d:Dot(axis) local half=size:Dot(axis)*.5
  if math.abs(velocity)<1e-8 then if math.abs(position)>half then return end
  else
   local a,b=(-half-position)/velocity,(half-position)/velocity local n=-axis
   if a>b then a,b=b,a n=axis end
   if a>near then near=a normal=n end far=math.min(far,b)
   if near>far then return end
  end
 end
 return near,cf:VectorToWorldSpace(normal)
end
local function track(humanoid)
 local model=humanoid.Parent
 if model and model:IsA("Model") and not records[model] then records[model]={humanoid=humanoid,samples={}} end
end
local function poses(model)
 local parts={}
 for _,child in model:GetChildren() do
  if child:IsA("BasePart") and SharedQuery.IsBodyPart(child,model) and child.CanQuery then parts[child]={cf=child.CFrame,size=child.Size} end
 end
 return parts
end
local function capture(now)
 for model,record in records do
  if not model:IsDescendantOf(workspace) then records[model]=nil
  elseif record.humanoid.Health<=0 then table.clear(record.samples)
  else
   local parts=poses(model)
   local root=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or next(parts)
   if root then
    table.insert(record.samples,{time=now,parts=parts,position=root.Position})
    while #record.samples>1 and record.samples[2].time<now-History.Window-.07 do table.remove(record.samples,1) end
   end
  end
 end
end
function History.Start()
 if started then return end started=true
 workspace.DescendantAdded:Connect(function(v) if v:IsA("Humanoid") then track(v) end end)
 for _,v in workspace:GetDescendants() do if v:IsA("Humanoid") then track(v) end end
 Run.Heartbeat:Connect(function(dt)
  accumulator+=dt if accumulator<1/60 then return end accumulator%=1/30 capture(workspace:GetServerTimeNow())
 end)
end
function History.ObservedAt(model)
 local record=records[model] local frames=record and record.samples
 return frames and frames[#frames] and frames[#frames].time
end
local function sample(record,time)
 local frames=record.samples if #frames==0 then return end
 -- Do not extrapolate a respawn or rewind across a large teleport.
 if time<frames[1].time-.04 then return end
 local before,after=frames[1],frames[#frames]
 for _,frame in frames do if frame.time<=time then before=frame else after=frame break end end
 if (before.position-frames[#frames].position).Magnitude>18 then return end
 local alpha=math.clamp((time-before.time)/math.max(.00001,after.time-before.time),0,1)
 local parts={}
 for part,a in before.parts do
  local b=after.parts[part]
  if b and part.Parent then parts[part]={cf=a.cf:Lerp(b.cf,alpha),size=a.size} end
 end
 return parts
end
-- A client observation can only select a nearby SERVER-recorded pose time.
-- It cannot enlarge a hitbox, move geometry or declare damage.
function History.ResolveTime(now,requested,ping,view,cameraOrigin,cameraDirection,classify)
 local fallback=History.Time(now,requested,ping)
 if typeof(view)~="table" or typeof(view.part)~="Instance" or not view.part:IsA("BasePart")
  or not Shot.Finite(view.position) or not Shot.Finite(cameraOrigin) or not Shot.Finite(cameraDirection) then return fallback,false end
 local part=view.part local model=part.Parent local record=records[model]
 if not record or not SharedQuery.IsBodyPart(part,model) or record.humanoid.Health<=0 or classify(model)~="target" then return fallback,false end
 local low=math.max(now-History.Window,fallback-History.AlignmentWindow)
 local high=math.min(now,fallback+History.AlignmentWindow)
 local bestTime,bestError=fallback,math.huge
 local frames=record.samples
 local function consider(time)
  if time<low or time>high then return end
  local parts=sample(record,time) local pose=parts and parts[part]
  if not pose then return end
  local error=(pose.cf.Position-view.position).Magnitude
  if error>History.AlignmentError then return end
  if not History.Box(cameraOrigin,cameraDirection,15000,pose.cf,pose.size) then return end
  if error<bestError-.001 or math.abs(error-bestError)<=.001 and math.abs(time-fallback)<math.abs(bestTime-fallback) then bestTime=time bestError=error end
 end
 consider(fallback) consider(low) consider(high)
 for i,frame in frames do
  consider(frame.time)
  local nextFrame=frames[i+1] local a=frame.parts[part] local b=nextFrame and nextFrame.parts[part]
  if a and b then
   local delta=b.cf.Position-a.cf.Position
   if delta.Magnitude>.001 then
    local alpha=math.clamp((view.position-a.cf.Position):Dot(delta)/delta:Dot(delta),0,1)
    consider(frame.time+(nextFrame.time-frame.time)*alpha)
   end
  end
 end
 return bestTime,bestError<math.huge
end
function History.Trace(options,time)
 local origin=options.origin local direction=options.direction.Unit local range=options.range
 local ignored=table.clone(options.ignore or {}) local candidates={}
 for model,record in records do
  if model:IsDescendantOf(workspace) and model~=options.shooter and record.humanoid.Health>0 and options.classify(model)=="target" then
   local parts=sample(record,time) or poses(model)
   if parts then
    table.insert(ignored,model)
    local nearest
    for part,pose in parts do
     local distance,normal=History.Box(origin,direction,range,pose.cf,pose.size,options.radius)
     if distance and (not nearest or distance<nearest.distance) then
      nearest={model=model,distance=distance,hit={Instance=part,Position=origin+direction*distance,Normal=normal,Distance=distance,Material=part.Material}}
     end
    end
    if nearest then table.insert(candidates,nearest) end
   end
  end
 end
 -- Current world geometry always wins; history never rewinds walls/doors.
 local world=Query.Trace({origin=origin,direction=direction,range=range,shooter=options.shooter,ignore=ignored,radius=options.radius,
  classify=function(model) return options.classify(model)=="ignore" and "ignore" or "block" end})
 local obstruction=(world.endpoint-origin).Magnitude
 local currentModel=world.result and Query.ModelFromPart(world.result.Instance)
 if currentModel and options.classify(currentModel)=="target" then
  table.insert(candidates,{model=currentModel,distance=obstruction,hit=world.result})
 end
 table.sort(candidates,function(a,b) return a.distance<b.distance end)
 local hits=0
 for _,candidate in candidates do
  if candidate.distance>obstruction+.001 then break end
  local multiplier=(1-(options.penetrationLoss or 0))^hits
  if options.onHit and not options.onHit(candidate.hit,candidate.model,hits+1,multiplier,candidate.distance) then
   return {endpoint=candidate.hit.Position,hits=hits,reason="protected",result=candidate.hit}
  end
  hits+=1
  if hits>=math.clamp(options.maxTargets or 1,1,8) then return {endpoint=candidate.hit.Position,hits=hits,reason="targets",result=candidate.hit} end
 end
 return {endpoint=world.endpoint,hits=hits,reason=world.reason,result=world.result}
end
return History
