-- A hollow 3D ocular in the FP viewport. Imported closed scope meshes are
-- replaced only in this display; the original world weapon is untouched.
local Optics={}
function Optics.Build(model,entries)
 local lens
 for _,entry in entries do if entry.part.Name=='Lens' then lens=entry break end end
 if not lens then return end
 local min=Vector3.new(math.huge,math.huge,math.huge) local max=-min
 for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
  local p=lens.rest:PointToWorldSpace(lens.part.Size*Vector3.new(x,y,z)*.5)
  min=min:Min(p) max=max:Max(p)
 end end end
 local radius=math.min(max.X-min.X,max.Y-min.Y)*.5
 local center=Vector3.new((min.X+max.X)*.5,(min.Y+max.Y)*.5,max.Z)
 local result={center=center,radius=radius*.91,parts={}}
 for _,entry in entries do
  if entry.part.Name=='Lens' or entry.part.Name=='Scope Base' or entry.part.Name=='Scope Base Pt 2' or entry.part.Name=='Stand' then entry.closedOptic=true end
 end
 -- Two shallow stepped rings preserve an open bore without a long opaque tunnel.
 for layer=1,2 do for i=1,48 do
  local angle=(i-.5)*2*math.pi/48
  local r=radius*(layer==1 and 1.03 or 1.14)
  local p=Instance.new('Part') p.Name='AX50_Ocular'
  p.Size=Vector3.new(radius*.24,2*(r+radius*.13)*math.tan(math.pi/48)*1.01,radius*(layer==1 and .18 or .12))
  p.Color=layer==1 and Color3.fromRGB(25,29,31) or Color3.fromRGB(100,108,113)
  p.Material=Enum.Material.Metal p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false
  local cf=CFrame.new(center+Vector3.new(math.cos(angle)*r,math.sin(angle)*r,layer==1 and 0 or -radius*.22))*CFrame.Angles(0,0,angle)
  p.CFrame=cf p.Parent=model table.insert(result.parts,{part=p,rest=cf})
 end end
 return result
end
function Optics.Alignment(optic,fieldOfView)
 local distance=optic.radius/(math.tan(math.rad(fieldOfView*.5))*.70)+optic.radius*.20
 return CFrame.new(-optic.center.X,-optic.center.Y,-optic.center.Z-distance)
end
function Optics.Project(optic,cf,fieldOfView,viewport)
 local center=cf:PointToWorldSpace(optic.center) local depth=-center.Z
 if depth<=.01 then return end
 local scale=viewport.Y/(2*math.tan(math.rad(fieldOfView*.5))*depth)
 return {point=Vector2.new(viewport.X*.5+center.X*scale,viewport.Y*.5-center.Y*scale),radius=optic.radius*scale}
end
return Optics
