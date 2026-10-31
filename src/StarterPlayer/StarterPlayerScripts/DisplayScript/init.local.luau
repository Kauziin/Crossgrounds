local NotificationManager=require(script.NotificationManager)
local TimerManager=require(script.TimerManager)
local player=game.Players.LocalPlayer
local gui=script.ScreenGui
gui.ResetOnSpawn=false gui.Parent=player:WaitForChild("PlayerGui")
local blur=game.Lighting:FindFirstChild("Blur") if blur then blur.Enabled=false end
workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
game.ReplicatedStorage.Events.DisplayIntermission.OnClientEvent:Connect(function()
 local b=game.Lighting:FindFirstChild("Blur") if b then b.Enabled=false end
 workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
end)