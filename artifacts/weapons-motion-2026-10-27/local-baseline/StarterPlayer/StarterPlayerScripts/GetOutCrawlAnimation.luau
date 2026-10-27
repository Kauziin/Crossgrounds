-- Authored procedural clip: no external animation asset or upload permission needed.
-- Joint poses are evaluated after Animator for R6, R15 and AnimationConstraint rigs.
local Animation={}
local Players=game:GetService("Players")local Run=game:GetService("RunService")
local T=require(game.ReplicatedStorage.Crossgrounds.GetOutPrototype)
local function angles(x,y,z)return CFrame.Angles(math.rad(x or 0),math.rad(y or 0),math.rad(z or 0))end
local frames={
 {rightshoulder=angles(-170,14,12),leftshoulder=angles(-110,-18,-26),rightelbow=angles(-15),leftelbow=angles(-95),righthip=angles(8,8,7),lefthip=angles(35,-10,-14),rightknee=angles(-15),leftknee=angles(-75)},
 {rightshoulder=angles(-145,8,22),leftshoulder=angles(-145,-8,-22),rightelbow=angles(-65),leftelbow=angles(-45),righthip=angles(22,8,9),lefthip=angles(18,-8,-9),rightknee=angles(-50),leftknee=angles(-25)},
 {rightshoulder=angles(-110,18,26),leftshoulder=angles(-170,-14,-12),rightelbow=angles(-95),leftelbow=angles(-15),righthip=angles(35,10,14),lefthip=angles(8,-8,-7),rightknee=angles(-75),leftknee=angles(-15)},
 {rightshoulder=angles(-145,8,22),leftshoulder=angles(-145,-8,-22),rightelbow=angles(-45),leftelbow=angles(-65),righthip=angles(18,8,9),lefthip=angles(22,-8,-9),rightknee=angles(-25),leftknee=angles(-50)},
}
local rest={rightshoulder=angles(-150,10,16),leftshoulder=angles(-150,-10,-16),rightelbow=angles(-45),leftelbow=angles(-45),righthip=angles(5,4,4),lefthip=angles(5,-4,-4),rightknee=angles(-12),leftknee=angles(-12),neck=angles(70)}
local limp={rightshoulder=angles(-30,0,34),leftshoulder=angles(-40,0,-40),rightelbow=angles(-25),leftelbow=angles(-35),righthip=angles(-8,0,8),lefthip=angles(-15,0,-10),rightknee=angles(20),leftknee=angles(30),neck=angles(8)}
local function sample(name,phase,movement)
 local index=phase*4 local first=math.floor(index)%4+1 local nextIndex=first%4+1
 local a=frames[first][name]or rest[name]or CFrame.identity local b=frames[nextIndex][name]or rest[name]or CFrame.identity
 local t=index%1 t=t*t*(3-2*t)
 return(rest[name]or CFrame.identity):Lerp(a:Lerp(b,t),movement)
end
function Animation:Start()
 if self.started then return end self.started=true
 local rigs={}local applied={}
 Run.PreSimulation:Connect(function(dt)
  local seen={}local live={}
  for _,player in Players:GetPlayers()do
   local character=player.Character
   if character and player:GetAttribute("CrossgroundsMode")=="get_out"then
    live[player]=true local rig=rigs[player]
    if not rig or rig.character~=character then
     if rig and rig.connection then rig.connection:Disconnect()end
     rig={character=character,joints={},weight=0,phase=0,movement=0}rigs[player]=rig
     local function add(joint)if joint:IsA("Motor6D")or joint:IsA("AnimationConstraint")then table.insert(rig.joints,joint)end end
     for _,joint in character:GetDescendants()do add(joint)end rig.connection=character.DescendantAdded:Connect(add)
    end
    local posture=player:GetAttribute("GetOutPosture")local crawling=posture=="Crawling"
    local low=crawling or posture=="Downed"or posture=="Dragged"
    if low then rig.lastClip=crawling and"crawl"or"limp"end
    local clipCrawl=crawling or not low and rig.lastClip=="crawl"
    local duration=low and T.CrawlEnterSeconds or T.CrawlExitSeconds
    -- Retarget from the current blend on release, stun or a new press; no queued tween.
    rig.weight=math.clamp(rig.weight+(low and 1 or -1)*dt/duration,0,1)
    local root=character:FindFirstChild("HumanoidRootPart")local speed=root and(root.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude or 0
    rig.standingHeight=player:GetAttribute("GetOutStandingRootHeight")or rig.standingHeight or 3
    local moving=crawling and math.clamp(speed/T.CrawlSpeed,0,1)or 0
    rig.movement+= (moving-rig.movement)*math.min(1,dt*12)
    if crawling then rig.phase=(rig.phase+math.min(speed,T.CrawlSpeed*1.5)*dt/T.CrawlStride)%1 end
    local weight=rig.weight*rig.weight*(3-2*rig.weight)
    local transition=math.sin(math.pi*rig.weight)
    for _,joint in rig.joints do if joint.Parent then
     local name=joint.Name:lower():gsub("[%s_]","")local target local blend=weight
     if root and joint.Part0==root and weight>0 then
      local rotation=joint.C0.Rotation
      local lift=weight*(math.max(0,-joint.C0.Position.Y)+.12)
      if weight<1 then
       local params=RaycastParams.new()params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={character}params.RespectCanCollide=true
       local floor=workspace:Raycast(root.Position,Vector3.new(0,-12,0),params)
       if floor then lift+=(1-weight)*math.max(0,rig.standingHeight-(root.Position.Y-floor.Position.Y))end
      end
      local offset=rotation:VectorToObjectSpace(Vector3.new(0,lift,0))
      target=CFrame.new(offset)*rotation:Inverse()*CFrame.Angles(-math.pi/2*weight,0,math.sin(rig.phase*math.pi*2)*.045*rig.movement*weight)*rotation
      blend=1
     elseif weight>0 then
      target=clipCrawl and sample(name,rig.phase,rig.movement)or limp[name]or CFrame.identity
      if name=="waist"then target=angles(0,math.sin(rig.phase*math.pi*2)*6*rig.movement,0)
      elseif name=="rightknee"or name=="leftknee"then target*=angles(-transition*45)
      elseif name=="neck"then target=clipCrawl and rest.neck or limp.neck end
     elseif player:GetAttribute("GetOutHacking")and name:find("shoulder",1,true)then
      local phase=name:find("right",1,true)and 0 or math.pi target=angles(-65+math.sin(workspace:GetServerTimeNow()*12+phase)*5)blend=1
     end
     if target then
      local old=applied[joint]local base=old and joint.Transform==old.value and old.base or joint.Transform
      local value=base:Lerp(target,blend)joint.Transform=value applied[joint]={base=base,value=value}seen[joint]=true
     end
    end end
   end
  end
  for joint,old in applied do if not seen[joint]then if joint.Parent and joint.Transform==old.value then joint.Transform=old.base end applied[joint]=nil end end
  for player,rig in rigs do if not live[player]then rig.connection:Disconnect()rigs[player]=nil end end
 end)
end
return Animation
