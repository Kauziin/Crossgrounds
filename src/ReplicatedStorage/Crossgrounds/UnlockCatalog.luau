-- Stable requirements: adding an item never moves an existing item's level.
local Weapons=require(script.Parent.WeaponCatalog)
local Attachments=require(script.Parent.AttachmentCatalog)
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local C={}
local fixed={m4a1=1,m1911=1,ak_47=12,fal=16,ax_50=55,mp5=7,mp7=10,aug=18,m13=24,scar=32,cr_56_amax=38}
local function hash(id)
 local n=0 for i=1,#id do n=(n*31+id:byte(i))%65521 end return n
end
function C.Get(mode,item)
 if mode=="ctf" then
  local w=Weapons.Get(item)
  if w and w.combatId then return {id=item,name=w.name or item,kind="weapon",level=fixed[item] or (2+hash(item)%54),weaponId=item} end
  local a=Attachments[item]
  if a and (a.status=="Available" or a.status=="VisualAdapter") then return {id=item,name=a.name or item,kind="attachment",weaponLevel=({optic=5,underbarrel=8,muzzle=12,magazine=15,barrel=20})[a.slot] or 10} end
 elseif mode=="arena" and Kits:IsPistolVisual(item) then
  return {id=item,name=Kits.ArenaPistolNames[item] or item,kind="appearance",level=item==Kits.ArenaPistolVisuals[1] and 1 or 2+hash(item)%54}
 end
end
function C.List(mode)
 local rows={}
 if mode=="ctf" then
  for id in Weapons.Weapons do local item=C.Get(mode,id) if item then table.insert(rows,item) end end
  for id in Attachments do local item=C.Get(mode,id) if item and item.kind=="attachment" then table.insert(rows,item) end end
 elseif mode=="arena" then for _,id in Kits.ArenaPistolVisuals do table.insert(rows,C.Get(mode,id)) end end
 table.sort(rows,function(a,b) local x,y=a.level or a.weaponLevel,b.level or b.weaponLevel return x==y and a.id<b.id or x<y end)
 return rows
end
function C.Canonical(id)
 if type(id)~="string" then return end
 local w=Weapons.Get(id)
 if w and w.combatId then return w.combatId end
 if Kits.Weapons[id] then return id end
end
return C
