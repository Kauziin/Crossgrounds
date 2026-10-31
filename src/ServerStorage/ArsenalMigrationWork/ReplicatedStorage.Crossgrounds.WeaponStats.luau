local Catalog=require(script.Parent.WeaponCatalog) local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Stats={statsSchemaVersion=1}
function Stats.Get(id)
 local weapon=Catalog.Get(id) local data=weapon and weapon.combatId and Kits.Weapons[weapon.combatId]
 if not data then return {statsSchemaVersion=1,provisional=true,baseStats={},attachmentStatIntent={},effectiveGameplayStats={}} end
 local values={damage=data.Damage,range=data.Range,spreadDegrees=data.Spread,rpm=60/data.Cooldown,capacity=data.Magazine,reloadSeconds=data.ReloadTime}
 return {statsSchemaVersion=1,provisional=true,baseStats=table.clone(values),attachmentStatIntent={},effectiveGameplayStats=values,combatId=weapon.combatId}
end
return Stats
