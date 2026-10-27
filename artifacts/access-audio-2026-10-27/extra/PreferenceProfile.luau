local Definition=require(game.ReplicatedStorage.ExperienceSettings)
local Profile={}
function Profile.New() return {Version=2,Global={},Modes={ctf={},arena={}},Devices={Keyboard={},Gamepad={},Touch={}}} end
function Profile.Container(profile,scope)
 if scope=="Global" then return profile.Global end
 local kind,id=scope:match("^(%w+):(%w+)$")
 if kind=="Mode" then return typeof(profile.Modes)=="table" and profile.Modes[id] elseif kind=="Device" then return typeof(profile.Devices)=="table" and profile.Devices[id] end
end
function Profile.Resolve(profile,key,mode)
 local rule=Definition.Rules[key] if not rule then return end
 local value=profile.Global[key] local source=value~=nil and "Global" or "Default"
 if value==nil then value=rule.Default end
 if rule.ModeOverride and profile.Modes[mode] and profile.Modes[mode][key]~=nil then value=profile.Modes[mode][key] source="Mode:"..mode end
 if rule.PreferenceDevice and profile.Devices[rule.PreferenceDevice][key]~=nil then value=profile.Devices[rule.PreferenceDevice][key] source="Device:"..rule.PreferenceDevice end
 return value,source
end
function Profile.Set(profile,scope,key,value,inherit)
 if not Definition:Allows(key,scope) then return false end
 local container=Profile.Container(profile,scope) if not container then return false end
 if inherit then container[key]=nil return true end
 local clean=Definition:Sanitize(key,value) if clean==nil then return false end
 container[key]=clean return true
end
function Profile.Migrate(saved)
 local profile=Profile.New() if typeof(saved)~="table" then return profile end
 if saved.Version==nil then
  for key,value in saved do local rule=Definition.Rules[key] if rule then Profile.Set(profile,rule.PreferenceDevice and "Device:"..rule.PreferenceDevice or "Global",key,value) end end
 else
  for _,scope in {"Global","Mode:ctf","Mode:arena","Device:Keyboard","Device:Gamepad","Device:Touch"} do
   local container=Profile.Container(saved,scope)
   if typeof(container)=="table" then local count=0 for key,value in container do count+=1 if count>256 then break end if typeof(key)=="string" then Profile.Set(profile,scope,key,value) end end end
  end
 end
 return profile
end
return Profile

