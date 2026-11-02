return function(t)
 local root=game.ReplicatedStorage.Crossgrounds local S=require(root.WeaponStats) local C=require(root.WeaponVisualConfiguration)
 t.test("AR15 magazines preserve damage, accuracy and reserve while changing exact capacity",function()
  local base=S.Resolve("m4a1",{})
  for id,capacity in {magazines_ar15_pmag_10=10,magazines_ar15_pmag_40=40,magazines_ar15_surefire_60=60} do
   local d=assert(S.Resolve("m4a1",{magazine=id}))
   t.expect.equal(d.Magazine,capacity) t.expect.equal(d.Damage,base.Damage) t.expect.equal(d.Spread,base.Spread) t.expect.equal(d.Reserve,base.Reserve)
   t.expect.falsy(C.Validate("ax_50",{magazine=id},true))
  end
 end)
 t.test("loaded weight progressively reduces movement and ADS speed",function()
  local a=S.Resolve("m4a1",{magazine="magazines_ar15_pmag_10"}) local b=S.Resolve("m4a1",{magazine="magazines_ar15_pmag_40"}) local c=S.Resolve("m4a1",{magazine="magazines_ar15_surefire_60"})
  t.expect.truthy(a.MovementSpeedMultiplier>b.MovementSpeedMultiplier and b.MovementSpeedMultiplier>c.MovementSpeedMultiplier)
  t.expect.truthy(a.AdsSpeedMultiplier>b.AdsSpeedMultiplier and b.AdsSpeedMultiplier>c.AdsSpeedMultiplier)
 end)
end
