return function(t)
 local Root=game.ServerScriptService.Crossgrounds
 local Roster=require(Root.PartyRoster)
 local Team=require(Root.TeamAdmissionPolicy)
 local XP=require(Root.PartyXPPolicy)
 local Admission=require(Root.PartyAdmission)
 local Queue=require(Root.QueueProvider)
 local function roster()
  local counter=0 local clock={now=0}
  return Roster.new({id=function()counter+=1 return tostring(counter)end,clock=function()return clock.now end}),clock
 end
 local function accept(r,leader,id) assert(r:Invite(leader,id)) assert(r:Accept(id,r.invites[id].id)) end
 t.test("create is exclusive and snapshot is copied",function()
  local r=roster() t.expect.truthy(r:Create(1))t.expect.falsy(r:Create(1))
  local s=r:Snapshot(1) s.group.members[1]=99 t.expect.equal(r:Get(1).members[1],1)
 end)
 t.test("invite requires leader and target without group",function()
  local r=roster()r:Create(1)accept(r,1,2)r:Create(3)
  t.expect.falsy(r:Invite(2,4))t.expect.falsy(r:Invite(1,3))
 end)
 t.test("expired or replaced invitation cannot be accepted",function()
  local r,clock=roster()r:Create(1)r:Invite(1,2)local old=r.invites[2].id
  r:Invite(1,2)t.expect.falsy(r:Accept(2,old))clock.now=61
  t.expect.falsy(r:Accept(2,r.invites[2].id))r:Expire()t.expect.equal(r.invites[2],nil)
 end)
 t.test("capacity is rechecked at accept",function()
  local r=roster()r:Create(1)r:Invite(1,13)local invite=r.invites[13].id
  for id=2,12 do accept(r,1,id)end
  t.expect.falsy(r:Accept(13,invite))t.expect.equal(#r:Get(1).members,12)
 end)
 t.test("lock prevents mutation and old leader invitation",function()
  local r=roster()r:Create(1)accept(r,1,2)r:Invite(1,3)local invite=r.invites[3].id
  local g=r:Get(1)r:SetLock(g,"ticket")t.expect.falsy(r:Remove(2,2))t.expect.falsy(r:SetLeader(1,2))t.expect.falsy(r:Accept(3,invite))
  r:SetLock(g,nil)r:SetLeader(1,2)t.expect.falsy(r:Accept(3,invite))
 end)
 t.test("leader disconnect transfers to oldest remaining member",function()
  local r=roster()r:Create(1)accept(r,1,2)accept(r,1,3)r:Forget(1)t.expect.equal(r:Get(2).leader,2)
  t.expect.falsy(r:Remove(3,2))r:Remove(2,3)t.expect.equal(r:Get(3),nil)
 end)
 t.test("last member dissolves group and invalidates invites",function()
  local r=roster()r:Create(1)r:Invite(1,2)r:Forget(1)r:Expire()t.expect.equal(next(r.groups),nil)t.expect.equal(r:Snapshot(2).invite,nil)
 end)
 t.test("same team needs six free seats while split can use twelve",function()
  local people={}for i=1,12 do people[i]=i end
  t.expect.equal(Team.Plan(people,true,{"A","B"},{A=0,B=0},6),nil)
  local plan=Team.Plan(people,false,{"A","B"},{A=0,B=0},6)local n={A=0,B=0}for _,team in plan do n[team]+=1 end
  t.expect.equal(n.A,6)t.expect.equal(n.B,6)
 end)
 t.test("pending reservations participate in capacity",function()
  t.expect.equal(Team.Plan({1,2},true,{"A","B"},{A=5,B=5},6),nil)
  local p=Team.Plan({1,2},false,{"A","B"},{A=5,B=5},6)t.expect.truthy(p)t.expect.truthy(p[1]~=p[2])
 end)
 t.test("whole group packing backtracks instead of splitting 3 3 2 2 2",function()
  local blocks={{1,2,3},{4,5,6},{7,8},{9,10},{11,12}}
  local plan=Team.PlanBlocks(blocks,{"A","B"},6)t.expect.truthy(plan)
  for _,block in blocks do for _,p in block do t.expect.equal(plan[p],plan[block[1]])end end
 end)
 t.test("unpackable whole groups are rejected",function()t.expect.equal(Team.PlanBlocks({{1,2,3,4,5},{6,7,8,9},{10,11,12}},{"A","B"},6),nil)end)
 t.test("party percent and fraction conservation",function()
  local a,r=XP.Boost(70,1,5,0)t.expect.equal(a,73)t.expect.equal(r,50)
  a,r=XP.Boost(70,1,5,r)t.expect.equal(a,74)t.expect.equal(r,0)
  t.expect.equal(XP.Boost(100,11,5,0),155)t.expect.equal(XP.Boost(100,0,5,0),100)
 end)
 local function fixture(failSecond)
  local r=roster()r:Create(1)accept(r,1,2)
  local members={}
  for i=1,2 do local p={UserId=i,DisplayName="P"..i,Parent=true,attributes={CrossgroundsMode="hub",ModeCharacterReady=true}}
   function p:GetAttribute(key)return self.attributes[key]end function p:SetAttribute(key,value)self.attributes[key]=value end members[i]=p
  end
  local party={Roster=r,Get=function(p)return r:Get(p.UserId)end,Members=function()return members end,SetRemovalHandler=function()end}
  local adapter={released=0}
  function adapter:ReserveAdmission()return true end function adapter:ReleaseAdmission()self.released+=1 end
  local c={queue=Queue.new(),adapters={arena=adapter},errors={}}
  c.context={GetMode=function(_,p)return p:GetAttribute("CrossgroundsMode")end}
  function c:Route()return {kind="local"}end function c:Publish()end function c:Error(p,message)self.errors[p]=message end
  function c:CallAdapter(_,method,p)
   if method=="Leave"then p:SetAttribute("CrossgroundsMode","hub")return true end
   p:SetAttribute("CrossgroundsMode","arena")
   if failSecond and p.UserId==2 then return false,"second member failed"end return true
  end
  return Admission.new(c,party),c,members,r
 end
 local function finish(a,r)
  local deadline=os.clock()+2 repeat task.wait()until not a.active[r:Get(1).id]or os.clock()>deadline
 end
 t.test("nonleader cannot initiate or consume collective entry",function()
  local a,c,p=fixture()a:Handle(p[2],{action="join",gameId="arena"})t.expect.truthy(c.errors[p[2]])
  a:Handle(p[1],{action="join",gameId="arena"})a:Handle(p[2],{action="enter",ticket=c.queue:Get(p[2]).ticket})t.expect.equal(c.queue:Get(p[1]).state,"ready")
  a:Handle(p[1],{action="cancel",ticket=c.queue:Get(p[1]).ticket})
 end)
 t.test("collective success consumes every ticket and releases reserve",function()
  local a,c,p,r=fixture()a:Handle(p[1],{action="join",gameId="arena"})
  a:Handle(p[1],{action="enter",ticket=c.queue:Get(p[1]).ticket})finish(a,r)
  for _,member in p do t.expect.equal(c.queue:Get(member).state,"idle")t.expect.equal(member:GetAttribute("CrossgroundsMode"),"arena")t.expect.falsy(member:GetAttribute("CrossgroundsTransition"))end
  t.expect.equal(c.adapters.arena.released,1)t.expect.equal(r:Get(1).lock,nil)
 end)
 t.test("failure rolls back even the partially entered failing member",function()
  local a,c,p,r=fixture(true)a:Handle(p[1],{action="join",gameId="arena"})
  a:Handle(p[1],{action="enter",ticket=c.queue:Get(p[1]).ticket})finish(a,r)
  for _,member in p do t.expect.equal(c.queue:Get(member).state,"failed")t.expect.equal(member:GetAttribute("CrossgroundsMode"),"hub")t.expect.falsy(member:GetAttribute("CrossgroundsTransition"))end
  t.expect.equal(c.adapters.arena.released,1)
 end)
 t.test("practice does not become a collective request",function()local a,_,p=fixture()t.expect.falsy(a:Handle(p[1],{action="join",gameId="ctf",variant="practice"}))end)
 t.test("collective transfer is gated before reserving tickets",function()
  local a,c,p=fixture()function c:Route()return{kind="teleport"}end c.partyTravel={Enabled=function()return false end}
  a:Handle(p[1],{action="join",gameId="arena"})t.expect.truthy(c.errors[p[1]])t.expect.equal(c.queue:Get(p[1]).state,"idle")
 end)
 t.test("failed collective transfer releases every source ticket",function()
  local a,c,p,r=fixture()function c:Route()return{kind="teleport"}end
  local calls=0 c.partyTravel={Enabled=function()return true end,Begin=function(_,entry,complete)calls+=1 t.expect.equal(#entry.members,2)complete("platform failure")return true end}
  a:Handle(p[1],{action="join",gameId="arena"})a:Handle(p[1],{action="enter",ticket=c.queue:Get(p[1]).ticket})
  t.expect.equal(calls,1)t.expect.equal(r:Get(1).lock,nil)
  for _,member in p do t.expect.equal(c.queue:Get(member).state,"failed")t.expect.falsy(member:GetAttribute("CrossgroundsTransition"))end
 end)
 t.test("destination partial admission rolls back every attempted member",function()
  local a,c,p,r=fixture(true)local ok=a:Receive(r:Get(1),p,"arena")t.expect.falsy(ok)t.expect.equal(r:Get(1).lock,nil)
  for _,member in p do t.expect.equal(member:GetAttribute("CrossgroundsMode"),"hub")end t.expect.equal(c.adapters.arena.released,1)
 end)
end
