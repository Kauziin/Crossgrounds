return function(source,policy)
 local function signal()
  local list={} local s={}
  function s:Connect(fn) table.insert(list,fn) return {Disconnect=function() end} end
  function s:Once(fn) local used=false return self:Connect(function(...) if not used then used=true fn(...) end end) end
  function s:Fire(...) for _,fn in list do fn(...) end end return s
 end
 local function entity(attrs)
  local signals={} local e={}
  function e:GetAttribute(k) return attrs[k] end
  function e:SetAttribute(k,v) attrs[k]=v if signals[k] then signals[k]:Fire() end end
  function e:GetAttributeChangedSignal(k) signals[k]=signals[k] or signal() return signals[k] end
  function e:WaitForChild(k) return self[k] end
  return e
 end
 local p=entity({CrossgroundsMode="hub"}) p.CharacterAdded=signal()
 local h={Health=100,HealthChanged=signal(),Died=signal()}
 local root={Position=Vector3.zero} local character={Destroying=signal()}
 function character:WaitForChild() return h end
 function character:FindFirstChildOfClass() return h end
 function character:FindFirstChild() return root end
 p.Character=character
 local beast=entity({CrossgroundsMode="get_out",GetOutRole="beast",GetOutRoundId=1})
 local beastRoot={Position=Vector3.new(20,0,0)} local beastHealth={Health=100}
 beast.Character={FindFirstChild=function() return beastRoot end,FindFirstChildOfClass=function() return beastHealth end}
 local players={LocalPlayer=p,GetPlayers=function() return {p,beast} end}
 local step=signal() local state=signal() local flag=signal()
 local remotes={State={OnClientEvent=state},Feedback={OnClientEvent=signal()}}
 local cross={WaitForChild=function() return remotes end}
 local events={WaitForChild=function() return {OnClientEvent=flag} end}
 local rs={WaitForChild=function(_,k) return k=="Events" and events or cross end,Crossgrounds={AudioEventPolicy="Policy"}}
 local plays={} local stops={} local audio={}
 function audio:Play(cue) table.insert(plays,cue) end function audio:Stop(cue) stops[cue]=(stops[cue] or 0)+1 end
 local now=100 local world=entity({RoundState="Playing"}) function world:GetServerTimeNow() return now end
 local fake={Players=players,ReplicatedStorage=rs,GetService=function(_,k) return k=="Players" and players or {Heartbeat=step} end}
 local f=assert(loadstring(source)) setfenv(f,setmetatable({game=fake,workspace=world,script={Parent={WaitForChild=function(_,n) return n end}},require=function(n) return n=="GameAudio" and audio or policy end},{__index=getfenv()})) f() task.wait(.05)
 local checks={} local function check(ok,text) assert(ok,text) table.insert(checks,text) end
 local function count(cue) local n=0 for _,v in plays do if v==cue then n+=1 end end return n end
 local function tick() now+=.2 step:Fire(.2) end
 tick() check(#plays==0,"Hub emits no gameplay sounds")
 p:SetAttribute("CrossgroundsMode","arena") p:SetAttribute("ArenaPlaying",true) tick()
 check(count("Respawn")==1,"Arena spawn cue waits for participation")
 p:SetAttribute("ArenaPlaying",false) h.Health=0 h.Died:Fire()
 check(count("Eliminated")==1,"Elimination survives ArenaPlaying clearing before Died")
 h.Health=100 p:SetAttribute("CrossgroundsMode","get_out")
 state:Fire({id="get_out",roundId=1,state="playing",role="survivor",result="active",gameplay={victim="Active"}}) tick()
 check(count("BeastPulse")==1,"Survivor hears nearby beast")
 beast:SetAttribute("GetOutRoundId",2) tick() check(p:GetAttribute("BeastProximity")==0,"Different-round beast cannot trigger proximity")
 beast:SetAttribute("GetOutRoundId",1)
 state:Fire({id="get_out",roundId=1,state="playing",role="beast",result="active",gameplay={victim="Active"}}) tick()
 check(p:GetAttribute("BeastProximity")==0,"Beast does not hear its own proximity cue")
 state:Fire({id="get_out",roundId=1,state="playing",role="survivor",result="active",gameplay={victim="Captured"}}) tick()
 check(p:GetAttribute("BeastProximity")==0,"Captured survivor has no proximity pulse")
 state:Fire({id="get_out",roundId=1,state="playing",role="survivor",result="active",gameplay={victim="Active",hack={sequence=1,checkAt=now,checkEnd=now+2}}}) tick() tick()
 check(count("HackCheck")==1,"Hack timing signal fires once per check")
 p:SetAttribute("CrossgroundsMode","hub") tick() check(p:GetAttribute("BeastProximity")==0 and stops.BeastPulse>0,"Returning to hub stops proximity audio")
 return checks
end
