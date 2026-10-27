local events=game.ReplicatedStorage:WaitForChild("Events")
local remote=events:FindFirstChild("ShotVisual") or Instance.new("RemoteEvent") remote.Name="ShotVisual" remote.Parent=events
local Shots={}
function Shots.Emit(character,tool,origin,endpoint,color,shotId,extra)
 local packet=extra or {}
 packet.actor=character packet.tool=tool packet.origin=origin packet.endpoint=endpoint packet.color=color packet.shotId=shotId
 remote:FireAllClients(packet)
end
return Shots
