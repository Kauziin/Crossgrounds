return function(t)
 local R=game.ReplicatedStorage.Crossgrounds
 local G=require(R.SMGGunsmith) local C=require(R.WeaponCatalog)
 local A=require(R.AttachmentCatalog) local K=require(R.AttachmentCompatibility)
 local S=require(R.WeaponStats) local Config=require(R.WeaponVisualConfiguration)
 t.test("all nine SMGs have common optics muzzle and laser with validated compatibility",function()
  t.expect.equal(#G.Ids,9)
  for _,id in G.Ids do
   local w=C.Get(id) t.expect.truthy(w.combatId)
   for _,aid in {"optics_g_i_mini_reflex","suppressors_monolithic_suppressor","lasers_tac_laser"} do
    t.expect.truthy(K.Check(w,A[aid]))
   end
   t.expect.equal(S.Resolve(id,{}).Reserve,240)
  end
 end)
 t.test("dedicated magazine capacities preserve damage and reject cross-weapon insertion",function()
  for _,v in G.Variants do if v.slot=="magazine" then
   local base=S.Resolve(v.weapon,{}) local d=assert(S.Resolve(v.weapon,{magazine=v.id}))
   t.expect.equal(d.Magazine,v.capacity) t.expect.equal(d.Damage,base.Damage) t.expect.equal(d.Reserve,base.Reserve)
   t.expect.falsy(Config.Validate("pp_19_bizon",{magazine=v.id},true))
  end end
  t.expect.falsy(table.find(C.Get("pp_19_bizon").slots,"magazine"))
 end)
 t.test("existing M4 AX50 and AUG conversion contracts remain available",function()
  t.expect.truthy(K.Check(C.Get("m4a1"),A.foregrips_commando_foregrip))
  t.expect.truthy(K.Check(C.Get("ax_50"),A.model_forge_tac_hunter))
  t.expect.truthy(K.Check(C.Get("aug"),A.aug_burst_conversion))
 end)
end
