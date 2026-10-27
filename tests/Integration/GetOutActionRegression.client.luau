-- Temporary integration participant, installed only for the explicit Studio session.
local event=game.ReplicatedStorage:WaitForChild("GetOutActionRegression",40)if not event then return end
local player=game.Players.LocalPlayer local Run=game:GetService("RunService")
local Router=require(player.PlayerScripts:WaitForChild("ControlRouter"))
local Interaction=require(player.PlayerScripts:WaitForChild("InteractionController"))
local remotes=game.ReplicatedStorage.Crossgrounds.GetOutRemotes local snapshot local lastCheck
remotes.State.OnClientEvent:Connect(function(data)snapshot=data end)
Run.Heartbeat:Connect(function()
 local hack=snapshot and snapshot.gameplay and snapshot.gameplay.hack
 if not hack or not hack.checkAt or lastCheck==hack.checkAt then return end
 local time=workspace:GetServerTimeNow()
 if time>=hack.checkAt+.05 and time<(hack.checkEnd or 0)then
  lastCheck=hack.checkAt Router:Dispatch("GetOutCheck",Enum.UserInputState.Begin)Router:Dispatch("GetOutCheck",Enum.UserInputState.End)
 end
end)
task.spawn(function()
 player.PlayerGui:WaitForChild("GetOutActions",70)
 local deadline=os.clock()+80 repeat task.wait(.1)until player:GetAttribute("ClientLoading")==false or os.clock()>deadline
 event:FireServer(0,{ready=true})
 repeat task.wait(.1)until player:GetAttribute("CrossgroundsMode")=="get_out"and player.PlayerGui.GetOutActions.Enabled and player:GetAttribute("ClientLoading")==false
 event:FireServer(0,{playingReady=true})
end)
event.OnClientEvent:Connect(function(id,command,value)
 task.spawn(function()
  local ok,result=xpcall(function()
   local character=player.Character local humanoid=character and character:FindFirstChildOfClass("Humanoid")local root=character and character:FindFirstChild("HumanoidRootPart")
   if command=="hold"then
    local nearest=Interaction:Nearest()local blocked=Router:IsBlocked()
    Router:Dispatch("ReloadInteract",Enum.UserInputState.Begin)
    task.wait(value or(nearest and nearest.HoldDuration+.35 or .5))Router:Dispatch("ReloadInteract",Enum.UserInputState.End)
    return{nearest=nearest and nearest:GetFullName(),blocked=blocked}
   elseif command=="crawl"then
    Router:Dispatch("GetOutCrawl",value and Enum.UserInputState.Begin or Enum.UserInputState.End)task.wait(.45)
    return{posture=player:GetAttribute("GetOutPosture")}
   elseif command=="tapCrawl"then
    Router:Dispatch("GetOutCrawl",Enum.UserInputState.Begin)task.wait(.04)Router:Dispatch("GetOutCrawl",Enum.UserInputState.End)task.wait(.5)
    return{posture=player:GetAttribute("GetOutPosture")}
   elseif command=="crawlMove"then
    local before=root.Position local samples={}local joints={}
    for _,joint in character:GetDescendants()do if(joint:IsA("Motor6D")or joint:IsA("AnimationConstraint"))and(joint.Name:lower():find("shoulder")or joint.Name:lower():find("knee"))then joints[joint]=joint.Transform end end
    local deadline=os.clock()+value.seconds local changed=false
    repeat
     remotes.Action:FireServer(player:GetAttribute("GetOutRoundId"),"CrawlMove",value.direction)
     task.wait(.04)
     for joint,old in joints do if joint.Transform~=old then changed=true end end
    until os.clock()>deadline
    remotes.Action:FireServer(player:GetAttribute("GetOutRoundId"),"CrawlMove",Vector3.zero)
    return{distance=(root.Position-before).Magnitude,animated=changed,posture=player:GetAttribute("GetOutPosture"),position=tostring(root.Position)}
   elseif command=="walk"or command=="jump"then
    local before=root.Position local head=character:FindFirstChild("Head")local top=-math.huge
    local jump=command=="jump"local started=os.clock()
    Run:BindToRenderStep("GetOutRegressionWalk",Enum.RenderPriority.Input.Value+1,function()
     humanoid:Move(value.direction,false)
     if head then top=math.max(top,head.Position.Y+head.Size.Y*.5)end
     if jump and os.clock()-started<.1 then humanoid.Jump=true end
    end)
    task.wait(value.seconds)Run:UnbindFromRenderStep("GetOutRegressionWalk")humanoid:Move(Vector3.zero)humanoid.Jump=false
    return{position=tostring(root.Position),distance=(root.Position-before).Magnitude,headTop=top}
   elseif command=="attack"then Router:Dispatch("GetOutAttack",Enum.UserInputState.Begin)task.wait(.5)return true
   elseif command=="ability"then
    Router:Dispatch("GetOutHacker",Enum.UserInputState.Begin)task.wait(.2)
    return{speed=humanoid.WalkSpeed,jump=humanoid.JumpHeight,jumping=humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping),class=player:GetAttribute("GetOutBeastClass")}
   elseif command=="drop"then Router:Dispatch("GetOutDrop",Enum.UserInputState.Begin)task.wait(.2)return true
   elseif command=="rawInteract"then
    remotes.Interact:FireServer(player:GetAttribute("GetOutRoundId"),"begin",value)
    remotes.Interact:FireServer(player:GetAttribute("GetOutRoundId"),"complete",value)return true
   elseif command=="pose"then
    local bottom=math.huge
    for _,name in {"UpperTorso","LowerTorso","Torso"}do local part=character:FindFirstChild(name)if part then
     local cf=part.CFrame local half=part.Size*.5 local extent=math.abs(cf.RightVector.Y)*half.X+math.abs(cf.UpVector.Y)*half.Y+math.abs(cf.LookVector.Y)*half.Z
     bottom=math.min(bottom,part.Position.Y-extent)
    end end
    return{torsoBottom=bottom,posture=player:GetAttribute("GetOutPosture")}
   elseif command=="stopHack"then remotes.Action:FireServer(player:GetAttribute("GetOutRoundId"),"CancelHack")task.wait(.2)return true
   end
  end,debug.traceback)
  event:FireServer(id,{ok=ok,result=result})
 end)
end)
