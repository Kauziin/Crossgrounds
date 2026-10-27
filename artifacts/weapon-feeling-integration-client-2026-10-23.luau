-- Temporary real-client exercise of the existing weapon remotes and camera.
local p=game.Players.LocalPlayer local Run=game:GetService("RunService")
local remote=game.ReplicatedStorage:WaitForChild("WeaponFeelingQA",25) assert(remote)
task.wait(1)
local Nav=require(p.PlayerScripts.MenuNavigation) Nav:OpenMenu("Resume")
local Presentation=require(p.PlayerScripts.CombatPresentation)
local results={} local function record(name,fn)
 local ok,detail=pcall(fn) table.insert(results,{name=name,passed=ok,detail=tostring(detail)})
 remote:InvokeServer("report",results)
end
local events=game.ReplicatedStorage.Events local confirmations={} local visuals=0
local conn=events.ShotResult.OnClientEvent:Connect(function(m) confirmations[m.shotId]=m end)
local viz=events.ShotVisual.OnClientEvent:Connect(function(m) if m.actor==p.Character then visuals+=1 end end)
local target,tool,aim,cameraOrigin,cameraDirection
local function prepare()
 task.wait(.3) local _,o,d=Presentation:GetAimWorld(850)
 target=remote:InvokeServer("prepare",{origin=o,direction=d})
 task.wait(.2) aim,cameraOrigin,cameraDirection=Presentation:GetAimWorld(122)
 tool=p.Character:FindFirstChildOfClass("Tool")
end
local function send(id,override,predict)
 local request={version=1,time=workspace:GetServerTimeNow(),cameraOrigin=cameraOrigin,cameraDirection=cameraDirection,view={part=target.part,position=target.position}}
 for k,v in override or {} do request[k]=v end
 local started=os.clock()
 if predict~=false then Presentation:PredictShot(id,tool,aim,request) end
 local elapsed=os.clock()-started
 events.WeaponAction:FireServer(tool,aim,Presentation:GetShotOrigin(),id,request)
 local deadline=os.clock()+3 repeat task.wait() until confirmations[id] or os.clock()>deadline
 return confirmations[id],elapsed
end
prepare()
record("725: eight pellets, one cartridge, immediate prediction and low-ping pose alignment",function()
 local reply,elapsed=send(101) assert(reply and reply.accepted,reply and reply.reason or "no reply")
 assert(p:GetAttribute("LastPredictedShotId")==101 and elapsed<.05)
 task.wait(.05) local state=remote:InvokeServer("snapshot")
 assert(state.ammo==1) assert(10000-state.health>150) assert(state.aligned) assert(visuals==8,"unexpected pellet replication count")
 return "damage="..(10000-state.health).."; ammo=1; visual packets="..visuals.."; prediction ms="..elapsed*1000
end)
record("early second trigger and invalid camera vector are rejected without consuming ammo",function()
 local reply=send(102,nil,false) assert(reply and not reply.accepted and reply.reason=="cadence")
 local invalid=send(103,{cameraDirection=Vector3.zero},false) assert(invalid and not invalid.accepted and invalid.reason=="vector")
 assert(remote:InvokeServer("snapshot").ammo==1) return "cadence/vector rejected"
end)
record("near cover blocks all pellets; 725 reload restores two rounds from finite reserve",function()
 task.wait(.6) remote:InvokeServer("wall",{origin=cameraOrigin,direction=cameraDirection})
 local before=remote:InvokeServer("snapshot")
 local reply=send(104) assert(reply and reply.accepted)
 task.wait(.1) local state=remote:InvokeServer("snapshot") assert(state.health==before.health) assert(state.reloading)
 task.wait(2.4) state=remote:InvokeServer("snapshot") assert(state.ammo==2 and state.reserve==30 and not state.reloading)
 return "no wall damage; magazine=2 reserve=30"
end)
record("SPAS-12: semi-auto pellets, own model and animated reload",function()
 remote:InvokeServer("configure","Demolidor") prepare()
 assert(tool:GetAttribute("WeaponId")=="SPAS12")
 local reply=send(105) assert(reply and reply.accepted)
 local state=remote:InvokeServer("snapshot") assert(state.ammo==7 and 10000-state.health>=120)
 events.WeaponReload:FireServer(tool) task.wait(.5)
 assert(tool:GetAttribute("Reloading")) assert(p.PlayerGui:FindFirstChild("FirstPersonDisplay") or not p:GetAttribute("FirstPerson"))
 task.wait(2.8) state=remote:InvokeServer("snapshot") assert(state.ammo==8 and state.reserve==47 and not state.reloading)
 return "eight pellets; magazine 8 -> 7 -> 8; reserve 48 -> 47"
end)
record("pending CTF loadout changes only on respawn; eliminator view remains until then",function()
 game.ReplicatedStorage.Crossgrounds.Remotes.SelectLoadout:FireServer("ctf","Invasor")
 task.wait(.2) assert(p:GetAttribute("SelectedKit")=="Demolidor")
 assert(p:GetAttribute("PendingCTFLoadout")=="Invasor")
 local dead=remote:InvokeServer("kill")
 local deadline=os.clock()+1 repeat Run.RenderStepped:Wait() until p:GetAttribute("SpectatingEliminator") or os.clock()>deadline
 assert(p:GetAttribute("SpectatingEliminator"),"spectator did not start")
 for _=1,4 do Run.RenderStepped:Wait() end
 assert(workspace.CurrentCamera.CameraType==Enum.CameraType.Scriptable,"camera not owned after rendered frames")
 assert(p.PlayerGui.EliminatorView.Eliminator.Visible) assert(not p.PlayerGui.WeaponHUD.Crosshair.Visible)
 task.wait(.4) assert(p:GetAttribute("SpectatingEliminator"),"spectator ended before respawn")
 local limit=os.clock()+12 repeat task.wait(.1) until p.Character~=dead or os.clock()>limit
 assert(p.Character~=dead,"respawn timed out") task.wait(.7)
 assert(not p:GetAttribute("SpectatingEliminator")) assert(p:GetAttribute("SelectedKit")=="Invasor")
 assert(p.Character:FindFirstChildOfClass("Tool"):GetAttribute("WeaponId")=="Shotgun725")
 return "spectated enemy; original respawn time preserved; new character equipped pending 725"
end)
conn:Disconnect() viz:Disconnect() remote:InvokeServer("finish")

