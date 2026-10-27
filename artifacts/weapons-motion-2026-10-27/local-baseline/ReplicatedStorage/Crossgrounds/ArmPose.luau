-- Two-bone support pose for Motor6D and AvatarJointUpgrade rigs.
local Pose={}
local function rotateBone(startWorld,endWorld,startLocal,endLocal,normal)
 local localDir=endLocal-startLocal local worldDir=endWorld-startWorld
 if localDir.Magnitude<.001 or worldDir.Magnitude<.001 then return end
 local reference=math.abs(localDir.Unit.Y)>.95 and Vector3.xAxis or Vector3.yAxis
 local rotation=CFrame.lookAt(Vector3.zero,worldDir,normal).Rotation*CFrame.lookAt(Vector3.zero,localDir,reference).Rotation:Inverse()
 return CFrame.new(startWorld)*rotation*CFrame.new(-startLocal)
end
local function setJoint(joint,partFrame,parentFrame)
 if joint:IsA("AnimationConstraint") then
  joint.Transform=(parentFrame*joint.Attachment0.CFrame):ToObjectSpace(partFrame*joint.Attachment1.CFrame)
 else joint.Transform=(parentFrame*joint.C0):ToObjectSpace(partFrame*joint.C1) end
end
local function joint(part,name)
 local legacy
 for _,value in part:GetChildren() do
  if value.Name==name then
   if value:IsA("AnimationConstraint") then return value
   elseif value:IsA("Motor6D") then legacy=value end
  end
 end
 return legacy
end
function Pose.Chain(character,side)
 local torso=character:FindFirstChild("UpperTorso") local upper=character:FindFirstChild(side.."UpperArm") local lower=character:FindFirstChild(side.."LowerArm") local hand=character:FindFirstChild(side.."Hand")
 if not torso or not upper or not lower or not hand then return end
 local shoulder=joint(upper,side.."Shoulder") local elbow=joint(lower,side.."Elbow") local wrist=joint(hand,side.."Wrist")
 if not shoulder or not elbow or not wrist then return end
 for _,joint in {shoulder,elbow,wrist} do if not joint:IsA("Motor6D") and not joint:IsA("AnimationConstraint") then return end end
 local sa0=torso:FindFirstChild(side.."ShoulderRigAttachment") local sa1=upper:FindFirstChild(side.."ShoulderRigAttachment")
 local ea0=upper:FindFirstChild(side.."ElbowRigAttachment") local ea1=lower:FindFirstChild(side.."ElbowRigAttachment")
 local wa0=lower:FindFirstChild(side.."WristRigAttachment") local wa1=hand:FindFirstChild(side.."WristRigAttachment") local grip=hand:FindFirstChild(side.."GripAttachment")
 if not sa0 or not sa1 or not ea0 or not ea1 or not wa0 or not wa1 or not grip then return end
 return {torso=torso,shoulder=shoulder,elbow=elbow,wrist=wrist,sa0=sa0,sa1=sa1,ea0=ea0,ea1=ea1,wa0=wa0,wa1=wa1,grip=grip,side=side}
end
function Pose.Solve(c,target,worldFrame)
 local handCF=(worldFrame or target.WorldCFrame)*c.grip.CFrame:Inverse()
 local start=(c.torso.CFrame*c.sa0.CFrame).Position local finish=(handCF*c.wa1.CFrame).Position
 local l1=(c.ea0.Position-c.sa1.Position).Magnitude local l2=(c.wa0.Position-c.ea1.Position).Magnitude
 if l1<.002 or l2<.002 then return end
 local delta=finish-start if delta.Magnitude<.001 then return end
 local distance=math.clamp(delta.Magnitude,math.abs(l1-l2)+.001,l1+l2-.001)
 local dir=delta.Unit local pole=c.torso.CFrame:VectorToWorldSpace(Vector3.new(c.side=="Left" and -1 or 1,-.7,.25))
 local bend=pole-dir*pole:Dot(dir) if bend.Magnitude<.001 then bend=c.torso.CFrame.RightVector end bend=bend.Unit
 local along=(l1*l1-l2*l2+distance*distance)/(2*distance)
 local height=math.sqrt(math.max(0,l1*l1-along*along))
 local elbowPos=start+dir*along+bend*height local wristPos=start+dir*distance
 local normal=dir:Cross(bend).Unit
 local upperCF=rotateBone(start,elbowPos,c.sa1.Position,c.ea0.Position,normal)
 local lowerCF=rotateBone(elbowPos,wristPos,c.ea1.Position,c.wa0.Position,normal)
 if not upperCF or not lowerCF then return end
 local desiredHand=CFrame.new(wristPos-finish)*handCF
 setJoint(c.shoulder,upperCF,c.torso.CFrame) setJoint(c.elbow,lowerCF,upperCF) setJoint(c.wrist,desiredHand,lowerCF)
end
return Pose
