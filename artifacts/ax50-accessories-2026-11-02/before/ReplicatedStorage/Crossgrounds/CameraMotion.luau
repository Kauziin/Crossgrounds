-- Cosmetic camera translation/roll only. Does not modify aim direction or recoil.
local Motion={} Motion.__index=Motion
function Motion.new() return setmetatable({phase=0,offset=Vector3.zero,roll=0,pitch=0},Motion) end
function Motion:Reset() self.phase=0 self.offset=Vector3.zero self.roll=0 self.pitch=0 end
function Motion:Update(dt,localVelocity,grounded,sprinting,aiming,amount,turnRate)
 dt=math.clamp(dt,0,.05) amount=math.clamp(amount or 0,0,1)
 local speed=Vector3.new(localVelocity.X,0,localVelocity.Z).Magnitude
 local moving=grounded and speed>.6 local intensity=math.clamp(speed/(sprinting and 25 or 18),0,1)
 if moving then self.phase+=dt*(sprinting and 12 or 8)*math.max(.35,intensity) end
 local weight=moving and amount*intensity*(aiming and .22 or 1) or 0
 local amplitude=sprinting and .19 or .075
 local target=Vector3.new(math.sin(self.phase)*amplitude*.45,math.cos(self.phase*2)*amplitude,0)*weight
 local targetRoll=math.rad(math.clamp(-localVelocity.X/18,-1,1)*(sprinting and 3.8 or 2.2)+math.sin(self.phase)*(sprinting and .85 or .2)-math.clamp(turnRate or 0,-3,3)*.6)*weight
 local targetPitch=math.rad(math.cos(self.phase*2)*(sprinting and .75 or .15))*weight
 local alpha=1-math.exp(-dt*13)
 self.offset=self.offset:Lerp(target,alpha) self.roll+=(targetRoll-self.roll)*alpha self.pitch+=(targetPitch-self.pitch)*alpha
 return self.offset,self.roll,self.pitch
end
return Motion
