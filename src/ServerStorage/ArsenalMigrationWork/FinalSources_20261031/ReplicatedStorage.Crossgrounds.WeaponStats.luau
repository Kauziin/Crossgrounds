local Catalog=require(script.Parent.WeaponCatalog) local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Stats={statsSchemaVersion=1}
function Stats.Get(id)
 local weapon=Catalog.Get(id) local data=weapon and weapon.combatId and Kits.Weapons[weapon.combatId]
 if not data then return {statsSchemaVersion=1,provisional=true,baseStats={},attachmentStatIntent={},effectiveGameplayStats={}} end
 local values={damage=data.Damage,range=data.Range,spreadDegrees=data.Spread,rpm=60/data.Cooldown,capacity=data.Magazine,reloadSeconds=data.ReloadTime}
 return {statsSchemaVersion=1,provisional=true,baseStats=table.clone(values),attachmentStatIntent={},effectiveGameplayStats=values,combatId=weapon.combatId}
end
function Stats.Compare(current,candidate)
 local a,b=Stats.Get(current).baseStats,Stats.Get(candidate).baseStats local result={}
 for key,value in b do if typeof(value)=="number" and typeof(a[key])=="number" then result[key]={current=a[key],candidate=value,delta=value-a[key]} end end
 return result
end
return Stats
