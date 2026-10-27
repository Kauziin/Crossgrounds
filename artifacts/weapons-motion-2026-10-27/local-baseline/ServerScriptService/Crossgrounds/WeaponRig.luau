-- Replicated weapon mount; clients solve hand poses after the Animator.
local Rig={}
local records=setmetatable({},{__mode="k"}) local pending=setmetatable({},{__mode="k"})
local started=false
function Rig:Clear(tool)
 local r=records[tool] if not r then return end records[tool]=nil
 for _,connection in r.connections do connection:Disconnect() end
 for _,object in r.owned do if object.Parent then object:Destroy() end end
 for _,joint in r.disabled do if joint.Parent then joint.Enabled=true end end
 tool:SetAttribute("SupportGripActive",false)
end
local function own(record,value) table.insert(record.owned,value) return value end
function Rig:Attach(tool)
 if records[tool] then return end
 local character=tool.Parent local h=character and character:FindFirstChildOfClass("Humanoid") local handle=tool:FindFirstChild("Handle")
 if not h or h.Health<=0 or not handle or not tool:GetAttribute("TwoHanded") then return end
 local support=handle:FindFirstChild("SupportGrip") if not support then return end
 local torso=character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") if not torso then return end
 local r={owned={},connections={},disabled={}} records[tool]=r
 if h.RigType==Enum.HumanoidRigType.R15 then
  if handle:FindFirstChild("RightHandGrip") then
   for _,joint in character:GetDescendants() do if joint:IsA("JointInstance") and joint.Name=="RightGrip" and joint.Part1==handle then joint.Enabled=false table.insert(r.disabled,joint) end end
   local mount=own(r,Instance.new("Motor6D")) mount.Name="CrossgroundsWeaponMount" mount.Part0=torso mount.Part1=handle
   local base=tool:GetAttribute("WeaponKind")=="Gun" and (tool:GetAttribute("WeaponId")=="ArenaPistol" and CFrame.new(0,.12,-.7) or CFrame.new(0,.05,-.35)) or CFrame.new(-.25,.1,-.25)*CFrame.Angles(0,math.pi/2,0)
   local rest=tool:GetAttribute("RestGrip") or tool.Grip
   local function updateMount() mount.C0=base*rest:ToObjectSpace(tool.Grip) end
   updateMount() mount.Parent=torso
   table.insert(r.connections,tool:GetPropertyChangedSignal("Grip"):Connect(updateMount))
  end
  local supported=character:FindFirstChild("LeftHand")~=nil
  tool:SetAttribute("SupportGripActive",supported)
 else
  -- R6 has no elbow. Keep the native right-hand joint and approximate support
  -- with a fixed-length left arm; do not stretch or detach the shoulder.
  local arm=character:FindFirstChild("Left Arm")
  local shoulder=torso:FindFirstChild("Left Shoulder")
  if arm and shoulder and shoulder:IsA("Motor6D") then
   shoulder.Enabled=false table.insert(r.disabled,shoulder)
   local start=shoulder.C0.Position local target=torso.CFrame:PointToObjectSpace(support.WorldPosition)
   local direction=target-start
   if direction.Magnitude>.05 then
    local position=start+direction.Unit*arm.Size.Y*.5
    local cf=CFrame.lookAt(position,position+direction.Unit)*CFrame.Angles(math.pi/2,0,0)
    local weld=own(r,Instance.new("Weld")) weld.Name="CrossgroundsR6Support" weld.Part0=torso weld.Part1=arm weld.C0=cf weld.Parent=torso
    tool:SetAttribute("SupportGripActive",true)
   end
  end
 end
 table.insert(r.connections,tool.Unequipped:Connect(function() self:Clear(tool) end))
 table.insert(r.connections,tool.AncestryChanged:Connect(function() if tool.Parent~=character then self:Clear(tool) end end))
 table.insert(r.connections,h.Died:Once(function() self:Clear(tool) end))
end
function Rig:Queue(tool)
 if pending[tool] or records[tool] then return end pending[tool]=true
 task.delay(.08,function() pending[tool]=nil
  if tool.Parent and tool.Parent:FindFirstChildOfClass("Humanoid") then
   local ok,err=pcall(function() self:Attach(tool) end) if not ok then self:Clear(tool) warn("WeaponRig: "..tostring(err)) end
  end
 end)
end
function Rig:Start()
 if started then return end started=true
 local function added(value)
  if value:IsA("Tool") and value:GetAttribute("TwoHanded") then self:Queue(value)
  elseif value:IsA("JointInstance") and value.Name=="RightGrip" and value.Part1 then
   local tool=value.Part1.Parent if tool and tool:IsA("Tool") then
    local record=records[tool] if record and tool.Handle:FindFirstChild("RightHandGrip") then value.Enabled=false table.insert(record.disabled,value) else self:Queue(tool) end
   end
  end
 end
 workspace.DescendantAdded:Connect(added)
 for _,value in workspace:GetDescendants() do added(value) end
end
return Rig
