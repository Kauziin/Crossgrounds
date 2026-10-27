return function(t)
 local Spawns=require(game.ServerScriptService.Crossgrounds.MapSpawns)
 local function scene(callback)
  local world=Instance.new("Folder") world.Name="MapSpawnContractQA" world.Parent=workspace
  local floor=Instance.new("Part") floor.Size=Vector3.new(60,1,60) floor.CFrame=CFrame.new(8000,200,8000) floor.Anchored=true floor.Parent=world
  local ok,err=pcall(callback,world,floor) world:Destroy() if not ok then error(err) end
 end
 t.test("authored spawn zones reject outside markers and respect rotation",function()
  local regions=Instance.new("Folder")
  local p=Instance.new("Part") p.Size=Vector3.new(20,16,40) p.CFrame=CFrame.new(8000,205,8000)*CFrame.Angles(0,math.rad(30),0) p.Parent=regions
  t.expect.truthy(Spawns.InRegions(p.CFrame,regions))
  t.expect.falsy(Spawns.InRegions(p.CFrame*CFrame.new(10,0,0),regions))
  t.expect.falsy(Spawns.InRegions(p.CFrame*CFrame.new(0,9,0),regions))
  t.expect.truthy(Spawns.InRegions(CFrame.new(),nil))
  regions:Destroy()
 end)
 t.test("requires solid support below the character",function() scene(function(world)
  t.expect.truthy(Spawns.Validate(world,CFrame.new(8000,204.1,8000)))
  t.expect.falsy(Spawns.Validate(world,CFrame.new(8100,204.1,8000)))
 end) end)
 t.test("rejects a low ceiling intersecting character clearance",function() scene(function(world)
  local ceiling=Instance.new("Part") ceiling.Size=Vector3.new(60,1,60) ceiling.CFrame=CFrame.new(8000,206,8000) ceiling.Anchored=true ceiling.Parent=world
  t.expect.falsy(Spawns.Validate(world,CFrame.new(8000,204.1,8000)))
 end) end)
 t.test("indoor sampling stays below the roof and spreads points",function() scene(function(world)
  local roof=Instance.new("Part") roof.Size=Vector3.new(60,1,60) roof.CFrame=CFrame.new(8000,213,8000) roof.Anchored=true roof.Parent=world
  local points=Spawns.Generate(world,Vector3.new(8000,200.5,8000),Vector3.new(60,13,60),nil,12)
  t.expect.equal(#points,12)
  for i,cf in points do
   t.expect.truthy(cf.Y<210 and Spawns.Validate(world,cf))
   for j=1,i-1 do t.expect.truthy((points[j].Position-cf.Position).Magnitude>=8) end
  end
 end) end)
end
