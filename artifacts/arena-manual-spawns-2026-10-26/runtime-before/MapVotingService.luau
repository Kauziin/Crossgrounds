local Voting={}
local Players=game:GetService("Players")
local Maps=require(script.Parent.MapManager)
local events=game.ReplicatedStorage.Events
local update=events:FindFirstChild("MapVoteState") or Instance.new("RemoteEvent",events) update.Name="MapVoteState"
local vote=events:FindFirstChild("VoteMap") or Instance.new("RemoteEvent",events) vote.Name="VoteMap"
local snapshot=events:FindFirstChild("GetMapVoteState") or Instance.new("RemoteFunction",events) snapshot.Name="GetMapVoteState"
local active=false local options={} local votes={} local endsAt=0 local winner
function Voting:Snapshot()
 local available=#options>0 and options or Maps:Catalog()
 local counts={} for _,o in available do counts[o.id]=0 end
 for _,id in pairs(votes) do if counts[id] then counts[id]+=1 end end
 return {active=active,options=available,counts=counts,endsAt=endsAt,winner=winner,current=workspace:GetAttribute("CurrentMapId")}
end
local function broadcast() update:FireAllClients(Voting:Snapshot()) end
function Voting:Begin(duration)
 options=Maps:Catalog() while #options>3 do table.remove(options,math.random(#options)) end
 votes={} winner=nil active=true endsAt=workspace:GetServerTimeNow()+duration
 broadcast()
end
function Voting:Finish(cancelled)
 active=false
 if not cancelled then
  local state=self:Snapshot() local best=-1 local ties={}
  for _,o in options do local count=state.counts[o.id] or 0 if count>best then best=count ties={o.id} elseif count==best then table.insert(ties,o.id) end end
  winner=#ties>0 and ties[math.random(#ties)] or "riverside"
 end
 broadcast() return winner
end
vote.OnServerEvent:Connect(function(player,id)
 if (player:GetAttribute("CrossgroundsMode") and player:GetAttribute("CrossgroundsMode")~="ctf") or player:GetAttribute("CrossgroundsTransition") then return end
 if not active or typeof(id)~="string" or workspace:GetServerTimeNow()>endsAt then return end
 local found=false for _,o in options do if o.id==id then found=true break end end
 if found then votes[player]=id broadcast() end
end)
function Voting:RemovePlayer(p) votes[p]=nil if active then broadcast() end end
Players.PlayerRemoving:Connect(function(p) Voting:RemovePlayer(p) end)
snapshot.OnServerInvoke=function() return Voting:Snapshot() end
return Voting
