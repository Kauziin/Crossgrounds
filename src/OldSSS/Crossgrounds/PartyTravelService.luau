local Service={}Service.__index=Service
local Players=game:GetService("Players")local Http=game:GetService("HttpService")local Run=game:GetService("RunService")
local Repository=require(script.Parent.PartyTransferRepository)
local Party=require(script.Parent.PartyService)
function Service.new(coordinator)
 return setmetatable({c=coordinator,pending={},receiving={}},Service)
end
function Service:Enabled()return self.c.travel.config.GroupTransferEnabled==true and self.c.travel.config.TeleportEnabled==true and not Run:IsStudio()end
function Service:Repo()
 if not self.repo then self.repo=Repository.new(game:GetService("MemoryStoreService"):GetHashMap("CrossgroundsPartyHandoffs_v1"))end return self.repo
end
function Service:Begin(entry,complete)
 if not self:Enabled()then return false,"Viagem coletiva entre Places ainda não foi habilitada."end
 local valid,why=self.c.travel:Verify(entry.route.placeId)if not valid then return false,why end
 local ids={}for _,p in entry.members do if not p.Parent or self.pending[p]then return false,"Um integrante não está disponível para viajar."end table.insert(ids,p.UserId)end
 local token=Http:GenerateGUID(false)
 local ok,record=self:Repo():Create({id=token,groupId=entry.group.id,leader=entry.group.leader,members=ids,sameTeam=entry.group.sameTeam,mode=entry.gameId,placeId=entry.route.placeId,sourceJob=game.JobId})
 if not ok then return false,record end
 local transfer={entry=entry,complete=complete,token=token,done=false}
 for _,p in entry.members do self.pending[p]=transfer end
 local options=Instance.new("TeleportOptions")options:SetTeleportData({crossgroundsPartyTransfer=token})
 local sent=pcall(function()game:GetService("TeleportService"):TeleportAsync(entry.route.placeId,entry.members,options)end)options:Destroy()
 if not sent then self:Finish(transfer,"O Roblox não iniciou a viagem. O grupo permanece no servidor atual.")return true end
 task.delay(35,function()if not transfer.done then self:Finish(transfer,"A viagem não foi concluída para todos. Quem já chegou aguardará no destino; reagrupe no lobby se houver separação.")end end)
 return true
end
function Service:Finish(transfer,message)
 if transfer.done then return end transfer.done=true
 for _,p in transfer.entry.members do if self.pending[p]==transfer then self.pending[p]=nil end end
 transfer.complete(message)
end
function Service:Arrive(player)
 if not self:Enabled()then return end
 local ok,join=pcall(player.GetJoinData,player)local token=ok and type(join.TeleportData)=="table"and join.TeleportData.crossgroundsPartyTransfer
 if type(token)~="string"or #token~=36 then return end
 player:SetAttribute("PartyArrivalPending",true)player:SetAttribute("CrossgroundsTransition",true)
 local accepted,record=self:Repo():Claim(token,player.UserId,game.PlaceId,game.JobId)
 if not accepted then
  player:SetAttribute("PartyArrivalPending",nil)player:SetAttribute("CrossgroundsTransition",false)self.c:Error(player,record)return
 end
 local arrival=self.receiving[token]
 if not arrival then arrival={token=token,record=record,players={},deadline=os.clock()+45}self.receiving[token]=arrival end
 arrival.players[player.UserId]=player
 if arrival.running then return end arrival.running=true
 task.spawn(function()
  local failure,ready
  repeat
   task.wait(.5)
   local latest=self:Repo():Get(token)
   if not latest or latest.closed then failure="A confirmação da viagem expirou."break end
   arrival.record=latest
   ready=Repository.Complete(latest)
   for _,id in latest.members do local p=arrival.players[id]
    if not p or not p.Parent or p:GetAttribute("ModeCharacterReady")~=true or p:GetAttribute("CareerReady")~=true and require(script.Parent.CareerService).Enabled()then ready=false end
   end
  until ready or os.clock()>arrival.deadline
  if not ready then failure=failure or"Nem todos os integrantes chegaram ou carregaram. Nenhuma entrada coletiva foi iniciada."end
  -- Close before admission. If this fails, no session may act on the same handoff twice.
  if not self:Repo():Close(token,game.JobId)then failure="Não foi possível encerrar a confirmação da viagem."end
  local present={}for _,id in arrival.record.members do local p=arrival.players[id]if p and p.Parent then table.insert(present,p)end end
  local ids={}for _,p in present do table.insert(ids,p.UserId)end
  local leader=table.find(ids,arrival.record.leader)and arrival.record.leader or ids[1]
  local restored,group=Party.Roster:Restore({id=arrival.record.groupId,leader=leader,members=ids,sameTeam=arrival.record.sameTeam})
  if not restored then failure=group end
  if not failure then
   local entered,reason=self.c.partyAdmission:Receive(group,present,arrival.record.mode)
   if not entered then failure=reason end
  end
  for _,p in present do p:SetAttribute("PartyArrivalPending",nil)p:SetAttribute("CrossgroundsTransition",false)
   if failure then self.c:Error(p,failure.." Use Social para organizar o grupo e o menu para voltar ao hub.")else self.c.queue:Clear(p)self.c:Publish(p)end
  end
  self.receiving[token]=nil
 end)
end
function Service:Start()
 if not self:Enabled()then return end
 self.failure=game:GetService("TeleportService").TeleportInitFailed:Connect(function(player,_,_,placeId)
  local transfer=self.pending[player]if transfer and transfer.entry.route.placeId==placeId then self:Finish(transfer,"O Roblox recusou a viagem de um integrante. Os participantes que ficaram podem reagrupar; o destino não inicia com o grupo incompleto.")end
 end)
 Players.PlayerAdded:Connect(function(p)task.spawn(function()self:Arrive(p)end)end)
 Players.PlayerRemoving:Connect(function(p)
  local transfer=self.pending[p]self.pending[p]=nil
  if transfer then local any=false for _,other in transfer.entry.members do if other~=p and other.Parent and self.pending[other]==transfer then any=true break end end if not any then self:Finish(transfer)end end
 end)
 for _,p in Players:GetPlayers()do task.spawn(function()self:Arrive(p)end)end
end
return Service
