local Lighting=game:GetService("Lighting")
local Tween=game:GetService("TweenService")
local player=game.Players.LocalPlayer
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Profiles=require(game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("MapLightingProfiles"))
local fields={"ClockTime","Brightness","ExposureCompensation","Ambient","OutdoorAmbient","ColorShift_Top","ColorShift_Bottom","EnvironmentDiffuseScale","EnvironmentSpecularScale","ShadowSoftness"}
local atmosphereFields={"Density","Offset","Color","Decay","Haze","Glare"}
local baseline={}for _,key in fields do baseline[key]=Lighting[key]end
local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")local originalAtmosphere=atmosphere local baseAtmosphere={}
if atmosphere then for _,key in atmosphereFields do baseAtmosphere[key]=atmosphere[key]end end
local current local lightingTween local atmosphereTween
local function update()
 local id
 if player:GetAttribute("AdminFreecam")==true then id=player:GetAttribute("AdminPhotoLightingProfile")
 elseif Scope:IsArena() then id=workspace:GetAttribute("ArenaLightingProfile") or workspace:GetAttribute("ArenaMapId")end
 if not Profiles[id] then id=nil end
 if id==current then return end current=id
 if lightingTween then lightingTween:Cancel()end if atmosphereTween then atmosphereTween:Cancel()end
 local profile=id and Profiles[id]
 local target={}for _,key in fields do target[key]=profile and profile[key]or baseline[key]end
 lightingTween=Tween:Create(Lighting,TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),target)lightingTween:Play()
 if profile then
  if not atmosphere or not atmosphere.Parent then atmosphere=Instance.new("Atmosphere")atmosphere.Name="LocalMapAtmosphere"atmosphere.Parent=Lighting end
  atmosphereTween=Tween:Create(atmosphere,TweenInfo.new(.8),profile.Atmosphere)atmosphereTween:Play()
 elseif atmosphere then
  if originalAtmosphere and originalAtmosphere.Parent then
   atmosphereTween=Tween:Create(originalAtmosphere,TweenInfo.new(.8),baseAtmosphere)atmosphereTween:Play()
  elseif atmosphere.Parent then atmosphere:Destroy()atmosphere=nil end
 end
 player:SetAttribute("MapLightingProfile",id)
end
Scope.Changed:Connect(update)
for _,name in {"AdminFreecam","AdminPhotoLightingProfile"}do player:GetAttributeChangedSignal(name):Connect(update)end
for _,name in {"ArenaMapId","ArenaLightingProfile"}do workspace:GetAttributeChangedSignal(name):Connect(update)end
update()
