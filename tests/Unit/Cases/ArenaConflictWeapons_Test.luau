return function(t)
 local K=require(game.ReplicatedStorage.KitDefinitions) local S=require(game.ReplicatedStorage.Crossgrounds.WeaponStats)
 local F=require(game.ServerScriptService.MainGameScript.GameManager.WeaponFactory)
 t.test("Arena rejects Projectile Test firearms as pistol selections",function()
  t.expect.falsy(K:IsPistolVisual("Blaster")) t.expect.falsy(K:IsPistolVisual("AutoBlaster"))
 end)
 t.test("all Arena pistol appearances share one semiautomatic definition",function()
  for _,visual in K.ArenaPistolVisuals do
   local tool=F:Create("ArenaPistol",visual)
   t.expect.equal(S.ResolveTool(tool),K.Weapons.ArenaPistol)
   t.expect.falsy(S.ResolveTool(tool).Automatic) t.expect.equal(tool:GetAttribute("WeaponId"),"ArenaPistol") tool:Destroy()
  end
 end)
 t.test("Conflict procedural pistols have independent combat identity",function()
  local mags={Glock18=17,Luger=8,Beretta=15}
  for id,capacity in mags do local tool=F:Create(id)
   t.expect.equal(S.ResolveTool(tool).Magazine,capacity) t.expect.equal(tool:GetAttribute("WeaponId"),id)
   t.expect.falsy(tool:GetAttribute("ArenaWeapon")) tool:Destroy()
  end
 end)
end
