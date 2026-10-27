return function(t)
 local Travel=require(game.ServerScriptService.Crossgrounds.TravelService)
 -- All IDs below are synthetic test fixtures, never production configuration.
 local function make(overrides)
  local config={PlaceRole="hub",TeleportEnabled=true,ApprovedUniverseId=202,CTFPlaceId=303,HubPlaceId=404}
  for k,v in overrides or {} do config[k]=v end
  local signal={callback=nil}
  function signal:Connect(fn) self.callback=fn return {Disconnect=function() self.callback=nil end} end
  local spy={calls=0,timers={},signal=signal,studio=false,failFetch=false,failSend=false}
  local travel=Travel.new(config,{
   PlaceId=101,UniverseId=202,IsStudio=function() return spy.studio end,FailureSignal=signal,
   FetchPlaces=function() if spy.failFetch then error("fixture fetch error") end return {[303]=true,[404]=true} end,
   Teleport=function(id,players,options)
    spy.calls+=1 spy.id=id spy.players=players spy.data=options:GetTeleportData()
    if spy.failSend then error("fixture transport error") end
   end,
   Schedule=function(_,fn) table.insert(spy.timers,fn) end,
  })
  return travel,spy
 end
 -- Unknown or out of Universe destinations never reach the transport.
 t.test("rejects absent and external destinations",function()
  local travel,spy=make() t.expect.falsy(travel:Verify(nil)) t.expect.falsy(travel:Verify(999))
  t.expect.falsy(travel:Verify(101)) t.expect.equal(spy.calls,0) travel:Destroy()
 end)
 -- Universe approval must match the current server.
 t.test("rejects wrong Universe approval",function()
  local travel=make({ApprovedUniverseId=999}) t.expect.falsy(travel:Verify(303)) travel:Destroy()
 end)
 -- Configuration must explicitly enable inter-Place travel.
 t.test("rejects disabled transport",function()
  local travel=make({TeleportEnabled=false}) t.expect.falsy(travel:Route("ctf",false)) travel:Destroy()
 end)
 -- Studio cannot claim real teleport support.
 t.test("Studio never sends a real teleport",function()
  local travel,spy=make() spy.studio=true
  t.expect.equal(travel:Route("ctf",false),nil)
  t.expect.falsy(travel:Begin({Parent=true},{placeId=303,gameId="ctf"},function() end))
  t.expect.equal(spy.calls,0) travel:Destroy()
 end)
 -- A failed membership query blocks admission, without guessing.
 t.test("membership lookup failure is recoverable",function()
  local travel,spy=make() spy.failFetch=true
  t.expect.falsy(travel:Verify(303)) spy.failFetch=false t.expect.truthy(travel:Verify(303)) travel:Destroy()
 end)
 -- Local prototype is explicit and does not use transport.
 t.test("local preparation has no teleport call",function()
  local travel,spy=make({PlaceRole="combinedPrototype",EnableLocalCTFPrototype=true,TeleportEnabled=false})
  t.expect.equal(travel:Route("ctf",true).kind,"local") t.expect.equal(spy.calls,0) travel:Destroy()
 end)
 -- A verified route sends only the server selected destination.
 t.test("verified request sends once and blocks duplicate",function()
  local travel,spy=make() local p={Parent=true} local route=travel:Route("ctf",false)
  t.expect.truthy(travel:Begin(p,route,function() end))
  t.expect.equal(spy.calls,1) t.expect.equal(spy.id,303) t.expect.equal(spy.players[1],p)
  t.expect.equal(spy.data.sourcePlaceId,101)
  t.expect.falsy(travel:Begin(p,route,function() end)) travel:Destroy()
 end)
 -- TeleportInitFailed affects only the matching player and destination.
 t.test("late transport failure releases the player for retry",function()
  local travel,spy=make() local p={Parent=true} local failed=0 local route=travel:Route("ctf",false)
  travel:Begin(p,route,function() failed+=1 end)
  spy.signal.callback({},nil,nil,303) spy.signal.callback(p,nil,nil,404) t.expect.equal(failed,0)
  spy.signal.callback(p,nil,nil,303) t.expect.equal(failed,1)
  t.expect.truthy(travel:Begin(p,route,function() end)) travel:Destroy()
 end)
 -- A missing completion produces failure, never synthetic arrival.
 t.test("unconfirmed travel times out",function()
  local travel,spy=make() local failed=0
  travel:Begin({Parent=true},travel:Route("ctf",false),function() failed+=1 end)
  spy.timers[1]() t.expect.equal(failed,1) travel:Destroy()
 end)
 -- Immediate transport errors are surfaced synchronously.
 t.test("transport exception does not leave a pending request",function()
  local travel,spy=make() spy.failSend=true local p={Parent=true} local route=travel:Route("ctf",false)
  t.expect.falsy(travel:Begin(p,route,function() end))
  spy.failSend=false t.expect.truthy(travel:Begin(p,route,function() end)) travel:Destroy()
 end)
 -- Removing a player cancels pending callbacks.
 t.test("forget prevents a late failure callback",function()
  local travel,spy=make() local p={Parent=true} local failed=0
  travel:Begin(p,travel:Route("ctf",false),function() failed+=1 end)
  travel:Forget(p) spy.signal.callback(p,nil,nil,303) spy.timers[1]()
  t.expect.equal(failed,0) travel:Destroy()
 end)
end
