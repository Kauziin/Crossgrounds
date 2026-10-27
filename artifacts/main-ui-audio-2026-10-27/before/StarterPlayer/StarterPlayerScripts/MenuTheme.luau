local Theme={}
local Tween=game:GetService("TweenService")
local player=game.Players.LocalPlayer
local Gui=game:GetService("GuiService")
function Theme.ReducedMotion()
 local state=player.PlayerGui:FindFirstChild("PreferenceState")
 if state and state:GetAttribute("PreferenceGlobalReducedMenuMotion")~=nil then return player:GetAttribute("SettingReducedMenuMotion")==true end
 local ok,native=pcall(function() return Gui.ReducedMotionEnabled end)
 return player:GetAttribute("SettingReducedMenuMotion")==true or ok and native
end
Theme.Colors={Surface=Color3.fromRGB(17,18,22),Button=Color3.fromRGB(30,31,37),Selected=Color3.fromRGB(62,65,75),Text=Color3.fromRGB(245,246,249),Muted=Color3.fromRGB(182,186,196)}
local styled=setmetatable({},{__mode="k"})
local function transparency(value)
 if player:GetAttribute("SettingHighContrast") then return 0 end
 local ok,preferred=pcall(function() return Gui.PreferredTransparency end)
 return value*(ok and preferred or 1)
end
local function corner(p,r) local c=p:FindFirstChildOfClass("UICorner") or Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=p end
local function stroke(p)
 local s=p:FindFirstChild("AcrylicEdge") or Instance.new("UIStroke") s.Name="AcrylicEdge" s.Color=Color3.new(1,1,1) s.Thickness=1 s.Transparency=.85 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=p
end
function Theme.Surface(p)
 p.BackgroundColor3=Theme.Colors.Surface p.BackgroundTransparency=p:GetAttribute("CascadePane") and 0 or transparency(.22) p.BorderSizePixel=0 corner(p,18) stroke(p)
 if not p:FindFirstChild("AcrylicTint") then local g=Instance.new("UIGradient") g.Name="AcrylicTint" g.Color=ColorSequence.new(Color3.fromRGB(215,220,235),Color3.fromRGB(115,118,130)) g.Rotation=90 g.Parent=p end
end
local depthTweens=setmetatable({},{__mode="k"})
function Theme.CascadeDepth(p,behind,animate)
 p:SetAttribute("CascadePane",true) p:SetAttribute("CascadeBehind",behind)
 Theme.Surface(p)
 local shade=p:FindFirstChild("DepthShade")
 if not shade then
  shade=Instance.new("Frame") shade.Name="DepthShade" shade:SetAttribute("CascadeDecoration",true)
  shade.Size=UDim2.fromScale(1,1) shade.BackgroundColor3=Color3.new(0,0,0) shade.BackgroundTransparency=1
  shade.BorderSizePixel=0 shade.Active=false shade.Selectable=false shade.ZIndex=0 corner(shade,18)
  local gradient=Instance.new("UIGradient")
  gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.55),NumberSequenceKeypoint.new(.75,.15),NumberSequenceKeypoint.new(1,0)})
  gradient.Parent=shade shade.Parent=p
 end
 if depthTweens[p] then depthTweens[p]:Cancel() depthTweens[p]=nil end
 local opacity=behind>0 and math.min(.24,.08+(behind-1)*.06) or 0
 shade.Visible=opacity>0
 if animate and opacity>0 then
  local tween=Tween:Create(shade,TweenInfo.new(.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1-opacity})
  depthTweens[p]=tween tween:Play()
 else shade.BackgroundTransparency=1-opacity end
end
function Theme.Button(b)
 if styled[b] then return end styled[b]=true
 b.BackgroundColor3=Theme.Colors.Button b.BackgroundTransparency=transparency(.28) b.BorderSizePixel=0
 b.AutoButtonColor=false b.Font=Enum.Font.GothamMedium b.TextColor3=Theme.Colors.Text corner(b,14) stroke(b)
 local function recolor()
  local c=b.BackgroundColor3
  -- The neutral button palette is already styled; never reinterpret it as selection.
  if c==Theme.Colors.Button or c==Theme.Colors.Selected then return end
  if c.B>c.R+.025 or c.G>c.R+.06 then b.BackgroundColor3=Theme.Colors.Selected end
 end
 b:GetPropertyChangedSignal("BackgroundColor3"):Connect(recolor)
 b.MouseEnter:Connect(function() if Theme.ReducedMotion() then b.BackgroundTransparency=transparency(.1) return end Tween:Create(b,TweenInfo.new(.12),{BackgroundTransparency=transparency(.1)}):Play() end)
 b.MouseLeave:Connect(function() if Theme.ReducedMotion() then b.BackgroundTransparency=transparency(.28) return end Tween:Create(b,TweenInfo.new(.12),{BackgroundTransparency=transparency(.28)}):Play() end)
end
function Theme.RefreshAccessibility(v)
 if styled[v] then v.BackgroundTransparency=transparency(.28) end
 local edge=v:FindFirstChild("AcrylicEdge")
 if edge then edge.Transparency=player:GetAttribute("SettingHighContrast") and .35 or .85 end
end
function Theme.Text(parent,name,value,height,size)
 local t=Instance.new("TextLabel") t.Name=name t.BackgroundTransparency=1 t.Text=value t.TextColor3=Theme.Colors.Text t.TextSize=size or 15 t.Font=Enum.Font.GothamMedium t.TextXAlignment=Enum.TextXAlignment.Left t.TextYAlignment=Enum.TextYAlignment.Top t.TextWrapped=true t.Size=UDim2.new(1,-8,0,height or 50) t.Parent=parent return t
end
local surfaces={Main=true,Options=true,Categories=true,Detail=true,RootPane=true,Dialog=true,Tools=true}
function Theme.Apply(gui)
 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 local function style(v)
  if not v:IsA("GuiObject") or v:GetAttribute("CascadeDecoration") then return end
  if v:IsA("TextButton") and v.Name=="Slider" then v.BackgroundColor3=Color3.fromRGB(74,76,84) v.BackgroundTransparency=.15 corner(v,5)
  elseif v:IsA("Frame") and v.Name=="Fill" and v.Parent.Name=="Slider" then v.BackgroundColor3=Theme.Colors.Muted
  elseif v:IsA("TextButton") then
   local mobile=gui.Name=="MobileCombatHUD" and (v.Parent.Name=="Controls" or v.Parent.Name=="Editor" and v.Name~="ToggleInspector")
   if not mobile then Theme.Button(v) end
  elseif v:IsA("TextBox") then v.BackgroundColor3=Theme.Colors.Button v.TextColor3=Theme.Colors.Text corner(v,9)
  elseif v:IsA("Frame") then
   if v.Name=="Shade" or v.Name=="Backdrop" or v.Name=="VoteShade" or v.Name=="LeaveShade" or v.Parent==gui and v.Size==UDim2.fromScale(1,1) then v.BackgroundTransparency=1
   elseif v.Parent:IsA("ScrollingFrame") and v.BackgroundTransparency<1 or surfaces[v.Name] or v.Name=="StatusPanel" and gui.Name=="CrossgroundsHub" or v.Name=="Panel" and gui.Name~="ExperienceMenu" and not v:GetAttribute("CascadeRoot") then Theme.Surface(v) end
  end
 end
 for _,v in gui:GetDescendants() do style(v) end gui.DescendantAdded:Connect(style)
end
return Theme


