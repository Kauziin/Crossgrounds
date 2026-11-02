-- Server policy for current and future paid-feature gates. Never trust client roles.
local Testers=require(game.ReplicatedStorage.Crossgrounds.TesterConfiguration)
local Access={OwnerUserIds={1248190494}}
function Access.IsPrivileged(userId)
 return table.find(Access.OwnerUserIds,userId)~=nil or table.find(Testers.UserIds,userId)~=nil
  or game.CreatorType==Enum.CreatorType.User and userId==game.CreatorId
end
function Access.Allows(player,feature) return player~=nil and Access.IsPrivileged(player.UserId) end
return Access
