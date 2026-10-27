local Bots={}
local Players=game:GetService("Players")
local Teams=game:GetService("Teams")
local Flags=require(script.Parent.FlagService)
local Brain=require(script.Parent.BotBrain)
local Avatar=require(script.Parent.AvatarService)
local Spawn=require(script.Parent.SpawnService)
local Damage=require(script.Parent.DamageService)
local Factory=require(script.Parent.WeaponFactory)
local template=game.ServerStorage.CTFBotTemplate
local folder=workspace:FindFirstChild("CTFBots") or Instance.new("Folder",workspace) folder.Name="CTFBots"
local bots={Blue={},Red={}} local respawn={Blue={},Red={}} local active=false local serial=0
local function alive(m) local h=m and m:FindFirstChildOfClass("Humanoid") return m and m.Parent and h and h.Health>0 end
local function create(team,slot)
 serial+=1 local m=template:Clone() m.Name=team.Name.."_AI_"..serial
 m:SetAttribute("CTFBot",true) m:SetAttribute("CTFTeam",team.Name) m:SetAttribute("CTFSlot",slot)
 local role=slot<=2 and "Runner" or slot<=4 and "Soldier" or "Guardian"
 m:SetAttribute("CTFRole",role)
 m.Parent=folder
 local h=m:FindFirstChildOfClass("Humanoid") h.MaxHealth=200 h.Health=200 h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
 Avatar:Apply(m,slot+(team.Name=="Red" and 6 or 0),team)
 Spawn:Place(m,team)
 local root=m:FindFirstChild("HumanoidRootPart") if root then pcall(function() root:SetNetworkOwner(nil) end) end
 local tool=Factory:Create(role=="Runner" and "SMG" or role=="Soldier" and "Rifle" or "Sniper")
 tool.Parent=m h:EquipTool(tool)
 Damage:Watch(m)
 h.Died:Connect(function()
  Brain:Stop(m) Damage:Unwatch(m)
  Flags:DropCarrier(m) respawn[team.Name][slot]=os.clock()+7+math.random()*2
  task.delay(2.5,function() if m.Parent then m:Destroy() end end)
 end)
 task.spawn(function() Brain:Start(m,team,slot,Flags,function() return active end) end)
 return m
end
function Bots:Reconcile()
 if not active then return end
 for _,team in Teams:GetTeams() do
  local list=bots[team.Name] local humans=0
  for _,p in Players:GetPlayers() do if p:GetAttribute("InMatch") and p.Team==team then humans+=1 end end
  local needed=math.max(0,6-humans)
  for slot=6,needed+1,-1 do if list[slot] then Flags:DropCarrier(list[slot]) Brain:Stop(list[slot]) Damage:Unwatch(list[slot]) list[slot]:Destroy() list[slot]=nil respawn[team.Name][slot]=0 end end
  for slot=1,needed do
   if not alive(list[slot]) and os.clock()>=(respawn[team.Name][slot] or 0) then
    if list[slot] then Brain:Stop(list[slot]) Damage:Unwatch(list[slot]) list[slot]:Destroy() end
    list[slot]=create(team,slot)
   end
  end
 end
end
function Bots:StartRound() active=true respawn={Blue={},Red={}} self:Reconcile() end
function Bots:StopRound()
 active=false
 for _,list in pairs(bots) do for slot=1,6 do if list[slot] then Flags:DropCarrier(list[slot]) Brain:Stop(list[slot]) Damage:Unwatch(list[slot]) list[slot]:Destroy() list[slot]=nil end end end
end
function Bots:GetCounts()
 local function count(list) local n=0 for _,m in pairs(list) do if alive(m) then n+=1 end end return n end
 return count(bots.Blue),count(bots.Red)
end
return Bots