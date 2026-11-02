local Lighting=game:GetService("Lighting")
local Players=game:GetService("Players")
local Collection=game:GetService("CollectionService")
local player=Players.LocalPlayer
local Profiles=require(game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("GraphicsProfiles"))
local originalShadows=Lighting.GlobalShadows
local originals=setmetatable({},{__mode="k"})
local connections={} local own={} local running=true local applying=false
local function effect(class,name)
 local v=Instance.new(class) v.Name=name own[v]=true v.Parent=Lighting return v
end
local bloom=effect("BloomEffect","CrossgroundsQualityBloom")
bloom.Size=20 bloom.Threshold=1.5
bloom.Enabled=false
local rays=effect("SunRaysEffect","CrossgroundsQualitySunRays")
rays.Spread=.8
rays.Enabled=false
local color=effect("ColorCorrectionEffect","CrossgroundsQualityColor")
local dof=effect("DepthOfFieldEffect","CrossgroundsPhotoDepth")
dof.Enabled=false dof.FocusDistance=25 dof.InFocusRadius=20 dof.NearIntensity=0 dof.FarIntensity=.12
local quality=Profiles.Default
local function capture(v,prop)
 local record=originals[v]
 if not record then record={} originals[v]=record end
 if record[prop]==nil then record[prop]=v[prop] end
 return record[prop]
end
local function tune(v)
 if own[v] then return end
 if v:IsA("Light") and v:IsDescendantOf(workspace) then
  v.Shadows=capture(v,"Shadows") and Profiles.Get(quality).LightShadows
 elseif v:IsA("PostEffect") and (v.Parent==Lighting or v.Parent==workspace.CurrentCamera) and not v:IsA("BlurEffect") then
  capture(v,"Enabled") v.Enabled=false
 elseif Collection:HasTag(v,"CrossgroundsQualityCosmetic") and (v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam")) then
  local minimum=tonumber(v:GetAttribute("MinGraphicsQuality")) or 3
  v.Enabled=capture(v,"Enabled") and quality>=minimum
 end
end
local function apply()
 if applying or not running then return end applying=true
 local value=player:GetAttribute("SettingGraphicsQuality")
 quality=typeof(value)=="number" and math.clamp(math.floor(value),1,4) or Profiles.Default
 local p=Profiles.Get(quality)
 Lighting.GlobalShadows=originalShadows and p.Shadows
 bloom.Intensity=p.Bloom bloom.Enabled=p.Bloom>0
 rays.Intensity=p.Rays rays.Enabled=p.Rays>0
 color.Saturation=p.Saturation color.Contrast=p.Contrast
 dof.Enabled=quality==4 and player:GetAttribute("AdminFreecam")==true
 player:SetAttribute("GraphicsProfileActive",p.Name)
 for v in originals do if v.Parent then tune(v) end end
 applying=false
end
-- Scan once; streamed lights and tagged cosmetic effects are handled incrementally.
for i,v in workspace:GetDescendants() do tune(v) if i%1000==0 then task.wait() end end
for _,v in Lighting:GetChildren() do tune(v) end
for _,v in Collection:GetTagged("CrossgroundsQualityCosmetic") do tune(v) end
local function hook(signal,fn) table.insert(connections,signal:Connect(fn)) end
hook(workspace.DescendantAdded,tune)
hook(Lighting.ChildAdded,tune)
hook(Collection:GetInstanceAddedSignal("CrossgroundsQualityCosmetic"),tune)
hook(player:GetAttributeChangedSignal("SettingGraphicsQuality"),apply)
hook(player:GetAttributeChangedSignal("AdminFreecam"),apply)
local cameraConnection
local function cameraChanged()
 if cameraConnection then cameraConnection:Disconnect() end
 local camera=workspace.CurrentCamera
 if camera then
  for _,v in camera:GetChildren() do tune(v) end
  cameraConnection=camera.ChildAdded:Connect(tune)
 end
end
hook(workspace:GetPropertyChangedSignal("CurrentCamera"),cameraChanged)
cameraChanged()
script.Destroying:Connect(function()
 running=false
 for _,c in connections do c:Disconnect() end
 if cameraConnection then cameraConnection:Disconnect() end
 for v,properties in originals do if v.Parent then for key,value in properties do v[key]=value end end end
 Lighting.GlobalShadows=originalShadows
 for v in own do v:Destroy() end
end)
apply()
