local Players=game:GetService("Players")
local Rules=require(game.ReplicatedStorage.Crossgrounds.JumpCooldown)
local Service={}local started=false
function Service:Start()
 if started then return end started=true
 local watched=setmetatable({},{__mode="k"})
 local function watch(h)
  if not h:IsA("Humanoid") or watched[h] then return end
  watched[h]=true
  local character=h.Parent local last local stateConnection local ancestryConnection
  stateConnection=h.StateChanged:Connect(function(_,state)
   if state~=Enum.HumanoidStateType.Jumping or h.Health<=0 then return end
   local player=Players:GetPlayerFromCharacter(character)
   local mode=player and player:GetAttribute("CrossgroundsMode") or character:GetAttribute("CTFBot") and "ctf"
   if Rules.Duration(mode)==0 then last=nil return end
   local now=workspace:GetServerTimeNow()
   if not Rules.Ready(mode,last,now) then
    h.Jump=false h:ChangeState(Enum.HumanoidStateType.Freefall)
    local root=character:FindFirstChild("HumanoidRootPart")
    if root then local v=root.AssemblyLinearVelocity root.AssemblyLinearVelocity=Vector3.new(v.X,math.min(0,v.Y),v.Z) end
    return
   end
   last=now character:SetAttribute("CombatJumpReadyAt",now+Rules.Duration(mode))
  end)
  ancestryConnection=h.AncestryChanged:Connect(function()
   if not h:IsDescendantOf(workspace) then stateConnection:Disconnect() ancestryConnection:Disconnect() watched[h]=nil end
  end)
 end
 workspace.DescendantAdded:Connect(watch)
 for _,h in workspace:GetDescendants() do watch(h) end
end
return Service
