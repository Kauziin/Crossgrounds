-- Runs before StarterPlayerScripts; never depends on their UI or mode modules.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Content=game:GetService("ContentProvider")
local Input=game:GetService("ContextActionService")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui")
gui.Name="CrossgroundsLoading"gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=10000
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local coverGroup=Instance.new("CanvasGroup") coverGroup.Name="Transition" coverGroup.Size=UDim2.fromScale(1,1) coverGroup.BackgroundTransparency=1 coverGroup.Parent=gui
local background=Instance.new("TextButton")background.Name="Cover"background.Size=UDim2.fromScale(1,1)
background.BackgroundColor3=Color3.fromRGB(9,15,24)background.BorderSizePixel=0 background.Text=""
background.AutoButtonColor=false background.Modal=true background.Active=true background.Parent=coverGroup
local gradient=Instance.new("UIGradient")gradient.Color=ColorSequence.new(Color3.fromRGB(20,37,55),Color3.fromRGB(7,12,20))gradient.Rotation=35 gradient.Parent=background
local panel=Instance.new("Frame")panel.AnchorPoint=Vector2.new(.5,.5)panel.Position=UDim2.fromScale(.5,.5)
panel.Size=UDim2.new(.86,0,0,270)panel.BackgroundTransparency=1 panel.Parent=background
local limit=Instance.new("UISizeConstraint")limit.MaxSize=Vector2.new(540,370)limit.Parent=panel
local function label(name,text,y,size,color)
 local item=Instance.new("TextLabel")item.Name=name item.Text=text item.Position=UDim2.new(0,0,0,y)
 item.Size=UDim2.new(1,0,0,size+14)item.TextSize=size item.Font=Enum.Font.GothamMedium
 item.TextColor3=color or Color3.fromRGB(232,240,247)item.BackgroundTransparency=1
 item.TextWrapped=true item.Parent=panel return item
end
label("Brand","C R O S S G R O U N D S",0,19,Color3.fromRGB(118,204,235))
local title=label("Phase","Preparando sua chegada",59,28)title.Font=Enum.Font.GothamBold
local detail=label("Detail","Conectando ao servidor…",108,15,Color3.fromRGB(168,187,205))
detail.Size=UDim2.new(1,0,0,48)
local track=Instance.new("Frame")track.Name="ProgressTrack"track.Position=UDim2.new(0,0,0,176)
track.Size=UDim2.new(1,0,0,4)track.BorderSizePixel=0 track.BackgroundColor3=Color3.fromRGB(42,61,79)track.Parent=panel
local fill=Instance.new("Frame")fill.Name="Progress"fill.Size=UDim2.fromScale(0,1)fill.BorderSizePixel=0
fill.BackgroundColor3=Color3.fromRGB(101,203,234)fill.Parent=track
local status=label("Status","CARREGANDO",190,12,Color3.fromRGB(124,148,170))
local retry=Instance.new("TextButton")retry.Name="Retry"retry.AnchorPoint=Vector2.new(.5,0)
retry.Position=UDim2.new(.5,0,0,236)retry.Size=UDim2.fromOffset(240,42)
retry.Text="Tentar novamente"retry.Font=Enum.Font.GothamMedium retry.TextSize=15
retry.BackgroundColor3=Color3.fromRGB(39,80,103)retry.TextColor3=Color3.new(1,1,1)retry.Visible=false retry.Parent=panel
Instance.new("UICorner",retry).CornerRadius=UDim.new(0,6)
gui.Parent=player:WaitForChild("PlayerGui")
game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()
local visible=true local opened=os.clock()local clearSince=nil local request=nil local phase=""local mode="loading"
local retired={}
local prepared={}local remotes local readyRemote local charRevision=nil local arrivalReady=false
local cosmeticDone=false local cosmeticStarted=false
local function block()return Enum.ContextActionResult.Sink end
Input:BindActionAtPriority("CrossgroundsLoadingMovement",block,false,10000,Enum.PlayerActions.CharacterForward,Enum.PlayerActions.CharacterBackward,Enum.PlayerActions.CharacterLeft,Enum.PlayerActions.CharacterRight,Enum.PlayerActions.CharacterJump)
player:SetAttribute("ClientLoading",true)
local fade local fadeSerial=0
local function show(value)
 if value==visible then return end visible=value fadeSerial+=1 local serial=fadeSerial
 if fade then fade:Cancel() end
 player:SetAttribute("ClientLoading",value)
 if value then gui.Enabled=true coverGroup.GroupTransparency=0
 elseif player:GetAttribute("SettingReducedMenuMotion") then gui.Enabled=false
 else
  fade=game:GetService("TweenService"):Create(coverGroup,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{GroupTransparency=1})
  fade:Play() task.delay(.22,function() if serial==fadeSerial and not visible then gui.Enabled=false end end)
 end
 if value then
  opened=os.clock()clearSince=nil arrivalReady=false
  Input:BindActionAtPriority("CrossgroundsLoadingMovement",block,false,10000,Enum.PlayerActions.CharacterForward,Enum.PlayerActions.CharacterBackward,Enum.PlayerActions.CharacterLeft,Enum.PlayerActions.CharacterRight,Enum.PlayerActions.CharacterJump)
 else Input:UnbindAction("CrossgroundsLoadingMovement")end
end
local function countParts(root)
 local n=root:IsA("BasePart")and 1 or 0
 for _,obj in root:GetDescendants()do if obj:IsA("BasePart")then n+=1 end end return n
end
local function preload(roots,done)
 task.spawn(function()
  local assets={}for _,root in roots do for _,obj in root:GetDescendants()do
   if obj:IsA("MeshPart")or obj:IsA("Decal")or obj:IsA("Texture")then table.insert(assets,obj)end
   if #assets>=96 then break end
  end if #assets>=96 then break end end
  local finished=false task.spawn(function()pcall(function()Content:PreloadAsync(assets)end)finished=true end)
  local deadline=os.clock()+4 repeat task.wait(.1)until finished or os.clock()>deadline
  done()
 end)
end
local function rootsFor(data)
 local roots={}local loaded=0 local expected=0
 for _,desc in data.roots do
  expected+=desc.parts local found=nil
  for _,root in workspace:GetChildren()do
   if root.Name==desc.name and root:GetAttribute("ClientSceneRevision")==desc.revision and root:GetAttribute("ClientSceneIndex")==desc.index then found=root break end
  end
  if found then local n=countParts(found)loaded+=math.min(n,desc.parts)if n>=desc.parts then table.insert(roots,found)end end
 end
 return roots,loaded,expected,#roots==#data.roots
end
local function floorsReady(anchors,roots,terrain)
 if #anchors==0 then return true end
 local include=table.clone(roots)if terrain then table.insert(include,workspace.Terrain)end
 local params=RaycastParams.new()params.FilterType=Enum.RaycastFilterType.Include params.FilterDescendantsInstances=include params.RespectCanCollide=true
 for _,pos in anchors do if typeof(pos)~="Vector3"or not workspace:Raycast(pos+Vector3.new(0,1,0),Vector3.new(0,-14,0),params)then return false end end return true
end
local function beginScene(data)
 if typeof(data)~="table"or typeof(data.token)~="string"or typeof(data.roots)~="table"then return end
 if retired[data.token] then return end
 if prepared[data.token]then readyRemote:FireServer(data.token)return end
 if request and request.token==data.token then return end
 request=data request.mode=player:GetAttribute("CrossgroundsMode")request.assets=false request.preloading=false
 arrivalReady=false show(true)
end
task.spawn(function()
 local root=game.ReplicatedStorage:WaitForChild("Crossgrounds")remotes=root:WaitForChild("Remotes")
 readyRemote=remotes:WaitForChild("SceneReady")remotes:WaitForChild("PrepareScene").OnClientEvent:Connect(beginScene)
 remotes:WaitForChild("SceneLoadFinished").OnClientEvent:Connect(function(token)
  if request and request.token==token then request=nil end
  prepared[token]=nil retired[token]=true
  task.delay(35,function() retired[token]=nil end)
 end)
 for _,name in {"ArenaRemotes","GetOutRemotes"}do task.spawn(function()
  local state=root:WaitForChild(name):WaitForChild("State")
  state.OnClientEvent:Connect(function(data)
   if typeof(data)=="table"and data.id==player:GetAttribute("CrossgroundsMode")then phase=data.state or""end
  end)
 end)end
end)
retry.Activated:Connect(function()
 if not remotes then return end
 if player:GetAttribute("CrossgroundsMode")=="hub" or (player:GetAttribute("CrossgroundsMode")=="ctf" and workspace:GetAttribute("RoundState")=="LoadFailed")then
  local event=remotes:FindFirstChild("RetryLoading")if event then event:FireServer()end
 else local command=remotes:FindFirstChild("Command")if command then command:FireServer({action="returnHub"})end end
 opened=os.clock()retry.Visible=false arrivalReady=false
end)
local exit=retry:Clone() exit.Name="ReturnHub" exit.Text="Voltar ao lobby" exit.Position=UDim2.new(.5,0,0,284) exit.Visible=false exit.Parent=panel
exit.Activated:Connect(function()
 local command=remotes and remotes:FindFirstChild("Command")
 if command then command:FireServer({action="returnHub"}) end
end)
local elapsed=0
Run.RenderStepped:Connect(function(dt)
 elapsed+=dt if elapsed<.15 then return end elapsed=0
 local currentMode=player:GetAttribute("CrossgroundsMode")or"loading"
 if mode~=currentMode then mode=currentMode phase=""request=nil arrivalReady=false cosmeticStarted=false cosmeticDone=false prepared={} retired={}end
 local boot=workspace:GetAttribute("CrossgroundsBootReady")==true
 local mapBusy=phase=="loading"or phase=="deploying"or phase=="preparing"or(mode=="ctf"and player:GetAttribute("InMatch")==true and workspace:GetAttribute("RoundState")=="Loading")
 local demand=not game:IsLoaded()or not boot or mode=="loading"or player:GetAttribute("CrossgroundsTransition")==true or player:GetAttribute("SceneLoading")==true or mapBusy or request~=nil or player:GetAttribute("SceneLoadingError")~=nil
 local serial=player:GetAttribute("CharacterReadySerial")
 if charRevision~=serial then charRevision=serial arrivalReady=false end
 if demand then show(true)clearSince=nil end
 if not visible then return end
 local progress=.08 local caption="Conectando ao servidor…"local heading="Preparando sua chegada"
 local errorText=workspace:GetAttribute("CrossgroundsBootError")or player:GetAttribute("SceneLoadingError")
 if game:IsLoaded()then
  progress=.2 caption=workspace:GetAttribute("CrossgroundsBootPhase")or"Preparando a experiência…"
  if boot then
   progress=.4 heading=mode=="hub"and"Entrando no Crossgrounds"or"Preparando a modalidade"
   caption="Aguardando cenário e personagem…"
  end
 end
 local hubReady=mode~="hub"
 if mode=="hub"then
  local hub=workspace:FindFirstChild("CrossgroundsPrototype")local expected=workspace:GetAttribute("HubSceneParts")or math.huge
  local loaded=hub and countParts(hub)or 0 hubReady=loaded>=expected
  if boot and not hubReady then caption="Recebendo o lobby…"progress=.4+.25*math.min(loaded/expected,1)end
  if hubReady and not cosmeticStarted then cosmeticStarted=true preload({hub},function()cosmeticDone=true end)end
  hubReady=hubReady and cosmeticDone
 end
 if request then
  local data=request
  if mode~=data.mode then request=nil
  else
   local roots,loaded,expected,complete=rootsFor(data)
   progress=.4+.35*(expected>0 and loaded/expected or 1)
   heading="Carregando o mapa"caption=string.format("Recebendo cenário · %d / %d peças",loaded,expected)
   if complete then
    caption="Preparando os recursos do mapa…"
    if not data.preloading then data.preloading=true preload(roots,function()data.assets=true end)end
    if data.assets and floorsReady(data.anchors or{},roots,data.terrain)then
     prepared[data.token]=true readyRemote:FireServer(data.token)request=nil
    end
   end
  end
 end
 local character=player.Character local root=character and character:FindFirstChild("HumanoidRootPart")local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 local ready=player:GetAttribute("ModeCharacterReady")==true and root and humanoid and humanoid.Health>0
 if ready and not arrivalReady then
  local destination=player:GetAttribute("CharacterReadyPosition")
  if typeof(destination)=="Vector3"and(root.Position-destination).Magnitude<10 then
   local params=RaycastParams.new()params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={character}params.RespectCanCollide=true
   arrivalReady=workspace:Raycast(root.Position+Vector3.new(0,2,0),Vector3.new(0,-15,0),params)~=nil
  end
 end
 if boot and hubReady and not request then progress=math.max(progress,.85)end
 if not demand and ready and arrivalReady and hubReady and not errorText then
  clearSince=clearSince or os.clock()caption="Tudo pronto"progress=1
  if os.clock()-clearSince>.35 then show(false)return end
 else clearSince=nil end
 if errorText or os.clock()-opened>45 then
  heading="O carregamento precisa de atenção"caption=errorText or"O cenário ainda não ficou pronto. Aguarde ou tente novamente."
  retry.Text=mode=="hub"and"Recarregar personagem"or(mode=="ctf" and workspace:GetAttribute("RoundState")=="LoadFailed")and"Tentar carregar mapa"or"Voltar ao lobby"retry.Visible=remotes~=nil
 else retry.Visible=false end
 exit.Visible=retry.Visible and mode=="ctf" and workspace:GetAttribute("RoundState")=="LoadFailed"
 title.Text=heading detail.Text=caption fill.Size=UDim2.fromScale(math.clamp(progress,0,1),1)
 status.Text=errorText and"AGUARDANDO NOVA TENTATIVA"or"CENÁRIO • RECURSOS • PERSONAGEM"
end)
