-- Local admission requests only: no matchmaking, reservations or cross-server queue.
local Queue={}
Queue.__index=Queue
function Queue.new() return setmetatable({entries={},serial=0},Queue) end
function Queue:Get(player)
 local item=self.entries[player]
 return item and table.clone(item) or {state="idle",message="Escolha uma modalidade."}
end
function Queue:Join(player,gameId)
 local current=self:Get(player)
 if current.state~="idle" and current.state~="failed" then return false,"Já existe uma solicitação em andamento." end
 self.serial+=1
 local item={state="joining",gameId=gameId,ticket=self.serial,message="Verificando a entrada no protótipo..."}
 self.entries[player]=item return true,table.clone(item)
end
function Queue:Ready(player,ticket,route)
 local current=self.entries[player]
 if not current or current.ticket~=ticket or current.state~="joining" then return false end
 current.state="ready" current.route=route current.message=route=="local" and "Entrada local disponível. Não é fila nem reserva entre servidores." or "Destino verificado. Confirme para viajar."
 return true
end
function Queue:Cancel(player,ticket)
 local current=self.entries[player]
 if not current or current.ticket~=ticket then return false,"Solicitação expirada." end
 if current.state~="joining" and current.state~="ready" then return false,"A entrada já começou; não foi cancelada." end
 self.entries[player]=nil return true
end
function Queue:Consume(player,ticket)
 local current=self.entries[player]
 if not current or current.ticket~=ticket or current.state~="ready" then return false,"A entrada ainda não está pronta ou expirou." end
 current.state="entering" current.message="Entrando na modalidade..."
 return true,table.clone(current)
end
function Queue:Travelling(player)
 local current=self.entries[player] if not current or current.state~="entering" then return false end
 current.state="travelling" current.message="Viagem solicitada. Aguardando o Roblox..." return true
end
function Queue:Fail(player,message,ticket)
 local current=self.entries[player]
 if ticket and (not current or current.ticket~=ticket) then return false end
 current=current or {} current.state="failed" current.message=message self.entries[player]=current return true
end
function Queue:Clear(player) self.entries[player]=nil end
function Queue:Destroy() table.clear(self.entries) end
return Queue

