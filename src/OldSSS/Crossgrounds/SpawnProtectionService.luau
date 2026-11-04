local Service={}
local Players=game:GetService("Players")
function Service:Break(player,character)
 if player.Character~=character then return end
 local mode=player:GetAttribute("CrossgroundsMode")
 if not (mode=="arena" and player:GetAttribute("ArenaPlaying") or mode=="ctf" and player:GetAttribute("InArena")) then return end
 for _,key in {"SpawnProtectedUntil","ArenaProtectedUntil"} do character:SetAttribute(key,0) end
 for _,name in {"SpawnShield","ArenaShield"} do local f=character:FindFirstChild(name) if f then f:Destroy() end end
end
function Service:Start()
 if self.started then return end self.started=true
 local root=game.ReplicatedStorage.Events
 local remote=root:FindFirstChild("BreakSpawnProtection") or Instance.new("RemoteEvent") remote.Name="BreakSpawnProtection" remote.Parent=root
 remote.OnServerEvent:Connect(function(p,c) if typeof(c)=="Instance" and c==p.Character then self:Break(p,c) end end)
 local elapsed=0
 game:GetService("RunService").Heartbeat:Connect(function(dt)
  elapsed+=dt if elapsed<.2 then return end elapsed=0
  local now=workspace:GetServerTimeNow()
  for _,p in Players:GetPlayers() do local c=p.Character if c then
   for key,name in {SpawnProtectedUntil="SpawnShield",ArenaProtectedUntil="ArenaShield"} do
    local untilTime=c:GetAttribute(key)
    if untilTime and untilTime<=now then local shield=c:FindFirstChild(name) if shield then shield:Destroy() end end
   end
  end end
 end)
end
return Service
