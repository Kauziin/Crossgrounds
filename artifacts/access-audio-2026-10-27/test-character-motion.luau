return function(source,preferences)
 local callbacks={} local run={PreAnimation={Connect=function(_,fn) callbacks.restore=fn end},PreSimulation={Connect=function(_,fn) callbacks.step=fn end}}
 local attrs={CrossgroundsMode="arena",ArenaPlaying=true,SettingSimpleAnimations=true}
 local c=Instance.new("Model") local h=Instance.new("Humanoid") h.Parent=c
 local root=Instance.new("Part") root.Name="HumanoidRootPart" root.Parent=c
 local neck=Instance.new("Motor6D") neck.Name="Neck" neck.Transform=CFrame.Angles(.5,.2,.1) neck.Parent=root
 local base=neck.Transform local world=root.CFrame local speed=h.WalkSpeed local hip=h.HipHeight
 local p={Character=c,GetAttribute=function(_,key) return attrs[key] end}
 local players={LocalPlayer=p,GetPlayers=function() return {p} end}
 local motion=require(game.ReplicatedStorage.Crossgrounds.LocomotionMotion)
 local fake={GetService=function(_,name) return name=="Players" and players or run end,ReplicatedStorage={Crossgrounds={MotionPreferences="Preferences",LocomotionMotion="Motion"}}}
 local f=assert(loadstring(source)) setfenv(f,setmetatable({game=fake,require=function(name) return name=="Preferences" and preferences or motion end},{__index=getfenv()})) f()
 local ok,result=xpcall(function()
  callbacks.step(.016)
  local _,angle=neck.Transform:ToAxisAngle() local _,original=base:ToAxisAngle()
  assert(angle<original*.16,"Simple animation attenuates Animator pose")
  callbacks.restore() assert(neck.Transform==base,"PreAnimation restores Animator base without accumulating attenuation")
  attrs.SettingSimpleAnimations=false callbacks.step(.016) assert(neck.Transform==base,"Disabling simple animations restores normal pose")
  callbacks.restore() attrs.SettingSimpleAnimations=true attrs.CrossgroundsMode="get_out" attrs.GetOutPosture="Crawling" callbacks.step(.016)
  assert(neck.Transform==base,"Low Get Out posture remains owned by crawl presentation")
  assert(root.CFrame==world and h.WalkSpeed==speed and h.HipHeight==hip,"Accessibility does not modify physical movement or posture")
  return {"Simple Animator pose","Nonaccumulating animation restore","Normal-animation restoration","Get Out crawl ownership","Physical movement preserved"}
 end,debug.traceback)
 c:Destroy() assert(ok,result) return result
end
