-- Only geometry and appearance are copied. Imported code is never required or cloned.
local Root=game.ReplicatedStorage.Crossgrounds
local Registry=require(Root.WeaponAssetRegistry) local Catalog=require(Root.WeaponCatalog)
local Attachments=require(Root.AttachmentCatalog) local Config=require(Root.WeaponVisualConfiguration)
local Visuals={}
local function resolve(id)
 local path=Registry[id] local v=game
 if not path then return end
 for _,name in path do v=v:FindFirstChild(name) if not v then return end end return v
end
local function geometry(source,origin,rotation)
 local model=Instance.new("Model") model.Name=source.Name
 local items=source:GetDescendants() if source:IsA("BasePart") then table.insert(items,source) end
 for _,p in items do if p:IsA("BasePart") then
  local copy=p:Clone()
  for _,v in copy:GetDescendants() do if not v:IsA("DataModelMesh") and not v:IsA("SurfaceAppearance") and not v:IsA("Decal") and not v:IsA("Texture") then v:Destroy() end end
  copy.CFrame=rotation*(CFrame.new(origin):Inverse()*p.CFrame)
  copy.Anchored=true copy.CanCollide=false copy.CanTouch=false copy.CanQuery=false copy.Massless=true
  local path=p:GetFullName():lower()
  if path:find("magazine") then copy:SetAttribute("ReloadGroup","Magazine") elseif path:find("bolt") or path:find("slide") or path:find("charging handle") then copy:SetAttribute("ReloadGroup","Slide") end
  copy.Parent=model
 end end return model
end
local function attach(parent,name,cf) local a=Instance.new("Attachment") a.Name=name a.CFrame=cf a.Parent=parent return a end
function Visuals.Build(id,configuration)
 local weapon=Catalog.Get(id) local source=resolve(id)
 if not weapon then source=resolve(id) end
 if not source then
  local templates=Root:FindFirstChild("LoadoutPreviews") local old=templates and templates:FindFirstChild(weapon and weapon.assetId or id)
  return old and old:Clone() or nil,"Asset indisponível."
 end
 local cf,size if source:IsA("Model") then cf,size=source:GetBoundingBox() elseif source:IsA("BasePart") then cf,size=source.CFrame,source.Size else
  local temporary=geometry(source,Vector3.zero,CFrame.new())
  if #temporary:GetChildren()==0 then temporary:Destroy() return nil,"Modelo sem geometria." end
  cf,size=temporary:GetBoundingBox() temporary:Destroy()
 end
 local grip=source:FindFirstChild(id=="m1911" and "Grips" or "Grip",true)
 local origin=grip and grip:IsA("BasePart") and grip.Position or cf.Position
 local model=geometry(source,origin,CFrame.Angles(0,-math.pi/2,0)) model.Name=id
 if #model:GetChildren()==0 then model:Destroy() return nil,"Modelo vazio." end
 local handle=Instance.new("Part") handle.Name="Handle" handle.Size=Vector3.new(.2,.5,.25) handle.Transparency=1 handle.Anchored=true handle.CanCollide=false handle.CanTouch=false handle.CanQuery=false handle.Parent=model model.PrimaryPart=handle
 attach(handle,"RightHandGrip",CFrame.Angles(-math.pi/2,0,0))
 attach(handle,"SupportGrip",CFrame.new(-.15,.45,id=="m1911" and -.2 or -2.2)*CFrame.Angles(-math.pi/2,0,math.pi/2))
 attach(handle,"Muzzle",CFrame.new(0,id=="m1911" and .46 or .8,id=="m1911" and -1.4 or -4.12))
 if id=="m4a1" then
  attach(handle,"optic",CFrame.new(0,1.12,-.9)) attach(handle,"muzzle",CFrame.new(0,.8,-4.12)) attach(handle,"underbarrel",CFrame.new(0,.62,-2.4))
 end
 if weapon then
  local clean,err=Config.Validate(id,configuration or {},false) if not clean then model:Destroy() return nil,err end
  for slot,attachmentId in clean do
   local src=resolve(attachmentId) local mount=handle:FindFirstChild(slot)
   if not src or not mount then model:Destroy() return nil,"Ponto de montagem ausente." end
   local bound=src:IsA("Model") and select(1,src:GetBoundingBox()) or src.CFrame
   local accessory=geometry(src,bound.Position,CFrame.Angles(0,-math.pi/2,0))
   local ac,sz=accessory:GetBoundingBox()
   local anchor=slot=="optic" and ac.Position-Vector3.new(0,sz.Y*.5,0) or slot=="underbarrel" and ac.Position+Vector3.new(0,sz.Y*.5,0) or ac.Position+Vector3.new(0,0,sz.Z*.5)
   for _,p in accessory:GetChildren() do if p:IsA("BasePart") then p.CFrame=mount.WorldCFrame*CFrame.new(-anchor)*p.CFrame p.Name="Accessory_"..attachmentId.."_"..p.Name p:SetAttribute("VisualAttachmentId",attachmentId) p.Parent=model end end accessory:Destroy()
   if slot=="optic" then for _,p in model:GetChildren() do if p.Name=="Rear Sight" or p.Name=="Front Sight" then p.Transparency=1 end end end
  end
 end
 model:SetAttribute("VisualWeaponId",id) return model
end
function Visuals.Apply(tool,id,configuration)
 local weapon=Catalog.Get(id) if not weapon or weapon.sourcePack=="Crossgrounds" then return tool end
 local model,err=Visuals.Build(id,configuration) if not model then return nil,err end
 local handle=tool:FindFirstChild("Handle") if not handle then model:Destroy() return nil,"Handle ausente." end
 local original=handle.CFrame
 for _,v in tool:GetChildren() do if v:IsA("BasePart") and v~=handle then v:Destroy() end end
 for _,v in model.Handle:GetChildren() do if v:IsA("Attachment") then local old=handle:FindFirstChild(v.Name) if old then old:Destroy() end v:Clone().Parent=handle end end
 for _,p in model:GetChildren() do if p:IsA("BasePart") and p~=model.Handle then
  p.CFrame=original*p.CFrame p.Anchored=false p.Parent=tool
  local joint=Instance.new("Motor6D") joint.Name=p:GetAttribute("ReloadGroup") or "VisualPart" joint.Part0=handle joint.Part1=p joint.C0=original:ToObjectSpace(p.CFrame) joint.Parent=p
 end end
 tool.Name=weapon.name tool.ToolTip=weapon.name.." · adaptação visual; regras atuais preservadas"
 tool:SetAttribute("VisualWeaponId",id) tool:SetAttribute("VisualConfiguration",game.HttpService:JSONEncode(configuration or {})) tool:SetAttribute("TwoHanded",true)
 model:Destroy() return tool
end
return Visuals
