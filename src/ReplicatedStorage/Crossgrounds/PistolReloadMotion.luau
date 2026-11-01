-- Cosmetic timelines in normalized server reload time. No ammo/timing writes.
local Motion={}
local profiles={
 m1911={kind='magazine',angle=-17,travel=.86},M1911={kind='magazine',angle=-17,travel=.86},
 x16={kind='magazine',angle=-13,travel=.82},Glock18={kind='magazine',angle=-13,travel=.82},Pistol={kind='magazine',angle=-13,travel=.82},
 m19={kind='magazine',angle=-14,travel=.86},renetti={kind='magazine',angle=-16,travel=.90},Beretta={kind='magazine',angle=-16,travel=.90},
 sykov={kind='magazine',angle=-18,travel=.78},desert_eagle={kind='magazine',angle=-11,travel=1.02},DesertEagle={kind='magazine',angle=-11,travel=1.02},
 magnum_357={kind='revolver'},Magnum={kind='revolver'},Luger={kind='toggle',angle=-15,travel=.87},ArenaPistol={kind='magazine',angle=-17,travel=.86},
}
local function smooth(a,b,t)
 local x=math.clamp((t-a)/(b-a),0,1)
 return x*x*x*(x*(x*6-15)+10)
end
local function pulse(a,b,c,d,t) return smooth(a,b,t)*(1-smooth(c,d,t)) end
function Motion.Profile(id) return profiles[id] end
function Motion.Sample(t,id,empty)
 local profile=profiles[id] if not profile then return nil end
 t=math.clamp(t,0,1)
 local active=pulse(0,.12,.88,1,t)
 local r={weapon=CFrame.identity,magazine=CFrame.identity,cylinder=CFrame.identity,slide=CFrame.identity,toggle=CFrame.identity,
  speedloader=CFrame.identity,breakAction=CFrame.identity,shell=CFrame.identity,tubeShell=CFrame.identity,hand=Vector3.zero,handRotation=CFrame.identity,active=active,
  visibility={Magazine=0,Speedloader=1}}
 if profile.kind=='revolver' then
  local opened=pulse(.10,.24,.79,.91,t)
  local eject=pulse(.26,.34,.39,.45,t)
  local load=pulse(.44,.53,.65,.73,t)
  local align=pulse(.38,.49,.71,.84,t)
  r.weapon=CFrame.new(-.08*active,-.08*active,.13*active)*CFrame.Angles(math.rad(12*active),math.rad(-8*active),math.rad(-27*active))
  r.cylinder=CFrame.new(-.31*opened,0,.055*eject)*CFrame.Angles(0,0,math.rad(-64*opened))
  r.speedloader=CFrame.new(-.31*opened,0,.32*(1-load))*CFrame.Angles(0,0,math.rad(-64*opened))
  r.hand=Vector3.new(-.32*opened,.42*align,-.40*align+.22*eject)
  r.handRotation=CFrame.Angles(0,math.rad(16*align),math.rad(-22*opened))
  r.visibility.Speedloader=1-pulse(.43,.49,.66,.73,t)
  return r
 end
 local exchange=pulse(.18,.34,.51,.72,t)
 local reach=pulse(.06,.16,.71,.81,t)
 local seat=pulse(.69,.73,.75,.79,t)
 local rack=empty~=false and pulse(.78,.83,.87,.92,t) or 0
 local rackReach=empty~=false and pulse(.73,.80,.91,.98,t) or 0
 r.weapon=CFrame.new(-.07*active,-.08*active,.13*active)*CFrame.Angles(math.rad(11*active-2*seat),math.rad(-6*active),math.rad(profile.angle*active))
 r.magazine=CFrame.new(-.06*exchange,-profile.travel*exchange+.035*seat,.12*exchange)*CFrame.Angles(math.rad(9*exchange),0,math.rad(-6*exchange))
 r.hand=Vector3.new(-.09*reach+.26*rackReach,-.18*reach-profile.travel*.78*exchange+.55*rackReach,.10*reach+.10*exchange+.04*rackReach)
 r.handRotation=CFrame.Angles(math.rad(-8*reach),0,math.rad(-12*reach))
 r.visibility.Magazine=pulse(.34,.39,.47,.52,t)
 if profile.kind=='toggle' then
  r.toggle=CFrame.new(0,.10*rack,.07*rack)*CFrame.Angles(math.rad(-42*rack),0,0)
 else
  -- Empty reloads retain the open slide until insertion, then release it.
  local locked=empty~=false and pulse(.01,.09,.77,.84,t) or 0
  r.slide=CFrame.new(0,0,.20*locked+.045*rack)
 end
 return r
end
return Motion
