local Policy={}
local Balance=require(script.Parent.ProgressionBalance)
function Policy.Reward(kind,headshot)
 if kind=="training" then return {XP=Balance.Get("TrainingKillXP"),TrainingKills=1} end
 if kind=="bot" then return {XP=Balance.Get("BotKillXP"),Coins=Balance.Get("CTFKillCoins"),Kills=1,BotKills=1} end
 if kind=="arena" then return {XP=Balance.Get("ArenaKillXP")+(headshot and Balance.Get("ArenaHeadshotXP") or 0),Coins=Balance.Get("ArenaKillCoins"),Kills=1} end
 assert(kind=="ctf","Unknown kill kind")
 return {XP=Balance.Get("CTFKillXP"),Coins=Balance.Get("CTFKillCoins"),Kills=1}
end
function Policy.HasPlayed(saved)
 if type(saved)~="table" then return false end
 if saved.HasPlayed==true then return true end
 -- A real legacy progress record may legitimately contain only zeros.
 for _,key in {"XP","Coins","Kills","Deaths","Captures","PlaySeconds"} do
  local value=saved[key]
  if type(value)=="number" and value==value and value>=0 then return true end
 end
 return false
end
function Policy.CollectFriends(candidates,resolve,limit)
 local matches={}
 for _,friend in candidates do
  local data=resolve(friend.Id)
  if Policy.HasPlayed(data) then table.insert(matches,{friend=friend,data=data}) end
  if #matches>=(limit or 8) then break end
 end
 return matches
end
return Policy
