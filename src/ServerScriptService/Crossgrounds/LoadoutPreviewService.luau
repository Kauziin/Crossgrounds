-- Build missing static menu assets once per server; never rebuild on menu navigation.
local Service={}
function Service.Start()
 local root=game.ReplicatedStorage.Crossgrounds
 local assets=root:FindFirstChild("LoadoutPreviews") or Instance.new("Folder") assets.Name="LoadoutPreviews" assets.Parent=root
 local Kits=require(game.ReplicatedStorage.KitDefinitions)
 local Factory=require(game.ServerScriptService.MainGameScript.GameManager.WeaponFactory)
 local wanted={}
 for _,id in Kits.Order do for _,weapon in Kits.Profiles[id].Weapons do wanted[weapon]=true end end
 for id in wanted do if not assets:FindFirstChild(id) then
  local tool=Factory:Create(id)
  if tool then
   local model=Instance.new("Model") model.Name=id
   for _,v in tool:GetDescendants() do if v:IsA("BasePart") then
    local part=v:Clone()
    for _,child in part:GetChildren() do if not child:IsA("DataModelMesh") and not child:IsA("SurfaceAppearance") and not child:IsA("Decal") and not child:IsA("Texture") then child:Destroy() end end
    part.Anchored=true part.CanCollide=false part.CanTouch=false part.CanQuery=false part.Parent=model
   end end
   tool:Destroy() model.Parent=assets
  end
  task.wait()
 end end
end
return Service
