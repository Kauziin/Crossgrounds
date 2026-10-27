-- Manual Edit-mode utility. Reparents known authoring assets without cloning/deleting them.
local Organizer={}
local LIMIT=400
local function folder(parent,name)
 local found=parent:FindFirstChild(name)
 if found then assert(found:IsA("Folder"),"Destination is not a folder: "..found:GetFullName()) return found end
 local value=Instance.new("Folder") value.Name=name value.Parent=parent return value
end
local function hash(text)
 local value=0
 for i=1,#text do value=(value*31+text:byte(i))%4294967296 if i%200000==0 then task.wait() end end
 return value
end
local function signature(root)
 local rows={} local prefix=#root:GetFullName()+2 local descendants=root:GetDescendants()
 for i,v in descendants do
  local path=v:GetFullName():sub(prefix)
  if v:IsA("BasePart") then table.insert(rows,path.."|"..v.ClassName.."|"..tostring(v.CFrame).."|"..tostring(v.Size))
  elseif v:IsA("LuaSourceContainer") then table.insert(rows,path.."|"..v.Source) end
  if i%5000==0 then task.wait() end
 end
 if root:IsA("LuaSourceContainer") then table.insert(rows,"|"..root.Source) end
 table.sort(rows)
 return #descendants,hash(table.concat(rows,"\0"))
end
local function moveBounded(root,parent,name)
 assert(not parent:FindFirstChild(name),"Destination already exists: "..name)
 local count,digest=signature(root)
 local scratch=Instance.new("Folder") scratch.Name="_StorageOrganizationStaging" scratch.Parent=game.ServerStorage
 local groups={} local pivots={} local work=0
 local function yieldAfter(size) work+=size if work>=1000 then work=0 task.wait() end end
 local function peel(node)
  if #node:GetDescendants()<=LIMIT then return end
  if node:IsA("Model") then table.insert(pivots,{node=node,primary=node.PrimaryPart,pivot=node.WorldPivot}) end
  local children=node:GetChildren()
  for _,child in children do
   peel(child)
   local size=#child:GetDescendants()+1 assert(size<=LIMIT+1,"Move batch too large")
   child.Parent=scratch yieldAfter(size)
  end
  table.insert(groups,{parent=node,children=children})
 end
 peel(root)
 root.Name=name root.Parent=parent
 for i=#groups,1,-1 do
  local group=groups[i]
  for _,child in group.children do
   local size=#child:GetDescendants()+1 assert(size<=LIMIT+1,"Restore batch too large")
   child.Parent=group.parent yieldAfter(size)
  end
 end
 for _,saved in pivots do saved.node.PrimaryPart=saved.primary saved.node.WorldPivot=saved.pivot end
 assert(#scratch:GetChildren()==0,"Unrestored authoring assets remain") scratch:Destroy()
 local afterCount,afterDigest=signature(root)
 assert(count==afterCount and digest==afterDigest,"Authoring hierarchy or geometry changed")
 return {path=root:GetFullName(),descendants=count,verified=true}
end
function Organizer.Run()
 assert(not game:GetService("RunService"):IsRunning(),"Stop Play before organizing storage")
 local storage=game.ServerStorage local development=folder(storage,"Development")
 local tools=folder(development,"Tools") local assets=folder(development,"Assets")
 local moves={
  {"CrossgroundsMapSources",development,"MapSources"},
  {"CrossgroundsAudioSources",assets,"AudioSources"},
  {"CrossgroundsImportedAssets",assets,"ImportedModels"},
  {"KitTools",assets,"KitTools"},
  {"CrossgroundsMapTools",tools,"MapTools"},
  {"GetOutFacilityAuthoring",tools,"GetOutFacilityAuthoring"},
  {"GetOutSliceAuthoring",tools,"GetOutSliceAuthoring"},
 }
 local result={}
 for _,move in moves do
  local source=storage:FindFirstChild(move[1])
  if source then table.insert(result,moveBounded(source,move[2],move[3])) end
 end
 return result
end
return Organizer
