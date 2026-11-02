-- AX-50 presentation prototype. No ammo, damage or fire-rate writes.
local Motion={}
Motion.Config={Duration=1.50,Reach={.55,.80},Unlock={.78,.95},Pull={.96,1.15},Push={1.22,1.38},Lock={1.30,1.43},Return={1.30,1.50},
 Lateral=.20,Depth=.16,Vertical=.035,Pitch=2.2,Yaw=-2.8,Roll=-5.5,ADSScale=.32,
 Markers={{at=.55,name="BoltReach"},{at=.80,name="BoltUnlock",sound="Seat"},{at=.98,name="BoltPull",sound="BoltBack"},{at=1.13,name="CasingEject"},{at=1.28,name="BoltPushLock",sound="BoltForward"},{at=1.48,name="BoltReturn"}}}
Motion.Recoil={Push=.50,Pitch=4.1,Roll=.48,Spring=155,Damping=20}
local function smooth(a,b,t)
 local x=math.clamp((t-a)/(b-a),0,1) return x*x*(3-2*x)
end
function Motion.Bolt(elapsed,cooldown,reloading)
 local c=Motion.Config local t=elapsed/Motion.TimeScale(cooldown)
 if reloading or t<0 or t>=c.Duration then return {active=0,weapon=CFrame.identity,bolt=CFrame.identity,hand=Vector3.zero} end
 local reach=smooth(c.Reach[1],c.Reach[2],t)*(1-smooth(c.Return[1],c.Return[2],t))
 local lift=smooth(c.Unlock[1],c.Unlock[2],t)*(1-smooth(c.Lock[1],c.Lock[2],t))
 local pull=smooth(c.Pull[1],c.Pull[2],t)*(1-smooth(c.Push[1],c.Push[2],t))
 return {active=reach,
  weapon=CFrame.new(.07*reach,-.09*reach,.09*reach)*CFrame.Angles(math.rad(-2*reach),0,math.rad(-7*reach)),
  bolt=CFrame.new(0,0,.43*pull)*CFrame.Angles(0,0,math.rad(-48*lift)),
  hand=Vector3.new(.20*reach,.40*reach+.12*lift,-.45*reach+.43*pull)}
end
function Motion.TimeScale(cooldown) return math.clamp((cooldown or Motion.Config.Duration)/Motion.Config.Duration,.3,1) end
local keys={{0,0},{.035,.70},{.10,1},{.18,.85},{.30,.45},{.45,.15},{.58,0},{.64,-.035},{.72,0}}
Motion.Config.KickKeys=keys
function Motion.Kick(elapsed,ads,strength)
 if elapsed<0 or elapsed>=keys[#keys][1] then return CFrame.identity end
 local w=0
 for i=2,#keys do if elapsed<=keys[i][1] then local a,b=keys[i-1],keys[i] w=a[2]+(b[2]-a[2])*smooth(a[1],b[1],elapsed) break end end
 local c=Motion.Config local scale=(1-(ads or 0)*(1-c.ADSScale))*(strength or 1)
 local bob=math.sin(elapsed*45)*math.exp(-elapsed*8)*w
 return CFrame.new(c.Lateral*w*scale,(c.Vertical*w+.018*bob)*scale,c.Depth*w*scale)*CFrame.Angles(math.rad(c.Pitch*w*scale),math.rad(c.Yaw*w*scale),math.rad((c.Roll*w+1.3*bob)*scale))
end
function Motion.Events(previous,current,cooldown)
 local events={} local scale=Motion.TimeScale(cooldown)
 for _,event in Motion.Config.Markers do if event.at*scale>previous and event.at*scale<=current then table.insert(events,event) end end return events
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
