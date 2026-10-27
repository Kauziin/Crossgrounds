-- Objective notices: one transient event card, plus compact live carrier rows.
local Notice={}
Notice.__index=Notice
local Tween=game:GetService("TweenService")
local TextService=game:GetService("TextService")
local Players=game:GetService("Players")
local white=Color3.fromRGB(240,247,251)
local muted=Color3.fromRGB(163,185,199)
local danger=Color3.fromRGB(255,112,101)
local success=Color3.fromRGB(75,225,185)
local gold=Color3.fromRGB(255,208,109)
local function object(class,name,parent)
 local o=Instance.new(class) o.Name=name
 if o:IsA("GuiObject")then o:SetAttribute("CascadeDecoration",true)o.BorderSizePixel=0 end
 o.Parent=parent return o
end
local function text(parent,name,size,bold)
 local o=object("TextLabel",name,parent)o.BackgroundTransparency=1 o.Font=bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
 o.TextSize=size o.TextColor3=white o.TextWrapped=true o.TextXAlignment=Enum.TextXAlignment.Left o.TextYAlignment=Enum.TextYAlignment.Center o.TextStrokeTransparency=1 o.Text="" return o
end
local function corner(parent,r)local c=Instance.new("UICorner")c.CornerRadius=UDim.new(0,r)c.Parent=parent end
local function stroke(parent,color,alpha)
 local s=Instance.new("UIStroke")s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Color=color s.Transparency=alpha s.Thickness=1 s.Parent=parent return s
end
local function flag(parent)
 local tile=object("Frame","FlagIcon",parent)tile.Size=UDim2.fromOffset(52,52)tile.Position=UDim2.fromOffset(17,21)corner(tile,12)
 local pole=object("Frame","Pole",tile)pole.BackgroundColor3=white pole.Size=UDim2.fromOffset(2,29)pole.Position=UDim2.fromOffset(16,12)
 local cloth=object("Frame","Banner",tile)cloth.Size=UDim2.fromOffset(21,15)cloth.Position=UDim2.fromOffset(18,12)corner(cloth,2)
 return tile,cloth
end
local function flagColor(team)return team=="Blue" and Color3.fromRGB(93,179,255) or Color3.fromRGB(255,115,109)end
local function flagName(team)return team=="Blue"and"azul"or"vermelha"end
function Notice.new(player)
 local self=setmetatable({player=player,enabled=false,queue={},serial=0,tweens={},carriers={},rows={}},Notice)
 local gui=Instance.new("ScreenGui")gui.Name="CTFFlagAlerts"gui.ResetOnSpawn=false gui.IgnoreGuiInset=false gui.DisplayOrder=84 gui.Enabled=false gui.Parent=player:WaitForChild("PlayerGui")self.Gui=gui
 local root=object("Frame","ObjectiveNotices",gui)root.AnchorPoint=Vector2.new(.5,0)root.BackgroundTransparency=1 self.Root=root
 self.Scale=Instance.new("UIScale")self.Scale.Parent=root
 local event=object("CanvasGroup","EventCard",root)event.BackgroundColor3=Color3.fromRGB(10,23,32)event.Size=UDim2.new(1,0,0,112)event.Visible=false corner(event,12)self.Card=event
 local gradient=Instance.new("UIGradient")gradient.Color=ColorSequence.new(Color3.fromRGB(28,46,56),Color3.fromRGB(10,23,32))gradient.Rotation=18 gradient.Parent=event
 self.Edge=stroke(event,success,.46)
 local accent=object("Frame","Accent",event)accent.Size=UDim2.new(0,4,1,-22)accent.Position=UDim2.fromOffset(0,11)corner(accent,2)self.Accent=accent
 self.Icon,self.Flag=flag(event)
 self.Heading=text(event,"EventTitle",11,true)
 self.Message=text(event,"Message",19,true)
 self.Action=text(event,"Instruction",12,false)self.Action.TextColor3=muted
 local track=object("Frame","TimeTrack",event)track.BackgroundColor3=Color3.fromRGB(39,59,71)track.Size=UDim2.new(1,-24,0,2)track.Position=UDim2.new(0,12,1,-7)
 self.Time=object("Frame","Remaining",track)self.Time.Size=UDim2.fromScale(1,1)
 local host=object("Frame","LiveCarriers",root)host.BackgroundTransparency=1 self.Host=host
 for i=1,2 do
  local row=object("Frame","Carrier"..i,host)row.Size=UDim2.new(1,0,0,48)row.BackgroundColor3=Color3.fromRGB(11,24,33)row.Visible=false corner(row,9)
  local edge=stroke(row,success,.7)
  local bar=object("Frame","TeamAccent",row)bar.Size=UDim2.new(0,3,1,-16)bar.Position=UDim2.fromOffset(0,8)corner(bar,2)
  local label=text(row,"Directive",10,true)local name=text(row,"CarrierName",14,false)
  self.rows[i]={frame=row,edge=edge,bar=bar,title=label,name=name}
 end
 local function resize()self:Layout()end
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
 for _,key in {"SettingHUDScale","SettingFontScale","SettingHighContrast"}do player:GetAttributeChangedSignal(key):Connect(resize)end
 self:Layout()return self
end
function Notice:CancelTweens()
 for _,t in self.tweens do t:Cancel()end table.clear(self.tweens)
end
function Notice:Layout()
 local v=workspace.CurrentCamera.ViewportSize
 local scale=math.min(self.player:GetAttribute("SettingHUDScale")or 1,math.max(.65,(v.X-24)/300))
 local width=math.min(540,(v.X-24)/scale)self.Scale.Scale=scale
 self.Root.Position=UDim2.new(.5,0,0,v.Y<500 and 105 or 122)self.Root.Size=UDim2.fromOffset(width,280)
 local f=self.player:GetAttribute("SettingFontScale")or 1
 self.Heading.TextSize=11*f self.Message.TextSize=19*f self.Action.TextSize=12*f
 local messageH=math.max(25,TextService:GetTextSize(self.Message.Text,self.Message.TextSize,self.Message.Font,Vector2.new(width-108,1000)).Y)
 local actionH=math.max(18,TextService:GetTextSize(self.Action.Text,self.Action.TextSize,self.Action.Font,Vector2.new(width-108,1000)).Y)
 local height=math.max(110,18+16*f+messageH+6+actionH+17)
 self.Card.Size=UDim2.new(1,0,0,height)
 self.Heading.Position=UDim2.fromOffset(86,13)self.Heading.Size=UDim2.new(1,-104,0,16*f)
 self.Message.Position=UDim2.fromOffset(86,29*f)self.Message.Size=UDim2.new(1,-104,0,messageH+4)
 self.Action.Position=UDim2.fromOffset(86,29*f+messageH+7)self.Action.Size=UDim2.new(1,-104,0,actionH)
 self.Icon.Position=UDim2.fromOffset(17,math.max(17,(height-52)/2))
 self.Card.BackgroundTransparency=self.player:GetAttribute("SettingHighContrast")and 0 or .04
 self.Host.Position=UDim2.fromOffset(0,self.Card.Visible and height+8 or 0)self.Host.Size=UDim2.new(1,0,0,140)
 local y=0
 for i,row in self.rows do
  local item=self.carriers[i]row.frame.Visible=item~=nil
  if item then
   row.title.TextSize=10*f row.name.TextSize=14*f
   local nameHeight=math.max(20,TextService:GetTextSize(item.name,row.name.TextSize,row.name.Font,Vector2.new(width-38,1000)).Y)
   local h=math.max(48,nameHeight+25*f)
   row.frame.Position=UDim2.fromOffset(0,y)row.frame.Size=UDim2.new(1,0,0,h)
   row.title.Position=UDim2.fromOffset(15,6)row.title.Size=UDim2.new(1,-30,0,13*f)
   row.name.Position=UDim2.fromOffset(15,19*f)row.name.Size=UDim2.new(1,-30,0,nameHeight+2)
   row.frame.BackgroundTransparency=self.player:GetAttribute("SettingHighContrast")and 0 or .1
   y+=h+6
  end
 end
end
function Notice:SetEnabled(on)
 if self.enabled==on then return end self.enabled=on self.Gui.Enabled=on
 if not on then self.serial+=1 self:CancelTweens()self.current=nil table.clear(self.queue)self.Card.Visible=false self.carriers={} end
 self:Layout()
end
function Notice:SetCarriers(items)
 -- The controller calls this as flags move; layout only when the displayed data changes.
 local signature=""for _,item in items do signature..=item.title..item.name end
 if self.carrierSignature==signature then return end self.carrierSignature=signature self.carriers=items
 for i,item in items do local row=self.rows[i]if row then row.title.Text=item.title row.title.TextColor3=item.color row.name.Text=item.name row.bar.BackgroundColor3=item.color row.edge.Color=item.color end end
 self:Layout()
end
function Notice:Next()
 if self.current or not self.enabled or #self.queue==0 then return end
 self:CancelTweens()local item=table.remove(self.queue,1)self.current=item self.serial+=1 local serial=self.serial
 self.Heading.Text=item.title self.Message.Text=item.message self.Action.Text=item.action
 self.Heading.TextColor3=item.color self.Accent.BackgroundColor3=item.color self.Edge.Color=item.color self.Time.BackgroundColor3=item.color
 self.Icon.BackgroundColor3=item.color:Lerp(Color3.fromRGB(12,24,32),.83)self.Flag.BackgroundColor3=flagColor(item.team)
 self.Card.Visible=true self.Card.GroupTransparency=0 self.Time.Size=UDim2.fromScale(1,1)self:Layout()
 local reduced=self.player:GetAttribute("SettingReducedMenuMotion")
 if not reduced then
  self.Card.GroupTransparency=1 self.Card.Position=UDim2.fromOffset(0,-8)
  local enter=Tween:Create(self.Card,TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{GroupTransparency=0,Position=UDim2.fromOffset(0,0)})table.insert(self.tweens,enter)enter:Play()
  local time=Tween:Create(self.Time,TweenInfo.new(4,Enum.EasingStyle.Linear),{Size=UDim2.fromScale(0,1)})table.insert(self.tweens,time)time:Play()
 else self.Card.Position=UDim2.new()end
 task.delay(4,function()
  if self.serial~=serial then return end
  local duration=reduced and 0 or .16
  if duration>0 then local fade=Tween:Create(self.Card,TweenInfo.new(duration),{GroupTransparency=1})table.insert(self.tweens,fade)fade:Play()end
  task.delay(duration,function()if self.serial~=serial then return end self.Card.Visible=false self.current=nil self:Layout()self:Next()end)
 end)
end
function Notice:Notify(data)
 if not self.enabled or typeof(data)~="table"or(data.team~="Blue"and data.team~="Red")then return end
 local own=self.player.Team and self.player.Team.Name==data.team
 local name=data.self and "Você"or tostring(data.carrier or "Jogador")
 local item={team=data.team,color=own and danger or success}
 if data.kind=="pickup"then
  item.urgent=own item.title=own and "ALERTA · SUA BANDEIRA FOI ROUBADA"or"BANDEIRA INIMIGA EM MOVIMENTO"
  item.message=data.self and ("Você está com a bandeira "..flagName(data.team).."!")or(name..(own and " está com a sua bandeira!"or" está com a bandeira "..flagName(data.team).."!"))
  item.action=own and "Intercepte o portador antes que ele chegue à base."or data.self and "Leve a bandeira à sua base para pontuar."or"Proteja o portador no caminho de volta."
 elseif data.kind=="capture"then
  item.title=own and "A EQUIPE INIMIGA PONTUOU"or"BANDEIRA CAPTURADA · PONTO PARA SUA EQUIPE"
  item.message=name.." capturou "..(own and "a sua bandeira!"or"a bandeira "..flagName(data.team).."!")
  item.action=own and "Reagrupe e defenda sua base."or"Boa captura! Prepare a próxima ofensiva."
 elseif data.kind=="return"then
  item.color=own and success or muted item.title="BANDEIRA DEVOLVIDA"
  item.message=own and "Sua bandeira está segura na base."or"A bandeira "..flagName(data.team).." voltou à base."
  item.action=own and "Defesa restabelecida. Sua equipe pode capturar."or"Avance para roubar a bandeira novamente."
 elseif data.kind=="drop"then
  item.color=gold item.title="BANDEIRA NO CHÃO"item.message=name.." deixou "..(own and "a sua bandeira cair!"or"a bandeira "..flagName(data.team).." cair!")
  item.action=own and "Toque na bandeira para devolvê-la à base."or"Recupere a bandeira e continue o ataque."
 else return end
 if item.urgent then
  self.serial+=1 self:CancelTweens()self.current=nil table.clear(self.queue)
 end
 if #self.queue>=3 then table.remove(self.queue,1)end table.insert(self.queue,item)self:Next()
end
return Notice
