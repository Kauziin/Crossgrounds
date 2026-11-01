-- One viewport-independent telescopic overlay, shared by every sight profile.
local Sight={} Sight.__index=Sight
function Sight.new(player)
 local self=setmetatable({},Sight)
 local gui=Instance.new("ScreenGui") gui.Name="OpticalSightHUD" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=12 gui.Enabled=false gui.Parent=player:WaitForChild("PlayerGui") self.gui=gui
 local root=Instance.new("Frame") root.AnchorPoint=Vector2.new(.5,.5) root.Position=UDim2.fromScale(.5,.5) root.BackgroundTransparency=1 root.Parent=gui self.root=root
 local function rect(name,size,position,rotation)
  local f=Instance.new("Frame") f.Name=name f.BorderSizePixel=0 f.BackgroundColor3=Color3.new() f.AnchorPoint=Vector2.new(.5,.5) f.Size=size f.Position=position f.Rotation=rotation or 0 f.Parent=root return f
 end
 -- Overlapping radial strips mask everything outside the circular lens.
 for i=1,128 do
  local a=i*math.pi*2/128
  rect("LensMask",UDim2.fromOffset(3000,0),UDim2.fromScale(.5,.5),math.deg(a))
 end
 for _,axis in {0,90} do rect("Reticle",UDim2.new(.72,0,0,1),UDim2.fromScale(.5,.5),axis) end
 local rim=rect("LensRim",UDim2.fromScale(1,1),UDim2.fromScale(.5,.5)) rim.BackgroundTransparency=1
 Instance.new("UICorner",rim).CornerRadius=UDim.new(1,0)
 local stroke=Instance.new("UIStroke",rim) stroke.Thickness=5 stroke.Color=Color3.fromRGB(23,25,28)
 for i=-4,4 do if i~=0 then
  for _,v in {Vector2.new(i*.055,0),Vector2.new(0,i*.055)} do
   local dot=rect("MilDot",UDim2.fromOffset(3,3),UDim2.fromScale(.5+v.X,.5+v.Y)) Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
  end
 end end
 return self
end
function Sight:Update(profile,viewport,point)
 self.gui.Enabled=profile~=nil
 if not profile then return end
 local size=math.min(viewport.X,viewport.Y)*.88
 self.root.Size=UDim2.fromOffset(size,size) self.root.Position=UDim2.fromOffset(point.X,point.Y)
 local index=0
 for _,f in self.root:GetChildren() do if f.Name=="LensMask" then
  index+=1 local a=index*math.pi*2/128 local radius=size*.5+1500
  f.Size=UDim2.fromOffset(3000,size*.5*.05+3)
  f.Position=UDim2.new(.5,math.cos(a)*radius,.5,math.sin(a)*radius)
 end end
end
return Sight
