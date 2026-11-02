-- Cosmetic carry/run pose. This never changes speed, cooldown or aim direction.
local Motion={} Motion.__index=Motion
function Motion.new() return setmetatable({phase=0,weight=0,side=0},Motion) end
function Motion:Reset() self.phase=0 self.weight=0 self.side=0 end
function Motion:Update(dt,velocity,grounded,sprinting,aiming,firing,amount)
 dt=math.clamp(dt,0,.05) amount=math.clamp(amount or 0,0,1)
 local speed=Vector3.new(velocity.X,0,velocity.Z).Magnitude
 local target=grounded and sprinting and speed>1 and not aiming and not firing and math.clamp(speed/25,0,1) or 0
 local alpha=1-math.exp(-dt*14) self.weight+=(target-self.weight)*alpha
 self.side+=(math.clamp(velocity.X/25,-1,1)-self.side)*alpha
 if speed>.6 and grounded then self.phase+=dt*(sprinting and 7 or 8)*math.clamp(speed/18,.25,1.4) end
 local w=self.weight*math.sqrt(amount) local wave=math.sin(self.phase) local step=math.cos(self.phase*2)
 local offset=Vector3.new(-.16*w+wave*.30*w,-.16*w+step*.075*w,.13*w)
 local rotation=CFrame.Angles(math.rad(-18*w+step*2.5*w),math.rad(10*w),math.rad(-12*w+wave*7*w-self.side*2*amount))
 return CFrame.new(offset)*rotation,w,self.phase
end
return Motion
