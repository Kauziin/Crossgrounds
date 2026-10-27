-- Server-owned P0 interactions. Round outcomes remain in GetOutRound.
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local T=require(game.ReplicatedStorage.Crossgrounds.GetOutPrototype)
local Traversal=require(script.Parent.GetOutTraversal)
local Gameplay={} Gameplay.__index=Gameplay
local function actor(p)
 local c=p and p.Character local h=c and c:FindFirstChildOfClass("Humanoid") local r=c and c:FindFirstChild("HumanoidRootPart")
 if c and c:IsDescendantOf(workspace) and h and h.Health>0 and r then return r,h,c end
end
local function now() return workspace:GetServerTimeNow() end
local function sound(part,pitch)
 local s=Instance.new("Sound") s.SoundId="rbxasset://sounds/volume_slider.ogg" s.Volume=.35 s.PlaybackSpeed=pitch or 1 s.RollOffMaxDistance=36 s.Parent=part s:Play() Debris:AddItem(s,3)
end
function Gameplay.new(adapter)
 return setmetatable({adapter=adapter,traversal=Traversal.new(),states={},terminals={},jobs={},doors={},clock=0},Gameplay)
end
function Gameplay:Active(p)
 local a=self.adapter
 return a.members[p] and a.round and (a.phase=="playing" or a.phase=="enraged") and p:GetAttribute("CrossgroundsMode")=="get_out" and not p:GetAttribute("CrossgroundsTransition") and actor(p)~=nil
end
function Gameplay:CanAct(p)
 local s=self.states[p]
 return self:Active(p) and (p==self.adapter.beast or self.adapter.round:IsActive(p)) and (not s or s.kind=="Active" or s.kind=="Crawling")
end
function Gameplay:Visible(from,to,ignore)
 local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude rp.FilterDescendantsInstances=ignore or {} rp.RespectCanCollide=true
 return workspace:Raycast(from,to-from,rp)==nil
end
function Gameplay:CancelHack(p)
 local job=self.jobs[p] if not job then return end
 job.terminal.users[p]=nil self.jobs[p]=nil p:SetAttribute("GetOutHacking",false)
end
function Gameplay:SetState(p,kind)
 self:CancelHack(p)
 local old=self.states[p] or {} old.kind=kind self.states[p]=old
 p:SetAttribute("GetOutVictimState",kind)
 self.traversal:Set(p,kind=="Active" and "Standing" or kind)
end
function Gameplay:Bind(p,speed)
 self:CleanPlayer(p)
 self.traversal:Bind(p,self.adapter.roles[p],speed)
 self.states[p]={kind="Active",freeze=0}
 p:SetAttribute("GetOutVictimState","Active")
 if p==self.adapter.beast then
  local r,h,c=actor(p) if not r then return end
  local tool=Instance.new("Tool") tool.Name="Martelo de contenção" tool.CanBeDropped=false tool.ManualActivationOnly=true
  local handle=Instance.new("Part") handle.Name="Handle" handle.Size=Vector3.new(.35,3,.35) handle.Color=Color3.fromRGB(92,69,50) handle.CanCollide=false handle.Massless=true handle.Parent=tool
  local head=Instance.new("Part") head.Name="Head" head.Size=Vector3.new(2.5,1,1) head.Color=Color3.fromRGB(102,124,139) head.CanCollide=false head.Massless=true head.CFrame=handle.CFrame*CFrame.new(0,1.2,0) head.Parent=tool
  local weld=Instance.new("WeldConstraint") weld.Part0=handle weld.Part1=head weld.Parent=head
  tool.Parent=c h:EquipTool(tool) self.hammer=tool self.grip=tool.Grip
 end
end
function Gameplay:Drop()
 local p=self.dragged self.dragged=nil
 if self.ropeObjects then for _,v in self.ropeObjects do v:Destroy() end self.ropeObjects=nil end
 if p and self.states[p] and self.states[p].kind=="Dragged" then self:SetState(p,"Downed") self.states[p].recoverAt=now()+T.DownedSeconds end
 local beast=self.traversal.records[self.adapter.beast]
 if beast and beast.h.Parent then beast.h.WalkSpeed=beast.speed end
end
function Gameplay:CleanPlayer(p)
 self:CancelHack(p)
 if self.dragged==p or p==self.adapter.beast then self:Drop() end
 local s=self.states[p]
 if s and s.pod then s.pod:SetAttribute("OccupantUserId",nil) end
 self.traversal:Restore(p) self.states[p]=nil self.adapter.pods[p]=nil
 for _,key in {"GetOutVictimState","GetOutHacking","GetOutFreeze","GetOutFreezePaused","GetOutHidden","GetOutPodState"} do p:SetAttribute(key,nil) end
 local c=p.Character if c then local tool=c:FindFirstChild("Martelo de contenção") if tool then tool:Destroy() end end
end
function Gameplay:Reset()
 self:Drop()
 local list={} for p in self.states do table.insert(list,p) end for _,p in list do self:CleanPlayer(p) end
 for _,d in self.doors do if d.tween then d.tween:Cancel() end end
 table.clear(self.doors) table.clear(self.terminals) table.clear(self.jobs)
 self.hammer=nil self.attackAt=0
end
function Gameplay:Down(p)
 if not self:CanAct(p) or p==self.adapter.beast then return false end
 self:SetState(p,"Downed") self.states[p].recoverAt=now()+T.DownedSeconds
 local r=actor(p) if r then sound(r,.65) end
 return true
end
function Gameplay:Attack(p)
 if p~=self.adapter.beast or not self:CanAct(p) or self.dragged or now()<(self.attackAt or 0) then return end
 self.attackAt=now()+T.AttackCooldown
 local a=self.adapter local serial=a.serial local hammer=self.hammer
 if not hammer or not hammer.Parent then return end
 sound(hammer.Handle,1.4)
 local swing=Tween:Create(hammer,TweenInfo.new(T.AttackWindup),{Grip=self.grip*CFrame.Angles(-1.4,0,0)}) swing:Play()
 task.spawn(function()
  local completed=swing.Completed:Wait()
  if completed~=Enum.PlaybackState.Completed or a.serial~=serial or not self:CanAct(p) then return end
  local r=actor(p) if not r then return end
  local chosen,nearest=nil,T.AttackRange
  for target in a.members do
   local tr=actor(target)
   if target~=p and tr and self:CanAct(target) then
    local delta=tr.Position-r.Position local distance=delta.Magnitude
    if distance<nearest and distance>.01 and r.CFrame.LookVector:Dot(delta.Unit)>=T.AttackArcCos and self:Visible(r.Position,tr.Position,{p.Character,target.Character}) then chosen=target nearest=distance end
   end
  end
  if chosen then self:Down(chosen) end
  if hammer.Parent then Tween:Create(hammer,TweenInfo.new(.3),{Grip=self.grip}):Play() end
  a:Publish()
 end)
end
function Gameplay:Leash(p)
 if self.dragged or not self:Active(self.adapter.beast) then return false end
 local r=actor(p) local br=actor(self.adapter.beast) local s=self.states[p]
 if not r or not br or not s or s.kind~="Downed" or (r.Position-br.Position).Magnitude>T.LeashRange or not self:Visible(br.Position,r.Position,{p.Character,self.adapter.beast.Character}) then return false end
 self:SetState(p,"Dragged") self.dragged=p
 local a=Instance.new("Attachment") a.Position=Vector3.new(0,-1,3.5) a.Parent=br
 local b=Instance.new("Attachment") b.Parent=r
 local rope=Instance.new("RopeConstraint") rope.Attachment0=a rope.Attachment1=b rope.Length=T.DragLength rope.Visible=true rope.Thickness=.12 rope.Restitution=0 rope.Parent=r
 local pull=Instance.new("AlignPosition") pull.Attachment0=b pull.Attachment1=a pull.MaxForce=math.max(1000,r.AssemblyMass*450) pull.MaxVelocity=14 pull.Responsiveness=8 pull.ApplyAtCenterOfMass=true pull.Parent=r
 self.ropeObjects={rope,pull,a,b} pcall(function() r:SetNetworkOwner(nil) end)
 local _,h=actor(self.adapter.beast) if h then h.WalkSpeed=T.DragWalkSpeed end
 return true
end
function Gameplay:Pod(marker)
 local p=self.dragged local r=actor(p) local br=actor(self.adapter.beast) local s=p and self.states[p]
 if not p or not r or not br or not s or s.kind~="Dragged" or marker:GetAttribute("OccupantUserId") or marker:GetAttribute("PodState")=="Consumed" or (br.Position-marker.Position).Magnitude>9 or (r.Position-marker.Position).Magnitude>13 or not self:Visible(br.Position,marker.Position,{p.Character,self.adapter.beast.Character}) then return false end
 self:Drop() self:SetState(p,"Captured") s=self.states[p] s.pod=marker
 marker:SetAttribute("OccupantUserId",p.UserId) marker:SetAttribute("PodState","Occupied")
 self.adapter.pods[p]={marker=marker}
 r.AssemblyLinearVelocity=Vector3.zero r.Anchored=true p.Character:PivotTo(marker.CFrame)
 p:SetAttribute("GetOutPodState",true) sound(marker,.8) return true
end
function Gameplay:Rescue(marker,rescuer)
 if not self:CanAct(rescuer) or rescuer==self.adapter.beast then return false,"rescuer_not_active" end
 local target for p,s in self.states do if s.pod==marker and s.kind=="Captured" then target=p break end end
 if not target then return false,"pod_empty" end
 local r=actor(target) if not r then return false,"victim_character_missing" end
 local exit=marker:FindFirstChild("RescueExit") local cf=exit and exit.WorldCFrame or marker.CFrame*CFrame.new(0,0,-6)
 local params=OverlapParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={target.Character,rescuer.Character,marker} params.RespectCanCollide=true
 local blockers=workspace:GetPartBoundsInBox(cf,Vector3.new(2.5,5,2.5),params)
 if #blockers>0 then return false,"rescue_exit_blocked:"..blockers[1]:GetFullName() end
 self.states[target].pod=nil self.adapter.pods[target]=nil marker:SetAttribute("OccupantUserId",nil) marker:SetAttribute("PodState","Available")
 r.Anchored=false r.AssemblyLinearVelocity=Vector3.zero target.Character:PivotTo(cf)
 self:SetState(target,"Active") target:SetAttribute("GetOutPodState",false)
 if not T.CumulativeFreeze then self.states[target].freeze=0 end
 sound(marker,1.2) return true
end
function Gameplay:StartHack(p,id,slot)
 local terminal=self.terminals[id]
 if not terminal or not self:CanAct(p) or p==self.adapter.beast or terminal.completed or now()<terminal.errorUntil then return end
 local r=actor(p) if not r or (r.Position-slot.WorldPosition).Magnitude>4 then return end
 for _,job in terminal.users do if job.slot==slot then return end end
 self:CancelHack(p)
 local job={terminal=terminal,id=id,slot=slot,nextCheck=now()+T.CheckInterval,sequence=0}
 terminal.users[p]=job self.jobs[p]=job p:SetAttribute("GetOutHacking",true)
end
function Gameplay:FailHack(p,job)
 local t=job.terminal t.errorUntil=now()+T.ErrorSeconds t.marker.Color=Color3.fromRGB(214,65,65)
 sound(t.marker,.6)
 local a=self.adapter if a.beast and a.beast.Parent then a.feedbackRemote:FireClient(a.beast,"HackError",t.marker.Position) end
 self:CancelHack(p)
end
function Gameplay:Check(p,sequence)
 local job=self.jobs[p] if not job or not job.checkAt or sequence~=job.sequence then return end
 if now()<job.checkAt or now()>job.checkAt+T.CheckWindow then self:FailHack(p,job) return end
 job.checkAt=nil job.nextCheck=now()+T.CheckInterval sound(job.terminal.marker,1.2)
end
function Gameplay:DoorClear(door)
 local params=OverlapParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={self.adapter.maps.world}
 for _,p in workspace:GetPartBoundsInBox(door.closed,door.part.Size+Vector3.new(6,0,2),params) do
  if p.CanCollide or p:FindFirstAncestorOfClass("Model") and p:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid") then return false end
 end return true
end
function Gameplay:ToggleDoor(door)
 if door.busy or not self:DoorClear(door) then return false end
 door.busy=true local opening=not door.open
 door.marker:SetAttribute("DoorState",opening and "Opening" or "Closing")
 door.part.CanCollide=false
 door.blocker.CanCollide=true
 local target=opening and door.hinge*CFrame.Angles(0,math.pi/2,0)*door.offset or door.closed
 door.tween=Tween:Create(door.part,TweenInfo.new(T.DoorCloseSeconds),{CFrame=target}) sound(door.part)
 door.tween:Play()
 task.spawn(function()
  local state=door.tween.Completed:Wait()
  if not door.part.Parent or state~=Enum.PlaybackState.Completed then return end
  door.open=opening door.busy=false door.part.CanCollide=not opening door.blocker.CanCollide=false
  door.marker:SetAttribute("DoorState",opening and "Open" or "Closed")
  for _,p in door.prompts do p.ActionText=opening and "Fechar porta" or "Abrir porta" end
 end)
 return true
end
function Gameplay:Build()
 local a=self.adapter local data=a.maps.manifest.routes.locks
 for id,marker in data.computers do
  local t={marker=marker,progress=0,errorUntil=0,users={},completed=false} self.terminals[id]=t
  for _,slot in marker:GetChildren() do if slot:IsA("Attachment") and slot.Name:match("^HackSlot") then
   local prompt=a:Prompt(marker,"Hackear terminal",.2,"survivor",function(p) self:StartHack(p,id,slot) end)
   prompt.Parent=slot prompt.MaxActivationDistance=4
  end end
 end
 for _,marker in data.pods do
  marker:SetAttribute("PodState","Available")
  a:Prompt(marker,"Aprisionar vítima",.6,"beast",function() if self:Pod(marker) then a:Publish() end end)
  a:Prompt(marker,"Resgatar aliado",T.RescueSeconds,"survivor",function(p) if self:Rescue(marker,p) then a:Publish() end end)
 end
 local traversal=a.maps.manifest.root:FindFirstChild("Traversal")
 for _,marker in traversal and traversal:GetChildren() or {} do
  if marker:GetAttribute("Kind")=="RegularDoor" then
   local part for _,v in a.maps.world.Geometry:GetDescendants() do if v:GetAttribute("RegularDoorId")==marker:GetAttribute("DoorId") then part=v break end end
   if part then
    local hinge=marker:GetAttribute("Hinge") local blocker=part:Clone() blocker.Name="DoorSafetyBlocker" blocker.Transparency=1 blocker.CanCollide=false blocker.Parent=part.Parent blocker:SetAttribute("RegularDoorId",nil)
    local door={part=part,closed=part.CFrame,hinge=hinge,offset=hinge:ToObjectSpace(part.CFrame),marker=marker,prompts={},blocker=blocker}
    table.insert(self.doors,door) marker:SetAttribute("DoorState","Closed")
    for _,role in {"survivor","beast"} do table.insert(door.prompts,a:Prompt(marker,"Abrir porta",role=="beast" and T.DoorSecondsBeast or T.DoorSecondsSurvivor,role,function() self:ToggleDoor(door) end)) end
   end
  end
 end
end
function Gameplay:Attach(p)
 local r=actor(p) if not r then return end
 local prompt=self.adapter:Prompt(r,"Prender corda",.4,"beast",function() if self:Leash(p) then self.adapter:Publish() end end)
 prompt.Name="GetOutCapture" prompt.MaxActivationDistance=T.LeashRange
end
function Gameplay:Action(p,action,value)
 if not self:Active(p) then return end
 if action=="Attack" then self:Attack(p)
 elseif action=="CrawlMove" and self.states[p] and self.states[p].kind=="Crawling" then self.traversal:Move(p,value)
 elseif action=="Drop" and p==self.adapter.beast then self:Drop()
 elseif action=="Check" and typeof(value)=="number" then self:Check(p,value)
 elseif action=="CancelHack" then self:CancelHack(p)
 elseif action=="Crawl" and self:CanAct(p) and p~=self.adapter.beast then
  local kind=self.states[p].kind=="Crawling" and "Standing" or "Crawling"
  if self.traversal:Set(p,kind) then self:CancelHack(p) self.states[p].kind=kind=="Standing" and "Active" or kind p:SetAttribute("GetOutVictimState",self.states[p].kind) end
 end
end
function Gameplay:Snapshot(p)
 local s=self.states[p] local job=self.jobs[p]
 return {victim=s and s.kind,freeze=s and s.freeze or 0,freezePaused=s and s.paused,dragging=p==self.adapter.beast and self.dragged and self.dragged.DisplayName or nil,
  hack=job and {progress=job.terminal.progress,checkAt=job.checkAt,checkEnd=job.checkAt and job.checkAt+T.CheckWindow,sequence=job.sequence} or nil}
end
function Gameplay:Tick(dt)
 local a=self.adapter local time=now()
 for p,job in self.jobs do
  local r=actor(p)
  if not self:CanAct(p) or not r or (r.Position-job.slot.WorldPosition).Magnitude>4 then self:CancelHack(p)
  elseif job.checkAt and time>job.checkAt+T.CheckWindow then self:FailHack(p,job)
  elseif not job.checkAt and time>=job.nextCheck then job.sequence+=1 job.checkAt=time+T.CheckLead end
 end
 for id,t in self.terminals do
  if not t.completed and time>=t.errorUntil then
   local users=0 local participant
   for p in t.users do users+=1 participant=p end
   t.progress=math.min(1,t.progress+dt*users/T.HackSeconds)
   t.marker:SetAttribute("HackProgress",t.progress)
   t.marker.Color=Color3.fromRGB(59,136,173)
   if t.progress>=1 and participant and a.round:CompleteComputer(participant,id) then
    t.completed=true t.marker.Color=Color3.fromRGB(70,196,157) sound(t.marker,1.5)
    for _,prompt in t.marker:GetDescendants() do if prompt:IsA("ProximityPrompt") then prompt.Enabled=false end end
    local list={} for p in t.users do table.insert(list,p) end for _,p in list do self:CancelHack(p) end
    if a.round.exitReady then for _,lock in a.maps.manifest.routes.locks.locks do lock.Color=Color3.fromRGB(70,196,157) end for _,prompt in a.crankPrompts do prompt.Enabled=true end end
   end
  end
 end
 local br=actor(a.beast)
 for _,pod in a.maps.manifest.routes.locks.pods do
  local occupied=pod:GetAttribute("OccupantUserId")~=nil
  for _,prompt in pod:GetChildren() do if prompt:IsA("ProximityPrompt") then
   prompt.Enabled=prompt:GetAttribute("GetOutRole")=="beast" and not occupied and pod:GetAttribute("PodState")~="Consumed" and self.dragged~=nil or prompt:GetAttribute("GetOutRole")=="survivor" and occupied
  end end
 end
 for p,s in self.states do
  local r=actor(p)
  local prompt=r and r:FindFirstChild("GetOutCapture") if prompt then prompt.Enabled=s.kind=="Downed" and not self.dragged end
  if s.kind=="Downed" and time>=(s.recoverAt or math.huge) then
   if self.traversal:CanStand(p) then self:SetState(p,"Active") else self:SetState(p,"Crawling") end
  elseif s.kind=="Dragged" then
   if r and br and not self:Visible(br.Position,r.Position,{p.Character,a.beast.Character}) then s.blockedFor=(s.blockedFor or 0)+dt else s.blockedFor=0 end
   if not r or not br or (r.Position-br.Position).Magnitude>T.DragBreakDistance or s.blockedFor>2 then self:Drop() end
  elseif s.kind=="Captured" and s.pod then
   s.paused=br~=nil and (br.Position-s.pod.Position).Magnitude<T.AntiCampRadius
   if not s.paused then s.freeze=math.min(1,(s.freeze or 0)+dt/T.PodSeconds) end
   p:SetAttribute("GetOutFreeze",s.freeze) p:SetAttribute("GetOutFreezePaused",s.paused)
   if s.freeze>=1 then
    local marker=s.pod s.pod=nil marker:SetAttribute("OccupantUserId",nil) marker:SetAttribute("PodState",T.PodReusable and "Available" or "Consumed")
    a.pods[p]=nil self:SetState(p,"Frozen") if r then r.Anchored=false p.Character:PivotTo(a:StagingPosition(p)) p.Character.Humanoid:MoveTo(r.Position) end
    a.round:Capture(p) p:SetAttribute("GetOutResult","captured") a:CheckRoundFinished()
   end
  end
 end
 local traversal=a.maps.manifest.root:FindFirstChild("Traversal")
 for _,marker in traversal and traversal:GetChildren() or {} do
  if marker:GetAttribute("Kind")=="HideSpot" then
   local occupant
   for p in a.members do
    local r=actor(p) local hidden=false
    if r and p~=a.beast and self:CanAct(p) and not occupant then
     local v=marker.CFrame:PointToObjectSpace(r.Position) local half=marker.Size*.5
     hidden=math.abs(v.X)<half.X and math.abs(v.Y)<half.Y and math.abs(v.Z)<half.Z
     if hidden then occupant=p end
    end
    p:SetAttribute("GetOutHidden",hidden)
   end
   marker:SetAttribute("OccupantUserId",occupant and occupant.UserId or nil)
  end
 end
end
function Gameplay:Rollback()
 for id,t in self.terminals do if t.completed and not self.adapter.round.completedPCs[id] then
  t.completed=false t.progress=0 t.marker:SetAttribute("HackProgress",0)
  for _,prompt in t.marker:GetDescendants() do if prompt:IsA("ProximityPrompt") then prompt.Enabled=true end end
 end end
end
return Gameplay

