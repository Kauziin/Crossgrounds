-- Shared scene validation for authored and automatically prepared spawn markers.
local Spawns={}
local clearance=Vector3.new(4,5.5,4)
function Spawns.Validate(world,cf)
 local ray=RaycastParams.new() ray.FilterType=Enum.RaycastFilterType.Include ray.FilterDescendantsInstances={world} ray.RespectCanCollide=true
 local floor=workspace:Raycast(cf.Position,Vector3.new(0,-6,0),ray)
 if not floor or floor.Normal.Y<.9 or cf.Position.Y-floor.Position.Y<2.8 then return false end
 local overlap=OverlapParams.new() overlap.FilterType=Enum.RaycastFilterType.Include overlap.FilterDescendantsInstances={world} overlap.RespectCanCollide=true
 for _,part in workspace:GetPartBoundsInBox(cf,clearance,overlap) do if part.CanCollide then return false end end
 return true
end
function Spawns.SafeExits(world,cf)
 local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Include rp.FilterDescendantsInstances={world} rp.RespectCanCollide=true
 local open={}
 for i=0,7 do
  local direction=Vector3.new(math.cos(i*math.pi/4),0,math.sin(i*math.pi/4))
  local target=cf.Position+direction*9
  local blocked=workspace:Raycast(cf.Position,direction*9,rp)
  local floor=workspace:Raycast(target,Vector3.new(0,-7,0),rp)
  if not blocked and floor and floor.Normal.Y>.9 and cf.Y-floor.Position.Y>=2.8 then table.insert(open,i) end
 end
 for _,a in open do for _,b in open do local angle=math.abs(a-b) angle=math.min(angle,8-angle) if angle>=2 then return true,#open end end end
 return false,#open
end
function Spawns.Generate(world,center,size,preferred,limit)
 local ray=RaycastParams.new() ray.FilterType=Enum.RaycastFilterType.Include ray.FilterDescendantsInstances={world} ray.RespectCanCollide=true
 local candidates={}
 local function add(position,look)
  local hit=workspace:Raycast(position+Vector3.new(0,8,0),Vector3.new(0,-34,0),ray)
  if not hit or hit.Normal.Y<.9 or hit.Position.Y>center.Y+8 then return end
  local p=hit.Position+Vector3.new(0,3.6,0)
  local direction=look or Vector3.new(center.X-p.X,0,center.Z-p.Z)
  local cf=direction.Magnitude>.01 and CFrame.lookAt(p,p+direction.Unit) or CFrame.new(p)
  if Spawns.Validate(world,cf) then
   for _,old in candidates do if (old.Position-p).Magnitude<5 then return end end
   table.insert(candidates,cf)
  end
 end
 for _,cf in preferred or {} do add(Vector3.new(cf.X,center.Y,cf.Z),cf.LookVector*Vector3.new(1,0,1)) end
 local step=math.max(8,math.max(size.X,size.Z)/30)
 for x=-size.X*.46,size.X*.46,step do
  for z=-size.Z*.46,size.Z*.46,step do add(center+Vector3.new(x,0,z)) end
  task.wait()
 end
 local selected={}
 if #candidates>0 then table.insert(selected,table.remove(candidates,1)) end
 while #selected<(limit or 24) and #candidates>0 do
  local best,bestDistance=1,-1
  for i,cf in candidates do
   local nearest=math.huge
   for _,old in selected do nearest=math.min(nearest,(old.Position-cf.Position).Magnitude) end
   if nearest>bestDistance then best=i bestDistance=nearest end
  end
  if bestDistance<8 then break end
  table.insert(selected,table.remove(candidates,best))
 end
 return selected,#candidates+#selected
end
function Spawns.InRegions(cf,regions)
 if not regions or #regions:GetChildren()==0 then return true end
 for _,region in regions:GetChildren() do if region:IsA("BasePart") then
  local p=region.CFrame:PointToObjectSpace(cf.Position)
  local half=region.Size*.5
  if math.abs(p.X)<=half.X-2 and math.abs(p.Y)<=half.Y and math.abs(p.Z)<=half.Z-2 then return true end
 end end
 return false
end
return Spawns
