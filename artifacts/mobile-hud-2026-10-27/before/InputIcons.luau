local Icons={}
local UIS=game:GetService("UserInputService")
local Mode=require(script.Parent:WaitForChild("InputMode"))
local player=game.Players.LocalPlayer
local changed=Instance.new("BindableEvent") Icons.Changed=changed.Event
local short={ButtonA="A",ButtonB="B",ButtonX="X",ButtonY="Y",ButtonL1="LB",ButtonR1="RB",ButtonL2="LT",ButtonR2="RT",ButtonL3="LS",ButtonR3="RS",ButtonSelect="VIEW",DPadLeft="←",DPadRight="→",DPadUp="↑",DPadDown="↓",LeftControl="CTRL",LeftShift="SHIFT",MouseButton1="M1",MouseButton2="M2",Space="ESPAÇO"}
function Icons:Platform()
 local ok,name=pcall(function() return UIS:GetStringForKeyCode(Enum.KeyCode.ButtonA) end)
 return ok and name=="ButtonCross" and "PlayStation" or "Xbox"
end
function Icons:Name(name)
 local platform=self:Platform()
 if platform=="PlayStation" then
  local ps={ButtonA="✕",ButtonB="○",ButtonX="□",ButtonY="△",ButtonL1="L1",ButtonR1="R1",ButtonL2="L2",ButtonR2="R2",ButtonL3="L3",ButtonR3="R3",ButtonSelect="SHARE"}
  if ps[name] then return ps[name] end
 end
 return short[name] or name:gsub("Left",""):gsub("Right",""):upper()
end
function Icons:Glyph(parent,name,key,size)
 local box=Instance.new("Frame") box.Name=name box.BackgroundTransparency=1 box.Size=UDim2.fromOffset(size or 28,size or 28) box.Parent=parent
 local image=Instance.new("ImageLabel") image.Name="Icon" image.Size=UDim2.fromScale(1,1) image.BackgroundTransparency=1 image.Parent=box
 local fallback=Instance.new("TextLabel") fallback.Name="Fallback" fallback.Size=UDim2.fromScale(1,1) fallback.BackgroundTransparency=1 fallback.Font=Enum.Font.GothamBold fallback.TextSize=12 fallback.TextColor3=Color3.fromRGB(225,237,255) fallback.Parent=box
 local function refresh()
  local value=type(key)=="function" and key() or key
  local asset=""
  if value:match("^Button") or value:match("^DPad") then local ok,result=pcall(function() return UIS:GetImageForKeyCode(Enum.KeyCode[value]) end) if ok then asset=result end end
  image.Image=asset image.Visible=asset~="" fallback.Visible=asset=="" fallback.Text=Icons:Name(value)
 end
 local connection=Icons.Changed:Connect(refresh) box.Destroying:Connect(function() connection:Disconnect() end) refresh()
 return box,refresh
end
function Icons:Refresh()
 player:SetAttribute("GamepadPlatform",self:Platform()) changed:Fire()
end
Mode.Changed:Connect(function() Icons:Refresh() end)
UIS.GamepadConnected:Connect(function() Icons:Refresh() end)
UIS.GamepadDisconnected:Connect(function() Icons:Refresh() end)
Icons:Refresh()
return Icons

