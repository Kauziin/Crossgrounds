local Scope=require(script.Parent:WaitForChild("ModeScope"))
if not Scope:HasCombatRuntime() then return end
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local player=game.Players.LocalPlayer
local remote=game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("CombatSlide")
Router:Register("Slide",function(state)
 if state==Enum.UserInputState.Begin then remote:FireServer(not player:GetAttribute("SlideActive"))
 elseif state==Enum.UserInputState.Cancel then remote:FireServer(false) end
 return Enum.ContextActionResult.Sink
end,{scope="combat"})
local function cancel() if player:GetAttribute("SlideActive") then remote:FireServer(false) end end
game:GetService("UserInputService").JumpRequest:Connect(cancel)
game:GetService("UserInputService").WindowFocusReleased:Connect(cancel)
Scope.Changed:Connect(cancel)
if Router.ContextChanged then Router.ContextChanged:Connect(function() if Router:IsBlocked() then cancel() end end) end
