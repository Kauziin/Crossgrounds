local Catalog=require(script.Parent.WeaponCatalog)
local NativeIrons=require(script.Parent.NativeIronReferences)
local Sights={Weapons={},Optics={}}
local Iron={levels={1.15},reticle="Iron",physical=true,hideWeapon=false}
Sights.Optics.optics_g_i_mini_reflex={levels={1.35},reticle="RedDot",physical=true,hideWeapon=false}
Sights.Telescopic={levels={4,8},reticle="MilDot",hideWeapon=true}
Sights.Weapons.ax_50={levels={4,8},reticle="MilDot",hideWeapon=false,physical=true}
Sights.Weapons.kar98k=Sights.Telescopic
function Sights.Get(id,optic,hasNativeIron)
 if optic and Sights.Optics[optic] then return Sights.Optics[optic] end
 if NativeIrons[id] and not optic and hasNativeIron~=false then return Iron end
 if id=="ax_50" and optic then return Sights.Telescopic end
 if Sights.Weapons[id] then return Sights.Weapons[id] end
 local entry=Catalog.Weapons[id]
 if id=="Sniper" or entry and entry.category=="SNIPER RIFLES" then return Sights.Telescopic end
end
function Sights.GetForTool(tool)
 local handle=tool:FindFirstChild("Handle")
 return Sights.Get(tool:GetAttribute("WeaponId"),tool:GetAttribute("OpticalAttachmentId"),
  handle~=nil and handle:FindFirstChild("IronRear")~=nil and handle:FindFirstChild("IronFront")~=nil)
end
function Sights.FOV(base,profile,level)
 local power=profile.levels[level] or profile.levels[1]
 return math.deg(2*math.atan(math.tan(math.rad(base*.5))/power))
end
return Sights
