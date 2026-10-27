return function(source,motion)
 local character=Instance.new("Model") local tool=Instance.new("Tool") tool:SetAttribute("WeaponId","ArenaPistol") tool:SetAttribute("WeaponKind","Gun")
 local handle=Instance.new("Part") handle.Name="Handle" handle.Parent=tool
 for _,name in {"RightHandGrip","SupportGrip","Muzzle"} do local a=Instance.new("Attachment") a.Name=name a.Position=Vector3.new(.1,0,-.2) a.Parent=handle end
 local mag=Instance.new("Part") mag.Name="Magazine" mag:SetAttribute("ReloadGroup","Magazine") mag.Parent=tool
 local attrs={} local p={Character=character,PlayerGui=game:GetService("CoreGui"),GetAttribute=function(_,k) return attrs[k] end,SetAttribute=function(_,k,v) attrs[k]=v end}
 local lighting=game.Lighting local actual=game
 local fake={Players={LocalPlayer=p},ReplicatedStorage={Crossgrounds={MotionPreferences="Motion",WeaponReloadMotion="Reload"}},Lighting=lighting}
 local world={Raycast=function() return nil end,GetServerTimeNow=function() return 100 end}
 local reload=require(actual.ReplicatedStorage.Crossgrounds.WeaponReloadMotion)
 local probe={Sample=function() return Color3.new(.5,.5,.5),Color3.new(1,1,1),Vector3.new(0,-1,0) end}
 local fn=assert(loadstring(source)) setfenv(fn,setmetatable({game=fake,workspace=world,script={Parent={WaitForChild=function() return "Probe" end}},require=function(key) return key=="Motion" and motion or key=="Reload" and reload or probe end},{__index=getfenv()}))
 local renderer=fn().new(tool)
 local ok,result=xpcall(function()
  local camera=Instance.new("Camera") camera.FieldOfView=90 camera.CFrame=CFrame.new()
  local action={weapon=CFrame.new(.3,.2,.1)*CFrame.Angles(.2,.1,.3),slide=CFrame.new(0,0,.1),support=Vector3.new(.2,.1,0)}
  local params={runPose=CFrame.new(.1,.1,0),recoil=.2,pitch=2,roll=3,arc=.3,action=action,runWeight=.8}
  renderer:Render(.02,camera,character,params)
  local animated=renderer.handle.CFrame
  attrs.SettingWeaponAnimationIntensity=0 renderer:Render(.02,camera,character,params)
  local neutral=renderer.handle.CFrame
  assert((neutral.Position-Vector3.new(.55,-.98,-1.7)).Magnitude<1e-5,"Zero intensity leaves stable base pose")
  assert((animated.Position-neutral.Position).Magnitude>.1,"Normal intensity animates the weapon")
  attrs.SettingWeaponFOVScale=.75 renderer:Render(.02,camera,character,params) local less=renderer.camera.FieldOfView
  attrs.SettingWeaponFOVScale=1.25 renderer:Render(.02,camera,character,params) local more=renderer.camera.FieldOfView
  assert(less<70 and more>70 and camera.FieldOfView==90,"Weapon perspective does not alter world FOV")
  tool:SetAttribute("Reloading",true) tool:SetAttribute("ReloadStartedAt",99.5) tool:SetAttribute("ReloadDuration",1)
  renderer:Render(.02,camera,character,params)
  assert(renderer.Model.Magazine.CFrame==renderer.handle.CFrame,"Zero intensity also suppresses magazine motion")
  assert(renderer:ShotOrigin(camera)~=nil,"Shot projection still resolves with changed weapon FOV")
  camera:Destroy()
  return {"Stable zero-intensity weapon pose","Normal weapon motion preserved","Independent weapon-camera FOV","Reload cosmetic motion suppressed at zero","Shot origin remains projected"}
 end,debug.traceback)
 renderer:Destroy() character:Destroy() tool:Destroy() assert(ok,result) return result
end
