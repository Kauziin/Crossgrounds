return function(t)
 local Ballot=require(game.ServerScriptService.Crossgrounds.MapBallot)
 local function make() return Ballot.new({{id="a"},{id="b"}}) end
 -- Unknown maps cannot enter the ballot.
 t.test("rejects maps outside current options",function() local b=make() t.expect.falsy(b:Vote({},"fake")) t.expect.equal(b:Counts().a,0) end)
 -- Each voter has only one current vote, even when clicking repeatedly.
 t.test("repeated votes count once",function() local b=make() local p={} b:Vote(p,"a") b:Vote(p,"a") t.expect.equal(b:Counts().a,1) end)
 -- Changing preference replaces the old vote.
 t.test("changing a vote removes the old choice",function() local b=make() local p={} b:Vote(p,"a") b:Vote(p,"b") t.expect.equal(b:Counts().a,0) t.expect.equal(b:Counts().b,1) end)
 -- Leaving a session withdraws its ballot.
 t.test("departure removes a vote",function() local b=make() local p={} b:Vote(p,"a") b:Remove(p) t.expect.equal(b:Counts().a,0) end)
 -- The majority choice is actually loaded by the owner.
 t.test("majority determines the winner",function() local b=make() b:Vote({},"b") b:Vote({},"b") b:Vote({},"a") t.expect.equal(b:Winner("b"),"b") end)
 -- Ties rotate away from the previous map without discarding votes.
 t.test("ties prefer another map",function() local b=make() t.expect.equal(b:Winner("a"),"b") end)
 -- Two sessions never share ballots.
 t.test("fresh ballots reset counts",function() local a,b=make(),make() a:Vote({},"a") t.expect.equal(b:Counts().a,0) end)
end
