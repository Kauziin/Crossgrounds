local Scope=require(script.Parent:WaitForChild("ModeScope"))
local role=workspace:GetAttribute("CrossgroundsPlaceRole")
if role~="combinedPrototype" and role~="arena" then return end
local player=game.Players.LocalPlayer local Run=game:GetService("RunService")
local Nav=require(script.Parent:WaitForChild("MenuNavigation")) local Bridge=require(script.Parent:WaitForChild("HubBridge"))
local Tween=game:GetService("TweenService") local Debris=game:GetService("Debris")
local Style=require(game.ReplicatedStorage.Crossgrounds.HUDStyle)
local Definitions=require(game.ReplicatedStorage.Crossgrounds.ArenaDefinitions)
local Mode=require(script.Parent:WaitForChild("InputMode"))
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local remotes=game.ReplicatedStorage.Crossgrounds:WaitForChild("ArenaRemotes")
local gui=Instance.new("ScreenGui") gui.Name="ArenaHUD" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=45 gui.Parent=player:WaitForChild("PlayerGui") gui.Enabled=Scope:IsArena()
local white=Color3.fromRGB(234,243,252) local dark=Color3.fromRGB(17,28,43)
local function frame(parent,name,x,y,w,h)
 local f=Instance.new("Frame") f.Name=name f.Position=UDim2.fromOffset(x,y) f.Size=UDim2.fromOffset(w,h) f.BackgroundColor3=dark f.BorderSizePixel=0 f.Parent=parent local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,9) c.Parent=f return f
end
local function label(parent,name,value,x,y,w,h,size)
 local t=Instance.new("TextLabel") t.Name=name t.Position=UDim2.fromOffset(x,y) t.Size=UDim2.fromOffset(w,h) t.BackgroundTransparency=1 t.Text=value t.Font=Enum.Font.GothamMedium t.TextSize=size or 14 t.TextColor3=white t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=parent Style.Text(t) return t
end
local function button(parent,name,value,x,y,w,h,callback)
 local b=Instance.new("TextButton") b.Name=name b.Text=value b.Position=UDim2.fromOffset(x,y) b.Size=UDim2.fromOffset(w,h) b.BackgroundColor3=Color3.fromRGB(38,75,111) b.BorderSizePixel=0 b.TextColor3=white b.TextSize=14 b.Font=Enum.Font.GothamBold b.Parent=parent local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,7) c.Parent=b Nav:Connect(b,callback) return b
end
local status=label(gui,"Round","ARENA · TESTES",24,45,500,34,19)
status.BackgroundTransparency=1 status.BackgroundColor3=dark
local info=label(gui,"Rules","20 HP · pistola + Executor",24,78,500,22,12)
info.BackgroundTransparency=1 info.BackgroundColor3=dark
local panel=frame(gui,"StatusPanel",24,0,276,108) panel.BackgroundTransparency=1 panel.AnchorPoint=Vector2.new(0,1) panel.Position=UDim2.new(0,24,1,-24)
local statusScale=Instance.new("UIScale") statusScale.Parent=panel
local health=label(panel,"Health","VIDA 20",12,5,260,24,16)
local bar=frame(panel,"HealthBack",12,31,252,9) Style.Outline(bar)
local fill=frame(bar,"Fill",0,0,252,9) fill.BackgroundColor3=Color3.fromRGB(77,194,159)
local ammo=label(panel,"Ammo","",12,46,252,22,15)
local stamina=label(panel,"Stamina","ESTAMINA",12,72,252,18,11)
local staminaBack=frame(panel,"StaminaBar",12,95,252,6) Style.Outline(staminaBack,Color3.fromRGB(129,202,255))
local staminaFill=frame(staminaBack,"Fill",0,0,252,6) staminaFill.BackgroundColor3=Color3.fromRGB(99,182,236)
local notifications=Instance.new("Frame") notifications.Name="Eliminations" notifications.BackgroundTransparency=1 notifications.AnchorPoint=Vector2.new(.5,0) notifications.Position=UDim2.fromScale(.5,.64) notifications.Size=UDim2.fromOffset(420,210) notifications.Parent=gui
local notificationScale=Instance.new("UIScale") notificationScale.Parent=notifications
local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,5) layout.HorizontalAlignment=Enum.HorizontalAlignment.Center layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=notifications
local killRows={}  local notificationId=0
local killFeed=Instance.new("Frame") killFeed.Name="KillFeed" killFeed.BackgroundTransparency=1 killFeed.AnchorPoint=Vector2.new(1,0) killFeed.Position=UDim2.new(1,-24,0,200) killFeed.Size=UDim2.fromOffset(360,180) killFeed.Parent=gui
local feedView=require(script.Parent:WaitForChild("KillFeedView")).new(killFeed,player,3,5)
local function clearNotifications()
 for _,row in killRows do if row.Parent then row:Destroy() end end killRows={} feedRows={} killFeed.Text=""
end
local function voice(id,volume,speed)
 local audio=Instance.new("Sound") audio.Name="ArenaFeedbackVoice" audio.SoundId=id audio.Volume=volume audio.PlaybackSpeed=speed or 1 audio.Parent=gui
 audio.Ended:Once(function() if audio.Parent then audio:Destroy() end end) Debris:AddItem(audio,6) audio:Play()
end
local function elimination(data)
 notificationId+=1
 local row=Instance.new("CanvasGroup") row.Name="Kill"..notificationId row.Size=UDim2.fromOffset(410,58) row.BackgroundColor3=dark row.BackgroundTransparency=1 row.BorderSizePixel=0 row.LayoutOrder=-notificationId row.GroupTransparency=1 row.Parent=notifications
 local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,8) corner.Parent=row
 local title=label(row,"Title",(data.headshot and "HEADSHOT" or "ELIMINAÇÃO").." · "..tostring(data.victim or ""),12,4,385,24,16)
 title.TextColor3=data.headshot and Color3.fromRGB(255,210,115) or white title.TextTruncate=Enum.TextTruncate.AtEnd
 local detail=tostring(data.weapon or "Arma").." · +"..tostring(data.xp or 0).." XP"..(data.training and " · TREINO" or "")
 if not data.training and (data.bonusXP or 0)>0 then detail..=" · inclui +"..data.bonusXP.." HS" end
 label(row,"Details",detail,12,29,385,23,12).TextTruncate=Enum.TextTruncate.AtEnd
 local pop=Instance.new("UIScale") pop.Scale=.92 pop.Parent=row
 table.insert(killRows,row)
 while #killRows>3 do local first=table.remove(killRows,1) if first.Parent then first:Destroy() end end
 Tween:Create(row,TweenInfo.new(.12),{GroupTransparency=0}):Play()
 Tween:Create(pop,TweenInfo.new(.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
 task.delay(2.4,function() if row.Parent then
  Tween:Create(row,TweenInfo.new(.22),{GroupTransparency=1}):Play()
  task.delay(.23,function() if row.Parent then row:Destroy() end local i=table.find(killRows,row) if i then table.remove(killRows,i) end end)
 end end)
end
local marker=label(gui,"Hit","×",0,0,35,35,24) marker.AnchorPoint=Vector2.new(.5,.5) marker.Position=UDim2.fromScale(.5,.5) marker.TextXAlignment=Enum.TextXAlignment.Center marker.Visible=false
local sound=game.ReplicatedStorage:FindFirstChild("HitMarker") if sound and sound:IsA("Sound") then sound=sound:Clone() sound.Parent=gui else sound=nil end
task.spawn(function()
 local samples={}
 for _,id in {Definitions.KillSound,Kits.Weapons.ArenaPistol.FireSound} do local sample=Instance.new("Sound") sample.SoundId=id sample.Parent=gui table.insert(samples,sample) end
 pcall(function() game:GetService("ContentProvider"):PreloadAsync(samples) end)
 for _,sample in samples do sample:Destroy() end
end)
local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local voteBrowser=Cascade.new(gui,"VoteShade","ARENA")
voteBrowser:AddPane("Maps","VOTAÇÃO DE MAPA")
local shade=voteBrowser.Backdrop local votePanel=voteBrowser.Panel
local state={state="idle",options={},counts={},endsAt=0} local voteOpen=false local cards={} local lastBallot=0 local markerToken=0
local hint=voteBrowser:Info("Maps","Hint","",60)
hint.LayoutOrder=-1 hint.Size=UDim2.new(1,-8,0,44)
local summary=voteBrowser:Info("Maps","Summary","",64) summary.LayoutOrder=1000
local mapList=voteBrowser.Panes.Maps.List
local voteGrid=require(script.Parent:WaitForChild("MapVoteGrid")).new(mapList,function(id)if state.state=="voting"then remotes.VoteMap:FireServer(id)end end)
local function showVote(value)
 local before=voteOpen voteOpen=value and Scope:IsArena()
 voteBrowser:SetOpen(voteOpen) player:SetAttribute("ArenaVotingOpen",voteOpen)
 if voteOpen and not before then
  voteBrowser:Push({"RootPane","Maps"})
  task.delay(.06,function()if voteOpen and voteGrid:First() then Nav:Focus(voteGrid:First()) end end)
 end
end
voteBrowser.OnClose=function() showVote(false) end
local back=voteBrowser:Button("RootPane","StayRoom","Continuar na sala",function() showVote(false) end)
voteBrowser:Button("RootPane","Maps","Votar no mapa  ›",function() voteBrowser:Push({"RootPane","Maps"}) end)
voteBrowser:Button("RootPane","Loadout","Escolher loadout",function() showVote(false) Nav:OpenMenu("Loadout") end)
voteBrowser:Button("RootPane","Settings","Ajustes",function() showVote(false) Nav:OpenMenu("Settings") end)
voteBrowser:Button("RootPane","ReturnHub","Voltar ao lobby principal",function() showVote(false) Bridge:Send("returnHub") end)
local function rebuildMaps(options)
 voteGrid:SetOptions(options)
end
Nav:SetBack(votePanel,function() if #voteBrowser.Stack>1 then voteBrowser:Push({"RootPane"}) else showVote(false) end end,back)
local open=button(gui,"OpenVoting","VOTAÇÃO",0,100,166,38,function() showVote(not voteOpen) end) open.AnchorPoint=Vector2.new(1,0) open.Position=UDim2.new(1,-24,0,100)
local returnButton=button(gui,"ReturnCrossgrounds","CROSSGROUNDS",0,144,166,38,function() Bridge:Send("returnHub") end) returnButton.AnchorPoint=Vector2.new(1,0) returnButton.Position=UDim2.new(1,-24,0,144)
local function snapshot(data)
 if typeof(data)~="table" or data.id~="arena" or not data.options then return end state=data
 rebuildMaps(state.options)
 if state.state=="voting" and state.endsAt~=lastBallot then lastBallot=state.endsAt showVote(true) end
 if state.state~="voting" then showVote(false) end
 voteGrid:Update(state.counts or {},state.vote,state.state=="voting")
end
remotes.State.OnClientEvent:Connect(snapshot)
Bridge.Changed:Connect(function(data) if data and data.mode=="arena" and data.session then snapshot(data.session) end end)
Nav.MenuRequested:Connect(function(id) if id=="ArenaVote" and Scope:IsArena() then showVote(true) end end)
local function scope()
 gui.Enabled=Scope:IsArena() if not Scope:IsArena() then showVote(false) markerToken+=1 marker.Visible=false clearNotifications() panel.Rotation=0 if sound then sound:Stop() end
 for _,audio in gui:GetChildren() do if audio:IsA("Sound") and audio.Name=="ArenaFeedbackVoice" then audio:Destroy() end end
 else pcall(function() game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false) game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false) end)
 local data=Bridge:Get() if data and data.session then snapshot(data.session) end end
end
Scope.Changed:Connect(scope)
game.ReplicatedStorage.Events:WaitForChild("CombatFeedback").OnClientEvent:Connect(function(data)
 if not Scope:IsArena() or typeof(data)~="table" then return end
 if data.kind=="Hit" or data.kind=="Kill" then
  markerToken+=1 local token=markerToken marker.Visible=true marker.TextColor3=data.headshot and Color3.fromRGB(255,211,117) or white
  local point=player:GetAttribute("AimScreenPosition") or workspace.CurrentCamera.ViewportSize*.5 marker.Position=UDim2.fromOffset(point.X,point.Y)
  marker.Rotation=data.kind=="Kill" and 15 or 0
  Tween:Create(marker,TweenInfo.new(.12),{Rotation=0}):Play()
  if data.kind=="Kill" then elimination(data) voice(Definitions.KillSound,.7,data.headshot and 1.05 or 1)
  elseif sound then voice(sound.SoundId,sound.Volume) end
  task.delay(data.kind=="Kill" and .22 or .12,function() if markerToken==token then marker.Visible=false end end)
 elseif data.kind=="ArenaKillFeed" then
  feedView:Add({killer=data.attacker,victim=data.victim,weapon=data.weapon,headshot=data.headshot,killerUserId=data.killerUserId,victimUserId=data.victimUserId})
 end
end)
local elapsed=0
Run.RenderStepped:Connect(function(dt)
 local modal=voteOpen or player:GetAttribute("ExperienceMenuOpen") or player:GetAttribute("ProgressionMenuOpen") or player:GetAttribute("LobbyMusicMenuOpen")
 for _,element in {status,info,panel,notifications,killFeed,open,returnButton} do element.Visible=not modal end
 local v=workspace.CurrentCamera.ViewportSize
 local touch=Mode:Get()==Enum.PreferredInput.Touch
 statusScale.Scale=touch and math.clamp(v.Y/600,.75,1) or 1
 panel.AnchorPoint=touch and Vector2.zero or Vector2.new(0,1)
 panel.Position=touch and UDim2.fromOffset(12,106) or UDim2.new(0,24,1,-24)
 status.TextSize=touch and 14 or 19 status.Size=touch and UDim2.new(1,-110,0,30) or UDim2.fromOffset(500,34)
 info.TextSize=touch and 11 or 12 info.Size=touch and UDim2.new(1,-32,0,22) or UDim2.fromOffset(500,22)
 info.TextTruncate=Enum.TextTruncate.AtEnd
 if touch then
  local portrait=v.Y>v.X
  killFeed.AnchorPoint=portrait and Vector2.new(1,0) or Vector2.new(.5,0)
  killFeed.Position=portrait and UDim2.new(1,-12,0,106) or UDim2.new(.5,0,0,106)
  killFeed.Size=UDim2.fromOffset(portrait and v.X*.37 or math.min(280,v.X*.34),84)
 else
  killFeed.AnchorPoint=Vector2.new(1,0) killFeed.Position=UDim2.new(1,-24,0,200) killFeed.Size=UDim2.fromOffset(360,115)
 end
 notificationScale.Scale=math.min(1,math.max(.45,(v.X-30)/420))
 local lean=Scope:IsArena() and not voteOpen and (player:GetAttribute("CameraMotionRoll") or 0) or 0
 local hudAngle=math.clamp(math.deg(lean)*.45,-1.5,1.5)
 panel.Rotation+=(hudAngle-panel.Rotation)*(1-math.exp(-dt*12))
 killFeed.Visible=not modal and player:GetAttribute("SettingKillFeedVisible")~=false
 shade.Visible=voteOpen and not player:GetAttribute("ExperienceMenuOpen") player:SetAttribute("ArenaVotingOpen",shade.Visible)
 elapsed+=dt if elapsed<.1 or not Scope:IsArena() then return end elapsed=0
 local seconds=math.max(0,math.ceil(state.paused and (state.remaining or 0) or (state.endsAt or 0)-workspace:GetServerTimeNow()))
 local name="Sala de preparação" for _,option in state.options do if option.id==state.map then name=option.name break end end
 local phase=({voting="VOTAÇÃO",loading="CARREGANDO",playing="PARTIDA",results="RESULTADOS",failed="INDISPONÍVEL"})[state.state] or "AGUARDANDO"
 status.Text="ARENA · "..phase.." · "..string.format("%d:%02d",math.floor(seconds/60),seconds%60)..(state.paused and " · PAUSADO" or "")
 info.Text=name.." · "..tostring(player:GetAttribute("ArenaKills") or 0).." eliminações · "..tostring(player:GetAttribute("ArenaDeaths") or 0).." mortes · "..tostring(player:GetAttribute("ArenaSessionXP") or 0).." XP da sessão"
 hint.Text=state.state=="voting" and ("Escolha um cenário · "..seconds.."s · um voto por jogador") or "A votação abre na próxima rodada."
 summary.Text="Visual selecionado: "..(Kits.ArenaPistolNames[player:GetAttribute("ArenaPistolVisual")] or "—").." · vale no próximo respawn.\nExecutor como segunda arma."
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") local hp=h and h.Health or 0
 local maxHealth=h and h.MaxHealth or Definitions.Health
 health.Text="VIDA "..math.ceil(hp).." / "..math.ceil(maxHealth)
 fill.Size=UDim2.fromScale(fill.Size.X.Scale+(math.clamp(hp/math.max(1,maxHealth),0,1)-fill.Size.X.Scale)*.8,1)
 local t=player.Character and player.Character:FindFirstChildOfClass("Tool")
 ammo.Text=t and (t.Name.." · "..(t:GetAttribute("WeaponKind")=="Gun" and (t:GetAttribute("Reloading") and "RECARGA..." or tostring(t:GetAttribute("Ammo") or 0).." / "..tostring(t:GetAttribute("ReserveAmmo") or 0)) or "CORPO A CORPO")) or "Aguardando equipamento"
 local respawn=math.max(0,math.ceil((player:GetAttribute("ArenaRespawnAt") or 0)-workspace:GetServerTimeNow()))
 stamina.Text=respawn>0 and ("REAPARECENDO EM "..respawn.."s") or "ESTAMINA"
 local energy=math.clamp((player:GetAttribute("Stamina") or 100)/100,0,1)
 staminaFill.Size=UDim2.fromScale(staminaFill.Size.X.Scale+(energy-staminaFill.Size.X.Scale)*.8,1)
 open.Visible=false returnButton.Visible=false
end)
scope()

