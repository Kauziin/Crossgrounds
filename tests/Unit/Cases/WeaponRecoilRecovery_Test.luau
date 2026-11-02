return function(t)
 local root=game.ReplicatedStorage.Crossgrounds local R=require(root.WeaponRecoil) local P=require(root.WeaponRecoilProfiles).Profiles
 t.test("all tuned recoil profiles return to neutral",function()
  for _,p in P do for _,fps in {30,60,120} do
   local r=R.new() r:Kick(p,1)
   for i=1,fps*3 do r:Update(1/fps,p) end
   t.expect.truthy(math.abs(r.pitch)<.001 and math.abs(r.push)<.001 and math.abs(r.roll)<.001)
  end end
 end)
 t.test("consecutive shots stack rise and reset return delay",function()
  local r=R.new() local p=P.ak_47 r:Kick(p,1) r:Update(.08,p) local first=r.pitch
  r:Kick(p,-1) t.expect.equal(r.elapsed,0) r:Update(.08,p)
  t.expect.truthy(r.pitch>first and r.elapsed<p.ReturnDelay)
 end)
 t.test("reset clears held recoil on weapon switches",function()
  local r=R.new() r:Kick(P.rytec_amr,1) r:Update(.05,P.rytec_amr) r:Reset()
  local push,pitch,roll=r:Update(.05,P.m13) t.expect.equal(push,0) t.expect.equal(pitch,0) t.expect.equal(roll,0)
 end)
end
