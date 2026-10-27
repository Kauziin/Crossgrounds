-- Structural checks for maps opting in to the v0.5 P0 traversal contract.
local Validator={}
function Validator.Read(map,manifest)
 if manifest.root:GetAttribute("TraversalVersion")~=1 then return false,{"Mapa ainda não preparado para o núcleo de perseguição v0.5."} end
 local traversal=manifest.root:FindFirstChild("Traversal")
 if not traversal then return false,{"Traversal descriptors missing"} end
 local errors={} local counts={RegularDoor=0,Vent=0,Window=0,HideSpot=0}
 for _,m in traversal:GetChildren() do
  local kind=m:GetAttribute("Kind")
  if not m:IsA("BasePart") or not counts[kind] then table.insert(errors,"Invalid traversal marker: "..m.Name)
  else
   counts[kind]+=1
   if kind=="RegularDoor" then
    local matches=0 for _,p in map.Geometry:GetDescendants() do if p:IsA("BasePart") and p:GetAttribute("RegularDoorId")==m:GetAttribute("DoorId") then matches+=1 end end
    if typeof(m:GetAttribute("Hinge"))~="CFrame" or matches~=1 then table.insert(errors,"Door pivot/leaf invalid: "..m.Name) end
   elseif kind=="Vent" then
    if typeof(m:GetAttribute("Entrance"))~="Vector3" or typeof(m:GetAttribute("Exit"))~="Vector3" or m:GetAttribute("HumanOnly")~=true or m:GetAttribute("RequiresCrawl")~=true or (m:GetAttribute("MinimumClearance") or 0)<2 then table.insert(errors,"Vent connection/clearance invalid") end
   end
  end
 end
 for kind,n in counts do if n<1 then table.insert(errors,"P0 requires "..kind) end end
 local data=manifest.routes.locks
 if data then
  for id,pc in data.computers do
   local positions={}
   for _,a in pc:GetChildren() do if a:IsA("Attachment") and a.Name:match("^HackSlot") then
    for _,position in positions do if (a.Position-position).Magnitude<2.5 then table.insert(errors,"Overlapping hack slots: "..id) end end
    table.insert(positions,a.Position)
   end end
   if #positions<1 or #positions>3 then table.insert(errors,"Invalid hack slots: "..id) end
  end
  for id,pod in data.pods do if not pod:FindFirstChild("RescueExit") then table.insert(errors,"Rescue clearance marker missing: "..id) end end
 end
 return #errors==0,errors
end
return Validator
