-- Visual fixtures only. No commands, rewards or persistence writes.
local scenarios={}
local function add(id,mode,attributes,events)
 table.insert(scenarios,{id=id,mode=mode,attributes=attributes or {},events=events or {}})
end
add("hub","hub")
add("ctf-hud","ctf",{InMatch=true,InArena=true})
add("arena-hud","arena",{ArenaPlaying=true,ArenaKills=12,ArenaDeaths=4,ArenaSessionXP=350})
for _,kind in {"pickup","drop","return","capture"}do
 add("ctf-flag-"..kind,"ctf",{InMatch=true,InArena=true},{{path="Events.CTFFlagAlert",data={kind=kind,team="Red",carrier="Jogador de teste",self=true}}})
end
add("ctf-victory","ctf",{InMatch=true,InArena=true},{{path="Events.DisplayVictory",special="blue"}})
add("ctf-tie","ctf",{InMatch=true,InArena=true},{{path="Events.DisplayVictory",value="Tie"}})
add("ctf-elimination","ctf",{InMatch=true,InArena=true},{{path="Events.CombatFeedback",data={kind="Kill",victim="Alvo de teste",headshot=true,xp=125}},{path="Events.KillFeed",data={killer="Você",victim="Alvo de teste",killerTeam="Blue",victimTeam="Red",weapon="M4A1",headshot=true}}})
for _,kind in {"account","weapon"}do add("level-"..kind,"hub",{},{{path="Crossgrounds.Remotes.LevelUpNotice",data={kind=kind,level=24,weapon="m4a1"}}})end
add("party-invitation","hub",{},{{path="Crossgrounds.Remotes.PartyState",data={invite={name="Amigo de teste",id="debug-invite",expiresAt=9999999999}}}})
add("ctf-vote","ctf",{InMatch=true},{{path="Events.MapVoteState",data={active=true,endsAt=9999999999,options={{id="riverside",name="Travessia",description="Mapa atual"}},counts={riverside=3},vote="riverside"}}})
add("arena-vote","arena",{},{{path="Crossgrounds.ArenaRemotes.State",data={id="arena",state="voting",endsAt=9999999999,options={{id="debug_map",name="Mapa de teste",description="Fixture visual"}},counts={debug_map=4}}}})
add("arena-respawn","arena",{ArenaPlaying=true,ArenaRespawnAt=9999999999})
for _,state in {"waiting","playing","enraged","results"}do for _,role in {"survivor","beast"}do
 add("getout-"..role.."-"..state,"get_out",{},{{path="Crossgrounds.GetOutRemotes.State",data={id="get_out",role=role,state=state,remaining=125,computers=2,result=state=="results"and"escaped"or nil,abilityReadyIn=0}}})
end end
for _,victim in {"Downed","Dragged","Captured"}do add("getout-"..victim,"get_out",{},{{path="Crossgrounds.GetOutRemotes.State",data={id="get_out",role="survivor",state="playing",remaining=95,computers=3,gameplay={victim=victim,freeze=.42}}}})end
add("getout-hacking","get_out",{},{{path="Crossgrounds.GetOutRemotes.State",data={id="get_out",role="survivor",state="playing",remaining=95,computers=3,gameplay={hack={progress=.65}}}}})
add("loading","hub",{ClientLoading=true})
add("loading-error","ctf",{SceneLoadingError="Falha simulada ao carregar o cenário. Tente novamente.",ClientLoading=true})
add("damage","ctf",{InMatch=true,InArena=true})
add("interaction","ctf",{InMatch=true,InArena=true})
add("dialog","hub")
add("eliminated","ctf",{InMatch=true},{{path="Events.CombatFeedback",special="eliminated"}})
local entries={{rank=1,name="Jogador de teste",userId=0,isBot=true,kills=18,deaths=4,score=3,medal="gold",prestige=2},{rank=2,name="Outro jogador",userId=0,isBot=true,kills=12,deaths=7,score=1,medal="silver",prestige=0}}
add("standings-ctf","ctf",{InMatch=true},{{path="Crossgrounds.Remotes.Standings",data={mode="ctf",entries=entries}}})
add("standings-arena","arena",{ArenaPlaying=true},{{path="Crossgrounds.Remotes.Standings",data={mode="arena",entries=entries}}})
add("weapon-hud","ctf",{InMatch=true,InArena=true})
add("gamepad-help","ctf",{InMatch=true,StudioInterfaceInput="Gamepad"})
add("optical-scope","ctf",{InMatch=true})
add("optical-reflex","ctf",{InMatch=true})
add("clan-fixture","hub")
add("party-fixture","hub")
for _,s in scenarios do if s.mode=="get_out"then for _,event in s.events do if event.data then event.data.gameplay=event.data.gameplay or {victim="Active"}end end end end
return scenarios
