return function(source,catalog)
 local signals={} local attrs={CrossgroundsMode="hub",SettingGameSFXVolume=.5,SettingBeastProximityVolume=.35}
 local p={GetAttribute=function(_,k) return attrs[k] end,SetAttribute=function(_,k,v) attrs[k]=v end}
 function p:GetAttributeChangedSignal(k) local b=Instance.new("BindableEvent") signals[k]=b return b.Event end
 local folder=Instance.new("Folder") folder.Name="IsolatedAudioTest"
 local fake={Players={LocalPlayer=p},ReplicatedStorage={Crossgrounds={GameAudioCatalog="Catalog"}},GetService=function(_,n) return n=="SoundService" and folder or {PreloadAsync=function() end} end}
 local f=assert(loadstring(source)) setfenv(f,setmetatable({game=fake,require=function() return catalog end},{__index=getfenv()}))
 local audio=f() task.wait()
 local ok,result=xpcall(function()
  assert(not audio:Play("Eliminated"),"No combat audio in hub")
  attrs.CrossgroundsMode="arena" attrs.ArenaPlaying=false
  assert(audio:Play("Eliminated"),"Elimination remains audible after participation flag clears")
  assert(not audio:Play("Eliminated"),"Duplicate cue is debounced")
  attrs.SettingGameSFXVolume=0 assert(not audio:Play("Respawn"),"Zero event volume mutes cues")
  attrs.CrossgroundsMode="get_out" assert(audio:Play("BeastPulse"),"Proximity has independent volume")
  attrs.SettingBeastProximityVolume=0 signals.SettingBeastProximityVolume:Fire() task.wait()
  for _,v in folder:GetChildren() do if v.Name:find("BeastPulse",1,true) then assert(not v.Playing,"Muting proximity stops its voices") end end
  attrs.SettingGameSFXVolume=.5 attrs.AdminCaptureClean=true assert(not audio:Play("Captured"),"Clean capture suppresses event audio")
  attrs.AdminCaptureClean=false attrs.CrossgroundsMode="hub" signals.CrossgroundsMode:Fire() task.wait()
  for _,v in folder:GetChildren() do assert(not v.Playing,"Mode switch stops outstanding voices") end
  return {"Hub scope gate","Elimination race guard","Cue cooldown","Event volume mute","Independent proximity volume","Immediate proximity mute","Clean capture gate","Mode-switch cleanup"}
 end,debug.traceback)
 audio:StopAll() folder:Destroy() for _,b in signals do b:Destroy() end assert(ok,result) return result
end
