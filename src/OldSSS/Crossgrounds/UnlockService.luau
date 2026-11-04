local Career=require(script.Parent.CareerService)
local P=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
local Catalog=require(game.ReplicatedStorage.Crossgrounds.UnlockCatalog)
local Config=require(game.ReplicatedStorage.Crossgrounds.WeaponVisualConfiguration)
local Service={}
function Service.Allows(player,mode,id,weapon)
 if mode=="ctf"and player:GetAttribute("CTFPracticeRange")==true and require(script.Parent.PracticeRangeService):IsActive(player)then return Catalog.Get(mode,id)~=nil,"Item indisponível."end
 if not Career.Enabled() then return true end
 local p=Career.Get(player) if not p then return false,"Aguarde o carregamento da carreira." end
 local item=Catalog.Get(mode,id,weapon) if not item then return false,"Item sem desbloqueio disponível." end
 if p.permanent[mode] and p.permanent[mode][id] then return true end
 if item.weaponLevel then
  local canonical=Catalog.Canonical(weapon or item.weaponId)
  return canonical~=nil and P.WeaponLevel(p.weapons[canonical] or 0)>=item.weaponLevel,"Requer nível "..item.weaponLevel.." da arma."
 end
 return p.accountUnlocked==true or P.Level(p.cycleXP,p.phase)>=item.level,"Requer nível "..item.level.." da conta."
end
function Service.Validate(player,loadout)
 for _,slot in {"primary","secondary"} do
  local id=loadout[slot.."WeaponId"] local ok,why=Service.Allows(player,"ctf",id)
  if not ok then return false,why end
  for _,attachment in loadout[slot.."Attachments"] or {} do
   local valid,err=Service.Allows(player,"ctf",attachment,id) if not valid then return false,err end
  end
 end
 return true
end
function Service.Resolve(player,loadout)
 if not Career.Enabled() then return loadout end
 local resolved=P.Copy(loadout or Config.Default(1))
 for _,slot in {"primary","secondary"} do
  if not Service.Allows(player,"ctf",resolved[slot.."WeaponId"]) then resolved[slot.."WeaponId"]=slot=="primary" and "m4a1" or "m1911" resolved[slot.."Attachments"]={} end
  for group,id in resolved[slot.."Attachments"] or {} do if not Service.Allows(player,"ctf",id,resolved[slot.."WeaponId"]) then resolved[slot.."Attachments"][group]=nil end end
 end
 return resolved
end
return Service
