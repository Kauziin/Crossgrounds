local Theme={}
local Tween=game:GetService('TweenService') local Gui=game:GetService('GuiService')
local player=game.Players.LocalPlayer local Accent=require(script.Parent:WaitForChild('AccentTheme'))
Theme.Colors={} Theme.Settings={}
local function palette()
 for k,v in Accent.Palette() do Theme.Colors[k]=v Theme.Settings[k]=v end
end
palette() Accent.Changed:Connect(palette)
Theme.Radius={Panel=16,Card=12,Button=10,Small=6}
Theme.Spacing={Gap=8,Inset=12}
local UIS=game:GetService('UserInputService')
function Theme.Mobile() return player~=nil and UIS.TouchEnabled and not Gui:IsTenFootInterface() end
function Theme.MobileFactor() return require(game.ReplicatedStorage.Crossgrounds.InterfaceLayout).MobileScale(Theme.Mobile(),player and player:GetAttribute('SettingMobileMenuScale')) end
function Theme.Scale() return (player and player:GetAttribute('SettingMenuScale')or 1)*Theme.MobileFactor() end
function Theme.MenuBounds(size)
 if not Theme.Mobile()then return size end
 local _,usable=require(game.ReplicatedStorage.Crossgrounds.MobileLayout).SafeBounds(size,player:GetAttribute('SettingTouchSafeX'),player:GetAttribute('SettingTouchSafeY'))
 return usable
end
function Theme.ObserveMobile(callback)
 if not player then return function()end end
 local connections={}
 for _,key in {'MobileMenuScale','TouchSafeX','TouchSafeY'}do table.insert(connections,player:GetAttributeChangedSignal('Setting'..key):Connect(callback))end
 table.insert(connections,UIS:GetPropertyChangedSignal('TouchEnabled'):Connect(callback))
 return function()for _,c in connections do c:Disconnect()end end
end
function Theme.ReducedMotion()
 local state=player.PlayerGui:FindFirstChild('PreferenceState')
 if state and state:GetAttribute('PreferenceGlobalReducedMenuMotion')~=nil then return player:GetAttribute('SettingReducedMenuMotion')==true end
 local ok,native=pcall(function()return Gui.ReducedMotionEnabled end)
 return player:GetAttribute('SettingReducedMenuMotion')==true or ok and native
end
local function alpha(value)
 if player:GetAttribute('SettingHighContrast')then return 0 end
 local ok,preferred=pcall(function()return Gui.PreferredTransparency end) return value*(ok and preferred or 1)
end
local function corner(p,r)
 local c=p:FindFirstChildOfClass('UICorner') or Instance.new('UICorner') c.CornerRadius=UDim.new(0,r) c.Parent=p
end
local function edge(p)
 local s=p:FindFirstChild('AcrylicEdge') or Instance.new('UIStroke') s.Name='AcrylicEdge' s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Thickness=1 s.Transparency=.45 s.Parent=p
 Accent.Role(s,'Color','Border') return s
end
function Theme.Surface(p)
 p.BorderSizePixel=0 p.BackgroundTransparency=alpha(p:GetAttribute('CascadePane') and .03 or .10)
 Accent.Role(p,'BackgroundColor3','Surface') corner(p,Theme.Radius.Panel) edge(p)
 local g=p:FindFirstChild('AcrylicTint') if g then g:Destroy()end
end
local depthTweens=setmetatable({},{__mode='k'})
function Theme.CascadeDepth(p,behind,animate)
 p:SetAttribute('CascadePane',true) p:SetAttribute('CascadeBehind',behind) Theme.Surface(p)
 local shade=p:FindFirstChild('DepthShade')
 if not shade then
  shade=Instance.new('Frame') shade.Name='DepthShade' shade:SetAttribute('CascadeDecoration',true) shade:SetAttribute('ThemePreserve',true)
  shade.Size=UDim2.fromScale(1,1) shade.BackgroundColor3=Color3.new() shade.BackgroundTransparency=1 shade.BorderSizePixel=0 shade.Active=false shade.Selectable=false shade.ZIndex=0 shade.Parent=p corner(shade,Theme.Radius.Panel)
 end
 if depthTweens[p]then depthTweens[p]:Cancel()depthTweens[p]=nil end
 local amount=behind>0 and math.min(.22,.07+(behind-1)*.05)or 0 shade.Visible=amount>0
 if animate and amount>0 then local t=Tween:Create(shade,TweenInfo.new(.16),{BackgroundTransparency=1-amount})depthTweens[p]=t t:Play()else shade.BackgroundTransparency=1-amount end
end
local styled=setmetatable({},{__mode='k'})
local function paint(b,r)
 if not b.Parent then return end
 local selected=b:GetAttribute('MenuSelected')==true
 Accent.Role(b,'BackgroundColor3',selected and 'Selected' or 'Button')
 b.BackgroundTransparency=alpha(selected and .03 or r.hover and .05 or .14)
 local s=edge(b) s.Thickness=(selected or r.hover)and 2 or 1 s.Transparency=(selected or r.hover)and .04 or .50
 Accent.Role(s,'Color',(selected or r.hover)and 'Accent' or 'Border')
end
function Theme.Button(b)
 if styled[b]then return end local r={hover=false}styled[b]=r
 b.AutoButtonColor=false b.Font=Enum.Font.GothamMedium b.TextColor3=Theme.Colors.Text b.BorderSizePixel=0 corner(b,Theme.Radius.Button)
 b.MouseEnter:Connect(function()r.hover=true paint(b,r)end)
 b.MouseLeave:Connect(function()r.hover=false paint(b,r)end)
 b:GetAttributeChangedSignal('MenuSelected'):Connect(function()paint(b,r)end)
 paint(b,r)
end
function Theme.RefreshAccessibility(v)
 local r=styled[v] if r then paint(v,r)end
 local s=v:FindFirstChild('AcrylicEdge')if s and not r then s.Transparency=player:GetAttribute('SettingHighContrast')and .12 or .45 end
end
function Theme.Text(parent,name,value,height,size)
 local t=Instance.new('TextLabel')t.Name=name t.BackgroundTransparency=1 t.Text=value t.TextColor3=Theme.Colors.Text t.TextSize=size or 15 t.Font=Enum.Font.GothamMedium t.TextXAlignment=Enum.TextXAlignment.Left t.TextYAlignment=Enum.TextYAlignment.Top t.TextWrapped=true t.Size=UDim2.new(1,-8,0,height or 50)t.Parent=parent return t
end
local surfaces={Main=true,Options=true,Categories=true,Detail=true,RootPane=true,Dialog=true,Tools=true,Scoreboard=true}
function Theme.Apply(gui)
 Accent.Bind(gui) gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 local function style(v)
  if not v:IsA('GuiObject')or v:GetAttribute('CascadeDecoration')or v:GetAttribute('SettingsStyled')then return end
  if v:IsA('TextButton')and v.Name=='Slider'then return
  elseif v:IsA('TextButton')then
   local mobile=gui.Name=='MobileCombatHUD'and(v.Parent.Name=='Controls'or v.Parent.Name=='Editor'and v.Name~='ToggleInspector')
   if not mobile then Theme.Button(v)end
  elseif v:IsA('TextBox')then Accent.Role(v,'BackgroundColor3','Card')v.TextColor3=Theme.Colors.Text corner(v,Theme.Radius.Small)
  elseif v:IsA('Frame')then
   if v.Name=='Shade'or v.Name=='Backdrop'or v.Name=='VoteShade'or v.Name=='LeaveShade'or v.Parent==gui and v.Size==UDim2.fromScale(1,1)then
    if v.Name~='Editor'then v.BackgroundTransparency=1 end
   elseif v.Parent:IsA('ScrollingFrame')and v.BackgroundTransparency<1 or surfaces[v.Name]or v.Name=='StatusPanel'and gui.Name=='CrossgroundsHub'or v.Name=='Panel'and gui.Name~='ExperienceMenu'and not v:GetAttribute('CascadeRoot')then Theme.Surface(v)end
  end
 end
 for _,v in gui:GetDescendants()do style(v)end gui.DescendantAdded:Connect(style)
end
Accent.Changed:Connect(function()for b,r in styled do if b.Parent then paint(b,r)end end end)
return Theme
