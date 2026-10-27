local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Grid={} Grid.__index=Grid
function Grid.Measure(width,count,minCard,maxColumns)
 local gap=10
 local columns=math.clamp(math.floor((width+gap)/((minCard or 120)+gap)),1,maxColumns or 5)
 local cell=math.max(1,math.floor((width-gap*(columns-1))/columns))
 return columns,cell,math.ceil(count/columns)*(cell+gap)-(count>0 and gap or 0)
end
function Grid.new(parent,onSelect)
 local frame=Instance.new("Frame") frame.Name="MapGrid" frame.BackgroundTransparency=1 frame.Size=UDim2.new(1,-8,0,1) frame.LayoutOrder=10 frame.Parent=parent
 local layout=Instance.new("UIGridLayout") layout.CellPadding=UDim2.fromOffset(10,10) layout.SortOrder=Enum.SortOrder.LayoutOrder layout.FillDirectionMaxCells=5 layout.Parent=frame
 local self=setmetatable({Frame=frame,Layout=layout,Cards={},Order={},Options={},OnSelect=onSelect,Enabled=false},Grid)
 frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()self:Resize()end)
 return self
end
function Grid:Resize()
 local scale=1 local ancestor=self.Frame
 while ancestor and not ancestor:IsA("PlayerGui") do
  local modifier=ancestor:FindFirstChildOfClass("UIScale") if modifier then scale*=modifier.Scale end
  ancestor=ancestor.Parent
 end
 local columns,cell,height=Grid.Measure(self.Frame.AbsoluteSize.X/math.max(.1,scale),#self.Order)
 self.Layout.FillDirectionMaxCells=columns self.Layout.CellSize=UDim2.fromOffset(cell,cell)
 self.Frame.Size=UDim2.new(1,-8,0,height)
 for i,card in self.Order do
  local column=(i-1)%columns
  card.NextSelectionLeft=column>0 and self.Order[i-1] or nil
  card.NextSelectionRight=column<columns-1 and self.Order[i+1] or nil
  card.NextSelectionUp=self.Order[i-columns]
  card.NextSelectionDown=self.Order[i+columns]
 end
end
function Grid:SetOptions(options)
 local parts={} for _,option in options do table.insert(parts,option.id..":"..option.name) end
 local signature=table.concat(parts,"|") if self.Signature==signature then return end self.Signature=signature
 for _,card in self.Order do card:Destroy() end self.Cards={} self.Order={} self.Options=options
 for index,option in options do
  local id=option.id
  local card=Instance.new("TextButton") card.Name=id card.Text="" card.LayoutOrder=index card.Parent=self.Frame Theme.Button(card)
  local accent=Instance.new("Frame") accent.Name="Accent" accent.BackgroundColor3=Color3.fromRGB(80,146,172) accent.BorderSizePixel=0 accent.Position=UDim2.fromOffset(12,12) accent.Size=UDim2.new(1,-24,0,4) accent.Parent=card
  local name=Instance.new("TextLabel") name.Name="MapName" name.BackgroundTransparency=1 name.Position=UDim2.new(0,12,.15,0) name.Size=UDim2.new(1,-24,.55,0)
  name.Text=option.name name.TextColor3=Theme.Colors.Text name.Font=Enum.Font.GothamBold name.TextSize=18 name.TextWrapped=true name.Parent=card
  local tally=Instance.new("TextLabel") tally.Name="Votes" tally.BackgroundTransparency=1 tally.Position=UDim2.new(0,12,.76,0) tally.Size=UDim2.new(1,-24,.16,0)
  tally.Font=Enum.Font.GothamMedium tally.TextSize=13 tally.TextColor3=Theme.Colors.Muted tally.Text="0 votos" tally.Parent=card
  local selected=Instance.new("TextLabel") selected.Name="SelectionMarker" selected.AnchorPoint=Vector2.new(1,0) selected.Position=UDim2.new(1,-7,0,4) selected.Size=UDim2.fromOffset(28,28)
  selected.Text="✓" selected.TextSize=21 selected.Font=Enum.Font.GothamBold selected.TextColor3=Color3.fromRGB(164,242,213) selected.BackgroundTransparency=1 selected.Visible=false selected.Parent=card
  Nav:Connect(card,function()if self.Enabled then self.OnSelect(id)end end)
  self.Cards[id]=card table.insert(self.Order,card)
 end
 self:Resize()
end
function Grid:Update(counts,choice,enabled)
 self.Enabled=enabled==true
 for id,card in self.Cards do
  local votes=counts[id] or 0 card.Votes.Text=tostring(votes)..(votes==1 and " voto" or " votos")
  card:FindFirstChild("SelectionMarker").Visible=id==choice card.BackgroundColor3=id==choice and Theme.Colors.Selected or Theme.Colors.Button
  card.AutoButtonColor=false card:SetAttribute("SelectedMap",id==choice)
 end
end
function Grid:First()return self.Order[1]end
return Grid


