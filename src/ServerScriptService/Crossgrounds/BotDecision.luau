-- Small utility selector. Inputs contain observations, never hidden target positions.
local Decision={}
function Decision.Choose(memory,resources,personality,objective,now,current,since)
 local seen=memory.visible and memory.target~=nil
 local scores={Objective=objective and (.65+personality.Objective+(objective.critical and .7 or 0)) or -1,
  Engage=seen and (.58+personality.Engage+(resources.distance<55 and .12 or 0)) or -1,
  Retreat=seen and ((1-resources.health)*.85+personality.Cover+(resources.ammo==0 and .35 or 0)-personality.Risk) or -1,
  Search=not seen and memory.position and memory.confidence>.1 and (.82+memory.confidence*.1+personality.Engage*.3) or -1,Patrol=.1}
 if resources.health<.18 and seen then scores.Retreat+=.6 end
 for key,value in scores do if value>=0 then scores[key]=math.clamp(value,0,1) end end
 if resources.reserve==0 and resources.ammo==0 then scores.Engage=-1 end
 local best,score="Patrol",scores.Patrol
 for _,key in {"Objective","Engage","Retreat","Search"} do if scores[key]>score then best=key score=scores[key] end end
 local critical=resources.health<.18 and seen or objective and objective.critical
 if not critical and current and (scores[current] or -1)>=0 and now-since<.85 then best=current
 elseif not critical and current and (scores[current] or -1)>=score-.12 then best=current end
 return best,scores,critical and "critical" or "utility"
end
return Decision
