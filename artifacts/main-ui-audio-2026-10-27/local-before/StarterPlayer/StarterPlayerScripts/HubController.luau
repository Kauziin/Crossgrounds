local player=game.Players.LocalPlayer
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Bridge=require(script.Parent:WaitForChild("HubBridge"))
local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Catalog=require(game.ReplicatedStorage.Crossgrounds.GameCatalog)
local gui=Instance.new("ScreenGui") gui.Name="CrossgroundsHub" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=60 gui.Parent=player.PlayerGui
local browser=Cascade.new(gui,"BrowserBackdrop","CROSSGROUNDS")
browser:AddPane("Modes","MODALIDADES") browser:AddPane("ModeDetails","SOBRE O MODO")
local selected="ctf" local catalogOpen=true local quickEntry local lastMode=Scope:Get() local cards={}
local refresh
local function stay()
 local data=Bridge:Get() local q=data and data.queue
 quickEntry=nil
 if q and (q.state=="joining" or q.state=="ready") then Bridge:Send("cancel",nil,q.ticket) end
 catalogOpen=false player:SetAttribute("LobbyMenuDismissed",true)
 if refresh then refresh() end
end
browser.OnClose=stay
local resume=browser:Button("RootPane","StayLobby","Permanecer no lobby",stay)
local function playModes() browser:Push({"RootPane","Modes"}) end
local function openProgress() player:SetAttribute("ProgressionMenuOpen",true) end
local function openSettings() Nav:OpenMenu("Settings") end
local function openMusic() Nav:OpenMenu("Playlist") end
browser:Button("RootPane","Modes","Jogar  ›",playModes)
browser:Button("RootPane","Progress","Progresso",openProgress)
browser:Button("RootPane","Settings","Ajustes",openSettings)
browser:Button("RootPane","Music","Música / Playlist",openMusic)

-- A presentation owned by this controller, used only at the root of the hub.
-- The existing cascade, callbacks and all other menus retain their own styling.
local InputMode=require(script.Parent:WaitForChild("InputMode"))
local turquoise=Color3.fromRGB(22,220,235)
local function homeObject(class,name,parent)
 local object=Instance.new(class) object.Name=name
 if object:IsA("GuiObject") then object:SetAttribute("CascadeDecoration",true) object.BorderSizePixel=0 object.BackgroundTransparency=1 end
 object.Parent=parent return object
end
local function homeText(name,parent,value,size)
 local object=homeObject("TextLabel",name,parent) object.Text=value object.Font=Enum.Font.GothamMedium
 object.TextSize=size object.TextColor3=Color3.fromRGB(226,233,238) object.TextXAlignment=Enum.TextXAlignment.Left
 object.TextYAlignment=Enum.TextYAlignment.Center return object
end
local function homeCorner(object,radius)
 local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,radius) corner.Parent=object
end
local function homeStroke(object,thickness,transparency)
 local stroke=Instance.new("UIStroke") stroke.Color=turquoise stroke.Thickness=thickness
 stroke.Transparency=transparency stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Parent=object return stroke
end
local scrimGui=Instance.new("ScreenGui") scrimGui.Name="CrossgroundsHomeBackdrop" scrimGui.ResetOnSpawn=false
scrimGui.IgnoreGuiInset=true scrimGui.ScreenInsets=Enum.ScreenInsets.None scrimGui.DisplayOrder=gui.DisplayOrder-1 scrimGui.Enabled=false scrimGui.Parent=player.PlayerGui
local scrim=homeObject("Frame","HomeScrim",scrimGui) scrim.Size=UDim2.fromScale(1,1) scrim.ZIndex=0
scrim.BackgroundColor3=Color3.fromRGB(1,5,9) scrim.BackgroundTransparency=.06
local fade=Instance.new("UIGradient") fade.Rotation=28
fade.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.25,.12),NumberSequenceKeypoint.new(.58,.58),NumberSequenceKeypoint.new(1,1)}) fade.Parent=scrim
local home=homeObject("Frame","Home",browser.Panel) home.Size=UDim2.fromScale(1,1)
local content=homeObject("Frame","Content",home)
local homeScale=Instance.new("UIScale") homeScale.Parent=content
local title=homeText("Wordmark",content,"CROSSGROUNDS",72) title.Font=Enum.Font.GothamBlack title.TextColor3=turquoise
local underline=homeObject("Frame","TitleRule",content) underline.BackgroundColor3=turquoise underline.BackgroundTransparency=0
local ruleTail=homeObject("Frame","RuleTail",content) ruleTail.BackgroundColor3=Color3.fromRGB(104,138,149) ruleTail.BackgroundTransparency=.7
local tailFade=Instance.new("UIGradient") tailFade.Transparency=NumberSequence.new(0,1) tailFade.Parent=ruleTail
local homeList=homeObject("ScrollingFrame","Actions",content) homeList.ScrollBarThickness=3 homeList.ScrollBarImageColor3=turquoise
homeList.CanvasSize=UDim2.new() homeList.AutomaticCanvasSize=Enum.AutomaticSize.Y homeList.ScrollingDirection=Enum.ScrollingDirection.Y
local homeLayout=Instance.new("UIListLayout") homeLayout.SortOrder=Enum.SortOrder.LayoutOrder homeLayout.Padding=UDim.new(0,2) homeLayout.Parent=homeList
local homePadding=Instance.new("UIPadding") homePadding.PaddingLeft=UDim.new(0,18) homePadding.PaddingTop=UDim.new(0,7) homePadding.PaddingBottom=UDim.new(0,7) homePadding.PaddingRight=UDim.new(0,10) homePadding.Parent=homeList
local homeButtons={} local homeRows={} local selectedHome local homeActive=false local focusPaint={}
local function iconLine(parent,x1,y1,x2,y2)
 local line=homeObject("Frame","Line",parent) line.BackgroundColor3=Color3.fromRGB(210,225,232) line.BackgroundTransparency=0
 line.AnchorPoint=Vector2.new(.5,.5) line.Position=UDim2.fromOffset((x1+x2)/2,(y1+y2)/2)
 line.Size=UDim2.fromOffset(Vector2.new(x2-x1,y2-y1).Magnitude,1.8) line.Rotation=math.deg(math.atan2(y2-y1,x2-x1)) return line
end
local function iconCircle(parent,x,y,w,h,solid)
 local shape=homeObject("Frame","Circle",parent) shape.Position=UDim2.fromOffset(x,y) shape.Size=UDim2.fromOffset(w,h)
 shape.BackgroundColor3=Color3.fromRGB(210,225,232) shape.BackgroundTransparency=solid and 0 or 1 homeCorner(shape,20)
 if not solid then local stroke=homeStroke(shape,1.6,0) stroke.Color=shape.BackgroundColor3 end
end
local function drawIcon(parent,kind)
 if kind=="Play" then
  for i=0,12 do iconLine(parent,6+i,3+i*.65,6+i,21-i*.65) end
 elseif kind=="StayLobby" then
  iconCircle(parent,8,2,8,8,false) iconCircle(parent,4,14,16,9,false)
  iconLine(parent,20,5,23,10) iconLine(parent,23,14,24,21)
 elseif kind=="Progress" then
  for i=0,2 do local bar=homeObject("Frame","Bar",parent) bar.BackgroundColor3=Color3.fromRGB(210,225,232) bar.BackgroundTransparency=0 bar.Position=UDim2.fromOffset(4+i*6,17-i*5) bar.Size=UDim2.fromOffset(3,7+i*5) end
  iconLine(parent,4,10,17,2) iconLine(parent,14,2,18,2) iconLine(parent,18,2,18,6)
 elseif kind=="Settings" then
  iconCircle(parent,5,5,14,14,false) iconCircle(parent,10,10,4,4,false)
  for i=0,7 do local a=i*math.pi/4 iconLine(parent,12+math.cos(a)*8,12+math.sin(a)*8,12+math.cos(a)*11,12+math.sin(a)*11) end
 else
  iconLine(parent,9,18,9,4) iconLine(parent,9,4,22,1) iconLine(parent,22,1,22,16) iconLine(parent,9,8,22,5)
  iconCircle(parent,3,17,7,5,true) iconCircle(parent,16,15,7,5,true)
 end
end
local function restoreFocusPaint()
 for object,properties in focusPaint do if object.Parent then for key,value in properties do object[key]=value end end end focusPaint={}
end
local function paintHomeFocus()
 if not homeActive or not browser.Backdrop.Visible then restoreFocusPaint() return end
 local cursorGui=player.PlayerGui:FindFirstChild("AccessibleMenuCursor") if not cursorGui then return end
 for _,name in {"FocusOutline","FocusGlow","Cursor"} do
  local object=cursorGui:FindFirstChild(name) local stroke=object and object:FindFirstChildOfClass("UIStroke")
  if stroke then
   if not focusPaint[stroke] then focusPaint[stroke]={Color=stroke.Color,Thickness=stroke.Thickness,Transparency=stroke.Transparency} end
   stroke.Color=turquoise
   if name=="FocusOutline" then stroke.Thickness=2 stroke.Transparency=.04
   elseif name=="FocusGlow" then stroke.Thickness=8 stroke.Transparency=.88 end
  end
 end
end
local function selectHome(button)
 if button then selectedHome=button end
 for object,row in homeRows do
  local active=object==selectedHome
  object.BackgroundTransparency=active and (player:GetAttribute("SettingHighContrast") and .08 or .48) or 1
  local gamepad=InputMode:Get()==Enum.PreferredInput.Gamepad
  row.Edge.Transparency=active and not gamepad and .12 or 1 row.Glow.Transparency=active and not gamepad and .88 or 1
  row.Label.TextColor3=active and Color3.new(1,1,1) or Color3.fromRGB(210,221,229)
  row.Diamond.Visible=active and InputMode:Get()~=Enum.PreferredInput.Gamepad
  row.Divider.Visible=not active
 end
 paintHomeFocus()
end
for index,entry in {{"Play","Jogar",playModes},{"StayLobby","Permanecer no lobby",stay},{"Progress","Progresso",openProgress},{"Settings","Ajustes",openSettings},{"Music","Música / Playlist",openMusic}} do
 local button=homeObject("TextButton",entry[1],homeList) button.Text="" button.AutoButtonColor=false button.LayoutOrder=index
 button.BackgroundColor3=Color3.fromRGB(2,16,23) button.Size=UDim2.new(1,-2,0,60) button:SetAttribute("AccessibleLabel",entry[2]) homeCorner(button,11)
 local edge=homeStroke(button,1.6,1) local glow=homeStroke(button,7,1)
 local icon=homeObject("Frame","Icon",button) icon.Position=UDim2.new(0,22,.5,-12) icon.Size=UDim2.fromOffset(26,26) drawIcon(icon,entry[1])
 local text=homeText("Label",button,entry[2],19) text.Position=UDim2.new(0,72,0,0) text.Size=UDim2.new(1,-110,1,0)
 text.TextWrapped=true
 local chevron=homeText("Chevron",button,"›",26) chevron.Position=UDim2.new(1,-36,0,0) chevron.Size=UDim2.new(0,20,1,0) chevron.TextXAlignment=Enum.TextXAlignment.Center
 local divider=homeObject("Frame","Divider",button) divider.Position=UDim2.new(0,0,1,-1) divider.Size=UDim2.new(1,0,0,1) divider.BackgroundColor3=Color3.fromRGB(151,179,192) divider.BackgroundTransparency=.83
 local diamond=homeObject("Frame","Diamond",button) diamond.AnchorPoint=Vector2.new(.5,.5) diamond.Position=UDim2.new(0,-12,.5,0) diamond.Size=UDim2.fromOffset(9,9) diamond.Rotation=45 diamond.BackgroundColor3=Color3.fromRGB(220,252,255) diamond.BackgroundTransparency=0 homeStroke(diamond,1.5,.08)
 homeRows[button]={Edge=edge,Glow=glow,Label=text,Diamond=diamond,Divider=divider} homeButtons[index]=button
 Nav:Connect(button,entry[3])
end
selectedHome=homeButtons[1]
for index,button in homeButtons do button.NextSelectionUp=homeButtons[index-1] or button button.NextSelectionDown=homeButtons[index+1] or button end
local function layoutHome()
 local size=home.AbsoluteSize if size.X<100 or size.Y<100 then return end
 local scale=player:GetAttribute("SettingMenuScale") or 1 homeScale.Scale=scale
 local w,h=size.X/scale,size.Y/scale content.Size=UDim2.fromOffset(w,h)
 local compact=h<520 local left=math.clamp(w*.064,22,108) local top=compact and 12 or math.clamp(h*.12,24,112)
 local fontSize=math.clamp(math.min(w*.058,h*(compact and .12 or .108)),27,90)
 local fontScale=player:GetAttribute("SettingFontScale") or 1
 local textService=game:GetService("TextService")
 local wordmarkWidth=textService:GetTextSize(title.Text,fontSize*fontScale,Enum.Font.GothamBlack,Vector2.new(10000,1000)).X
 fontSize*=math.min(1,(w-left-20)/math.max(1,wordmarkWidth))
 local titleHeight=fontSize*fontScale*1.2
 title.TextSize=fontSize title.Position=UDim2.fromOffset(left,top) title.Size=UDim2.new(1,-left-20,0,titleHeight)
 local ruleY=top+titleHeight+(compact and 6 or 14)
 underline.Position=UDim2.fromOffset(left+4,ruleY) underline.Size=UDim2.fromOffset(compact and 48 or 76,3)
 ruleTail.Position=UDim2.fromOffset(left+(compact and 52 or 80),ruleY) ruleTail.Size=UDim2.fromOffset(math.min(350,w*.25),2)
 local listTop=ruleY+(compact and 12 or 40)
 local listWidth=math.min(w-left-18,math.clamp(w*(compact and .45 or .29),compact and 320 or 290,450))
 local labelSize=compact and 16 or math.clamp(h*.025,17,21)
 local textHeight=textService:GetTextSize("Permanecer no lobby",labelSize*fontScale,Enum.Font.GothamMedium,Vector2.new(math.max(60,listWidth-112),1000)).Y
 local rowHeight=math.max(math.clamp(h*.078,44,68),textHeight+12)
 -- Leave room for the existing console footer and admin notice on short screens.
 local bottomSpace=compact and (player:GetAttribute("CrossgroundsAdmin")==true and 104 or 40) or 16
 homeList.Position=UDim2.fromOffset(left-18,listTop) homeList.Size=UDim2.fromOffset(listWidth+28,math.max(44,h-listTop-bottomSpace))
 for _,button in homeButtons do
  button.Size=UDim2.new(1,-2,0,rowHeight)
  homeRows[button].Label.TextSize=labelSize
 end
end
local cascadeResize=browser.Resize
function browser:Resize(animate)
 cascadeResize(self,animate)
 homeActive=#self.Stack==1 and self.Stack[1]=="RootPane"
 home.Visible=homeActive scrimGui.Enabled=homeActive and self.Backdrop.Visible self.Heading.Visible=not homeActive
 if homeActive then
  self.Panel.Size=UDim2.fromScale(1,1) self.Panel.Position=UDim2.fromScale(.5,.5)
  self.Panel.PreferenceScale.Scale=1 self.Panes.RootPane.Frame.Visible=false
  layoutHome() selectHome(selectedHome)
 else restoreFocusPaint() end
end
local cascadePush=browser.Push
function browser:Push(ids)
 cascadePush(self,ids)
 if #ids==1 and ids[1]=="RootPane" then
  selectedHome=homeButtons[1] selectHome(selectedHome)
  task.defer(function() if self.Backdrop.Visible and home.Visible then Nav:Focus(selectedHome) end end)
 end
end
home:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutHome)
Nav.FocusChanged:Connect(function(object) if homeActive and object and homeRows[object] then selectHome(object) end end)
InputMode.Changed:Connect(function() selectHome(selectedHome) end)
browser.Backdrop:GetPropertyChangedSignal("Visible"):Connect(function()
 scrimGui.Enabled=homeActive and browser.Backdrop.Visible
 if not browser.Backdrop.Visible then restoreFocusPaint() elseif homeActive then selectHome(selectedHome) end
end)
player:GetAttributeChangedSignal("SettingHighContrast"):Connect(function() selectHome(selectedHome) end)
player:GetAttributeChangedSignal("SettingFontScale"):Connect(layoutHome)
player:GetAttributeChangedSignal("CrossgroundsAdmin"):Connect(layoutHome)
local function definition()
 local data=Bridge:Get() for _,v in data and data.catalog or {} do if v.id==selected then return v end end
end
local description=browser:Info("ModeDetails","Description","Carregando...",150)
local primary=browser:Button("ModeDetails","Primary","Jogar",function()
 local data=Bridge:Get() local item=definition() if not data or not item or Bridge.Pending then return end
 local q=data.queue
 if q.state=="ready" then Bridge:Send("enter",nil,q.ticket)
 elseif (q.state=="idle" or q.state=="failed") and item.canEnter then quickEntry=selected Bridge:Send("join",selected) end
end)
local cancel=browser:Button("ModeDetails","CancelEntry","Cancelar entrada",function()
 local data=Bridge:Get() if data and (data.queue.state=="ready" or data.queue.state=="joining") then quickEntry=nil Bridge:Send("cancel",nil,data.queue.ticket) end
end)
local status=browser:Info("ModeDetails","Status","",62)
browser:Button("ModeDetails","StayLobby","Permanecer no lobby",stay)
for _,v in Catalog:List() do
 local id=v.id
 local b=browser:Button("Modes",id,v.name,function() selected=id browser:Push({"RootPane","Modes","ModeDetails"}) if refresh then refresh() end end,60)
 b.Text=""
 local title=Theme.Text(b,"ModeName",v.name,24,16) title.Position=UDim2.fromOffset(12,8) title.Size=UDim2.new(1,-24,0,24) title.TextTruncate=Enum.TextTruncate.AtEnd title.TextWrapped=false
 local stateText=Theme.Text(b,"State","Carregando...",22,12) stateText.Position=UDim2.fromOffset(12,36) stateText.Size=UDim2.new(1,-24,0,22) stateText.TextWrapped=false stateText.TextTruncate=Enum.TextTruncate.AtEnd
 cards[id]={Button=b,Title=title,State=stateText}
end
local overlay=Instance.new("Frame") overlay.Name="StatusPanel" overlay.AnchorPoint=Vector2.new(.5,.5) overlay.Position=UDim2.fromScale(.5,.5) overlay.Size=UDim2.fromOffset(360,220) overlay.Visible=false overlay.Parent=gui Theme.Surface(overlay)
local message=Theme.Text(overlay,"Message","",120,16) message.Position=UDim2.fromOffset(16,16) message.Size=UDim2.new(1,-32,0,128)
local acknowledge=Instance.new("TextButton") acknowledge.Name="Continue" acknowledge.Text="Voltar ao lobby" acknowledge.Position=UDim2.new(0,16,1,-64) acknowledge.Size=UDim2.new(1,-32,0,48) acknowledge.Parent=overlay Theme.Button(acknowledge)
Nav:Connect(acknowledge,function() Bridge:Send("dismiss") end) Nav:SetBack(overlay,function() Bridge:Send("dismiss") end,acknowledge)
local reopen=Instance.new("TextButton") reopen.Name="OpenModes" reopen.Text="Jogar / Modalidades" reopen.AnchorPoint=Vector2.new(0,1) reopen.Position=UDim2.new(0,20,1,-22) reopen.Size=UDim2.fromOffset(214,42) reopen.TextSize=15 reopen.Parent=gui Theme.Button(reopen)
Nav:Connect(reopen,function() catalogOpen=true browser:Push({"RootPane","Modes"}) refresh() end)
refresh=function()
 local data=Bridge:Get() local mode=Scope:Get() local q=data and data.queue or {state="idle"}
 local open=mode=="hub" and catalogOpen and not player:GetAttribute("ExperienceMenuOpen") and not player:GetAttribute("ProgressionMenuOpen") and not player:GetAttribute("LobbyMusicMenuOpen")
 if browser.Backdrop.Visible~=open then browser:SetOpen(open) end
 player:SetAttribute("LobbyBrowserOpen",open)
 reopen.Visible=mode=="hub" and not open and not player:GetAttribute("ExperienceMenuOpen") and not player:GetAttribute("ProgressionMenuOpen") and not player:GetAttribute("LobbyMusicMenuOpen")
 local attention=mode~="hub" and (q.state=="failed" or q.state=="entering" or q.state=="travelling" or data and data.error or Bridge.LocalError)
 overlay.Visible=attention and true or false message.Text=Bridge.LocalError or data and data.error or q.message or ""
 acknowledge.Visible=q.state~="entering" and q.state~="travelling"
 if not data then return end
 if q.state=="ready" and q.route=="local" and quickEntry==q.gameId and not Bridge.Pending then quickEntry=nil task.defer(function() Bridge:Send("enter",nil,q.ticket) end) end
 local item=definition()
 for index,v in data.catalog do
  local card=cards[v.id]
  if card then
   local playable=v.canEnter==true
   card.Button.LayoutOrder=(playable and 0 or 1000)+index
   card.Button.Size=UDim2.new(1,-4,0,playable and 74 or 50)
   card.Button.BackgroundTransparency=playable and .22 or .6
   card.Button:SetAttribute("Playable",playable)
   card.Title.Text=v.name card.Title.TextSize=playable and 16 or 13
   card.Title.TextColor3=playable and Theme.Colors.Text or Color3.fromRGB(149,151,159)
   card.Title.Position=UDim2.fromOffset(12,playable and 9 or 5)
   card.State.Text=playable and "Disponível para jogar" or v.status=="planned" and "Em breve" or "Indisponível"
   card.State.TextColor3=playable and Color3.fromRGB(121,228,157) or Color3.fromRGB(137,140,149)
   card.State.Position=UDim2.fromOffset(12,playable and 40 or 27)
  end
 end
 description.Text=item and (item.name.."\n\n"..item.description.."\n\n"..(item.canEnter and "Escolha Jogar para entrar. Você pode permanecer no lobby pelo menu." or item.reason or "Em desenvolvimento.")) or "Carregando o catálogo..."
 primary.Text=Bridge.Pending and "Aguarde..." or q.state=="ready" and "Confirmar entrada" or item and item.canEnter and "Jogar "..item.name or "Em desenvolvimento"
 cancel.Visible=q.state=="joining" or q.state=="ready"
 status.Text=Bridge.LocalError or data.error or (q.state~="idle" and q.message) or ""
end
Nav:SetBack(browser.Panel,function() if #browser.Stack>1 then browser:Push({"RootPane"}) else stay() end end,homeButtons[1])
Nav.MenuRequested:Connect(function(id)
 if id=="Hub" and Scope:IsHub() then catalogOpen=true browser:Push({"RootPane","Modes"}) refresh()
 elseif id=="Resume" and Scope:IsHub() then stay() end
end)
Scope.Changed:Connect(function()
 local mode=Scope:Get() if mode=="hub" and lastMode~="hub" then catalogOpen=false end lastMode=mode refresh()
end)
Bridge.Changed:Connect(refresh)
player:GetAttributeChangedSignal("ExperienceMenuOpen"):Connect(refresh)
player:GetAttributeChangedSignal("ProgressionMenuOpen"):Connect(refresh)
player:GetAttributeChangedSignal("LobbyMusicMenuOpen"):Connect(refresh)
browser:Push({"RootPane"}) refresh()

