-- Rewards originate only from confirmed eliminations on the server.
local Rewards={}
local Progress=require(script.Parent.ProgressionService)
local Policy=require(script.Parent.ProgressionPolicy)
function Rewards.Apply(player,target,headshot)
 local training=target==nil
 local xp=Progress.Kill(player,training and "training" or "arena",headshot)
 local bonus=not training and headshot and Policy.Reward("arena",true).XP-Policy.Reward("arena",false).XP or 0
 if not training then player:SetAttribute("ArenaKills",(player:GetAttribute("ArenaKills") or 0)+1) end
 player:SetAttribute("ArenaSessionXP",(player:GetAttribute("ArenaSessionXP") or 0)+xp)
 return {xp=xp,bonusXP=bonus,sessionXP=player:GetAttribute("ArenaSessionXP"),training=training}
end
return Rewards
