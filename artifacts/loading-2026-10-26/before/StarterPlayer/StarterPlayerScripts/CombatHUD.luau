if not require(script.Parent:WaitForChild("ModeScope")):HasCTFRuntime() then return end
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local InputMode=require(script.Parent:WaitForChild("InputMode"))
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local Icons=require(script.Parent:WaitForChild("InputIcons"))
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local StarterGui=game:GetService("StarterGui")
local RunService=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local player=Players.LocalPlayer local events=game.ReplicatedStorage:WaitForChild("Events")
local Style=require(game.ReplicatedStorage.Crossgrounds.HUDStyle)
local Kits=require(game.ReplicatedStorage:WaitForChild("KitDefinitions"))
local gui=Instance.new("ScreenGui") gui.Name="CombatHUD" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=12 gui.Parent=player:WaitForChild("PlayerGui") gui.Enabled=Scope:IsCTF()
local white=Color3.fromRGB(234,242,252) local muted=Color3.fromRGB(161,183,205) local dark=Color3.fromRGB(18,28,42)
local function frame(parent,name,pos,size,color,trans)
 local f=Instance.new("Frame") f.Name=name f.Position=pos f.Size=size f.BackgroundColor3=color or dark f.BackgroundTransparency=trans or 0 f.BorderSizePixel=0 f.Parent=parent return f
end
local function round(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 7) c.Parent=p end
local function label(parent,name,text,pos,size,fontSize,color)
 local t=Instance.new("TextLabel") t.Name=name t.Position=pos t.Size=size t.BackgroundTransparency=1 t.Text=text t.Font=Enum.Font.GothamMedium t.TextSize=fontSize t.TextColor3=color or white t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=parent Style.Text(t) return t
end
local function button(parent,name,text,pos,size)
 local b=Instance.new("TextButton") b.Name=name b.Position=pos b.Size=size b.BackgroundColor3=Color3.fromRGB(32,48,67) b.BorderSizePixel=0 b.TextColor3=white b.Text=text b.TextSize=13 b.Font=Enum.Font.GothamMedium b.Selectable=true b.Parent=parent round(b) return b
end
task.spawn(function() for _=1,8 do local ok=pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false) StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false) end) if ok then break end task.wait(.5) end end)
local panel=frame(gui,"StatusPanel",UDim2.new(0,24,1,-24),UDim2.fromOffset(278,112),dark,1) panel.AnchorPoint=Vector2.new(0,1) round(panel,9)
local weapon=label(panel,"Weapon","",UDim2.fromOffset(12,7),UDim2.fromOffset(145,24),15) weapon.Font=Enum.Font.GothamBold
local ammo=label(panel,"Ammo","",UDim2.fromOffset(153,5),UDim2.fromOffset(113,27),20) ammo.TextXAlignment=Enum.TextXAlignment.Right ammo.Font=Enum.Font.GothamBold
local hp=label(panel,"Health","200",UDim2.fromOffset(230,34),UDim2.fromOffset(36,18),12) hp.TextXAlignment=Enum.TextXAlignment.Right
local healthBack=frame(panel,"HealthBar",UDim2.fromOffset(12,39),UDim2.fromOffset(209,7),Color3.fromRGB(51,64,76)) round(healthBack,3) Style.Outline(healthBack)
local healthFill=frame(healthBack,"Fill",UDim2.new(),UDim2.fromScale(1,1),Color3.fromRGB(92,213,139)) round(healthFill,3)
local staminaBack=frame(panel,"StaminaBar",UDim2.fromOffset(12,53),UDim2.fromOffset(254,4),Color3.fromRGB(51,64,76)) round(staminaBack,2) Style.Outline(staminaBack,Color3.fromRGB(129,202,255))
local staminaFill=frame(staminaBack,"Fill",UDim2.new(),UDim2.fromScale(1,1),Color3.fromRGB(99,182,236)) round(staminaFill,2)
local slots={}
for i=1,2 do slots[i]=button(panel,"Slot"..i,"",UDim2.fromOffset(12+(i-1)*130,70),UDim2.fromOffset(124,30)) Style.Outline(slots[i]) Style.Text(slots[i]) end
local menu=button(gui,"MenuButton","",UDim2.fromOffset(24,56),UDim2.fromOffset(155,30)) menu.BackgroundTransparency=1 Style.Outline(menu) Style.Text(menu)
local menuGlyph=Icons:Glyph(menu,"Command",function() return Router:Key(player:GetAttribute("InMatch") and "Leave" or "KitMenu",InputMode:Get()==Enum.PreferredInput.Gamepad and "Gamepad" or "Keyboard") end,24) menuGlyph.Position=UDim2.new(0,5,.5,-12)
menu.TextXAlignment=Enum.TextXAlignment.Right
local menuPadding=Instance.new("UIPadding") menuPadding.PaddingRight=UDim.new(0,14) menuPadding.Parent=menu
Router.Changed:Connect(function() Icons:Refresh() end) player:GetAttributeChangedSignal("InMatch"):Connect(function() Icons:Refresh() end)

local lobby=label(gui,"LobbyStatus","",UDim2.fromOffset(24,92),UDim2.fromOffset(430,40),14,muted) lobby.TextWrapped=true
local score=frame(gui,"Score",UDim2.new(.5,0,0,50),UDim2.fromOffset(300,38),dark,1) score.AnchorPoint=Vector2.new(.5,0) round(score)
local blue=label(score,"Blue","AZUL  0",UDim2.fromOffset(12,0),UDim2.fromOffset(95,38),15,Color3.fromRGB(114,186,255))
local timer=label(score,"Timer","",UDim2.fromOffset(105,0),UDim2.fromOffset(90,38),18) timer.TextXAlignment=Enum.TextXAlignment.Center
local red=label(score,"Red","0  VERMELHO",UDim2.fromOffset(195,0),UDim2.fromOffset(93,38),14,Color3.fromRGB(255,137,128)) red.TextXAlignment=Enum.TextXAlignment.Right
local objective=label(gui,"Objective","",UDim2.new(.5,-260,0,93),UDim2.fromOffset(520,25),13) objective.TextXAlignment=Enum.TextXAlignment.Center objective.TextStrokeTransparency=.55
local victory=label(gui,"Victory","",UDim2.new(.5,-240,.3,0),UDim2.fromOffset(480,60),28) victory.TextXAlignment=Enum.TextXAlignment.Center victory.Font=Enum.Font.GothamBold victory.TextStrokeTransparency=.45
local respawn=label(gui,"Respawn","",UDim2.new(.5,-180,.6,0),UDim2.fromOffset(360,32),20) respawn.TextXAlignment=Enum.TextXAlignment.Center respawn.TextStrokeTransparency=.4
local shade=frame(gui,"LeaveShade",UDim2.new(),UDim2.fromScale(1,1),Color3.new(0,0,0),.4) shade.Visible=false shade.BackgroundTransparency=1
local dialog=frame(shade,"Dialog",UDim2.fromScale(.5,.5),UDim2.fromOffset(360,155),dark) dialog.AnchorPoint=Vector2.new(.5,.5) round(dialog,12)
label(dialog,"Title","PREPARAÇÃO DO CTF?",UDim2.fromOffset(20,15),UDim2.fromOffset(320,30),21)
label(dialog,"Detail","Sair da partida e voltar ao treino do CTF.",UDim2.fromOffset(20,52),UDim2.fromOffset(320,25),13,muted)
local cancel=button(dialog,"Cancel","FICAR",UDim2.fromOffset(20,100),UDim2.fromOffset(152,38))
local confirm=button(dialog,"Confirm","VOLTAR AO TREINO",UDim2.fromOffset(188,100),UDim2.fromOffset(152,38)) confirm.BackgroundColor3=Color3.fromRGB(164,77,65)
cancel.NextSelectionRight=confirm confirm.NextSelectionLeft=cancel
local function close() shade.Visible=false end
local function open() if player:GetAttribute("InMatch") then shade.Visible=true end end
Nav:Connect(cancel,close)
Nav:SetBack(dialog,close,cancel)
Nav:Connect(confirm,function() close() events.LeaveMatch:FireServer() end)
Nav:Connect(menu,function()
 if player:GetAttribute("InMatch") then open() else Nav:OpenMenu("CTFKits") end
end)
Router:Register("Leave",function(state)
 if not player:GetAttribute("InMatch") then return Enum.ContextActionResult.Pass end
 if state==Enum.UserInputState.Begin then open() end
end)
local function equip(index)
 if shade.Visible or player:GetAttribute("ExperienceMenuOpen") then return end
 local p=Kits.Profiles[player:GetAttribute("SelectedKit")] local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 if not p or not h or h.Health<=0 then return end
 for _,container in {player.Backpack,c} do for _,t in container:GetChildren() do if t:IsA("Tool") and t:GetAttribute("WeaponId")==p.Weapons[index] then h:EquipTool(t) return end end end
end
for i,b in slots do Nav:Connect(b,function() equip(i) end) end
UIS.InputBegan:Connect(function(input,processed) if processed then return end if input.KeyCode==Enum.KeyCode.One then equip(1) elseif input.KeyCode==Enum.KeyCode.Two then equip(2) end end)
local feed=frame(gui,"KillFeed",UDim2.new(1,-24,0,126),UDim2.fromOffset(345,155),dark,1) feed.AnchorPoint=Vector2.new(1,0)
local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,4) layout.HorizontalAlignment=Enum.HorizontalAlignment.Right layout.Parent=feed
local entries={}
local function esc(s) return tostring(s or ""):gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;") end
local function short(s) s=tostring(s or "") local bot=s:match(" · IA$") s=s:gsub(" · IA$","") local n=utf8.offset(s,11) return (n and s:sub(1,n-1).."…" or s)..(bot and " · IA" or "") end
local function color(team) return team=="Blue" and "#83bcff" or "#ff9c92" end
events:WaitForChild("KillFeed").OnClientEvent:Connect(function(data)
 if not Scope:IsCTF() then return end
 local row=label(feed,"Entry","",UDim2.new(),UDim2.new(1,0,0,25),12) row.TextXAlignment=Enum.TextXAlignment.Right row.RichText=true row.BackgroundColor3=dark row.BackgroundTransparency=1 round(row,4)
 if data.killer then row.Text='<font color="'..color(data.killerTeam)..'">'..esc(short(data.killer))..'</font>  '..esc(data.weapon)..' › <font color="'..color(data.victimTeam)..'">'..esc(short(data.victim))..'</font>'
 else row.Text='<font color="'..color(data.victimTeam)..'">'..esc(short(data.victim))..'</font>  eliminado' end
 table.insert(entries,row)
 if #entries>5 then local old=table.remove(entries,1) old:Destroy() end
 task.delay(6,function() local i=table.find(entries,row) if i then table.remove(entries,i) end if row.Parent then Tween:Create(row,TweenInfo.new(.2),{TextTransparency=1,BackgroundTransparency=1}):Play() task.wait(.2) row:Destroy() end end)
end)
local toast=label(gui,"KillToast","",UDim2.new(.5,-220,1,-165),UDim2.fromOffset(440,28),16) toast.TextXAlignment=Enum.TextXAlignment.Center toast.Font=Enum.Font.GothamBold toast.TextStrokeTransparency=.45
local toastToken=0
local marker=label(gui,"HitMarker","×",UDim2.new(),UDim2.fromOffset(35,35),30) marker.AnchorPoint=Vector2.new(.5,.5) marker.TextXAlignment=Enum.TextXAlignment.Center marker.Visible=false marker.TextStrokeTransparency=.6
local hitSound=game.ReplicatedStorage:WaitForChild("HitMarker"):Clone() hitSound.Name="LocalHitMarker" hitSound.Volume=.32 hitSound.Parent=SoundService
local hitToken=0 local lastHitSound=-100 local headUntil=0
events:WaitForChild("CombatFeedback").OnClientEvent:Connect(function(data)
 if not Scope:IsCTF() then return end
 if data.kind=="Hit" then
  hitToken+=1 local mine=hitToken local p=player:GetAttribute("AimScreenPosition") or workspace.CurrentCamera.ViewportSize*.5
  if data.headshot then headUntil=os.clock()+.12 end
  marker.Position=UDim2.fromOffset(p.X,p.Y) marker.TextColor3=os.clock()<headUntil and Color3.fromRGB(255,197,100) or white marker.Visible=true
  if os.clock()-lastHitSound>=.06 then lastHitSound=os.clock() hitSound.PlaybackSpeed=data.headshot and 1.15 or 1 hitSound.TimePosition=0 hitSound:Play() end
  task.delay(.12,function() if mine==hitToken then marker.Visible=false end end)
 elseif data.kind=="Kill" then
  toastToken+=1 local mine=toastToken
  toast.Text=(data.headshot and "HEADSHOT" or "ELIMINAÇÃO").." · "..tostring(data.victim)..(data.xp and " · +"..data.xp.." XP" or "") toast.TextTransparency=0
  task.delay(2.2,function() if mine==toastToken then Tween:Create(toast,TweenInfo.new(.35),{TextTransparency=1}):Play() end end)
 end
end)
events.DisplayVictory.OnClientEvent:Connect(function(team)
 if not Scope:IsCTF() then return end
 victory.Text=team and (team=="Tie" and "EMPATE" or (team.Name=="Blue" and "AZUL VENCEU" or "VERMELHO VENCEU")) or ""
end)
local notificationToken=0
events.DisplayNotification.OnClientEvent:Connect(function(_,message)
 if not Scope:IsCTF() then return end
 notificationToken+=1 local n=notificationToken objective.Text=tostring(message)
 task.delay(2.5,function() if notificationToken==n then notificationToken=0 end end)
end)
local function resize()
 local v=workspace.CurrentCamera.ViewportSize
 local touch=InputMode:Get()==Enum.PreferredInput.Touch
 local gamepad=InputMode:Get()==Enum.PreferredInput.Gamepad
 local safeX=gamepad and math.max(24,v.X*.05) or 24
 local safeY=gamepad and math.max(24,v.Y*.05) or 24
 panel.AnchorPoint=touch and Vector2.new(0,0) or Vector2.new(0,1)
 panel.Position=touch and UDim2.fromOffset(18,135) or UDim2.new(0,safeX,1,-safeY)
 panel.Size=UDim2.fromOffset(278,touch and 126 or 112)
 for _,b in slots do b.Size=UDim2.fromOffset(124,touch and 44 or 30) end
 local scale=panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",panel)
 local factor=gamepad and math.clamp(v.Y/720,1,1.5) or touch and 1 or math.clamp(v.X/1100,.72,1)
 scale.Scale=factor
 local ds=dialog:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",dialog) ds.Scale=math.min(gamepad and 1.35 or 1,(v.X-30)/360)
 menu.Position=UDim2.fromOffset(safeX,gamepad and safeY or 56)
 menu.Size=UDim2.fromOffset(gamepad and 210 or 155,(gamepad or touch) and 44 or 30)
 menu.TextSize=gamepad and 17 or 13
 lobby.Position=UDim2.fromOffset(safeX,(gamepad and safeY or 56)+50)
 lobby.TextSize=gamepad and 18 or 14
 score.Position=UDim2.new(.5,0,0,gamepad and safeY or 50)
 local ss=score:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",score) ss.Scale=gamepad and factor or 1
 objective.Position=UDim2.new(.5,-260,0,(gamepad and safeY+38*factor+8 or 93))
 objective.TextSize=gamepad and 18 or 13
 toast.TextSize=gamepad and 22 or 16
 feed.Position=UDim2.new(1,-safeX,0,gamepad and safeY+100 or 126)
 feed.Size=UDim2.fromOffset(math.min(345,v.X*.42),155)
 local fs=feed:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",feed) fs.Scale=gamepad and factor or 1
 for _,r in entries do r.Size=UDim2.new(1,0,0,25) end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) InputMode.Changed:Connect(resize) resize()
local elapsed=0
RunService.RenderStepped:Connect(function(dt)
 elapsed+=dt if elapsed<.1 then return end elapsed=0
 local inArena=player:GetAttribute("InArena")==true local joined=player:GetAttribute("InMatch")==true
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 local t=c and c:FindFirstChildOfClass("Tool") local data=t and Kits.Weapons[t:GetAttribute("WeaponId")]
 local health=h and h.Health or 0
 panel.Visible=h and health>0 or false feed.Visible=inArena
 menu.Text=joined and "PREPARAÇÃO" or "KITS CTF"
 lobby.Visible=not inArena
 local state=workspace:GetAttribute("RoundState")
 lobby.Text=joined and "Você está pronto. Explore o lobby até a próxima rodada." or (state=="Playing" and "Rodada em andamento · Entre quando quiser." or "Treine, escolha seu kit e entre na partida.")
 if not joined and shade.Visible then close() end
 hp.Text=tostring(math.ceil(health)) healthFill.Size=UDim2.fromScale(math.clamp(health/200,0,1),1) healthFill.BackgroundColor3=health<60 and Color3.fromRGB(239,102,88) or Color3.fromRGB(92,213,139)
 local stamina=player:GetAttribute("Stamina") or 100 staminaFill.Size=UDim2.fromScale(stamina/100,1)
 weapon.Text=data and data.Name or "—"
 ammo.Text=data and (data.Kind=="Gun" and (t:GetAttribute("Reloading") and "···" or tostring(t:GetAttribute("PredictedAmmo") or t:GetAttribute("Ammo") or 0).." / "..tostring(t:GetAttribute("ReserveAmmo") or 0)) or "MELEE") or ""
 local profile=Kits.Profiles[player:GetAttribute("SelectedKit")]
 for i,b in slots do local id=profile and profile.Weapons[i] local d=id and Kits.Weapons[id] b.Text=tostring(i).."  "..(d and d.Name or "—") b.Outline.Color=t and t:GetAttribute("WeaponId")==id and Color3.fromRGB(99,196,255) or Color3.fromRGB(229,239,248) end
 blue.Text="AZUL  "..tostring(game.Teams.Blue:GetAttribute("Captures") or 0) red.Text=tostring(game.Teams.Red:GetAttribute("Captures") or 0).."  VERMELHO"
 local time=workspace:FindFirstChild("MapPurgeProof") time=time and time:FindFirstChild("Time")
 feed.Visible=player:GetAttribute("SettingKillFeedVisible")~=false
 local seconds=time and time.Value or 0 timer.Text=state=="Lobby" and "LOBBY" or string.format("%02d:%02d",math.floor(seconds/60),seconds%60)
 if notificationToken==0 then
  local own=player.Team and workspace.CTFInfrastructure:FindFirstChild(player.Team.Name.."Base")
  local flag=own and own:GetAttribute("FlagState")
  if inArena then
   objective.Text=flag=="carried" and "SUA BANDEIRA FOI ROUBADA — INTERCEPTE O PORTADOR" or flag=="dropped" and "RECUPERE SUA BANDEIRA · "..math.max(0,math.ceil((own:GetAttribute("FlagReturnAt") or 0)-workspace:GetServerTimeNow())).."s" or "Capture a bandeira inimiga e retorne à sua base"
  else objective.Text=state=="Countdown" and "A RODADA COMEÇA EM INSTANTES" or "" end
 end
 local at=player:GetAttribute("RespawnAt") or 0
 respawn.Text=health<=0 and at>workspace:GetServerTimeNow() and "REAPARECENDO EM "..math.ceil(at-workspace:GetServerTimeNow()) or ""
end)
Scope.Changed:Connect(function()
 gui.Enabled=Scope:IsCTF()
 close() toastToken+=1 hitToken+=1 notificationToken=0
 toast.Text="" victory.Text="" objective.Text="" marker.Visible=false hitSound:Stop()
 for _,entry in entries do entry:Destroy() end table.clear(entries)
end)


