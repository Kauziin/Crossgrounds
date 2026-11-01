-- Static backing and camera-facing key light; no animation or render loop.
local Style={}
function Style.Attach(viewport)
 viewport.Ambient=Color3.fromRGB(210,215,222) viewport.LightColor=Color3.new(1,1,1) viewport.ImageColor3=Color3.new(1,1,1)
 local backing=Instance.new('Frame') backing.Name=viewport.Name..'SoftLight' backing.BackgroundTransparency=1 backing.BorderSizePixel=0 backing.Active=false backing:SetAttribute('CascadeDecoration',true) backing.Parent=viewport.Parent
 for i=1,3 do
  local glow=Instance.new('Frame') glow.AnchorPoint=Vector2.new(.5,.5) glow.Position=UDim2.fromScale(.5,.55) glow.Size=UDim2.fromScale(1-(i-1)*.12,.8-(i-1)*.09) glow.BackgroundColor3=Color3.new(1,1,1) glow.BackgroundTransparency=.975 glow.BorderSizePixel=0 glow:SetAttribute('CascadeDecoration',true) glow.Parent=backing
  Instance.new('UICorner',glow).CornerRadius=UDim.new(1,0)
  local fade=Instance.new('UIGradient',glow) fade.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.3,.45),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(.7,.45),NumberSequenceKeypoint.new(1,1)})
 end
 local connections={}
 local function sync()
  backing.Position=viewport.Position backing.Size=viewport.Size backing.AnchorPoint=viewport.AnchorPoint backing.Visible=viewport.Visible backing.ZIndex=math.max(0,viewport.ZIndex-1)
  for _,g in backing:GetChildren() do g.ZIndex=backing.ZIndex end
 end
 for _,name in {'Position','Size','AnchorPoint','Visible','ZIndex'} do table.insert(connections,viewport:GetPropertyChangedSignal(name):Connect(sync)) end
 viewport.Destroying:Connect(function() for _,c in connections do c:Disconnect() end backing:Destroy() end)
 sync() return backing
end
function Style.Aim(viewport,camera) viewport.LightDirection=(camera.CFrame.LookVector+Vector3.new(0,-.25,0)).Unit end
return Style
