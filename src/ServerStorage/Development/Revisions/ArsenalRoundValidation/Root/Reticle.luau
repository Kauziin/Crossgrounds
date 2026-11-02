-- The exact same renderer is used in the weapon HUD and settings preview.
local Reticle={} Reticle.__index=Reticle
Reticle.Colors={Color3.fromRGB(245,246,249),Color3.fromRGB(70,245,135),Color3.fromRGB(80,225,255),Color3.fromRGB(255,225,80),Color3.fromRGB(255,120,220),Color3.fromRGB(255,100,100)}
function Reticle.new(parent,name)
 local root=Instance.new("Frame") root.Name=name or "Crosshair" root.Size=UDim2.fromOffset(1,1) root.AnchorPoint=Vector2.new(.5,.5) root.BackgroundTransparency=1 root.Parent=parent
 local self=setmetatable({Root=root,arms={}},Reticle)
 for i=1,5 do
  local part=Instance.new("Frame") part.Name=i==5 and "Dot" or "Arm"..i part.AnchorPoint=Vector2.new(.5,.5) part.BorderSizePixel=0 part.Parent=root
  local stroke=Instance.new("UIStroke") stroke.Thickness=1 stroke.Color=Color3.new(0,0,0) stroke.Parent=part
  self.arms[i]=part
 end return self
end
function Reticle:Update(get,motion)
 local color=Reticle.Colors[get("ReticleColor")] or Reticle.Colors[1]
 local size,thickness,gap=get("ReticleSize"),get("ReticleThickness"),get("ReticleGap")
 if get("ReticleDynamic") then gap+=math.clamp(motion or 0,0,1)*6 end
 local opacity=get("ReticleOpacity")
 for i,part in self.arms do
  part.BackgroundColor3=color part.BackgroundTransparency=1-opacity part:FindFirstChildOfClass("UIStroke").Enabled=get("ReticleOutline")
  if i==5 then part.Visible=get("ReticleDot") part.Size=UDim2.fromOffset(thickness+2,thickness+2) part.Position=UDim2.new()
  else
   local horizontal=i>2 local sign=i%2==0 and 1 or -1
   part.Size=horizontal and UDim2.fromOffset(size,thickness) or UDim2.fromOffset(thickness,size)
   part.Position=UDim2.fromOffset(horizontal and sign*gap or 0,not horizontal and sign*gap or 0)
  end
 end
end
return Reticle
