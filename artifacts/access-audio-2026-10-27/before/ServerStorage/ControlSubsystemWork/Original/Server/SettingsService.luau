-- Versioned preferences, using the existing store and update remote.
local Service={}
local Players=game:GetService("Players") local Run=game:GetService("RunService")
local Definition=require(game.ReplicatedStorage.ExperienceSettings) local Controls=require(game.ReplicatedStorage.ControlDefinitions)
local Profile=require(game.ReplicatedStorage.Crossgrounds.PreferenceProfile)
local events=game.ReplicatedStorage.Events local update=events:FindFirstChild("UpdateExperienceSetting") or Instance.new("RemoteEvent",events) update.Name="UpdateExperienceSetting"
local store=game:GetService("DataStoreService"):GetDataStore("CTF_ExperienceSettings_v1")
local profiles,dirty,revisions,rate,states,connections={},{},{},{},{},{}
local acknowledgements={}
local scopes={"Global","Mode:ctf","Mode:arena","Device:Keyboard","Device:Gamepad","Device:Touch"}
local function sync(p)
 local profile=profiles[p] if not profile then return end
 local state=states[p]
 for key,rule in Definition.Rules do
  local value=Profile.Resolve(profile,key,p:GetAttribute("CrossgroundsMode") or "hub")
  p:SetAttribute("Setting"..key,value)
  if state then for _,scope in scopes do if Definition:Allows(key,scope) then state:SetAttribute(Definition:PreferenceAttribute(key,scope),Profile.Container(profile,scope)[key]) end end end
 end
 if state then
  state:SetAttribute("Revision",revisions[p] or 0)
  -- Profile and acknowledgements arrive atomically; separate attribute echoes
  -- cannot roll a newer client draft back to an earlier request.
  state:SetAttribute("Snapshot",game.HttpService:JSONEncode({version=1,revision=revisions[p] or 0,profile=profile,acks=acknowledgements[p] or {}}))
  state:SetAttribute("Ready",true)
 end
end
local function mark(p,scope,key)
 revisions[p]=(revisions[p] or 0)+1 dirty[p]=dirty[p] or {} dirty[p][scope.."|"..key]=revisions[p]
end
local function set(p,scope,key,value,inherit)
 local profile=profiles[p] if not profile or not Profile.Set(profile,scope,key,value,inherit) then return false end
 mark(p,scope,key) return true
end
local function save(p)
 if not dirty[p] or not next(dirty[p]) or Run:IsStudio() or p.UserId<=0 then return end
 local captured=Profile.Migrate(profiles[p]) local changes=table.clone(dirty[p]) local newer=false
 local ok=pcall(function() store:UpdateAsync("u"..p.UserId,function(old)
  if typeof(old)=="table" and typeof(old.Version)=="number" and old.Version>Definition.Version then newer=true return nil end
  local merged=Profile.Migrate(old)
  for path in changes do local scope,key=path:match("^(.-)|(.+)$") local value=Profile.Container(captured,scope)[key] Profile.Set(merged,scope,key,value,value==nil) end
  return merged
 end) end)
 if not p.Parent then return end
 p:SetAttribute("SettingsSaveState",newer and "NewerVersion" or ok and "Saved" or "RetryPending")
 if ok and not newer then for path,version in changes do if dirty[p] and dirty[p][path]==version then dirty[p][path]=nil end end end
end
local function added(p)
 profiles[p]=Profile.New() revisions[p]=0 dirty[p]={} acknowledgements[p]={}
 local gui=Instance.new("ScreenGui") gui.Name="PreferenceState" gui.ResetOnSpawn=false gui.Enabled=false gui.Parent=p:WaitForChild("PlayerGui") states[p]=gui
 p:SetAttribute("SettingsPersistence",not Run:IsStudio()) p:SetAttribute("SettingsSaveState",Run:IsStudio() and "StudioSessionOnly" or "Loading") sync(p)
 connections[p]=p:GetAttributeChangedSignal("CrossgroundsMode"):Connect(function() sync(p) end)
 if Run:IsStudio() or p.UserId<=0 then return end
 local ok,data=pcall(function() return store:GetAsync("u"..p.UserId) end)
 if not p.Parent then return end
 if ok then
  local loaded=Profile.Migrate(data)
  for path in dirty[p] or {} do local scope,key=path:match("^(.-)|(.+)$") local value=Profile.Container(profiles[p],scope)[key] Profile.Set(loaded,scope,key,value,value==nil) end
  profiles[p]=loaded p:SetAttribute("SettingsSaveState","Loaded") sync(p)
 else p:SetAttribute("SettingsSaveState","LoadFailed") end
end
update.OnServerEvent:Connect(function(p,key,value)
 if typeof(key)~="string" or not profiles[p] then return end
 local now=os.clock() local budget=rate[p]
 if not budget or now-budget.start>=1 then budget={start=now,count=0} rate[p]=budget end
 budget.count+=1 if budget.count>60 then return end
 if key=="PreferenceEdit" then
  if typeof(value)~="table" then return end local count=0 for _ in value do count+=1 if count>5 then return end end
  local scope,field,op,sequence=value.scope,value.key,value.op,value.sequence
  if typeof(scope)~="string" or typeof(field)~="string" or not Definition:Allows(field,scope) then return end
  if sequence~=nil and (typeof(sequence)~="number" or sequence~=sequence or sequence%1~=0 or sequence<1 or sequence>=2147483648) then return end
  local path=scope.."|"..field
  if sequence and sequence<=(acknowledgements[p][path] or 0) then return end
  if op=="set" then set(p,scope,field,value.value)
  elseif op=="inherit" then set(p,scope,field,nil,true)
  elseif op=="default" then set(p,scope,field,Definition.Rules[field].Default)
  else return end
  if sequence then acknowledgements[p][path]=sequence end
 elseif key=="PreferenceReset" then
  if typeof(value)~="table" or typeof(value.scope)~="string" or typeof(value.category)~="string" then return end
  local count=0 for _ in value do count+=1 if count>4 then return end end
  local sequence=value.sequence
  if sequence~=nil and (typeof(sequence)~="number" or sequence~=sequence or sequence%1~=0 or sequence<1 or sequence>=2147483648) then return end
  for field,rule in Definition.Rules do if (value.category=="All" or rule.Category==value.category) and Definition:Allows(field,value.scope) then
   local path=value.scope.."|"..field
   if not sequence or sequence>(acknowledgements[p][path] or 0) then
    set(p,value.scope,field,rule.Default,value.inherit==true)
    if sequence then acknowledgements[p][path]=sequence end
   end
  end end
 elseif key=="ResetControls" and (value==true or value=="Keyboard" or value=="Gamepad") then
  for action,data in Controls.Actions do for _,device in {"Gamepad","Keyboard"} do if value==true or value==device then set(p,"Device:"..device,Controls:Attribute(action,device),data[device]) end end end
 elseif key=="MobileHUDLayout" then
  if typeof(value)~="table" then return end local clean={} local count,expected=0,0
  for _,rule in Definition.Rules do if rule.MobileLayout then expected+=1 end end
  for field,number in value do
   count+=1 if count>expected or typeof(field)~="string" then return end
   local rule=Definition.Rules[field] if not rule or not rule.MobileLayout then return end
   local valid=Definition:Sanitize(field,number) if valid==nil then return end clean[field]=valid
  end
  if count~=expected then return end for field,number in clean do set(p,"Device:Touch",field,number) end
 else
  local rule=Definition.Rules[key] if not rule then return end
  local clean=Definition:Sanitize(key,value) if clean==nil then return end
  local scope=rule.PreferenceDevice and "Device:"..rule.PreferenceDevice or "Global"
  if rule.Device then
   local container=Profile.Container(profiles[p],scope) local old=container[key] or rule.Default
   for other in Controls.Actions do local otherKey=Controls:Attribute(other,rule.Device)
    if otherKey~=key and Controls:Conflicts(rule.Action,other) and Profile.Resolve(profiles[p],otherKey,"hub")==clean then set(p,scope,otherKey,old) break end
   end
  end
  set(p,scope,key,clean)
 end
 sync(p) p:SetAttribute("SettingsSaveState",Run:IsStudio() and "StudioSessionOnly" or "Pending")
end)
function Service:Snapshot(p) return profiles[p] and Profile.Migrate(profiles[p]) end
Players.PlayerAdded:Connect(function(p) task.spawn(added,p) end)
Players.PlayerRemoving:Connect(function(p)
 save(p) if connections[p] then connections[p]:Disconnect() end
 profiles[p]=nil dirty[p]=nil revisions[p]=nil rate[p]=nil states[p]=nil connections[p]=nil acknowledgements[p]=nil
end)
for _,p in Players:GetPlayers() do task.spawn(added,p) end
task.spawn(function() while true do task.wait(30) for _,p in Players:GetPlayers() do save(p) end end end)
game:BindToClose(function() for _,p in Players:GetPlayers() do save(p) end end)
return Service

