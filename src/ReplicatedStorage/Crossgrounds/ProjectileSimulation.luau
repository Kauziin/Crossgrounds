-- Logical projectile only. Caller owns scheduling and cosmetic representation.
local Query=require(script.Parent.ShotQuery)
local Sim={} Sim.__index=Sim
function Sim.new(options)
 return setmetatable({options=options,position=options.origin,velocity=options.direction.Unit*options.speed,
  age=0,distance=0,hits=0,ignored=table.clone(options.ignore or {}),active=true},Sim)
end
function Sim:Cancel(reason) self.active=false self.reason=reason or "cancelled" end
function Sim:Step(dt)
 if not self.active or dt<=0 or dt~=dt or dt==math.huge then return end
 local o=self.options local remaining=math.min(dt,o.lifetime-self.age)
 -- Bounded curvature error; no elapsed time is thrown away at low FPS.
 while self.active and remaining>1e-7 do
  local h=math.min(remaining,1/120) remaining-=h
  local acceleration=o.acceleration or Vector3.zero
  local delta=self.velocity*h+acceleration*(h*h*.5)
  local length=math.min(delta.Magnitude,o.range-self.distance)
  if length>1e-7 then
   local result=Query.Trace({origin=self.position,direction=delta,range=length,shooter=o.shooter,ignore=self.ignored,
    radius=o.radius,initial=self.age==0,raycast=o.raycast,spherecast=o.spherecast,classify=o.classify,maxTargets=o.maxTargets,
    hitOffset=self.hits,distanceOffset=self.distance,penetrationLoss=o.penetrationLoss,
    onHit=function(hit,model,index,multiplier,distance)
     local accepted=not o.onHit or o.onHit(hit,model,index,multiplier,distance)
     if accepted then table.insert(self.ignored,model) end return accepted
    end})
   self.distance+=(result.endpoint-self.position).Magnitude self.position=result.endpoint self.hits=result.hits
   if result.reason~="range" then self.result=result self:Cancel(result.reason) end
  end
  self.velocity+=acceleration*h self.age+=h
  if self.distance>=o.range-1e-6 then self:Cancel("range") end
  if self.age>=o.lifetime-1e-7 then self:Cancel("lifetime") end
 end
 return self.result
end
return Sim
