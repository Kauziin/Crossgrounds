local View={}
local cyan=Color3.fromRGB(63,226,232) local death=Color3.fromRGB(255,151,102)
local function esc(s) return tostring(s or ""):gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;") end
local function short(s) s=tostring(s or "") local at=utf8.offset(s,17) return at and s:sub(1,at-1).."…" or s end
local function team(name) return name=="Blue" and "#83bcff" or name=="Red" and "#ff9c92" or "#eaf3fc" end
local function skull(parent)
 local icon=Instance.new("Frame") icon.Name="Headshot" icon.BackgroundTransparency=1 icon.Size=UDim2.fromOffset(22,24) icon.Position=UDim2.new(1,-27,0,9) icon.Parent=parent
 local function shape(name,x,y,w,h,color,round)
  local f=Instance.new("Frame") f.Name=name f.BackgroundColor3=color f.BorderSizePixel=0 f.Position=UDim2.fromOffset(x,y) f.Size=UDim2.fromOffset(w,h) f.Parent=icon
  if round then local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,round) c.Parent=f end
 end
 local orange=Color3.fromRGB(255,153,51) local hole=Color3.fromRGB(25,30,37)
 shape("Cranium",2,0,18,17,orange,7) shape("Jaw",5,13,12,8,orange,2)
 shape("LeftEye",5,7,4,5,hole,2) shape("RightEye",13,7,4,5,hole,2) shape("Nose",10,12,2,3,hole,1)
 shape("Tooth1",8,18,1,3,hole) shape("Tooth2",13,18,1,3,hole)
end
function View.new(parent,player,limit,lifetime)
 local self={Rows={}}
 local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,5) layout.HorizontalAlignment=Enum.HorizontalAlignment.Right layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=parent
 local sequence=0
 function self:Add(data)
  local kill=data.killerUserId==player.UserId local died=data.victimUserId==player.UserId local personal=kill or died
  sequence+=1
  local row=Instance.new("Frame") row.Name=personal and "PersonalElimination" or "Elimination" row:SetAttribute("CascadeDecoration",true) row:SetAttribute("LocalKill",kill) row:SetAttribute("LocalDeath",died) row.LayoutOrder=sequence row.Size=UDim2.new(1,0,0,0) row.AutomaticSize=Enum.AutomaticSize.Y row.BorderSizePixel=0 row.BackgroundColor3=Color3.fromRGB(11,23,31) row.BackgroundTransparency=personal and .22 or .65 row.Parent=parent
  local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,6) corner.Parent=row
  local tint=died and death or cyan
  if personal then local edge=Instance.new("UIStroke") edge.Color=tint edge.Thickness=1.5 edge.Transparency=.3 edge.Parent=row end
  local text=Instance.new("TextLabel") text.Name="Description" text.BackgroundTransparency=1 text.Position=UDim2.fromOffset(7,3) text.Size=UDim2.new(1,data.headshot and -39 or -14,0,personal and 46 or 34) text.AutomaticSize=Enum.AutomaticSize.Y text.Font=personal and Enum.Font.GothamBold or Enum.Font.GothamMedium text.TextSize=personal and 17 or 13 text.TextColor3=personal and tint or Color3.fromRGB(234,243,252) text.TextWrapped=true text.TextXAlignment=Enum.TextXAlignment.Right text.RichText=true text.Parent=row
  local function who(name,color) return personal and esc(short(name)) or '<font color="'..team(color)..'">'..esc(short(name))..'</font>' end
  text.Text=(data.killer and who(data.killer,data.killerTeam).."  ›  " or "")..who(data.victim,data.victimTeam).."\n"..esc(data.weapon or "Eliminado")
  if data.headshot then skull(row) end
  table.insert(self.Rows,row)
  if #self.Rows>limit then table.remove(self.Rows,1):Destroy() end
  task.delay(lifetime,function() local i=table.find(self.Rows,row) if i then table.remove(self.Rows,i) end row:Destroy() end)
 end
 return self
end
return View
