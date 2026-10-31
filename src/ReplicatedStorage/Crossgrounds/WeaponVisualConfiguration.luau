local Catalog=require(script.Parent.WeaponCatalog)
local Attachments=require(script.Parent.AttachmentCatalog)
local Config={MaxAttachments=5}
function Config.Validate(id,value,playable)
 local weapon=Catalog.Get(id)
 if not weapon or playable and not weapon.combatId or typeof(value)~="table" then return nil,"Arma indisponível." end
 local clean={} local count=0
 for slot,attachmentId in value do
  count+=1 if count>Config.MaxAttachments or typeof(slot)~="string" or typeof(attachmentId)~="string" then return nil,"Configuração inválida." end
  local a=Attachments[attachmentId]
  if not a or a.status~="Available" or a.slot~=slot or not table.find(a.compatible or {},id) or not table.find(weapon.slots,slot) then return nil,"Acessório incompatível." end
  clean[slot]=attachmentId
 end
 return clean
end
function Config.Loadout(value)
 if typeof(value)~="table" or typeof(value.name)~="string" or #value.name==0 or #value.name>80 or not utf8.len(value.name) or utf8.len(value.name)>32 or value.name:find("%c") then return nil,"Nome inválido." end
 local primary=Catalog.Get(value.primaryWeaponId) local secondary=Catalog.Get(value.secondaryWeaponId)
 if not primary or primary.category=="PISTOLS" or not secondary or secondary.category~="PISTOLS" then return nil,"Escolha uma primária e uma pistola." end
 local p,err=Config.Validate(primary.id,value.primaryAttachments or {},true) if not p then return nil,err end
 local s,why=Config.Validate(secondary.id,value.secondaryAttachments or {},true) if not s then return nil,why end
 local melee=value.meleeWeaponId or "Sword" local data=require(game.ReplicatedStorage.KitDefinitions).Weapons[melee]
 if not data or data.Kind=="Gun" then return nil,"Corpo a corpo inválido." end
 return {name=value.name,primaryWeaponId=primary.id,secondaryWeaponId=secondary.id,meleeWeaponId=melee,primaryAttachments=p,secondaryAttachments=s}
end
function Config.Default(index) return {name="Loadout "..index,primaryWeaponId="m4a1",secondaryWeaponId="m1911",meleeWeaponId="Sword",primaryAttachments={},secondaryAttachments={}} end
return Config
