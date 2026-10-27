local FlagService = {}
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local Config = require(game.ServerStorage.Configurations)
local Events = game.ReplicatedStorage.Events
local arena = workspace:WaitForChild("CTFInfrastructure")
local flags = {}
local connections = {}
local active = false
local alert=Events:FindFirstChild("CTFFlagAlert") or Instance.new("RemoteEvent") alert.Name="CTFFlagAlert" alert.Parent=Events
local function notify(flag,kind,character)
 local actor=character and Players:GetPlayerFromCharacter(character)
 local name=actor and actor.DisplayName or character and (character:GetAttribute("DisplayName") or character.Name) or ""
 for _,viewer in Players:GetPlayers() do
  if viewer:GetAttribute("CrossgroundsMode")=="ctf" and viewer:GetAttribute("InMatch") then
   alert:FireClient(viewer,{kind=kind,team=flag.team.Name,carrier=name,self=actor==viewer})
  end
 end
end
local function publish(flag)
 if not flag.base then return end
 flag.base:SetAttribute("FlagState",flag.state)
 local ref=flag.base:FindFirstChild("FlagCarrier") or Instance.new("ObjectValue") ref.Name="FlagCarrier" ref.Value=flag.carrier ref.Parent=flag.base
 local actor=flag.carrier and Players:GetPlayerFromCharacter(flag.carrier)
 flag.base:SetAttribute("FlagCarrierName",actor and actor.DisplayName or flag.carrier and (flag.carrier:GetAttribute("DisplayName") or flag.carrier.Name) or nil)
 flag.base:SetAttribute("FlagReturnAt",flag.state=="dropped" and workspace:GetServerTimeNow()+Config.FLAG_RESPAWN_TIME or 0)
end

local function actorInfo(character)
 if not character or not character:IsA("Model") then return nil end
 local humanoid = character:FindFirstChildOfClass("Humanoid")
 if not humanoid or humanoid.Health <= 0 then return nil end
 local player = Players:GetPlayerFromCharacter(character)
 if player and player:GetAttribute("InArena") then return player.Team, player, humanoid end
 if character:GetAttribute("CTFBot") then
  return Teams:FindFirstChild(character:GetAttribute("CTFTeam")), nil, humanoid
 end
 return nil
end

local function showFlag(flag, position)
 flag.pole.CFrame = CFrame.new(position + Vector3.new(0, 4.5, 0))
 flag.banner.CFrame = CFrame.new(position + Vector3.new(0, 6, 1.7))
 flag.pole.Transparency = 0
 flag.banner.Transparency = 0
 flag.hitbox.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
 flag.hitbox.CanTouch = true
end

local function hideFlag(flag)
 flag.pole.Transparency = 1
 flag.banner.Transparency = 1
 flag.hitbox.CanTouch = false
end

local function clearCarry(flag)
 for _,c in flag.carryConnections or {} do c:Disconnect() end flag.carryConnections=nil
 if flag.carryVisual then flag.carryVisual:Destroy() flag.carryVisual = nil end
 if flag.carrier then flag.carrier:SetAttribute("CarryingFlag",nil) end
 flag.carrier = nil
end

function FlagService:Return(flag, silent)
 local wasAway = flag.state ~= "home"
 flag.returnToken += 1
 clearCarry(flag)
 flag.state = "home"
 showFlag(flag, flag.home)
 publish(flag)
 if active and wasAway and not silent then Events.ReturnFlag:Fire(flag.team.TeamColor) notify(flag,"return") end
end

function FlagService:DropCarrier(character)
 for _, flag in pairs(flags) do
  if flag.carrier == character then
   local root = character:FindFirstChild("HumanoidRootPart")
   local dropAt = root and root.Position or flag.home
   flag.returnToken += 1
   clearCarry(flag)
   flag.state = "dropped"
   notify(flag,"drop",character)
   publish(flag)
   showFlag(flag, Vector3.new(dropAt.X, math.max(dropAt.Y - 3, 13), dropAt.Z))
   local token = flag.returnToken
   task.delay(Config.FLAG_RESPAWN_TIME, function()
    if active and flag.state == "dropped" and token == flag.returnToken then
     self:Return(flag)
    end
   end)
  end
 end
end

local function carryFlag(flag, character, humanoid)
 flag.returnToken += 1
 flag.state = "carried"
 flag.carrier = character
 character:SetAttribute("CarryingFlag",flag.team.Name)
 publish(flag)
 hideFlag(flag)
 notify(flag,"pickup",character)
 local root = character:FindFirstChild("HumanoidRootPart")
 if root then
  local pole = Instance.new("Part")
  pole.Name = "CarriedFlag"
  pole.Size = Vector3.new(.3, 4.5, .3)
  pole.Material = Enum.Material.Metal
  pole.Color = Color3.fromRGB(220, 220, 205)
  pole.CanCollide = false
  pole.CanTouch = false
  pole.Massless = true
  pole.CFrame = root.CFrame * CFrame.new(1.3, 1.8, .7)
  pole.Parent = character
  local weld = Instance.new("WeldConstraint")
  weld.Part0 = root weld.Part1 = pole weld.Parent = pole
  local banner = Instance.new("Part")
  banner.Name = "CarriedBanner"
  banner.Size = Vector3.new(.2, 1.7, 1.5)
  banner.Material = Enum.Material.Fabric
  banner.Color = flag.banner.Color
  banner.CanCollide = false banner.CanTouch = false banner.Massless = true
  banner.CFrame = pole.CFrame * CFrame.new(0, 1, .8)
  banner.Parent = pole
  local bannerWeld = Instance.new("WeldConstraint")
  bannerWeld.Part0 = pole bannerWeld.Part1 = banner bannerWeld.Parent = banner
  flag.carryVisual = pole
 end
 flag.carryConnections={humanoid.Died:Once(function() FlagService:DropCarrier(character) end),character.Destroying:Once(function() FlagService:DropCarrier(character) end)}
end

function FlagService:TryInteract(character)
 if not active then return end
 local team, player, humanoid = actorInfo(character)
 if not team then return end
 local root = character:FindFirstChild("HumanoidRootPart")
 if not root then return end
 local own = flags[team.Name]
 if not own then return end
 local enemy
 for _, flag in pairs(flags) do if flag.team ~= team then enemy = flag break end end
 if not enemy then return end
 local function near(a, b, radius)
  return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude <= radius and math.abs(a.Y-b.Y) < 12
 end
 if enemy.carrier == character and near(root.Position, own.home, 7) then
  if not Config.REQUIRE_RETURN_BEFORE_CAP or own.state == "home" then
   notify(enemy,"capture",character)
   self:Return(enemy, true)
   Events.CaptureFlag:Fire(player, team.TeamColor)
  end
  return
 end
 if own.state == "dropped" and near(root.Position, own.hitbox.Position, 6) then
  self:Return(own)
 end
 if enemy.state ~= "carried" and near(root.Position, enemy.hitbox.Position, 6) then
  carryFlag(enemy, character, humanoid)
 end
end

function FlagService:GetFlag(teamName)
 return flags[teamName]
end

function FlagService:Initialize()
 for _,c in connections do c:Disconnect() end connections={}
 for _,f in pairs(flags) do f.returnToken+=1 clearCarry(f) end flags={}
 arena=workspace:WaitForChild("CTFInfrastructure")
 for _, team in ipairs(Teams:GetTeams()) do
  local base = arena:WaitForChild(team.Name .. "Base")
  local stand = base:WaitForChild("FlagStand")
  local hitbox = base:FindFirstChild("FlagHitbox") or Instance.new("Part")
  hitbox.Name = "FlagHitbox"
  hitbox.Size = Vector3.new(7, 6, 7)
  hitbox.Transparency = 1
  hitbox.Anchored = true
  hitbox.CanCollide = false
  hitbox.CanQuery = false
  hitbox.Parent = base
  local flag = {
   base=base, team = team, stand = stand, pole = base.FlagPole, banner = base.FlagBanner,
   hitbox = hitbox, home = Vector3.new(stand.Position.X, stand.Position.Y - .5, stand.Position.Z),
   state = "home", returnToken = 0
  }
  flags[team.Name] = flag
  showFlag(flag, flag.home)
 publish(flag)
  local function touched(part)
   self:TryInteract(part:FindFirstAncestorOfClass("Model"))
  end
  table.insert(connections,hitbox.Touched:Connect(touched))
  table.insert(connections,stand.Touched:Connect(touched))
 end
end

function FlagService:StartRound()
 active = true
 for _, flag in pairs(flags) do self:Return(flag) end
end

function FlagService:StopRound()
 active = false
 for _, flag in pairs(flags) do self:Return(flag) end
end

return FlagService