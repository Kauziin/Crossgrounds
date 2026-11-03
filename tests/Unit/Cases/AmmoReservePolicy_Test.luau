return function(t)
 local P=require(game.ReplicatedStorage.Crossgrounds.AmmoReservePolicy)
 t.test("class reserves preserve magazine and projectile minimums",function()
  local weapons={}
  for _,ids in P.Classes do for _,id in ids do weapons[id]={Kind="Gun",Magazine=7,Reserve=2} end end
  weapons.Blaster.Reserve=100 weapons.unknown={Kind="Gun",Reserve=99,Magazine=1}
  weapons.ArenaPistol={Kind="Gun",Magazine=12,Reserve=120}
  P.Apply(weapons)
  for class,ids in P.Classes do for _,id in ids do
   local d=weapons[id]
   t.expect.equal(d.Magazine,7)
   if id~="Blaster" then t.expect.equal(d.Reserve,P.Reserves[class]) end
  end end
  t.expect.equal(weapons.Blaster.Reserve,100) t.expect.equal(weapons.unknown.Reserve,10)
  t.expect.equal(weapons.ArenaPistol.Reserve,0) t.expect.truthy(weapons.ArenaPistol.InfiniteReserve)
 end)
end
