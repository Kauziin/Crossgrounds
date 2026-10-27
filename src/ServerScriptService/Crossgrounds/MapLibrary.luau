-- Server-only metadata registry. Geometry never replicates until a mode loads it.
local Library={}
local ArenaIcons=require(game.ReplicatedStorage.Crossgrounds:WaitForChild("ArenaMapIcons"))
function Library.Root(mode)
 local library=game.ServerStorage:FindFirstChild("CrossgroundsMaps")
 local folder=library and library:FindFirstChild(mode)
 if folder then return folder end
 if mode=="Arena" then return game.ServerStorage:FindFirstChild("CrossgroundsArenaMaps") end
end
function Library.Get(mode,id)
 if typeof(id)~="string" or #id>64 then return nil end
 local root=Library.Root(mode) local map=root and root:FindFirstChild(id)
 if not map or map:GetAttribute("Enabled")==false or map:GetAttribute("Sanitized")~=true or not map:FindFirstChild("Geometry") then return nil end
 local points=map:FindFirstChild("Spawns")
 if not points or #points:GetChildren()<4 then return nil end
 return map
end
function Library.Catalog(mode)
 local out={} local root=Library.Root(mode)
 if root then for _,map in root:GetChildren() do
  if Library.Get(mode,map.Name) then
   table.insert(out,{id=map.Name,name=map:GetAttribute("DisplayName") or map.Name,creator=map:GetAttribute("SourceCreator"),assetId=map:GetAttribute("SourceAssetId"),order=map:GetAttribute("SortOrder") or 100,thumbnail=map:GetAttribute("Thumbnail")or(mode=="Arena"and ArenaIcons[map.Name])or""})
  end
 end end
 table.sort(out,function(a,b) if a.order==b.order then return a.id<b.id end return a.order<b.order end)
 return out
end
return Library
