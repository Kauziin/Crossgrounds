if not game:GetService("RunService"):IsStudio() then return end
if not workspace:GetAttribute("GetOutP0Testing") then return end
-- Scripted traversal is driven by the server in this explicit test suite.
local player=game.Players.LocalPlayer
require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls():Disable()
