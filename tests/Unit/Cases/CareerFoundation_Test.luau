return function(t)
 local P=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
 local Repository=require(game.ServerScriptService.Crossgrounds.CareerRepository)
 local function store()
  local s={data={},writes=0}
  function s:GetAsync(k) if self.failRead then error("unavailable") end return P.Copy(self.data[k]) end
  function s:UpdateAsync(k,fn)
   if self.failBefore then error("before write") end
   local nextValue=fn(P.Copy(self.data[k]))
   if nextValue~=nil then self.data[k]=P.Copy(nextValue) self.writes+=1 end
   if self.failAfter then self.failAfter=false error("response lost") end
   return P.Copy(nextValue)
  end
  return s
 end
 t.test("all normal thresholds and cap",function()
  for l=1,55 do t.expect.equal(P.Level(P.Threshold(l)),l) if l>1 then t.expect.equal(P.Level(P.Threshold(l)-1),l-1) end end
  t.expect.equal(P.CycleCost,343710) t.expect.equal(P.Level(1e9),55)
 end)
 t.test("migration preserves exact voluntary boundary and fractional overflow",function()
  local p=P.Migrate({XP=P.CycleCost,Kills=123,Coins=17})
  t.expect.equal(p.prestige,0) t.expect.equal(P.Level(p.cycleXP),55)
  p=P.Migrate({XP=P.CycleCost+1,Kills=123,Coins=17})
  t.expect.equal(p.prestige,1) t.expect.equal(p.cycleXP,1) t.expect.equal(p.stats.Kills,123) t.expect.equal(p.stats.Coins,17)
  for _,m in P.Modes do t.expect.equal(p.tokens[m],1) end
 end)
 t.test("legacy high level does not guarantee prestige",function()
  local p=P.Migrate({XP=150000}) t.expect.equal(p.prestige,0) t.expect.truthy(P.Level(p.cycleXP)<55)
 end)
 t.test("ten prestiges then mastery then legend",function()
  local p=P.New() p.cosmetics.cards.earned=true p.identity.card="earned" p.weapons.m4a1=30000 p.permanent.ctf.m4a1=true
  for i=1,10 do p.cycleXP=P.CycleCost t.expect.truthy(P.Transition(p)) t.expect.equal(p.prestige,i) end
  p.cycleXP=P.CycleCost t.expect.truthy(P.Transition(p)) t.expect.equal(p.phase,"mastery") t.expect.equal(P.Level(p.cycleXP,p.phase),1)
  p.cycleXP=P.Cap("mastery") t.expect.equal(P.Level(p.cycleXP,p.phase),1000) t.expect.truthy(P.Transition(p))
  t.expect.equal(p.phase,"legend") t.expect.equal(P.Level(p.cycleXP,p.phase),1) t.expect.truthy(p.accountUnlocked)
  t.expect.equal(p.weapons.m4a1,30000) t.expect.truthy(p.permanent.ctf.m4a1) t.expect.truthy(p.cosmetics.cards.earned) t.expect.equal(p.identity.card,"earned")
  for _,m in P.Modes do t.expect.equal(p.tokens[m],12) end
  t.expect.falsy(P.Transition(p))
 end)
 t.test("migration can reach legend and is repeatable",function()
  local xp=11*P.CycleCost+P.Cap("mastery")+24001
  local p=P.Migrate({XP=xp}) t.expect.equal(p.phase,"legend") t.expect.equal(p.cycleXP,24001) t.expect.equal(P.Level(p.cycleXP,p.phase),3)
  local again=P.Migrate(p) t.expect.equal(again.lifetimeXP,xp) t.expect.equal(again.transitions,12) t.expect.equal(again.tokens.arena,12)
 end)
 t.test("cap does not bank next cycle XP or erase weapon XP",function()
  local p=P.New() p.cycleXP=P.CycleCost-1
  P.Award(p,{XP=100,Kills=1},"ctf","m4a1",100)
  t.expect.equal(p.cycleXP,P.CycleCost) t.expect.equal(p.lifetimeXP,100) t.expect.equal(p.stats.ctf_Kills,1)
  P.Transition(p) t.expect.equal(p.cycleXP,0) t.expect.equal(p.weapons.m4a1,100)
 end)
 t.test("token scoped and duplicate rejected without consumption",function()
  local p=P.New() p.transitions=1 p.prestige=1 p.tokens.ctf=1
  t.expect.falsy(P.Unlock(p,"arena","m4a1")) t.expect.truthy(P.Unlock(p,"ctf","m4a1"))
  p.tokens.ctf=2 t.expect.falsy(P.Unlock(p,"ctf","m4a1")) t.expect.equal(p.tokens.ctf,2)
 end)
 t.test("public identity omits inventory and rejects unowned cosmetics",function()
  local p=P.New() t.expect.falsy(P.EquipIdentity(p,"card","fake"))
  local public=P.Public(p,10,"Nome") t.expect.equal(public.tokens,nil) t.expect.equal(public.weapons,nil) t.expect.equal(public.stats,nil)
  public.identity.card="changed" t.expect.equal(p.identity.card,"default")
 end)
 t.test("future and corrupt profiles fail closed",function()
  t.expect.equal(P.Migrate({schemaVersion=3}),nil)
  local p=P.New() p.cycleXP=0/0 t.expect.equal(P.Migrate(p),nil)
 end)
 t.test("load failure never creates blank profile",function()
  local s,old=store(),store() old.failRead=true
  local r=Repository.new(s,old,"A",function() return 0 end)
  t.expect.equal(r:Open(1),nil) t.expect.equal(s.writes,0)
 end)
 t.test("exclusive lease and expired writer rejected",function()
  local s,old=store(),store() local now=0
  local a=Repository.new(s,old,"A",function() return now end) local b=Repository.new(s,old,"B",function() return now end)
  local p=a:Open(1) t.expect.truthy(p) t.expect.equal(b:Open(1),nil)
  now=181 t.expect.truthy(b:Open(1)) t.expect.falsy(a:Commit(1,p)) t.expect.falsy(a:Close(1))
 end)
 t.test("uncertain write retries same snapshot exactly once",function()
  local s,old=store(),store() local r=Repository.new(s,old,"A",function() return 0 end)
  local p=r:Open(1) P.Award(p,{XP=100},"arena") s.failAfter=true
  t.expect.falsy(r:Commit(1,p)) local ok,saved=r:Commit(1,p)
  t.expect.truthy(ok) t.expect.equal(saved.lifetimeXP,100) t.expect.equal(saved.revision,1)
  t.expect.truthy(r:Close(1))
 end)
 t.test("malformed envelope cannot overwrite stored origin",function()
  local s,old=store(),store() s.data.u1={sequence=4}
  t.expect.equal(Repository.new(s,old,"A",function() return 0 end):Open(1),nil) t.expect.equal(s.writes,0)
 end)
 t.test("uncertain open recovers without repeating migration",function()
  local s,old=store(),store() old.data.u1={XP=P.CycleCost+1}
  local r=Repository.new(s,old,"A",function() return 0 end) s.failAfter=true
  t.expect.equal(r:Open(1),nil)
  local p=r:Open(1) t.expect.equal(p.prestige,1) t.expect.equal(p.tokens.ctf,1)
 end)
 t.test("uncertain transaction prevents release and freezes candidate",function()
  local s,old=store(),store() local r=Repository.new(s,old,"A",function() return 0 end)
  local p=r:Open(1) P.Award(p,{XP=100},"arena") s.failAfter=true
  t.expect.falsy(r:Commit(1,p)) t.expect.falsy(r:Close(1))
  P.Award(p,{XP=50},"arena") local ok,saved=r:Commit(1,p)
  t.expect.truthy(ok) t.expect.equal(saved.lifetimeXP,100)
 end)
 t.test("corrupt transitions and token balances preserve origin",function()
  local p=P.New() p.tokens.arena=1 t.expect.equal(P.Migrate(p),nil)
  p=P.New() p.phase="legend" t.expect.equal(P.Migrate(p),nil)
  p=P.New() p.cosmetics.frames=nil t.expect.equal(P.Migrate(p),nil)
 end)
end
