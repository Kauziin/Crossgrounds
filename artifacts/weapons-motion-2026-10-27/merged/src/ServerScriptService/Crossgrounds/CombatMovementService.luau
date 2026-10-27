-- The server owns slide eligibility, duration, obstruction and cleanup.
local Service={}
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Rules=require(game.ReplicatedStorage.Crossgrounds.CombatMovement)
local active={} local last={} local requests={} local started=false
local poseRequests={}
local function playing(p)
 local mode=p:GetAttribute("CrossgroundsMode")
 return mode=="ctf" and p:GetAttribute("InMatch")==true or mode=="arena" and p:GetAttribute("ArenaPlaying")==true
end
local function blocked(p)
 return p:GetAttribute("CrossgroundsTransition") or p:GetAttribute("AdminFreecam")
  or p:GetAttribute("GameMenuOpen") or p:GetAttribute("ExperienceMenuOpen")
  or p:GetAttribute("ArenaVotingOpen") or p:GetAttribute("SpectatingEliminator")
end
function Service:Stop(p,reason)
 local s=active[p] if not s then return end active[p]=nil
 s.velocity:Destroy() s.attachment:Destroy()
 if s.root.Parent then pcall(function() s.root:SetNetworkOwnershipAuto() end) end
 if p.Character==s.character and s.humanoid.Parent and s.humanoid.Health>0 and playing(p) then
  s.humanoid.WalkSpeed=p:GetAttribute("SprintActive") and (p:GetAttribute("KitSprintSpeed") or 25) or (p:GetAttribute("KitWalkSpeed") or 18)
 end
 p:SetAttribute("SlideActive",false) p:SetAttribute("SlideExitReason",reason or "complete")
 if s.character.Parent then s.character:SetAttribute("SlideActive",false) end
end
function Service:Request(p,on)
 if on==false then self:Stop(p,"cancelled") return false end
 local now=os.clock()
 if now-(requests[p] or -100)<.12 then return false end requests[p]=now
 if active[p] then return false end
 local c=p.Character local h=c and c:FindFirstChildOfClass("Humanoid") local root=c and c:FindFirstChild("HumanoidRootPart")
 if not h or not root then return false end
 local flat=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z)
 if not Rules.CanSlide({mode=p:GetAttribute("CrossgroundsMode"),playing=playing(p),alive=h.Health>0,
  grounded=h.FloorMaterial~=Enum.Material.Air and h:GetState()~=Enum.HumanoidStateType.Jumping,
  sprinting=p:GetAttribute("SprintActive"),blocked=blocked(p) or h.Sit or root.Anchored,
  speed=flat.Magnitude,cooldown=Rules.Cooldown-(now-(last[p] or -100))}) then return false end
 local direction=flat.Unit
 local attachment=Instance.new("Attachment") attachment.Name="CombatSlideAttachment" attachment.Parent=root
 local velocity=Instance.new("LinearVelocity") velocity.Name="CombatSlideVelocity"
 velocity.Attachment0=attachment velocity.RelativeTo=Enum.ActuatorRelativeTo.World
 velocity.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane
 velocity.PrimaryTangentAxis=Vector3.xAxis velocity.SecondaryTangentAxis=Vector3.zAxis
 velocity.ForceLimitsEnabled=true velocity.MaxForce=root.AssemblyMass*900
 local initial=math.min(flat.Magnitude,p:GetAttribute("KitSprintSpeed") or 25)
 velocity.PlaneVelocity=Vector2.new(direction.X,direction.Z)*initial velocity.Parent=root
 pcall(function() root:SetNetworkOwner(nil) end)
 active[p]={character=c,humanoid=h,root=root,attachment=attachment,velocity=velocity,
  start=now,initial=initial,direction=direction,tool=c:FindFirstChildOfClass("Tool"),mode=p:GetAttribute("CrossgroundsMode")}
 last[p]=now h.WalkSpeed=0
 p:SetAttribute("SlideActive",true) p:SetAttribute("SlideStartedAt",workspace:GetServerTimeNow())
 c:SetAttribute("SlideActive",true) c:SetAttribute("SlideStartedAt",workspace:GetServerTimeNow())
 c:SetAttribute("SlideDirection",direction)
 return true
end
function Service:Start()
 if started then return end started=true
 local events=game.ReplicatedStorage:WaitForChild("Events")
 local remote=events:FindFirstChild("CombatSlide") or Instance.new("RemoteEvent") remote.Name="CombatSlide" remote.Parent=events
 remote.OnServerEvent:Connect(function(p,on) if typeof(on)=="boolean" then self:Request(p,on) end end)
 local pose=events:FindFirstChild("CombatPose") or Instance.new("RemoteEvent") pose.Name="CombatPose" pose.Parent=events
 pose.OnServerEvent:Connect(function(p,pitch,aiming)
  if typeof(pitch)~="number" or pitch~=pitch or math.abs(pitch)>1.3 or typeof(aiming)~="boolean" then return end
  if os.clock()-(poseRequests[p] or -100)<.075 then return end poseRequests[p]=os.clock()
  local c=p.Character local h=c and c:FindFirstChildOfClass("Humanoid")
  if not playing(p) or blocked(p) or not h or h.Health<=0 or not c:FindFirstChildOfClass("Tool") then return end
  c:SetAttribute("CombatAimPitch",pitch) p:SetAttribute("CombatAiming",aiming)
 end)
 Run.Heartbeat:Connect(function(dt)
  for p,s in active do
   local h,root=s.humanoid,s.root local elapsed=os.clock()-s.start
   local reason
   if p.Character~=s.character or not root.Parent or not h.Parent or h.Health<=0 then reason="character"
   elseif not playing(p) or p:GetAttribute("CrossgroundsMode")~=s.mode or blocked(p) then reason="context"
   elseif h.Sit or root.Anchored then reason="state"
   elseif s.character:FindFirstChildOfClass("Tool")~=s.tool then reason="weapon"
   elseif h:GetState()==Enum.HumanoidStateType.Jumping or h.FloorMaterial==Enum.Material.Air then reason="airborne"
   elseif elapsed>=Rules.Duration then reason="complete"
   else
    local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={s.character} params.RespectCanCollide=true
    local distance=math.max(1.5,Rules.Speed(s.initial,elapsed)*math.min(dt,.05)+1)
    local hit=workspace:Blockcast(root.CFrame,Vector3.new(1.4,1.6,1.2),s.direction*distance,params)
    if hit and hit.Normal:Dot(s.direction)<-.35 then reason="obstructed" end
   end
   if reason then self:Stop(p,reason)
   else
    h.WalkSpeed=0 s.velocity.PlaneVelocity=Vector2.new(s.direction.X,s.direction.Z)*Rules.Speed(s.initial,elapsed)
   end
  end
 end)
 Players.PlayerRemoving:Connect(function(p) self:Stop(p,"removed") last[p]=nil requests[p]=nil poseRequests[p]=nil end)
end
return Service
