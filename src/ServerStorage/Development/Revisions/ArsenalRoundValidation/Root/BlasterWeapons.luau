local Weapons={}
local Kits=require(game.ReplicatedStorage.KitDefinitions)
function Weapons.Create(id)
 local data=Kits.Weapons[id] assert(data and data.SourcePack=="ProjectileTest","Unknown blaster")
 local tool=game.ReplicatedStorage.Crossgrounds.ProjectileTest.Tools[id]:Clone()
 tool.Name=data.Name tool.CanBeDropped=false
 tool:SetAttribute("WeaponId",id) tool:SetAttribute("WeaponKind","Gun") tool:SetAttribute("SourcePack","ProjectileTest")
 tool:SetAttribute("TwoHanded",false) tool:SetAttribute("ModelVersion",1)
 tool:SetAttribute("Ammo",data.Magazine) tool:SetAttribute("ReserveAmmo",data.Reserve) tool:SetAttribute("Reloading",false)
 tool:SetAttribute("ShotSeed",Random.new():NextInteger(1,2147483646)) tool:SetAttribute("ShotAmmoVersion",1)
 local h=tool.Handle h.Transparency=1
 for _,v in tool:GetDescendants() do if v:IsA("BasePart") then v.Anchored=false v.CanCollide=false v.CanTouch=false v.CanQuery=false v.Massless=true end end
 local source=h:FindFirstChild("MuzzleAttachment",true) or tool:FindFirstChild("MuzzleAttachment",true)
 local muzzle=Instance.new("Attachment") muzzle.Name="Muzzle" muzzle.CFrame=source and h.CFrame:ToObjectSpace(source.WorldCFrame) or CFrame.new(0,0,-2) muzzle.Parent=h
 tool:SetAttribute("RestGrip",tool.Grip)
 return tool
end
return Weapons
