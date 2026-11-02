return function(t)
 local root=game.ReplicatedStorage.Crossgrounds
 local Stats=require(root.WeaponStats)
 local Config=require(root.WeaponVisualConfiguration)
 local CameraMotion=require(root.CameraMotion)
 t.test("AX50 magazine capacities and penalties preserve ballistics",function()
  local base=Stats.Resolve("ax_50",{})
  for id,capacity in {magazines_7rnd_50_bmg_magazine=7,magazines_9rnd_50_bmg_magazine=9} do
   local data=assert(Stats.Resolve("ax_50",{magazine=id}))
   t.expect.equal(data.Magazine,capacity)
   for _,field in {"Damage","MinDamage","Cooldown","Spread","Reserve","ProjectileSpeed"} do t.expect.equal(data[field],base[field]) end
   t.expect.truthy(data.MovementSpeedMultiplier<1 and data.AdsSpeedMultiplier<1 and data.ReloadTime>base.ReloadTime)
   t.expect.falsy(Config.Validate("m4a1",{magazine=id},true))
  end
  local seven=Stats.Resolve("ax_50",{magazine="magazines_7rnd_50_bmg_magazine"})
  local nine=Stats.Resolve("ax_50",{magazine="magazines_9rnd_50_bmg_magazine"})
  t.expect.truthy(nine.MovementSpeedMultiplier<seven.MovementSpeedMultiplier and nine.AdsSpeedMultiplier<seven.AdsSpeedMultiplier and nine.ReloadTime>seven.ReloadTime)
 end)
 t.test("stock composes with magazine without modifying firing recoil",function()
  local base=Stats.Resolve("ax_50",{})
  local data=assert(Stats.Resolve("ax_50",{stock="model_forge_tac_hunter",magazine="magazines_9rnd_50_bmg_magazine"}))
  t.expect.equal(data.Magazine,9) t.expect.equal(data.AdsMotionMultiplier,.4)
  t.expect.equal(data.VisualRecoil,base.VisualRecoil)
  t.expect.truthy(math.abs(data.MovementSpeedMultiplier-.9212)<1e-6 and math.abs(data.AdsSpeedMultiplier-.81)<1e-6)
  t.expect.falsy(Config.Validate("hdr",{stock="model_forge_tac_hunter"},true))
 end)
 t.test("stability reduces camera bob only while ADS at 30 60 120 FPS",function()
  for _,fps in {30,60,120} do
   for _,aiming in {false,true} do
    local base,stock=CameraMotion.new(),CameraMotion.new()
    for _=1,fps do
     local a,ar,ap=base:Update(1/fps,Vector3.new(4,0,-8),true,false,aiming,1,.4)
     local b,br,bp=stock:Update(1/fps,Vector3.new(4,0,-8),true,false,aiming,1,.4,.4)
     local factor=aiming and .4 or 1
     t.expect.truthy((b-a*factor).Magnitude<1e-6 and math.abs(br-ar*factor)<1e-6 and math.abs(bp-ap*factor)<1e-6)
    end
   end
  end
 end)
end
