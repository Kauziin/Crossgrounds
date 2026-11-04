-- One owner for the character's Get Out collision, posture and movement overrides.
local Physics=game:GetService("PhysicsService")
local Run=game:GetService("RunService")
local T=require(game.ReplicatedStorage.Crossgrounds.GetOutPrototype)
local Traversal={} Traversal.__index=Traversal
local groups={"GetOutHuman","GetOutBeast","GetOutBody","GetOutVent","GetOutIncapacitated"}
for _,name in groups do if not Physics:IsCollisionGroupRegistered(name) then Physics:RegisterCollisionGroup(name) end end
for _,group in Physics:GetRegisteredCollisionGroups() do Physics:CollisionGroupSetCollidable("GetOutBody",group.name,false) end
Physics:CollisionGroupSetCollidable("GetOutHuman","GetOutVent",false)
Physics:CollisionGroupSetCollidable("GetOutBeast","GetOutVent",true)
Physics:CollisionGroupSetCollidable("GetOutHuman","GetOutHuman",false)
Physics:CollisionGroupSetCollidable("GetOutIncapacitated","GetOutBeast",false)
Physics:CollisionGroupSetCollidable("GetOutIncapacitated","GetOutHuman",false)
Physics:CollisionGroupSetCollidable("GetOutIncapacitated","GetOutVent",true)

function Traversal.new() return setmetatable({records={}},Traversal) end
function Traversal:Restore(player)
 local r=self.records[player] if not r then return end
 self.records[player]=nil
 if r.connection then r.connection:Disconnect() end
 if r.crawlConnection then r.crawlConnection:Disconnect() end
 if r.crawlObjects then for _,v in r.crawlObjects do v:Destroy() end end
 if r.collider then r.collider:Destroy() end
 for part,old in r.parts do if part.Parent then part.CollisionGroup=old.group part.CanCollide=old.collide part.Massless=old.massless end end
 if r.h.Parent then r.h.HipHeight=r.hip r.h.PlatformStand=false r.h.AutoRotate=true r.h.WalkSpeed=r.speed r.h.JumpHeight=r.jump r.h:SetStateEnabled(Enum.HumanoidStateType.Jumping,r.jumpEnabled)end
 if r.root.Parent then r.root.Anchored=false r.root.AssemblyLinearVelocity=Vector3.zero r.root.AssemblyAngularVelocity=Vector3.zero pcall(function() r.root:SetNetworkOwnershipAuto() end) end
 player:SetAttribute("GetOutPosture",nil)
 for _,key in {"GetOutJumpBlocked","GetOutRunnerUntil","GetOutWindowSlowUntil","GetOutStandingRootHeight"}do player:SetAttribute(key,nil)end
end
function Traversal:Bind(player,role,speed)
 self:Restore(player)
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") local root=c and c:FindFirstChild("HumanoidRootPart")
 if not h or not root then return end
 local r={character=c,h=h,root=root,hip=h.HipHeight,speed=speed,jump=math.min(h.JumpHeight,T.JumpHeight),jumpEnabled=h:GetStateEnabled(Enum.HumanoidStateType.Jumping),parts={},role=role,low=false,state="Standing",windowSides={}}
 local head=c:FindFirstChild("Head")
 if head then
  local headHeight=head.Position.Y-root.Position.Y+head.Size.Y*.5+h.HipHeight+root.Size.Y*.5
  r.jump=math.max(0,math.min(r.jump,T.WindowHeadClearance-headHeight-.45))
 end
 local function register(p)
  if not p:IsA("BasePart") or p.Name=="GetOutCrawlCollider" or p:FindFirstAncestorOfClass("Tool") then return end
  r.parts[p]={group=p.CollisionGroup,collide=p.CanCollide,massless=p.Massless}
  p.CollisionGroup=r.low and "GetOutBody" or role=="beast" and "GetOutBeast" or "GetOutHuman"
 end
 for _,p in c:GetDescendants() do register(p) end
 r.connection=c.DescendantAdded:Connect(register)
 self.records[player]=r player:SetAttribute("GetOutPosture","Standing")
 local leg=c:FindFirstChild("Left Leg")
 player:SetAttribute("GetOutStandingRootHeight",r.hip+root.Size.Y*.5+(leg and leg.Size.Y or 0))
 return r
end
function Traversal:UpdateMovement(player)
 local r=self.records[player]if not r or not r.h.Parent then return end
 local time=workspace:GetServerTimeNow()local standing=r.state=="Standing"
 local boost=time<(r.runnerUntil or 0)local slow=time<(r.windowUntil or 0)
 local speed=r.dragging and T.DragWalkSpeed or r.speed
 if boost then speed*=T.RunnerSpeedMultiplier end if slow then speed*=T.WindowSpeedMultiplier end
 r.h.WalkSpeed=standing and speed or r.state=="Crawling"and T.CrawlSpeed or 0
 local jump=standing and not boost
 r.h.JumpHeight=jump and r.jump or 0 r.h:SetStateEnabled(Enum.HumanoidStateType.Jumping,jump)
 if not jump then r.h.Jump=false end
 player:SetAttribute("GetOutJumpBlocked",not jump)
end
function Traversal:Runner(player)
 local r=self.records[player]if not r or r.role~="beast"or r.state~="Standing"then return false end
 r.runnerUntil=workspace:GetServerTimeNow()+T.RunnerSeconds
 player:SetAttribute("GetOutRunnerUntil",r.runnerUntil)self:UpdateMovement(player)return true
end
function Traversal:Tick(windows)
 for player,r in self.records do
  if r.root.Parent and r.h.Parent then
   if r.role=="beast"then for _,window in windows or{}do
    local pos=window.CFrame:PointToObjectSpace(r.root.Position)local half=window.Size*.5
    local side=pos.X>half.X+.25 and 1 or pos.X< -half.X-.25 and -1 or 0
    if math.abs(pos.Z)<=half.Z+1 and math.abs(pos.Y)<=half.Y+2 then
     local previous=r.windowSides[window]
     if side~=0 then
      if previous and previous~=side then
       r.windowUntil=workspace:GetServerTimeNow()+T.WindowSlowSeconds
       player:SetAttribute("GetOutWindowSlowUntil",r.windowUntil)
       -- Clamp the carried horizontal velocity as well as the walking speed.
       local velocity=r.root.AssemblyLinearVelocity
       r.root.AssemblyLinearVelocity=Vector3.new(velocity.X*T.WindowSpeedMultiplier,velocity.Y,velocity.Z*T.WindowSpeedMultiplier)
      end
      r.windowSides[window]=side
     end
    else r.windowSides[window]=nil end
   end end
   self:UpdateMovement(player)
  end
 end
end
function Traversal:CanStand(player)
 local r=self.records[player] if not r then return false end
 local params=OverlapParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={r.character} params.RespectCanCollide=true params.CollisionGroup="GetOutHuman"
 -- Bottom stays above the floor; query the volume the restored torso/head will occupy.
 for _,p in workspace:GetPartBoundsInBox(CFrame.new(r.root.Position+Vector3.new(0,2.4,0)),Vector3.new(2.4,3.6,2.4),params) do if p.CanCollide then return false end end
 return true
end
function Traversal:Set(player,state)
 local r=self.records[player] if not r then return false end
 local low=state=="Crawling" or state=="Downed" or state=="Dragged"
 if state=="Crawling" and r.role=="beast" then return false end
 if not low and r.low and not self:CanStand(player) and state=="Standing" then return false end
 r.low=low
 for p,old in r.parts do if p.Parent then
  p.CollisionGroup=low and "GetOutBody" or r.role=="beast" and "GetOutBeast" or "GetOutHuman"
  p.Massless=low and p~=r.root or old.massless
 end end
 if low and not r.collider then
  local p=Instance.new("Part") p.Name="GetOutCrawlCollider" p.Size=Vector3.new(2,T.CrawlHeight,2.5) p.Transparency=1 p.Massless=true p.CanTouch=false p.CollisionGroup="GetOutHuman" p.CFrame=r.root.CFrame
  p.Parent=r.character local weld=Instance.new("WeldConstraint") weld.Part0=r.root weld.Part1=p weld.Parent=p r.collider=p
 elseif not low and r.collider then r.collider:Destroy() r.collider=nil end
 if r.collider then r.collider.CollisionGroup=state=="Crawling" and "GetOutHuman" or "GetOutIncapacitated" end
 r.h.HipHeight=low and (r.h.RigType==Enum.HumanoidRigType.R6 and -2 or 0) or r.hip
 if r.crawlConnection then r.crawlConnection:Disconnect() r.crawlConnection=nil end
 if r.crawlObjects then for _,v in r.crawlObjects do v:Destroy() end r.crawlObjects=nil end
 local previous=r.state r.state=state
 r.crawlReadyAt=state=="Crawling"and(previous=="Crawling"and r.crawlReadyAt or workspace:GetServerTimeNow()+T.CrawlEnterSeconds)or 0
 local mobile=state=="Standing" or state=="Crawling"
 self:UpdateMovement(player)
 r.h.AutoRotate=state=="Standing" r.h.PlatformStand=low
 if state=="Crawling" then
  local attachment=Instance.new("Attachment") attachment.Name="GetOutCrawlDrive" attachment.Parent=r.root
  local velocity=Instance.new("LinearVelocity") velocity.Name="GetOutCrawlVelocity" velocity.Attachment0=attachment velocity.RelativeTo=Enum.ActuatorRelativeTo.World velocity.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane
  velocity.PrimaryTangentAxis=Vector3.xAxis velocity.SecondaryTangentAxis=Vector3.zAxis velocity.PlaneVelocity=Vector2.zero velocity.MaxForce=math.max(5000,r.root.AssemblyMass*800) velocity.Parent=r.root
  local orientation=Instance.new("AlignOrientation") orientation.Attachment0=attachment orientation.Mode=Enum.OrientationAlignmentMode.OneAttachment orientation.MaxTorque=math.max(10000,r.root.AssemblyMass*2000) orientation.Responsiveness=20
  local forward=r.root.CFrame.LookVector*Vector3.new(1,0,1) orientation.CFrame=CFrame.lookAt(Vector3.zero,forward.Magnitude>.01 and forward.Unit or -Vector3.zAxis) orientation.Parent=r.root
  r.crawlObjects={velocity,orientation,attachment} r.velocity=velocity r.orientation=orientation r.lastMove=0
  r.root.AssemblyLinearVelocity=Vector3.zero r.root.AssemblyAngularVelocity=Vector3.zero
  pcall(function() r.root:SetNetworkOwner(nil) end)
  r.crawlConnection=Run.Heartbeat:Connect(function() if workspace:GetServerTimeNow()-r.lastMove>.4 and velocity.Parent then velocity.PlaneVelocity=Vector2.zero end end)
 elseif mobile and not r.root.Anchored then
  r.root.AssemblyLinearVelocity=Vector3.zero r.h:ChangeState(Enum.HumanoidStateType.GettingUp)
  pcall(function() r.root:SetNetworkOwnershipAuto() end)
 end
 player:SetAttribute("GetOutPosture",state)
 return true
end
function Traversal:Move(player,direction)
 local r=self.records[player]
 if not r or r.state~="Crawling" or typeof(direction)~="Vector3" then return false end
 if direction.X~=direction.X or direction.Z~=direction.Z or math.abs(direction.X)>1.1 or math.abs(direction.Z)>1.1 or math.abs(direction.Y)>.01 then return false end
 local planar=direction*Vector3.new(1,0,1) if planar.Magnitude>1 then planar=planar.Unit end
 r.lastMove=workspace:GetServerTimeNow()
 local speed=r.lastMove>=(r.crawlReadyAt or 0)and T.CrawlSpeed or 0
 r.velocity.PlaneVelocity=Vector2.new(planar.X,planar.Z)*speed
 if planar.Magnitude>.05 then r.orientation.CFrame=CFrame.lookAt(Vector3.zero,planar.Unit) end
 return true
end
return Traversal
