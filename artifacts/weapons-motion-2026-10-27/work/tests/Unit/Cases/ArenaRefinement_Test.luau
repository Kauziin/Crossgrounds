return function(t)
 local Kits=require(game.ReplicatedStorage.KitDefinitions)
 local Loadout=require(game.ReplicatedStorage.Crossgrounds.LoadoutDefinitions)
 local Reload=require(game.ReplicatedStorage.Crossgrounds.WeaponReloadMotion)
 local Standings=require(game.ReplicatedStorage.Crossgrounds.Standings)
 t.test("Arena round, reload and cooldown are configured independently from CTF",function()
  t.expect.equal(require(game.ReplicatedStorage.Crossgrounds.ArenaDefinitions).RoundDuration,300)
  t.expect.equal(Kits.Weapons.ArenaPistol.Cooldown,1) t.expect.equal(Kits.Weapons.ArenaPistol.ReloadTime,.9)
  t.expect.truthy(Kits.Weapons.ArenaPistol.Reserve>=Kits.Weapons.ArenaPistol.Magazine*8)
  t.expect.truthy(Kits.Weapons.Rifle.Cooldown<1)
 end)
 t.test("all six loadouts have names and both weapons",function()
  for _,mode in {"arena","ctf"} do
   local list=Loadout.List(mode) t.expect.equal(#list,mode=="arena" and 6 or #Kits.Order)
   for i,l in list do t.expect.equal(l.number,i) t.expect.truthy(#l.primary>0 and #l.secondary>0 and #l.name>0) t.expect.truthy(Loadout.Valid(mode,l.id)) end
  end
  t.expect.falsy(Loadout.Valid("arena","Rifle")) t.expect.falsy(Loadout.Valid("ctf","DesertEagle"))
 end)
 t.test("reload returns exactly to rest and separates the magazine or cylinder",function()
  for _,id in Kits.ArenaPistolVisuals do
   for _,t0 in {0,1} do
    local sample=Reload.Sample(t0,id)
    t.expect.truthy(sample.weapon.Position.Magnitude<.00001)
    t.expect.truthy(sample.magazine.Position.Magnitude<.00001)
    t.expect.truthy(sample.slide.Position.Magnitude<.00001)
   end
   local mid=Reload.Sample(.45,id)
   t.expect.truthy(mid.magazine.Position.Magnitude>.7)
   if id=="Magnum" then t.expect.truthy(mid.cylinder.Position.X<-.3) end
  end
 end)
 t.test("standings sort deterministically and award the podium only once",function()
  local rows={{userId=4,kills=1,deaths=1,score=1},{userId=3,kills=5,deaths=2,score=5},{userId=2,kills=5,deaths=1,score=5},{userId=1,kills=5,deaths=1,score=5}}
  Standings.Sort(rows)
  for i,row in rows do t.expect.equal(row.userId,i) t.expect.equal(row.rank,i) end
  t.expect.equal(rows[1].medal,"gold") t.expect.equal(rows[2].medal,"silver") t.expect.equal(rows[3].medal,"bronze") t.expect.equal(rows[4].medal,"standard")
 end)
end
