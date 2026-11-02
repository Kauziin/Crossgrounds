return function(t)
 local M=require(game.ReplicatedStorage.Crossgrounds.AX50Motion)
 t.test("bolt stays idle through the main recoil and resets completely",function()
  t.expect.equal(M.Bolt(.50,1.5,false).active,0)
  t.expect.truthy(M.Bolt(1.05,1.5,false).active>.9)
  for _,sample in {M.Bolt(1.5,1.5,false),M.Bolt(.9,1.5,true)} do t.expect.equal(sample.active,0) t.expect.equal(sample.bolt,CFrame.identity) t.expect.equal(sample.hand,Vector3.zero) end
 end)
 t.test("casing occurs only on extraction once at any frame rate",function()
  for _,fps in {30,60,120} do
   local count=0 local last=0
   for i=1,math.ceil(1.6*fps) do
    local now=i/fps for _,e in M.Events(last,now,1.5) do if e.name=="CasingEject" then count+=1 t.expect.truthy(now>=1.13 and now<1.13+1/fps+.001) end end last=now
   end
   t.expect.equal(count,1)
  end
 end)
 t.test("hipfire kick is lateral and deeper than ADS and returns to identity",function()
  local hip=M.Kick(.1,0,1) local ads=M.Kick(.1,1,1)
  t.expect.truthy(hip.X>0 and hip.Z>0 and hip.Position.Magnitude>ads.Position.Magnitude)
  t.expect.equal(M.Kick(.8,0,1),CFrame.identity)
 end)
end
