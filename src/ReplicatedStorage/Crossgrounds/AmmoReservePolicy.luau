-- Independent of WeaponCatalog: KitDefinitions is a dependency of that catalog.
local Policy={}
Policy.Reserves={assault=300,smg=240,shotgun=64,marksman=80,sniper=40,pistol=150,lmg=400,explosive=4,projectile=12,special=10}
Policy.Classes={
 assault={"Rifle","ak_47","an_94","as_val","cr_56_amax","fal","fr_5_56","grau_5_56","kilo_141","m13","m4a1","oden","ram_7","scar_h"},
 smg={"SMG","aug","fennec","iso","mp5","mp7","p90","pp_19_bizon","striker_45","uzi"},
 shotgun={"Shotgun725","SPAS12","725","jak_12","model_680","origin_12","r9_0"},
 marksman={"Sniper","ebr14","kar98k","mk2_carbine","simonov","sp_r_208"},
 sniper={"ax_50","dragunov","hdr","rytec_amr","barrett_m82"},
 pistol={"Pistol","Glock18","Luger","Beretta","m1911","magnum_357","x16","m19","desert_eagle","renetti","sykov"},
 lmg={"bruen_mk9","holger_26","m91","pkm","sa87"},
 explosive={"pila","rpg_7","strela_p","jokr","grenade_launcher"},
 projectile={"Blaster","AutoBlaster","crossbow"},
}
function Policy.Apply(weapons)
 local classes={}
 for class,ids in Policy.Classes do for _,id in ids do classes[id]=class end end
 for id,data in weapons do if data.Kind=="Gun" then
  local class=classes[id] or "special"
  data.AmmoClass=class
  data.Reserve=class=="projectile" and math.max(Policy.Reserves.projectile,data.Reserve or 0) or Policy.Reserves[class]
 end end
 if weapons.ArenaPistol then weapons.ArenaPistol.InfiniteReserve=true weapons.ArenaPistol.Reserve=0 end
end
return Policy
