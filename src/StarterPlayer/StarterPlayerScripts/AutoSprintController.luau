local player=game.Players.LocalPlayer
local Mode=require(script.Parent:WaitForChild("InputMode"))
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Router=require(script.Parent:WaitForChild("ControlRouter"))
if not Scope:HasCombatRuntime() then return end
local remote=game.ReplicatedStorage.Events:WaitForChild("SetSprint")
local requested=false local elapsed=0
game:GetService("RunService").Heartbeat:Connect(function(dt)
 elapsed+=dt if elapsed<.12 then return end elapsed=0
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 local camera=workspace.CurrentCamera
 local enabled=Mode:Get()==Enum.PreferredInput.Touch and player:GetAttribute("SettingAutoSprint")==true and Scope:IsCombat() and not Router:IsBlocked() and h and h.Health>0
 local forward=enabled and Vector3.new(camera.CFrame.LookVector.X,0,camera.CFrame.LookVector.Z) or Vector3.zero
 local dot=forward.Magnitude>.01 and h.MoveDirection:Dot(forward.Unit) or 0
 local want=enabled and dot>(requested and .55 or .8) and h.MoveDirection.Magnitude>.7 or false
 if want and not requested and (player:GetAttribute("Stamina") or 0)<35 then want=false end
 if requested and not player:GetAttribute("SprintActive") and (player:GetAttribute("Stamina") or 0)<20 then want=false end
 if want~=requested then requested=want remote:FireServer(want) end
end)
