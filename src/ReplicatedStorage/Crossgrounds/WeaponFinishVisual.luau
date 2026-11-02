local Catalog=require(script.Parent.WeaponFinishCatalog)
local V={}
function V.Apply(model,id)
 local finish=Catalog.Items[id]if not finish then return false end
 for _,p in model:GetDescendants()do if p:IsA("BasePart")then
  local original=p:GetAttribute("FinishOriginalColor")
  if original then p.Color=original end
  local name=p.Name:lower()
  local excluded=p.Transparency>.1 or p.Material==Enum.Material.Glass or p.Material==Enum.Material.Neon or name:find("lens",1,true)or name:find("sight",1,true)or name:find("bullet",1,true)or name:find("shell",1,true)or name:find("hitbox",1,true)
  if id~="default"and not excluded then
   if not original then p:SetAttribute("FinishOriginalColor",p.Color)end
   local hash=0 for i=1,#name do hash=(hash*31+name:byte(i))%65521 end
   p.Color=Color3.fromRGB(table.unpack(hash%3==0 and finish.b or finish.a))
  end
 end end
 model:SetAttribute("WeaponFinish",id)return true
end
return V
