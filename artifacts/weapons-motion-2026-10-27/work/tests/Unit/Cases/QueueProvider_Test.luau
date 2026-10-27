return function(t)
 local Queue=require(game.ServerScriptService.Crossgrounds.QueueProvider)
 -- Enter must be confirmed once, after server readiness.
 t.test("requires readiness and consumes only once",function()
  local q,p=Queue.new(),{} local ok,item=q:Join(p,"ctf")
  t.expect.truthy(ok) t.expect.equal(q:Get(p).state,"joining")
  t.expect.falsy(q:Consume(p,item.ticket)) t.expect.truthy(q:Ready(p,item.ticket,"local"))
  t.expect.truthy(q:Consume(p,item.ticket)) t.expect.equal(q:Get(p).state,"entering")
  t.expect.falsy(q:Consume(p,item.ticket))
 end)
 -- Two requests must not create competing admissions.
 t.test("rejects duplicate join",function()
  local q,p=Queue.new(),{} q:Join(p,"ctf")
  t.expect.falsy(q:Join(p,"ctf"))
 end)
 -- A stale UI event must not cancel a newer request.
 t.test("stale cancellation preserves the active ticket",function()
  local q,p=Queue.new(),{} local _,a=q:Join(p,"ctf")
  q:Cancel(p,a.ticket) local _,b=q:Join(p,"ctf")
  t.expect.falsy(q:Cancel(p,a.ticket)) t.expect.equal(q:Get(p).ticket,b.ticket)
 end)
 -- Once cancelled, delayed readiness must not recreate a request.
 t.test("cancel prevents delayed readiness",function()
  local q,p=Queue.new(),{} local _,a=q:Join(p,"ctf")
  t.expect.truthy(q:Cancel(p,a.ticket)) t.expect.falsy(q:Ready(p,a.ticket,"local"))
  t.expect.equal(q:Get(p).state,"idle")
 end)
 -- No cancellation success is claimed after entry or travel begins.
 t.test("does not falsely cancel an ongoing transition",function()
  local q,p=Queue.new(),{} local _,a=q:Join(p,"ctf") q:Ready(p,a.ticket,"teleport") q:Consume(p,a.ticket)
  t.expect.falsy(q:Cancel(p,a.ticket)) t.expect.truthy(q:Travelling(p))
  t.expect.falsy(q:Cancel(p,a.ticket)) t.expect.equal(q:Get(p).state,"travelling")
 end)
 -- A late failure cannot overwrite a new ticket.
 t.test("ignores failure for an old ticket",function()
  local q,p=Queue.new(),{} local _,a=q:Join(p,"ctf") q:Cancel(p,a.ticket)
  local _,b=q:Join(p,"ctf") t.expect.falsy(q:Fail(p,"old",a.ticket))
  t.expect.equal(q:Get(p).ticket,b.ticket)
 end)
 -- Player state and caller copies are independent.
 t.test("isolates player and snapshot state",function()
  local q,a,b=Queue.new(),{},{} q:Join(a,"ctf") local snapshot=q:Get(a) snapshot.state="idle"
  t.expect.equal(q:Get(a).state,"joining") t.expect.equal(q:Get(b).state,"idle")
  q:Clear(a) t.expect.equal(q:Get(a).state,"idle")
 end)
end
