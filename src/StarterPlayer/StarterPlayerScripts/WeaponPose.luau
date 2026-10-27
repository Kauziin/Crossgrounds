-- Evaluate every visible R15 wielder locally, after animation evaluation.
local Pose=require(game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("ArmPose"))
local Carry=require(game.ReplicatedStorage.Crossgrounds.WeaponLocomotion)
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local active={} local pending={} local necks={} local gait=setmetatable({},{__mode="k"})
workspace.DescendantRemoving:Connect(function(v) necks[v]=nil end)
local function register(tool)
 if active[tool] or pending[tool] or not tool:GetAttribute("TwoHanded") then return end
 pending[tool]=true
 task.delay(.12,function()
  pending[tool]=nil local c=tool.Parent local h=c and c:FindFirstChildOfClass("Humanoid")
  local handle=tool:FindFirstChild("Handle") if not h or not handle or h.RigType~=Enum.HumanoidRigType.R15 then return end
  local left=Pose.Chain(c,"Left") local right=handle:FindFirstChild("RightHandGrip") and Pose.Chain(c,"Right") or nil
  active[tool]={character=c,humanoid=h,carry=Carry.new(),player=Players:GetPlayerFromCharacter(c),left=left,right=right,support=handle:FindFirstChild("SupportGrip"),grip=handle:FindFirstChild("RightHandGrip")}
 end)
end
local function added(value)
 if value:IsA("Tool") then register(value)
 elseif value:IsA("JointInstance") and value.Name=="CrossgroundsWeaponMount" and value.Part1 then
  local t=value.Part1.Parent if t and t:IsA("Tool") then register(t) end
 end
end
workspace.DescendantAdded:Connect(added)
for _,value in workspace:GetDescendants() do added(value) end
Run.PreSimulation:Connect(function(dt)
 local bots=workspace:FindFirstChild("CTFBots")
 if bots then for _,bot in bots:GetChildren() do
  local neck=necks[bot] if not neck or not neck.Parent then neck=bot:FindFirstChild("Neck",true) necks[bot]=neck end
  if neck and neck:IsA("Motor6D") then
   local phase=os.clock()*.7+(bot:GetAttribute("BotScanSeed") or 0)
   local alert=bot:GetAttribute("BotAlert")
   neck.Transform=CFrame.Angles(math.sin(phase*1.8)*.025,alert and 0 or math.sin(phase)*.18,math.sin(phase*.6)*.025)
  end
  local h=bot:FindFirstChildOfClass("Humanoid") local root=bot:FindFirstChild("HumanoidRootPart")
  if h and h.Health>0 and root then
   local speed=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z).Magnitude
   local g=gait[bot]
   if not g or os.clock()>(g.refreshAt or 0) then
    g=g or {phase=0} g.refreshAt=os.clock()+2
    for _,name in {"LeftHip","RightHip","LeftKnee","RightKnee","LeftAnkle","RightAnkle","Waist"} do g[name]=bot:FindFirstChild(name,true) end
    gait[bot]=g
   end
   local weight=h.FloorMaterial~=Enum.Material.Air and math.clamp(speed/16,0,1) or 0
   g.phase+=dt*math.clamp(speed*.7,0,14)
   for _,side in {"Left","Right"} do
    local swing=math.sin(g.phase+(side=="Left" and 0 or math.pi))*weight
    local hip=g[side.."Hip"] local knee=g[side.."Knee"] local ankle=g[side.."Ankle"]
    if hip then hip.Transform=CFrame.Angles(swing*.55,0,0) end
    if knee then knee.Transform=CFrame.Angles(math.max(0,-swing)*.85,0,0) end
    if ankle then ankle.Transform=CFrame.Angles(-swing*.20,0,0) end
   end
   if g.Waist then g.Waist.Transform=CFrame.new(0,math.sin(g.phase*2)*.025*weight,0)*CFrame.Angles(weight*.07,math.sin(g.phase)*.035*weight,0) end
  end
 end end
 for tool,r in active do
  if tool.Parent~=r.character or not r.character.Parent or r.humanoid.Health<=0 then if r.mount and r.mount.Parent then r.mount.Transform=CFrame.new() end active[tool]=nil
  elseif tool:GetAttribute("SupportGripActive") then
   -- Avatar descriptions can replace limbs/joints after equipping.
   if not r.refreshAt or os.clock()>=r.refreshAt then
    r.left=Pose.Chain(r.character,"Left") r.right=r.grip and Pose.Chain(r.character,"Right") or nil r.refreshAt=os.clock()+.5
   end
   local torso=r.character:FindFirstChild("UpperTorso") local root=r.character:FindFirstChild("HumanoidRootPart")
   local mount=torso and torso:FindFirstChild("CrossgroundsWeaponMount") r.mount=mount
   local desired
   if mount and mount.Part1==tool.Handle and root then
    local velocity=root.CFrame:VectorToObjectSpace(root.AssemblyLinearVelocity)
    local amount=r.player and r.player:GetAttribute("SettingCameraMotion") if amount==nil then amount=.35 end
    local running=r.player and r.player:GetAttribute("SprintActive")==true
    local aiming=r.player and r.player:GetAttribute("CombatAiming")==true
    local firing=r.player and r.player:GetAttribute("CombatFiring")==true
    local pose=r.carry:Update(dt,velocity,r.humanoid.FloorMaterial~=Enum.Material.Air,running,aiming,firing or tool:GetAttribute("Reloading") or tool:GetAttribute("Attacking"),amount)
    mount.Transform=pose desired=torso.CFrame*mount.C0*pose*mount.C1:Inverse()
   end
   if r.right and r.grip and r.grip.Parent then Pose.Solve(r.right,r.grip,desired and desired*r.grip.CFrame) end
   if r.left and r.support and r.support.Parent then Pose.Solve(r.left,r.support,desired and desired*r.support.CFrame) end
  end
 end
end)
