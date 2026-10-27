-- Additive player pose after Animator. Existing bot pose and Get Out are independent.
local Players=game:GetService("Players") local Run=game:GetService("RunService")
local Motion=require(game.ReplicatedStorage.Crossgrounds.LocomotionMotion)
local records=setmetatable({},{__mode="k"})
local function reset(r)
 for _,entry in r.joints do
  if entry.joint.Parent and entry.applied and entry.joint.Transform==entry.applied then entry.joint.Transform=entry.base end
  entry.applied=nil
 end
end
Run.PreAnimation:Connect(function() for _,r in records do reset(r) end end)
Run.PreSimulation:Connect(function(dt)
 for _,p in Players:GetPlayers() do
  local c=p.Character local h=c and c:FindFirstChildOfClass("Humanoid") local root=c and c:FindFirstChild("HumanoidRootPart")
  local active=c and (p:GetAttribute("CrossgroundsMode")=="ctf" and p:GetAttribute("InMatch") or p:GetAttribute("CrossgroundsMode")=="arena" and p:GetAttribute("ArenaPlaying"))
  local r=c and records[c]
  if not active or not h or not root or h.Health<=0 or h.RigType~=Enum.HumanoidRigType.R15 or h.Sit then
   if r then reset(r) records[c]=nil end
  else
   if not r then r={motion=Motion.new(),joints={},refresh=0} records[c]=r end
   if os.clock()>=r.refresh then
    reset(r) r.joints={} r.refresh=os.clock()+1
    for _,name in {"LeftHip","RightHip","LeftKnee","RightKnee","LeftAnkle","RightAnkle","Waist"} do
     local j=c:FindFirstChild(name,true)
     if j and (j:IsA("Motor6D") or j:IsA("AnimationConstraint")) then r.joints[name]={joint=j} end
    end
   end
   local v=root.CFrame:VectorToObjectSpace(root.AssemblyLinearVelocity)
   local m=r.motion:Update(dt,v,h.FloorMaterial~=Enum.Material.Air,c:GetAttribute("SlideActive")==true)
   local function apply(name,offset,replace)
    local e=r.joints[name] if not e or not e.joint.Parent then return end
    e.base=e.joint.Transform e.applied=replace and offset or e.base*offset e.joint.Transform=e.applied
   end
   if m.slide>.01 then
    local w=m.slide
    apply("Waist",CFrame.new(0,-.28*w,0)*CFrame.Angles(-.32*w,0,-.12*w))
    apply("LeftHip",CFrame.Angles(-1.1*w,0,-.12*w),true)
    apply("RightHip",CFrame.Angles(-.38*w,0,.22*w),true)
    apply("LeftKnee",CFrame.Angles(.3*w,0,0),true) apply("RightKnee",CFrame.Angles(1.25*w,0,0),true)
   elseif h.FloorMaterial==Enum.Material.Air then
    local fall=v.Y<0
    apply("LeftHip",CFrame.Angles(fall and -.15 or -.55,0,-.04))
    apply("RightHip",CFrame.Angles(fall and .12 or .28,0,.04))
    apply("LeftKnee",CFrame.Angles(fall and .22 or .5,0,0))
   else
    local stride=math.sin(m.phase)*m.weight
    local side=m.side local backward=math.max(0,-m.forward)
    -- Cardinal direction changes hips/feet, not just the facing of a forward run.
    apply("LeftHip",CFrame.Angles(-stride*.18*backward,side*.28*m.weight,-stride*side*.30))
    apply("RightHip",CFrame.Angles(stride*.18*backward,side*.28*m.weight,stride*side*.30))
    apply("Waist",CFrame.new(0,-m.land*.18,0)*CFrame.Angles(m.land*.12,side*.10*m.weight,-side*.07*m.weight))
    apply("LeftKnee",CFrame.Angles(m.land*.3,0,0)) apply("RightKnee",CFrame.Angles(m.land*.3,0,0))
   end
  end
 end
end)
