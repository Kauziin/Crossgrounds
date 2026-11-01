local Motion={}
local Pistols=require(script.Parent.PistolReloadMotion)
local function smooth(a,b,t) local x=math.clamp((t-a)/(b-a),0,1) return x*x*(3-2*x) end
function Motion.Sample(t,visual,empty)
 local pistol=Pistols.Sample(t,visual,empty) if pistol then return pistol end
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
function Motion.PartTransform(sample,group,pivot)
 local cf=group=='Magazine' and sample.magazine or group=='Cylinder' and sample.cylinder or group=='Slide' and sample.slide
  or group=='Toggle' and sample.toggle or group=='Speedloader' and (sample.speedloader or CFrame.identity)
  or group=='BreakAction' and sample.breakAction or group=='Shell' and sample.breakAction*sample.shell or group=='TubeShell' and sample.tubeShell or CFrame.identity
 if pivot and (group=='Cylinder' or group=='Toggle' or group=='Speedloader') then return CFrame.new(pivot)*cf*CFrame.new(-pivot) end
 return cf
end
local function blend(a,b,alpha)
 local result={}
 for key,value in b do
  if typeof(value)=='CFrame' then result[key]=(a[key] or CFrame.identity):Lerp(value,alpha)
  elseif typeof(value)=='Vector3' then result[key]=(a[key] or Vector3.zero):Lerp(value,alpha)
  elseif typeof(value)=='number' then result[key]=(a[key] or 0)+(value-(a[key] or 0))*alpha
  elseif key=='visibility' then
   result[key]={} for group,v in value do local old=a.visibility and a.visibility[group] or (group=='Speedloader' and 1 or 0) result[key][group]=old+(v-old)*alpha end
  else result[key]=value end
 end
 return result
end
function Motion.new()
 local self={}
 function self:Update(tool,dt,now)
  local id=tool:GetAttribute('CosmeticId') or tool:GetAttribute('WeaponId')
  local running=tool:GetAttribute('Reloading')==true
  local started=tool:GetAttribute('ReloadStartedAt') or now
  local duration=math.max(.05,tool:GetAttribute('ReloadDuration') or 1)
  local t=running and math.clamp((now-started)/duration,0,1) or 0
  local sample=Motion.Sample(t,id,tool:GetAttribute('ReloadWasEmpty'))
  if Pistols.Profile(id) then
   if not running and self.running and self.last and (self.progress or 1)<.999 then self.returnFrom=self.last self.returnTime=0 end
   if running then self.returnFrom=nil end
   if self.returnFrom then
    self.returnTime+=math.max(0,dt) local x=math.clamp(self.returnTime/.14,0,1) local a=x*x*x*(x*(x*6-15)+10)
    sample=blend(self.returnFrom,sample,a) if x>=1 then self.returnFrom=nil end
   end
  end
  self.running=running self.progress=t self.last=sample return sample
 end
 return self
end
return Motion
