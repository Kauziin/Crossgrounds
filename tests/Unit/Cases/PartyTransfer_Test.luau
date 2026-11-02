return function(t)
 local P=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
 local R=require(game.ServerScriptService.Crossgrounds.PartyTransferRepository)
 local Roster=require(game.ServerScriptService.Crossgrounds.PartyRoster)
 local function setup()
  local clock={now=100}local map={data={}}
  function map:GetAsync(k)return P.Copy(self.data[k])end
  function map:UpdateAsync(k,fn)
   local value=fn(P.Copy(self.data[k]))if value then self.data[k]=P.Copy(value)end
   if self.loseReply then self.loseReply=false error("reply lost")end return P.Copy(value)
  end
  return R.new(map,function()return clock.now end),map,clock
 end
 local function data()return{id="opaque-guid",groupId="group1",leader=1,members={1,2},sameTeam=true,mode="ctf",placeId=22,sourceJob="source"}end
 t.test("handoff accepts only server members and destination",function()
  local r=setup()t.expect.truthy(r:Create(data()))t.expect.falsy(r:Claim("opaque-guid",9,22,"A"))t.expect.falsy(r:Claim("opaque-guid",1,33,"A"))
  t.expect.truthy(r:Claim("opaque-guid",1,22,"A"))
 end)
 t.test("first destination owns the whole handoff",function()
  local r=setup()r:Create(data())t.expect.truthy(r:Claim("opaque-guid",1,22,"A"))t.expect.falsy(r:Claim("opaque-guid",2,22,"B"))t.expect.truthy(r:Claim("opaque-guid",2,22,"A"))
 end)
 t.test("complete requires all members; claims are idempotent",function()
  local r=setup()r:Create(data())local ok,record=r:Claim("opaque-guid",1,22,"A")t.expect.truthy(ok)t.expect.falsy(R.Complete(record))
  r:Claim("opaque-guid",1,22,"A")ok,record=r:Claim("opaque-guid",2,22,"A")t.expect.truthy(ok)t.expect.truthy(R.Complete(record))
 end)
 t.test("expiry and closure reject replay",function()
  local r,_,clock=setup()r:Create(data())clock.now=221 t.expect.falsy(r:Claim("opaque-guid",1,22,"A"))
  r=setup()r:Create(data())r:Claim("opaque-guid",1,22,"A")t.expect.falsy(r:Close("opaque-guid","B"))t.expect.truthy(r:Close("opaque-guid","A"))t.expect.falsy(r:Claim("opaque-guid",2,22,"A"))
 end)
 t.test("uncertain creation and arrival do not duplicate members",function()
  local r,map=setup()map.loseReply=true t.expect.falsy(r:Create(data()))t.expect.truthy(r:Create(data()))
  map.loseReply=true t.expect.falsy(r:Claim("opaque-guid",1,22,"A"))local ok,record=r:Claim("opaque-guid",1,22,"A")t.expect.truthy(ok)t.expect.equal(#record.members,2)
 end)
 t.test("unknown versions and invalid formations fail closed",function()
  local r=setup()local d=data()d.members={1,1}t.expect.falsy(r:Create(d))d=data()d.members={1,2,3,4,5,6,7}t.expect.falsy(r:Create(d))d.sameTeam=false t.expect.truthy(r:Create(d))
  local record=r:Get("opaque-guid")record.version=2 t.expect.falsy(R.Validate(record))
 end)
 t.test("restoration validates entire formation before mutation",function()
  local roster=Roster.new({id=function()return"existing"end})roster:Create(2)
  t.expect.falsy(roster:Restore({id="arrival",leader=1,members={1,2},sameTeam=true}))t.expect.equal(roster:Get(1),nil)
  roster:Forget(2)local ok,g=roster:Restore({id="arrival",leader=1,members={1,2},sameTeam=false})t.expect.truthy(ok)t.expect.equal(g.leader,1)t.expect.falsy(g.sameTeam)
  t.expect.falsy(roster:Restore({id="again",leader=1,members={1,2},sameTeam=true}))
 end)
end
