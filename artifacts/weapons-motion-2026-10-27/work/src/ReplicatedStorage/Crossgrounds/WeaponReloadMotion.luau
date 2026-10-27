local Motion={}
local function smooth(a,b,t) local x=math.clamp((t-a)/(b-a),0,1) return x*x*(3-2*x) end
function Motion.Sample(t,visual)
 t=math.clamp(t,0,1)
 local out=smooth(.05,.28,t)*(1-smooth(.62,.85,t))
 local rack=smooth(.78,.86,t)*(1-smooth(.88,1,t))
 local tilt=math.sin(t*math.pi)
 local revolver=visual=="Magnum"
 local double=visual=="Shotgun725" local tube=visual=="SPAS12"
 local opened=double and smooth(.08,.24,t)*(1-smooth(.76,.94,t)) or 0
 local insert=tube and smooth(.12,.22,t)*(1-smooth(.68,.80,t)) or 0
 local feed=tube and math.sin(math.clamp((t-.2)/.48,0,1)*math.pi*4)^2*insert or 0
 local shell=double and smooth(.22,.42,t)*(1-smooth(.55,.72,t)) or 0
 return {
  weapon=CFrame.new(-.12*tilt,-.12*tilt,.18*tilt)*CFrame.Angles(math.rad(18*tilt),math.rad(-10*tilt),math.rad(-25*tilt)),
  magazine=CFrame.new(0,-.85*out,.12*out),
  cylinder=CFrame.new(-.42*out,0,0)*CFrame.Angles(0,0,t*math.pi*4*out),
  slide=CFrame.new(0,0,.22*rack),
  toggle=CFrame.new(0,.15*rack,.08*rack)*CFrame.Angles(math.rad(-35*rack),0,0),
  breakAction=CFrame.new(0,.32,-.65)*CFrame.Angles(math.rad(-34*opened),0,0)*CFrame.new(0,-.32,.65),
  shell=CFrame.new(0,.15*shell,.65*shell),
  tubeShell=CFrame.new(.28*insert,-.25*insert,.22*feed),
  hand=(double or tube) and Vector3.new(-.20*tilt,-.35*tilt,.65*tilt+.15*feed) or Vector3.new(revolver and -.42*out or -.10*out,-.6*out,.18*out),
  active=tilt,
 }
end
return Motion
