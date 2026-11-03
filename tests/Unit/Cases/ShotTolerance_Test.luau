return function(t)
 local S=require(game.ReplicatedStorage.Crossgrounds.ShotMath)
 t.test("shared radius adds a small margin and tracer does not mutate weapon data",function()
  local visual={Width=.02,Length=10,Speed=3000}
  local data={ProjectileRadius=.4,ShotVisual=visual}
  local c=S.Config(data)
  t.expect.truthy(math.abs(c.radius-.5)<1e-6)
  t.expect.equal(c.visual.Width,.05) t.expect.equal(visual.Width,.02)
  t.expect.equal(S.Config({}).radius,.1)
  t.expect.equal(S.Config({ProjectileRadius=5}).radius,5)
 end)
end
