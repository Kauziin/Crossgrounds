return function(t)
 local Ballistics=require(game.ServerScriptService.Crossgrounds.Ballistics)
 local Kits=require(game.ReplicatedStorage.KitDefinitions)
 local function fixture(spec,callback)
  local folder=Instance.new("Folder") local entries={} local byName={}
  for i,row in spec do
   local model=Instance.new("Model") model.Name=row[1] model:SetAttribute("Relation",row[2]) model.Parent=folder
   local h=Instance.new("Humanoid") h.RequiresNeck=false h.MaxHealth=500 h.Health=500 h.Parent=model
   local body=Instance.new("Part") body.Name="Torso" body.Parent=model
   local part=body
   if row[3] then local a=Instance.new("Accessory") a.Parent=model part=Instance.new("Part") part.Name="Handle" part.Parent=a end
   local entry={model=model,part=part,position=Vector3.new(i*10,0,0)} table.insert(entries,entry) byName[row[1]]=entry
  end
  local function cast(_,ray,params)
   for _,entry in entries do
    local ignored=false
    for _,model in params.FilterDescendantsInstances do if entry.part:IsDescendantOf(model) then ignored=true break end end
    if not ignored and entry.position.Magnitude<=ray.Magnitude then return {Instance=entry.part,Position=entry.position} end
   end
  end
  local function fire(max,custom)
   local hits={}
   local result=Ballistics.Trace({origin=Vector3.zero,direction=Vector3.xAxis,range=500,maxTargets=max,penetrationLoss=.2,raycast=cast,
    classify=function(model) return model:GetAttribute("Relation") end,
    onHit=function(hit,model,index,multiplier,distance)
     if custom and custom(model)==false then return false end
     table.insert(hits,{name=model.Name,damage=Kits.ShotDamage(Kits.Weapons.Sniper,distance,false,multiplier),index=index})
     return true
    end})
   return result,hits
  end
  local ok,err=pcall(callback,fire,byName,entries) folder:Destroy() if not ok then error(err,0) end
 end
 t.test("allies and their accessories do not consume penetration",function()
  fixture({{"ally","ignore",true},{"enemy1","target"},{"enemy2","target"},{"enemy3","target"}},function(fire)
   local result,hits=fire(2) t.expect.equal(#hits,2) t.expect.equal(hits[1].name,"enemy1") t.expect.equal(hits[1].damage,150) t.expect.equal(hits[2].damage,120) t.expect.equal(result.reason,"targets")
  end)
 end)
 t.test("ordinary guns stop at the first enemy",function()
  fixture({{"enemy1","target"},{"enemy2","target"}},function(fire) local _,hits=fire(1) t.expect.equal(#hits,1) end)
 end)
 t.test("cover before targets blocks all damage",function()
  fixture({{"wall","block"},{"enemy1","target"}},function(fire) local r,hits=fire(2) t.expect.equal(#hits,0) t.expect.equal(r.reason,"wall") end)
 end)
 t.test("cover after first enemy stops penetration",function()
  fixture({{"enemy1","target"},{"wall","block"},{"enemy2","target"}},function(fire) local r,hits=fire(2) t.expect.equal(#hits,1) t.expect.equal(r.reason,"wall") end)
 end)
 t.test("rejected protected targets do not leak damage behind them",function()
  fixture({{"shield","target"},{"enemy2","target"}},function(fire) local r,hits=fire(2,function() return false end) t.expect.equal(#hits,0) t.expect.equal(r.reason,"protected") end)
 end)
 t.test("a character cannot be damaged twice through different body parts",function()
  fixture({{"enemy1","target"},{"enemy2","target"}},function(fire,_,entries)
   table.insert(entries,2,entries[1]) local _,hits=fire(2) t.expect.equal(#hits,2) t.expect.equal(hits[2].name,"enemy2")
  end)
 end)
 t.test("ignored corpses allow a full damage first target",function()
  fixture({{"corpse","ignore"},{"enemy1","target"}},function(fire) local _,hits=fire(1) t.expect.equal(hits[1].damage,150) t.expect.equal(hits[1].name,"enemy1") end)
 end)
 t.test("penetration composes with falloff and headshots",function()
  t.expect.equal(Kits.ShotDamage(Kits.Weapons.Sniper,350,true,1),Kits.DamageAtDistance(Kits.Weapons.Sniper,350)*1.5)
  t.expect.equal(Kits.ShotDamage(Kits.Weapons.Sniper,350,true,.8),Kits.DamageAtDistance(Kits.Weapons.Sniper,350)*.8*1.5)
 end)
end
