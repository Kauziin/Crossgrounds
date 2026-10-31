-- Command Bar helper, Edit only. Original imports are never edited.
-- local w=require(game.ServerStorage.ArsenalWorkshop); local copy=w.Begin("m4a1")
-- w.Finish(true) stores the edited copy under ServerStorage.ArsenalMigrationWork.Edited.
local Workshop={}
local function editOnly() assert(not game:GetService("RunService"):IsRunning(),"Use apenas em Edit.") end
function Workshop.Begin(id)
 editOnly() assert(not workspace:FindFirstChild("ArsenalEditTemporary"),"Finalize a edição anterior.")
 local model,err=require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals).Build(id,{}) assert(model,err)
 model:SetAttribute("OriginalPivot",model:GetPivot()) model:SetAttribute("OriginalWeaponId",id)
 model.Name="ArsenalEditTemporary" model:PivotTo(CFrame.new(0,10,0)) model.Parent=workspace
 game:GetService("Selection"):Set({model}) return model
end
function Workshop.Finish(keep)
 editOnly() local model=workspace:FindFirstChild("ArsenalEditTemporary") if not model then return end
 if keep then
  local work=game.ServerStorage:WaitForChild("ArsenalMigrationWork") local edited=work:FindFirstChild("Edited") or Instance.new("Folder",work) edited.Name="Edited"
  model:PivotTo(model:GetAttribute("OriginalPivot")) model.Name=model:GetAttribute("OriginalWeaponId").."_"..game.HttpService:GenerateGUID(false) model.Parent=edited
 else model:Destroy() end
 game:GetService("Selection"):Set({})
end
return Workshop
