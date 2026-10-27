-- Explicit StudioTestService suite. Never starts during ordinary play or published servers.
local Suite={}
function Suite.Run(a)
 workspace:SetAttribute("GetOutP0Testing",true)
 local test=game:GetService("StudioTestService") local Players=game:GetService("Players")
 local results={} local function check(ok,label) assert(ok,label) table.insert(results,label) end
 local function waitFor(fn,seconds)
  local deadline=os.clock()+seconds repeat if fn() then return true end task.wait(.1) until os.clock()>deadline return false
 end
 local function root(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
 local function place(p,cf) local r=root(p) p.Character:PivotTo(cf) r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero pcall(function() r:SetNetworkOwner(nil) end) end
 local ok,err=xpcall(function()
  check(waitFor(function()
   local list=Players:GetPlayers() if #list<3 then return false end
   for _,p in list do if not p:GetAttribute("ModeCharacterReady") or not p:GetAttribute("GetOutClientReady") or not root(p) then return false end end return true
  end,120),"three hub characters ready")
  local players=Players:GetPlayers()
  for _,p in players do task.spawn(function() a:Enter(p) end) end
  check(waitFor(function() return a.phase=="playing" or a.phase=="failed" end,60) and a.phase=="playing","round started after client map acknowledgements: "..tostring(a.message))
  task.wait(2)
  local survivors={} for _,p in players do
   local r=root(p) local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
   check(r and h and h.Health>0 and (r.Position-a:CharacterPosition(p).Position).Magnitude<15,"spawn remained on map: "..p.Name)
   if p~=a.beast then table.insert(survivors,p) end
  end
  local p=survivors[1] local ally=survivors[2] local beast=a.beast local g=a.gameplay
  g:Action(p,"Crawl") check(p:GetAttribute("GetOutPosture")=="Crawling" and p.Character:FindFirstChild("GetOutCrawlCollider"),"crawl uses a physical low collider")
  place(p,CFrame.new(2590,101,0))
  local function crawlTo(x)
   local result=waitFor(function()
    local delta=Vector3.new(x,root(p).Position.Y,0)-root(p).Position
    if delta.Magnitude<.8 then return true end
    g.traversal:Move(p,delta.Unit) return false
   end,6)
   g.traversal:Move(p,Vector3.zero)
   return result and math.abs(root(p).Position.Z)<2.5
  end
  check(crawlTo(2610),"physical vent crossing west to east")
  check(crawlTo(2590),"physical vent crossing east to west")
  place(p,CFrame.new(2600,101,0)) g:Action(p,"Crawl")
  check(p:GetAttribute("GetOutPosture")=="Crawling","cannot stand under vent ceiling")
  place(p,CFrame.new(2585,101,0)) g:Action(p,"Crawl")
  check(p:GetAttribute("GetOutPosture")=="Standing","stands after clearing ceiling")
  local function jumpWindow(player,fromX,toX)
   place(player,CFrame.new(fromX,103,30)) local humanoid=player.Character:FindFirstChildOfClass("Humanoid")
   humanoid:ChangeState(Enum.HumanoidStateType.Jumping) humanoid:MoveTo(Vector3.new(toX,103,30))
   local passed=waitFor(function() return toX>2600 and root(player).Position.X>2605 or toX<2600 and root(player).Position.X<2595 end,5)
   humanoid:MoveTo(root(player).Position) return passed
  end
  check(jumpWindow(p,2593,2608),"survivor physically crosses jump window")
  place(p,CFrame.new(2575,103,20))
  check(jumpWindow(beast,2608,2592),"beast physically crosses jump window")
  local physics=game:GetService("PhysicsService")
  check(physics:CollisionGroupsAreCollidable("GetOutBeast","GetOutVent") and not physics:CollisionGroupsAreCollidable("GetOutHuman","GetOutVent"),"vent blocks beast only")
  local door=g.doors[1] place(p,CFrame.new(2587,104,-30))
  check(g:ToggleDoor(door),"regular door opens") task.wait(.8)
  place(p,CFrame.new(2600,104,-30)) check(not g:ToggleDoor(door),"door refuses to close on character")
  place(p,CFrame.new(2587,104,-30)) check(g:ToggleDoor(door),"regular door closes after clearance") task.wait(.8)
  place(p,CFrame.new(2630,104,-15)) place(beast,CFrame.lookAt(Vector3.new(2630,104,-10),Vector3.new(2630,104,-15)))
  g:Attack(beast) check(waitFor(function() return g.states[p].kind=="Downed" end,2),"hammer downs without lethal damage")
  check(p.Character:FindFirstChildOfClass("Humanoid").Health>0,"downed victim stays alive")
  check(g:Leash(p) and g.dragged==p,"beast leashes downed victim")
  local beforeDrag=root(p).Position local beastRoot=root(beast)
  beast.Character.Humanoid:MoveTo(beastRoot.Position+Vector3.new(-12,0,0))
  check(waitFor(function() return (root(p).Position-beforeDrag).Magnitude>6 and (root(p).Position-root(beast).Position).Magnitude<8 end,4) and g.dragged==p,"victim physically follows the walking beast")
  beast.Character.Humanoid:MoveTo(root(beast).Position)
  local pod=a.maps.manifest.routes.locks.pods.pod2
  place(beast,pod.CFrame*CFrame.new(0,0,-4)) place(p,pod.CFrame*CFrame.new(0,0,-2))
  check(g:Pod(pod) and g.states[p].kind=="Captured","dragged victim enters a nearby capsule")
  g:Tick(1) check(g.states[p].freeze==0,"anti-camping pauses freeze")
  place(beast,CFrame.new(2620,104,-10)) g:Tick(1) check(g.states[p].freeze>0,"freeze progresses away from beast")
  place(ally,pod.CFrame*CFrame.new(4,0,-4))
  task.wait(.2) -- Let avatar constraints update after scripted repositioning.
  local rescued,rescueReason=g:Rescue(pod,ally)
  check(rescued and not root(p).Anchored and not p.Character:FindFirstChild("GetOutCrawlCollider"),"rescue restores movement and removes restraints: "..tostring(rescueReason))
  local terminal=g.terminals.pc1 local slots={terminal.marker.HackSlot1,terminal.marker.HackSlot3}
  place(p,slots[1].WorldCFrame) place(ally,slots[2].WorldCFrame)
  g:StartHack(p,"pc1",slots[1]) g:StartHack(ally,"pc1",slots[2])
  check(g.jobs[p] and g.jobs[ally],"two users occupy separate hack slots")
  g.jobs[p].nextCheck=0 g:Tick(.1)
  local seq=g.jobs[p].sequence g:Check(p,seq)
  check(not g.jobs[p] and terminal.errorUntil>workspace:GetServerTimeNow(),"server rejects early timing check")
  terminal.errorUntil=0 g:StartHack(p,"pc1",slots[1])
  g:Tick(12)
  check(a.round.completedPCs.pc1==true,"cooperative progress completes exactly one PC")
  check(a.round:RollbackLastComputer(),"Hacker rolls back the completed PC") g:Rollback()
  check(not terminal.completed and terminal.progress==0,"rollback resets shared terminal state")
  place(beast,root(p).CFrame*CFrame.new(0,0,4))
  check(g:Down(p) and g:Leash(p),"victim can be leashed again after rescue")
  g:Drop() check(not g.dragged and not g.ropeObjects and g.states[p].kind=="Downed","release cleans rope and constraints")
  place(p,CFrame.new(2560,103,0)) g:SetState(p,"Active")
  for id in a.maps.manifest.routes.locks.computers do check(a.round:CompleteComputer(p,id),"final objective completes: "..id) end
  check(a.round:Crank(p,"door1"),"first exit crank unlocks after all PCs") a:OpenDoor("door1")
  place(p,CFrame.new(2548,103,0)) p.Character.Humanoid:MoveTo(Vector3.new(2532,103,0))
  check(waitFor(function() return a.round.status[p]=="escaped" end,5),"first survivor physically crosses escape zone")
  check(a.phase=="playing" and a.round.status[ally]=="active","first escape preserves the other survivor's round")
  check(a.round:Crank(ally,"door2"),"second exit crank remains independent") a:OpenDoor("door2")
  place(ally,CFrame.new(2652,103,0)) ally.Character.Humanoid:MoveTo(Vector3.new(2668,103,0))
  check(waitFor(function() return a.phase=="results" end,5),"last physical escape resolves the round")
  check(a.round.status[p]=="escaped" and a.round.status[ally]=="escaped","results preserve both individual escapes")
  for _,player in players do local r=root(player) check(r and not r.Anchored and not player.Character:FindFirstChild("GetOutCrawlCollider"),"results restore character: "..player.Name) end
 end,debug.traceback)
local diagnostics={}
 for _,p in Players:GetPlayers() do
  local r=root(p) local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  table.insert(diagnostics,{name=p.Name,mode=p:GetAttribute("CrossgroundsMode"),ready=p:GetAttribute("ModeCharacterReady"),health=h and h.Health,position=r and tostring(r.Position)})
 end
 local errors={} for _,entry in game:GetService("LogService"):GetLogHistory() do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message) end end
 local result={ok=ok,checks=results,error=not ok and tostring(err) or nil,players=diagnostics,runtimeErrors=errors}
 print("GetOut P0 smoke",game.HttpService:JSONEncode(result))
 test:EndTest(result)
end
return Suite
