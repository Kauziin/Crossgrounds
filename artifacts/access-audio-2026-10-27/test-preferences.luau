return function(sources,profileSource)
 local results={}
 local function check(ok,message) assert(ok,message) table.insert(results,message) end
 local function run(source,env) local f=assert(loadstring(source)) if env then setfenv(f,setmetatable(env,{__index=getfenv()})) end return f() end
 local settings=run(sources["ReplicatedStorage.ExperienceSettings"],{script=game.ReplicatedStorage.ExperienceSettings})
 local profile=run(profileSource,{require=function() return settings end})
 local motion=run(sources["ReplicatedStorage.Crossgrounds.MotionPreferences"])
 local policy=run(sources["ReplicatedStorage.Crossgrounds.AudioEventPolicy"])
 local attrs={} local p={GetAttribute=function(_,k) return attrs[k] end}
 check(motion.CharacterWeight(p)==1 and motion.WeaponWeight(p)==1,"Default cosmetic motion is preserved")
 attrs.SettingSimpleAnimations=true
 check(motion.CharacterWeight(p)==.15 and motion.WeaponWeight(p)==.2,"Simple animations reduce character and weapon motion")
 attrs.SettingWeaponAnimationIntensity=0 check(motion.WeaponWeight(p)==0,"Weapon intensity can disable decorative motion")
 attrs.SettingSimpleAnimations=false attrs.SettingWeaponAnimationIntensity=.5 check(motion.WeaponWeight(p)==.5,"Weapon intensity remains independent")
 check(motion.FOVAlpha(1/60,.15)<motion.FOVAlpha(1/60,1),"Slower FOV preference slows the transition")
 local a=motion.FOVAlpha(1/30,.4) local b=motion.FOVAlpha(1/60,.4)
 check(math.abs(a-(1-(1-b)^2))<1e-8,"FOV smoothing is frame-rate independent")
 for _,fov in {60,70,90,110} do
  local normal,depth=motion.WeaponProjection(fov,1) local less=motion.WeaponProjection(fov,.75) local more=motion.WeaponProjection(fov,1.25)
  check(normal==70 and depth==1 and less<normal and more>normal,"Weapon FOV choices preserve normal and order perspective at "..fov)
 end
 local old=profile.Migrate({Version=2,Global={FieldOfView=85},Modes={arena={},ctf={}},Devices={Keyboard={},Gamepad={},Touch={}}})
 for _,key in {"SimpleAnimations","WeaponAnimationIntensity","FOVTransitionSpeed","WeaponFOVScale","GameSFXVolume","BeastProximityVolume"} do
  check(settings:Allows(key,"Global") and profile.Resolve(old,key,"arena")==settings.Rules[key].Default,"Old profiles receive default for "..key)
 end
 check(profile.Set(old,"Global","WeaponFOVScale",1.25) and profile.Resolve(profile.Migrate(old),"WeaponFOVScale","ctf")==1.25,"New camera preference survives profile migration")
 check(not profile.Set(old,"Global","WeaponFOVScale",5),"Invalid weapon FOV choice is rejected")
 check(settings:Sanitize("FOVTransitionSpeed",0)==.15 and settings:Sanitize("GameSFXVolume",5)==1,"New numeric preferences enforce bounds")
 for kind,cue in {pickup="FlagStolen",capture="FlagLost",drop="FlagDropped",["return"]="FlagReturned"} do check(policy.Flag({kind=kind,team="Blue"},"Blue")==cue,"Own flag event maps correctly: "..kind) end
 check(policy.Flag({kind="capture",team="Red"},"Blue")=="FlagCaptured","Enemy flag capture uses success cue")
 local near,fast=policy.Proximity(15) local far,slow=policy.Proximity(70)
 check(near==1 and far==0 and fast<slow,"Beast pulse becomes louder and faster nearby")
 check(policy.Proximity(200)==0,"Distant beast stays silent")
 local initial={roundId=1,state="playing",computers=0,gameplay={victim="Active"},result="active"}
 check(#policy.GetOut(nil,initial)==0,"Initial snapshot does not replay old events")
 local next={roundId=1,state="enraged",computers=1,gameplay={victim="Captured"},result="active"}
 local cues=policy.GetOut(initial,next)
 check(table.find(cues,"BeastEnraged") and table.find(cues,"ComputerComplete") and table.find(cues,"Captured"),"Get Out transitions produce event cues")
 check(#policy.GetOut(next,next)==0,"Repeated snapshots do not duplicate cues")
 check(#policy.GetOut(next,{roundId=2,state="playing"})==0,"A new round resets event comparisons")
 return results
end
