-- Server-owned permission list. Client attributes never authorize a command.
local Admin={}
local Players=game:GetService("Players")
local ALLOWED={[1248190494]=true}
function Admin:IsAuthorized(player) return ALLOWED[player.UserId]==true end
function Admin:Start(coordinator)
 if self.started then return end self.started=true
 local remote=Instance.new("RemoteFunction") remote.Name="AdminCamera" remote.Parent=game.ReplicatedStorage.Crossgrounds.Remotes
 local sessions={} local rates={} local busy={} local previews={}
 local terrainAreas={}
 local function clearTerrain(player)
  local region=terrainAreas[player] terrainAreas[player]=nil
  if region then workspace.Terrain:FillRegion(region,4,Enum.Material.Air) end
 end
 local publishWork=0 local disposeWork=0
 local function dispose(node)
  local count=#node:GetDescendants()+1
  if count>250 then for _,child in node:GetChildren() do dispose(child) end count=1 end
  node:Destroy() disposeWork+=count if disposeWork>=500 then disposeWork=0 task.wait() end
 end
 local function publish(node,parent)
  local count=#node:GetDescendants()+1
  if count>250 then
   local children=node:GetChildren() local primary=node:IsA("Model") and node.PrimaryPart local pivot=node:IsA("Model") and node.WorldPivot
   for _,child in children do child.Parent=nil end node.Parent=parent
   for _,child in children do publish(child,node) end
   if node:IsA("Model") then node.PrimaryPart=primary node.WorldPivot=pivot end
  else node.Parent=parent publishWork+=count end
  if publishWork>=500 then publishWork=0 task.wait() end
 end
 local function stop(player)
  local session=sessions[player] sessions[player]=nil
  if session and session.root.Parent then session.root.Anchored=session.anchored end
  player:SetAttribute("AdminFreecam",false)
  player:SetAttribute("AdminPhotoUnlimited",nil) clearTerrain(player)
  player:SetAttribute("AdminPhotoMap",nil)player:SetAttribute("AdminPhotoLightingProfile",nil)
  if previews[player] then local preview=previews[player] previews[player]=nil dispose(preview) end
 end
 local function added(player)
  player:SetAttribute("CrossgroundsAdmin",self:IsAuthorized(player))
  player:SetAttribute("AdminFreecam",false)
  player.CharacterAdded:Connect(function() stop(player) end)
  player:GetAttributeChangedSignal("CrossgroundsMode"):Connect(function()
   if player:GetAttribute("CrossgroundsMode")~="hub" then stop(player) end
  end)
 end
 remote.OnServerInvoke=function(player,enabled,mapId)
  if not self:IsAuthorized(player) then return false,"Sem permissão." end
  if enabled=="catalog" then return true,require(script.Parent.MapLibrary).PhotoCatalog() end
  if busy[player] or os.clock()-(rates[player] or -10)<.3 then return false,"Aguarde." end
  rates[player]=os.clock()
  if enabled=="preview" then
   if not sessions[player] then return false,"Ative a câmera livre primeiro." end
   local source,mode,id=require(script.Parent.MapLibrary).PhotoGet(mapId)
   if not source then return false,"Mapa indisponível." end
   local session=sessions[player]
   busy[player]=true
   local ok,result=pcall(function()
    clearTerrain(player)
    if previews[player] then dispose(previews[player]) previews[player]=nil end
    local preview=Instance.new("Model") preview.Name="AdminPhoto_"..player.UserId
    preview:SetAttribute("CrossgroundsAdminPhoto",true) preview:SetAttribute("MapId",mapId) preview.Parent=workspace previews[player]=preview
    local geometry=source.Geometry:Clone()
    local infrastructure=source:FindFirstChild("CTFInfrastructure")
    if infrastructure then infrastructure:Clone().Parent=geometry end
    local offset=Vector3.new(8192+session.slot*2048,512,0)
    for i,obj in geometry:GetDescendants() do
     if obj:IsA("LuaSourceContainer") then obj:Destroy()
     elseif obj:IsA("BasePart") then obj.CFrame+=offset obj.Anchored=true
     elseif obj:IsA("Sound") then obj.Playing=false end
     if i%500==0 then task.wait() end
    end
    publish(geometry,preview)
    if mode=="CTF" then
     local fallback=game.ServerStorage.CTFMaps:FindFirstChild("riverside")
     local terrainSource=source:FindFirstChild("TerrainData") and source or fallback
     local terrain=terrainSource and terrainSource:FindFirstChild("TerrainData")
     local origin=terrainSource and terrainSource:GetAttribute("TerrainOrigin")
     if terrain and terrain:IsA("TerrainRegion") and typeof(origin)=="Vector3" then
      local cell=origin+offset/4
      local minimum=Vector3.new(cell.X,cell.Y,cell.Z)*4
      local cells=terrain.SizeInCells
      terrainAreas[player]=Region3.new(minimum,minimum+Vector3.new(cells.X,cells.Y,cells.Z)*4):ExpandToGrid(4)
      workspace.Terrain:PasteRegion(terrain,Vector3int16.new(cell.X,cell.Y,cell.Z),true)
     end
    end
    if sessions[player]~=session then error("Sessão de captura encerrada.") end
    local cf,size=preview:GetBoundingBox()
    player:SetAttribute("AdminPhotoMap",mapId)player:SetAttribute("AdminPhotoLightingProfile",source:GetAttribute("LightingProfile")or mapId)
    return {name=source:GetAttribute("DisplayName") or mapId,focus=cf.Position,position=cf.Position+Vector3.new(.7,.8,1).Unit*math.max(size.X,size.Z,80)*1.1}
   end)
   busy[player]=nil
   if not ok then clearTerrain(player) if previews[player] then dispose(previews[player]) previews[player]=nil end warn(result) return false,"Falha ao preparar cópia para captura." end
   return true,result
  end
  if typeof(enabled)~="boolean" then return false,"Comando inválido." end
  if not enabled then stop(player) return true end
  if sessions[player] then return true end
  busy[player]=true
  local ok,result,message=pcall(function()
   if player:GetAttribute("CrossgroundsTransition") then return false,"Aguarde a transição atual." end
   if coordinator.context:GetMode(player)~="hub" then
    coordinator:Command(player,{action="returnHub"})
    local deadline=os.clock()+15
    repeat
     if not player.Parent then return false,"Sessão encerrada." end
     if coordinator.context:GetMode(player)=="hub" and not player:GetAttribute("CrossgroundsTransition") then break end
     task.wait(.1)
    until os.clock()>=deadline
   end
   if coordinator.context:GetMode(player)~="hub" or player:GetAttribute("CrossgroundsTransition") then return false,"Não foi possível sair da partida." end
   local queue=coordinator.queue:Get(player)
   if queue.state~="idle" then coordinator.queue:Clear(player) coordinator:Publish(player) end
   local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
   if not root or player:GetAttribute("ModeCharacterReady")~=true then return false,"Aguarde o personagem ficar pronto." end
   local used={} for _,session in sessions do used[session.slot]=true end
   local slot=1 while used[slot] do slot+=1 end
   if slot>50 then return false,"Todas as áreas de captura estão ocupadas." end
   sessions[player]={root=root,anchored=root.Anchored,slot=slot}
   player:SetAttribute("AdminPhotoUnlimited",true)
   root.AssemblyLinearVelocity=Vector3.zero root.Anchored=true
   player:SetAttribute("AdminFreecam",true)
   return true
  end)
  busy[player]=nil
  if not ok then stop(player) warn(result) return false,"Falha ao preparar câmera admin." end
  return result,message
 end
 Players.PlayerAdded:Connect(added)
 Players.PlayerRemoving:Connect(function(player) stop(player) rates[player]=nil busy[player]=nil end)
 for _,player in Players:GetPlayers() do added(player) end
end
return Admin

