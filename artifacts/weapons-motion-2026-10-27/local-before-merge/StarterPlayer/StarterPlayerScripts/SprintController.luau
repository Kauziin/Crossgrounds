if not require(script.Parent:WaitForChild("ModeScope")):HasCombatRuntime() then return end
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local Run=game:GetService("RunService")
local player=game.Players.LocalPlayer
local toggle=game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("ToggleSprint")
Router:Register("Sprint",function(state) if state==Enum.UserInputState.Begin then toggle:FireServer() end end,{touch=true,title="CORRER",position=UDim2.fromScale(.57,.65)})
local held=false local bufferedUntil=0
local function requestJump()
 if Router:IsBlocked() then held=false bufferedUntil=0 return end
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if not h or h.Health<=0 or not h:GetStateEnabled(Enum.HumanoidStateType.Jumping) then return end
 h.Jump=true
 local state=h:GetState()
 if h.FloorMaterial~=Enum.Material.Air and state~=Enum.HumanoidStateType.Jumping and state~=Enum.HumanoidStateType.Seated then
  h:ChangeState(Enum.HumanoidStateType.Jumping)
 end
end
Router:Register("Jump",function(state)
 if state==Enum.UserInputState.Begin then held=true bufferedUntil=os.clock()+.18 requestJump()
 elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then
  held=false
  local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h then h.Jump=false end
 end
 return Enum.ContextActionResult.Sink
end)
-- Runs after PlayerModule has processed its own (consumed) gamepad input.
Run.PreSimulation:Connect(function()
 if Router:IsBlocked() then held=false bufferedUntil=0 return end
 if held or os.clock()<bufferedUntil then requestJump() end
end)
game:GetService("UserInputService").WindowFocusReleased:Connect(function() held=false bufferedUntil=0 end)

