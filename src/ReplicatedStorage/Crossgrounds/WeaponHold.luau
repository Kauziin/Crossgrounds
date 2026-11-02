-- Shared pistol classification, including Arena cosmetics and MW catalog tools.
local Hold = {}
local pistols = {ArenaPistol=true, Pistol=true, Glock18=true, Luger=true, Beretta=true, m1911=true, magnum_357=true,
	x16=true, m19=true, desert_eagle=true, renetti=true, sykov=true}
function Hold.IsPistol(tool)
	return tool ~= nil and (pistols[tool:GetAttribute("WeaponId")] == true
		or pistols[tool:GetAttribute("VisualWeaponId")] == true)
end
function Hold.Mount(tool)
	if tool:GetAttribute("WeaponKind") == "Gun" then
		return Hold.IsPistol(tool) and CFrame.new(0,.12,-.7) or CFrame.new(0,.05,-.35)
	end
	return CFrame.new(-.25,.1,-.25)*CFrame.Angles(0,math.pi/2,0)
end
return Hold
