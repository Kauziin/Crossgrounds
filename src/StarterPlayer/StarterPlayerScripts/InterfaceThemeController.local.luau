local player=game.Players.LocalPlayer local Run=game:GetService("RunService")
local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Preferences=require(script.Parent:WaitForChild("PreferenceClient"))
local GuiService=game:GetService("GuiService")
local fonts=setmetatable({},{__mode="k"}) local applying=setmetatable({},{__mode="k"})
local hud={CombatHUD=true,ArenaHUD=true,MatchStandings=true,AccessibleInteractionHUD=true}
local function typography(v)
 if not (v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox")) then return end
 if not fonts[v] then
  fonts[v]={size=v.TextSize,color=v.TextColor3}
  v:GetPropertyChangedSignal("TextSize"):Connect(function()
   if not applying[v] and v.Parent and math.abs(v.TextSize-fonts[v].size*(player:GetAttribute("SettingFontScale") or 1))>.001 then fonts[v].size=v.TextSize
    applying[v]=true v.TextSize=fonts[v].size*(player:GetAttribute("SettingFontScale") or 1) applying[v]=nil
   end
  end)
 end
 applying[v]=true v.TextScaled=false v.TextSize=fonts[v].size*(player:GetAttribute("SettingFontScale") or 1) applying[v]=nil
 local _,saturation=fonts[v].color:ToHSV()
 if saturation<.2 then v.TextColor3=player:GetAttribute("SettingHighContrast") and Color3.new(1,1,1) or fonts[v].color end
end
local function scaleHUD(gui)
 if not hud[gui.Name] then return end
 local width=workspace.CurrentCamera.ViewportSize.X
 for _,v in gui:GetChildren() do
  if v:IsA("GuiObject") and v.Size~=UDim2.fromScale(1,1) then
   local scale=v:FindFirstChild("HUDPreferenceScale") or Instance.new("UIScale") scale.Name="HUDPreferenceScale" scale.Parent=v
   local nominal=player:GetAttribute("SettingHUDScale") or 1
   scale.Scale=math.min(nominal,(width-24)/math.max(1,v.Size.X.Offset+v.Size.X.Scale*width))
  end
 end
end
local names={ExperienceMenu=true,JoinMenu=true,CrossgroundsHub=true,ArenaHUD=true,CombatHUD=true,MobileCombatHUD=true,ProgressionPanel=true,HeldStandings=true,MatchStandings=true,AccessibleInteractionHUD=true,AccessibleMenuCursor=true,LobbyMusicMenu=true}
local bound=setmetatable({},{__mode="k"}) local panels=setmetatable({},{__mode="k"})
local function attach(gui)
 if not gui:IsA("ScreenGui") or not names[gui.Name] or bound[gui] then return end
 bound[gui]=true Theme.Apply(gui)
 local function track(v) typography(v) if v:IsA("Frame") and v.Name=="Panel" then panels[v]=gui end end
 for _,v in gui:GetDescendants() do track(v) end gui.DescendantAdded:Connect(track) scaleHUD(gui)
end
for _,g in player.PlayerGui:GetChildren() do attach(g) end player.PlayerGui.ChildAdded:Connect(attach)
local blur=Instance.new("BlurEffect") blur.Name="CrossgroundsMenuAcrylic" blur.Size=0 blur.Enabled=false blur.Parent=game.Lighting
local function visible(panel,gui)
 if not gui.Enabled then return false end
 local v=panel while v and v~=gui do if v:IsA("GuiObject") and not v.Visible then return false end v=v.Parent end
 return v==gui
end
local amount=0
local function refresh()
 for gui in bound do if gui.Parent then
  scaleHUD(gui)
  for _,v in gui:GetDescendants() do
   typography(v)
   if v:IsA("GuiObject") then Theme.RefreshAccessibility(v) end
   if v:IsA("Frame") and (v:GetAttribute("CascadePane") or v:FindFirstChild("AcrylicTint")) then Theme.Surface(v) end
  end
 end end
end
Preferences.Changed:Connect(function(changes)
 if not changes or changes.FontScale or changes.HighContrast or changes.HUDScale then refresh() end
end)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh)
pcall(function() GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(refresh) end)
Run.RenderStepped:Connect(function(dt)
 local depth=0 local order=-math.huge
 for panel,gui in panels do
  if panel.Parent and visible(panel,gui) then
   local d=panel:GetAttribute("CascadeDepth") or 0
   if d>0 and gui.DisplayOrder>=order then order=gui.DisplayOrder depth=d end
  end
 end
 if player:GetAttribute("HUDLayoutEditing") then depth=2 end
 local goal=depth>=2 and 18 or 0
 if Theme.ReducedMotion() then amount=goal else amount+=(goal-amount)*(1-math.exp(-dt*16)) end
 if math.abs(amount-goal)<.05 then amount=goal end
 blur.Enabled=amount>.05 blur.Size=amount
 player:SetAttribute("VisibleMenuDepth",depth)
end)
