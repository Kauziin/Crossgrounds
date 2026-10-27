return function(t)
 local R=require(game.ReplicatedStorage.Crossgrounds.CombatMovement)
 local A=require(game.ReplicatedStorage.Crossgrounds.WeaponActionMotion)
 local L=require(game.ReplicatedStorage.Crossgrounds.LocomotionMotion)
 local F=require(game.ReplicatedStorage.Crossgrounds.AnalogFilter)
 local AA=require(game.ReplicatedStorage.Crossgrounds.AimAssist)
 t.test("slide requires active combat grounded sprint and real velocity",function()
  local s={mode="ctf",playing=true,alive=true,grounded=true,sprinting=true,speed=25,cooldown=0}
  t.expect.truthy(R.CanSlide(s)) s.mode="arena" t.expect.truthy(R.CanSlide(s))
  for _,k in {"playing","alive","grounded","sprinting"} do s[k]=false t.expect.falsy(R.CanSlide(s)) s[k]=true end
  s.mode="get_out" t.expect.falsy(R.CanSlide(s)) s.mode="ctf"
  s.speed=3 t.expect.falsy(R.CanSlide(s)) s.speed=25 s.blocked=true t.expect.falsy(R.CanSlide(s))
  s.blocked=false s.cooldown=.1 t.expect.falsy(R.CanSlide(s))
 end)
 t.test("slide decelerates without extending or boosting velocity",function()
  local previous=25
  for i=0,100 do local speed=R.Speed(25,R.Duration*i/100) t.expect.truthy(speed<=previous+.0001) previous=speed end
  t.expect.equal(R.Speed(25,0),25) t.expect.equal(R.Speed(25,100),R.ExitSpeed)
 end)
 t.test("radial hysteresis rejects boundary noise and releases instantly",function()
  local s={}
  for _,v in {.09,.101,.11,.099,.104} do t.expect.equal(F.Stick(s,Vector2.new(v,0),.1).Magnitude,0) end
  t.expect.truthy(F.Stick(s,Vector2.new(.2,0),.1).X>0)
  t.expect.truthy(F.Stick(s,Vector2.new(.11,0),.1).X>0)
  t.expect.equal(F.Stick(s,Vector2.zero,.1),Vector2.zero)
  t.expect.equal(F.Stick(s,Vector2.new(.11,0),.1),Vector2.zero)
 end)
 t.test("hysteresis does not retain a stale direction or distort diagonals",function()
  local s={} local value=Vector2.new(.6,.8)
  t.expect.truthy((F.Stick(s,value,.1)-value).Magnitude<.00001)
  t.expect.equal(F.Stick(s,Vector2.zero,.1),Vector2.zero)
  t.expect.equal(F.Stick(s,Vector2.new(-1,0),.1).X,-1)
 end)
 t.test("equip and action curves return precisely to rest",function()
  local start=A.Sample({equippedFor=0}) local stop=A.Sample({equippedFor=1})
  t.expect.truthy(start.weapon.Position.Magnitude>.2)
  t.expect.equal(stop.weapon,CFrame.new()) t.expect.equal(stop.support,Vector3.zero)
 end)
 t.test("melee contact follows each weapon's actual active interval",function()
  local knife={Windup=.04,ActiveTime=.13} local axe={Windup=.2,ActiveTime=.32}
  t.expect.truthy(A.Melee(.035,knife)<0)
  t.expect.truthy(A.Melee(.16,knife)>0)
  t.expect.truthy(A.Melee(.16,axe)<0)
  t.expect.equal(A.Melee(10,axe),0)
 end)
 t.test("shot mechanism settles and slide pose never moves forward",function()
  local a=A.Sample({firedAgo=0,slide=1}) local b=A.Sample({firedAgo=1,slide=1})
  t.expect.truthy(a.slide.Position.Z>.1) t.expect.truthy(b.slide.Position.Magnitude<.00001)
  t.expect.truthy(a.weapon.Position.Y<0)
 end)
 t.test("jump fall land follow physical state and ignore shallow steps",function()
  local s=L.new()
  t.expect.equal(s:Update(1/60,Vector3.zero,true,false).state,"Idle")
  t.expect.equal(s:Update(1/60,Vector3.new(0,20,0),false,false).state,"Jump")
  t.expect.equal(s:Update(1/60,Vector3.new(0,-25,0),false,false).state,"Fall")
  t.expect.equal(s:Update(1/60,Vector3.zero,true,false).state,"Land")
  s=L.new() s:Update(.016,Vector3.new(0,-3,0),false,false)
  t.expect.equal(s:Update(.016,Vector3.zero,true,false).land,0)
 end)
 t.test("all eight directions preserve lateral and backwards semantics",function()
  for _,v in {Vector3.new(0,0,-18),Vector3.new(0,0,18),Vector3.new(18,0,0),Vector3.new(-18,0,0),Vector3.new(12,0,-12),Vector3.new(-12,0,-12),Vector3.new(12,0,12),Vector3.new(-12,0,12)} do
   local s=L.new():Update(.016,v,true,false)
   t.expect.truthy(s.weight>0) t.expect.truthy(s.side*v.X>=0) t.expect.truthy(s.forward*-v.Z>=0)
  end
 end)
 t.test("slide camera height blends in and recovers after cancellation",function()
  local s=L.new() local m
  for i=1,40 do m=s:Update(1/60,Vector3.new(0,0,-20),true,true) end
  t.expect.equal(m.state,"Slide") t.expect.truthy(m.cameraY<-.5)
  for i=1,80 do m=s:Update(1/60,Vector3.zero,true,false) end
  t.expect.truthy(math.abs(m.cameraY)<.00001)
 end)
 t.test("moving target never rotates aim for left-stick-only movement",function()
  local s=AA.NewState()
  for i=1,60 do
   local origin=Vector3.new(i*.002,0,0)
   local w=AA.Window(origin,Vector3.new(0,0,-1),{id="e",point=Vector3.new(i*.01,0,-20)},true,100)
   local _,r=AA.Step(s,w,{origin=origin,look=Vector2.zero,strafe=1,device="gamepad",dt=1/60,strength=1})
   t.expect.equal(r,Vector2.zero)
  end
 end)
 t.test("letting go of touch aim stops tracking on the very next frame",function()
  local s=AA.NewState() local r
  for i=1,60 do
   local w=AA.Window(Vector3.zero,Vector3.new(0,0,-1),{id="e",point=Vector3.new(i*.01,0,-20)},true,100)
   _,r=AA.Step(s,w,{origin=Vector3.zero,look=i<60 and Vector2.new(-.2,0) or Vector2.zero,device="touch",dt=1/60,strength=1})
   if i==59 then t.expect.truthy(r.X<0) end
  end
  t.expect.equal(r,Vector2.zero)
 end)
 t.test("horizontal input cannot introduce vertical assisted drift",function()
  local s=AA.NewState()
  for i=1,60 do
   local w=AA.Window(Vector3.zero,Vector3.new(0,0,-1),{id="e",point=Vector3.new(i*.01,i*.01,-20)},true,100)
   local _,r=AA.Step(s,w,{origin=Vector3.zero,look=Vector2.new(-.2,0),device="gamepad",dt=1/60,strength=1})
   t.expect.equal(r.Y,0)
  end
 end)
 t.test("slide and leave share B only in disjoint running contexts",function()
  local P=require(game.ReplicatedStorage.ControlPolicy) local D=require(game.ReplicatedStorage.ControlDefinitions)
  local s={mode="ctf",inMatch=true,alive=true,sprinting=true}
  t.expect.truthy(P.Available("Slide",s)) t.expect.falsy(P.Available("Leave",s))
  s.sprinting=false t.expect.falsy(P.Available("Slide",s)) t.expect.truthy(P.Available("Leave",s))
  local bindings={} for name,v in D.Actions do bindings[name]=v.Gamepad end
  local plan=P.Normalize(D,bindings,"Gamepad") t.expect.truthy(plan)
  t.expect.equal(plan.Slide,"ButtonB") t.expect.equal(plan.Leave,"ButtonB")
 end)
 t.test("Arena reload remains available through the shared interaction action",function()
  local P=require(game.ReplicatedStorage.ControlPolicy)
  t.expect.truthy(P.Available("ReloadInteract",{mode="arena",alive=true,arenaPlaying=true}))
  t.expect.falsy(P.Available("ReloadInteract",{mode="arena",alive=true,arenaPlaying=false}))
 end)
end
