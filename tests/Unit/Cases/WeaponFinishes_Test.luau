return function(t)
 local Root=game.ReplicatedStorage.Crossgrounds
 local P=require(Root.CareerPolicy)local Catalog=require(Root.WeaponFinishCatalog)
 local V=require(Root.WeaponFinishVisual)local Unlocks=require(Root.UnlockCatalog)
 t.test("curated account track covers every normal level",function()
  local levels={}for _,item in Unlocks.List("ctf")do if item.kind=="weapon"then levels[item.level]=true end end
  for level=1,55 do t.expect.truthy(levels[level])end
  t.expect.equal(Unlocks.Get("ctf","m4a1").level,1)t.expect.equal(Unlocks.Get("ctf","m1911").level,1)t.expect.equal(Unlocks.Get("ctf","ax_50").level,55)
 end)
 t.test("finish milestones follow weapon XP",function()
  local p=P.New()
  for id,item in Catalog.Items do
   local threshold=200*(item.level-1)^2
   t.expect.truthy(Catalog.Allows(p,"m4a1",id,"ctf",P.WeaponLevel(threshold)))
   if item.level>1 then t.expect.falsy(Catalog.Allows(p,"m4a1",id,"ctf",P.WeaponLevel(threshold-1)))end
  end
 end)
 t.test("permanent token is scoped to weapon and mode",function()
  local p=P.New()p.tokens.ctf=1
  local id=Catalog.TokenId("m4a1","gold")t.expect.truthy(Unlocks.Get("ctf",id))t.expect.truthy(P.Unlock(p,"ctf",id))
  t.expect.truthy(Catalog.Allows(p,"m4a1","gold","ctf",1))
  t.expect.falsy(Catalog.Allows(p,"m1911","gold","ctf",1))t.expect.falsy(Catalog.Allows(p,"m4a1","gold","arena",1))
 end)
 t.test("unknown finishes and nonexistent weapons cannot use tokens",function()
  t.expect.equal(Catalog.Parse("finish:m4a1:unknown"),nil)
  t.expect.equal(Unlocks.Get("ctf","finish:nonexistent:gold"),nil)
  t.expect.equal(Unlocks.Get("arena","finish:ax_50:gold"),nil)
 end)
 t.test("paint preserves glass, invisible helpers and combat properties",function()
  local model=Instance.new("Model")local body=Instance.new("Part")body.Name="Receiver"body.Color=Color3.fromRGB(100,100,100)body.Anchored=true body.CanCollide=false body.Parent=model
  local lens=body:Clone()lens.Name="Lens"lens.Material=Enum.Material.Glass lens.Parent=model
  local helper=body:Clone()helper.Name="Handle"helper.Transparency=1 helper.Parent=model
  local size,cf=body.Size,body.CFrame local original=body.Color
  V.Apply(model,"gold")t.expect.truthy(body.Color~=original)t.expect.equal(lens.Color,original)t.expect.equal(helper.Color,original)
  t.expect.equal(body.Size,size)t.expect.equal(body.CFrame,cf)t.expect.truthy(body.Anchored)t.expect.falsy(body.CanCollide)
  V.Apply(model,"forest")V.Apply(model,"default")t.expect.equal(body.Color,original)model:Destroy()
 end)
 t.test("finishes and weapon progress survive prestige and mastery",function()
  local p=P.New()p.weapons.m4a1=583200 p.weaponFinishes.m4a1="gold"
  for _=1,12 do p.cycleXP=P.Cap(p.phase)t.expect.truthy(P.Transition(p))t.expect.equal(p.weapons.m4a1,583200)t.expect.equal(p.weaponFinishes.m4a1,"gold")end
 end)
 t.test("optional finish state migrates old v2 profiles",function()
  local p=P.New()p.weaponFinishes=nil local migrated=P.Migrate(p)t.expect.truthy(migrated.weaponFinishes)
  p.weaponFinishes=5 t.expect.equal(P.Migrate(p),nil)
 end)
end
