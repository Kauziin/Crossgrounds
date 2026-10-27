-- Shared ray/sphere queries. Caller decides authority and damage.
local Ballistics={}
local Shot=require(script.Parent.ShotMath)
function Ballistics.ModelFromPart(part)
 local node=part
 while node and node~=workspace do
  if node:IsA("Model") and node:FindFirstChildOfClass("Humanoid") then return node end
  node=node.Parent
 end
end
-- Hats and invisible rig roots are not damage hitboxes.
function Ballistics.IsBodyPart(part,model)
 if not part:IsA("BasePart") or part.Parent~=model then return false end
 if part.Name=="HumanoidRootPart" and (model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")) then return false end
 return true
end
function Ballistics.Trace(options)
 local origin=options.origin local direction=options.direction
 if not Shot.Finite(origin) or not Shot.Finite(direction) or direction.Magnitude<.0001 then return {endpoint=origin,hits=0,reason="direction"} end
 local range=math.clamp(options.range,0,15000) local ray=direction.Unit*range
 local ignored={} if options.shooter then table.insert(ignored,options.shooter) end
 for _,value in options.ignore or {} do table.insert(ignored,value) end
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
 local limit=math.clamp(options.maxTargets or 1,1,8) local hits=options.hitOffset or 0
 local cast=options.raycast or function(o,d,filter)
  if (options.radius or 0)>0 then
   if options.initial and not options.spherecast then
    local overlap=OverlapParams.new() overlap.FilterType=filter.FilterType overlap.FilterDescendantsInstances=filter.FilterDescendantsInstances
    for _,part in workspace:GetPartBoundsInRadius(o,options.radius,overlap) do
     local surface=part:GetClosestPointOnSurface(o) local offset=o-surface
     if offset.Magnitude<=options.radius then
      return {Instance=part,Position=o,Distance=0,Normal=offset.Magnitude>.0001 and offset.Unit or -d.Unit,Material=part.Material}
     end
    end
   end
   return (options.spherecast or function(a,r,b,p) return workspace:Spherecast(a,r,b,p) end)(o,options.radius,d,filter)
  end
  return workspace:Raycast(o,d,filter)
 end
 for _=1,64 do
  params.FilterDescendantsInstances=ignored
  local result=cast(origin,ray,params)
  if not result then return {endpoint=origin+ray,hits=hits,reason="range"} end
  local model=Ballistics.ModelFromPart(result.Instance)
  local relation=model and options.classify(model) or "block"
  if model and not Ballistics.IsBodyPart(result.Instance,model) then table.insert(ignored,result.Instance:FindFirstAncestorOfClass("Accessory") or result.Instance)
  elseif relation=="ignore" then table.insert(ignored,model)
  elseif relation=="target" then
   local index=hits+1 local multiplier=(1-(options.penetrationLoss or 0))^(index-1)
   local accepted=not options.onHit or options.onHit(result,model,index,multiplier,(options.distanceOffset or 0)+(result.Position-origin).Magnitude)
   if not accepted then return {endpoint=result.Position,hits=hits,reason="protected",result=result} end
   hits=index
   if hits>=limit then return {endpoint=result.Position,hits=hits,reason="targets",result=result} end
   table.insert(ignored,model)
  else return {endpoint=result.Position,hits=hits,reason="wall",result=result} end
 end
 return {endpoint=origin,hits=hits,reason="iteration_limit"}
end
local function finite(v)
 return typeof(v)=="Vector3" and v.X==v.X and v.Y==v.Y and v.Z==v.Z and v.Magnitude<100000
end
-- FP origins are constrained near the head and behind a cover check, never trusted blindly.
function Ballistics.ResolveOrigin(character,tool,aim,requested,classify,cast)
 local head=character:FindFirstChild("Head") if not head then return end
 local handle=tool:FindFirstChild("Handle") local muzzle=handle and handle:FindFirstChild("Muzzle")
 local origin=muzzle and muzzle.WorldPosition or head.Position
 if (origin-head.Position).Magnitude>8 then origin=head.Position end
 if not finite(aim) then return end
 local aimDelta=aim-head.Position
 if finite(requested) and aimDelta.Magnitude>.05 then
  local offset=requested-head.Position local axial=offset:Dot(aimDelta.Unit)
  local radial=(offset-aimDelta.Unit*axial).Magnitude
  if offset.Magnitude<=6.5 and axial>=-1 and axial<=6 and radial<=2 then origin=requested end
 end
 local delta=origin-head.Position
 if delta.Magnitude>.01 then
  local check=Ballistics.Trace({origin=head.Position,direction=delta,range=delta.Magnitude,shooter=character,raycast=cast,
   classify=function(model) return classify(model)=="ignore" and "ignore" or "block" end})
  if check.result then return origin,check.result end
 end
 return origin
end
return Ballistics
