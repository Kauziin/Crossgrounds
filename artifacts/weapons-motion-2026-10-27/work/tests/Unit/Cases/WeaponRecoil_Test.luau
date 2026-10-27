return function(t)
 local Spring=require(game.ReplicatedStorage.Crossgrounds.WeaponRecoil)
 local profile=require(game.ReplicatedStorage.KitDefinitions).Weapons.Sniper.VisualRecoil
 t.test("recoil returns to rest after a shot",function()
  local r=Spring.new() r:Kick(profile,1) local peak=0
  for _=1,180 do local push=r:Update(1/60,profile) peak=math.max(peak,push) end
  t.expect.truthy(peak>.2) t.expect.truthy(r.push<.001) t.expect.truthy(r.pitch<.001)
 end)
 t.test("30 and 144 fps produce similar peak kick",function()
  local function simulate(fps) local r=Spring.new() r:Kick(profile,1) local peak=0 for _=1,fps do local push=r:Update(1/fps,profile) peak=math.max(peak,push) end return peak end
  t.expect.truthy(math.abs(simulate(30)-simulate(144))<.03)
 end)
 t.test("sustained fire remains bounded and reset clears motion",function()
  local r=Spring.new() for _=1,200 do r:Kick(profile,-1) r:Update(.1,profile) end
  t.expect.truthy(r.push<=1 and r.pitch<=10 and math.abs(r.roll)<=4) r:Reset()
  t.expect.equal(r.push,0) t.expect.equal(r.pitch,0) t.expect.equal(r.pushV,0)
 end)
end
