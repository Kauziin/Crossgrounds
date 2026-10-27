local Service={}
local Players=game:GetService("Players")
local Sort=require(game.ReplicatedStorage.Crossgrounds.Standings)
function Service:Start()
 if self.started then return end self.started=true
 local root=game.ReplicatedStorage.Crossgrounds.Remotes
 local event=Instance.new("RemoteEvent") event.Name="Standings" event.Parent=root
 task.spawn(function() while true do
  local groups={arena={},ctf={}}
  for _,p in Players:GetPlayers() do
   local mode=p:GetAttribute("CrossgroundsMode") local group=groups[mode]
   if group and (mode=="arena" or p:GetAttribute("InMatch")) then
    local stats=p:FindFirstChild("leaderstats")
    local function value(name) local v=stats and stats:FindFirstChild(name) return v and v.Value or 0 end
    local kills=mode=="arena" and (p:GetAttribute("ArenaKills") or 0) or value("Kills")
    table.insert(group,{userId=p.UserId,name=p.DisplayName,kills=kills,deaths=mode=="arena" and (p:GetAttribute("ArenaDeaths") or 0) or value("Deaths"),score=mode=="arena" and kills or value("Captures")})
   end
  end
  for _,rows in groups do Sort.Sort(rows) end
  for _,p in Players:GetPlayers() do local mode=p:GetAttribute("CrossgroundsMode") if groups[mode] then event:FireClient(p,{mode=mode,entries=groups[mode]}) end end
  task.wait(1)
 end end)
end
return Service

