return function(t)
 local Kits=require(game.ReplicatedStorage.KitDefinitions)
 local Shot=require(game.ReplicatedStorage.Crossgrounds.ShotMath)
 local Query=require(game.ReplicatedStorage.Crossgrounds.ShotQuery)
 local Factory=require(game.ServerScriptService.MainGameScript.GameManager.WeaponFactory)
 local Loadouts=require(game.ReplicatedStorage.Crossgrounds.LoadoutDefinitions)
 t.test("CTF gains two loadouts while Arena retains its six pistol appearances",function()
  local list=Loadouts.List("ctf") t.expect.equal(#list,5)
  t.expect.equal(list[4].primary,"725") t.expect.equal(list[4].secondary,"Bastão")
  t.expect.equal(list[5].primary,"SPAS-12 Semi-Auto") t.expect.equal(list[5].secondary,"Martelo")
  t.expect.equal(#Loadouts.List("arena"),6) t.expect.falsy(Loadouts.Valid("arena","Invasor"))
 end)
 t.test("headshots add exactly fifty percent after distance and penetration",function()
  for _,data in Kits.Weapons do if data.Kind=="Gun" then
   for _,distance in {0,data.FalloffStart,data.FalloffEnd,data.Range} do
    t.expect.equal(Kits.ShotDamage(data,distance,true,.8),Kits.ShotDamage(data,distance,false,.8)*1.5)
   end
   t.expect.truthy(Kits.DamageAtDistance(data,0)>Kits.DamageAtDistance(data,data.Range))
  end end
  t.expect.equal(Kits.ShotDamage(Kits.Weapons.Shotgun725,0,true),43.5)
 end)
 t.test("shotguns share deterministic bounded pellet cones",function()
  for _,id in {"Shotgun725","SPAS12"} do
   local data=Kits.Weapons[id] local config=Shot.Config(data)
   t.expect.equal(config.pellets,8) t.expect.falsy(data.Automatic)
   local previous
   for i=1,8 do
    local d=Shot.Direction(-Vector3.zAxis,data.Spread,123,1,i,8)
    t.expect.equal(d,Shot.Direction(-Vector3.zAxis,data.Spread,123,1,i,8))
    t.expect.truthy(d:Dot(-Vector3.zAxis)>=math.cos(math.rad(data.Spread*.5)))
    if previous then t.expect.truthy((previous-d).Magnitude>.001) end previous=d
   end
  end
 end)
 t.test("new models have correct grips, muzzles, reload parts and nonphysical hitboxes",function()
  for _,id in {"Shotgun725","SPAS12","Baton","Hammer"} do
   local tool=Factory:Create(id) local ok,err=pcall(function()
    t.expect.truthy(tool.Handle:FindFirstChild("RightHandGrip"))
    if Kits.Weapons[id].Kind=="Gun" then
     t.expect.truthy(tool.Handle:FindFirstChild("Muzzle")) t.expect.truthy(tool.Handle:FindFirstChild("SupportGrip"))
     t.expect.truthy(tool:GetAttribute("TwoHanded"))
     t.expect.truthy(#tool:GetChildren()>45)
     local group=tool:FindFirstChild(id=="Shotgun725" and "Barrel1" or "LoadingShell"):GetAttribute("ReloadGroup")
     t.expect.equal(group,id=="Shotgun725" and "BreakAction" or "TubeShell")
    else t.expect.truthy(tool:FindFirstChild("Hitbox")) t.expect.equal(tool.Hitbox.Transparency,1) end
    for _,part in tool:GetChildren() do if part:IsA("BasePart") then t.expect.falsy(part.CanTouch) t.expect.falsy(part.CanCollide) t.expect.falsy(part.CanQuery) end end
   end)
   tool:Destroy() if not ok then error(err,0) end
  end
 end)
 t.test("accessories and invisible roots never intercept body shots",function()
  local model=Instance.new("Model") local h=Instance.new("Humanoid") h.Parent=model
  local torso=Instance.new("Part") torso.Name="Torso" torso.Parent=model
  local root=Instance.new("Part") root.Name="HumanoidRootPart" root.Parent=model
  local hat=Instance.new("Accessory") hat.Parent=model local handle=Instance.new("Part") handle.Parent=hat
  t.expect.truthy(Query.IsBodyPart(torso,model)) t.expect.falsy(Query.IsBodyPart(root,model)) t.expect.falsy(Query.IsBodyPart(handle,model))
  model:Destroy()
 end)
 t.test("range bands distinguish full damage, falloff and no reach",function()
  local data=Kits.Weapons.Shotgun725
  t.expect.equal(Kits.RangeBand(data,10),"ALCANCE EFETIVO")
  t.expect.equal(Kits.RangeBand(data,40),"DANO REDUZIDO")
  t.expect.equal(Kits.RangeBand(data,120),"FORA DE ALCANCE")
  t.expect.equal(Kits.DamageAtDistance(data,75),4)
 end)
end

