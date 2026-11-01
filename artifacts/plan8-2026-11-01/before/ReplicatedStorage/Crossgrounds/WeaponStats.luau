local Effects=require(script.Parent.AttachmentEffects)
local Root = script.Parent

local Catalog = require(Root.WeaponCatalog)
local Attachments = require(Root.AttachmentCatalog)
local Config = require(Root.WeaponVisualConfiguration)
local Kits = require(game.ReplicatedStorage.KitDefinitions)
local Http = game:GetService("HttpService")

local Stats = {statsSchemaVersion = 1}
local cache = setmetatable({}, {__mode = "k"})

local numericFields = {
	Damage = true,
	MinDamage = true,
	Range = true,
	FalloffStart = true,
	FalloffEnd = true,
	ProjectileSpeed = true,
	AdsSpeedMultiplier = true,
	MovementSpeedMultiplier = true,
	Cooldown = true,
	Magazine = true,
	Reserve = true,
	ReloadTime = true,
	Spread = true,
}

local vectorFields = {
	CameraRecoilMin = true,
	CameraRecoilMax = true,
}

local function finite(value)
	return typeof(value) == "number"
		and value == value
		and math.abs(value) < 1000000
end

-- Calcula os atributos de uma arma com acessórios.
function Stats.Resolve(weaponId, configuration)
	local weapon = Catalog.Get(weaponId)
	local base = weapon and Kits.Weapons[weapon.combatId]

	if not base then
		return nil
	end

	local clean = Config.Validate(
		weaponId,
		configuration or {},
		true
	)

	if not clean then
		return nil
	end

	local data = table.clone(base)
	data.AdsSpeedMultiplier = 1
	data.MovementSpeedMultiplier = 1

	for _, attachmentId in clean do
		local attachment = Attachments[attachmentId]

		for field, factor in attachment.statMultipliers or {} do
			local value = data[field]

			if field == "VisualRecoil"
				and typeof(factor) == "table"
				and typeof(value) == "table" then
				local recoil = table.clone(value)
				for recoilField, recoilFactor in factor do
					if finite(recoilFactor)
						and recoilFactor > 0
						and finite(recoil[recoilField]) then
						recoil[recoilField] *= recoilFactor
					end
				end
				data.VisualRecoil = recoil

			elseif finite(factor) and factor > 0 then
				if numericFields[field] and finite(value) then
					data[field] = value * factor

				elseif vectorFields[field]
					and typeof(value) == "Vector2" then
					data[field] = value * factor
				end
			end
		end

		for field, amount in attachment.statAdd or {} do
			local value = data[field]

			if numericFields[field]
				and finite(value)
				and finite(amount) then
				data[field] = value + amount
			end
		end
	end

	-- Proteções para valores utilizados no combate.
	data.Cooldown = math.max(0.03, data.Cooldown)
	data.Magazine = math.max(1, math.floor(data.Magazine + 0.5))
	data.Reserve = math.max(0, math.floor(data.Reserve + 0.5))
	data.ReloadTime = math.max(0.1, data.ReloadTime)
	data.Range = math.max(1, data.Range)
	data.Spread = math.max(0, data.Spread)
	data.Damage = math.max(0, data.Damage)

	if data.MinDamage then
		data.MinDamage = math.clamp(
			data.MinDamage, 0, data.Damage
		)
	end

	return data
end

-- Obtém os atributos da Tool real.
-- Também funciona com armas sem acessórios.
function Stats.ResolveTool(tool)
	if not tool then
		return nil
	end

	local id = tool:GetAttribute("WeaponId")
	local visualId = tool:GetAttribute("VisualWeaponId")
	local raw = tool:GetAttribute("VisualConfiguration") or ""

	local old = cache[tool]

	if old
		and old.id == id
		and old.visualId == visualId
		and old.raw == raw then
		return old.data
	end

	local data = Kits.Weapons[id]

	if data and typeof(visualId) == "string" then
		local weapon = Catalog.Get(visualId)

		if weapon and weapon.combatId == id then
			local ok, configuration = pcall(
				Http.JSONDecode, Http, raw
			)

			if ok and typeof(configuration) == "table" then
				data = Stats.Resolve(visualId, configuration) or data
			end
		end
	end

	cache[tool] = {
		id = id,
		visualId = visualId,
		raw = raw,
		data = data,
	}

	return data
end

local function visible(data)
	return {
		damage = data.Damage,
		range = data.Range,
		spreadDegrees = data.Spread,
		rpm = data.Cooldown and 60 / data.Cooldown,
		capacity = data.Magazine,
		reloadSeconds = data.ReloadTime,
	}
end

-- Mantém compatibilidade com os menus existentes.
function Stats.Get(id, configuration)
	local weapon = Catalog.Get(id)
	local base = weapon and Kits.Weapons[weapon.combatId]

	if not base then
		return {
			statsSchemaVersion = 1,
			provisional = true,
			baseStats = {},
			attachmentStatIntent = {},
			effectiveGameplayStats = {},
		}
	end

	local effective = Stats.Resolve(id, configuration or {}) or base

	return {
		statsSchemaVersion = 1,
		provisional = true,
		baseStats = visible(base),
		attachmentStatIntent = {},
		effectiveGameplayStats = visible(effective),
		combatId = weapon.combatId,
	}
end

function Stats.Compare(current, candidate)
	local a = Stats.Get(current).baseStats
	local b = Stats.Get(candidate).baseStats
	local result = {}

	for key, value in b do
		if typeof(value) == "number"
			and typeof(a[key]) == "number" then
			result[key] = {
				current = a[key],
				candidate = value,
				delta = value - a[key],
			}
		end
	end

	return result
end

return Stats