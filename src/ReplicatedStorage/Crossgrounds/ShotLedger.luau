-- No remotes or damage here; server-only use of this contract.
local Ledger={} Ledger.__index=Ledger
function Ledger.new() return setmetatable({sequence=0,last={},tokens=32,at=0},Ledger) end
function Ledger:Receive(id,now)
 local elapsed=math.max(0,now-self.at) self.at=now self.tokens=math.min(32,self.tokens+elapsed*20)
 if self.tokens<1 then return false,"rate" end self.tokens-=1
 if typeof(id)~="number" or id%1~=0 or id<=self.sequence or id>self.sequence+128 then return false,"sequence" end
 self.sequence=id return true
end
function Ledger:Ready(key,now,cooldown)
 return now-(self.last[key] or -math.huge)+.05>=cooldown and now-(self.last.any or -math.huge)>=.07
end
function Ledger:Commit(key,now,cooldown)
 self.last[key]=math.max(now,(self.last[key] or -math.huge)+(cooldown or 0)) self.last.any=now
end
return Ledger
