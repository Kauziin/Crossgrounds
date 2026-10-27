local MovementService = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local events = game.ReplicatedStorage:WaitForChild("Events")
local toggle = events:FindFirstChild("ToggleSprint") or Instance.new("RemoteEvent")
toggle.Name = "ToggleSprint"
toggle.Parent = events
local requested=events:FindFirstChild("SetSprint") or Instance.new("RemoteEvent") requested.Name="SetSprint" requested.Parent=events
local states = {}
local MAX_STAMINA = 100
local DRAIN_PER_SECOND = require(game.ReplicatedStorage.Crossgrounds.SprintDefinitions).DrainPerSecond
local REGEN_PER_SECOND = 15
local REGEN_DELAY = 1

local function stateFor(player)
 local state = states[player]
 if not state then
  state = {stamina=MAX_STAMINA, sprinting=false, lastDrain=0}
  states[player] = state
 end
 return state
end

local function applySpeed(player, state)
 local character = player.Character
 local humanoid = character and character:FindFirstChildOfClass("Humanoid")
 if humanoid and humanoid.Health > 0 then
  humanoid.WalkSpeed = state.sprinting and (player:GetAttribute("KitSprintSpeed") or 25)
   or (player:GetAttribute("KitWalkSpeed") or 18)
 end
 player:SetAttribute("SprintActive", state.sprinting)
end

function MovementService:ApplyToCharacter(player)
 local state = stateFor(player)
 state.stamina = MAX_STAMINA
 state.sprinting = false
 state.lastDrain = 0
 player:SetAttribute("Stamina", MAX_STAMINA)
 applySpeed(player, state)
end

function MovementService:Reset(player)
 states[player] = nil
 player:SetAttribute("Stamina", MAX_STAMINA)
 player:SetAttribute("SprintActive", false)
end

function MovementService:SetRequested(player,on)
 if (player:GetAttribute("CrossgroundsMode") and player:GetAttribute("CrossgroundsMode")~="ctf") or player:GetAttribute("CrossgroundsTransition") then return end
 if not player.Character or not (player:GetAttribute("InMatch") or player.Character:GetAttribute("AtLobby")) then return end
 local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if not humanoid or humanoid.Health <= 0 then return end
 local state = stateFor(player)
 if on==nil then on=not state.sprinting end
 state.sprinting=on==true and state.stamina>=20
 applySpeed(player, state)
end
toggle.OnServerEvent:Connect(function(p) MovementService:SetRequested(p) end)
requested.OnServerEvent:Connect(function(p,on) if typeof(on)=="boolean" then MovementService:SetRequested(p,on) end end)

local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
 elapsed += dt
 if elapsed < .1 then return end
 local step = elapsed
 elapsed = 0
 for _, player in ipairs(Players:GetPlayers()) do
  local state = states[player]
  if state and player.Character then
   local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
   if humanoid and humanoid.Health > 0 then
    if state.sprinting and humanoid.MoveDirection.Magnitude > .05 then
     state.stamina = math.max(0, state.stamina - DRAIN_PER_SECOND * step)
     state.lastDrain = os.clock()
     if state.stamina <= 0 then state.sprinting = false applySpeed(player, state) end
    elseif os.clock() - state.lastDrain >= REGEN_DELAY then
     state.stamina = math.min(MAX_STAMINA, state.stamina + REGEN_PER_SECOND * step)
    end
    player:SetAttribute("Stamina", math.floor(state.stamina + .5))
   end
  end
 end
end)
Players.PlayerRemoving:Connect(function(player) states[player] = nil end)
return MovementService
