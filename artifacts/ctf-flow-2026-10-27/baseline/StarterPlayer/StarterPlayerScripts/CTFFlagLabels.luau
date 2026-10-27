-- World objective text is local to participants physically inside the active CTF map.
local player=game.Players.LocalPlayer
local Run=game:GetService("RunService")
local arena local labels={} local elapsed=0 local added
local function track(obj)
 if (obj:IsA("BillboardGui") or obj:IsA("SurfaceGui")) and obj.Name=="FlagLabel" then table.insert(labels,obj) obj.Enabled=false end
end
local function refreshArena()
 local current=workspace:FindFirstChild("CTFInfrastructure")
 if current==arena then return end
 if added then added:Disconnect() added=nil end
 arena=current table.clear(labels)
 if arena then
  added=arena.DescendantAdded:Connect(track)
  for _,obj in arena:GetDescendants() do track(obj) end
 end
end
Run.Heartbeat:Connect(function(dt)
 elapsed+=dt if elapsed<.15 then return end elapsed=0 refreshArena()
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 local visible=arena~=nil and root~=nil and h~=nil and h.Health>0
  and player:GetAttribute("CrossgroundsMode")=="ctf" and player:GetAttribute("InArena")==true
  and workspace:GetAttribute("RoundState")=="Playing" and player:GetAttribute("AdminFreecam")~=true
 if visible then
  local center=arena:GetAttribute("PlayRegionCenter") or Vector3.new(0,60,0)
  local size=arena:GetAttribute("PlayRegionSize") or Vector3.new(420,160,240)
  local delta=root.Position-center local half=size*.5
  visible=math.abs(delta.X)<=half.X and math.abs(delta.Y)<=half.Y and math.abs(delta.Z)<=half.Z
 end
 for _,gui in labels do if gui.Parent and gui.Enabled~=visible then gui.Enabled=visible end end
end)
refreshArena()

