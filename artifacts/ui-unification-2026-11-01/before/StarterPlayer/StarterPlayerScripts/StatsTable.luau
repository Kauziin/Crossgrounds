local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Table={} Table.__index=Table
local function cell(parent,column,x,header)
 local t=Theme.Text(parent,column.id,header and column.label or "",header and 24 or 32,header and 11 or 14)
 t.Position=UDim2.new(x,8,0,0) t.Size=UDim2.new(column.width,-16,1,0)
 t.TextYAlignment=Enum.TextYAlignment.Center t.TextXAlignment=column.align or Enum.TextXAlignment.Left
 t.TextTruncate=Enum.TextTruncate.AtEnd t.TextWrapped=false
 if header then t.TextColor3=Theme.Colors.Muted end
 return t
end
function Table.new(parent,name,columns)
 local holder=Instance.new("Frame") holder.Name=name holder.Size=UDim2.new(1,-8,0,0) holder.AutomaticSize=Enum.AutomaticSize.Y holder.BackgroundTransparency=1 holder.Parent=parent
 local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,4) layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=holder
 local header=Instance.new("Frame") header.Name="Headers" header.Size=UDim2.new(1,0,0,24) header.BackgroundTransparency=1 header.LayoutOrder=-1000 header.Parent=holder
 local x=0 for _,column in columns do cell(header,column,x,true) x+=column.width end
 return setmetatable({Holder=holder,Columns=columns,Rows={}},Table)
end
function Table:Clear()
 for _,row in self.Rows do row.Frame:Destroy() end self.Rows={}
end
function Table:Add(values,index)
 local row=Instance.new("Frame") row.Name="Row"..tostring(index or #self.Rows+1) row.Size=UDim2.new(1,0,0,32) row.LayoutOrder=index or #self.Rows+1 row.BackgroundColor3=Theme.Colors.Button row.BackgroundTransparency=.45 row.BorderSizePixel=0 row.Parent=self.Holder
 local round=Instance.new("UICorner") round.CornerRadius=UDim.new(0,9) round.Parent=row
 local fields={} local x=0
 for _,column in self.Columns do local t=cell(row,column,x,false) t.Text=tostring(values[column.id] or "—") fields[column.id]=t x+=column.width end
 local result={Frame=row,Fields=fields} table.insert(self.Rows,result) Nav:Register(row,function() end) return result
end
return Table
