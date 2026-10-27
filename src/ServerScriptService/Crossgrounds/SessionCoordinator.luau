local Coordinator={}
Coordinator.__index=Coordinator
local Players=game:GetService("Players")
local Catalog=require(game.ReplicatedStorage.Crossgrounds.GameCatalog)
local Protocol=require(game.ReplicatedStorage.Crossgrounds.SessionProtocol)
local Queue=require(script.Parent.QueueProvider)
function Coordinator.new(context,travel,preferences,remotes)
 return setmetatable({context=context,travel=travel,preferences=preferences,remotes=remotes,queue=Queue.new(),adapters={},errors={},connections={},playerConnections={},rates={},snapshotRates={},revisions={}},Coordinator)
end
function Coordinator:Register(adapter)
 assert(Catalog:Get(adapter.id) and not self.adapters[adapter.id],"Adaptador duplicado ou não registrado.")
 self.adapters[adapter.id]=adapter
 if adapter.Changed then table.insert(self.connections,adapter.Changed:Connect(function()
  for _,p in Players:GetPlayers() do if self.context:GetMode(p)==adapter.id then self:Publish(p) end end
 end)) end
end
function Coordinator:Route(id)
 local definition=Catalog:Get(id)
 if id~="hub" and (not definition or definition.status=="planned") then return nil,"Modalidade em desenvolvimento; não possui entrada nem fila." end
 local adapter=self.adapters[id]
 return self.travel:Route(id,adapter and adapter:IsAvailable() or false)
end
function Coordinator:Snapshot(player)
 local list=Catalog:List()
 for _,definition in list do
  if definition.status~="planned" then
   local route,reason=self:Route(definition.id)
   definition.canEnter=route~=nil definition.route=route and route.kind or "unconfigured" definition.reason=reason
  else definition.canEnter=false definition.reason="Em desenvolvimento. Sem fila disponível." end
 end
 local mode=self.context:GetMode(player)
 local adapter=self.adapters[mode]
 return {version=Protocol.Version,revision=self.revisions[player] or 0,mode=mode,catalog=list,queue=self.queue:Get(player),session=adapter and adapter:Snapshot(player) or {state="hub"},error=self.errors[player],preferences=self.preferences:Describe(),prototype=self.travel.config.PlaceRole=="combinedPrototype"}
end
function Coordinator:Publish(player)
 if player.Parent then self.revisions[player]=(self.revisions[player] or 0)+1 self.remotes.State:FireClient(player,self:Snapshot(player)) end
end
function Coordinator:Error(player,message) self.errors[player]=message self:Publish(player) end
function Coordinator:CallAdapter(adapter,method,player)
 if not adapter or typeof(adapter[method])~="function" then return false,"Adaptador indisponível." end
 local ok,result,message=pcall(adapter[method],adapter,player)
 if not ok then warn("Crossgrounds adapter "..method..": "..tostring(result)) return false,"A modalidade não concluiu a transição. Tente novamente." end
 return result,message
end
function Coordinator:Command(player,command)
 local now=os.clock()
 local budget=self.rates[player]
 if not budget or now-budget.at>=1 then budget={at=now,count=0} self.rates[player]=budget end
 budget.count+=1 if budget.count>15 then if budget.count==16 then self:Error(player,"Muitas solicitações. Aguarde um instante.") end return end
 local valid,reason=Protocol:Validate(command) if not valid then self:Error(player,reason) return end
 self.errors[player]=nil
 local action=command.action
 if (action=="join"or action=="enter")and (workspace:GetAttribute("CrossgroundsBootReady")~=true or player:GetAttribute("ModeCharacterReady")~=true or player:GetAttribute("CrossgroundsTransition"))then
  self:Error(player,"Aguarde o carregamento do lobby e do personagem.")return
 end
 if action=="join" then
  if self.context:GetMode(player)~="hub" then self:Error(player,"Volte ao Crossgrounds antes de escolher outra modalidade.") return end
  local definition=Catalog:Get(command.gameId)
  if not definition or definition.status=="planned" then self:Error(player,"Modalidade em desenvolvimento; não existe fila para ela.") return end
  local ok,item=self.queue:Join(player,command.gameId)
  if not ok then self:Error(player,item) return end
  self:Publish(player)
  task.defer(function()
   local route,message=self:Route(item.gameId)
   if not player.Parent then return end
   if not route then self.queue:Fail(player,message,item.ticket)
   else self.queue:Ready(player,item.ticket,route.kind) end
   self:Publish(player)
  end)
 elseif action=="cancel" then
  local ok,message=self.queue:Cancel(player,command.ticket)
  if not ok then self:Error(player,message) return end
  self:Publish(player)
 elseif action=="dismiss" then
  local state=self.queue:Get(player).state
  if state=="failed" then self.queue:Clear(player) end
  self:Publish(player)
 elseif action=="enter" then
  if self.context:GetMode(player)~="hub" then self:Error(player,"Você já saiu do catálogo.") return end
  local ok,item=self.queue:Consume(player,command.ticket)
  if not ok then self:Error(player,item) return end
  self:Publish(player)
  task.spawn(function()
   local route,message=self:Route(item.gameId)
   if not player.Parent then return end
   if not route then self.queue:Fail(player,message,item.ticket) self:Publish(player) return end
   player:SetAttribute("CrossgroundsTransition",true)
   if route.kind=="local" then
    local entered,err=self:CallAdapter(self.adapters[item.gameId],"Enter",player)
    if not player.Parent then return end
    player:SetAttribute("CrossgroundsTransition",false)
    if entered then self.errors[player]=nil self.queue:Clear(player)
    else
     self:CallAdapter(self.adapters[item.gameId],"Leave",player)
     if not player.Parent then return end
     self.queue:Fail(player,err,item.ticket)
    end
   else
    self.queue:Travelling(player) self:Publish(player)
    local sent,err=self.travel:Begin(player,route,function(failure)
     if not player.Parent then return end
     player:SetAttribute("CrossgroundsTransition",false) self.queue:Fail(player,failure,item.ticket) self:Publish(player)
    end)
    if not sent then player:SetAttribute("CrossgroundsTransition",false) self.queue:Fail(player,err,item.ticket) end
   end
   self:Publish(player)
  end)
 elseif action=="returnHub" then
  local activeMode=self.context:GetMode(player)
  if activeMode=="hub" then self:Error(player,"Você já está no Crossgrounds.") return end
  local adapter=self.adapters[activeMode]
  if player:GetAttribute("CrossgroundsTransition") then self:Error(player,"Aguarde a transição atual; nenhuma saída foi confirmada.") return end
  local route,message=self:Route("hub")
  if not player.Parent then return end
  if player:GetAttribute("CrossgroundsTransition") then self:Error(player,"Aguarde a transição atual.") return end
  if not route then self:Error(player,message) return end
  self.queue:Clear(player) local _,ticket=self.queue:Join(player,"hub") self.queue:Ready(player,ticket.ticket,route.kind) self.queue:Consume(player,ticket.ticket)
  player:SetAttribute("CrossgroundsTransition",true) self:Publish(player)
  task.spawn(function()
   if route.kind=="local" then
    local left,err=self:CallAdapter(adapter,"Leave",player)
    if not player.Parent then return end
    player:SetAttribute("CrossgroundsTransition",false)
    if left then self.errors[player]=nil self.queue:Clear(player) else self.queue:Fail(player,err,ticket.ticket) end
   else
    self.queue:Travelling(player) self:Publish(player)
    local sent,err=self.travel:Begin(player,route,function(failure)
     if not player.Parent then return end
     player:SetAttribute("CrossgroundsTransition",false) self.queue:Fail(player,failure,ticket.ticket) self:Publish(player)
    end)
    if not sent then player:SetAttribute("CrossgroundsTransition",false) self.queue:Fail(player,err,ticket.ticket) end
   end
   self:Publish(player)
  end)
 end
end
function Coordinator:Start()
 if self.started then return end self.started=true
 local function added(player)
  local list={}
  for _,key in {"InMatch","InArena","ModeCharacterReady","CrossgroundsMode"} do table.insert(list,player:GetAttributeChangedSignal(key):Connect(function() self:Publish(player) end)) end
  self.playerConnections[player]=list self:Publish(player)
 end
 table.insert(self.connections,Players.PlayerAdded:Connect(added))
 table.insert(self.connections,Players.PlayerRemoving:Connect(function(player)
  for _,c in self.playerConnections[player] or {} do c:Disconnect() end
  self.playerConnections[player]=nil self.queue:Clear(player) self.travel:Forget(player) self.errors[player]=nil self.rates[player]=nil self.snapshotRates[player]=nil self.revisions[player]=nil
 end))
 table.insert(self.connections,workspace:GetAttributeChangedSignal("RoundState"):Connect(function() for _,p in Players:GetPlayers() do if self.context:IsCTF(p) then self:Publish(p) end end end))
 table.insert(self.connections,self.remotes.Command.OnServerEvent:Connect(function(player,command) self:Command(player,command) end))
 self.remotes.GetState.OnServerInvoke=function(player)
  local now=os.clock() if now-(self.snapshotRates[player] or -10)<.25 then return nil end self.snapshotRates[player]=now return self:Snapshot(player)
 end
 for _,p in Players:GetPlayers() do added(p) end
 workspace:SetAttribute("CrossgroundsCoordinatorStartCount",(workspace:GetAttribute("CrossgroundsCoordinatorStartCount") or 0)+1)
end
return Coordinator

