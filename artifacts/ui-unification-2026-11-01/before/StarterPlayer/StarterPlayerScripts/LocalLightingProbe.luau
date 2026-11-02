-- Approximate world illumination for the isolated weapon viewport.
local Probe={}
local Lighting=game:GetService("Lighting")
local lights={}
local function added(v) if v:IsA("Light") then lights[v]=true end end
for _,v in workspace:GetDescendants() do added(v) end
workspace.DescendantAdded:Connect(added) workspace.DescendantRemoving:Connect(function(v) lights[v]=nil end)
local function clamp(c) return Color3.new(math.clamp(c.R,.015,1),math.clamp(c.G,.015,1),math.clamp(c.B,.015,1)) end
function Probe.Sample(camera,character)
 local p=camera.CFrame.Position local ray=RaycastParams.new() ray.FilterType=Enum.RaycastFilterType.Exclude ray.FilterDescendantsInstances=character and {character} or {}
 local roof=workspace:Raycast(p,Vector3.new(0,100,0),ray)
 local ambient=Lighting.Ambient:Lerp(Lighting.OutdoorAmbient,roof and 0 or .65)
 local sun=Lighting:GetSunDirection()
 local exposed=sun.Y>0 and not workspace:Raycast(p,sun*300,ray)
 local direct=exposed and math.clamp(Lighting.Brightness*.18,.1,.55) or .03
 local tint=Color3.new(direct,direct,direct)
 local sampled=0
 for light in lights do
  if light.Parent and light.Enabled then
   local parent=light.Parent
   local position=parent:IsA("Attachment") and parent.WorldPosition or parent:IsA("BasePart") and parent.Position
   local distance=position and (position-p).Magnitude
   if distance and distance<math.min(light.Range,50) then
    local hit=workspace:Raycast(p,position-p,ray)
    if not hit or hit.Instance==parent or parent:IsA("Attachment") and hit.Instance==parent.Parent then
     local strength=math.min(.65,light.Brightness*.12*(1-distance/light.Range)^2)
     ambient=Color3.new(ambient.R+light.Color.R*strength,ambient.G+light.Color.G*strength,ambient.B+light.Color.B*strength)
     sampled+=1 if sampled>=12 then break end
    end
   end
  end
 end
 return clamp(ambient),clamp(tint),camera.CFrame:VectorToObjectSpace(-sun)
end
return Probe
