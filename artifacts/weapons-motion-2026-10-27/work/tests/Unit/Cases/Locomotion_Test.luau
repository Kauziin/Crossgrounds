return function(t)
 local Carry=require(game.ReplicatedStorage.Crossgrounds.WeaponLocomotion)
 local Camera=require(game.ReplicatedStorage.Crossgrounds.CameraMotion)
 t.test("running sweep is slower and has a wide lateral travel",function()
  local r=Carry.new() local minimum,maximum=math.huge,-math.huge
  for i=1,180 do local cf=r:Update(1/60,Vector3.new(0,0,-25),true,true,false,false,1) if i>60 then minimum=math.min(minimum,cf.X) maximum=math.max(maximum,cf.X) end end
  t.expect.truthy(maximum-minimum>.5) t.expect.truthy(r.phase>28 and r.phase<30)
 end)
 t.test("zero motion amount produces no carry animation",function()
  local r=Carry.new() local cf
  for _=1,120 do cf=r:Update(1/60,Vector3.new(0,0,-25),true,true,false,false,0) end
  t.expect.equal(cf.Position.Magnitude,0) local _,angle=cf:ToAxisAngle() t.expect.equal(angle,0)
 end)
 t.test("sprint pose returns when aiming and firing",function()
  for _,aim in {true,false} do
   local r=Carry.new() for _=1,60 do r:Update(1/60,Vector3.new(0,0,-25),true,true,false,false,1) end
   t.expect.truthy(r.weight>.9)
   for _=1,100 do r:Update(1/60,Vector3.new(0,0,-25),true,true,aim,not aim,1) end
   t.expect.truthy(r.weight<.001)
  end
 end)
 t.test("run pose remains bounded at 30 and 144 fps",function()
  local a,b=Carry.new(),Carry.new()
  for _=1,30 do a:Update(1/30,Vector3.new(0,0,-25),true,true,false,false,1) end
  for _=1,144 do b:Update(1/144,Vector3.new(0,0,-25),true,true,false,false,1) end
  t.expect.truthy(math.abs(a.weight-b.weight)<.001) a:Reset() t.expect.equal(a.weight,0)
 end)
 t.test("airborne character does not continue building sprint pose",function()
  local r=Carry.new() for _=1,60 do r:Update(1/60,Vector3.new(0,0,-25),false,true,false,false,1) end
  t.expect.equal(r.weight,0)
 end)
 t.test("camera has stronger running lean and resets pitch",function()
  local c=Camera.new() local maxRoll,maxPitch=0,0
  for _=1,100 do local _,roll,pitch=c:Update(1/60,Vector3.new(20,0,-25),true,true,false,1,2) maxRoll=math.max(maxRoll,math.abs(roll)) maxPitch=math.max(maxPitch,math.abs(pitch)) end
  t.expect.truthy(maxRoll>math.rad(2)) t.expect.truthy(maxPitch>0) c:Reset() t.expect.equal(c.pitch,0) t.expect.equal(c.roll,0)
 end)
 t.test("camera motion is absent with the option disabled",function()
  local c=Camera.new() local offset,roll,pitch=c:Update(1/60,Vector3.new(20,0,-25),true,true,false,0,3)
  t.expect.equal(offset.Magnitude,0) t.expect.equal(roll,0) t.expect.equal(pitch,0)
 end)
end
