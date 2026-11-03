-- Evaluate every visible R15 wielder locally, after animation evaluation.
local Pose=require(game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("ArmPose"))
local Carry=require(game.ReplicatedStorage.Crossgrounds.WeaponLocomotion)
local Action=require(game.ReplicatedStorage.Crossgrounds.WeaponActionMotion)
local AX50=require(game.ReplicatedStorage.Crossgrounds.AX50Motion)
local Stats=require(game.ReplicatedStorage.Crossgrounds.WeaponStats)
local Reload=require(game.ReplicatedStorage.Crossgrounds.WeaponReloadMotion)
local Hold=require(game.ReplicatedStorage.Crossgrounds.WeaponHold)
local Locomotion=require(game.ReplicatedStorage.Crossgrounds.LocomotionMotion)
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Preferences=require(game.ReplicatedStorage.Crossgrounds.MotionPreferences)
local viewer=Players.LocalPlayer
local active={} local pending={}
local function register(tool)
 if active[tool] or pending[tool] or not tool:GetAttribute("TwoHanded") then return end
 pending[tool]=true
 task.delay(.12,function()
  pending[tool]=nil local c=tool.Parent local h=c and c:FindFirstChildOfClass("Humanoid")
  local handle=tool:FindFirstChild("Handle") if not h or not handle or h.RigType~=Enum.HumanoidRigType.R15 then return end
  local left=Pose.Chain(c,"Left") local right=handle:FindFirstChild("RightHandGrip") and Pose.Chain(c,"Right") or nil
  active[tool]={character=c,humanoid=h,carry=Carry.new(),equippedAt=os.clock(),locomotion=Locomotion.new(),kick=0,reloadMotion=Reload.new(),player=Players:GetPlayerFromCharacter(c),left=left,right=right,support=handle:FindFirstChild("SupportGrip"),grip=handle:FindFirstChild("RightHandGrip")}
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
 -- NPC locomotion belongs to the native Animator; keep weapon handling below.
 for tool,r in active do
  if tool.Parent~=r.character or not r.character.Parent or r.humanoid.Health<=0 then if r.mount and r.mount.Parent then r.mount.Transform=CFrame.new() end active[tool]=nil
  elseif tool:GetAttribute("SupportGripActive") then
   -- Avatar descriptions can replace limbs/joints after equipping.
   if not r.refreshAt or os.clock()>=r.refreshAt then
    r.left=Pose.Chain(r.character,"Left") r.right=r.grip and Pose.Chain(r.character,"Right") or nil r.refreshAt=os.clock()+.5
   end
   local torso=r.character:FindFirstChild("UpperTorso") local root=r.character:FindFirstChild("HumanoidRootPart")
   local mount=torso and torso:FindFirstChild("CrossgroundsWeaponMount") r.mount=mount
   local desired local reload local bolt
   if mount and mount.Part1==tool.Handle and root then
    local velocity=root.CFrame:VectorToObjectSpace(root.AssemblyLinearVelocity)
    local amount=r.player and r.player:GetAttribute("SettingCameraMotion") if amount==nil then amount=.35 end
    local running=r.player and r.player:GetAttribute("SprintActive")==true
    local aiming=r.player and r.player:GetAttribute("CombatAiming")==true
    local firing=r.player and r.player:GetAttribute("CombatFiring")==true
    local visualWeight=Preferences.WeaponWeight(viewer)
    local pose=r.carry:Update(dt,velocity,r.humanoid.FloorMaterial~=Enum.Material.Air,running,aiming,firing or tool:GetAttribute("Reloading") or tool:GetAttribute("Attacking"),amount)

    local now=workspace:GetServerTimeNow()
    local duration=math.max(.1,tool:GetAttribute("ReloadDuration") or 1)
    local t=tool:GetAttribute("Reloading") and math.clamp((now-(tool:GetAttribute("ReloadStartedAt") or now))/duration,0,1) or 0
    reload=r.reloadMotion:Update(tool,dt,now)
    if Hold.IsPistol(tool) then
     if not r.reloadParts then r.reloadParts={} for _,part in tool:GetChildren() do if part:IsA("BasePart") and part:GetAttribute("ReloadGroup") then for _,joint in part:GetChildren() do if joint:IsA("Motor6D") then table.insert(r.reloadParts,{part=part,joint=joint,group=part:GetAttribute("ReloadGroup"),only=part:GetAttribute("ReloadOnly")}) end end end end end
     for _,entry in r.reloadParts do if entry.joint.Parent then
      local pivot=tool.Handle:FindFirstChild("ReloadPivot_"..entry.group)
      local transform=Preferences.Transform(Reload.PartTransform(reload,entry.group,pivot and pivot.Position),visualWeight)
      entry.joint.Transform=entry.joint.C0:Inverse()*transform*entry.joint.C0
      entry.part.LocalTransparencyModifier=(reload.visibility and reload.visibility[entry.group] or 0)*visualWeight
      if entry.only then entry.part.Transparency=reload.active>.02 and visualWeight>.01 and 0 or 1 end
     end end
    end
    local loco=r.locomotion:Update(dt,velocity,r.humanoid.FloorMaterial~=Enum.Material.Air,r.character:GetAttribute("SlideActive")==true)
    local action=Action.Sample({equippedFor=os.clock()-r.equippedAt,slide=loco.slide,land=loco.land})
    local shot=tool:GetAttribute("PresentationShotAt") or -100
    if tool:GetAttribute('WeaponId')=='ax_50' then
     local data=Stats.ResolveTool(tool)
     bolt=AX50.Bolt(now-shot,data and data.Cooldown,tool:GetAttribute('Reloading'))
     if not r.bolts then
      r.bolts={}
      for _,p in tool:GetChildren() do if p:IsA('BasePart') and p.Name=='Bolt' then
       for _,joint in p:GetChildren() do if joint:IsA('Motor6D') then table.insert(r.bolts,joint) end end
      end end
     end
     for _,joint in r.bolts do if joint.Parent then
      local pivot=Vector3.new(0,joint.C0.Y,joint.C0.Z)
      local delta=CFrame.new(pivot)*Preferences.Transform(bolt.bolt,visualWeight)*CFrame.new(-pivot)
      joint.Transform=joint.C0:Inverse()*delta*joint.C0
     end end
     action.weapon*=bolt.weapon
    end
    local kick=math.exp(-math.max(0,now-shot)*22)
    local pitch=r.character:GetAttribute("CombatAimPitch") or 0
    pose=CFrame.Angles(math.clamp(pitch,-1.15,1.15)*.8,0,0)*pose*action.weapon*reload.weapon*CFrame.new(0,0,kick*.10)*CFrame.Angles(kick*.04,0,0)
    pose=CFrame.Angles(math.clamp(pitch,-1.15,1.15)*.8,0,0)*Preferences.Transform(CFrame.Angles(-math.clamp(pitch,-1.15,1.15)*.8,0,0)*pose,visualWeight)
    mount.Transform=pose desired=torso.CFrame*mount.C0*pose*mount.C1:Inverse()
   end
   if r.right and r.grip and r.grip.Parent then Pose.Solve(r.right,r.grip,desired and desired*CFrame.new(bolt and bolt.hand*Preferences.WeaponWeight(viewer) or Vector3.zero)*r.grip.CFrame) end
   local leftAttachment = r.support
if not leftAttachment or not leftAttachment.Parent then
    -- fallback to muzzle if no support grip
    leftAttachment = tool and tool:FindFirstChild("Muzzle")
end
if r.left and leftAttachment and leftAttachment.Parent then
    Pose.Solve(r.left, leftAttachment, desired and desired*CFrame.new(reload and reload.hand*Preferences.WeaponWeight(viewer) or Vector3.zero)*leftAttachment.CFrame*Preferences.Transform(reload and reload.handRotation or CFrame.identity,Preferences.WeaponWeight(viewer)))
end
  end
 end
end)
