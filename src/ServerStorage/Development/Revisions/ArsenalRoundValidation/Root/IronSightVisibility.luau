-- Imported weapons use several names for native irons. Never match an added optic
-- or an integrated receiver/rail, even when their names contain "sight".
local Visibility={}
function Visibility.IsName(name)
 local n=name:lower():gsub('[^%w]','')
 if n:find('rail',1,true) or n:find('receiver',1,true) or n:find('scope',1,true) or n:find('optic',1,true) or n:find('laser',1,true) then return false end
 if n:match('^frontsight') or n:match('^rearsight') or n:match('^fliprearsight') or n:match('^frontiron') or n:match('^reariron') or n:match('^backiron') or n:match('^ironsight') or n:match('^rearglowsight') then return true end
 return n=='iron' or n=='sight' or n=='sights' or n=='sightbase' or n=='sightsbase' or n=='basesight' or n=='sightpart' or n=='sightparts' or n=='sightpost' or n=='ringsight' or n=='barrelsight' or n=='sightrib' or n=='sightend' or n=='sightmark' or n:match('^sightsaaaa')~=nil
end
function Visibility.IsSourcePart(part,root)
 local p=part
 while p do
  if p:GetAttribute('VisualAttachmentId') then return false end
  if p:GetAttribute('IronSightPart')==true or Visibility.IsName(p.Name) then return true end
  if p==root then break end p=p.Parent
 end
 return false
end
function Visibility.Apply(model,equipped)
 for _,p in model:GetDescendants() do if p:IsA('BasePart') and not p:GetAttribute('VisualAttachmentId') and p:GetAttribute('IronSightPart') then
  if p:GetAttribute('IronSightOriginalTransparency')==nil then p:SetAttribute('IronSightOriginalTransparency',p.Transparency) end
  p:SetAttribute('IronSightHidden',equipped==true)
  p.Transparency=equipped and 1 or p:GetAttribute('IronSightOriginalTransparency')
  for _,v in p:GetDescendants() do if v:IsA('Decal') or v:IsA('Texture') then
   if v:GetAttribute('IronSightOriginalTransparency')==nil then v:SetAttribute('IronSightOriginalTransparency',v.Transparency) end
   v.Transparency=equipped and 1 or v:GetAttribute('IronSightOriginalTransparency')
  end end
 end end
end
return Visibility
