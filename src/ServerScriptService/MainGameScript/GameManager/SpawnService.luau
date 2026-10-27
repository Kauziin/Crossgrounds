local Spawn={}
local Players=game:GetService("Players")

local recent=setmetatable({},{__mode="k"})
local function actors()
 local result={}
 for _,p in Players:GetPlayers() do if p:GetAttribute("InMatch") and p.Character then table.insert(result,{model=p.Character,team=p.Team and p.Team.Name}) end end
 local bots=workspace:FindFirstChild("CTFBots")
 if bots then for _,b in bots:GetChildren() do table.insert(result,{model=b,team=b:GetAttribute("CTFTeam")}) end end
 return result
end
function Spawn:Choose(team)
 local arena=workspace:WaitForChild("CTFInfrastructure")
 local pads=arena[team.Name.."Base"].Spawns:GetChildren()
 local all=actors()
 local scored={}
 for _,pad in pads do
  local score=math.random()*12
  for _,actor in all do
   local h=actor.model:FindFirstChildOfClass("Humanoid")
   local r=actor.model:FindFirstChild("HumanoidRootPart")
   if h and h.Health>0 and r then
    local d=(r.Position-pad.Position).Magnitude
    if actor.team~=team.Name then
     score+=math.min(d,160)*.1
     if d<65 then score-=(65-d)*5 end
     local params=RaycastParams.new() params.FilterDescendantsInstances={actor.model,pad} params.FilterType=Enum.RaycastFilterType.Exclude
     if d<150 and not workspace:Raycast(r.Position,pad.Position+Vector3.new(0,3,0)-r.Position,params) then score-=100 end
    elseif d<9 then score-=90 end
   end
  end
  if os.clock()-(recent[pad] or -100)<4 then score-=75 end
  table.insert(scored,{pad=pad,score=score})
 end
 table.sort(scored,function(a,b) return a.score>b.score end)
 local best=scored[1] and scored[1].pad
 if best then recent[best]=os.clock() end
 return best
end
local function clearShields(model)
 for _,v in model:GetChildren() do if v:IsA("ForceField") and (v.Name=="LobbyShield" or v.Name=="SpawnShield") then v:Destroy() end end
end
function Spawn:Place(model,team)
 clearShields(model)
 local pad=self:Choose(team)
 if not pad then return end
 local p=pad.Position+Vector3.new(0,4,0)
 model:PivotTo(CFrame.lookAt(p,p+Vector3.new(team.Name=="Blue" and 1 or -1,0,0)))
 model:SetAttribute("SpawnProtectedUntil",workspace:GetServerTimeNow()+2)
 local shield=Instance.new("ForceField") shield.Name="SpawnShield" shield.Parent=model
 task.delay(2,function() if shield.Parent then shield:Destroy() end end)
end
function Spawn:Lobby(model)
 clearShields(model)
 local p=workspace.CTFLobby.Spawn.Position+Vector3.new(math.random(-8,8),4,math.random(-6,6))
 model:PivotTo(CFrame.lookAt(p,Vector3.new(0,p.Y,343)))
 local h=model:FindFirstChildOfClass("Humanoid")
 if h then h.MaxHealth=200 h.Health=200 end
 local shield=Instance.new("ForceField") shield.Name="LobbyShield" shield.Visible=false shield.Parent=model
end
return Spawn