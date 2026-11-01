-- One authority for menus, saved configurations and server-side construction.
local Compatibility = {Version = 2}
local cache = setmetatable({}, {__mode = 'k'})

local function contains(list, value)
	return typeof(list) == "table" and table.find(list, value) ~= nil
end

function Compatibility.Check(weapon, attachment)
	if not weapon or not attachment then return false, "Registro desconhecido." end
	local platform = weapon.platform
	if contains(attachment.blockedWeapons, weapon.id)
		or platform and contains(attachment.blockedPlatforms, platform) then
		return false, "Bloqueado para esta arma."
	end
	if attachment.pendingAudit or attachment.status ~= "Available"
		or attachment.auditStatus ~= "Verified" then
		return false, "Montagem pendente de verificação."
	end
	if not contains(weapon.slots, attachment.slot) then
		return false, "A arma não possui este slot."
	end
	local mount = weapon.mountPoints and weapon.mountPoints[attachment.slot]
	if not mount or mount ~= attachment.mountType then
		return false, "Ponto de montagem incompatível."
	end
	local mode = attachment.compatibilityMode
	if mode == "SpecificWeapon" then
		if not contains(attachment.compatibleWeapons, weapon.id) then return false, "Incompatível com esta arma." end
	elseif mode == "SpecificPlatform" then
		if not platform or not contains(attachment.compatiblePlatforms, platform) then return false, "Plataforma incompatível." end
	elseif mode == "Universal" then
		-- A shared rail alone is not evidence that the geometry clears this weapon.
		if not contains(attachment.verifiedMountWeapons, weapon.id) then return false, "Encaixe não verificado." end
	else
		return false, "Compatibilidade desconhecida."
	end
	return true
end

function Compatibility.Invalidate()
	Compatibility.Version += 1
	table.clear(cache)
end

function Compatibility.ForSlot(weapon, catalog, slot)
	local record = cache[weapon]
	if not record or record.version ~= Compatibility.Version or record.catalog ~= catalog then
		record = {version = Compatibility.Version, catalog = catalog, slots = {}}
		cache[weapon] = record
	end
	if not record.slots[slot] then
		local entries = {}
		for _,attachment in catalog do
			if attachment.slot == slot then
				local available,reason = Compatibility.Check(weapon,attachment)
				table.insert(entries,{attachment=attachment,available=available,reason=reason})
			end
		end
		table.sort(entries,function(a,b) return a.attachment.name < b.attachment.name end)
		record.slots[slot] = entries
	end
	return record.slots[slot]
end

return Compatibility
