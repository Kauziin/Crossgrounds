if not game:GetService("RunService"):IsStudio()or game:GetService("StudioTestService"):GetTestArgs()~="GetOutMovementVisual"then return end
local Players=game.Players local Test=game:GetService("StudioTestService")
local event=Instance.new("RemoteEvent")event.Name="GetOutActionRegression"event.Parent=game.ReplicatedStorage
local replies={}local statuses={}local seq=0 local checks={}local measures={}
event.OnServerEvent:Connect(function(p,id,data)if id==0 then statuses[p]=data else replies[id]=data end end)
local function waitFor(fn,seconds)local untilTime=os.clock()+seconds repeat if fn()then return true end task.wait(.05)until os.clock()>untilTime return false end
local function check(ok,label)assert(ok,label)table.insert(checks,label)end
local function rpc(p,name,value)
 seq+=1 local id=seq event:FireClient(p,id,name,value)assert(waitFor(function()return replies[id]end,12),"client timeout")local data=replies[id]replies[id]=nil assert(data.ok,tostring(data.result))return data.result
end
local function place(p,cf)p.Character:PivotTo(cf)p.Character.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero end
task.spawn(function()
 local ok,result=xpcall(function()
  check(waitFor(function()if#Players:GetPlayers()<2 or not workspace:GetAttribute("CrossgroundsBootReady")then return end for _,p in Players:GetPlayers()do if not statuses[p]or not statuses[p].ready then return end end return true end,100),"two clients ready")
  local a=require(game.ServerScriptService.Crossgrounds.HubBootstrap).Coordinator.adapters.get_out
  for _,p in Players:GetPlayers()do task.spawn(function()a:Enter(p)end)end
  check(waitFor(function()return a.phase=="playing"or a.phase=="failed"end,50)and a.phase=="playing",a.message or"round started")
  check(waitFor(function()for _,p in Players:GetPlayers()do if not statuses[p]or not statuses[p].playingReady then return false end end return true end,40),"both loading screens released")
  local beast=a.beast local survivor for p,role in a.roles do if role=="survivor"then survivor=p end end
  place(survivor,CFrame.new(2597,103.5,30))place(beast,CFrame.new(2630,103.5,-40))task.wait(.4)
  measures.survivor=rpc(survivor,"jump",{direction=Vector3.xAxis,seconds=1.2})
  check(survivor.Character.HumanoidRootPart.Position.X>2602,"survivor crosses with 2.4-stud jump")check(measures.survivor.headTop<108.5,"survivor has upper-edge clearance")
  place(beast,CFrame.new(2603,103.5,30))task.wait(.4)measures.beast=rpc(beast,"jump",{direction=-Vector3.xAxis,seconds=.7})
  check(beast.Character.HumanoidRootPart.Position.X<2598,"beast crosses with 2.4-stud jump")check(measures.beast.headTop<108.5,"beast has upper-edge clearance")
  check(math.abs(beast.Character.Humanoid.WalkSpeed-7.2)<.01,"window still applies sixty percent slowdown")
  place(survivor,CFrame.new(2580,103.5,-15))task.wait(.3)rpc(survivor,"crawl",true)
  workspace:SetAttribute("GetOutVisualSurvivor",survivor.Name)
  workspace:SetAttribute("GetOutVisualReady",true)
  event:FireClient(survivor,999,"crawlMove",{direction=Vector3.xAxis,seconds=3})
  task.wait(4)measures.pose=rpc(survivor,"pose")check(measures.pose.torsoBottom>99.95,"crawl torso stays above the floor")
  task.wait(25)
  check(survivor:GetAttribute("GetOutPosture")=="Crawling","visual crawl remains active while held")
  rpc(survivor,"crawl",false)check(survivor:GetAttribute("GetOutPosture")=="Standing","visual crawl releases to standing")
  return{checks=checks,measures=measures}
 end,debug.traceback)
 local report={ok=ok,result=result,checks=checks,measures=measures}
 print("GetOutMovementVisualResult "..game.HttpService:JSONEncode(report))Test:EndTest(report)
end)
