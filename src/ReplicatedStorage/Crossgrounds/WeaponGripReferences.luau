-- Source-space references for MW models without a separate Grip mesh.
-- Offsets are balance/art calibration in source studs, not ballistic statistics.
local API={}
local triggerOffset=Vector3.new(.25,-.18,0)
API.Profiles={
 aug={support={"Grip"},supportOffset=Vector3.zero},
 cr_56_amax={support={"Rail Covers"}},
 jak_12={support={"Handguard"}},
 mk2_carbine={support={"Handguard"}},
 simonov={support={"Base"},supportOffset=Vector3.new(-.9,.25,0)},
 dragunov={support={"Handguard"}},
 ebr14={support={"Base"},supportOffset=Vector3.new(-1.4,.20,0)},
 holger_26={support={"Handguard Part"}},
 sp_r_208={support={"Chassis"},supportOffset=Vector3.new(-.45,-.25,0)},
 ["725"]={support={"Handguard"}},
 bruen_mk9={origin={"Grip (Placeholder)"},originOffset=Vector3.zero,support={"Handguard"}},
 kar98k={supportFromOrigin=Vector3.new(-2.25,.24,0)},
 fal={support={"Handguard"}},
 model_680={origin={"Default Stock"},originOffset=Vector3.new(-.95,.18,0),support={"Pump"}},
 oden={support={"Handguard"}},
 p90={support={"Trigger"},supportOffset=Vector3.new(-.65,-.08,0)},
 mp7={support={"Bottom Rail"}},
 ram_7={origin={"Back Grip"},originOffset=Vector3.zero,support={"Handguard"}},
 mp5={support={"Surefire Handguard","Base"}},
}
local function part(source,path,largest)
 local node=source
 for _,name in path do node=node:FindFirstChild(name) if not node then return nil end end
 if largest then
  for _,p in source:GetChildren() do
   if p:IsA("BasePart") and p.Name==node.Name and p.Size.X>node.Size.X then node=p end
  end
 end
 return node:IsA("BasePart") and node or nil
end
function API.Resolve(source,id)
 local profile=API.Profiles[id] if not profile then return nil end
 local grip=assert(part(source,profile.origin or {"Trigger"}),"Missing grip reference: "..id)
 local origin=grip.Position+(profile.originOffset or triggerOffset)
 if profile.supportFromOrigin then return origin,origin+profile.supportFromOrigin end
 local support=assert(part(source,profile.support,profile.largestSupport),"Missing support reference: "..id)
 local offset=profile.supportOffset or Vector3.new(0,-support.Size.Y*.5,0)
 return origin,support.Position+offset
end
return API
