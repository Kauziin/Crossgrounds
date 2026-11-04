-- Server observations only. Cosmetic client sounds cannot publish here.
local Noise={} local entries={} local sequence=0
function Noise.Emit(actor,position,radius)
 sequence+=1 table.insert(entries,{id=sequence,actor=actor,position=position,radius=math.clamp(radius or 100,10,180),time=os.clock()})
 while #entries>48 do table.remove(entries,1) end
end
function Noise.Since(id,now)
 local result={} for _,entry in entries do if entry.id>id and now-entry.time<2 then table.insert(result,entry) end end
 return result,sequence
end
return Noise
