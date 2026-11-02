local Burst={}
function Burst.Config(data,converted)
 local count=data.BurstCount
 if converted then count=3 end
 if not count then return end
 return {count=count,interval=data.BurstInterval or .1,pause=data.BurstPause or .28}
end
function Burst.Ready(state,now)
 return not state.nextAt or now+.025>=state.nextAt
end
function Burst.Commit(state,now,config)
 if state.last and now-state.last>.6 then state.count=0 end
 state.count=(state.count or 0)+1 state.last=now
 local scheduled=math.max(now,state.nextAt or now)
 if state.count>=config.count then state.count=0 state.nextAt=scheduled+config.pause else state.nextAt=scheduled+config.interval end
end
return Burst

