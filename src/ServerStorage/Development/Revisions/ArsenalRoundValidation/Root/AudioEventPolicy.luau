-- Pure decisions shared by presentation and tests. No server game-state writes.
local Policy={}
function Policy.Flag(event,ownTeam)
 if type(event)~="table" then return end
 local own=event.team==ownTeam
 if event.kind=="pickup" then return own and "FlagStolen" or "FlagPickup" end
 if event.kind=="capture" then return own and "FlagLost" or "FlagCaptured" end
 if event.kind=="return" then return "FlagReturned" end
 if event.kind=="drop" then return "FlagDropped" end
end
function Policy.Proximity(distance)
 local weight=math.clamp((70-distance)/55,0,1)
 return weight,1.55-1.03*weight
end
function Policy.GetOut(previous,current)
 local cues={}
 if not previous or previous.roundId~=current.roundId then return cues end
 if current.state~=previous.state then
  if current.state=="playing" then table.insert(cues,"RoundStart")
  elseif current.state=="enraged" then table.insert(cues,"BeastEnraged")
  elseif current.state=="results" then table.insert(cues,"RoundEnd") end
 end
 if (current.computers or 0)>(previous.computers or 0) then table.insert(cues,"ComputerComplete") end
 local before=(previous.gameplay or {}).victim local after=(current.gameplay or {}).victim
 if after~=before then
  if after=="Downed" then table.insert(cues,"Downed")
  elseif after=="Captured" then table.insert(cues,"Captured")
  elseif after=="Active" and (before=="Captured" or before=="Dragged") then table.insert(cues,"Rescued") end
 end
 if current.result~=previous.result and current.result=="escaped" then table.insert(cues,"Escaped") end
 return cues
end
return Policy
