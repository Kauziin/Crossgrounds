local Damage=require(game.ServerScriptService.MainGameScript.GameManager.DamageService)
local Adapter={} Adapter.__index=Adapter
local lanes={-1,1,0,-1,1,0}
local function spacing()
 local arena=workspace:FindFirstChild("CTFInfrastructure")
 return arena and arena:GetAttribute("LaneSpacing") or 70
end
function Adapter.new(bot,team,slot,flags) return setmetatable({bot=bot,team=team,slot=slot,flags=flags,lane=(lanes[slot] or 0)*spacing()},Adapter) end
function Adapter.Cross(position,target,lane)
 local arena=workspace:FindFirstChild("CTFInfrastructure")
 local routes=arena and arena:FindFirstChild("BotRoutes")
 if routes then
  if math.abs(position.X-target.X)>80 then
  local route=routes:FindFirstChild(lane<0 and "North" or lane>0 and "South" or "Center")
  if route then
   local points=route:GetChildren() local direction=target.X>position.X and 1 or -1
   table.sort(points,function(a,b)return a.Position.X*direction<b.Position.X*direction end)
   for _,point in points do
    if (point.Position.X-position.X)*direction>12 and (target.X-point.Position.X)*direction>12 then return point.Position end
   end
  end
  end
  return target
 end
 if position.X<-36 and target.X>36 then return Vector3.new(-32,41,lane) end
 if position.X>36 and target.X<-36 then return Vector3.new(32,41,lane) end
 if position.X<36 and position.X>=-36 and target.X>36 then return Vector3.new(42,41,lane) end
 if position.X>-36 and position.X<=36 and target.X<-36 then return Vector3.new(-42,41,lane) end
 return target
end
function Adapter:Candidates()
 local result={}
 for _,player in game.Players:GetPlayers() do if player:GetAttribute("InArena") and player.Team~=self.team and player.Character then table.insert(result,player.Character) end end
 local bots=workspace:FindFirstChild("CTFBots")
 if bots then for _,bot in bots:GetChildren() do local team=bot:GetAttribute("CTFTeam") if bot~=self.bot and typeof(team)=="string" and team~=self.team.Name then table.insert(result,bot) end end end
 return result
end
function Adapter:Objective(memory,now)
 local own=self.flags:GetFlag(self.team.Name) local other=self.flags:GetFlag(self.team.Name=="Blue" and "Red" or "Blue")
 if not own or not other then return end
 local root=self.bot.HumanoidRootPart local sign=self.team.Name=="Blue" and -1 or 1
 local position,label,critical
 if other.carrier==self.bot then position=own.home label="Returning" critical=true
 elseif own.state=="dropped" then position=own.hitbox.Position label="Recovering" critical=true
 elseif own.carrier and memory.target==own.carrier and memory.position then position=memory.position label="Intercepting"
 elseif other.carrier and other.carrier~=self.bot and Damage:Team(other.carrier)==self.team then
  local r=other.carrier:FindFirstChild("HumanoidRootPart") if r then position=r.Position+Vector3.new(-sign*10,0,self.slot%2==0 and 7 or -7) label="Escorting" end
 elseif self.bot:GetAttribute("CTFRole")=="Guardian" then
  position=own.home+Vector3.new(-sign*22,0,self.lane*.45) label="Guarding"
 else position=other.hitbox.Position label="Capturing" end
 if not position then position=own.home label="Guarding" end
 if label=="Guarding" then position+=Vector3.new(math.sin(now*.22+self.slot)*6,0,math.cos(now*.22+self.slot)*7) end
 return {position=Adapter.Cross(root.Position,position,self.lane),label=label,critical=critical}
end
function Adapter:Cover(threat)
 local infrastructure=workspace:FindFirstChild("CTFInfrastructure") local covers=infrastructure and infrastructure:FindFirstChild("TacticalCover")
 if not covers or not threat then return end
 local root=self.bot.HumanoidRootPart local best,score
 local params=RaycastParams.new() params.FilterDescendantsInstances={self.bot} params.RespectCanCollide=true
 for _,model in covers:GetChildren() do
  local node=model:FindFirstChild("CoverNode")
  if node then
   local distance=(node.Position-root.Position).Magnitude
   if distance<55 then
    local delta=node.Position+Vector3.new(0,1.3,0)-threat local result=workspace:Raycast(threat,delta,params)
    if result and (result.Position-node.Position).Magnitude>2 then
     local value=distance+(model:GetAttribute("CoverTeam")==self.team.Name and 0 or 12)
     if not score or value<score then score=value best=node.Position end
    end
   end
  end
 end
 return best
end
function Adapter:Alternate()
 self.lane=self.lane==0 and (self.slot%2==0 and spacing() or -spacing()) or 0
 local own=self.flags:GetFlag(self.team.Name)
 return own and own.home+Vector3.new(self.team.Name=="Blue" and 16 or -16,0,self.lane*.4)
end
return Adapter
