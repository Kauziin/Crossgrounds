return function(t)
 local History=require(game.ServerScriptService.Crossgrounds.ShotHistory)
 t.test("client timestamps cannot choose arbitrary rewind",function()
  t.expect.truthy(math.abs(History.Time(100,0,0)-(99.95-1/60))<.0001)
  t.expect.truthy(math.abs(History.Time(100,1000,0)-(100-1/60))<.0001)
  t.expect.truthy(History.Time(100,0,10)>=99.65)
  t.expect.truthy(math.abs(History.Time(100,99.85,.3)-99.69)<.0001)
 end)
 t.test("oriented box intersection preserves range and direction",function()
  local cf=CFrame.new(10,0,0)*CFrame.Angles(0,.4,0)
  local distance=History.Box(Vector3.zero,Vector3.xAxis,100,cf,Vector3.new(2,4,2))
  t.expect.truthy(distance>8 and distance<11)
  t.expect.equal(History.Box(Vector3.zero,-Vector3.xAxis,100,cf,Vector3.new(2,4,2)),nil)
  t.expect.equal(History.Box(Vector3.zero,Vector3.xAxis,5,cf,Vector3.new(2,4,2)),nil)
 end)
 t.test("parallel rays outside a hitbox miss",function()
  t.expect.equal(History.Box(Vector3.new(0,3,0),Vector3.xAxis,100,CFrame.new(10,0,0),Vector3.new(2,4,2)),nil)
  local distance=History.Box(Vector3.new(10,0,0),Vector3.xAxis,100,CFrame.new(10,0,0),Vector3.new(2,4,2))
  t.expect.equal(distance,0)
 end)
 t.test("observed pose hints cannot move hitboxes or choose arbitrary time",function()
  History.Start()
  local folder=Instance.new("Folder") folder.Name="PoseHintQA" folder.Parent=workspace
  local model=Instance.new("Model") model.Parent=folder
  local part=Instance.new("Part") part.Name="Head" part.Anchored=true part.Position=Vector3.new(6500,15500,0) part.Parent=model
  local h=Instance.new("Humanoid") h.RequiresNeck=false h.Parent=model
  local ok,err=pcall(function()
   task.wait(.10) local now=workspace:GetServerTimeNow()
   local time,aligned=History.ResolveTime(now,now,0,{part=part,position=part.Position},part.Position-Vector3.xAxis*20,Vector3.xAxis,function() return "target" end)
   t.expect.truthy(aligned) t.expect.truthy(time>=now-History.Window and time<=now)
   local fallback,invalid=History.ResolveTime(now,now,0,{part=part,position=part.Position+Vector3.new(0,100,0)},part.Position-Vector3.xAxis*20,Vector3.xAxis,function() return "target" end)
   t.expect.falsy(invalid) t.expect.equal(fallback,History.Time(now,now,0))
   local _,away=History.ResolveTime(now,now,0,{part=part,position=part.Position},part.Position-Vector3.xAxis*20,-Vector3.xAxis,function() return "target" end)
   t.expect.falsy(away)
   local _,ally=History.ResolveTime(now,now,0,{part=part,position=part.Position},part.Position-Vector3.xAxis*20,Vector3.xAxis,function() return "ignore" end)
   t.expect.falsy(ally)
  end)
  folder:Destroy() if not ok then error(err,0) end
 end)
 t.test("a moving client observation selects a bounded server pose instead of the present miss",function()
  History.Start()
  local Query=require(game.ReplicatedStorage.Crossgrounds.ShotQuery)
  local folder=Instance.new("Folder") folder.Name="MovingPoseQA" folder.Parent=workspace
  local model=Instance.new("Model") model.Parent=folder
  local origin=Vector3.new(6700,15700,0)
  local body=Instance.new("Part") body.Name="Torso" body.Size=Vector3.new(2,4,2) body.Anchored=true body.Position=origin+Vector3.xAxis*25 body.Parent=model
  local root=Instance.new("Part") root.Name="HumanoidRootPart" root.Anchored=true root.Transparency=1 root.CanQuery=false root.Position=body.Position root.Parent=model
  local h=Instance.new("Humanoid") h.RequiresNeck=false h.Parent=model
  local ok,err=pcall(function()
   local deadline=os.clock()+2
   repeat task.wait() until History.ObservedAt(model) or os.clock()>deadline
   local at=History.ObservedAt(model) assert(at,"missing initial pose")
   local observed=body.Position
   body.Position+=Vector3.new(0,0,5) root.Position=body.Position
   repeat task.wait() until (History.ObservedAt(model) or 0)>at or os.clock()>deadline
   -- Fixed test clock keeps the alignment contract independent of Studio startup hitches.
   local now=at+.045
   local classify=function(m) return m==model and "target" or "block" end
   local time,aligned=History.ResolveTime(now,now,0,{part=body,position=observed},origin,Vector3.xAxis,classify)
   t.expect.truthy(aligned) t.expect.truthy(math.abs(time-History.Time(now,now,0))<=History.AlignmentWindow+.0001)
   local options={origin=origin,direction=Vector3.xAxis,range=100,classify=classify}
   t.expect.equal(Query.Trace(options).hits,0) t.expect.equal(History.Trace(options,time).hits,1)
   local wall=Instance.new("Part") wall.Anchored=true wall.Size=Vector3.new(1,10,10) wall.Position=origin+Vector3.xAxis*10 wall.Parent=folder
   t.expect.equal(History.Trace(options,time).hits,0)
  end)
  folder:Destroy() if not ok then error(err,0) end
 end)
 local function fixture(fn)
  History.Start()
  local folder=Instance.new("Folder") folder.Name="HistoryQA" folder.Parent=workspace
  local origin=Vector3.new(7000,15000,0) local models={}
  for i=1,2 do
   local model=Instance.new("Model") model.Name="HistoryTarget"..i model.Parent=folder
   local root=Instance.new("Part") root.Name="HumanoidRootPart" root.Size=Vector3.new(2,4,2) root.Anchored=true root.Position=origin+Vector3.new(i*20,0,0) root.Parent=model
   local h=Instance.new("Humanoid") h.RequiresNeck=false h.MaxHealth=500 h.Health=500 h.Parent=model
   table.insert(models,model)
  end
  local deadline=os.clock()+3
  repeat task.wait() until History.ObservedAt(models[1]) or os.clock()>deadline
  local time=History.ObservedAt(models[1]) assert(time,"history sample unavailable")
  for _,model in models do model.HumanoidRootPart.Position+=Vector3.new(0,0,8) end
  repeat task.wait() until (History.ObservedAt(models[1]) or 0)>time or os.clock()>deadline
  local function trace(callback)
   return History.Trace({origin=origin,direction=Vector3.xAxis,range=100,maxTargets=2,penetrationLoss=.2,
    classify=function(model) return table.find(models,model) and model.Humanoid.Health>0 and "target" or "ignore" end,onHit=callback},time)
  end
  local ok,err=pcall(fn,trace,models,folder,origin) folder:Destroy() if not ok then error(err,0) end
 end
 t.test("history restores moving hitboxes but current walls still block",function()
  fixture(function(trace,_,folder,origin)
   t.expect.equal(trace().hits,2)
   local wall=Instance.new("Part") wall.Anchored=true wall.Size=Vector3.new(1,10,10) wall.Position=origin+Vector3.new(10,0,0) wall.Parent=folder
   local result=trace() t.expect.equal(result.hits,0) t.expect.equal(result.reason,"wall")
  end)
 end)
 t.test("history preserves penetration loss and protected target blocking",function()
  fixture(function(trace,models)
   local multipliers={}
   local result=trace(function(_,model,_,multiplier) table.insert(multipliers,multiplier) model.Humanoid:TakeDamage(100*multiplier) return true end)
   t.expect.equal(result.hits,2) t.expect.equal(multipliers[1],1) t.expect.equal(multipliers[2],.8)
   t.expect.equal(models[1].Humanoid.Health,400) t.expect.equal(models[2].Humanoid.Health,420)
   local protected=trace(function() return false end) t.expect.equal(protected.hits,0) t.expect.equal(protected.reason,"protected")
  end)
 end)
 t.test("history never resurrects a dead target or crosses a large teleport",function()
  fixture(function(trace,models)
   models[1].Humanoid.Health=0 models[2].HumanoidRootPart.Position+=Vector3.new(0,0,100)
   local at=History.ObservedAt(models[2]) local deadline=os.clock()+3
   repeat task.wait() until (History.ObservedAt(models[2]) or 0)>at or os.clock()>deadline
   t.expect.equal(trace().hits,0)
  end)
 end)
end
