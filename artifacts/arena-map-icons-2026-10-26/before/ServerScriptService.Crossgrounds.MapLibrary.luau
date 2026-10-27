-- Server-only metadata registry. Geometry never replicates until a mode loads it.
local Library={}
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
   table.insert(out,{id=map.Name,name=map:GetAttribute("DisplayName") or map.Name,creator=map:GetAttribute("SourceCreator"),assetId=map:GetAttribute("SourceAssetId"),order=map:GetAttribute("SortOrder") or 100})
  end
 end end
 table.sort(out,function(a,b) if a.order==b.order then return a.id<b.id end return a.order<b.order end)
 return out
end
-- Photo catalog deliberately does not require gameplay spawns or enabled matchmaking.
function Library.PhotoGet(key)
 if typeof(key)~="string" or #key>140 then return end
 local mode,id=key:match("^([^/]+)/([^/]+)$")
 if not mode then mode="Arena" id=key end -- older callers
 local root=mode=="CTF" and game.ServerStorage:FindFirstChild("CTFMaps") or Library.Root(mode)
 if mode~="CTF" and mode~="Arena" and mode~="GetOut" then return end
 local map=root and root:FindFirstChild(id)
 if map and map:FindFirstChild("Geometry") then return map,mode,id end
end
function Library.PhotoCatalog()
 local out={}
 for _,mode in {"Arena","CTF","GetOut"} do
  local root=mode=="CTF" and game.ServerStorage:FindFirstChild("CTFMaps") or Library.Root(mode)
  if root then for _,map in root:GetChildren() do
   local key=mode.."/"..map.Name
   if Library.PhotoGet(key) then table.insert(out,{id=key,name=map:GetAttribute("DisplayName") or map.Name,mode=mode,order=map:GetAttribute("SortOrder") or 100}) end
  end end
 end
 table.sort(out,function(a,b) if a.mode~=b.mode then return a.mode<b.mode end if a.order~=b.order then return a.order<b.order end return a.name<b.name end)
 return out
end
return Library

