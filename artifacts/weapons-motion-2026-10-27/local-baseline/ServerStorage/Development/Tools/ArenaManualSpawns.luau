-- Hand-authored positions after visual review. Coordinates are template space, not editor space.
local Author={}
local Data={
 glacier={
  {"GeloOeste",1738,-163.9019,345,90},
  {"GeloOeste",1738,-163.9019,375,0},
  {"GeloOeste",1738,-163.9019,420,0},
  {"GeloOeste",1742,-163.9019,448,0},
  {"GeloOeste",1762,-163.9019,318,90},
  {"GeloOeste",1762,-163.9019,405,0},
  {"GeloOeste",1762,-163.9019,435,0},
  {"GeloNorte",1787,-163.9019,303,90},
  {"GeloNorte",1810,-163.9019,285,90},
  {"GeloOeste",1754,-163.9019,370,0},
  {"GeloLeste",1871,-163.9019,415,-90},
  {"GeloLeste",1893,-163.9019,292,180},
  {"GeloLeste",1893,-163.9019,330,180},
  {"GeloLeste",1893,-163.9019,380,-90},
  {"GeloSul",1805,-163.9019,450,90},
  {"GeloSul",1835,-163.9019,450,-90},
  {"GeloSul",1850,-163.9019,431,-90},
  {"Plato",1780,-138.9004,345,90},
  {"Plato",1805,-138.9004,350,180},
  {"Plato",1820,-138.9004,330,180},
  {"Plato",1855,-138.9004,375,-90},
  {"Plato",1835,-138.9004,395,0},
  {"Plato",1810,-138.9004,410,0},
  {"Plato",1770,-138.9004,375,90},
 },
 assault={
  {"EstacaoOeste",1690,116.6,260,180},
  {"EstacaoOeste",1690,116.6,295,180},
  {"EstacaoOeste",1690,116.6,435,0},
  {"EstacaoOeste",1690,116.6,465,0},
  {"EstacaoLeste",1720,116.6,285,180},
  {"EstacaoLeste",1720,116.6,325,180},
  {"EstacaoLeste",1720,116.6,430,0},
  {"EstacaoLeste",1720,116.6,475,0},
  {"RuaCentral",1768,84.1,285,180},
  {"RuaCentral",1768,84.1,335,90},
  {"RuaCentral",1768,84.1,395,0},
  {"RuaCentral",1768,84.1,435,0},
  {"RuaSul",1805,84.1,410,0},
  {"RuaSul",1840,84.1,410,0},
  {"RuaSul",1950,84.1,410,-90},
  {"RuaSul",1945,84.6,445,-90},
  {"PatioNorte",1800,83.6,185,90},
  {"PatioNorte",1850,83.6,185,180},
  {"PatioNorte",1935,83.6,195,-90},
  {"FrenteArmazem",1810,84.6,335,-90},
  {"FrenteArmazem",1840,84.6,335,-90},
  {"FrenteArmazem",1870,84.6,335,-90},
  {"PassagemLeste",1920,84.6,315,-90},
  {"PassagemLeste",1958,83.6,360,-90},
  {"MercadoNorte",1875,86.2001,220,180},
  {"MercadoNorte",1875,84.6,280,-90},
  {"RuaCentral",1768,84.1,460,0},
 },
 factory={
  {"Patio",1768,83.6,258,180},
  {"Patio",1795,83.7006,258,180},
  {"Patio",1775,83.6,278,90},
  {"Patio",1805,83.7,278,-90},
  {"Patio",1768,83.6,302,90},
  {"Patio",1790,83.7003,302,0},
  {"Patio",1815,83.6,302,-90},
  {"Patio",1830,83.6,310,-90},
  {"Patio",1757,83.6,258,90},
  {"Patio",1808,83.7,292,-90},
  {"Patio",1780,83.6,310,0},
  {"Patio",1767,83.6,272,90},
  {"Patio",1793,83.7,274,180},
  {"Patio",1813,83.6,269,-90},
  {"Patio",1818,83.6,309,0},
 },
 beach={
  {"Areia",1748,-145.6739,390,180},
  {"Areia",1780,-145.6739,390,180},
  {"Areia",1753,-145.6739,369,180},
  {"Areia",1778,-145.6739,371,180},
  {"Areia",1790,-145.6739,373,180},
  {"Areia",1815,-145.6739,380,180},
  {"Areia",1840,-145.6241,372,180},
  {"Areia",1845,-145.6739,390,180},
  {"Orla",1710,-145.6739,404,180},
  {"Orla",1735,-145.6739,405,180},
  {"Orla",1760,-145.6739,405,180},
  {"Orla",1785,-145.6739,405,180},
  {"Orla",1810,-145.6739,405,180},
  {"Orla",1835,-145.6739,405,180},
  {"Praca",1712,-145.6739,435,0},
  {"Praca",1712,-145.6739,465,0},
  {"Praca",1768,-145.6739,445,0},
  {"Praca",1798,-145.6739,445,0},
  {"Praca",1845,-145.6739,465,0},
  {"AlamedaLeste",1875,-145.6739,432,-90},
  {"AlamedaLeste",1875,-145.6739,448,-90},
  {"AlamedaLeste",1875,-145.6739,475,0},
  {"Lojas",1720,-145.6739,470,0},
  {"Lojas",1745,-145.6739,470,0},
  {"Lojas",1800,-145.6739,470,0},
  {"Lojas",1825,-145.6739,470,0},
 },
}

local Storage=game:GetService("ServerStorage")
local Validator=require(game.ServerScriptService.Crossgrounds.MapSpawns)
local function cf(point)
 return CFrame.new(point[2],point[3],point[4])*CFrame.Angles(0,math.rad(-point[5]),0)
end
local function marker(parent,index,point,offset,visible)
 local p=Instance.new("Part") p.Name=string.format("Spawn%03d",index) p.Size=visible and Vector3.new(2,1,3) or Vector3.one
 p.CFrame=cf(point)+offset p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
 p.Transparency=visible and .25 or 1 p.Color=Color3.fromRGB(40,235,170) p.Material=visible and Enum.Material.Neon or Enum.Material.Plastic
 p:SetAttribute("SpawnRole","Player") p:SetAttribute("SpawnZone",point[1]) p:SetAttribute("ManualReview","2026-10-26") p.Parent=parent
 if visible then
  local gui=Instance.new("SurfaceGui")gui.Name="EditorDirection"gui.Face=Enum.NormalId.Top gui.CanvasSize=Vector2.new(120,180)gui.Parent=p
  local arrow=Instance.new("TextLabel")arrow.Size=UDim2.fromScale(1,1)arrow.BackgroundTransparency=1 arrow.Text="FRONT\n↑"arrow.TextScaled=true arrow.TextColor3=Color3.new(0,0,0)arrow.Parent=gui
 end
 return p
end
function Author.Validate()
 assert(not game.RunService:IsRunning(),"Use com Play parado.")
 local report={}
 for id,points in Data do
  local map=workspace.ArenaSpawnEditor[id] local offset=map:GetAttribute("EditorOffset") local valid=0
  for index,point in points do
   assert(Validator.Validate(map.Geometry,cf(point)+offset),id.." ponto bloqueado: "..index)
   local exits=Validator.SafeExits(map.Geometry,cf(point)+offset)
   assert(exits,id.." ponto sem rotas de saída: "..index)
   valid+=1
  end
  table.insert(report,{id=id,spawns=valid})
 end
 return report
end
function Author.Apply()
 local report=Author.Validate()
 local development=Storage.Development
 local revisions=development:FindFirstChild("Revisions") or Instance.new("Folder") revisions.Name="Revisions" revisions.Parent=development
 local maps=revisions:FindFirstChild("Maps") or Instance.new("Folder")maps.Name="Maps"maps.Parent=revisions
 local originals={}
 for id in Data do
  for _,source in development.MapSources.Arena:GetChildren()do
   if source:GetAttribute("CrossgroundsMapId")==id then assert(not originals[id],"Original duplicado: "..id)originals[id]=source end
  end
  assert(originals[id],"Original não encontrado: "..id)
 end
 game.ChangeHistoryService:SetWaypoint("Before hand-authored Arena spawns")
 for id,points in Data do
  local template=Storage.CrossgroundsMaps.Arena[id]local preview=workspace.ArenaSpawnEditor[id]local original=originals[id]
  local editorOffset=preview:GetAttribute("EditorOffset")local sourceOffset=template:GetAttribute("SourceOffset")
  assert(typeof(sourceOffset)=="Vector3","SourceOffset ausente: "..id)
  local backup=Instance.new("Folder")backup.Name=id.."_manual_spawns_20261026_"..#maps:GetChildren()
  backup:SetAttribute("RevisionType","SpawnsOnly")backup:SetAttribute("MapId",id)backup.Parent=maps
  local function preserve(obj,name)if obj then obj.Name=name obj.Parent=backup end end
  preserve(template:FindFirstChild("Spawns"),"TemplateSpawns")
  preserve(preview:FindFirstChild("Spawns"),"PreviewSpawns")
  preserve(original:FindFirstChild("AuthoredSpawns"),"SourceAuthoredSpawns")
  local stored=Instance.new("Folder")stored.Name="Spawns"stored.Parent=template
  local shown=Instance.new("Folder")shown.Name="Spawns"shown.Parent=preview
  local authored=Instance.new("Folder")authored.Name="AuthoredSpawns"authored.Parent=original
  for index,point in points do marker(stored,index,point,Vector3.zero,false)marker(shown,index,point,editorOffset,true)marker(authored,index,point,-sourceOffset,false)end
  if id=="factory"then
   preserve(template:FindFirstChild("SpawnRegions"),"TemplateRegions")
   preserve(preview:FindFirstChild("SpawnRegions"),"PreviewRegions")
   preserve(original:FindFirstChild("SpawnRegions"),"SourceRegions")
   for _,entry in {{template,Vector3.zero},{preview,editorOffset},{original,-sourceOffset}}do
    local regions=Instance.new("Folder")regions.Name="SpawnRegions"regions.Parent=entry[1]
    local p=Instance.new("Part")p.Name="PatioInterno"p.Size=Vector3.new(95,18,68)p.Position=Vector3.new(1795,88,283)+entry[2]
    p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Transparency=entry[1]==preview and .92 or 1
    p.Color=Color3.fromRGB(74,150,255)p:SetAttribute("FloorY",80+entry[2].Y)p.Parent=regions
   end
  end
  if id=="glacier"then template:SetAttribute("KillPlaneY",-184)original:SetAttribute("AuthoredKillPlaneY",-184-sourceOffset.Y)end
  template:SetAttribute("SpawnCount",#points)template:SetAttribute("SpawnAuthoring","manual_2026-10-26")
  original:SetAttribute("SpawnAuthoring","manual_2026-10-26")
 end
 game.ChangeHistoryService:SetWaypoint("Hand-authored Arena spawns applied")
 return report
end
return Author

