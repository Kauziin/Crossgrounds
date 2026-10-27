-- Run in Edit mode only. Copies visual geometry from the existing weapon factory.
local Factory=require(game.ServerScriptService.MainGameScript.GameManager.WeaponFactory)
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local root=game.ReplicatedStorage.Crossgrounds
assert(not root:FindFirstChild("LoadoutPreviews"),"Preview library already exists; preserve it before rebuilding")
local library=Instance.new("Folder") library.Name="LoadoutPreviews" library:SetAttribute("Purpose","Read-only loadout menu models") library.Parent=root
local definitions={} for _,id in Kits.ArenaPistolVisuals do table.insert(definitions,{id,"ArenaPistol",id}) end table.insert(definitions,{"Sword","Sword"})
local report={}
for _,entry in definitions do
 local tool=Factory:Create(entry[2],entry[3]) assert(tool,entry[1])
 local model=Instance.new("Model") model.Name=entry[1] model:SetAttribute("DisplayName",tool.Name) model:SetAttribute("WeaponKind",tool:GetAttribute("WeaponKind"))
 local count=0
 for _,part in tool:GetDescendants() do if part:IsA("BasePart") and part.Transparency<.98 then
  local copy=part:Clone()
  for _,child in copy:GetChildren() do if not (child:IsA("DataModelMesh") or child:IsA("SurfaceAppearance") or child:IsA("Decal") or child:IsA("Texture")) then child:Destroy() end end
  copy.Anchored=true copy.CanCollide=false copy.CanTouch=false copy.CanQuery=false copy.Massless=true
  copy.CFrame=tool.Handle.CFrame:ToObjectSpace(part.CFrame) copy.Parent=model count+=1
 end end
 tool:Destroy()
 local box=model:GetBoundingBox() for _,part in model:GetChildren() do part.CFrame-=box.Position end
 model.Parent=library table.insert(report,{id=entry[1],parts=count}) task.wait()
end
return report
