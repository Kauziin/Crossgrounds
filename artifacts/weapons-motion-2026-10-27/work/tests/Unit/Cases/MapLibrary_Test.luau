return function(t)
 local Library=require(game.ServerScriptService.Crossgrounds.MapLibrary)
 t.test("separates Arena and Get Out maps",function()
  t.expect.truthy(Library.Get("Arena","shipment")) t.expect.truthy(Library.Get("GetOut","office"))
  t.expect.falsy(Library.Get("Arena","office")) t.expect.falsy(Library.Get("GetOut","shipment"))
 end)
 t.test("does not accept paths or unknown identifiers",function()
  t.expect.falsy(Library.Get("Arena","../GetOut/office")) t.expect.falsy(Library.Get("Arena",{}))
 end)
 t.test("unprepared and disabled maps cannot enter voting",function()
  local root=Library.Root("Arena") local m=Instance.new("Model") m.Name="MapLibraryContractQA" m.Parent=root
  local ok,err=pcall(function()
   m:SetAttribute("Sanitized",true) local g=Instance.new("Folder") g.Name="Geometry" g.Parent=m
   t.expect.falsy(Library.Get("Arena",m.Name))
   local points=Instance.new("Folder") points.Name="Spawns" points.Parent=m
   for i=1,4 do local p=Instance.new("Part") p.Parent=points end
   t.expect.truthy(Library.Get("Arena",m.Name)) m:SetAttribute("Enabled",false)
   t.expect.falsy(Library.Get("Arena",m.Name))
  end)
  m:Destroy() if not ok then error(err) end
 end)
end
