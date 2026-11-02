-- Imported sample IDs originate in ServerStorage.ImportedArsenalOriginals.
-- Availability/permissions and listening must be checked in the published universe.
local Library={}
Library.Banks={
 mp7={MagOut=2111370397,MagIn=2111371028,Seat=484110242,BoltBack=1081972959,BoltForward=1081973132},
 mp5={MagOut=292201848,MagIn=293309896,Seat=321719832},
 pkm={MagOut=620783923,MagIn=620784044,Seat=627851977,BoltBack=393678915,BoltForward=393678926,LidUp=873154055,LidDown=873154203},
 awp={MagOut=1352731010,MagIn=1352730873,Seat=537744814,BoltBack=1352729449,BoltForward=1352729982},
 fn_fal={MagOut=877467882,MagIn=898393418,Seat=321719832,BoltBack=1544313552,BoltForward=1313112558},
}
Library.Profiles={mp7="mp7",mp5="mp5",pkm="pkm",fn_fal="fn_fal",awp="awp",ax_50="awp"}
Library.Provisional={ax_50=true} -- Shared bolt-action bank, not an original AX-50 recording.
function Library.Events(id,empty)
 local bank=Library.Banks[Library.Profiles[id]] if not bank then return {} end
 local times={{.05,"LidUp"},{.12,"MagOut"},{.62,"MagIn"},{.72,"Seat"},{.76,"LidDown"}}
 if empty then table.insert(times,{.80,"BoltBack"}) table.insert(times,{.90,"BoltForward"}) end
 local result={} for _,event in times do if bank[event[2]] then table.insert(result,{at=event[1],name=event[2],id=bank[event[2]]}) end end
 return result
end
-- Never replay old events when a weapon enters hearing range midway through reload.
function Library.Crossed(events,previous,current)
 local result={} for _,event in events do if event.at>previous and event.at<=current then table.insert(result,event) end end return result
end
return Library
