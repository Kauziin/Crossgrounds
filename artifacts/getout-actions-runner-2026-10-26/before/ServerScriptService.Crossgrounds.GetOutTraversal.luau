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
 if r.h.Parent then r.h.HipHeight=r.hip r.h.PlatformStand=false r.h.AutoRotate=true r.h.WalkSpeed=r.speed r.h.JumpHeight=r.jump end
 if r.root.Parent then r.root.Anchored=false r.root.AssemblyLinearVelocity=Vector3.zero r.root.AssemblyAngularVelocity=Vector3.zero pcall(function() r.root:SetNetworkOwnershipAuto() end) end
 player:SetAttribute("GetOutPosture",nil)
end
function Traversal:Bind(player,role,speed)
 self:Restore(player)
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") local root=c and c:FindFirstChild("HumanoidRootPart")
 if not h or not root then return end
 local r={character=c,h=h,root=root,hip=h.HipHeight,speed=speed,jump=h.JumpHeight,parts={},role=role,low=false}
 local function register(p)
  if not p:IsA("BasePart") or p.Name=="GetOutCrawlCollider" or p:FindFirstAncestorOfClass("Tool") then return end
  r.parts[p]={group=p.CollisionGroup,collide=p.CanCollide,massless=p.Massless}
  p.CollisionGroup=r.low and "GetOutBody" or role=="beast" and "GetOutBeast" or "GetOutHuman"
 end
 for _,p in c:GetDescendants() do register(p) end
 r.connection=c.DescendantAdded:Connect(register)
 self.records[player]=r player:SetAttribute("GetOutPosture","Standing")
 return r
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
 r.state=state
 local mobile=state=="Standing" or state=="Crawling"
 r.h.WalkSpeed=state=="Crawling" and T.CrawlSpeed or mobile and r.speed or 0
 r.h.JumpHeight=state=="Standing" and r.jump or 0
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
 r.lastMove=workspace:GetServerTimeNow() r.velocity.PlaneVelocity=Vector2.new(planar.X,planar.Z)*T.CrawlSpeed
 if planar.Magnitude>.05 then r.orientation.CFrame=CFrame.lookAt(Vector3.zero,planar.Unit) end
 return true
end
return Traversal

