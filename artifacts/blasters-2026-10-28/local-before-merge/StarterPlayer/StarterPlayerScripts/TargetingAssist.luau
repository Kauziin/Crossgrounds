local Assist={}
local Players=game:GetService("Players") local player=Players.LocalPlayer
local Scope=require(script.Parent:WaitForChild("ModeScope")) local Mode=require(script.Parent:WaitForChild("InputMode"))
local Math=require(game.ReplicatedStorage.Crossgrounds.AimAssist)
local models=setmetatable({},{__mode="k"}) local refreshed=-100 local candidates={}
local state=Math.NewState()
local function track(item) if item:IsA("Humanoid") and item.Parent:IsA("Model") then models[item.Parent]=item end end
workspace.DescendantAdded:Connect(track) for _,item in workspace:GetDescendants() do track(item) end
function Assist:Reset()
 refreshed=-100 candidates={} Math.Reset(state)
 player:SetAttribute("AimAssistActive",false) player:SetAttribute("AimAssistFriction",1)
 player:SetAttribute("AimAssistRotation",Vector2.zero) player:SetAttribute("AimAssistDistance",0)
end
local function eligibility(model,h,ctf,now,world)
 local other=Players:GetPlayerFromCharacter(model) local team=player.Team
 local allied=ctf and team and ((other and other.Team==team) or model:GetAttribute("CTFTeam")==team.Name)
 local protected=math.max(model:GetAttribute("SpawnProtectedUntil") or 0,model:GetAttribute("ArenaProtectedUntil") or 0)>now
 return Math.Eligible({mode=Scope:Get(),health=h.Health,allied=allied,protected=protected,
  shooterActive=player:GetAttribute(ctf and "InArena" or "ArenaPlaying"),
  targetActive=other and other:GetAttribute(ctf and "InArena" or "ArenaPlaying"),
  targetBot=model:GetAttribute("CTFBot"),
  targetTraining=world and model:IsDescendantOf(world) and model:GetAttribute("ArenaTarget")}),allied
end
function Assist:Target(view,point,camera,range,enabled,strength,firearm,viewmodel,aiming,context)
 local input=Mode:Get()
 if not enabled or strength<=0 or not firearm or not Scope:IsCombat() or input~=Enum.PreferredInput.Gamepad and input~=Enum.PreferredInput.Touch then self:Reset() return nil,1,Vector2.zero end
 if os.clock()-refreshed>.08 then
  refreshed=os.clock() candidates={}
  for model,h in models do
   if model.Parent and h.Parent and model~=player.Character then
    local body=model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")
    local root=model:FindFirstChild("HumanoidRootPart") or body
    if body and root then table.insert(candidates,{id=model,body=body,root=root,humanoid=h}) end
   end
  end
 end
 local now=workspace:GetServerTimeNow() local ctf=Scope:IsCTF() local world=workspace:FindFirstChild("CrossgroundsArenaRound")
 local ignore={}
 if player.Character then table.insert(ignore,player.Character) end if viewmodel then table.insert(ignore,viewmodel) end
 local active={}
 for _,entry in candidates do
  local h=entry.humanoid local model=entry.id
  if model.Parent and h.Parent and entry.body.Parent and entry.root.Parent then
   local eligible,allied=eligibility(model,h,ctf,now,world)
   if allied or h.Health<=0 then table.insert(ignore,model) end
   if eligible then
    local body,root=entry.body,entry.root
    entry.frame=CFrame.new(root.Position+Vector3.new(0,.4,0))
    entry.size=Vector3.new(math.max(body.Size.X,root.Size.X)*1.25,math.clamp(h.HipHeight+root.Size.Y+1,3.5,6),math.max(body.Size.Z,root.Size.Z)*1.2)
    table.insert(active,entry)
   end
  end
 end
 local ray=camera:ViewportPointToRay(point.X,point.Y)
 local direction=view:VectorToWorldSpace(camera.CFrame:VectorToObjectSpace(ray.Direction))
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances=ignore
 local selected=Math.Select(view.Position,direction,active,function(candidate,origin,anchor)
  local hit=workspace:Raycast(origin,candidate.body.Position-origin,params)
  if not hit or not hit.Instance:IsDescendantOf(candidate.id) then return false end
  local covered=workspace:Raycast(origin,anchor-origin,params)
  return not covered or covered.Instance:IsDescendantOf(candidate.id)
 end,range,aiming,state.target)
 context=context or {} context.origin=view.Position context.strength=strength
 context.device=input==Enum.PreferredInput.Gamepad and "gamepad" or "touch"
 local friction,rotation=Math.Step(state,selected,context)
 player:SetAttribute("AimAssistActive",selected~=nil)
 player:SetAttribute("AimAssistFriction",friction) player:SetAttribute("AimAssistRotation",rotation)
 player:SetAttribute("AimAssistDistance",selected and selected.distance or 0)
 return selected,friction,rotation
end
Scope.Changed:Connect(function() Assist:Reset() end)
Mode.Changed:Connect(function() Assist:Reset() end)
player:GetPropertyChangedSignal("Team"):Connect(function() Assist:Reset() end)
return Assist
