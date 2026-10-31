return function(t)
 local AA=require(game.ReplicatedStorage.Crossgrounds.AimAssist)
 local Intent=require(game.ReplicatedStorage.Crossgrounds.AimAssistIntent)
 local Kits=require(game.ReplicatedStorage.KitDefinitions)
 local Shot=require(game.ReplicatedStorage.Crossgrounds.ShotMath)
 t.test("100ms frames retain bounded tracking while 200ms hitches reset it",function()
  local state=AA.NewState()local rotation=Vector2.zero
  for i=1,10 do
   local window=AA.Window(Vector3.zero,-Vector3.zAxis,{id="target",point=Vector3.new(i*.06,0,-20),size=Vector3.new(2.8,5,2)},true,100)
   local _,r=AA.Step(state,window,{origin=Vector3.zero,dt=.1,strength=1,look=Vector2.new(-.2,0)})rotation=r
  end
  t.expect.truthy(rotation.X<0)t.expect.truthy(math.abs(rotation.X)<=math.rad(90)*.05)
  local _,r=AA.Step(state,nil,{dt=.2,strength=1})t.expect.equal(r.Magnitude,0)
 end)
 t.test("rewound spheres preserve rounded corners and do not inflate them into a box",function()
  local sweep=require(game.ReplicatedStorage.Crossgrounds.SweptSphereBox)
  t.expect.equal(sweep(Vector3.new(1.35,1.35,0),-Vector3.zAxis,30,CFrame.new(0,0,-10),Vector3.one*2,.4),nil)
  t.expect.truthy(sweep(Vector3.new(1.2,1.2,0),-Vector3.zAxis,30,CFrame.new(0,0,-10),Vector3.one*2,.4))
 end)
 t.test("lobby assistance accepts only live local practice targets",function()
  local s={mode="ctf",practiceShooter=true,targetPractice=true,health=100}
  t.expect.truthy(AA.Eligible(s)) s.targetPractice=false s.targetBot=true t.expect.falsy(AA.Eligible(s))
  s.targetPractice=true s.protected=true t.expect.falsy(AA.Eligible(s))s.protected=false s.health=0 t.expect.falsy(AA.Eligible(s))
 end)
 t.test("sparse touch events retain intention without replaying displacement",function()
  local intent=Intent.TouchLook(Vector2.zero,Vector2.new(.004,0),1/60,true,0)
  t.expect.truthy(intent.X<0)
  t.expect.equal(Intent.TouchLook(intent,Vector2.zero,1/60,true,1/60),intent)
  t.expect.equal(Intent.TouchLook(intent,Vector2.zero,1/60,true,.11),Vector2.zero)
  t.expect.equal(Intent.TouchLook(intent,Vector2.zero,1/60,false,0),Vector2.zero)
 end)
 t.test("the two original guns retain separate cadence magazines and reloads",function()
  local a,b=Kits.Weapons.AutoBlaster,Kits.Weapons.Blaster
  t.expect.truthy(a.Automatic) t.expect.falsy(b.Automatic)
  t.expect.equal(a.Magazine,30)t.expect.equal(b.Magazine,10)
  t.expect.equal(a.ReloadTime,1.5)t.expect.equal(b.ReloadTime,1)
  t.expect.equal(Shot.Config(a).radius,.4)t.expect.equal(Shot.Config(b).kind,"hitscan")
  t.expect.equal(Shot.Config(Kits.Weapons.Rifle).radius,0)
 end)
 t.test("source guns are selectable in CTF and Arena",function()
  local L=require(game.ReplicatedStorage.Crossgrounds.LoadoutDefinitions)
  for _,id in {"Blaster","AutoBlaster"}do
   t.expect.truthy(L.Valid("ctf",id))t.expect.truthy(L.Valid("arena",id))
   t.expect.equal(Kits.ArenaGunId(id),id)
  end
  t.expect.equal(Kits.ArenaGunId("Magnum"),"ArenaPistol")
 end)
 t.test("factory returns real models without the sample's competing controller",function()
  local F=require(game.ServerScriptService.MainGameScript.GameManager.WeaponFactory)
  for _,id in {"Blaster","AutoBlaster"}do
   local tool=F:Create(id)t.expect.equal(tool:GetAttribute("WeaponId"),id)
   t.expect.truthy(tool.Handle.Muzzle)t.expect.truthy(tool:FindFirstChild("Blaster"))
   for _,v in tool:GetDescendants()do t.expect.falsy(v:IsA("LuaSourceContainer"))end
   tool:Destroy()
  end
 end)
end
