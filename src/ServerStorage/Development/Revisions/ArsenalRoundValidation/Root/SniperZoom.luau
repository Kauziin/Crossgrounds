local Catalog=require(script.Parent.WeaponCatalog)
local Zoom={}
function Zoom.IsSniper(id)
 local entry=Catalog.Weapons[id]
 return id=="Sniper" or entry~=nil and entry.category=="SNIPER RIFLES"
end
function Zoom.FOV(base,id,level)
 if not Zoom.IsSniper(id) then return base*58/70 end
 local magnification=level==2 and 8 or 4
 return math.deg(2*math.atan(math.tan(math.rad(base*.5))/magnification))
end
return Zoom
