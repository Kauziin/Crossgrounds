return function(t)
 local Root=game.ReplicatedStorage.Crossgrounds
 local Catalog=require(Root.WeaponCatalog) local Config=require(Root.WeaponVisualConfiguration)
 local Stats=require(Root.WeaponStats) local A=require(Root.AttachmentCatalog)
 local Visual=require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals)
 t.test("primary and pistol are independently validated",function() t.expect.truthy(Config.Loadout(Config.Default(1))) end)
 t.test("legacy melee is preserved and cannot become a third firearm",function()
  local d=Config.Default(1) d.meleeWeaponId="Knife" t.expect.equal(Config.Loadout(d).meleeWeaponId,"Knife")
  d.meleeWeaponId="Rifle" t.expect.falsy(Config.Loadout(d))
 end)
 t.test("preview-only weapons cannot be equipped",function() local d=Config.Default(1) d.primaryWeaponId="ak_47" t.expect.falsy(Config.Loadout(d)) end)
 t.test("a rifle cannot occupy the pistol slot",function() local d=Config.Default(1) d.secondaryWeaponId="m4a1" t.expect.falsy(Config.Loadout(d)) end)
 t.test("cross-weapon attachments and fake slots are rejected",function()
  t.expect.falsy(Config.Validate("m1911",{optic="optics_g_i_mini_reflex"},true))
  t.expect.falsy(Config.Validate("m4a1",{ammunition="suppressors_monolithic_suppressor"},true))
 end)
 t.test("accessories have no gameplay stat bonuses",function()
  local before=Stats.Get("m4a1").effectiveGameplayStats
  t.expect.truthy(Config.Validate("m4a1",{optic="optics_g_i_mini_reflex",muzzle="suppressors_monolithic_suppressor",underbarrel="foregrips_commando_foregrip"},true))
  local after=Stats.Get("m4a1").effectiveGameplayStats for key,value in before do t.expect.equal(after[key],value) end
 end)
 t.test("sanitized visuals keep moving groups without imported scripts",function()
  local model=assert(Visual.Build("m4a1",{optic="optics_g_i_mini_reflex"})) local groups=0
  for _,v in model:GetDescendants() do
   t.expect.falsy(v:IsA("LuaSourceContainer") or v:IsA("RemoteEvent"))
   if v:IsA("BasePart") then t.expect.falsy(v.CanCollide or v.CanQuery) if v:GetAttribute("ReloadGroup") then groups+=1 end end
  end
  t.expect.truthy(groups>0) t.expect.truthy(model.Handle.Muzzle and model.Handle.RightHandGrip and model.Handle.SupportGrip) model:Destroy()
 end)
 t.test("Arena pistol cosmetics remain independent",function()
  local tool=require(game.ServerScriptService.MainGameScript.GameManager.WeaponFactory):Create("ArenaPistol","Magnum")
  t.expect.equal(tool:GetAttribute("CosmeticId"),"Magnum") t.expect.equal(tool:GetAttribute("VisualWeaponId"),nil) tool:Destroy()
 end)
 t.test("MW replaces external duplicates without losing attachment variants",function()
  for _,id in {"m4a1","mp7","725","fal","pkm"} do t.expect.equal(Catalog.Get(id).sourcePack,"mw2019") end
  local count=0 for _ in A do count+=1 end t.expect.equal(count,97)
 end)
 t.test("legacy primary choices and preview melee occupy different lists",function()
  for _,v in Catalog.List("primary") do t.expect.falsy(v.category=="PISTOLS" or v.category=="MELEE") end
  t.expect.truthy(#Catalog.List("melee")>=32)
 end)
end
