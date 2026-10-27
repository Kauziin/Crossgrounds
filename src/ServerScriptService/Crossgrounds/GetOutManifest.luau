--!strict
-- Only hand-authored markers may make an imported map eligible for Get Out.
local Rules = require(game.ReplicatedStorage.Crossgrounds.GetOutRules)
local Manifest = {}

local function part(parent, name)
    local item = parent and parent:FindFirstChild(name)
    return item and item:IsA("BasePart") and item or nil
end

local function parts(parent, name, count)
    local folder = parent and parent:FindFirstChild(name)
    if not folder or not folder:IsA("Folder") then return nil end
    local found = {}
    local ids = {}
    for _, item in folder:GetChildren() do
        if not item:IsA("BasePart") then return nil end
        local id = item:GetAttribute("ObjectiveId")
        if typeof(id) ~= "string" or id == "" or ids[id] then return nil end
        ids[id] = true
        found[id] = item
    end
    if count and #folder:GetChildren() ~= count then return nil end
    if not next(found) then return nil end
    return found
end

local function doors(root, required)
    local exits = parts(root, "ExitDoors", required)
    local zones = parts(root, "ExitZones", required)
    if not exits or not zones then return nil end
    for id in exits do if not zones[id] then return nil end end
    return { doors = exits, zones = zones }
end

local validators = {}

function validators.locks(root)
    local pc = parts(root, "Computers", 4)
    local locks = parts(root, "Locks", 4)
    local exits = doors(root, 2)
    local cranks = parts(root, "Cranks", 2)
    local pods = parts(root, "FreezePods", nil)
    local panels = parts(root, "ContainmentPanels", 2)
    local chamber = part(root, "ContainmentChamber")
    local lever = part(root, "ContainmentLever")
    local containmentDoor = part(root, "ContainmentDoor")
    if not pc or not locks or not exits or not cranks or not pods or not panels
        or not chamber or not lever or not containmentDoor then return nil end
    for id in exits.doors do if not cranks[id] then return nil end end
    return { computers = pc, locks = locks, doors = exits.doors, zones = exits.zones,
        cranks = cranks, pods = pods, containmentPanels = panels,
        chamber = chamber, lever = lever, containmentDoor = containmentDoor }
end

function validators.vault_code(root)
    local pc = parts(root, "Computers", 4)
    local exits = doors(root, nil)
    local dial = part(root, "VaultDial")
    if not pc or not exits or not dial then return nil end
    local slots = {}
    for _, marker in pc do
        local slot, digit = marker:GetAttribute("DigitSlot"), marker:GetAttribute("Digit")
        if typeof(slot) ~= "number" or slot % 1 ~= 0 or slot < 1 or slot > 4 or slots[slot]
            or typeof(digit) ~= "number" or digit % 1 ~= 0 or digit < 0 or digit > 9 then return nil end
        slots[slot] = digit
    end
    return { computers = pc, doors = exits.doors, zones = exits.zones, dial = dial, slots = slots }
end

function validators.laser_shutdown(root)
    local panels = parts(root, "SecurityPanels", 4)
    local beams = parts(root, "LaserBeams", 4)
    local exits = doors(root, nil)
    if not panels or not beams or not exits then return nil end
    local linked = {}
    for _, panel in panels do
        local beamId = panel:GetAttribute("BeamId")
        if typeof(beamId) ~= "string" or not beams[beamId] or linked[beamId] then return nil end
        linked[beamId] = true
    end
    return { panels = panels, beams = beams, doors = exits.doors, zones = exits.zones }
end

local function resources(root, folderName)
    local items = parts(root, folderName, nil)
    local exits = doors(root, nil)
    local bench = part(root, "Workbench")
    local sealed = part(root, "SealedDoor")
    if not items or not exits or not bench or not sealed then return nil end
    return { items = items, doors = exits.doors, zones = exits.zones, bench = bench, sealedDoor = sealed }
end

function validators.thermal_tool(root) return resources(root, "ThermalParts") end
function validators.demolition(root) return resources(root, "DemolitionResources") end

function Manifest.Read(map)
    if not map or map:GetAttribute("Enabled") == false or map:GetAttribute("Sanitized") ~= true then
        return nil, "Mapa não preparado."
    end
    local root = map:FindFirstChild("GetOut")
    if not root or not root:IsA("Folder") or root:GetAttribute("Authored") ~= true then
        return nil, "Manifesto GetOut autorado ausente."
    end
    local beast = part(root, "BeastSpawn")
    local survivors = parts(root, "SurvivorSpawns", nil)
    if not beast or not survivors then return nil, "Spawns de papéis incompletos." end
    local declared = root:GetAttribute("SupportedRoutes")
    if typeof(declared) ~= "string" then return nil, "Rotas não declaradas." end
    local available, diagnostics = {}, {}
    for _, route in Rules.Routes do
        if string.find("," .. declared .. ",", "," .. route .. ",", 1, true) then
            local data = validators[route](root)
            if data then available[route] = data
            else table.insert(diagnostics, route .. ": marcadores incompletos ou IDs inválidos") end
        end
    end
    if not next(available) then return nil, "Nenhuma rota válida: " .. table.concat(diagnostics, "; ") end
    return { map = map, root = root, beastSpawn = beast, survivorSpawns = survivors, routes = available, diagnostics = diagnostics }
end

function Manifest.Choose(manifest, rng, implemented)
    local eligible = {}
    for _, route in Rules.Routes do
        if manifest.routes[route] and (not implemented or implemented[route]) then table.insert(eligible, route) end
    end
    if #eligible == 0 then return nil, "Nenhuma rota implementada e válida." end
    -- More than one route requires an explicitly supplied selection policy.
    -- The design has not approved uniform odds or map-specific weights yet.
    if #eligible > 1 and not rng then return nil, "Distribuição das rotas pendente." end
    local index = #eligible == 1 and 1 or rng:NextInteger(1, #eligible)
    return eligible[index], manifest.routes[eligible[index]]
end

return Manifest
