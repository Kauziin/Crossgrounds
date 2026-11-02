local p=game.Players.LocalPlayer
local Scope=require(script.Parent:WaitForChild("ModeScope")) if not Scope:HasCombatRuntime() then return end local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local InputMode=require(script.Parent:WaitForChild("InputMode")) local Router=require(script.Parent:WaitForChild("ControlRouter")) local Icons=require(script.Parent:WaitForChild("InputIcons"))
local Bridge=require(script.Parent:WaitForChild("HubBridge")) local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local gui=Instance.new("ScreenGui") gui.Name="FloatingMapVote" gui.ResetOnSpawn=false gui.IgnoreGuiInset=false gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets gui.DisplayOrder=55 gui.Enabled=false gui.Parent=p.PlayerGui
local panel=Instance.new("Frame") panel.Name="Panel" panel.AnchorPoint=Vector2.new(.5,1) panel.Position=UDim2.new(.5,0,1,-70) panel.Size=UDim2.fromOffset(660,260) panel.Parent=gui Theme.Surface(panel)
local title=Theme.Text(panel,"Title","VOTE NO PRÓXIMO MAPA",28,16) title.Position=UDim2.fromOffset(12,8) title.Size=UDim2.new(1,-130,0,28)
local toggle=Instance.new("TextButton") toggle.Name="Toggle" toggle.Text="Votar / fechar" toggle.Position=UDim2.new(1,-126,0,8) toggle.Size=UDim2.fromOffset(114,30) toggle.TextSize=12 toggle.Parent=panel Theme.Button(toggle)
local list=Instance.new("ScrollingFrame") list.Name="Choices" list.BackgroundTransparency=1 list.BorderSizePixel=0 list.Position=UDim2.fromOffset(10,44) list.Size=UDim2.new(1,-20,1,-54) list.ScrollBarThickness=3 list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new() list.Parent=panel
local events=game.ReplicatedStorage:WaitForChild("Events") local arena=game.ReplicatedStorage.Crossgrounds:WaitForChild("ArenaRemotes")
local states={} local interactive=false local current
local function interact(value)
 interactive=value==true and gui.Enabled p:SetAttribute("MapVotingMenuOpen",interactive)
 toggle.Text=interactive and "Fechar · "..Icons:Name("ButtonB") or "Votar · "..Icons:Name(Router:Key("VoteMenu",InputMode:Get()==Enum.PreferredInput.Gamepad and "Gamepad" or "Keyboard"))
end
local grid=require(script.Parent:WaitForChild("MapVoteGrid")).new(list,function(id)
 if not current or not current.active then return end
 if Scope:IsArena() then arena.VoteMap:FireServer(id) elseif Scope:IsCTF() then events.VoteMap:FireServer(id) end
end)
grid.MinCard=140 grid.MaxColumns=4
local function refresh()
 current=states[Scope:Get()]
 local other=p:GetAttribute("ExperienceMenuOpen") or p:GetAttribute("ProgressionMenuOpen") or p:GetAttribute("LobbyMusicMenuOpen") or p:GetAttribute("HUDLayoutEditing")
 gui.Enabled=current~=nil and current.active==true and not other
 if not gui.Enabled then interact(false) return end
 grid:SetOptions(current.options or {}) grid:Update(current.counts or {},current.vote,true)
 title.Text="PRÓXIMO MAPA · "..math.max(0,math.ceil((current.endsAt or 0)-workspace:GetServerTimeNow())).."s"
end
local function update(mode,data)
 if typeof(data)~="table" then return end
 states[mode]={active=mode=="arena" and data.state=="voting" or mode=="ctf" and data.active==true,options=data.options or {},counts=data.counts or {},vote=data.vote,endsAt=data.endsAt}
 refresh()
end
events:WaitForChild("MapVoteState").OnClientEvent:Connect(function(data) update("ctf",data) end)
arena.State.OnClientEvent:Connect(function(data) update("arena",data) end)
Bridge.Changed:Connect(function() local data=Bridge:Get() if data and data.session and data.session.id=="arena" then update("arena",data.session) end end)
Scope.Changed:Connect(function() interact(false) refresh() end)
Nav:Connect(toggle,function() interact(not interactive) if interactive then task.delay(.06,function() if interactive then Nav:Focus(grid:First()) end end) end end)
Nav:SetBack(panel,function() interact(false) end,toggle)
Nav.MenuRequested:Connect(function(id)
 if id=="MapVote" or id=="ArenaVote" then refresh() interact(not interactive) if interactive then task.delay(.05,function() if gui.Enabled then Nav:Focus(grid:First()) end end) end
 elseif id~="Resume" then interact(false) end
end)
local function resize()
 local v=Theme.MenuBounds(workspace.CurrentCamera.ViewportSize) local w=math.min(660,v.X-24)
 panel.Size=UDim2.fromOffset(w,math.max(70,math.min(v.Y-130,w<430 and 330 or 230)))
 local scale=panel:FindFirstChildOfClass('UIScale')or Instance.new('UIScale',panel)scale.Scale=Theme.MobileFactor()
 panel.Position=UDim2.new(.5,0,1,-70-(workspace.CurrentCamera.ViewportSize.Y-v.Y)*.5)
end
Theme.ObserveMobile(resize)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
for _,key in {"ExperienceMenuOpen","ProgressionMenuOpen","LobbyMusicMenuOpen","HUDLayoutEditing"} do p:GetAttributeChangedSignal(key):Connect(refresh) end
local elapsed=0 game:GetService("RunService").Heartbeat:Connect(function(dt) elapsed+=dt if elapsed>=1 then elapsed=0 refresh() end end)
task.spawn(function() local ok,data=pcall(function() return events:WaitForChild("GetMapVoteState",10):InvokeServer() end) if ok then update("ctf",data) end end)
resize() refresh()
