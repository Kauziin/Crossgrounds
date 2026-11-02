-- Collective local admission: reserve first, then enter; any failure rolls back.
local Admission={} Admission.__index=Admission
local Http=game:GetService("HttpService")
local Balance=require(script.Parent.ProgressionBalance)
function Admission.new(coordinator,party)
 local self=setmetatable({coordinator=coordinator,party=party,active={},byPlayer={}},Admission)
 party.SetRemovalHandler(function(group,_,disconnected)
  local entry=self.active[group.id]
  if not entry then return true end
  if entry.entering and not disconnected then return false,"Aguarde a entrada terminar antes de sair." end
  self:Cancel(entry,"A formação do grupo mudou.") return true
 end)
 return self
end
function Admission:Publish(entry)
 for _,p in entry.members do if p.Parent then self.coordinator:Publish(p) end end
end
function Admission:Release(entry)
 if entry.adapter and entry.reserved then entry.adapter:ReleaseAdmission(entry.token) entry.reserved=false end
 if self.active[entry.group.id]==entry then self.active[entry.group.id]=nil end
 for _,p in entry.members do if self.byPlayer[p]==entry then self.byPlayer[p]=nil end end
 if entry.group.lock==entry.token then self.party.Roster:SetLock(entry.group,nil) end
end
function Admission:Cancel(entry,message)
 entry.cancelled=message
 if entry.entering then return end -- Enter coroutine owns rollback after yields.
 self:Release(entry)
 for _,p in entry.members do self.coordinator.queue:Fail(p,message) end
 self:Publish(entry)
end
function Admission:Prepare(player,command,group)
 local c=self.coordinator
 if group.leader~=player.UserId then c:Error(player,"Somente o líder inicia a busca do grupo.") return end
 if group.lock then c:Error(player,"Já existe uma entrada de grupo em andamento.") return end
 local route,reason=c:Route(command.gameId)
 if not route then c:Error(player,reason) return end
 local remote=route.kind=="teleport"
 if remote and not c.partyTravel:Enabled()then c:Error(player,"Viagem coletiva entre Places ainda não foi habilitada.")return end
 local adapter=c.adapters[command.gameId]
 if not remote and(not adapter or not adapter.ReserveAdmission)then c:Error(player,"A modalidade ainda não admite grupos.") return end
 local members=self.party.Members(group)
 local definition=require(game.ReplicatedStorage.Crossgrounds.GameCatalog):Get(command.gameId)
 local limit=command.gameId=="ctf"and group.sameTeam and 6 or definition.capacity.maxCombatants
 if #members>limit then c:Error(player,"Esta opção aceita até "..limit.." integrantes. Remova pessoas ou permita a divisão de equipes.")return end
 if #members~=#group.members then c:Error(player,"Aguarde todos os integrantes chegarem ao lobby.") return end
 for _,p in members do
  local q=c.queue:Get(p)
  if c.context:GetMode(p)~="hub" or p:GetAttribute("ModeCharacterReady")~=true or p:GetAttribute("CrossgroundsTransition") or q.state~="idle" and q.state~="failed" then c:Error(player,p.DisplayName.." precisa estar livre e pronto no lobby.") return end
 end
 local entry={group=group,members=members,token=Http:GenerateGUID(false),adapter=adapter,gameId=command.gameId,route=route,tickets={}}
 if not remote then
  local reserved,err=adapter:ReserveAdmission(members,group.sameTeam,entry.token)
  if not reserved then c:Error(player,err or "Não há vagas para o grupo inteiro.") return end
  entry.reserved=true
 end
 self.active[group.id]=entry
 self.party.Roster:SetLock(group,entry.token)
 entry.revision=group.revision
 for _,p in members do
  local ok,item=c.queue:Join(p,command.gameId)
  if not ok then self:Cancel(entry,"Uma solicitação concorrente impediu a entrada.") return end
  entry.tickets[p]=item.ticket self.byPlayer[p]=entry
  c.queue:Ready(p,item.ticket,route.kind)
  local q=c.queue.entries[p] q.collective=true q.leaderUserId=group.leader q.partySize=#members
  q.message=p==player and "Grupo pronto. Confirme a entrada coletiva." or "Aguardando o líder confirmar a entrada."
 end
 self:Publish(entry)
 task.delay(Balance.Get("PartyAdmissionSeconds"),function() if self.active[group.id]==entry and not entry.entering then self:Cancel(entry,"A confirmação de entrada do grupo expirou.") end end)
end
function Admission:Enter(player,entry,ticket)
 local c=self.coordinator
 if player.UserId~=entry.group.leader then c:Error(player,"A confirmação pertence ao líder do grupo.") return end
 if ticket~=entry.tickets[player] or entry.entering or entry.cancelled then c:Error(player,"Entrada coletiva expirada.") return end
 if entry.group.revision~=entry.revision then self:Cancel(entry,"O grupo mudou. Inicie uma nova busca.") return end
 for _,p in entry.members do
  if not p.Parent or c.context:GetMode(p)~="hub" or p:GetAttribute("CrossgroundsTransition") or p:GetAttribute("ModeCharacterReady")~=true then self:Cancel(entry,"Um integrante não está mais pronto no lobby.") return end
 end
 for _,p in entry.members do
  local ok=c.queue:Consume(p,entry.tickets[p]) if not ok then self:Cancel(entry,"A entrada de um integrante expirou.") return end
 end
 entry.entering=true
 for _,p in entry.members do p:SetAttribute("CrossgroundsTransition",true) end
 self:Publish(entry)
 if entry.route.kind=="teleport"then
  for _,p in entry.members do c.queue:Travelling(p)end self:Publish(entry)
  local sent,reason=c.partyTravel:Begin(entry,function(message)
   self:Release(entry)
   for _,p in entry.members do if p.Parent then p:SetAttribute("CrossgroundsTransition",false)if message then c.queue:Fail(p,message)else c.queue:Clear(p)end end end self:Publish(entry)
  end)
  if not sent then self:Release(entry)for _,p in entry.members do if p.Parent then p:SetAttribute("CrossgroundsTransition",false)c.queue:Fail(p,reason)end end self:Publish(entry)end
  return
 end
 task.spawn(function()
  local attempted={} local failure
  for _,p in entry.members do
   if entry.cancelled or not p.Parent then failure=entry.cancelled or "Um integrante desconectou." break end
   table.insert(attempted,p)
   local ok,why=c:CallAdapter(entry.adapter,"Enter",p)
   if not ok then failure=why or "Falha na entrada de um integrante." break end
  end
  failure=failure or entry.cancelled
  if failure then
   -- Include the member whose Enter failed: it may already own a staging rig.
   for i=#attempted,1,-1 do local p=attempted[i] if p.Parent then c:CallAdapter(entry.adapter,"Leave",p) end end
  end
  self:Release(entry)
  for _,p in entry.members do
   if p.Parent then
    p:SetAttribute("CrossgroundsTransition",false)
    if failure then c.queue:Fail(p,failure) else c.queue:Clear(p) end
   else c.queue:Clear(p) end
  end
  self:Publish(entry)
 end)
end
function Admission:Receive(group,members,mode)
 local c=self.coordinator local adapter=c.adapters[mode]
 if not adapter or not adapter.ReserveAdmission then return false,"O destino não admite essa modalidade."end
 local entry={group=group,members=members,adapter=adapter,token=Http:GenerateGUID(false),gameId=mode,entering=true}
 local reserved,reason=adapter:ReserveAdmission(members,group.sameTeam,entry.token)
 if not reserved then return false,reason end
 entry.reserved=true self.active[group.id]=entry self.party.Roster:SetLock(group,entry.token)
 local attempted={}local failure
 for _,p in members do
  if not p.Parent or entry.cancelled then failure=entry.cancelled or"Um integrante desconectou durante a chegada."break end
  table.insert(attempted,p)local ok,why=c:CallAdapter(adapter,"Enter",p)if not ok then failure=why break end
 end
 failure=failure or entry.cancelled
 if failure then for i=#attempted,1,-1 do local p=attempted[i]if p.Parent then c:CallAdapter(adapter,"Leave",p)end end end
 self:Release(entry)return failure==nil,failure
end
function Admission:Handle(player,command)
 local entry=self.byPlayer[player]
 if entry then
  if command.action=="enter" then self:Enter(player,entry,command.ticket)
  elseif command.action=="cancel" then
   if player.UserId~=entry.group.leader then self.coordinator:Error(player,"Peça ao líder para cancelar ou saia do grupo.")
   elseif command.ticket~=entry.tickets[player] then self.coordinator:Error(player,"Solicitação expirada.")
   elseif entry.entering then self.coordinator:Error(player,"A entrada já começou.")
   else self:Cancel(entry,"Entrada coletiva cancelada pelo líder.") end
  else self.coordinator:Error(player,"Conclua ou cancele a entrada do grupo primeiro.") end
  return true
 end
 local group=self.party.Get(player)
 if command.action=="join" and command.variant~="practice" and group and #group.members>1 then self:Prepare(player,command,group) return true end
 return false
end
return Admission
