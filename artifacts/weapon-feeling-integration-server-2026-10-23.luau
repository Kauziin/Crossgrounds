-- Temporary Studio integration fixture; removed from the DataModel after QA.
local Players=game:GetService("Players")
local p=Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
task.wait(3)
local root=game.ServerScriptService.MainGameScript.GameManager
local bootstrap=require(game.ServerScriptService.Crossgrounds.HubBootstrap)
local ctf=bootstrap.Coordinator.adapters.ctf
assert(ctf:Enter(p))
local Kit=require(root.KitService) local Damage=require(root.DamageService)
local folder=Instance.new("Folder") folder.Name="WeaponFeelingFixtures" folder.Parent=workspace
local remote=Instance.new("RemoteFunction") remote.Name="WeaponFeelingQA" remote.Parent=game.ReplicatedStorage
local target local c
local function configure(id)
 c=p.Character p:SetAttribute("SelectedKit",id) Kit:ApplyToCharacter(p,c)
 p.Team=game.Teams.Blue p:SetAttribute("InArena",true) c:SetAttribute("AtLobby",false)
 c.HumanoidRootPart.Anchored=true c:SetAttribute("SpawnProtectedUntil",0)
 for _,f in c:GetChildren() do if f:IsA("ForceField") then f:Destroy() end end
 task.wait(.15)
end
configure("Invasor")
remote.OnServerInvoke=function(player,op,payload)
 assert(player==p)
 if op=="configure" then configure(payload) return true
 elseif op=="prepare" then
  folder:ClearAllChildren()
  local origin=payload.origin local direction=payload.direction.Unit assert((origin-c.Head.Position).Magnitude<20)
  target=Instance.new("Model") target.Name="QA Enemy" target:SetAttribute("CTFBot",true) target:SetAttribute("CTFTeam","Red") target.Parent=folder
  local body=Instance.new("Part") body.Name="Torso" body.Size=Vector3.new(18,18,2) body.Anchored=true body.CFrame=CFrame.lookAt(origin+direction*22,origin) body.Parent=target
  local h=Instance.new("Humanoid") h.RequiresNeck=false h.MaxHealth=10000 h.Health=10000 h.Parent=target
  local r=Instance.new("Part") r.Name="HumanoidRootPart" r.Size=Vector3.one r.Anchored=true r.CanCollide=false r.Transparency=1 r.CFrame=body.CFrame r.Parent=target
  Damage:Watch(target) task.wait(.12)
  return {part=body,position=body.Position}
 elseif op=="snapshot" then
  local t=c:FindFirstChildOfClass("Tool")
  return {ammo=t and t:GetAttribute("Ammo"),reserve=t and t:GetAttribute("ReserveAmmo"),health=target and target.Humanoid.Health,
   reloading=t and t:GetAttribute("Reloading"),aligned=t and t:GetAttribute("LastShotViewAligned")}
 elseif op=="wall" then
  local wall=Instance.new("Part") wall.Anchored=true wall.Size=Vector3.new(24,24,1) wall.CFrame=CFrame.lookAt(payload.origin+payload.direction*5,payload.origin) wall.Parent=folder return true
 elseif op=="kill" then
  folder:ClearAllChildren()
  target=Instance.new("Model") target.Name="QA Eliminator" target:SetAttribute("CTFBot",true) target:SetAttribute("CTFTeam","Red") target.Parent=folder
  local r=Instance.new("Part") r.Name="HumanoidRootPart" r.Anchored=true r.CFrame=c.HumanoidRootPart.CFrame*CFrame.new(8,0,-8) r.Parent=target
  local h=Instance.new("Humanoid") h.RequiresNeck=false h.Parent=target
  c.HumanoidRootPart.Anchored=false c.Humanoid.Health=20 c:SetAttribute("SpawnProtectedUntil",0)
  for _,f in c:GetChildren() do if f:IsA("ForceField") then f:Destroy() end end
  assert(Damage:Deal(target,c.Humanoid,100,"Rifle",false),"death was rejected") return c
 elseif op=="report" then
  local v=game.ServerStorage:FindFirstChild("WeaponFeelingClientResults") or Instance.new("StringValue")
  v.Name="WeaponFeelingClientResults" v.Value=game.HttpService:JSONEncode(payload) v.Parent=game.ServerStorage return true
 elseif op=="finish" then
  folder:Destroy() return true
 end
end

