-- Editable procedural action curves shared by FP/TP. Cosmetic; no ammo writes.
local Motion={}
local function smooth(a,b,t) local x=math.clamp((t-a)/(b-a),0,1) return x*x*(3-2*x) end
function Motion.Sample(s)
 local equip=1-smooth(0,.30,math.max(0,s.equippedFor or 1))
 local ads=math.clamp(s.ads or 0,0,1)
 local slide=math.clamp(s.slide or 0,0,1)
 local land=math.clamp(s.land or 0,0,1)
 local air=math.clamp(s.vertical or 0,-35,35)/35
 local fire=math.exp(-math.max(0,s.firedAgo or 100)*30)
 local weapon=CFrame.new(.18*equip,-.6*equip-.18*slide-.12*land,.35*equip)
  *CFrame.Angles(math.rad(-32*equip-12*slide+3*land-2*air),0,math.rad(12*equip-9*slide))
 -- Sight-ready position; a true sight-aligned scope needs a dedicated optical model.
 local ready=CFrame.new(-.34*ads,.20*ads,-.16*ads)*CFrame.Angles(math.rad(-1.5*ads),0,0)
 return {weapon=ready*weapon,slide=CFrame.new(0,0,.16*fire),bolt=CFrame.new(0,0,.12*fire),
  support=Vector3.new(-.04*equip,-.10*equip-.05*land,.14*equip),equip=equip}
end
function Motion.Melee(elapsed,data)
 local windup=data.Windup or .1 local active=data.ActiveTime or .2 local recovery=.12
 if elapsed<0 or elapsed>=windup+active+recovery then return 0 end
 if elapsed<windup then return -.24*smooth(0,math.max(.001,windup),elapsed) end
 if elapsed<windup+active then return -.24+1.24*smooth(0,active,elapsed-windup) end
 return 1-smooth(0,recovery,elapsed-windup-active)
end
return Motion
