return function(t)
 local AA=require(game.ReplicatedStorage.Crossgrounds.AimAssist)
 local origin=Vector3.zero local forward=Vector3.new(0,0,-1)
 local function candidate(x,z,id) return {id=id or "enemy",point=Vector3.new(x,0,z or -20),size=Vector3.new(2.8,5,2)} end
 local function window(x,distance,id) return AA.Window(origin,forward,candidate(x,-(distance or 20),id),true,500) end
 local function context(look)
  return {origin=origin,dt=1/60,strength=1,slowdown=1,tracking=1,look=look or Vector2.zero,strafe=0,device="gamepad"}
 end
 local function sample(look,distance)
  local state=AA.NewState() local friction,rotation=1,Vector2.zero
  for i=1,45 do friction,rotation=AA.Step(state,window(i*.01,distance),context(look)) end
  return friction,rotation,state
 end
 t.test("allies corpses protection and inactive shooters are rejected",function()
  local state={mode="ctf",health=200,shooterActive=true,targetBot=true}
  t.expect.truthy(AA.Eligible(state))
  for _,key in {"allied","protected"} do state[key]=true t.expect.falsy(AA.Eligible(state)) state[key]=false end
  state.health=0 t.expect.falsy(AA.Eligible(state)) state.health=200 state.shooterActive=false t.expect.falsy(AA.Eligible(state))
  state.shooterActive=true state.mode="hub" t.expect.falsy(AA.Eligible(state))
 end)
 t.test("Arena targets require an active Arena shooter",function()
  t.expect.truthy(AA.Eligible({mode="arena",health=20,shooterActive=true,targetTraining=true}))
  t.expect.falsy(AA.Eligible({mode="arena",health=20,shooterActive=true,targetBot=true}))
 end)
 t.test("walls behind-camera targets and maximum range prevent selection",function()
  local pick=AA.Select(origin,forward,{candidate(0,-340,"far"),candidate(0,40,"back"),candidate(0,-20)},function() return false end,500,true)
  t.expect.equal(pick,nil)
  t.expect.equal(AA.Select(origin,forward,{candidate(0,-301)},function() return true end,500,true),nil)
  t.expect.equal(AA.Select(origin,forward,{candidate(0,40)},function() return true end,500,true),nil)
 end)
 t.test("near body window expands with apparent size rather than a fixed cone",function()
  t.expect.truthy(window(1.3,4))
  t.expect.equal(window(10,100),nil)
 end)
 t.test("anchor follows the player's chosen area instead of the center",function()
  local w=window(1,20) t.expect.truthy(w)
  t.expect.truthy(math.abs(w.point.X)<.001)
  t.expect.equal(w.center.X,1)
 end)
 t.test("stationary targets never attract aim even with right stick or strafe",function()
  local state=AA.NewState() local c=context(Vector2.new(-.2,.1)) c.strafe=1
  for _=1,60 do local _,r=AA.Step(state,window(1,20),c) t.expect.equal(r.Magnitude,0) end
 end)
 t.test("moving target cannot rotate an idle player's camera",function()
  local _,r=sample(Vector2.zero,20) t.expect.equal(r.Magnitude,0)
 end)
 t.test("tracking helps matching input and yields to opposing input",function()
  local _,r=sample(Vector2.new(-.2,0),20) t.expect.truthy(r.X<0)
  local _,opposite=sample(Vector2.new(.2,0),20) t.expect.equal(opposite.Magnitude,0)
 end)
 t.test("tracking contribution is partial and rate-limited at close distance",function()
  local _,r=sample(Vector2.new(-.2,0),4)
  t.expect.truthy(r.Magnitude>0)
  t.expect.truthy(math.abs(r.X)<math.rad(AA.Tuning.MaxYawRate)/60)
 end)
 t.test("distance removes rotation and tapers friction",function()
  local near,rotation=sample(Vector2.new(-.2,0),20)
  local far,farRotation=sample(Vector2.new(-.2,0),270)
  t.expect.truthy(near<far) t.expect.equal(farRotation.Magnitude,0) t.expect.truthy(rotation.Magnitude>0)
 end)
 t.test("zero master and independent component controls work",function()
  local state=AA.NewState() local c=context(Vector2.new(-.2,0)) c.strength=0
  local friction,r=AA.Step(state,window(0,20),c) t.expect.equal(friction,1) t.expect.equal(r.Magnitude,0)
  c.strength=1 c.tracking=0 c.slowdown=0
  for i=1,45 do friction,r=AA.Step(state,window(i*.01,20),c) end
  t.expect.equal(friction,1) t.expect.equal(r.Magnitude,0)
 end)
 t.test("new target has a reaction interval and walls reset assistance immediately",function()
  local state=AA.NewState() local c=context(Vector2.new(-.2,0))
  for i=1,5 do local _,r=AA.Step(state,window(i*.01,20),c) t.expect.equal(r.Magnitude,0) end
  local friction,r=AA.Step(state,nil,c) t.expect.equal(friction,1) t.expect.equal(r.Magnitude,0)
 end)
 t.test("changing the selected enemy does not inherit tracking velocity",function()
  local _,_,state=sample(Vector2.new(-.2,0),20)
  local _,r=AA.Step(state,window(.45,20,"different"),context(Vector2.new(-.2,0)))
  t.expect.equal(r.Magnitude,0)
 end)
 t.test("large frame hitches produce no catch-up jump",function()
  local _,_,state=sample(Vector2.new(-.2,0),20) local c=context(Vector2.new(-.2,0)) c.dt=.2
  local friction,r=AA.Step(state,window(.5,20),c) t.expect.equal(friction,1) t.expect.equal(r.Magnitude,0)
 end)
 t.test("fast manual turns receive less friction",function()
  local soft=sample(Vector2.new(-.2,0),20)
  local fast=sample(Vector2.new(-1,0),20)
  t.expect.truthy(fast>soft)
 end)
 t.test("tracking is consistent across 30 60 and 120 FPS",function()
  local function run(fps)
   local state=AA.NewState() local sum=0 local c=context(Vector2.new(-.2,0)) c.dt=1/fps
   for i=1,fps do local _,r=AA.Step(state,window(i/fps*.6,20),c) sum+=r.X end
   return sum
  end
  local a,b,c=run(30),run(60),run(120)
  t.expect.truthy(math.abs(a-b)<math.abs(b)*.15)
  t.expect.truthy(math.abs(c-b)<math.abs(b)*.15)
 end)
 t.test("matching full stick tracking is not suppressed by fast-look friction escape",function()
  local _,soft=sample(Vector2.new(-.2,0),20)
  local _,full=sample(Vector2.new(-1,0),20)
  t.expect.truthy(soft.X<0)
  t.expect.truthy(math.abs(full.X)>=math.abs(soft.X)*.99)
 end)
 t.test("small filtered corrections keep acquisition without a second deadzone",function()
  local _,r=sample(Vector2.new(-.02,0),20)
  t.expect.truthy(r.X<0)
 end)
 t.test("middle distance tracking remains available with a bounded outer cutoff",function()
  for _,distance in {80,120,200} do
   local _,r=sample(Vector2.new(-.2,0),distance)
   t.expect.truthy(r.X<0)
  end
  local _,far=sample(Vector2.new(-.2,0),270)
  t.expect.equal(far.Magnitude,0)
  t.expect.equal(AA.Window(origin,forward,candidate(0,-301),true,1000),nil)
  t.expect.equal(AA.Window(origin,forward,candidate(0,-120),true,100),nil)
 end)
 t.test("releasing the look stick clears acquired tracking even while strafing",function()
  local _,_,state=sample(Vector2.new(-.2,0),120)
  local c=context(Vector2.zero) c.strafe=1
  local _,r=AA.Step(state,window(.46,120),c)
  t.expect.equal(r.Magnitude,0)
  t.expect.equal(state.age,0)
 end)

 t.test("centering supplies gentle correction to a stationary target during ADS",function()
  local state=AA.NewState() local c=context(Vector2.zero) c.centering=.5 c.aiming=true c.tracking=0
  local r=Vector2.zero
  for _=1,45 do local _,rotation=AA.Step(state,window(1,20),c) r=rotation end
  t.expect.truthy(r.X<0)
  t.expect.truthy(math.abs(r.X)<=math.rad(AA.Tuning.MaxCenteringYawRate)*.5*c.dt+.000001)
 end)
 t.test("centering does not move an idle hip-fire camera",function()
  local state=AA.NewState() local c=context(Vector2.zero) c.centering=1
  for _=1,45 do local _,r=AA.Step(state,window(1,20),c) t.expect.equal(r.Magnitude,0) end
 end)
 t.test("small deliberate look can acquire a stationary target in hip fire",function()
  local state=AA.NewState() local c=context(Vector2.new(-.02,0)) c.centering=.5 c.tracking=0
  local r=Vector2.zero
  for _=1,45 do local _,rotation=AA.Step(state,window(1,20),c) r=rotation end
  t.expect.truthy(r.X<0)
 end)
 t.test("centering yields immediately to deliberate opposing input",function()
  local state=AA.NewState() local c=context(Vector2.new(-.2,0)) c.centering=1 c.aiming=true c.tracking=0
  for _=1,45 do AA.Step(state,window(1,20),c) end
  c.look=Vector2.new(.2,0) local _,r=AA.Step(state,window(1,20),c)
  t.expect.equal(r.Magnitude,0)
 end)
 t.test("full stick turns and a zero centering preference remove attraction",function()
  for _,values in {{look=Vector2.new(-1,0),amount=1},{look=Vector2.new(-.2,0),amount=0}} do
   local state=AA.NewState() local c=context(values.look) c.centering=values.amount c.aiming=true c.tracking=0
   for _=1,45 do local _,r=AA.Step(state,window(1,20),c) t.expect.equal(r.Magnitude,0) end
  end
 end)
 t.test("occlusion and target changes clear centering acquisition",function()
  local state=AA.NewState() local c=context(Vector2.zero) c.centering=1 c.aiming=true
  for _=1,45 do AA.Step(state,window(1,20),c) end
  local _,r=AA.Step(state,nil,c) t.expect.equal(r.Magnitude,0)
  local _,nextRotation=AA.Step(state,window(1,20,"new"),c) t.expect.equal(nextRotation.Magnitude,0)
 end)
 t.test("centering never overshoots the remaining angular error on slow frames",function()
  local state=AA.NewState() local c=context(Vector2.zero) c.centering=1 c.aiming=true c.dt=.1
  local w=window(.001,20)
  for _=1,45 do local _,r=AA.Step(state,w,c) t.expect.truthy(math.abs(r.X)<=math.abs(w.centerError.X)) end
  c.dt=.2 local _,r=AA.Step(state,w,c) t.expect.equal(r.Magnitude,0)
 end)
 t.test("touch centering expires with the look gesture outside ADS",function()
  local Intent=require(game.ReplicatedStorage.Crossgrounds.AimAssistIntent)
  local state=AA.NewState() local c=context(Vector2.new(-.1,0)) c.centering=1 c.device="touch"
  local r=Vector2.zero
  for _=1,45 do local _,rotation=AA.Step(state,window(1,20),c) r=rotation end
  t.expect.truthy(r.X<0)
  c.look=Intent.Resolve({device="touch",look=c.look,touchOwned=true,touchAt=0,now=.2})
  local _,expired=AA.Step(state,window(1,20),c) t.expect.equal(expired.Magnitude,0)
 end)

 t.test("centering retains its own range beyond motion tracking",function()
  local state=AA.NewState() local c=context(Vector2.zero) c.aiming=true c.centering=.65 c.tracking=0
  local r=Vector2.zero
  for _=1,45 do local _,rotation=AA.Step(state,window(1,270),c) r=rotation end
  t.expect.truthy(r.X<0)
  t.expect.equal(AA.Window(origin,forward,candidate(0,-301),true,1000),nil)
 end)

end

