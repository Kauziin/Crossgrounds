local Dialog={}
local Theme=require(script.Parent.MenuTheme)
function Dialog.new(options)
 local nav=options.Navigation local player=game.Players.LocalPlayer local previous=nav:GetFocus()local dead=false
 local gui=Instance.new('ScreenGui')gui.Name='MenuDialog'gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=90
 local shade=Instance.new('TextButton')shade.Name='Modal'shade.Text=''shade.Size=UDim2.fromScale(1,1)shade.BackgroundColor3=Color3.new()shade.BackgroundTransparency=.42 shade:SetAttribute('CascadeDecoration',true)shade.Parent=gui
 local panel=Instance.new('Frame')panel.Name='Panel'panel.AnchorPoint=Vector2.new(.5,.5)panel.Position=UDim2.fromScale(.5,.5)panel:SetAttribute('CascadeDecoration',true)panel.Parent=shade Theme.Surface(panel)
 local list=Instance.new('ScrollingFrame')list.Name='Content'list.BackgroundTransparency=1 list.BorderSizePixel=0 list.Position=UDim2.fromOffset(16,16)list.Size=UDim2.new(1,-32,1,-32)list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new()list.ScrollBarThickness=3 list.Parent=panel
 local flow=Instance.new('UIListLayout')flow.Padding=UDim.new(0,8)flow.SortOrder=Enum.SortOrder.LayoutOrder flow.Parent=list
 local title=Theme.Text(list,'Title',options.Title or 'Confirmar',32,20)title.Font=Enum.Font.GothamBold title.LayoutOrder=0
 local message=Theme.Text(list,'Message',options.Message or '',54,14)message.AutomaticSize=Enum.AutomaticSize.Y message.LayoutOrder=1
 local self={Root=shade}local buttons={}
 local function close()
  if dead then return end dead=true nav:SetFloatingRoot(nil)gui:Destroy()
  if options.Closed then options.Closed()end
  if previous and previous.Parent then nav:Focus(previous)end
 end
 for i,action in options.Actions do
  local b=Instance.new('TextButton')b.Name=action.Name or 'Action'..i b.Text=action.Text b.TextSize=15 b.TextWrapped=true b.Size=UDim2.new(1,-4,0,48)b.LayoutOrder=i+1 b:SetAttribute('CascadeDecoration',true)b:SetAttribute('MenuSelected',i==1)b.Parent=list Theme.Button(b)
  if action.Destructive then local mark=Instance.new('Frame')mark.Name='Danger'mark:SetAttribute('ThemePreserve',true)mark.BackgroundColor3=Color3.fromRGB(244,115,121)mark.BorderSizePixel=0 mark.Position=UDim2.fromOffset(0,8)mark.Size=UDim2.new(0,3,1,-16)mark.Parent=b end
  nav:Connect(b,function()close()if action.Callback then action.Callback()end end)table.insert(buttons,b)
 end
 local function resize()
  local v=Theme.MenuBounds(workspace.CurrentCamera.ViewportSize) local scale=player:GetAttribute('SettingMenuScale')or 1
  local fit=panel:FindFirstChildOfClass('UIScale')or Instance.new('UIScale',panel)fit.Scale=scale*Theme.MobileFactor()
  panel.Size=UDim2.fromOffset(math.min(480,(v.X-28)/scale),math.min(math.max(140+#buttons*56,flow.AbsoluteContentSize.Y+40),(v.Y-28)/scale))
  for _,b in buttons do b.Size=UDim2.new(1,-4,0,math.max(48,30*(player:GetAttribute('SettingFontScale')or 1)+16))end
 end
 local c=workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(resize)
 local f=player:GetAttributeChangedSignal('SettingFontScale'):Connect(resize)
 local m=player:GetAttributeChangedSignal('SettingMenuScale'):Connect(resize)
 local stopMobile=Theme.ObserveMobile(resize)
 local content=flow:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(resize)
 gui.Destroying:Once(function()c:Disconnect()f:Disconnect()m:Disconnect()content:Disconnect()stopMobile()end)
 gui.Parent=player.PlayerGui nav:SetFloatingRoot(shade,close,buttons[1])nav:SetBack(shade,close,buttons[1])resize()
 task.defer(function()if not dead then nav:Focus(buttons[1])end end)
 function self:Destroy()close()end
 return self
end
return Dialog
