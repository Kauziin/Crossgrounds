return function(t)
 local Profiles=require(game.ServerScriptService.Crossgrounds.BotProfiles)
 local Sensor=require(game.ServerScriptService.Crossgrounds.BotPerception)
 local Decision=require(game.ServerScriptService.Crossgrounds.BotDecision)
 local Combat=require(game.ServerScriptService.Crossgrounds.BotCombat)
 local Authority=require(game.ServerScriptService.Crossgrounds.ShotAuthority)
 t.test("close targets behind the bot are outside the visual cone",function()
  t.expect.falsy(Sensor.InCone(Vector3.xAxis,-Vector3.xAxis)) t.expect.truthy(Sensor.InCone(Vector3.xAxis,Vector3.xAxis*100))
 end)
 t.test("difficulty and personality do not change weapon damage or health",function()
  for difficulty in Profiles.Difficulties do for personality in Profiles.Personalities do
   local profile,weights=Profiles.Resolve(difficulty,personality)
   t.expect.truthy(profile.Reaction[1]>0) t.expect.equal(profile.Damage,nil) t.expect.equal(profile.Health,nil)
   t.expect.truthy(weights.Engage~=nil)
  end end
 end)
 t.test("utility preserves commitment and exits combat when vision is lost",function()
  local _,p=Profiles.Resolve("Regular","Aggressive")
  local m={visible=true,target={},position=Vector3.xAxis,confidence=1} local r={health=1,ammo=10,reserve=10,distance=20}
  local state=Decision.Choose(m,r,p,{position=Vector3.zero},1,"Objective",.5) t.expect.equal(state,"Objective")
  m.visible=false state=Decision.Choose(m,r,p,nil,2,"Engage",0) t.expect.equal(state,"Search")
  m.confidence=0 m.position=nil state=Decision.Choose(m,r,p,nil,8,"Search",0) t.expect.equal(state,"Patrol")
 end)
 t.test("aim rotation is bounded by angular speed and deltaTime",function()
  local nextDirection=Combat.Rotate(Vector3.xAxis,Vector3.zAxis,math.rad(10))
  t.expect.truthy(math.acos(math.clamp(nextDirection:Dot(Vector3.xAxis),-1,1))<math.rad(10.1))
  t.expect.truthy(nextDirection:Dot(Vector3.zAxis)<.25)
 end)
 t.test("waypoint arrival tolerates root height without accepting another floor",function()
  local Nav=require(game.ServerScriptService.Crossgrounds.BotNavigation)
  t.expect.truthy(Nav.ReachedWaypoint(Vector3.new(1,3.3,0),Vector3.zero))
  t.expect.falsy(Nav.ReachedWaypoint(Vector3.new(0,9,0),Vector3.zero))
  t.expect.falsy(Nav.ReachedWaypoint(Vector3.new(5,3,0),Vector3.zero))
 end)
 local function fixture(callback)
  local bots=workspace:FindFirstChild("CTFBots") assert(bots)
  local origin=Vector3.new(5000,13000,0)
  local function model(name,position,parent)
   local m=Instance.new("Model") m.Name=name m.Parent=parent
   for _,row in {{"HumanoidRootPart",Vector3.zero},{"Head",Vector3.new(0,1.5,0)}} do local p=Instance.new("Part") p.Name=row[1] p.Size=Vector3.new(2,2,2) p.Anchored=true p.Position=position+row[2] p.Parent=m end
   local h=Instance.new("Humanoid") h.RequiresNeck=false h.MaxHealth=500 h.Health=500 h.Parent=m return m
  end
  local bot=model("BotIQFixture",origin,bots) bot:SetAttribute("CTFBot",true)
  bot.HumanoidRootPart.CFrame=CFrame.lookAt(origin,origin+Vector3.xAxis)
  local target=model("BotTargetFixture",origin+Vector3.new(30,0,0),workspace)
  local tool=require(game.ServerScriptService.MainGameScript.GameManager.WeaponFactory):Create("Rifle")
  for _,part in tool:GetDescendants() do if part:IsA("BasePart") then part.Anchored=true part.CFrame=CFrame.new(origin)*part.CFrame end end
  tool.Parent=bot tool:SetAttribute("Ammo",2) tool:SetAttribute("ReserveAmmo",5)
  local ok,err=pcall(callback,bot,target,tool,origin) bot:Destroy() target:Destroy() if not ok then error(err,0) end
 end
 t.test("perception loses covered targets without updating their hidden position",function()
  fixture(function(bot,target,_,origin)
   local s=Sensor.new(bot,Profiles.Difficulties.Regular,function(m) return m==target and "target" or "block" end,function() return {target} end,function() return true end)
   local m=s:Scan(1) t.expect.truthy(m.visible) local seen=m.position
   local wall=Instance.new("Part") wall.Anchored=true wall.Size=Vector3.new(1,20,20) wall.Position=origin+Vector3.new(15,0,0) wall.Parent=workspace
   target.HumanoidRootPart.Position+=Vector3.new(0,0,4)
   local hidden=s:Scan(1.3) t.expect.falsy(hidden.visible) t.expect.equal(hidden.position,seen)
   s:Scan(9) wall:Destroy() t.expect.equal(s.memory.target,nil)
  end)
 end)
 t.test("NPC shot uses shared ammo, cadence and real obstruction",function()
  fixture(function(bot,target,tool,origin)
   local hits=0 local function fire()
    return Authority.FireNPC({character=bot,tool=tool,direction=Vector3.xAxis,aim=origin+Vector3.new(30,1.5,0),valid=function() return true end,
     classify=function(m) return m==target and "target" or "block" end,onHit=function() hits+=1 return true end})
   end
   local accepted=fire() t.expect.truthy(accepted) t.expect.equal(tool:GetAttribute("Ammo"),1) t.expect.equal(hits,1)
   t.expect.falsy(fire()) t.expect.equal(tool:GetAttribute("Ammo"),1)
   task.wait(.23)
   local wall=Instance.new("Part") wall.Anchored=true wall.Size=Vector3.new(1,20,20) wall.Position=origin+Vector3.new(15,0,0) wall.Parent=workspace
   accepted=fire() wall:Destroy() t.expect.truthy(accepted) t.expect.equal(hits,1) t.expect.equal(tool:GetAttribute("Ammo"),0)
  end)
 end)
 t.test("NPC reload consumes finite reserve and cancels when invalidated",function()
  fixture(function(bot,_,tool)
   tool:SetAttribute("Ammo",0) local valid=true
   t.expect.truthy(Authority.ReloadNPC(bot,tool,function() return valid end))
   valid=false task.wait(2.1) t.expect.equal(tool:GetAttribute("Ammo"),0) t.expect.equal(tool:GetAttribute("ReserveAmmo"),5)
   t.expect.falsy(tool:GetAttribute("Reloading"))
   t.expect.truthy(Authority.ReloadNPC(bot,tool,function() return true end)) task.wait(2.1)
   t.expect.equal(tool:GetAttribute("Ammo"),5) t.expect.equal(tool:GetAttribute("ReserveAmmo"),0)
  end)
 end)
 t.test("shared scheduler executes decisions and cancels the controller",function()
  fixture(function(bot,_,_,origin)
   bot:SetAttribute("CTFTeam","Blue") bot:SetAttribute("CTFRole","Soldier") bot:SetAttribute("CTFSlot",1)
   local runtime=require(game.ServerScriptService.Crossgrounds.BotRuntime)
   local own={home=origin,hitbox={Position=origin},state="home"}
   local other={home=origin+Vector3.new(30,0,0),hitbox={Position=origin+Vector3.new(30,0,0)},state="home"}
   local flags={} function flags:GetFlag(name) return name=="Blue" and own or other end function flags:TryInteract() end
   local before=runtime:Snapshot().decisions
   runtime:Start(bot,game.Teams.Blue,1,flags,function() return true end)
   task.wait(.35) local after=runtime:Snapshot() runtime:Stop(bot) task.wait(.15)
   t.expect.truthy(after.decisions>before) t.expect.truthy(bot:GetAttribute("CTFState"))
   t.expect.equal(runtime:Snapshot().active,0) t.expect.falsy(runtime:Snapshot().connected)
  end)
 end)
end
