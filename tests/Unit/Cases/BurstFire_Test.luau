return function(t)
 local B=require(game.ReplicatedStorage.Crossgrounds.BurstFire)
 local K=require(game.ReplicatedStorage.KitDefinitions)
 t.test("FR fires three and AN94 two per trigger",function()t.expect.equal(B.Config(K.Weapons.fr_5_56,false).count,3)t.expect.equal(B.Config(K.Weapons.an_94,false).count,2)end)
 t.test("AUG requires the functional conversion",function()t.expect.equal(B.Config(K.Weapons.aug,false),nil)t.expect.equal(B.Config(K.Weapons.aug,true).count,3)end)
 t.test("a fourth shot must wait for the burst pause",function()local s={}local c=B.Config(K.Weapons.fr_5_56,false)B.Commit(s,0,c)B.Commit(s,.1,c)B.Commit(s,.2,c)t.expect.falsy(B.Ready(s,.3))t.expect.truthy(B.Ready(s,.48))end)
 t.test("latency tolerance cannot accumulate a faster schedule",function()local s={}local c=B.Config(K.Weapons.fr_5_56,false)B.Commit(s,0,c)t.expect.falsy(B.Ready(s,.05))B.Commit(s,.08,c)B.Commit(s,.18,c)t.expect.truthy(s.nextAt>=.48-.000001)end)
 t.test("damage reduction does not change legacy or semiauto weapons",function()t.expect.equal(K.Weapons.m4a1.Damage,28)t.expect.equal(K.Weapons.m4a1.MinDamage,19.5)t.expect.equal(K.Weapons.fr_5_56.Damage,80)t.expect.equal(K.Weapons.Rifle.Damage,34)end)
end
