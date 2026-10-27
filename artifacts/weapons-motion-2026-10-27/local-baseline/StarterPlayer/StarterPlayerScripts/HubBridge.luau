local Bridge={}
local player=game.Players.LocalPlayer
local root=game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("Remotes")
local command=root:WaitForChild("Command") local event=root:WaitForChild("State") local get=root:WaitForChild("GetState")
local signal=Instance.new("BindableEvent") Bridge.Changed=signal.Event
local current local generation=0
local function apply(data)
 if type(data)~="table" or data.version~=1 then return end
 if current and (data.revision or 0)<(current.revision or 0) then return end
 current=data Bridge.Pending=false Bridge.LocalError=nil generation+=1 signal:Fire()
end
event.OnClientEvent:Connect(apply)
function Bridge:Get() return current end
function Bridge:Send(action,gameId,ticket)
 if self.Pending then return end
 local data={action=action} if gameId then data.gameId=gameId end if ticket then data.ticket=ticket end
 self.Pending=true self.LocalError=nil generation+=1 local token=generation
 command:FireServer(data) signal:Fire()
 task.delay(6,function() if generation==token and self.Pending then self.Pending=false self.LocalError="O servidor não confirmou a solicitação. Consulte o estado e tente novamente." signal:Fire() end end)
end
task.spawn(function()
 for _=1,3 do
  local ok,data=pcall(function() return get:InvokeServer() end)
  if ok and data then apply(data) return end task.wait(.5)
 end
 Bridge.LocalError="Não foi possível carregar o catálogo do servidor." signal:Fire()
end)
return Bridge

