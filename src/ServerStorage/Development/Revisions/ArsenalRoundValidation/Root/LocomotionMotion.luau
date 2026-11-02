-- Locomotor state follows actual grounding/velocity; no fixed airborne timers.
local Motion={} Motion.__index=Motion
function Motion.new() return setmetatable({phase=0,slide=0,air=0,land=0,grounded=nil,minY=0},Motion) end
function Motion:Update(dt,velocity,grounded,sliding)
 dt=math.clamp(dt,0,.05)
 if self.grounded==false and grounded and self.minY< -5 then self.land=math.clamp((-self.minY-5)/45,.1,1) end
 self.grounded=grounded self.minY=grounded and 0 or math.min(self.minY,velocity.Y)
 self.land*=math.exp(-dt*12)
 self.slide+=((sliding and 1 or 0)-self.slide)*(1-math.exp(-dt*18))
 local speed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
 local weight=grounded and not sliding and math.clamp(speed/18,0,1) or 0
 if weight>0 then self.phase+=dt*speed*.48 end
 local side=math.clamp(velocity.X/math.max(speed,1),-1,1)
 local forward=math.clamp(-velocity.Z/math.max(speed,1),-1,1)
 local state=sliding and "Slide" or not grounded and (velocity.Y>1 and "Jump" or "Fall") or self.land>.08 and "Land" or speed>.5 and (forward<-.4 and "Backward" or math.abs(side)>.6 and "Strafe" or "Move") or "Idle"
 return {state=state,phase=self.phase,side=side,forward=forward,weight=weight,slide=self.slide,land=self.land,
  cameraY=-.55*self.slide,weapon=CFrame.new(0,-self.land*.08,0)*CFrame.Angles(math.rad(velocity.Y*.05),0,math.rad(-side*weight*1.8))}
end
return Motion
