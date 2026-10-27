-- Client presentation state is separate from replicated server attributes.
local Definition=require(game.ReplicatedStorage.ExperienceSettings)
local Profile=require(script.Parent.PreferenceProfile)
local Drafts={} Drafts.__index=Drafts
local scopes={"Global","Mode:ctf","Mode:arena","Device:Keyboard","Device:Gamepad","Device:Touch"}
function Drafts.Path(scope,key) return scope.."|"..key end
function Drafts.new()
 return setmetatable({profile=Profile.New(),revision=-1,sequence=0,drafts={}},Drafts)
end
function Drafts:NextSequence() self.sequence+=1 return self.sequence end
function Drafts:Stage(key,scope,value,inherit,sequence)
 if not Definition:Allows(key,scope) then return end
 local clean
 if not inherit then clean=Definition:Sanitize(key,value) if clean==nil then return end end
 sequence=sequence or self:NextSequence()
 self.drafts[Drafts.Path(scope,key)]={sequence=sequence,value=clean,present=not inherit}
 return sequence,clean
end
function Drafts:Stored(key,scope)
 local draft=self.drafts[Drafts.Path(scope,key)]
 if draft then return draft.value,draft.present end
 local bucket=Profile.Container(self.profile,scope)
 local value=bucket and bucket[key] return value,value~=nil
end
function Drafts:Value(key,scope)
 local value,custom=self:Stored(key,scope)
 if not custom then value=self:Stored(key,"Global") end
 if value==nil then value=Definition.Rules[key].Default end
 return value,custom,scope
end
function Drafts:Apply(snapshot)
 if typeof(snapshot)~="table" or snapshot.version~=1 or typeof(snapshot.revision)~="number" or snapshot.revision~=snapshot.revision or snapshot.revision==math.huge or snapshot.revision%1~=0 or snapshot.revision<0 or snapshot.revision<self.revision or typeof(snapshot.profile)~="table" or typeof(snapshot.acks)~="table" then return false,{} end
 local before={}
 for key in Definition.Rules do for _,scope in scopes do if Definition:Allows(key,scope) then
  local value,custom=self:Stored(key,scope) before[Drafts.Path(scope,key)]={value=value,custom=custom}
 end end end
 self.profile=Profile.Migrate(snapshot.profile) self.revision=snapshot.revision
 for path,sequence in snapshot.acks do
  if typeof(sequence)=="number" and sequence==sequence and sequence>0 and sequence<2147483648 and sequence%1==0 then
   self.sequence=math.max(self.sequence,sequence)
   local draft=self.drafts[path] if draft and sequence>=draft.sequence then self.drafts[path]=nil end
  end
 end
 local changes={}
 for key in Definition.Rules do for _,scope in scopes do if Definition:Allows(key,scope) then
  local old=before[Drafts.Path(scope,key)] local value,custom=self:Stored(key,scope)
  if old.value~=value or old.custom~=custom then changes[key]=true end
 end end end
 return true,changes
end
return Drafts
