-- One visible page; data, navigation callbacks and setting cards are unchanged.
local Layout={}
local Theme=require(script.Parent.MenuTheme)
local Accent=require(script.Parent.AccentTheme)
local Visual=require(script.Parent.SettingsVisual)
function Layout.Apply(c)
 local compact=c.Height<450 local leaf=not c.Categories[c.Page]
 local id=leaf and 'Detail'or c.Page=='Options'and 'Options'or 'Categories'
 local f=c.Panes[id]local list=c.Lists[id]
 local top=compact and 36 or 48 local heading=compact and 46 or 58
 c.Panel:SetAttribute('CascadeDepth',2)
 for name,pane in c.Panes do
  pane:SetAttribute('NeoSettingsPage',true)
  pane.Visible=name==id pane.BackgroundTransparency=1 pane.ZIndex=1
  local shade=pane:FindFirstChild('DepthShade')if shade then shade.Visible=false end
  local edge=pane:FindFirstChild('AcrylicEdge')if edge then edge.Transparency=1 end
 end
 f.Position=UDim2.fromOffset(0,top)f.Size=UDim2.fromOffset(c.Width,c.Height-top-32)
 f.Back.Visible=true f.Back.Text='‹  '..(c.Titles[c.Page]or c.Page)f.Back.TextXAlignment=Enum.TextXAlignment.Left f.Back.TextSize=compact and 21 or 28
 f.Back.Position=UDim2.fromOffset(4,0)f.Back.Size=UDim2.new(1,-12,0,heading)
 Accent.Role(f.Back,'TextColor3','Accent')
 local description=not compact and leaf and c.Page~='Bindings'
 c.Subtitle.Visible=description c.Subtitle.Text=Visual.Descriptions[c.Page]or 'Personalize suas preferências.'
 c.Subtitle.Position=UDim2.fromOffset(18,heading)c.Subtitle.Size=UDim2.new(1,-36,0,28)
 local contentY=heading+(description and 36 or 6)+(c.Page=='Bindings'and 50 or 0)
 c.BindingTabs.Position=UDim2.fromOffset(8,heading+2)
 list.Position=UDim2.fromOffset(8,contentY)
 list.Size=UDim2.new(1,-24,1,-contentY-8)
 if not leaf then list.Size=UDim2.new(0,math.min(520,c.Width-24),1,-contentY-8)end
 for _,b in list:GetChildren()do if b:IsA('TextButton')then
  if b:GetAttribute('CompactRail')then b.Text=b:GetAttribute('ExpandedText')or b.Name end
  b:SetAttribute('CompactRail',false)b:SetAttribute('MenuSelected',false)
  b.TextWrapped=true b.TextTruncate=Enum.TextTruncate.None b.TextSize=16
  b.Size=UDim2.new(1,-4,0,math.max(46,(compact and 46 or 54)*(game.Players.LocalPlayer:GetAttribute('SettingFontScale')or 1)))
  local icon=b:FindFirstChild('CategoryIcon')or Visual.Icon(b,b.Name,22)
  icon.Visible=not leaf icon.Size=UDim2.fromOffset(22,22)icon.Position=UDim2.new(0,-32,.5,-11)
  local pad=b:FindFirstChildOfClass('UIPadding')if pad then pad.PaddingLeft=UDim.new(0,leaf and 12 or 46)pad.PaddingRight=UDim.new(0,10)end
 end end
 return id
end
return Layout
