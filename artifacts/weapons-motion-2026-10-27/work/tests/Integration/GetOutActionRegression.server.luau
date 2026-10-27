if not game:GetService("RunService"):IsStudio()or game:GetService("StudioTestService"):GetTestArgs()~="GetOutActionRegression"then return end
local Players=game:GetService("Players")local Test=game:GetService("StudioTestService")
local event=Instance.new("RemoteEvent")event.Name="GetOutActionRegression"event.Parent=game.ReplicatedStorage
local replies={}local statuses={}local sequence=0 local checks={}local observations={}
event.OnServerEvent:Connect(function(p,id,data)if id==0 then statuses[p]=data else replies[id]={player=p,data=data}end end)
local function check(value,label)assert(value,label)table.insert(checks,label)end
local function waitFor(fn,seconds)local deadline=os.clock()+seconds repeat if fn()then return true end task.wait(.05)until os.clock()>deadline return false end
local function root(p)return p.Character.HumanoidRootPart end
local function place(p,cf)p.Character:PivotTo(cf)root(p).AssemblyLinearVelocity=Vector3.zero root(p).AssemblyAngularVelocity=Vector3.zero end
local function rpc(p,command,value,timeout)
 sequence+=1 local id=sequence event:FireClient(p,id,command,value)
 assert(waitFor(function()return replies[id]~=nil end,timeout or 10),"client RPC timeout: "..command)
 local response=replies[id]replies[id]=nil assert(response.player==p,"wrong client reply")assert(response.data.ok,tostring(response.data.result))return response.data.result
end
task.spawn(function()
 local ok,result=xpcall(function()
  check(waitFor(function()if not workspace:GetAttribute("CrossgroundsBootReady")or#Players:GetPlayers()<3 then return end for _,p in Players:GetPlayers()do if not p:GetAttribute("ModeCharacterReady")or not statuses[p]or not statuses[p].ready then return end end return true end,110),"three real clients ready in hub")
  local a=require(game.ServerScriptService.Crossgrounds.HubBootstrap).Coordinator.adapters.get_out
  for _,p in Players:GetPlayers()do task.spawn(function()a:Enter(p)end)end
  check(waitFor(function()return a.phase=="playing"or a.phase=="failed"end,60)and a.phase=="playing",a.message or"round ready")
  check(waitFor(function()for _,p in Players:GetPlayers()do if not statuses[p]or not statuses[p].playingReady then return false end end return true end,50),"loading overlay released for all clients")
  local survivors={}for p,role in a.roles do if role=="survivor"then table.insert(survivors,p)end end
  local survivor=survivors[1]local ally=survivors[2]local beast=a.beast local data=a.maps.manifest.routes.locks local g=a.gameplay
  local pc=data.computers.pc1 place(survivor,pc.HackSlot2.WorldCFrame)place(ally,CFrame.new(2570,103.5,-40))place(beast,CFrame.new(2630,103.5,40))task.wait(.5)
  rpc(survivor,"hold",.06)task.wait(.4)check(not g.jobs[survivor],"short interaction cancels without starting hack")
  place(beast,pc.HackSlot2.WorldCFrame)task.wait(.4)rpc(beast,"rawInteract",pc.HackSlot2:GetChildren()[1])task.wait(.3)
  check(not g.jobs[beast]and not a.interactions[beast],"beast cannot use survivor computer prompt")place(beast,CFrame.new(2630,103.5,40))
  local hold=rpc(survivor,"hold")task.wait(.2)check(not hold.blocked and g.jobs[survivor]~=nil,"native client interaction starts hacking")rpc(survivor,"stopHack")
  place(survivor,CFrame.new(2585,103.5,0))task.wait(.3)
  rpc(survivor,"tapCrawl")check(survivor:GetAttribute("GetOutPosture")=="Standing","short crawl press interrupts entry and returns to standing")
  rpc(survivor,"crawl",true)check(survivor:GetAttribute("GetOutPosture")=="Crawling","holding crawl enters low posture")
  local crawl=rpc(survivor,"crawlMove",{direction=Vector3.xAxis,seconds=1.4})observations.crawl=crawl check(crawl.animated and crawl.distance>2,"crawl locomotion animates shoulders/knees while physically moving")
  rpc(survivor,"crawl",false)check(waitFor(function()return survivor:GetAttribute("GetOutPosture")=="Standing"end,2),"crawl release stands in clear space")
  place(survivor,CFrame.new(2597,103.5,0))rpc(survivor,"crawl",true)
  local passage=rpc(survivor,"crawlMove",{direction=Vector3.xAxis,seconds=3})observations.vent=passage check(root(survivor).Position.X>2602,"compact vent crosses without teleport")
  place(survivor,CFrame.new(2600,101.3,0))rpc(survivor,"crawl",false)check(survivor:GetAttribute("GetOutPosture")=="Crawling","release under vent cannot stand through its ceiling")
  rpc(survivor,"crawlMove",{direction=Vector3.xAxis,seconds=2})check(waitFor(function()return survivor:GetAttribute("GetOutPosture")=="Standing"end,2),"release stands automatically after clearing vent")
  place(survivor,CFrame.new(2597,103.5,30))task.wait(.4)
  local jump=rpc(survivor,"jump",{direction=Vector3.xAxis,seconds=1.2})observations.survivorWindow=jump
  check(root(survivor).Position.X>2602,"survivor crosses Facility-sized window")check(jump.headTop<108.65,"survivor jump stays below upper window edge")
  place(survivor,CFrame.new(2570,103.5,-40))place(beast,CFrame.new(2630,103.5,40))task.wait(.3)
  local ability=rpc(beast,"ability")observations.runner=ability check(ability.class=="Runner"and math.abs(ability.speed-45)<.01 and ability.jump==0 and not ability.jumping,"Runner grants +150 percent and blocks jumping")
  local untilTime=beast:GetAttribute("GetOutRunnerUntil")check(waitFor(function()return workspace:GetServerTimeNow()>untilTime+.15 end,4),"Runner completes three-second duration")
  check(math.abs(beast.Character.Humanoid.WalkSpeed-18)<.01 and beast.Character.Humanoid.JumpHeight>0,"Runner restores speed and jumping")
  place(beast,CFrame.new(2603,103.5,30))task.wait(.4)
  local window=rpc(beast,"jump",{direction=-Vector3.xAxis,seconds=.7})observations.beastWindow=window
  check(root(beast).Position.X<2598,"beast crosses compact window")check(math.abs(beast.Character.Humanoid.WalkSpeed-7.2)<.01,"window crossing reduces beast speed by sixty percent")
  check(window.headTop<108.65,"beast jump stays below upper window edge")task.wait(1.7)check(math.abs(beast.Character.Humanoid.WalkSpeed-18)<.01,"window slowdown expires")
  place(survivor,CFrame.new(2630,103.5,-15))place(beast,CFrame.lookAt(Vector3.new(2630,103.5,-10),Vector3.new(2630,103.5,-15)))task.wait(.4)
  rpc(beast,"attack")check(waitFor(function()return g.states[survivor].kind=="Downed"end,2),"client attack downs survivor")
  rpc(beast,"hold")check(waitFor(function()return g.dragged==survivor end,2),"client prompt attaches rope to downed survivor")
  local pod=data.pods.pod2 place(beast,pod.CFrame*CFrame.new(0,0,-4))place(survivor,pod.CFrame*CFrame.new(0,0,-2))task.wait(.5)
  rpc(beast,"hold")check(waitFor(function()return g.states[survivor].kind=="Captured"end,2),"client prompt captures dragged survivor in capsule")
  place(beast,CFrame.new(2620,103.5,-10))place(ally,pod.CFrame*CFrame.new(4,0,-4))task.wait(.5)
  rpc(ally,"hold",3.5)check(waitFor(function()return g.states[survivor].kind=="Active"end,2),"ally client prompt rescues capsule occupant")
  place(beast,CFrame.new(2630,103.5,45))
  for i=1,4 do
   local terminal=data.computers['pc'..i]
   place(survivor,terminal.HackSlot2.WorldCFrame)place(ally,terminal.HackSlot1.WorldCFrame)task.wait(.4)
   rpc(survivor,"hold")rpc(ally,"hold")
   check(waitFor(function()return a.round.completedPCs['pc'..i]end,20),"cooperative computer "..i.." completes with client timing checks")
  end
  check(a.round.exitReady,"four computers release exit locks")
  local crank=data.cranks.door1 place(survivor,crank.CFrame*CFrame.new(2,0,0))task.wait(.4)rpc(survivor,"hold",10.5,14)
  check(a.round.openedDoors.door1,"client crank opens physical exit")
  for _,p in survivors do place(p,CFrame.new(2544,103.5,0))task.wait(.3)rpc(p,"walk",{direction=-Vector3.xAxis,seconds=1})end
  check(waitFor(function()return a.phase=="results"end,3),"full round reaches results through physical escapes")
  for _,p in survivors do check(a.round.status[p]=="escaped","individual escape recorded: "..p.Name)end
  return{checks=checks,observations=observations,ending=a.round.ending}
 end,debug.traceback)
 Test:EndTest({ok=ok,result=result,checks=checks,observations=observations})
end)
