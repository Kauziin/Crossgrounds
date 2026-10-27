-- Temporary native-client diagnostic. Never part of src or normal bootstrap.
if not game:GetService("RunService"):IsStudio() or game:GetService("StudioTestService"):GetTestArgs()~="GetOutActionProbe"then return end
local Players=game:GetService("Players")local Test=game:GetService("StudioTestService")
local event=Instance.new("RemoteEvent")event.Name="GetOutActionProbe"event.Parent=game.ReplicatedStorage
local reports={}event.OnServerEvent:Connect(function(p,data)reports[p]=data end)
local function waitFor(fn,seconds)local deadline=os.clock()+seconds repeat if fn()then return true end task.wait(.1)until os.clock()>deadline return false end
local function place(p,cf)p.Character:PivotTo(cf)p.Character.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero end
task.spawn(function()
 local ok,result=xpcall(function()
  assert(waitFor(function()if not workspace:GetAttribute("CrossgroundsBootReady")or#Players:GetPlayers()<2 then return end for _,p in Players:GetPlayers()do if not p:GetAttribute("ModeCharacterReady")or not reports[p]or not reports[p].ready then return end end return true end,100),"hub/client not ready")
  local a=require(game.ServerScriptService.Crossgrounds.HubBootstrap).Coordinator.adapters.get_out
  for _,p in Players:GetPlayers()do task.spawn(function()a:Enter(p)end)end
  assert(waitFor(function()return a.phase=="playing"or a.phase=="failed"end,60)and a.phase=="playing",a.message or"round not playing")
  assert(waitFor(function()for _,p in Players:GetPlayers()do if not reports[p]or not reports[p].playingReady then return false end end return true end,50),"client loading overlay did not release")
  local survivor for p,role in a.roles do if role=="survivor"then survivor=p break end end
  local pc=a.maps.manifest.routes.locks.computers.pc1 local slot=pc.HackSlot2
  place(survivor,slot.WorldCFrame)
  local events={}for _,prompt in pc:GetDescendants()do if prompt:IsA("ProximityPrompt")then
   prompt.PromptButtonHoldBegan:Connect(function(p)table.insert(events,{event="begin",player=p.Name,prompt=prompt:GetFullName(),time=workspace:GetServerTimeNow()})end)
   prompt.PromptButtonHoldEnded:Connect(function(p)table.insert(events,{event="end",player=p.Name,time=workspace:GetServerTimeNow()})end)
   prompt.Triggered:Connect(function(p)table.insert(events,{event="trigger",player=p.Name,time=workspace:GetServerTimeNow()})end)
  end end
  reports[survivor]=nil task.wait(1)event:FireClient(survivor,"interact")
  waitFor(function()return reports[survivor]~=nil end,8)task.wait(.5)
  return {hackActive=a.gameplay.jobs[survivor]~=nil,report=reports[survivor],events=events}
 end,debug.traceback)
 Test:EndTest({ok=ok,result=result})
end)
