local Players=game:GetService("Players") local Tween=game:GetService("TweenService") local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer local root=game.ReplicatedStorage
local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Scope=require(script.Parent:WaitForChild("ModeScope")) local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Router=require(script.Parent:WaitForChild("ControlRouter")) local Icons=require(script.Parent:WaitForChild("InputIcons"))
local Mode=require(script.Parent:WaitForChild("InputMode")) local Bridge=require(script.Parent:WaitForChild("HubBridge"))
local Card=require(script.Parent:WaitForChild("SettingsCard"))
local Visual=require(script.Parent:WaitForChild("SettingsVisual"))
local Palette=Theme.Settings
local Preferences=require(script.Parent:WaitForChild("PreferenceClient"))
local Reticle=require(root.Crossgrounds.Reticle)
local Settings=require(root.ExperienceSettings) local Controls=require(root.ControlDefinitions)
local Loadouts=require(root.Crossgrounds.LoadoutDefinitions) local remotes=root.Crossgrounds:WaitForChild("Remotes")
local update=root.Events:WaitForChild("UpdateExperienceSetting")
local gui=Instance.new("ScreenGui") gui.Name="ExperienceMenu" gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.ResetOnSpawn=false gui.IgnoreGuiInset=false gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets gui.DisplayOrder=65 gui.Parent=player:WaitForChild("PlayerGui")
local white=Color3.fromRGB(236,243,249) local muted=Color3.fromRGB(159,182,198) local accent=Color3.fromRGB(84,191,204)
local function label(parent,name,value,size)
 local t=Instance.new("TextLabel") t.Name=name t.Text=value t.Size=size or UDim2.new(1,-24,0,24) t.BackgroundTransparency=1 t.Font=Enum.Font.GothamMedium t.TextSize=14 t.TextColor3=white t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=parent return t
end
local function btn(parent,name,value)
 local b=Instance.new("TextButton") b.Name=name b.Text=value b.Size=UDim2.new(1,-4,0,46) b.BackgroundColor3=Color3.fromRGB(30,48,62) b.BorderSizePixel=0 b.TextColor3=white b.TextSize=15 b.Font=Enum.Font.GothamMedium b.TextXAlignment=Enum.TextXAlignment.Left b.TextWrapped=true b.Parent=parent
 local pad=Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0,12) pad.PaddingRight=UDim.new(0,10) pad.Parent=b
 local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,6) corner.Parent=b return b
end
local launch=btn(gui,"SettingsButton","☰  MENU") launch.Size=UDim2.fromOffset(104,38) launch.AnchorPoint=Vector2.new(1,0) launch.Position=UDim2.new(1,-16,0,56)
local shade=Instance.new("Frame") shade.Name="Shade" shade.Size=UDim2.fromScale(1,1) shade.BackgroundColor3=Color3.fromRGB(3,9,14) shade.BackgroundTransparency=1 shade.Visible=false shade.Active=true shade.Parent=gui
local panel=Instance.new("Frame") panel.Name="Panel" panel.BackgroundTransparency=1 panel.AnchorPoint=Vector2.new(.5,.5) panel.Position=UDim2.fromScale(.5,.5) panel.Size=UDim2.new(1,-48,1,-88) panel.Parent=shade
local header=label(panel,"Title","CROSSGROUNDS  /  PAUSA",UDim2.new(1,0,0,30)) header.TextSize=20 header.Font=Enum.Font.GothamBold
local status=label(panel,"Status","",UDim2.new(1,0,0,32)) status.Position=UDim2.new(0,0,1,-32) status.TextColor3=muted status.TextWrapped=true status.TextSize=12
local panes={} local lists={}
for _,id in {"Main","Options","Categories","Detail"} do
 local f=Instance.new("Frame") f.Name=id f.BackgroundColor3=Color3.fromRGB(14,26,36) f.BorderSizePixel=0 f.ClipsDescendants=true f:SetAttribute("CascadePane",true) f.Parent=panel panes[id]=f
 local title=btn(f,"Back","") title.Position=UDim2.fromOffset(8,8) title.Size=UDim2.new(1,-16,0,38) title.BackgroundTransparency=1
 local list=Instance.new("ScrollingFrame") list.Name="List" list.Position=UDim2.fromOffset(8,52) list.Size=UDim2.new(1,-16,1,-60) list.BackgroundTransparency=1 list.BorderSizePixel=0 list.ScrollBarThickness=4 list.ScrollBarImageColor3=accent list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new() list.Parent=f lists[id]=list
 local layout=Instance.new("UIListLayout") layout.Padding=UDim.new(0,6) layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=list
end
local page="Main" local category="Options" local connections={} local detailRows={} local mainButtons={}
local activeLoadoutView
local show,render,resize,confirm
local pageState={} local pendingConfirmation
local paneTweens={}
local function remember()
 if lists.Detail.Visible then local focused=Nav:GetFocus() pageState[page]={scroll=lists.Detail.CanvasPosition,focus=focused and focused:IsDescendantOf(lists.Detail) and focused.Name or nil} end
end
local editScope="Global"
local bindingDevice="Keyboard"
local bindingTabs=Instance.new("Frame") bindingTabs.Name="InputTabs" bindingTabs.BackgroundTransparency=1 bindingTabs.Position=UDim2.fromOffset(8,50) bindingTabs.Size=UDim2.new(1,-16,0,30) bindingTabs.Visible=false bindingTabs.Parent=panes.Detail
local tabButtons={}
for index,entry in {{"Keyboard","Teclado & Mouse"},{"Gamepad","Controle"},{"Touch","Toque"}} do
 local b=btn(bindingTabs,entry[1],entry[2]) b.Size=UDim2.new(1/3,-3,1,0) b.Position=UDim2.new((index-1)/3,0,0,0) b.TextSize=11 b.TextXAlignment=Enum.TextXAlignment.Center
 b.UIPadding.PaddingLeft=UDim.new(0,2) b.UIPadding.PaddingRight=UDim.new(0,2) tabButtons[entry[1]]=b
 Nav:Connect(b,function() if not player:GetAttribute("Rebinding") then bindingDevice=entry[1] render("Bindings") Nav:Focus(b) end end)
end
local categories={
 Options={{"Gameplay","Geral"},{"Controls","Controles"},{"Camera","Mira e Câmera"},{"Interface","Interface"},{"Graphics","Gráficos"},{"Accessibility","Acessibilidade"},{"Audio","Áudio"},{"Progress","Progresso"},{"Maps","Votação de mapa"},{"AdminMaps","Admin · mapas e capturas"},{"Development","Desenvolvimento · Studio"}},
 Controls={{"Analog","Analógicos"},{"Bindings","Remapear comandos"},{"HUDSettings","Toque · editar HUD"}},
 Camera={{"CameraCore","Câmera e perspectiva"},{"Aim","Mira e sensibilidade"},{"Reticle","Retículo"}},
}
local leafParent={Aim="Camera",Reticle="Camera",CameraCore="Camera",Analog="Controls",Bindings="Controls",HUDSettings="Controls"}
local keys={Graphics=Settings.Categories.Graphics,Gameplay=Settings.Categories.Gameplay,CameraCore=Settings.Categories.Camera,Aim=Settings.Categories.Aim,Analog=Settings.Categories.Analog,Interface=Settings.Categories.Interface,Accessibility=Settings.Categories.Accessibility,Audio=Settings.Categories.Audio,Reticle=Settings.Categories.Reticle}
local titles={Graphics="GRÁFICOS",AdminMaps="ADMIN · MAPAS E CAPTURAS",Gameplay="GERAL",Controls="CONTROLES",Camera="MIRA E CÂMERA",CameraCore="CÂMERA",Aim="MIRA",Reticle="RETÍCULO",Interface="INTERFACE",Analog="ANALÓGICOS",Accessibility="ACESSIBILIDADE",Audio="ÁUDIO",Bindings="REMAPEAR COMANDOS",HUDSettings="TOQUE · HUD",Options="OPÇÕES",Loadout="LOADOUT",Maps="MAPAS",Development="DESENVOLVIMENTO",Surrender="RENDER-SE",Exit="SAIR"}
local function get(key) local v=player:GetAttribute("Setting"..key) if v==nil then return Settings.Rules[key].Default end return v end
local function cleanDetail()
 if activeLoadoutView then activeLoadoutView:Destroy() activeLoadoutView=nil end
 for _,c in connections do c:Disconnect() end connections={}
 for _,v in lists.Detail:GetChildren() do if not v:IsA("UIListLayout") then v:Destroy() end end detailRows={}
end
local function hook(signal,fn) local c=signal:Connect(fn) table.insert(connections,c) return c end
local function info(text)
 local t=label(lists.Detail,"Info",text,UDim2.new(1,-6,0,62)) t.TextWrapped=true t.AutomaticSize=Enum.AutomaticSize.Y t.TextColor3=muted t.TextYAlignment=Enum.TextYAlignment.Top return t
end
local function action(name,text,fn)
 local b=btn(lists.Detail,name,text) Nav:Connect(b,fn) table.insert(detailRows,b) return b
end
local function context(key)
 return Preferences:Context(key,Settings:Allows(key,editScope) and editScope or "Global")
end
local function commit(key,value)
 Preferences:Edit(key,context(key),value,"set")
end
local function settingRow(key)
 local row=Card.new(lists.Detail,key,{Settings=Settings,Preferences=Preferences,Nav=Nav,Context=context,Commit=commit,Scale=function() return get("MenuScale") end})
 table.insert(detailRows,row)
end
confirm=function(message,callback)
 remember() cleanDetail() pendingConfirmation=page
 info(message)
 action("ConfirmReset","CONFIRMAR RESTAURAÇÃO",function() local target=pendingConfirmation pendingConfirmation=nil callback() render(target) end)
 action("CancelReset","Cancelar",function() local target=pendingConfirmation pendingConfirmation=nil render(target) end)
 resize(true)
end
local function dev(actionName,payload)
 local remote=remotes:FindFirstChild("DevelopmentCommand") if not remote then status.Text="Ferramentas disponíveis somente no Studio." return end
 task.spawn(function() local ok,success,message=pcall(function() return remote:InvokeServer(actionName,payload) end) status.Text=ok and message or "Falha na solicitação." end)
end
render=function(id)
 remember() page=id pendingConfirmation=nil cleanDetail() panes.Detail.Back.Text="‹  "..(titles[id] or id)
 if keys[id] then
  local modeFields=false for _,key in keys[id] do if Settings.Rules[key].ModeOverride then modeFields=true end end
  if modeFields then
   action("Scope","Escopo: "..(editScope=="Global" and "Global" or editScope:sub(6):upper()).."  ›",function()
    editScope=editScope=="Global" and "Mode:ctf" or editScope=="Mode:ctf" and "Mode:arena" or "Global" render(id)
   end)
  end
  if id=="Reticle" then
   local preview=btn(lists.Detail,"ReticlePreview","Prévia · toque para simular movimento") preview.Size=UDim2.new(1,-4,0,135) preview.TextYAlignment=Enum.TextYAlignment.Bottom preview.TextSize=12
   local sample=Reticle.new(preview,"ReticlePreviewShape") sample.Root.Position=UDim2.fromScale(.5,.42) local moving=false
   local function updatePreview() sample:Update(function(key) return Preferences:Value(key,context(key)) end,moving and 1 or 0) end
   hook(Preferences.Changed,updatePreview) Nav:Connect(preview,function() moving=not moving updatePreview() end) updatePreview()
  end
  for _,key in keys[id] do if not (Scope:IsArena() and table.find({"FirstPerson","ShiftLock","Shoulder"},key)) then settingRow(key) end end
  action("ResetCategory","Restaurar padrões desta categoria",function() confirm("Restaurar os padrões desta categoria no escopo selecionado?",function() Preferences:Reset(modeFields and editScope~="Global" and editScope or context(keys[id][1]),Settings.Rules[keys[id][1]].Category,false) end) end)
  if modeFields and editScope~="Global" then action("InheritCategory","Voltar a herdar Global nesta categoria",function() confirm("Remover as personalizações desta categoria e herdar Global?",function() Preferences:Reset(editScope,Settings.Rules[keys[id][1]].Category,true) end) end) end
  if id=="Interface" then
   action("ResetAllPreferences","Restaurar preferências globais",function() confirm("Restaurar todas as preferências globais?",function() Preferences:Reset("Global","All",true) end) end)
   action("ResetEveryScope","Restaurar tudo: global, modos e dispositivos",function() confirm("Restaurar todas as preferências, incluindo modos e dispositivos?",function() for _,scope in {"Global","Mode:ctf","Mode:arena","Device:Keyboard","Device:Gamepad","Device:Touch"} do Preferences:Reset(scope,"All",true) end end) end)
  end
  if id=="Graphics" then info("Equilibrado é o padrão. Alto e Visual acrescentam efeitos; Desempenho reduz sombras e pós-processamento. A qualidade global do Roblox continua sob seu controle. Profundidade de campo fica restrita à câmera de fotografia no perfil Visual.") end
  if id=="Aim" then info("Desaceleração reduz a sensibilidade perto do corpo. Acompanhamento ajuda uma parte do movimento visível, sem centralizar a mira; diminui com a distância.") end
  if id=="Audio" then action("Playlist","GERENCIAR PLAYLIST DO LOBBY  ›",function() show(false) Nav:OpenMenu("Playlist") end) end
  if id=="Gameplay" then info("Corrida automática: ativa no toque ao avançar; para ao recuar ou abrir menus. Usa estamina.") end
 elseif id=="Loadout" then
  if Scope:IsHub() then info("Entre em uma modalidade pelo catálogo para escolher seu loadout. Durante a rodada, a troca vale no próximo nascimento.") resize(true) return end
  if Scope:IsGetOut() then info("Get Out Clássico usa papéis sorteados a cada rodada. O protótipo não possui loadout selecionável.") resize(true) return end
  local mode=Scope:IsArena() and "arena" or "ctf"
  if mode=="arena" then
   activeLoadoutView=require(script.Parent:WaitForChild("LoadoutMenuView")).new(lists.Detail,{
    Player=player,Navigation=Nav,Definitions=Loadouts,Loadouts=Loadouts.List(mode),
    Select=function(id) remotes.SelectLoadout:FireServer(mode,id) end,
   })
   resize(true) return
  end
  info("Sua escolha entra em vigor no próximo nascimento. O equipamento desta vida é preservado.")
  local function refresh()
   local active=player:GetAttribute(Loadouts.ActiveAttribute(mode)) local pending=player:GetAttribute(Loadouts.PendingAttribute(mode))
   local selected=pending or active
   for _,b in detailRows do
    local marked=b:GetAttribute("LoadoutId")==selected
    b.BackgroundColor3=marked and Theme.Colors.Selected or Theme.Colors.Button
    b:SetAttribute("MenuSelected",marked)
   end
   status.Text=pending and "Loadout agendado para o próximo nascimento." or "Selecione o equipamento para sua próxima vida."
  end
  for _,l in Loadouts.List(mode) do
   local b=action(l.id,tostring(l.number)..".  "..l.name.."  ·  "..l.class.."\n"..l.primary.."  /  "..l.secondary,function() remotes.SelectLoadout:FireServer(mode,l.id) end)
   b.Size=UDim2.new(1,-4,0,76) b.TextSize=14 b:SetAttribute("LoadoutId",l.id)
  end
  hook(player:GetAttributeChangedSignal(Loadouts.PendingAttribute(mode)),refresh) hook(player:GetAttributeChangedSignal(Loadouts.ActiveAttribute(mode)),refresh) refresh()
 elseif id=="HUDSettings" then
  action("EditHUD","EDITAR POSIÇÃO, TAMANHO E OPACIDADE",function() show(false) Nav:OpenMenu("MobileHUD") end).Size=UDim2.new(1,-4,0,64)
  info("Todos os botões ficam expostos no editor, inclusive os específicos de CTF. Arraste um botão, ajuste os valores e toque SALVAR.")
 elseif id=="Bindings" then
  if bindingDevice=="Touch" then
   info("Personalize a posição, o tamanho e a opacidade dos comandos de toque. Na captura limpa admin, toque com três dedos para restaurar a interface.")
   action("EditTouchHUD","EDITAR CONTROLES DE TOQUE",function() show(false) Nav:OpenMenu("MobileHUD") end)
  else
   info("Selecione um comando e pressione o novo botão em até 5s. Sem entrada, mantém a configuração anterior.")
   local device=bindingDevice
   for _,actionName in Controls.Order do
    if not Controls.Actions[actionName].AdminOnly or player:GetAttribute("CrossgroundsAdmin")==true then
     local b=action(actionName..device,"",function() Router:Capture(actionName,device) end)
     local glyph,refresh=Icons:Glyph(b,"Binding",function() return Router:Key(actionName,device) end,28) glyph.Position=UDim2.fromOffset(3,9)
     b.TextXAlignment=Enum.TextXAlignment.Right b.TextSize=12
     local function updateKey() b.Text=Controls.Actions[actionName].Label.."  ·  "..Icons:Name(Router:Key(actionName,device)).."    " refresh() end
     hook(Router.Changed,updateKey) hook(Icons.Changed,updateKey) updateKey()
    end
   end
   action("ResetControls","RESTAURAR PADRÕES DESTE DISPOSITIVO",function() Router:Reset(device) end)
  end
 elseif id=="AdminMaps" then
  if player:GetAttribute("CrossgroundsAdmin")~=true then return end
  info("Escolha um mapa para explorar em modo espectador. Tempo ilimitado, sem rodada ou reinício automático. A seleção ativa o modo admin e sai da partida atual.")
  task.spawn(function()
   local remote=remotes:FindFirstChild("AdminCamera")
   local ok,allowed,catalog=pcall(function() return remote:InvokeServer("catalog") end)
   if page~="AdminMaps" or not shade.Visible then return end
   if not ok or not allowed then status.Text="Catálogo admin indisponível." return end
   for _,entry in catalog do
    action("Photo_"..entry.id,entry.mode.."  ·  "..entry.name,function()
     show(false) player:SetAttribute("AdminMapSelection",nil) player:SetAttribute("AdminMapSelection",entry.id)
    end)
   end
   resize(false)
  end)
 elseif id=="Maps" then
  if Scope:IsArena() then action("ArenaVote","ABRIR VOTAÇÃO DA ARENA",function() show(false) Nav:OpenMenu("ArenaVote") end)
  elseif Scope:IsCTF() then
   info("Votação disponível durante a preparação da rodada.")
   task.spawn(function()
    local ok,data=pcall(function() return root.Events.GetMapVoteState:InvokeServer() end)
    if not ok or page~="Maps" or not shade.Visible then return end
    local grid=require(script.Parent:WaitForChild("MapVoteGrid")).new(lists.Detail,function(id)root.Events.VoteMap:FireServer(id)end)
    local function updateVote(snapshot)
     if page~="Maps" or not shade.Visible or not grid.Frame.Parent then return end
     grid:SetOptions(snapshot.options or {}) grid:Update(snapshot.counts or {},snapshot.vote,snapshot.active)
     status.Text=snapshot.active and "Escolha um mapa · um voto por jogador." or "Votação fechada."
    end
    hook(root.Events.MapVoteState.OnClientEvent,updateVote) updateVote(data)
   end)
  elseif Scope:IsGetOut() then info("O protótipo Get Out usa Facility. A votação de mapas virá após a validação de outros cenários.")
  else info("Entre em uma modalidade para votar em um mapa.") end
 elseif id=="Development" then
  info("Ferramentas de teste exclusivas do Studio. Nenhum comando é disponibilizado em servidores publicados.")
  if workspace:GetAttribute("DevelopmentToolsAvailable") then
   action("BotsDebug","Alternar diagnóstico dos bots",function() dev("botsDebug",not workspace:GetAttribute("BotDiagnosticsEnabled")) end)
   action("BotsSnapshot","Medir bots / rotas / CPU",function() dev("botsSnapshot") end)
   for _,profile in {"Recruit","Regular","Veteran","Elite"} do action("BotProfile"..profile,"Próximos bots: "..profile,function() dev("botsDifficulty",profile) end) end
   for _,a in {{"pause","PAUSAR CRONÔMETRO"},{"resume","RETOMAR CRONÔMETRO"},{"restart","REINICIAR RODADA"},{"vote","ENCERRAR / NOVA VOTAÇÃO"},{"respawn","RENASCER AGORA"}} do action(a[1],a[2],function() dev(a[1]) end) end
   for _,n in {60,300,1800} do action("Time"..n,"DEFINIR TEMPO: "..n.."s",function() dev("time",n) end) end
   local box=Instance.new("TextBox") box.Name="CustomTime" box.PlaceholderText="Segundos personalizados (1–3600), Enter aplica" box.Text="" box.ClearTextOnFocus=false box.Size=UDim2.new(1,-4,0,46) box.TextColor3=white box.BackgroundColor3=Color3.fromRGB(29,45,59) box.Font=Enum.Font.Gotham box.TextSize=13 box.Parent=lists.Detail
   Nav:Register(box,function() box:CaptureFocus() end)
   hook(box.FocusLost,function(enter) if enter then local n=tonumber(box.Text) if n then n=math.clamp(n,1,3600) box.Text=tostring(n) dev("time",n) end end end)
   local snapshot=Bridge:Get() local options=snapshot and snapshot.session and snapshot.session.options or {}
   if Scope:IsArena() then for _,o in options do action("DevMap"..o.id,"CARREGAR: "..o.name,function() dev("map",o.id) end) end end
  end
 elseif id=="Surrender" then
  if Scope:IsCTF() then info("A votação de rendição por equipe será implementada futuramente.")
  elseif Scope:IsArena() then info("Arena é individual. Você pode encerrar sua participação voltando ao hub.") action("SurrenderConfirm","VOLTAR AO HUB",function() show(false) Bridge:Send("returnHub") end)
  elseif Scope:IsGetOut() then info("Você pode sair da partida de teste e voltar ao hub.") action("SurrenderConfirm","VOLTAR AO HUB",function() show(false) Bridge:Send("returnHub") end)
  else info("Você está no hub.") end
 elseif id=="Exit" then
  info(Scope:IsHub() and "Você já está no hub." or "Sair da modalidade atual e voltar ao hub?")
  if not Scope:IsHub() then action("ExitConfirm","CONFIRMAR SAÍDA",function() show(false) Bridge:Send("returnHub") end) end
 end
 lists.Detail.CanvasPosition=pageState[id] and pageState[id].scroll or Vector2.zero resize(true)
end
local siblingTabs=Instance.new("Frame") siblingTabs.Name="SiblingCategories" siblingTabs:SetAttribute("SettingsStyled",true) siblingTabs.BackgroundTransparency=1 siblingTabs.Parent=panes.Detail
local subtitle=label(panes.Detail,"Description","",UDim2.new(1,-36,0,25)) subtitle:SetAttribute("SettingsStyled",true) subtitle.TextColor3=Palette.Muted subtitle.TextSize=12 subtitle.Position=UDim2.fromOffset(18,49)
local categoryButtons={}
local function buildCategories(id)
 local target=id=="Options" and "Options" or "Categories"
 if id~="Options" then
  for _,child in lists.Categories:GetChildren() do if child:IsA("GuiButton") then child:Destroy() end end
  for group in categories do if group~="Options" then categoryButtons[group]=nil end end
 end
 for _,b in categoryButtons[id] or {} do b:Destroy() end categoryButtons[id]={}
 for _,item in categories[id] or {} do
  if (item[1]~="Development" or workspace:GetAttribute("DevelopmentToolsAvailable")) and (item[1]~="AdminMaps" or player:GetAttribute("CrossgroundsAdmin")==true) then
   local b=btn(lists[target],item[1],item[2].."  ›") table.insert(categoryButtons[id],b)
   Nav:Connect(b,function()
    if item[1]=="Progress" then show(false) player:SetAttribute("ProgressionMenuOpen",true)
    elseif categories[item[1]] then remember() category=item[1] page=item[1] buildCategories(item[1]) resize(true)
    else category=id render(item[1]) end
   end)
  end
 end
 panes[target].Back.Text="‹  "..(titles[id] or id)
end
local function chooseCategory(id)
 if not categoryButtons.Options then buildCategories("Options") end
 remember() category=id page=id buildCategories(id) resize(true)
end
resize=function(animate)
 bindingTabs.Visible=page=="Bindings"
 lists.Detail.Position=UDim2.fromOffset(8,page=="Bindings" and 86 or 52) lists.Detail.Size=UDim2.new(1,-16,1,page=="Bindings" and -94 or -60)
 for device,b in tabButtons do b.BackgroundColor3=device==bindingDevice and Theme.Colors.Selected or Theme.Colors.Button b:SetAttribute("MenuSelected",device==bindingDevice) end
 local v=shade.AbsoluteSize if v.X<200 or v.Y<150 then v=workspace.CurrentCamera.ViewportSize end
 local scale=get("MenuScale") local modifier=panel:FindFirstChild("PreferenceScale") or Instance.new("UIScale") modifier.Name="PreferenceScale" modifier.Scale=scale modifier.Parent=panel
 local w=math.min(1280,(v.X-24)/scale) local h=math.min(720,(v.Y-20)/scale) panel.Size=UDim2.fromOffset(w,h)
 for f,t in paneTweens do t:Cancel() paneTweens[f]=nil end
 local configActive=page~="Main" and not table.find({"Loadout","Exit","Surrender"},page)
 panel:SetAttribute("SettingsOverhaul",configActive)
 for _,f in panes do f:SetAttribute("SettingsOverhaul",configActive) end
 siblingTabs.Visible=configActive subtitle.Visible=configActive
 if configActive then
  local stack={"Main","Options"}
  if page=="Controls" or page=="Camera" or leafParent[page] then table.insert(stack,"Categories") end
  if not categories[page] then table.insert(stack,"Detail") end
  if not categoryButtons.Options then buildCategories("Options") end
  if leafParent[page] and not categoryButtons[leafParent[page]] then buildCategories(leafParent[page]) end
  local content=#stack local contextIndex=stack[content]=="Detail" and content-1 or content
  local rail=w<620 and 30 or 48 local gap=7
  local contextWidth=w<620 and 50 or math.clamp(w*.20,156,215)
  local used=0 panel:SetAttribute("CascadeDepth",#stack)
  for _,f in panes do f.Visible=false end
  for i,id in stack do
   local f=panes[id] f.Visible=true f.ZIndex=i f.Active=true
   local collapsed=i<contextIndex or w<620 and i==contextIndex and i<content
   local width=i==content and w-used or collapsed and rail or contextWidth
   local target=UDim2.fromOffset(used,40) local size=UDim2.fromOffset(width,h-78)
   if paneTweens[f] then paneTweens[f]:Cancel() paneTweens[f]=nil end
   Theme.CascadeDepth(f,0,false)
   if animate and not Theme.ReducedMotion() then local t=Tween:Create(f,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=target,Size=size}) paneTweens[f]=t t:Play() else f.Position=target f.Size=size end
   local back=f.Back back.Visible=id~="Main" back.Text=collapsed and "<" or "<  "..(id=="Detail" and titles[page] or id=="Categories" and titles[leafParent[page] or page] or "CONFIGURAÇÕES") back.TextSize=id=="Detail" and 20 or 15
   back.Position=UDim2.fromOffset(4,8) back.Size=UDim2.new(1,-8,0,36)
   lists[id].Position=UDim2.fromOffset(6,id=="Main" and 8 or 52) lists[id].Size=UDim2.new(1,-12,1,id=="Main" and -16 or -60)
   for _,button in lists[id]:GetChildren() do if button:IsA("TextButton") then
    if not button:GetAttribute("CompactRail") then button:SetAttribute("ExpandedText",button.Text) end
    local full=button:GetAttribute("ExpandedText") or button.Name
    button:SetAttribute("CompactRail",collapsed) button.Text=collapsed and "" or full button.TextTruncate=Enum.TextTruncate.None button.TextWrapped=true button.TextSize=14
    local icon=button:FindFirstChild("CategoryIcon") or Visual.Icon(button,button.Name,24)
    icon.Visible=id~="Detail" icon.Position=collapsed and UDim2.new(.5,-12,.5,-12) or UDim2.new(0,6,.5,-12)
    button.Size=UDim2.new(1,-2,0,collapsed and 46 or 58)
    local pad=button:FindFirstChildOfClass("UIPadding") if pad then pad.PaddingLeft=UDim.new(0,collapsed and 0 or id=="Detail" and 12 or 39) pad.PaddingRight=UDim.new(0,4) end
    local selected=id=="Main" and button.Name=="Options" or id=="Options" and button.Name==(leafParent[page] or page) or id=="Categories" and button.Name==page
    button:SetAttribute("MenuSelected",selected)
    local edge=button:FindFirstChild("AcrylicEdge") if edge then edge.Color=selected and Palette.Accent or Palette.Border edge.Thickness=selected and 2 or 1 edge.Transparency=selected and .1 or .7 end
   end end
   used+=width+gap
  end
  subtitle.Text=Visual.Descriptions[page] or "Personalize suas preferências."
  local detail=panes.Detail
  siblingTabs.Position=UDim2.fromOffset(10,78) siblingTabs.Size=UDim2.new(1,-20,0,34)
  for _,child in siblingTabs:GetChildren() do child:Destroy() end
  local group=leafParent[page] or "Options" local siblings={}
  for _,entry in categories[group] or {} do if entry[1]~="Progress" and (entry[1]~="Development" or workspace:GetAttribute("DevelopmentToolsAvailable")) and (entry[1]~="AdminMaps" or player:GetAttribute("CrossgroundsAdmin")==true) then table.insert(siblings,entry) end end
  for i,entry in siblings do
   local id=entry[1] local b=btn(siblingTabs,id,entry[2]) b.TextSize=11 b.TextTruncate=Enum.TextTruncate.AtEnd b.TextWrapped=false b.Size=UDim2.new(1/#siblings,-3,1,0) b.Position=UDim2.fromScale((i-1)/#siblings,0)
   b.TextColor3=id==page and Palette.Accent or Palette.Muted
   Nav:Connect(b,function() if categories[id] then chooseCategory(id) else category=group render(id) end end)
  end
  siblingTabs.Visible=stack[content]=="Detail" and #siblings<=5
  local top=siblingTabs.Visible and 120 or 78
  bindingTabs.Position=UDim2.fromOffset(8,top)
  lists.Detail.Position=UDim2.fromOffset(8,top+(page=="Bindings" and 36 or 0)) lists.Detail.Size=UDim2.new(1,-16,1,-top-(page=="Bindings" and 44 or 8))
 else
 local narrow=w<760
 local controlLeaf=leafParent[page]~=nil
 local simple=table.find({"Loadout","Exit","Surrender"},page)~=nil
 local stack={"Main"}
 if page~="Main" then
  if simple then table.insert(stack,"Detail")
  else
   table.insert(stack,"Options")
   if page=="Controls" or page=="Camera" or controlLeaf then table.insert(stack,"Categories") end
   if not categories[page] then table.insert(stack,"Detail") end
  end
 end
 if page~="Main" and not simple and not categoryButtons.Options then buildCategories("Options") end
 if controlLeaf and not categoryButtons[leafParent[page]] then buildCategories(leafParent[page]) end
 panel:SetAttribute("CascadeDepth",#stack)
 local preferred=190
 local step=preferred+8
 if step*(#stack-1)+340>w then step=math.max(24,(w-math.min(340,w-24*(#stack-1)))/math.max(1,#stack-1)) end
 for _,f in panes do f.Visible=false end
 for i,id in stack do
  local f=panes[id] f.Visible=not narrow or i==#stack f.Active=true f.ZIndex=i
  local x=narrow and 0 or (i-1)*step local y=narrow and 32 or 38+(i-1)*5
  local width=narrow and w or #stack==1 and math.min(w,240) or i==#stack and w-x or step-8
  f.Size=UDim2.fromOffset(width,narrow and h-54 or h-70-(i-1)*5)
  Theme.CascadeDepth(f,#stack-i,animate and not Theme.ReducedMotion())
  for _,b in lists[id]:GetChildren() do if b:IsA("TextButton") then b.TextWrapped=i==#stack b.TextTruncate=i==#stack and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd end end
  local target=UDim2.fromOffset(x,y)
  if animate and not Theme.ReducedMotion() then f.Position=target+UDim2.fromOffset(18,0) local t=Tween:Create(f,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=target}) paneTweens[f]=t t:Play() else f.Position=target end
 end
 end
 header.Text="CROSSGROUNDS  /  "..(page=="Main" and "PAUSA" or titles[page] or page)
 panes.Main.Back.Visible=false lists.Main.Position=UDim2.fromOffset(8,8) lists.Main.Size=UDim2.new(1,-16,1,-16)
 for _,b in mainButtons do b.Size=UDim2.new(1,-4,0,math.clamp((h-110)/5,48,62)) end
 if animate then
  local activeId=panes.Detail.Visible and "Detail" or panes.Categories.Visible and "Categories" or panes.Options.Visible and "Options" or "Main"
  local activeList=lists[activeId] local target=panes[activeId].Back
  for _,child in activeList:GetChildren() do if child:IsA("GuiButton") or child:IsA("Frame") and Settings.Rules[child.Name] then target=child break end end
  local saved=pageState[page] if saved and saved.focus and lists.Detail.Visible then target=lists.Detail:FindFirstChild(saved.focus) or target end
  if page=="Loadout" and activeLoadoutView then
   target=activeLoadoutView:DefaultFocus()
   task.delay(.08,function() if page=="Loadout" and shade.Visible and target.Parent then Nav:Focus(target) end end)
  else task.defer(function() if shade.Visible and target.Parent then Nav:Focus(target) end end) end
 end
 local nativeMenu=workspace:FindFirstChild("TopbarPlus") and player.PlayerGui:FindFirstChild("TopbarStandard")
 launch.Visible=not nativeMenu and not shade.Visible and not player:GetAttribute("HUDLayoutEditing")
end
show=function(on,id)
 shade.Visible=on player:SetAttribute("ExperienceMenuOpen",on)
 if not on then remember() end
 if on then status.Text="Analógico: cursor · D-pad: navegar / ajustar · X: valor · Y: padrão"
  local target=id or "Main"
  if target=="Main" then page="Main" resize(true)
  elseif categories[target] then chooseCategory(target)
  else render(target) end
 else resize(false) end
end
panes.Main.Back.Text="MENU"
for _,a in {{"Resume","Continuar"},{"Loadout","Loadout"},{"Options","Opções"},{"Surrender","Render-se"},{"Exit","Sair"}} do
 local b=btn(lists.Main,a[1],a[2]) mainButtons[a[1]]=b
 Nav:Connect(b,function() if a[1]=="Resume" then show(false) if Scope:IsHub() then Nav:OpenMenu("Resume") end elseif a[1]=="Progress" then show(false) player:SetAttribute("ProgressionMenuOpen",true) elseif a[1]=="Options" then chooseCategory("Options") elseif a[1]=="Loadout" and Scope:IsHub() then show(false) Nav:OpenMenu("Hub") else category="Main" render(a[1]) end end)
end
Nav:Connect(panes.Options.Back,function() page="Main" resize(true) end)
Nav:Connect(panes.Categories.Back,function() chooseCategory("Options") end)
Nav:Connect(panes.Detail.Back,function() if pendingConfirmation then local target=pendingConfirmation pendingConfirmation=nil render(target) return end if page=="Loadout" or page=="Exit" or page=="Surrender" then page="Main" resize(true) elseif leafParent[page] then chooseCategory(leafParent[page]) else chooseCategory("Options") end end)
Nav:Connect(panes.Main.Back,function() show(false) end)
-- Bumpers share gameplay shoulder/shift-lock inputs; the modal context owns them.
Nav:SetCategories(panel,function(step)
 if pendingConfirmation then return end
 if false then
  local devices={"Keyboard","Gamepad","Touch"}
  local index=table.find(devices,bindingDevice) or 1
  bindingDevice=devices[(index-1+step)%#devices+1] render("Bindings")
  Nav:Focus(tabButtons[bindingDevice])
  return
 end
 local group=leafParent[page] or (categories[page] and page~="Options" and page) or "Options"
 local entries=categories[group] or categories.Options local eligible={}
 for _,entry in entries do
  if (entry[1]~="Development" or workspace:GetAttribute("DevelopmentToolsAvailable"))
   and (entry[1]~="AdminMaps" or player:GetAttribute("CrossgroundsAdmin")==true)
   and entry[1]~="Progress" then table.insert(eligible,entry[1]) end
 end
 if #eligible==0 then return end
 local index=table.find(eligible,page) or table.find(eligible,category) or (step>0 and 0 or 1)
 local id=eligible[(index-1+step)%#eligible+1]
 if categories[id] then chooseCategory(id) else category=group render(id) end
 -- resize restores this category's last focus.
end)
Nav:SetBack(panel,function() if pendingConfirmation then local target=pendingConfirmation pendingConfirmation=nil render(target) return end remember() if page=="Main" then show(false) elseif categories[page] then if page~="Options" then chooseCategory("Options") else page="Main" resize(true) end else
 if leafParent[page] then chooseCategory(leafParent[page]) elseif table.find({"Loadout","Exit","Surrender"},page) then page="Main" resize(true) else chooseCategory("Options") end end end,mainButtons.Resume)
Nav:Connect(launch,function() show(true,"Main") end)
Nav.MenuRequested:Connect(function(id)
 if id=="Main" or id=="Pause" then show(true,"Main")
 elseif id=="Resume" then show(false)
 elseif id=="Settings" then show(true,"Options")
 elseif id=="Controls" then show(true,"Controls")
 elseif id=="HUDSettings" or id=="Maps" or id=="Loadout" then show(true,id)
 elseif id=="MobileHUD" or id=="Hub" or id=="ArenaVote" or id=="Progress" or id=="Playlist" then show(false) end
end)
Router:Register("Menu",function(s) if s==Enum.UserInputState.Begin then show(not shade.Visible,"Main") end end,{allowMenus=true})
Router:Register("VoteMenu",function(s) if s==Enum.UserInputState.Begin then if Scope:IsArena() then show(false) Nav:OpenMenu("ArenaVote") else show(true,"Maps") end end end,{allowMenus=true,scope="global"})
Router.CaptureChanged:Connect(function(active,message) status.Text=active and "PRESSIONE UM NOVO BOTÃO · 5s" or message end)
local function scopeLabels()
 mainButtons.Resume.Text=Scope:IsHub() and "Permanecer no lobby" or "Continuar"
 mainButtons.Loadout.Text=Scope:IsHub() and "Jogar / Modalidades" or "Loadout"
 if Scope:IsGetOut() then mainButtons.Loadout.Text="Papéis do Get Out" end
end
Scope.Changed:Connect(function() scopeLabels() show(false) end) scopeLabels()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() resize(false) end)
player:GetAttributeChangedSignal("SettingMenuScale"):Connect(function() resize(false) end)
shade:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() resize(false) end)
player:GetAttributeChangedSignal("HUDLayoutEditing"):Connect(function() resize(false) end)
player:SetAttribute("ExperienceMenuOpen",false) resize(false)

