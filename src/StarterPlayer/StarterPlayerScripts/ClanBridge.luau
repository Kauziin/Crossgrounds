local Bridge={Status="",Busy=false}
local remotes=game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("Remotes")
local remote=remotes:WaitForChild("ClanCommand")
local signal=Instance.new("BindableEvent")Bridge.Changed=signal.Event
local current={invites={}}
local dirty,queued=false,false
local lastRead,lastWrite=-10,-10
local function queueRefresh()
 if queued then return end queued=true
 task.delay(.65,function()
  queued=false if not dirty then return end
  if Bridge.Busy then queueRefresh()else Bridge:Send("get")end
 end)
end
function Bridge:Get()return current end
function Bridge:Send(action,payload)
 if self.Busy then return false,"Aguarde a solicitação anterior."end
 self.Busy=true signal:Fire()
 local read=action=="get"or action=="view"or action=="leaderboard"
 task.wait(math.max(0,(read and .55 or 1.05)-(os.clock()-(read and lastRead or lastWrite))))
 if read then lastRead=os.clock()else lastWrite=os.clock()end
 if action=="get"then dirty=false end
 local ok,accepted,value=pcall(function()return remote:InvokeServer(action,payload)end)
 self.Busy=false
 if not ok then self.Status="Clãs indisponíveis. Tente novamente."
 elseif not accepted then self.Status=tostring(value or"Operação indisponível.")
 elseif action=="get"then current=value self.Status=""
 elseif type(value)=="string"then self.Status=value
 else self.Status=""end
 signal:Fire()
 if dirty then queueRefresh()end
 return ok and accepted,value
end
remotes:WaitForChild("ClanState").OnClientEvent:Connect(function()dirty=true queueRefresh()end)
return Bridge
