return function(t)
 local root=game.ReplicatedStorage.Crossgrounds
 local S=require(root.WeaponStats) local V=require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals)
 local C=require(root.WeaponVisualConfiguration)
 t.test("magazine overrides keep reserve and damage invariant",function()
  local base=S.Resolve("m4a1",{})
  for id,capacity in {magazines_20rnd_5_56x45mm_normal_magazine=20,magazines_30rnd_5_56x45mm_nato_magazine_kilo=30,magazines_30rnd_5_56x45mm_holger_magazine=30} do
   local d=assert(S.Resolve("m4a1",{magazine=id}))
   t.expect.equal(d.Magazine,capacity) t.expect.equal(d.Reserve,base.Reserve) t.expect.equal(d.Damage,base.Damage)
  end
 end)
 t.test("heavy stability trades range against extended",function()
  local h=S.Resolve("ax_50",{barrel="barrels_ax_50_heavy"}) local e=S.Resolve("ax_50",{barrel="barrels_ax_50_extended"})
  t.expect.truthy(h.Range<e.Range and h.Spread<e.Spread and h.VisualRecoil.Roll<e.VisualRecoil.Roll)
 end)
 t.test("M4 magazines cannot be equipped on AX50",function()
  t.expect.falsy(C.Validate("ax_50",{magazine="magazines_20rnd_5_56x45mm_normal_magazine"},true))
 end)
 t.test("extended and heavy preserve a single dependent muzzle reference",function()
  for _,id in {"barrels_ax_50_extended","barrels_ax_50_heavy"} do
   local m=assert(V.Build("ax_50",{barrel=id,muzzle="suppressors_colossus_suppressor"}))
   t.expect.truthy((m.Handle.Muzzle.Position-m.Handle.muzzle.Position).Magnitude<.001)
   t.expect.truthy(m.Handle.Muzzle.Position.Z < -9)
   m:Destroy()
  end
 end)
end
