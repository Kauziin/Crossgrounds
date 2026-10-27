return function(t)
 local Accuracy=require(game.ReplicatedStorage.Crossgrounds.BotAccuracy)
 local Spawns=require(game.ServerScriptService.Crossgrounds.MapSpawns)
 t.test("bots have bounded deliberate misses and role-specific accuracy",function()
  local counts={}
  for _,role in {"Runner","Soldier","Guardian"} do
   local rng=Random.new(723) local hit=0
   for i=1,2000 do local offset,intended=Accuracy.Offset(rng,role,70)
    if intended then hit+=1 else t.expect.truthy(math.abs(offset.X)>=3.2) end
    t.expect.truthy(offset.Magnitude<12)
   end
   counts[role]=hit t.expect.truthy(hit>250 and hit<1000)
  end
  t.expect.truthy(counts.Guardian>counts.Soldier and counts.Soldier>counts.Runner)
 end)
 t.test("a spawn with a single narrow way out is rejected",function()
  local world=Instance.new("Model") world.Name="SafeExitQA" world.Parent=workspace
  local function part(size,offset) local p=Instance.new("Part") p.Anchored=true p.Size=size p.CFrame=CFrame.new(Vector3.new(0,10000,0)+offset) p.Parent=world return p end
  part(Vector3.new(60,1,60),Vector3.new(0,-.5,0))
  local cf=CFrame.new(0,10003.6,0)
  local open=Spawns.SafeExits(world,cf) t.expect.truthy(open)
  part(Vector3.new(22,8,1),Vector3.new(0,4,3))
  part(Vector3.new(22,8,1),Vector3.new(0,4,-3))
  part(Vector3.new(1,8,22),Vector3.new(-3,4,0))
  local closed=Spawns.SafeExits(world,cf) world:Destroy() t.expect.falsy(closed)
 end)
end
