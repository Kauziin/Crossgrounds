-- AX-50 presentation prototype. No ammo, damage or fire-rate writes.
local Motion={}
Motion.Recoil={Push=.50,Pitch=4.1,Roll=.48,Spring=155,Damping=20}
local function smooth(a,b,t)
 local x=math.clamp((t-a)/(b-a),0,1) return x*x*(3-2*x)
end
function Motion.Bolt(elapsed,cooldown,reloading)
 local t=elapsed/math.clamp(cooldown or 1.5,.65,3)
 if reloading or t<0 or t>=.94 then return {active=0,weapon=CFrame.identity,bolt=CFrame.identity,hand=Vector3.zero} end
 local reach=smooth(.10,.23,t)*(1-smooth(.77,.94,t))
 local lift=smooth(.22,.32,t)*(1-smooth(.69,.79,t))
 local pull=smooth(.32,.46,t)*(1-smooth(.55,.69,t))
 return {active=reach,
  weapon=CFrame.new(.07*reach,-.09*reach,.09*reach)*CFrame.Angles(math.rad(-2*reach),0,math.rad(-7*reach)),
  bolt=CFrame.new(0,0,.43*pull)*CFrame.Angles(0,0,math.rad(-48*lift)),
  hand=Vector3.new(.20*reach,.40*reach+.12*lift,-.45*reach+.43*pull)}
end
function Motion.new()
 local self={position=Vector2.zero,velocity=Vector2.zero}
 function self:Reset() self.position=Vector2.zero self.velocity=Vector2.zero end
 function self:Kick(side,ads)
  local scale=ads and .78 or 1
  self.velocity+=Vector2.new((side or 1)*.055,.66)*scale
 end
 function self:Update(dt)
  -- Analytic underdamped spring: same recovery at 30, 60 and 120 FPS.
  local t=math.clamp(dt,0,.25) local decay,frequency=9,12
  local a=self.position local b=(self.velocity+a*decay)/frequency
  local c,s=math.cos(frequency*t),math.sin(frequency*t) local e=math.exp(-decay*t)
  self.position=(a*c+b*s)*e
  self.velocity=((b*frequency-a*decay)*c-(a*frequency+b*decay)*s)*e
  return self.position
 end
 return self
end
return Motion
