local shared=script.Parent.Working.Shared
local P=require(shared.ControlPolicy) local D=require(shared.ControlDefinitions)
local count=0
local function check(value,message) count+=1 assert(value,message) end
local function state(changes)
 local s={mode="ctf",alive=true,inMatch=true,arenaPlaying=true,authorized=true,victim="Active"}
 for key,value in changes or {} do s[key]=value end return s
end
local function allowed(action,changes) return P.Available(action,state(changes)) end
for _,device in {"Keyboard","Gamepad"} do
 local bindings={}
 for action,data in D.Actions do
  bindings[action]=data[device]
  check(D:IsAllowed(device,data[device],action),"Invalid default "..action)
 end
 for a in D.Actions do for b in D.Actions do
  if a<b then check(bindings[a]~=bindings[b] or not P.Conflicts(a,b),device..": default conflict "..a.."/"..b) end
 end end
 local normalized=P.Normalize(D,bindings,device)
 for action,key in bindings do check(normalized[action]==key,"Normalization changed a valid default") end
end
check(not P.Conflicts("Fire","GetOutAttack"),"Exclusive combat actions must share")
check(not P.Conflicts("Shoulder","MenuNext"),"Menu should share shoulder")
check(not P.Conflicts("ShiftLock","AdminSpeedDown"),"Admin should share shift lock")
check(P.Conflicts("Menu","AdminSpeedUp"),"Menu and admin speed overlap")
check(P.Conflicts("AdminMode","Fire"),"Admin activation overlaps gameplay")
for action in D.Actions do
 check(not allowed(action,{suspended=true}),"Suspension leaked "..action)
 check(not allowed(action,{modal=true,settingsMenu=false}) or action=="MenuNext" or action=="MenuPrevious","Modal leaked "..action)
end
for _,attr in {"modal","suspended","admin","spectating"} do
 check(not allowed("Fire",{[attr]=true}),"Fire blocked by "..attr)
end
check(allowed("Menu",{admin=true}),"Settings must open in admin")
check(not allowed("AdminSpeedUp",{admin=true,modal=true}),"Admin controls must yield to menus")
check(allowed("AdminSpeedUp",{admin=true}),"Admin speed unavailable")
check(not allowed("AdminMode",{authorized=false,inMatch=false}),"Permission check")
check(not allowed("AdminMode"),"Admin must leave match before activating")
check(allowed("AdminMode",{inMatch=false}),"Admin should start outside match")
check(allowed("AdminMode",{admin=true}),"Admin must be able to exit")
check(allowed("GetOutCrawl",{mode="get_out",role="survivor"}),"Survivor crawl")
check(not allowed("GetOutCrawl",{mode="get_out",role="beast"}),"Beast cannot crawl")
check(not allowed("GetOutAttack",{mode="get_out",role="survivor"}),"Survivor cannot attack")
check(allowed("GetOutAttack",{mode="get_out",role="beast"}),"Beast attack")
check(not allowed("GetOutCheck",{mode="get_out",role="survivor"}),"Check outside hack")
check(allowed("GetOutCheck",{mode="get_out",role="survivor",hacking=true}),"Check during hack")
check(not allowed("ReloadInteract",{mode="get_out",role="survivor",hacking=true}),"Interaction during hack")
check(not allowed("GetOutDrop",{mode="get_out",role="beast"}),"Drop without victim")
check(allowed("GetOutDrop",{mode="get_out",role="beast",dragging=true}),"Drop with victim")
check(not allowed("Fire",{mode="arena",arenaPlaying=false}),"Arena waiting cannot fire")
check(not allowed("Fire",{alive=false}),"Dead player cannot fire")
check(not allowed("Fire",{inMatch=false}),"Lobby cannot fire")
check(not allowed("GetOutAttack",{mode="get_out",role="beast",result="captured"}),"Ended round cannot attack")
for _,device in {"Keyboard","Gamepad"} do
 local bindings={} for action,data in D.Actions do bindings[action]=data[device] end
 local old=bindings.ReloadInteract
 local plan=P.Plan(D,bindings,"ReloadInteract",device,bindings.Fire)
 check(plan~=nil,"Multi-conflict swap failed")
 check(plan.Fire==old and plan.GetOutAttack==old,"Both world contexts must be reassigned")
 check(bindings.Fire==D.Actions.Fire[device],"Plan mutated original")
 local legacy=table.clone(bindings)
 legacy.AdminSpeedUp=bindings.Menu legacy.AdminSpeedDown=bindings.Perspective
 local repaired=P.Normalize(D,legacy,device)
 check(repaired~=nil,"Legacy migration")
 for a in D.Actions do for b in D.Actions do
  if a<b then check(repaired[a]~=repaired[b] or not P.Conflicts(a,b),"Migrated conflict "..a.."/"..b) end
 end end
end
check(not D:IsAllowed("Keyboard","W","AdminSpeedUp"),"W must stay movement")
check(not D:IsAllowed("Keyboard","Space","Fire"),"Space must stay jump/check")
check(P.Plan(D,{},"Unknown","Gamepad","ButtonA")==nil,"Unknown action")
return {passed=count}
