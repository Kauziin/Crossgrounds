-- Cosmetic weapon-only spring, independent from camera orientation and shot direction.
local Recoil={} Recoil.__index=Recoil
function Recoil.new() return setmetatable({push=0,pitch=0,roll=0,pushV=0,pitchV=0,rollV=0},Recoil) end
function Recoil:Reset() self.push=0 self.pitch=0 self.roll=0 self.pushV=0 self.pitchV=0 self.rollV=0 end
function Recoil:Kick(profile,side)
 self.pushV=math.min(self.pushV+(profile.Push or .1)*18,28)
 self.pitchV=math.min(self.pitchV+(profile.Pitch or 2)*18,220)
 self.rollV=math.clamp(self.rollV+(side or 1)*(profile.Roll or .4)*15,-40,40)
end
function Recoil:Update(dt,profile)
 local time=math.clamp(dt,0,.1) local spring=profile.Spring or 200 local damping=profile.Damping or 27
 while time>0 do
  local step=math.min(time,1/120) time-=step
  self.pushV+=(-spring*self.push-damping*self.pushV)*step
  self.pitchV+=(-spring*self.pitch-damping*self.pitchV)*step
  self.rollV+=(-spring*self.roll-damping*self.rollV)*step
  self.push=math.clamp(self.push+self.pushV*step,0,1)
  self.pitch=math.clamp(self.pitch+self.pitchV*step,0,10)
  self.roll=math.clamp(self.roll+self.rollV*step,-4,4)
 end
 return self.push,self.pitch,self.roll
end
return Recoil
