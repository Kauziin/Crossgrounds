local player=game.Players.LocalPlayer
local Definition=require(game.ReplicatedStorage.ExperienceSettings)
local Drafts=require(game.ReplicatedStorage.Crossgrounds.PreferenceDrafts)
local state=player:WaitForChild("PlayerGui"):WaitForChild("PreferenceState")
local remote=game.ReplicatedStorage.Events:WaitForChild("UpdateExperienceSetting")
local Gui=game:GetService("GuiService")
local Client={} local changed=Instance.new("BindableEvent") Client.Changed=changed.Event
local ledger=Drafts.new() local effective={} local notified={}
local queued=false local pending={} local flights={} local flushScheduled=false local retryScheduled=false
local function sendEdits()
 if flushScheduled then return end flushScheduled=true
 task.delay(.08,function()
  flushScheduled=false local sent=0
  for path,request in pending do
   pending[path]=nil remote:FireServer("PreferenceEdit",request) sent+=1
   if flights[path] then flights[path].sent=os.clock() end
   if sent>=3 then break end
  end
  if next(pending) then sendEdits() end
 end)
end
local function retryEdits()
 if retryScheduled then return end retryScheduled=true
 task.delay(1,function()
  retryScheduled=false if not state.Parent then return end
  for path,flight in flights do
   local draft=ledger.drafts[path]
   if not draft or draft.sequence~=flight.request.sequence then flights[path]=nil
   elseif os.clock()-flight.sent>=.9 then pending[path]=flight.request end
  end
  if next(pending) then sendEdits() end
  if next(flights) then retryEdits() end
 end)
end
function Client:Context(key,scope)
 local rule=Definition.Rules[key] return rule.PreferenceDevice and "Device:"..rule.PreferenceDevice or scope or "Global"
end
function Client:Value(key,scope) return ledger:Value(key,self:Context(key,scope)) end
function Client:Refresh()
 local mode=player:GetAttribute("CrossgroundsMode") or "hub" local changes=notified notified={}
 local _,explicit=ledger:Stored("ReducedMenuMotion","Global")
 for key,rule in Definition.Rules do
  local scope=rule.PreferenceDevice and "Device:"..rule.PreferenceDevice or rule.ModeOverride and (mode=="ctf" or mode=="arena") and "Mode:"..mode or "Global"
  local value=self:Value(key,scope)
  if key=="ReducedMenuMotion" and not explicit then local ok,native=pcall(function() return Gui.ReducedMotionEnabled end) if ok and native then value=true end end
  if effective[key]~=value then changes[key]=true effective[key]=value end
  if player:GetAttribute("Setting"..key)~=value then player:SetAttribute("Setting"..key,value) end
 end
 if next(changes) then changed:Fire(changes) end
end
local function schedule(key)
 if key then notified[key]=true end
 if queued then return end queued=true task.defer(function() queued=false if state.Parent then Client:Refresh() end end)
end
local function snapshot()
 local encoded=state:GetAttribute("Snapshot") if typeof(encoded)~="string" then return end
 local ok,data=pcall(function() return game.HttpService:JSONDecode(encoded) end) if not ok then return end
 local accepted,changes=ledger:Apply(data) if accepted then
  for key in changes do notified[key]=true end
  for path,flight in flights do local draft=ledger.drafts[path] if not draft or draft.sequence~=flight.request.sequence then flights[path]=nil end end
  schedule()
 end
end
function Client:Edit(key,scope,value,op)
 if not Definition.Rules[key] then return false end
 if op~=nil and op~="set" and op~="default" and op~="inherit" then return false end
 scope=self:Context(key,scope) if not Definition:Allows(key,scope) then return false end
 if op=="default" then value=Definition.Rules[key].Default end
 local sequence,clean=ledger:Stage(key,scope,value,op=="inherit") if not sequence then return false end
 local path=Drafts.Path(scope,key)
 local request={scope=scope,key=key,op=op or "set",value=clean,sequence=sequence}
 pending[path]=request flights[path]={request=request,sent=os.clock()}
 sendEdits() retryEdits() schedule(key) return true
end
function Client:Reset(scope,category,inherit)
 local sequence=ledger:NextSequence()
 for key,rule in Definition.Rules do if (category=="All" or rule.Category==category) and Definition:Allows(key,scope) then
  local path=Drafts.Path(scope,key) pending[path]=nil
  local _,clean=ledger:Stage(key,scope,rule.Default,inherit==true,sequence) notified[key]=true
  flights[path]={request={scope=scope,key=key,op=inherit and "inherit" or "default",value=clean,sequence=sequence},sent=os.clock()}
 end end
 remote:FireServer("PreferenceReset",{scope=scope,category=category,inherit=inherit==true,sequence=sequence}) retryEdits() schedule()
end
state:GetAttributeChangedSignal("Snapshot"):Connect(snapshot)
-- Keep legacy Setting* consumers current even when an older attribute echo arrives.
player.AttributeChanged:Connect(function(name)
 local key=name:match("^Setting(.+)$")
 local rule=key and Definition.Rules[key]
 if not rule then return end
 -- The existing remapper and touch editor also preview Setting* directly.
 -- Leave those previews intact until their legacy request updates Snapshot.
 if (rule.Device or rule.MobileLayout) and not ledger.drafts[Drafts.Path(Client:Context(key),key)] then return end
 if effective[key]~=nil and player:GetAttribute(name)~=effective[key] then schedule() end
end)
player:GetAttributeChangedSignal("CrossgroundsMode"):Connect(function() schedule() end)
pcall(function() Gui:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function() schedule("ReducedMenuMotion") end) end)
snapshot() Client:Refresh()
return Client
