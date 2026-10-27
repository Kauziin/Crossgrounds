return function(t)
 local catalog=require(game.ReplicatedStorage.Crossgrounds.GameCatalog)
 -- CTF and the newly authorized Arena hub test are prototypes.
 t.test("CTF and Arena are prototypes with no fabricated Arena capacity",function()
  local playable={}
  for _,g in catalog:List() do if g.status~="planned" then table.insert(playable,g.id) end end
  t.expect.equal(#playable,2) t.expect.truthy(table.find(playable,"ctf")) t.expect.truthy(table.find(playable,"arena"))
  t.expect.equal(catalog:Get("arena").capacity,nil)
  local c=catalog:Get("ctf") t.expect.equal(c.capacity.teams,2) t.expect.equal(c.capacity.combatantsPerTeam,6)
 end)
 -- Undecided game capacities must not be fabricated.
 t.test("planned games have no numeric capacity",function()
  for _,id in {"get_out","duels"} do
   local g=catalog:Get(id) t.expect.equal(g.status,"planned") t.expect.equal(g.capacity,nil)
  end
 end)
 -- Client metadata mutations cannot rewrite the shared catalog.
 t.test("catalog snapshots are isolated",function()
  local c=catalog:Get("ctf") c.name="changed" c.capacity.teams=99
  t.expect.equal(catalog:Get("ctf").capacity.teams,2) t.expect.equal(catalog:Get("unknown"),nil)
 end)
end
