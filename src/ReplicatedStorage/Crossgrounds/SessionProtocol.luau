local Protocol={Version=1}
Protocol.States={idle=true,joining=true,ready=true,entering=true,travelling=true,failed=true}
local actions={join=true,cancel=true,enter=true,returnHub=true,dismiss=true}
function Protocol:Validate(command)
 if typeof(command)~="table" then return false,"Solicitação inválida." end
 for key in pairs(command) do if key~="action" and key~="gameId" and key~="ticket" then return false,"Campo não permitido." end end
 if typeof(command.action)~="string" or not actions[command.action] then return false,"Ação desconhecida." end
 if command.gameId~=nil and (typeof(command.gameId)~="string" or #command.gameId>40) then return false,"Modalidade inválida." end
 if command.ticket~=nil and (typeof(command.ticket)~="number" or command.ticket~=command.ticket or command.ticket<1 or command.ticket%1~=0 or command.ticket>1e12) then return false,"Solicitação expirada." end
 if command.action=="join" and not command.gameId then return false,"Escolha uma modalidade." end
 if (command.action=="enter" or command.action=="cancel") and not command.ticket then return false,"Solicitação expirada." end
 return true
end
return Protocol

