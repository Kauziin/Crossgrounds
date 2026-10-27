-- Dedicated progression presentation. Data and requests stay in ProgressionPanel.
local V={}
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local player=game.Players.LocalPlayer
V.C={Surface=Color3.fromRGB(7,15,19),Card=Color3.fromRGB(22,31,36),Accent=Color3.fromRGB(0,231,233),Text=Color3.fromRGB(242,247,249),Muted=Color3.fromRGB(174,192,199),Edge=Color3.fromRGB(74,96,103),Peer=Color3.fromRGB(216,227,250)}
local C=V.C
local function make(class,parent,name)
 local o=Instance.new(class) o.Name=name or class
 if o:IsA("GuiObject") then o:SetAttribute("SettingsStyled",true) o.BorderSizePixel=0 end
 o.Parent=parent return o
end
function V.Round(o,r) local c=make("UICorner",o) c.CornerRadius=UDim.new(0,r or 12) return c end
function V.Edge(o,color,thickness)
 local s=o:FindFirstChild("Edge") or make("UIStroke",o,"Edge") s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Color=color or C.Edge s.Thickness=thickness or 1 s.Transparency=.3 return s
end
function V.Box(parent,name,height)
 local f=make("Frame",parent,name) f.Size=UDim2.new(1,0,0,height) f.BackgroundColor3=C.Card f.BackgroundTransparency=.12 V.Round(f) V.Edge(f) return f
end
function V.Text(parent,name,value,x,y,w,h,size,color)
 local t=make("TextLabel",parent,name) t.BackgroundTransparency=1 t.Text=value t.Position=UDim2.fromOffset(x,y) t.Size=UDim2.fromOffset(w,h)
 t.Font=Enum.Font.GothamMedium t.TextSize=size or 16 t.TextColor3=color or C.Text t.TextXAlignment=Enum.TextXAlignment.Left t.TextWrapped=true return t
end
function V.Area(parent,name,order,gap)
 local f=make("Frame",parent,name) f.Size=UDim2.new(1,-4,0,0) f.AutomaticSize=Enum.AutomaticSize.Y f.BackgroundTransparency=1 f.LayoutOrder=order or 0
 local l=make("UIListLayout",f) l.Padding=UDim.new(0,gap or 12) l.SortOrder=Enum.SortOrder.LayoutOrder return f
end
function V.Clear(f) for _,v in f:GetChildren() do if v:IsA("GuiObject") then v:Destroy() end end end
function V.Button(parent,name,value,callback)
 local b=make("TextButton",parent,name) b.Text=value b.Font=Enum.Font.GothamMedium b.TextColor3=C.Text b.TextSize=15 b.TextWrapped=true b.AutoButtonColor=false b.BackgroundColor3=C.Card b.BackgroundTransparency=.08
 V.Round(b,12) local edge=V.Edge(b)
 b.MouseEnter:Connect(function() edge.Color=C.Accent end) b.MouseLeave:Connect(function() if b:GetAttribute("Selected")~=true then edge.Color=C.Edge end end)
 if callback then Nav:Connect(b,callback) end return b
end
function V.Select(b,on)
 b:SetAttribute("Selected",on) b.BackgroundColor3=on and Color3.fromRGB(15,48,54) or C.Card
 local edge=b:FindFirstChild("Edge") if edge then edge.Color=on and C.Accent or C.Edge edge.Thickness=on and 2 or 1 edge.Transparency=on and 0 or .3 end
 local marker=b:FindFirstChild("SelectedMarker") if marker then marker.Visible=on end
end
local function line(p,x1,y1,x2,y2,color,thick)
 local delta=Vector2.new(x2-x1,y2-y1) local f=make("Frame",p) f.BackgroundColor3=color f.AnchorPoint=Vector2.new(.5,.5) f.Position=UDim2.fromOffset((x1+x2)/2,(y1+y2)/2) f.Size=UDim2.fromOffset(delta.Magnitude,thick or 2) f.Rotation=math.deg(math.atan2(delta.Y,delta.X)) V.Round(f,1) return f
end
local function ring(p,x,y,w,h,color)
 local f=make("Frame",p) f.BackgroundTransparency=1 f.Position=UDim2.fromOffset(x,y) f.Size=UDim2.fromOffset(w,h) V.Round(f,100) V.Edge(f,color,2).Transparency=0 return f
end
function V.Icon(parent,id,x,y,size,color)
 local p=make("Frame",parent,"Icon") p.BackgroundTransparency=1 p.Position=UDim2.fromOffset(x,y) p.Size=UDim2.fromOffset(32,32)
 local scale=make("UIScale",p) scale.Scale=(size or 32)/32 color=color or C.Accent
 if id=="Profile" or id=="Friends" then
  ring(p,11,3,10,10,color) ring(p,6,17,20,13,color)
  if id=="Friends" then ring(p,1,9,7,7,color) line(p,1,27,1,21,color) ring(p,24,9,7,7,color) line(p,31,21,31,27,color) end
 elseif id=="Wins" or id=="Leaders" then
  line(p,8,4,24,4,color) line(p,8,4,10,18,color) line(p,24,4,22,18,color) line(p,10,18,22,18,color) line(p,16,18,16,27,color) line(p,9,28,23,28,color)
  line(p,7,7,2,7,color) line(p,2,7,3,15,color) line(p,3,15,10,17,color) line(p,25,7,30,7,color) line(p,30,7,29,15,color) line(p,29,15,22,17,color)
 elseif id=="Crown" then
  line(p,4,24,28,24,color,3) line(p,4,24,2,8,color,3) line(p,2,8,10,15,color,3) line(p,10,15,16,3,color,3) line(p,16,3,22,15,color,3) line(p,22,15,30,8,color,3) line(p,30,8,28,24,color,3)
 elseif id=="Coins" then
  ring(p,10,3,17,8,color) ring(p,10,9,17,8,color) ring(p,3,16,17,8,color) ring(p,3,22,17,8,color)
 elseif id=="PlaySeconds" then
  ring(p,3,3,26,26,color) line(p,16,7,16,17,color) line(p,16,17,23,21,color)
 elseif id=="Captures" or id=="ctf" then
  line(p,6,30,9,3,color) line(p,9,4,19,7,color) line(p,19,7,28,4,color) line(p,28,4,25,18,color) line(p,25,18,17,20,color) line(p,17,20,8,17,color)
 elseif id=="Deaths" or id=="Losses" then
  ring(p,5,3,22,21,color) local l=make("Frame",p) l.BackgroundColor3=color l.Position=UDim2.fromOffset(10,21) l.Size=UDim2.fromOffset(13,8) V.Round(l,2)
  for _,x0 in {10,20} do local eye=make("Frame",p) eye.BackgroundColor3=C.Card eye.Position=UDim2.fromOffset(x0,11) eye.Size=UDim2.fromOffset(4,6) V.Round(eye,3) end
 elseif id=="Ratio" then
  line(p,1,19,9,19,color) line(p,9,19,13,5,color) line(p,13,5,19,27,color) line(p,19,27,23,16,color) line(p,23,16,31,16,color)
 elseif id=="general" or id=="XP" or id=="Level" then
  for i=1,3 do local f=make("Frame",p) f.BackgroundColor3=color f.Size=UDim2.fromOffset(6,i*7) f.Position=UDim2.fromOffset(3+(i-1)*10,29-i*7) V.Round(f,1) end
 elseif id=="arena" or id=="duels" then
  line(p,4,4,26,26,color,3) line(p,28,4,6,26,color,3) line(p,2,20,12,30,color) line(p,20,30,30,20,color)
 elseif id=="get_out" or id=="Escapes" then
  ring(p,18,1,7,7,color) line(p,20,11,13,20,color,3) line(p,13,20,5,25,color,3) line(p,14,19,23,24,color,3) line(p,23,24,20,31,color,3) line(p,18,11,9,10,color) line(p,9,10,5,17,color) line(p,18,12,24,17,color) line(p,24,17,30,16,color)
 elseif id=="Back" then
  line(p,26,16,5,16,color) line(p,5,16,13,8,color) line(p,5,16,13,24,color)
 else
  ring(p,4,4,24,24,color) if id~="TrainingKills" then line(p,16,0,16,9,color) line(p,16,23,16,32,color) line(p,0,16,9,16,color) line(p,23,16,32,16,color) else ring(p,10,10,12,12,color) end
 end
 return p
end
function V.Avatar(parent,data,x,y,size,color)
 local a=make("ImageLabel",parent,"Avatar") a.BackgroundColor3=Color3.fromRGB(18,43,48) a.Position=UDim2.fromOffset(x,y) a.Size=UDim2.fromOffset(size,size) a.Image="rbxthumb://type=AvatarHeadShot&id="..data.userId.."&w=150&h=150" V.Round(a,12) V.Edge(a,color or C.Accent,2).Transparency=0 return a
end
function V.Bar(parent,name,x,y,width,height,ratio,color)
 local track=make("Frame",parent,name) track.Position=UDim2.fromOffset(x,y) track.Size=UDim2.fromOffset(width,height) track.BackgroundColor3=Color3.fromRGB(20,38,44) V.Round(track,6)
 local fill=make("Frame",track,"Fill") fill.BackgroundColor3=color or C.Accent fill.Size=UDim2.fromScale(math.clamp(ratio,0,1),1) V.Round(fill,6) return track
end
function V.Format(key,value,S)
 if key=="Ratio" then return string.format("%.2f",value):gsub("%.",",") end
 if key=="PlaySeconds" then return V.Format("Count",math.floor(value/60),S).." min" end
 local s=tostring(math.floor(value)) local sign=s:sub(1,1)=="-" and "-" or "" s=s:gsub("^-","")
 return sign..s:reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","")
end
function V.Identity(parent,data,width,S,compact,peer)
 local height=compact and 132 or 154
 local f=make("Frame",parent,"Identity") f.BackgroundTransparency=1 f.Size=UDim2.fromOffset(width,height)
 local size=compact and (width<380 and 76 or 94) or 130 local x=size+24 local color=peer and C.Peer or C.Accent
 V.Avatar(f,data,4,8,size,color)
 local name=V.Text(f,"DisplayName",data.name,x,8,width-x-4,36,compact and (width<380 and 19 or 25) or 32) name.Font=Enum.Font.GothamBold name.TextWrapped=false name.TextTruncate=Enum.TextTruncate.AtEnd
 local xp=data.XP or 0 local level=S.Level(xp) local prev=math.floor(250*((level-1)^1.45)) local nextXP=math.floor(250*(level^1.45))
 V.Text(f,"Level","Nível "..level..(not compact and ("  ·  "..V.Format("Wins",data.Wins or 0,S).." vitórias") or ""),x,45,width-x-4,27,20)
 if compact then V.Bar(f,"XP",x,89,width-x-10,12,(xp-prev)/math.max(1,nextXP-prev),color)
 else
  if width>=650 then
   name.Size=UDim2.fromOffset(math.min(300,width-x-190),36)
   local coins=V.Box(f,"Coins",38) coins.Position=UDim2.fromOffset(width-170,14) coins.Size=UDim2.fromOffset(162,38)
   V.Icon(coins,"Coins",10,7,24,Color3.fromRGB(250,208,72)) V.Text(coins,"Amount",V.Format("Coins",data.Coins or 0,S),42,0,110,38,20).Font=Enum.Font.GothamBold
  else V.Text(f,"Coins",V.Format("Coins",data.Coins or 0,S).." moedas",x,74,width-x-4,22,14,C.Muted) end
  V.Text(f,"XPValue",V.Format("XP",xp,S).." XP",x,103,width-x-4,23,14)
  if width>=650 then local t=V.Text(f,"NextLevel",V.Format("XP",math.max(0,nextXP-xp),S).." XP para o próximo nível",x+160,103,width-x-164,23,13,C.Muted) t.TextXAlignment=Enum.TextXAlignment.Right end
  V.Bar(f,"XP",x,132,width-x-4,12,(xp-prev)/math.max(1,nextXP-prev),color)
 end
 return f
end
function V.Metrics(parent,data,mode,width,S)
 local fields=mode=="general" and {"Kills","Deaths","Ratio","Captures","Coins","PlaySeconds","TrainingKills","BotKills"} or S.Display[mode] local cols=width>=700 and 4 or width>=580 and 3 or 2
 local holder=make("Frame",parent,"Metrics") holder.BackgroundTransparency=1 holder.Size=UDim2.new(1,-4,0,math.ceil(#fields/cols)*94-10)
 local grid=make("UIGridLayout",holder) grid.CellPadding=UDim2.fromOffset(12,10) grid.CellSize=UDim2.new(1/cols,-12*(cols-1)/cols,0,84) grid.SortOrder=Enum.SortOrder.LayoutOrder
 for i,key in fields do
  local card=V.Box(holder,key,84) card.LayoutOrder=i
  local iconBox=make("Frame",card,"IconTile") iconBox.BackgroundColor3=Color3.fromRGB(14,55,60) iconBox.Position=UDim2.fromOffset(12,14) iconBox.Size=UDim2.fromOffset(48,56) V.Round(iconBox,9)
  V.Icon(iconBox,key,8,12,32,(key=="Deaths" or key=="Ratio") and C.Peer or C.Accent)
  local label=V.Text(card,"Label",S.Labels[key],72,9,200,31,14,C.Text) label.Size=UDim2.new(1,-80,0,31)
  local value=V.Text(card,"Value",V.Format(key,S.Value(data,mode,key),S),72,40,200,32,27) value.Size=UDim2.new(1,-80,0,32) value.Font=Enum.Font.GothamBold
 end
 return holder
end
local modeLines={arena={"Ratio","Kills"},get_out={"Wins","Escapes"},duels={"Wins","Losses"},ctf={"Captures","Ratio"}}
function V.ModeCards(parent,data,selected,width,S,activate)
 local holder=make("Frame",parent,"ModeCards") holder.BackgroundTransparency=1
 local cols=width>=800 and 4 or 2 holder.Size=UDim2.new(1,-4,0,math.ceil(4/cols)*132-12)
 local grid=make("UIGridLayout",holder) grid.CellSize=UDim2.new(1/cols,-12*(cols-1)/cols,0,120) grid.CellPadding=UDim2.fromOffset(12,12) grid.SortOrder=Enum.SortOrder.LayoutOrder
 local tints={arena=Color3.fromRGB(16,53,68),get_out=Color3.fromRGB(45,21,29),duels=Color3.fromRGB(30,33,42),ctf=Color3.fromRGB(27,45,37)}
 for i,m in {"arena","get_out","duels","ctf"} do
  local b=V.Button(holder,m,"",function() activate(m) end) b.LayoutOrder=i b.BackgroundColor3=tints[m] V.Select(b,selected==m)
  local gradient=make("UIGradient",b) gradient.Color=ColorSequence.new(tints[m],C.Surface) gradient.Rotation=25
  if m=="arena" then
   local image=make("ImageLabel",b,"MapPreview") image.BackgroundTransparency=1 image.Size=UDim2.fromScale(1,1) image.Image=require(game.ReplicatedStorage.Crossgrounds.ArenaMapIcons).arena image.ScaleType=Enum.ScaleType.Crop image.ImageTransparency=.74 V.Round(image,12)
  end
  V.Icon(b,m,14,12,26,C.Text)
  local name=V.Text(b,"Title",S.Names[m],50,8,200,35,16) name.Size=UDim2.new(1,-58,0,35) name.Font=Enum.Font.GothamBold
  for j,key in modeLines[m] do
   local label=(key=="Kills" and "Elim." or key=="Ratio" and "E/M" or S.Labels[key]).."   "..V.Format(key,S.Value(data,m,key),S)
   V.Text(b,key,label,16,44+j*22,200,22,14).Size=UDim2.new(1,-24,0,22)
  end
 end
 return holder
end
function V.RankRow(parent,entry,metric,width,S,prestige,scope,mode)
 local row=V.Box(parent,"Rank"..entry.rank,40) row.LayoutOrder=entry.rank row.BackgroundTransparency=.22 Nav:Register(row,function() end)
 local small=width<620 local top=entry.rank<=3 local colors={Color3.fromRGB(255,214,82),Color3.fromRGB(216,229,244),Color3.fromRGB(232,155,87)}
 if top then V.Icon(row,"Crown",small and 6 or 14,10,20,colors[entry.rank]) end
 local badge=V.Text(row,"Position",tostring(entry.rank),top and (small and 30 or 44) or 14,0,small and 32 or 52,40,small and 15 or 19,colors[entry.rank] or C.Text) badge.Font=Enum.Font.GothamBold
 V.Avatar(row,entry,small and 64 or 104,4,32,colors[entry.rank] or C.Edge)
 local name=V.Text(row,"Player",entry.name,small and 108 or 152,0,width-(small and 218 or 310),40,small and 13 or 16) name.TextWrapped=false name.TextTruncate=Enum.TextTruncate.AtEnd
 if top and scope=="global" and S.Primary[mode]==metric then prestige.Apply(name,entry.rank) end
 local val=V.Text(row,"Value",V.Format(metric,entry.value,S),width-(small and 106 or 164),0,small and 94 or 148,40,small and 13 or 17) val.TextXAlignment=Enum.TextXAlignment.Right
 if top then V.Edge(row,colors[entry.rank]).Transparency=.45 end
 return row
end
function V.CompareRow(parent,key,a,b,width,S)
 local row=V.Box(parent,key,50) Nav:Register(row,function() end) local small=width<620
 local tile=make("Frame",row,"IconTile") tile.BackgroundColor3=Color3.fromRGB(12,48,53) tile.Position=UDim2.fromOffset(8,6) tile.Size=UDim2.fromOffset(38,38) V.Round(tile,7) V.Icon(tile,key,6,6,26)
 local label=V.Text(row,"Label",S.Labels[key],56,0,width*.20,50,14)
 local leftX=width*.30 local barsX=width*.40 local barsW=width*.35 local rightX=width*.76
 if small then label.Size=UDim2.fromOffset(width*.31,24) label.Position=UDim2.fromOffset(54,1) leftX=54 barsX=width*.43 barsW=width*.30 rightX=width*.76 end
 local left=V.Text(row,"You",V.Format(key,a,S),leftX,small and 23 or 0,width*.10,small and 23 or 50,small and 13 or 17) left.Font=Enum.Font.GothamBold
 V.Bar(row,"YourBar",barsX,14,barsW,9,a/math.max(1,a,b),C.Accent)
 V.Bar(row,"FriendBar",barsX,28,barsW,9,b/math.max(1,a,b),C.Peer)
 local right=V.Text(row,"Friend",V.Format(key,b,S),rightX,0,width*.10,50,small and 12 or 17) right.TextXAlignment=Enum.TextXAlignment.Center right.Font=Enum.Font.GothamBold
 local delta=a-b local good=(key=="Deaths" or key=="Losses") and delta<0 or key~="Deaths" and key~="Losses" and delta>0
 local color=(key=="Coins" or key=="PlaySeconds" or delta==0) and C.Muted or good and Color3.fromRGB(46,232,159) or Color3.fromRGB(255,100,109)
 local d=V.Text(row,"Difference",(delta>0 and "+" or "")..V.Format(key,delta,S),width*.87,0,width*.12-8,50,small and 11 or 16,color) d.TextXAlignment=Enum.TextXAlignment.Right d.Font=Enum.Font.GothamBold
 if small then
  row.Size=UDim2.new(1,0,0,76) tile.Position=UDim2.fromOffset(8,16)
  label.Position=UDim2.fromOffset(56,2) label.Size=UDim2.fromOffset(width-70,23)
  left.Position=UDim2.fromOffset(56,26) left.Size=UDim2.fromOffset((width-70)*.33,22)
  right.Position=UDim2.fromOffset(56+(width-70)*.33,26) right.Size=UDim2.fromOffset((width-70)*.33,22)
  d.Position=UDim2.fromOffset(56+(width-70)*.66,26) d.Size=UDim2.fromOffset((width-70)*.34,22)
  row.YourBar.Position=UDim2.fromOffset(56,54) row.YourBar.Size=UDim2.fromOffset(width-72,6)
  row.FriendBar.Position=UDim2.fromOffset(56,65) row.FriendBar.Size=UDim2.fromOffset(width-72,6)
 end
 return row
end
function V.new(gui)
 gui.IgnoreGuiInset=false gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 local backdrop=make("Frame",gui,"Backdrop") backdrop.BackgroundTransparency=1 backdrop.Size=UDim2.fromScale(1,1)
 local panel=make("Frame",backdrop,"Panel") panel:SetAttribute("CascadeDepth",2) panel:SetAttribute("ProgressionSurface",true) panel.BackgroundTransparency=1 panel.AnchorPoint=Vector2.new(.5,.5) panel.Position=UDim2.fromScale(.5,.5)
 local scale=make("UIScale",panel,"Fit")
 local title=V.Text(panel,"Title","PROGRESSO",8,0,240,32,24)
 local side=V.Box(panel,"Navigation",600) side.BackgroundColor3=C.Surface side.BackgroundTransparency=.05
 local content=V.Box(panel,"Content",600) content.BackgroundColor3=C.Surface content.BackgroundTransparency=.04
 local heading=V.Text(content,"Heading","ESTATÍSTICAS PESSOAIS",20,0,500,48,17)
 local separator=make("Frame",content,"Separator") separator.BackgroundColor3=C.Edge separator.BackgroundTransparency=.35 separator.Position=UDim2.fromOffset(18,49) separator.Size=UDim2.new(1,-36,0,1)
 local self={Backdrop=backdrop,Panel=panel,Content=content,Heading=heading,Panes={},Buttons={},Width=1100,Compact=false}
 local titles={Profile="ESTATÍSTICAS PESSOAIS",Leaders="PLACAR DE LÍDERES",Friends="COMPARATIVO COM AMIGOS"}
 for _,id in {"Profile","Leaders","Friends"} do
  local pane=make("Frame",content,id) pane.BackgroundTransparency=1 pane.Size=UDim2.fromScale(1,1) pane.Visible=id=="Profile"
  local filters=make("Frame",pane,"Filters") filters.BackgroundTransparency=1
  local list=make("ScrollingFrame",pane,"List") list.BackgroundTransparency=1 list.ScrollBarThickness=3 list.ScrollBarImageColor3=C.Accent list.CanvasSize=UDim2.new() list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.BorderSizePixel=0
  local layout=make("UIListLayout",list) layout.Padding=UDim.new(0,12) layout.SortOrder=Enum.SortOrder.LayoutOrder
  self.Panes[id]={Frame=pane,List=list,Filters=filters}
 end
 local entries={{"Profile","Estatísticas Pessoais"},{"Leaders","Placar de Líderes"},{"Friends","Comparativo com Amigos"},{"Close","Voltar ao menu"}}
 for i,entry in entries do
  local id=entry[1] local b=V.Button(side,id,"",function() if self.OnSelect then self.OnSelect(id) end end) b.LayoutOrder=i
  V.Icon(b,id=="Close" and "Back" or id,18,20,28,C.Text)
  local label=V.Text(b,"Label",entry[2],62,0,150,68,15) label.Size=UDim2.new(1,-70,1,0)
  local marker=make("Frame",b,"SelectedMarker") marker.BackgroundColor3=C.Accent marker.Size=UDim2.fromOffset(10,10) marker.Rotation=45 marker.AnchorPoint=Vector2.new(.5,.5) marker.Position=UDim2.fromScale(0,.5) marker.Visible=false
  self.Buttons[id]=b
 end
 function self:Select(id)
  self.Selected=id self.Heading.Text=titles[id] or "PROGRESSO"
  for key,p in self.Panes do p.Frame.Visible=key==id end
  for key,b in self.Buttons do V.Select(b,key==id) end
 end
 function self:Resize()
  local viewport=backdrop.AbsoluteSize if viewport.X<100 then viewport=workspace.CurrentCamera.ViewportSize end
  local preference=math.clamp(player:GetAttribute("SettingMenuScale") or 1,.65,1.5)
  local desktop=viewport.X>=1000 and viewport.X/viewport.Y>1.3
  scale.Scale=desktop and math.min(preference,(viewport.X-32)/1400,(viewport.Y-50)/710) or math.min(preference,math.max(.65,(viewport.X-24)/360))
  local w=math.min(1400,(viewport.X-32)/scale.Scale) local h=math.min(710,(viewport.Y-76)/scale.Scale)
  panel.Size=UDim2.fromOffset(w,h) self.Compact=w<780
  local compact=self.Compact local sidebar=compact and 0 or w<1150 and 218 or 240 local gap=compact and 0 or 12
  side.Position=UDim2.fromOffset(0,42) side.Size=compact and UDim2.fromOffset(w,60) or UDim2.fromOffset(sidebar,h-42)
  content.Position=UDim2.fromOffset(sidebar+gap,compact and 114 or 42) content.Size=UDim2.fromOffset(w-sidebar-gap,h-(compact and 114 or 42))
  for i,entry in entries do
   local b=self.Buttons[entry[1]] local icon=b:FindFirstChild("Icon") local label=b.Label
   if compact then
    b.Position=UDim2.fromOffset((i-1)*w/4+4,5) b.Size=UDim2.fromOffset(w/4-8,50) icon.Visible=false label.Position=UDim2.fromOffset(4,0) label.Size=UDim2.new(1,-8,1,0) label.TextSize=w<520 and 11 or 13 label.TextXAlignment=Enum.TextXAlignment.Center
   else
    b.Position=UDim2.fromOffset(12,i==4 and 274 or 18+(i-1)*76) b.Size=UDim2.fromOffset(sidebar-24,i==4 and 56 or 68) icon.Visible=true label.Position=UDim2.fromOffset(62,0) label.Size=UDim2.new(1,-70,1,0) label.TextSize=15 label.TextXAlignment=Enum.TextXAlignment.Left
   end
  end
  self.Width=w-sidebar-gap-40 self.HeaderHeight=self.Width<970 and 106 or 58
  heading.Size=UDim2.fromOffset(self.Width,46)
  separator.Position=UDim2.fromOffset(18,self.HeaderHeight-8)
  for id,p in self.Panes do
   local filtersWidth=id=="Leaders" and math.min(660,self.Width) or id=="Friends" and math.min(300,self.Width) or math.min(260,self.Width)
   p.Filters.Position=UDim2.fromOffset(20+self.Width-filtersWidth,self.HeaderHeight==58 and 7 or 48) p.Filters.Size=UDim2.fromOffset(filtersWidth,36)
   p.List.Position=UDim2.fromOffset(20,self.HeaderHeight+4) p.List.Size=UDim2.new(1,-40,1,-self.HeaderHeight-18-(id=="Leaders" and 70 or 0))
  end
  if self.OnResize then self.OnResize() end
 end
 self:Select("Profile")
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() self:Resize() end)
 backdrop:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:Resize() end)
 player:GetAttributeChangedSignal("SettingMenuScale"):Connect(function() self:Resize() end)
 self:Resize() return self
end
return V
