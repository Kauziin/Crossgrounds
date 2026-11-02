local Career=require(script.Parent.CareerService)
local P=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
local Catalog=require(game.ReplicatedStorage.Crossgrounds.WeaponFinishCatalog)
local Visual=require(game.ReplicatedStorage.Crossgrounds.WeaponFinishVisual)
local Service={}
function Service.Apply(tool,player)
 local profile=Career.Get(player)if not profile then return end
 local id=tool:GetAttribute("WeaponId")local mode=player:GetAttribute("CrossgroundsMode")=="arena"and"arena"or"ctf"
 local finish=profile.weaponFinishes and profile.weaponFinishes[id]or"default"
 if not Catalog.Allows(profile,id,finish,mode,P.WeaponLevel(profile.weapons[id]))then finish="default"end
 Visual.Apply(tool,finish)
end
return Service
