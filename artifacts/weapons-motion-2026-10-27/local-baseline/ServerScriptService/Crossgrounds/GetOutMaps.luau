--!strict
local Library = require(script.Parent.MapLibrary)
local Manifest = require(script.Parent.GetOutManifest)
local Spawns = require(script.Parent.MapSpawns)
local SliceValidator = require(script.Parent.GetOutSliceValidator)
local Maps = {}
Maps.__index = Maps

function Maps.new()
    return setmetatable({ world = nil, manifest = nil, routeId = nil, mapId = nil }, Maps)
end

function Maps:Catalog(implemented)
    local out = {}
    for _, entry in Library.Catalog("GetOut") do
        local source = Library.Get("GetOut", entry.id)
        local manifest = source and Manifest.Read(source)
        if manifest and SliceValidator.Read(source,manifest) then
            for route in manifest.routes do
                if not implemented or implemented[route] then table.insert(out, entry) break end
            end
        end
    end
    return out
end

function Maps:Clear()
    if self.world then self.world:Destroy() end
    self.world = nil
    self.manifest = nil
    self.routeId = nil
    self.mapId = nil
    workspace:SetAttribute("GetOutMapId", nil)
end

function Maps:Load(id, selectionPolicy, implemented, canContinue)
    local source = Library.Get("GetOut", id)
    local sourceManifest, reason = Manifest.Read(source)
    if not sourceManifest then return false, reason end
    local valid,diagnostics=SliceValidator.Read(source,sourceManifest)
    if not valid then return false,table.concat(diagnostics,"; ") end
    local routeId, selectionReason = Manifest.Choose(sourceManifest, selectionPolicy, implemented)
    if not routeId then return false, selectionReason end
    self:Clear()
    local world = Instance.new("Model")
    world.Name = "CrossgroundsGetOutRound"
    world:SetAttribute("CrossgroundsOwned", true)
    world:SetAttribute("Sanitized", true)
    world.Parent = workspace
    self.world = world
    local geometry = Instance.new("Folder") geometry.Name = "Geometry" geometry.Parent = world
    for _, batch in source.Geometry:GetChildren() do
        if canContinue and not canContinue() then self:Clear() return false, "Carregamento interrompido." end
        batch:Clone().Parent = geometry
        task.wait()
    end
    sourceManifest.root:Clone().Parent = world
    local liveManifest, liveReason = Manifest.Read(world)
    if not liveManifest or not liveManifest.routes[routeId] then
        self:Clear() return false, liveReason or "Manifesto de rota inválido após a cópia."
    end
    if not Spawns.Validate(world, liveManifest.beastSpawn.CFrame) then
        self:Clear() return false, "Spawn da Besta bloqueado."
    end
    for _, spawn in liveManifest.survivorSpawns do
        if not Spawns.Validate(world, spawn.CFrame) then
            self:Clear() return false, "Spawn de sobrevivente bloqueado."
        end
    end
    self.manifest = liveManifest
    self.routeId = routeId
    self.mapId = id
    workspace:SetAttribute("GetOutMapId", id)
    return true, liveManifest, routeId, liveManifest.routes[routeId]
end

return Maps
