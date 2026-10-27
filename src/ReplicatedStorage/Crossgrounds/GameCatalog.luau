local Catalog={}
local definitions={
 {id="ctf",name="Capture a Bandeira",status="prototype",description="Capture a bandeira inimiga e proteja a sua. Duas equipes, três kits e bots para completar a partida.",capacity={teams=2,combatantsPerTeam=6,maxCombatants=12},version="0.1.0"},
 {id="get_out",name="Get Out",status="prototype",version="0.5-p0",description="Hackeie quatro PCs, use portas e dutos e resgate aliados para escapar da Besta. Duas saídas; 2 a 5 jogadores."},
 {id="duels",name="Duels",status="planned",description="Uma modalidade de duelos em desenvolvimento."},
 {id="arena",name="Arena",status="prototype",version="0.1.0-hubtest",description="Combate rápido em primeira pessoa. 20 de vida, pistolas e reaparecimento após a morte. Vote no próximo mapa."},
}
function Catalog:Get(id)
 for _,item in definitions do if item.id==id then local copy=table.clone(item) if copy.capacity then copy.capacity=table.clone(copy.capacity) end return copy end end
end
function Catalog:List()
 local list={} for _,item in definitions do table.insert(list,self:Get(item.id)) end return list
end
return Catalog

