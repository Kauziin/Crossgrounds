-- Presentation only: existing Resume/Loadout/Exit/Surrender callbacks are retained.
local Layout={}
local Accent=require(script.Parent.AccentTheme)
function Layout.Apply(c)
 local title=c.Panel:FindFirstChild('NeoPauseTitle')
 if not c.Active then
  if title then title.Visible=false end
  for _,pane in c.Panes do for _,b in pane.List:GetChildren()do local line=b:FindFirstChild('NeoDivider')if line then line.Visible=false end end end
  return
 end
 if not title then
  title=Instance.new('TextLabel')title.Name='NeoPauseTitle'title.BackgroundTransparency=1 title.Font=Enum.Font.GothamBold title.TextXAlignment=Enum.TextXAlignment.Left title.Parent=c.Panel
  Accent.Role(title,'TextColor3','Accent')
 end
 local compact=c.Height<450 local top=compact and 38 or 52
 title.Visible=true title.Text=({Main='PAUSA',Exit='SAIR DA MODALIDADE',Surrender='RENDER-SE'})[c.Page]
 title.TextSize=compact and 23 or 30 title.Position=UDim2.fromOffset(4,top)title.Size=UDim2.new(1,-16,0,42)
 local id=c.Page=='Main'and 'Main'or 'Detail'
 for name,pane in c.Panes do
  pane.Visible=name==id pane:SetAttribute('NeoSettingsPage',true)pane.BackgroundTransparency=1
  local edge=pane:FindFirstChild('AcrylicEdge')if edge then edge.Transparency=1 end
  local shade=pane:FindFirstChild('DepthShade')if shade then shade.Visible=false end
 end
 local pane=c.Panes[id]pane.Position=UDim2.fromOffset(0,top+48)pane.Size=UDim2.new(1,0,1,-top-84)pane.Back.Visible=id~='Main'
 pane.Back.Text='‹  Voltar'pane.Back.Position=UDim2.fromOffset(4,0)pane.Back.Size=UDim2.fromOffset(140,44)
 local list=c.Lists[id]list.Position=UDim2.fromOffset(8,id=='Main'and 0 or 50)list.Size=UDim2.new(0,math.min(c.Width-24,id=='Main'and 440 or 700),1,id=='Main'and -4 or -54)
 local font=game.Players.LocalPlayer:GetAttribute('SettingFontScale')or 1
 for _,b in list:GetChildren()do
  if b:IsA('TextButton')then
   b.Size=UDim2.new(1,-6,0,math.max(46,(compact and 46 or 54)*font))b.TextSize=16 b.TextXAlignment=Enum.TextXAlignment.Left
   local line=b:FindFirstChild('NeoDivider')
   if not line then line=Instance.new('Frame')line.Name='NeoDivider'line:SetAttribute('SettingsStyled',true)line.BorderSizePixel=0 line.BackgroundTransparency=.75 line.Position=UDim2.new(0,0,1,-1)line.Size=UDim2.new(1,0,0,1)line.Parent=b Accent.Role(line,'BackgroundColor3','Border')end
   line.Visible=true
  elseif b:IsA('TextLabel')then b.Size=UDim2.new(1,-8,0,b.Size.Y.Offset)b.TextSize=15 end
 end
 c.Panel:SetAttribute('CascadeDepth',2)
end
return Layout
