return function(t)
 local Motion=require(game.ReplicatedStorage.Crossgrounds.AX50Motion)
 local Sights=require(game.ReplicatedStorage.Crossgrounds.SightDefinitions)
 t.test('only AX-50 uses physical scope prototype',function()
  t.expect.truthy(Sights.Get('ax_50').physical)
  t.expect.falsy(Sights.Get('hdr').physical)
  t.expect.truthy(Sights.Get('hdr').hideWeapon)
  t.expect.falsy(Sights.Get('ax_50','optics_solozero_variable_zoom_scope').physical)
 end)
 t.test('bolt lifts before pulling and returns before next shot',function()
  local raised=Motion.Bolt(.40,1.5,false)
  local pulled=Motion.Bolt(.72,1.5,false)
  t.expect.truthy(raised.active>0)
  t.expect.truthy(pulled.bolt.Position.Z>.40)
  t.expect.equal(Motion.Bolt(1.5,1.5,false).active,0)
  t.expect.equal(Motion.Bolt(.72,1.5,true).active,0)
  t.expect.equal(Motion.Bolt(-1,1.5,false).active,0)
 end)
 t.test('camera recovery is frame-rate independent and settles',function()
  local a,b=Motion.new(),Motion.new() a:Kick(1,true) b:Kick(1,true)
  for _=1,15 do a:Update(1/30) end
  for _=1,60 do b:Update(1/120) end
  t.expect.truthy((a.position-b.position).Magnitude<.00001)
  for _=1,60 do a:Update(1/30) end
  t.expect.truthy(a.position.Magnitude<.00001)
  a:Reset() t.expect.equal(a.velocity,Vector2.zero)
 end)
 t.test('ocular is open 3D geometry aligned across aspect ratios and FOVs',function()
  local Optics=require(game.StarterPlayer.StarterPlayerScripts.AX50Optics)
  local model=Instance.new('Model')
  local p=Instance.new('Part') p.Name='Lens' p.Size=Vector3.new(.44,.44,2.9) p.CFrame=CFrame.new(0,1.45,-1.6) p.Parent=model
  local entries={{part=p,rest=p.CFrame}}
  local optic=Optics.Build(model,entries)
  t.expect.equal(#optic.parts,96) t.expect.truthy(entries[1].closedOptic)
  t.expect.equal(p.Transparency,0)
  for _,size in {Vector2.new(1920,1080),Vector2.new(1280,720),Vector2.new(1024,768)} do
   for _,fov in {50,70,90} do
    local projected=Optics.Project(optic,Optics.Alignment(optic,fov),fov,size)
    t.expect.truthy((projected.point-size*.5).Magnitude<.001)
    t.expect.truthy(projected.radius>size.Y*.25 and projected.radius<size.Y*.4)
   end
  end
  model:Destroy()
 end)
end
