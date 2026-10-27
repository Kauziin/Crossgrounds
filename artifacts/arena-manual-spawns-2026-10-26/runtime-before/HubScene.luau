local Scene = {}
local ServerStorage = game:GetService("ServerStorage")
local function part(parent, name, size, cf, color, transparency)
 local p = Instance.new("Part")
 p.Name = name p.Size = size p.CFrame = cf p.Anchored = true
 p.Color = color p.Material = Enum.Material.SmoothPlastic
 p.Transparency = transparency or 0 p.Parent = parent
 return p
end
local function sign(parent, name, caption, cf, size)
 local board = part(parent, name, size, cf, Color3.fromRGB(18, 34, 49))
 board.CanCollide = false
 local surface = Instance.new("SurfaceGui")
 surface.Face = Enum.NormalId.Front surface.CanvasSize = Vector2.new(720, 220)
 surface.LightInfluence = 0 surface.Parent = board
 local text = Instance.new("TextLabel")
 text.Size = UDim2.fromScale(1, 1) text.BackgroundTransparency = 1
 text.Font = Enum.Font.GothamBold text.TextColor3 = Color3.fromRGB(231, 246, 255)
 text.TextScaled = true text.TextWrapped = true text.Text = caption text.Parent = surface
 return board
end
function Scene:Ensure()
 local existing = workspace:FindFirstChild("CrossgroundsPrototype")
 if existing and existing:FindFirstChild("LobbyWorld") and existing:FindFirstChild("Spawn") then return existing end
 if existing then assert(existing:GetAttribute("CrossgroundsOwned"),"Hub externo preservado; migração automática indisponível.") end
 local development = ServerStorage:FindFirstChild("Development")
 local sources = development and development:FindFirstChild("MapSources")
  or ServerStorage:FindFirstChild("CrossroadsSourceMaps") or ServerStorage:FindFirstChild("CrossgroundsMapSources")
 local lobby = sources and sources:FindFirstChild("Lobby")
 local source = lobby and lobby:FindFirstChild("Flee the Facility Lobby (Remake)")
 assert(source and source:IsA("Model"), "Mapa do lobby não encontrado em ServerStorage.")
 local folder = Instance.new("Folder")
 folder.Name = "CrossgroundsPrototype" folder:SetAttribute("CrossgroundsOwned", true)
 local world = source:Clone()
 world.Name = "LobbyWorld"
 world.Parent = folder
 local sourceSpawn = world:FindFirstChild("SpawnLocation", true) or world:FindFirstChild("LobbySpawnPad", true)
 assert(sourceSpawn and sourceSpawn:IsA("BasePart"), "Spawn do lobby não encontrado.")
 sourceSpawn.CanTouch = false
 if sourceSpawn:IsA("SpawnLocation") then sourceSpawn.Enabled = false end
 local spawn = part(folder, "Spawn", Vector3.new(8, 1, 8), sourceSpawn.CFrame, Color3.new(1,1,1), 1)
 spawn.CanCollide = false spawn.CanTouch = false
 local cave = world:FindFirstChild("LobbyCaveSpawnPadIn", true)
 if cave and cave:IsA("BasePart") then
  local center = cave.Position
  local platform = part(folder, "AFKPlatform", Vector3.new(22, .6, 22), CFrame.new(center + Vector3.new(0,-.6,0)), Color3.fromRGB(30,58,70))
  platform.Material = Enum.Material.WoodPlanks
  local zone = part(folder, "AFKZone", Vector3.new(22, 9, 22), CFrame.new(center + Vector3.new(0,4,0)), Color3.fromRGB(87,188,186), 1)
  zone.CanCollide = false zone.CanTouch = false zone.CanQuery = false
  sign(folder, "AFKSign", "ÁREA AFK\nDescanse aqui · sem recompensas por inatividade", CFrame.lookAt(center + Vector3.new(0,5,-10), center), Vector3.new(15,4,.3))
  local gate = part(folder, "AFKPortal", Vector3.new(5,.4,5), sourceSpawn.CFrame * CFrame.new(0,1,-9), Color3.fromRGB(48,158,160))
  gate.CanCollide = false
  local prompt = Instance.new("ProximityPrompt")
  prompt.ActionText = "Ir para área AFK" prompt.ObjectText = "Crossgrounds"
  prompt.HoldDuration = .4 prompt.MaxActivationDistance = 10 prompt.Parent = gate
  prompt.Triggered:Connect(function(player)
   if player:GetAttribute("CrossgroundsMode") == "hub" and player.Character then
    player.Character:PivotTo(CFrame.new(center + Vector3.new(0,4,0)))
   end
  end)
  local exit = part(folder, "AFKReturn", Vector3.new(5,.4,5), CFrame.new(center + Vector3.new(0,.5,8)), Color3.fromRGB(67,115,166))
  exit.CanCollide = false
  local back = Instance.new("ProximityPrompt")
  back.ActionText = "Voltar ao lobby" back.ObjectText = "Crossgrounds"
  back.HoldDuration = .4 back.MaxActivationDistance = 10 back.Parent = exit
  back.Triggered:Connect(function(player)
   if player:GetAttribute("CrossgroundsMode") == "hub" and player.Character then
    player.Character:PivotTo(CFrame.new(spawn.Position + Vector3.new(0,4,0)))
   end
  end)
 end
 -- Keep the former owned prototype intact and recoverable.
 if existing then
  local development=ServerStorage:FindFirstChild("Development") or Instance.new("Folder") development.Name="Development" development.Parent=ServerStorage
  local revisions=development:FindFirstChild("Revisions") or Instance.new("Folder") revisions.Name="Revisions" revisions.Parent=development
  local archives=revisions:FindFirstChild("Hub") or Instance.new("Folder") archives.Name="Hub" archives.Parent=revisions
  existing.Name="CrossgroundsPrototype_"..os.time().."_"..#archives:GetChildren()
  existing.Parent=archives
 end
 world.Parent=nil folder.Parent=workspace
 local inserted=0
 local function mount(parent,child)
  local count=#child:GetDescendants()
  if count>400 then
   local children=child:GetChildren() local primary=child:IsA("Model") and child.PrimaryPart
   for _,v in children do v.Parent=nil end
   child.Parent=parent
   for _,v in children do mount(child,v) end
   if primary then child.PrimaryPart=primary end
  else child.Parent=parent inserted+=count+1 end
  if inserted>=300 then inserted=0 task.wait() end
 end
 mount(folder,world)
 return folder
end
return Scene
