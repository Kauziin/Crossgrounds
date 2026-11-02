local Bridge={Status="",Busy=false}
local remotes=game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("Remotes")
local command=remotes:WaitForChild("PartyCommand")
local changed=Instance.new("BindableEvent") Bridge.Changed=changed.Event
local current={}
local function apply(data) if type(data)=="table" then current=data changed:Fire() end end
remotes:WaitForChild("PartyState").OnClientEvent:Connect(apply)
function Bridge:Get() return current end
function Bridge:Send(action,payload)
 if self.Busy then return false,"Aguarde a solicitação anterior." end
 self.Busy=true changed:Fire()
 local ok,success,result=pcall(function()return command:InvokeServer(action,payload)end)
 self.Busy=false
 if not ok then self.Status="Não foi possível atualizar o grupo. Tente novamente."
 elseif success and action=="get" then apply(result)
 else self.Status=tostring(result or "") end
 changed:Fire() return ok and success,result
end
task.spawn(function()Bridge:Send("get")end)
return Bridge
