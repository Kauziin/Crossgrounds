local Players=game:GetService("Players") local Run=game:GetService("RunService")
local E=require(game.ReplicatedStorage.Crossgrounds.BlasterEffects)
local active={} local pending={}
local function register(tool)
 if not tool:IsA("Tool") or tool:GetAttribute("SourcePack")~="ProjectileTest" or active[tool] or pending[tool] then return end
 local h=tool.Parent:FindFirstChildOfClass("Humanoid") if not h then return end
 local animator=h:FindFirstChildOfClass("Animator") if not animator then return end
 pending[tool]=true
 local record={character=tool.Parent,tracks={},connections={}}
 local folder=tool:WaitForChild("Animations",5)
 if not folder then pending[tool]=nil return end
 for _,name in {"Idle","Shoot","Reload"}do
  local animation=folder:WaitForChild(name,5)
  if not animation then pending[tool]=nil for _,t in record.tracks do t:Stop(0)end return end
  local track=animator:LoadAnimation(animation) track.Priority=Enum.AnimationPriority.Action track.Looped=animation.Name=="Idle" record.tracks[animation.Name]=track
  table.insert(record.connections,track:GetMarkerReachedSignal("Sound"):Connect(function(key)
   local owner=Players:GetPlayerFromCharacter(record.character)
   if owner~=Players.LocalPlayer or not owner:GetAttribute("FirstPerson") then E.Sound(tool,key)end
  end))
 end
 pending[tool]=nil
 if tool.Parent~=record.character then for _,t in record.tracks do t:Stop(0)end for _,c in record.connections do c:Disconnect()end return end
 active[tool]=record
 record.tracks.Idle:Play(.1)
end
workspace.DescendantAdded:Connect(function(v)if v:IsA("Tool")then task.defer(register,v)end end)
Run.Heartbeat:Connect(function()
 for tool,r in active do
  local h=r.character:FindFirstChildOfClass("Humanoid")
  if tool.Parent~=r.character or not h or h.Health<=0 then
   for _,t in r.tracks do t:Stop(.1)end for _,c in r.connections do c:Disconnect()end active[tool]=nil
  else
   local shot=tool:GetAttribute("PresentationShotAt")
   if shot and shot~=r.shot then r.shot=shot r.tracks.Shoot:Play(0)end
   local reload=tool:GetAttribute("Reloading")==true
   if reload and not r.reload then local t=r.tracks.Reload r.tracks.Shoot:Stop(0)t:Play(.1,1,t.Length>0 and t.Length/math.max(.1,tool:GetAttribute("ReloadDuration")or 1)or 1)
   elseif not reload and r.reload then r.tracks.Reload:Stop(.1)end
   if reload and r.tracks.Reload.Length>0 then r.tracks.Reload:AdjustSpeed(r.tracks.Reload.Length/math.max(.1,tool:GetAttribute("ReloadDuration")or 1))end
   r.reload=reload
  end
 end
end)
for _,v in workspace:GetDescendants()do if v:IsA("Tool")then register(v)end end
