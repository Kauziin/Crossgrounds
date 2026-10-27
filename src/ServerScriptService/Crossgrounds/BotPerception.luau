local Query=require(script.Parent.Ballistics)
local Noise=require(script.Parent.CombatNoise)
local Sensor={} Sensor.__index=Sensor
function Sensor.new(bot,profile,relation,candidates,budget)
 return setmetatable({bot=bot,profile=profile,relation=relation,candidates=candidates,budget=budget,memory={confidence=0},noiseId=0},Sensor)
end
function Sensor.InCone(forward,delta,cosine)
 return delta.Magnitude<.01 or forward:Dot(delta.Unit)>=(cosine or math.cos(math.rad(70)))
end
function Sensor:Scan(now)
 local root=self.bot:FindFirstChild("HumanoidRootPart") if not root then return end
 local origin=root.Position+Vector3.new(0,1.5,0) local memory=self.memory local rows={}
 for _,model in self.candidates() do
  local h=model:FindFirstChildOfClass("Humanoid") local r=model:FindFirstChild("HumanoidRootPart")
  if h and h.Health>0 and r and self.relation(model)=="target" and (model:GetAttribute("SpawnProtectedUntil") or 0)<=workspace:GetServerTimeNow() then
   local delta=r.Position-origin local distance=delta.Magnitude
   if distance<190 and Sensor.InCone(root.CFrame.LookVector,delta) then table.insert(rows,{model=model,part=r,distance=distance,score=distance-(memory.target==model and 22 or 0)}) end
  end
 end
 table.sort(rows,function(a,b) return a.score<b.score end)
 local previouslyVisible=memory.visible memory.visible=false
 for i=1,math.min(3,#rows) do
  if not self.budget() then break end
  local row=rows[i] local position=row.part.Position+Vector3.new(0,.65,0)
  local delta=position-origin
  local result=Query.Trace({origin=origin,direction=delta,range=delta.Magnitude,shooter=self.bot,
   classify=function(model) return self.relation(model)=="ignore" and "ignore" or "block" end})
  if not result.result or result.result.Instance:IsDescendantOf(row.model) then
   local changed=memory.target~=row.model
   memory.velocity=not changed and memory.position and (position-memory.position)/math.max(.05,now-(memory.seenAt or now)) or Vector3.zero
   if memory.velocity.Magnitude>35 then memory.velocity=memory.velocity.Unit*35 end
   memory.target=row.model memory.position=position memory.seenAt=now memory.visible=true memory.confidence=1
   if changed or not previouslyVisible then memory.acquiredAt=now end
   if changed then memory.changes=(memory.changes or 0)+1 end
   break
  end
 end
 if not memory.visible then
  if memory.heardAt and memory.heardAt>(memory.seenAt or -100) and now-memory.heardAt<3 then
   memory.position=memory.heard memory.confidence=.45*(1-(now-memory.heardAt)/3) memory.target=nil
  else
   memory.confidence=math.max(0,1-(now-(memory.seenAt or -100))/self.profile.Memory)
   if memory.confidence==0 then memory.target=nil memory.position=nil memory.velocity=Vector3.zero end
  end
 end
 local events,latest=Noise.Since(self.noiseId,now) self.noiseId=latest
 for _,event in events do
  if event.actor~=self.bot and event.actor and event.actor.Parent and self.relation(event.actor)=="target" and (event.position-origin).Magnitude<event.radius then
   if not memory.visible and now>=(self.nextHear or 0) and self.budget() then
    self.nextHear=now+.5
    local delta=event.position-origin
    local obstruction=Query.Trace({origin=origin,direction=delta,range=delta.Magnitude,shooter=self.bot,classify=function() return "ignore" end}).result
    local audible=not obstruction or delta.Magnitude<event.radius*.45
    if audible then
    -- Quantized area, not a live target reference or exact wallhack position.
    memory.heard=Vector3.new(math.round(event.position.X/8)*8,event.position.Y,math.round(event.position.Z/8)*8)
    memory.heardAt=now memory.position=memory.heard memory.confidence=math.max(memory.confidence,.45)
    end
   end
  end
 end
 if memory.heardAt and now-memory.heardAt>3 and not memory.visible and not memory.target then memory.position=nil memory.heard=nil memory.confidence=0 end
 return memory
end
return Sensor
