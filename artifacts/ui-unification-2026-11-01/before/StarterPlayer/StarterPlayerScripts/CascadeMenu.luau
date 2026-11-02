local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Tween=game:GetService("TweenService")
local player=game.Players.LocalPlayer
local Cascade={} Cascade.__index=Cascade
function Cascade.new(gui,name,title)
 gui.IgnoreGuiInset=false gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 local backdrop=Instance.new("Frame") backdrop.Name=name backdrop.BackgroundTransparency=1 backdrop.Size=UDim2.fromScale(1,1) backdrop.Visible=false backdrop.Parent=gui
 local panel=Instance.new("Frame") panel.Name="Panel" panel:SetAttribute("CascadeRoot",true) panel.BackgroundTransparency=1 panel.Size=UDim2.new(1,-32,1,-48) panel.AnchorPoint=Vector2.new(.5,.5) panel.Position=UDim2.fromScale(.5,.5) panel.Parent=backdrop
 local heading=Theme.Text(panel,"Title",title,30,22)
 local self=setmetatable({Backdrop=backdrop,Panel=panel,Heading=heading,Panes={},Stack={}},Cascade)
 self:AddPane("RootPane",title)
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() self:Resize(false) end)
 player:GetAttributeChangedSignal("SettingMenuScale"):Connect(function() self:Resize(false) end)
 Nav:SetBack(panel,function() if #self.Stack>1 then self:Push({self.Stack[1]}) elseif self.OnClose then self.OnClose() end end)
 return self
end
function Cascade:AddPane(id,title)
 local f=Instance.new("Frame") f.Name=id f.Visible=false f.Active=true f.ClipsDescendants=true f:SetAttribute("CascadePane",true) Theme.Surface(f) f.Parent=self.Panel
 local back=Instance.new("TextButton") back.Name="Back" back.Text="‹  "..title back.TextSize=15 back.TextXAlignment=Enum.TextXAlignment.Left back.Size=UDim2.new(1,-16,0,36) back.Position=UDim2.fromOffset(8,8) back.Parent=f Theme.Button(back)
 local list=Instance.new("ScrollingFrame") list.Name="List" list.BackgroundTransparency=1 list.BorderSizePixel=0 list.Position=UDim2.fromOffset(10,52) list.Size=UDim2.new(1,-20,1,-62) list.ScrollBarThickness=3 list.ScrollBarImageColor3=Theme.Colors.Muted list.CanvasSize=UDim2.new() list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.Parent=f
 local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,7) layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=list
 self.Panes[id]={Frame=f,List=list,Back=back}
 Nav:Connect(back,function() local at=table.find(self.Stack,id) if at and at>1 then local previous={} for i=1,at-1 do previous[i]=self.Stack[i] end self:Push(previous) elseif self.OnClose then self.OnClose() end end)
 return list
end
function Cascade:Button(id,name,text,callback,height)
 local list=self.Panes[id].List
 local b=Instance.new("TextButton") b.Name=name b.Text="  "..text b.TextXAlignment=Enum.TextXAlignment.Left b.TextWrapped=true b.TextSize=15 b.Size=UDim2.new(1,-4,0,height or 46) b.Parent=list Theme.Button(b)
 local pad=Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0,10) pad.PaddingRight=UDim.new(0,10) pad.Parent=b
 Nav:Connect(b,callback) return b
end
function Cascade:Info(id,name,text,height)
 local t=Theme.Text(self.Panes[id].List,name,text,height or 68,14) Nav:Register(t,function() end) return t
end
function Cascade:Push(ids)
 self.Stack=ids self:Resize(true)
 task.delay(.04,function() if self.Backdrop.Visible then local p=self.Panes[ids[#ids]] if p then local target=p.Back for _,v in p.List:GetChildren() do if v:IsA("TextButton") then target=v break end end Nav:Focus(target) end end end)
end
function Cascade:SetOpen(on)
 self.Backdrop.Visible=on
 if on then if #self.Stack==0 then self.Stack={"RootPane"} end self:Resize(true) end
end
function Cascade:Resize(animate)
 local v=self.Backdrop.AbsoluteSize if v.X<200 or v.Y<150 then v=workspace.CurrentCamera.ViewportSize end
 local w=math.min(1120,v.X-32) local h=math.min(660,v.Y-40) self.Panel.Size=UDim2.fromOffset(w,h)
 local scale=player:GetAttribute("SettingMenuScale") or 1
 local modifier=self.Panel:FindFirstChild("PreferenceScale") or Instance.new("UIScale") modifier.Name="PreferenceScale" modifier.Scale=scale modifier.Parent=self.Panel
 w=math.min(1120,(v.X-24)/scale) h=math.min(660,(v.Y-20)/scale) self.Panel.Size=UDim2.fromOffset(w,h)
 local narrow=w<720
 local n=#self.Stack self.Panel:SetAttribute("CascadeDepth",n) local step=218
 if step*(n-1)+330>w then step=math.max(28,(w-math.min(330,w-(n-1)*28))/math.max(1,n-1)) end
 for _,p in self.Panes do p.Frame.Visible=false end
 for i,id in self.Stack do
  local p=self.Panes[id] local x=(i-1)*step local target=UDim2.fromOffset(x,38+(i-1)*6)
  p.Frame.Visible=not narrow or i==n if narrow then x=0 target=UDim2.fromOffset(0,38) end p.Frame.ZIndex=i p.Frame.Size=UDim2.fromOffset(narrow and w or n==1 and math.min(w,310) or i==n and w-x or step-8,h-76-(i-1)*6)
  Theme.CascadeDepth(p.Frame,n-i,animate and not Theme.ReducedMotion())
  for _,b in p.List:GetChildren() do if b:IsA("TextButton") then b.TextWrapped=i==n b.TextTruncate=i==n and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd end end
  if id=="RootPane" then
   p.Back.Visible=false p.List.Position=UDim2.fromOffset(10,10) p.List.Size=UDim2.new(1,-20,1,-20)
   local buttons={} for _,v in p.List:GetChildren() do if v:IsA("TextButton") then table.insert(buttons,v) end end
   for _,b in buttons do b.Size=UDim2.new(1,-4,0,math.clamp((p.Frame.Size.Y.Offset-20-math.max(0,#buttons-1)*7)/math.max(1,#buttons),46,58)) end
  end
  if animate and not Theme.ReducedMotion() then p.Frame.Position=target+UDim2.fromOffset(14,0) Tween:Create(p.Frame,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=target}):Play() else p.Frame.Position=target end
 end
end
return Cascade
