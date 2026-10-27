return function(t)
 local protocol=require(game.ReplicatedStorage.Crossgrounds.SessionProtocol)
 -- The documented admission command is accepted.
 t.test("accepts join and ticket commands",function()
  t.expect.truthy(protocol:Validate({action="join",gameId="ctf"}))
  t.expect.truthy(protocol:Validate({action="enter",ticket=1}))
  t.expect.truthy(protocol:Validate({action="cancel",ticket=1}))
  t.expect.truthy(protocol:Validate({action="returnHub"}))
 end)
 -- Clients cannot provide Place IDs or transport options.
 t.test("rejects client destination injection",function()
  t.expect.falsy(protocol:Validate({action="join",gameId="ctf",placeId=123}))
  t.expect.falsy(protocol:Validate({action="returnHub",TeleportData={}}))
 end)
 -- Expired, nonnumeric and nonfinite tickets cannot consume admission.
 t.test("rejects malformed tickets",function()
  for _,n in {0,-1,.5,math.huge,0/0,1e13,"1"} do t.expect.falsy(protocol:Validate({action="enter",ticket=n})) end
  t.expect.falsy(protocol:Validate({action="cancel"}))
 end)
 -- Missing fields and unknown actions fail predictably.
 t.test("rejects invalid commands",function()
  for _,c in {false,"join",{}, {action="join"},{action="spawn"},{action="join",gameId=2}} do t.expect.falsy(protocol:Validate(c)) end
 end)
end
