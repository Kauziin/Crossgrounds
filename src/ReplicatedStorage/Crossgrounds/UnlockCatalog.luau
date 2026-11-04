-- Stable requirements: adding an item never moves an existing item's level.
local Weapons=require(script.Parent.WeaponCatalog)
local Attachments=require(script.Parent.AttachmentCatalog)
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Finishes=require(script.Parent.WeaponFinishCatalog)
local AttachmentLevels=require(script.Parent.WeaponAttachmentLevels)
local C={}
function C.FinishWeapon(mode,id)
 if mode=="ctf"then for _,w in Weapons.Weapons do if w.combatId==id and Kits.Weapons[id]and Kits.Weapons[id].Kind=="Gun"then return true end end
 elseif mode=="arena"then for _,visual in Kits.ArenaPistolVisuals do if Kits.ArenaGunId(visual)==id then return true end end end
 return false
end
-- Initial curated track; every account level offers at least one Conflict weapon.
-- Add new IDs explicitly without shifting already assigned requirements.
local fixed={
 m4a1=1,m1911=1,legacy_Beretta=2,model_680=3,kilo_141=4,x16=5,legacy_Rifle=6,
 mp5=7,ebr14=8,legacy_Luger=9,mp7=10,m19=11,ak_47=12,legacy_SMG=13,uzi=14,
 legacy_Sniper=15,fal=16,sa87=17,aug=18,origin_12=19,magnum_357=20,p90=21,
 simonov=22,legacy_SPAS12=23,m13=24,fr_5_56=25,pkm=26,dragunov=27,
 pp_19_bizon=28,legacy_Glock18=29,r9_0=30,oden=31,scar_h=32,iso=33,
 mk2_carbine=34,m91=35,hdr=36,legacy_Shotgun725=37,cr_56_amax=38,renetti=39,
 striker_45=40,kar98k=41,holger_26=42,desert_eagle=43,ram_7=44,legacy_Blaster=44,
 an_94=45,sp_r_208=46,grau_5_56=47,bruen_mk9=48,fennec=49,jak_12=50,
 as_val=51,legacy_AutoBlaster=51,sykov=52,rytec_amr=53,["725"]=54,ax_50=55,
}
local arenaLevels={M1911=1,Luger=4,Beretta=8,m1911=12,Magnum=16,x16=20,Glock18=24,m19=28,DesertEagle=32,magnum_357=36,renetti=42,desert_eagle=48,sykov=55}
function C.Get(mode,item,weaponId)
 local weapon,finish=Finishes.Parse(item)if weapon then if C.FinishWeapon(mode,weapon)then return {id=item,name=Finishes.Items[finish].name.." · "..weapon,kind="finish",weaponLevel=Finishes.Items[finish].level,weaponId=weapon}end return end
 if mode=="ctf" then
  local w=Weapons.Get(item)
  if w and w.combatId then return {id=item,name=w.name or item,kind="weapon",level=fixed[item] or 55,weaponId=item} end
  local a=Attachments[item]
  if a and (a.status=="Available" or a.status=="VisualAdapter") then
   local track=AttachmentLevels[weaponId]
   local level=track and track[item] or ({optic=5,underbarrel=8,muzzle=12,magazine=15,barrel=20})[a.slot] or 10
   return {id=item,name=a.name or item,kind="attachment",weaponLevel=level}
  end
 elseif mode=="arena" and Kits:IsPistolVisual(item) then
  return {id=item,name=Kits.ArenaPistolNames[item] or item,kind="appearance",level=arenaLevels[item] or 55}
 end
end
function C.List(mode)
 local rows={}
 if mode=="ctf" then
  for id in Weapons.Weapons do local item=C.Get(mode,id) if item then table.insert(rows,item) end end
  for id in Attachments do local item=C.Get(mode,id) if item and item.kind=="attachment" then table.insert(rows,item) end end
 elseif mode=="arena" then for _,id in Kits.ArenaPistolVisuals do table.insert(rows,C.Get(mode,id)) end end
 local seen={}for _,row in table.clone(rows)do local weapon=C.Canonical(row.weaponId or row.id)
  if weapon and not seen[weapon]and C.FinishWeapon(mode,weapon)then seen[weapon]=true for id in Finishes.Items do if id~="default"then table.insert(rows,C.Get(mode,Finishes.TokenId(weapon,id)))end end end
 end
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
