if not require(script.Parent:WaitForChild("ModeScope")):HasCombatRuntime() then return end
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local Run=game:GetService("RunService")
local player=game.Players.LocalPlayer
local toggle=game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("ToggleSprint")
Router:Register("Sprint",function(state) if state==Enum.UserInputState.Begin then toggle:FireServer() end end,{touch=true,title="CORRER",position=UDim2.fromScale(.57,.65)})
local held=false local bufferedUntil=0
local Jump=require(game.ReplicatedStorage.Crossgrounds:WaitForChild("JumpCooldown"))
local lastJump local tracked local jumpConnection
local function track(h)
 if tracked==h then return end
 if jumpConnection then jumpConnection:Disconnect() end
 tracked=h lastJump=nil
 if h then jumpConnection=h.StateChanged:Connect(function(_,state)
  if state==Enum.HumanoidStateType.Jumping then lastJump=workspace:GetServerTimeNow() end
 end) end
end
local function jumpReady(h)
 local mode=player:GetAttribute("CrossgroundsMode")
 if Jump.Duration(mode)==0 then return true end
 local now=workspace:GetServerTimeNow()
 return Jump.Ready(mode,lastJump,now) and now>=(h.Parent:GetAttribute("CombatJumpReadyAt") or 0)
end
local function requestJump()
 if Router:IsBlocked() then held=false bufferedUntil=0 return end
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 track(h)
 if not h or h.Health<=0 or not h:GetStateEnabled(Enum.HumanoidStateType.Jumping) then return end
 if not jumpReady(h) then h.Jump=false return end
 if player:GetAttribute("SlideActive") then game.ReplicatedStorage.Events.CombatSlide:FireServer(false) end
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
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") track(h)
 if h and not jumpReady(h) then h.Jump=false return end
 if Router:IsBlocked() then held=false bufferedUntil=0 return end
 if held or os.clock()<bufferedUntil then requestJump() end
end)
game:GetService("UserInputService").WindowFocusReleased:Connect(function() held=false bufferedUntil=0 end)
