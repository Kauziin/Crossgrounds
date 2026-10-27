return function(t)
 local Policy=require(game.ReplicatedStorage.Crossgrounds.CombatCameraPolicy)
 local Filter=require(game.ReplicatedStorage.Crossgrounds.AnalogFilter)
 local Layout=require(game.ReplicatedStorage.Crossgrounds.MobileLayout)
 local Settings=require(game.ReplicatedStorage.ExperienceSettings)
 t.test("Arena is first person for every weapon and firearms always lock",function()
  for _,kind in {"Gun","Melee","MeleeArea"} do
   local locked,first=Policy.Resolve("arena",kind,false,false)
   t.expect.truthy(locked) t.expect.truthy(first)
  end
  local locked,first=Policy.Resolve("ctf","Gun",false,false)
  t.expect.truthy(locked) t.expect.falsy(first)
  local melee,perspective=Policy.Resolve("ctf","Melee",false,true)
  t.expect.falsy(melee) t.expect.truthy(perspective)
 end)
 t.test("dynamic response is monotonic symmetric and preserves maximum speed",function()
  local previous=-1
  for i=0,100 do
   local m=i/100 local v=Filter.Dynamic(Vector2.new(m,0),1)
   t.expect.truthy(v.X>=previous) previous=v.X
   t.expect.truthy((v+Filter.Dynamic(Vector2.new(-m,0),1)).Magnitude<.000001)
  end
  t.expect.truthy(Filter.Dynamic(Vector2.new(.25,0),1).X<.25)
  t.expect.truthy(Filter.Dynamic(Vector2.new(.75,0),1).X>.75)
  t.expect.equal(Filter.Dynamic(Vector2.new(1,0),1).X,1)
  t.expect.truthy((Filter.Look(Vector2.new(.05,0),.1,1,.65)).Magnitude==0)
 end)
 t.test("touch turns match screen fraction and sensitivity clamps at four",function()
  local a=Filter.TouchRadians(Vector2.new(450,0),900,1,1)
  local b=Filter.TouchRadians(Vector2.new(900,0),1800,1,1)
  t.expect.truthy((a-b).Magnitude<.000001)
  t.expect.truthy(math.abs(a.X-math.rad(120))<.000001)
  t.expect.equal(Settings:Sanitize("LookSensitivity",99),4)
  t.expect.equal(Settings:Sanitize("LookSensitivity",-10),.2)
 end)
 t.test("default touch buttons are separated across phone and tablet viewports",function()
  for _,v in {Vector2.new(390,844),Vector2.new(740,360),Vector2.new(900,480),Vector2.new(1280,800)} do
   local placed={}
   for _,action in Layout.Order do
    local point,size=Layout.Pixels(Layout.Buttons[action],v)
    for _,old in placed do t.expect.truthy((old.point-point).Magnitude>(old.size+size)*.5+4) end
    table.insert(placed,{point=point,size=size})
   end
  end
 end)
 t.test("every editable HUD field rejects invalid values and stays inside limits",function()
  for action in Layout.Buttons do for _,field in {"X","Y","Size","Opacity"} do
   local key=Layout.Key(action,field) local r=Settings.Rules[key]
   t.expect.equal(Settings:Sanitize(key,math.huge),nil)
   t.expect.equal(Settings:Sanitize(key,-100),r.Min)
   t.expect.equal(Settings:Sanitize(key,1000),r.Max)
  end end
 end)
end
