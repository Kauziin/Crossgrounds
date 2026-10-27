-- Pure ballot. Eligibility and deadlines are checked by the owning game.
local Ballot={} Ballot.__index=Ballot
function Ballot.new(options)
 local self=setmetatable({options={},votes={}},Ballot)
 for _,option in options do assert(typeof(option.id)=="string" and not self.options[option.id],"Duplicate map ID") self.options[option.id]=true end
 return self
end
function Ballot:Vote(voter,id)
 if not self.options[id] then return false end self.votes[voter]=id return true
end
function Ballot:Remove(voter) self.votes[voter]=nil end
function Ballot:Counts()
 local counts={} for id in self.options do counts[id]=0 end
 for _,id in self.votes do counts[id]+=1 end return counts
end
function Ballot:Winner(previous)
 local counts=self:Counts() local best=-1 local ties={}
 for id,count in counts do if count>best then best=count ties={id} elseif count==best then table.insert(ties,id) end end
 table.sort(ties)
 if #ties>1 then for _,id in ties do if id~=previous then return id end end end
 return ties[1]
end
return Ballot
