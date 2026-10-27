-- Effective camera rules; preferences remain available when returning to CTF/melee.
local Policy={}
function Policy.Resolve(mode,kind,preferredLock,preferredFirst)
 return mode=="arena" or kind=="Gun" or preferredLock,mode=="arena" or preferredFirst
end
return Policy
