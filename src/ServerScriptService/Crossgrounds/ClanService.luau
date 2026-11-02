local Service={}
local Players=game:GetService("Players")local Run=game:GetService("RunService")local Http=game:GetService("HttpService")
local Career=require(script.Parent.CareerService)
local P=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
local Catalog=require(game.ReplicatedStorage.Crossgrounds.ClanCatalog)
local Policy=require(script.Parent.ClanPolicy)
local Repository=require(script.Parent.ClanRepository)
local Balance=require(script.Parent.ProgressionBalance)
local cache,pendingIndex,labelCache,rates,busy={},{},{},{},{}
local rankCache,outbox={},{}
local event,repo,ordered
local function memory()
 local data={}return {GetAsync=function(_,key)return P.Copy(data[key])end,UpdateAsync=function(_,key,fn)local value=fn(P.Copy(data[key]))if value then data[key]=P.Copy(value)end return P.Copy(value)end}
end
local function repository()
 if not repo then
  local dss=game:GetService("DataStoreService")
  repo=Repository.new(Run:IsStudio()and memory()or dss:GetDataStore("CrossgroundsClans_v1"),{capacity=function()return math.clamp(Balance.Get("ClanMaxMembers"),2,100)end})
  if not Run:IsStudio()then ordered={roster=dss:GetOrderedDataStore("CG_ClanRosterXP_v1"),earned=dss:GetOrderedDataStore("CG_ClanEarnedXP_v1")}end
 end return repo
end
local function remember(record)
 local previous=cache[record.id]
 cache[record.id]={data=record,at=os.clock()}
 if not previous or previous.data.revision~=record.revision then pendingIndex[record.id]=record rankCache={}end
 return record
end
local function get(id,fresh)
 local item=cache[id]if not fresh and item and os.clock()-item.at<5 then return item.data end
 local record,why=repository():Get(id)if record then return remember(record)end return nil,why
end
local function filter(value,author)
 return game:GetService("TextService"):FilterStringAsync(value,author,Enum.TextFilterContext.PublicChat):GetNonChatStringForBroadcastAsync()
end
local function label(record)
 local key=record.id local item=labelCache[key]
 if item and os.clock()-item.at<120 then return item.name,item.tag end
 local ok,name,tag=pcall(function()return filter(record.metadata.name,record.creator),filter(record.metadata.tag,record.creator)end)
 if not ok then return "Clã "..record.code,record.code end
 labelCache[key]={name=name,tag=tag,at=os.clock()}return name,tag
end
local function notify(record,extra)
 if not event then return end
 local ids={}for _,member in record.members do ids[member.userId]=true end if extra then ids[extra]=true end
 for id in ids do local p=Players:GetPlayerByUserId(id)if p then event:FireClient(p)end end
end
local function validId(id)return type(id)=="string"and #id==36 and id:match("^[%x%-]+$")~=nil end
local function account(player)return Career.Get(player)end
local function currentRef(player)local p=account(player)return p and p.clan end
local function lobby(player)return player.Parent==Players and player:GetAttribute("CrossgroundsMode")=="hub"and not player:GetAttribute("CrossgroundsTransition")end
local function clearRef(player,id,epoch)
 return Career.Mutate(player,function(p)
  if not p.clan or p.clan.id~=id or p.clan.epoch~=epoch then return false,"A filiação mudou."end
  p.clan=nil return true
 end)
end
local function grant(player,record)
 local member=record.members[tostring(player.UserId)]local p=account(player)
 if not member or not p or not p.clan or p.clan.epoch~=member.epoch or Catalog.Level(record.totals.XP or 0)<3 or(member.contribution.XP or 0)<1000 or p.cosmetics.cards.clan then return end
 Career.Mutate(player,function(nextProfile)
  if not nextProfile.clan or nextProfile.clan.epoch~=member.epoch then return false end
  nextProfile.cosmetics.cards.clan=true nextProfile.cosmetics.frames.clan=true nextProfile.cosmetics.titles.clan=true return true
 end)
end
function Service.View(record,player)
 local name,tag=label(record)local current,earned=Policy.Scores(record)
 local rows={}
 for _,member in record.members do table.insert(rows,{userId=member.userId,name=member.name,role=member.role,epoch=member.epoch,contributionXP=member.contribution.XP or 0})end
 table.sort(rows,function(a,b)if a.role~=b.role then local rank={leader=1,officer=2,member=3}return rank[a.role]<rank[b.role]end return a.userId<b.userId end)
 local own=player and record.members[tostring(player.UserId)]local invite=player and record.invites[tostring(player.UserId)]
 return {id=record.id,code=record.code,name=name,tag=tag,emblem=record.metadata.emblem,color=record.metadata.color,level=Catalog.Level(earned.XP),xp=earned.XP,current=current,earned=earned,members=rows,capacity=math.clamp(Balance.Get("ClanMaxMembers"),2,100),role=own and own.role,epoch=own and own.epoch,invite=invite and invite.expires>os.time()and{id=invite.id,expires=invite.expires}or nil,archived=record.archived,updatedAt=record.updatedAt}
end
function Service.Reconcile(player)
 local profile=account(player)local ref=profile and profile.clan
 if not ref then return true end
 if ref.state=="joining"then
  local ok,saved=Career.Flush(player)if not ok then return false,"Confirmação do perfil pendente."end
  ref=saved.clan if not ref then return true end
  if ref.state=="active"then return true end
  local op=ref.operation
  if type(op)~="table"or type(op.data)~="table"then return false,"Filiação pendente inválida."end
  local accepted,record
  if op.kind=="create"then accepted,record=repository():Create(op.data)
  elseif op.kind=="join"then accepted,record=repository():Join(ref.id,op.data)
  else return false,"Operação de filiação desconhecida."end
  if not accepted then return false,record end
  remember(record)
  local committed,message=Career.Mutate(player,function(p)
   if not p.clan or p.clan.epoch~=ref.epoch then return false,"A filiação mudou."end
   p.clan.state="active"p.clan.operation=nil
   p.clan.code=record.code p.clan.emblem=record.metadata.emblem p.clan.color=record.metadata.color
   if p.clanInvites then p.clanInvites[ref.id]=nil end return true
  end)
  notify(record,player.UserId)return committed,message
 end
 local record,why=get(ref.id,true)
 if not record then return false,why end
 local member=record.members[tostring(player.UserId)]
 if not member or member.epoch~=ref.epoch then return clearRef(player,ref.id,ref.epoch)end
 grant(player,record)return true
end
function Service.Snapshot(player)
 local p=account(player)if not p then return nil,"Aguarde o perfil de carreira."end
 local result={sessionOnly=Run:IsStudio(),invites={}}
 if p.clan then
  result.pending=p.clan.state=="joining"
  local record,why=get(p.clan.id)
  if record then result.clan=Service.View(record,player)
  elseif p.clan.state=="active"then return nil,why or"Clã temporariamente indisponível."end
 end
 for id,ref in p.clanInvites or{}do
  local record=get(id)
  local invite=record and record.invites[tostring(player.UserId)]
  if invite and invite.id==ref.token and invite.expires>os.time()then local name,tag=label(record)table.insert(result.invites,{clanId=id,token=invite.id,name=name,tag=tag})end
 end
 return result
end
function Service.Create(player,payload)
 local p=account(player)if not p or p.clan then return false,"Você já possui uma filiação ou confirmação pendente."end
 if type(payload)~="table"or type(payload.name)~="string"or type(payload.tag)~="string"or #payload.name>160 or #payload.tag>5 or not Catalog.Emblems[payload.emblem]or not Catalog.Colors[payload.color]then return false,"Nome, tag ou brasão inválido."end
 local name=payload.name:match("^%s*(.-)%s*$")local tag=payload.tag:upper()
 if not utf8.len(name)or utf8.len(name)<3 or utf8.len(name)>40 or name:find("%c")or #tag<2 or #tag>5 or not tag:match("^[A-Z0-9]+$")then return false,"Nome: 3–40 caracteres. Tag: 2–5 letras ou números."end
 local ok,filteredName,filteredTag=pcall(function()return filter(name,player.UserId),filter(tag,player.UserId)end)
 if not ok then return false,"Não foi possível validar o nome. Tente novamente."end
 if filteredName:find("#",1,true)or filteredTag:find("#",1,true)then return false,"Escolha outro nome ou tag."end
 local data={id=Http:GenerateGUID(false),epoch=Http:GenerateGUID(false),userId=player.UserId,displayName=player.DisplayName,name=name,tag=tag,emblem=payload.emblem,color=payload.color,career=p.stats}
 local confirmed,message=Career.Mutate(player,function(nextProfile)
  if nextProfile.clan then return false,"Você já possui uma filiação."end
  nextProfile.clan={id=data.id,epoch=data.epoch,state="joining",contribution={},operation={kind="create",data=P.Copy(data)}}return true
 end)
 if not confirmed then return false,message end
 return Service.Reconcile(player)
end
function Service.Accept(player,payload)
 local p=account(player)
 if not p or p.clan or type(payload)~="table"or not validId(payload.clanId)or type(payload.token)~="string"then return false,"Convite ou perfil indisponível."end
 local record,why=get(payload.clanId,true)if not record then return false,why end
 local invite=record.invites[tostring(player.UserId)]if not invite or invite.id~=payload.token or invite.expires<=os.time()then return false,"Convite expirado."end
 local data={userId=player.UserId,epoch=Http:GenerateGUID(false),displayName=player.DisplayName,invite=payload.token,career=p.stats}
 local ok,message=Career.Mutate(player,function(nextProfile)
  if nextProfile.clan then return false,"Você já está em um clã."end
  nextProfile.clan={id=record.id,epoch=data.epoch,state="joining",contribution={},operation={kind="join",data=P.Copy(data)}}return true
 end)
 if not ok then return false,message end return Service.Reconcile(player)
end
function Service.Invite(player,targetId)
 local ref=currentRef(player)local target=type(targetId)=="number"and Players:GetPlayerByUserId(targetId)
 if not ref or ref.state~="active"or not target or not lobby(target)then return false,"Convide uma pessoa presente no lobby."end
 local targetProfile=account(target)if not targetProfile or targetProfile.clan then return false,"Essa pessoa já possui filiação ou está carregando."end
 local allowed,reason=require(script.Parent.SocialDirectory).InviteAllowed(target)if not allowed then return false,reason end
 local ok,friends=pcall(function()return player:IsFriendsWithAsync(target.UserId)end)if not ok or not friends then return false,"Convide um amigo do Roblox."end
 local token=Http:GenerateGUID(false)local expires=os.time()+math.clamp(Balance.Get("ClanInviteSeconds"),30,86400)
 local accepted,record=repository():Update(ref.id,function(clan,now)return Policy.Invite(clan,player.UserId,targetId,token,now,expires)end)
 if not accepted then return false,record end remember(record)
 Career.Stage(target,function(p)
  p.clanInvites=p.clanInvites or{}local entries={}for id,value in p.clanInvites do if value.expires<=os.time()then p.clanInvites[id]=nil else table.insert(entries,{id=id,expires=value.expires})end end
  table.sort(entries,function(a,b)return a.expires<b.expires end)if #entries>=10 then p.clanInvites[entries[1].id]=nil end
  p.clanInvites[ref.id]={token=token,expires=expires}return true
 end)
 notify(record,target.UserId)return true,"Convite de clã enviado."
end
function Service.CancelPending(player)
 local ok,saved=Career.Flush(player)if not ok then return false,"Aguarde a confirmação do perfil."end
 local ref=saved.clan
 if not ref or ref.state~="joining"or type(ref.operation)~="table"then return false,"Nenhuma filiação pendente."end
 local removed,record=repository():Abort(ref.id,player.UserId,ref.epoch,ref.operation)
 if not removed then return false,record end remember(record)
 local cleared,message=clearRef(player,ref.id,ref.epoch)notify(record,player.UserId)return cleared,message
end
local function flushMember(player)
 local ok,saved=Career.Flush(player)if not ok then return false,"Confirme o perfil antes de sair."end
 local ref=saved.clan if not ref or ref.state~="active"then return false,"Filiação indisponível."end
 local accepted,record=repository():Contribute(ref.id,{{userId=player.UserId,epoch=ref.epoch,contribution=ref.contribution,career=saved.stats}})
 if not accepted then return false,record end remember(record)return true,record,ref
end
function Service.Leave(player)
 local ok,record,ref=flushMember(player)if not ok then return false,record end
 local removed,value=repository():Remove(ref.id,player.UserId,player.UserId,ref.epoch)if not removed then return false,value end remember(value)
 local cleared,message=clearRef(player,ref.id,ref.epoch)notify(value,player.UserId)return cleared,message
end
function Service.Manage(player,action,payload)
 local ref=currentRef(player)
 if not ref or ref.state~="active"or type(payload)~="table"or type(payload.userId)~="number"or type(payload.epoch)~="string"then return false,"Integrante inválido."end
 if payload.userId==player.UserId then return false,"Use a opção Sair do clã."end
 -- Flush a local member's confirmed stream before administrative removal.
 -- Other servers reconcile only the snapshots already confirmed in the clan.
 if action=="kick"then
  local target=Players:GetPlayerByUserId(payload.userId)local targetRef=target and currentRef(target)
  if targetRef and targetRef.id==ref.id and targetRef.epoch==payload.epoch then
   local flushed,why=flushMember(target)if not flushed then return false,why end
  end
 end
 local ok,record=repository():Update(ref.id,function(clan)
  if action=="kick"then return Policy.Remove(clan,player.UserId,payload.userId,payload.epoch)end
  if action=="leader"then return Policy.Transfer(clan,player.UserId,payload.userId,payload.epoch)end
  return Policy.Role(clan,player.UserId,payload.userId,payload.epoch,payload.role)
 end)
 if not ok then return false,record end remember(record)
 if action=="kick"then local target=Players:GetPlayerByUserId(payload.userId)if target then clearRef(target,ref.id,payload.epoch)end end
 notify(record,payload.userId)return true,"Clã atualizado."
end
function Service.Leaderboard(scope)
 if scope~="roster"and scope~="earned"then return false,"Ranking inválido."end
 local known=rankCache[scope]if known and os.clock()-known.at<60 then return true,P.Copy(known.value)end
 repository()local records={}
 if ordered then
  local ok,pages=pcall(function()return ordered[scope]:GetSortedAsync(false,20,0)end)
  if not ok then return false,"Ranking indisponível. Tente novamente."end
  for _,entry in pages:GetCurrentPage()do local record=get(entry.key)if record and not record.archived then table.insert(records,record)end end
 else for _,item in cache do if not item.data.archived then table.insert(records,item.data)end end end
 local rows={}
 for _,record in records do local current,earned=Policy.Scores(record)local name,tag=label(record)
  table.insert(rows,{id=record.id,name=name,tag=tag,score=(scope=="roster"and current or earned).XP,members=Policy.Count(record.members),level=Catalog.Level(earned.XP)})
 end
 table.sort(rows,function(a,b)return a.score==b.score and a.id<b.id or a.score>b.score end)
 for i=#rows,21,-1 do table.remove(rows,i)end for i,row in rows do row.rank=i end
 local result={scope=scope,rows=rows,sessionOnly=Run:IsStudio(),at=os.time(),label=scope=="roster"and"Histórico do elenco atual"or"Conquistas do clã",message="Top consultado · atualização periódica · somas representam dedicação coletiva."}
 rankCache[scope]={at=os.clock(),value=result}return true,P.Copy(result)
end
function Service.Command(player,action,payload)
 if action=="get"then local result,why=Service.Snapshot(player)return result~=nil,result or why end
 if action=="leaderboard"then return Service.Leaderboard(payload)end
 if action=="view"and validId(payload)then local record,why=get(payload)return record~=nil,record and Service.View(record,player)or why end
 if not lobby(player)then return false,"Volte ao lobby para gerenciar o clã."end
 if action=="create"then return Service.Create(player,payload)end
 if action=="accept"then return Service.Accept(player,payload)end
 if action=="invite"then return Service.Invite(player,payload)end
 if action=="leave"then return Service.Leave(player)end
 if action=="cancelPending"then return Service.CancelPending(player)end
 if action=="kick"or action=="leader"or action=="role"then return Service.Manage(player,action,payload)end
 if action=="decline"and type(payload)=="table"and validId(payload.clanId)and type(payload.token)=="string"then
  local ok,record=repository():Update(payload.clanId,function(clan)
   local invite=clan.invites[tostring(player.UserId)]if not invite or invite.id~=payload.token then return false,"Convite expirado ou substituído."end
   clan.invites[tostring(player.UserId)]=nil return true
  end)
  if not ok then return false,record end remember(record)
  Career.Stage(player,function(p)if p.clanInvites then p.clanInvites[payload.clanId]=nil end return true end)
  if event then event:FireClient(player)end return true,"Convite recusado."
 end
 if action=="reconcile"then return Service.Reconcile(player)end
 return false,"Ação de clã inválida."
end
local function contribute(player,mode,baseAmounts,_,_,training,eligible,context)
 if training or not eligible or not context then return end
 Career.Stage(player,function(p)
  local ref=p.clan if not ref or ref.state~="active"or ref.id~=context.clanId or ref.epoch~=context.epoch then return false end
  for _,key in Catalog.Fields do
   local amount=P.Number(baseAmounts[key])
   if amount>0 then ref.contribution[key]=math.min(P.MaxNumber,(ref.contribution[key]or 0)+amount)
    if table.find(Catalog.Modes,mode)then local k=mode.."_"..key ref.contribution[k]=math.min(P.MaxNumber,(ref.contribution[k]or 0)+amount)end
   end
  end return true
 end)
end
local function cycle()
 local batches={}
 for _,player in Players:GetPlayers()do
  if not busy[player]then
   local ref=currentRef(player)
   if ref and ref.state=="joining"then Service.Reconcile(player)
   elseif ref then
    local ok,saved=Career.Flush(player)
    if ok and saved.clan and saved.clan.state=="active"then local claim=saved.clan
     batches[claim.id]=batches[claim.id]or{}table.insert(batches[claim.id],{userId=player.UserId,epoch=claim.epoch,contribution=claim.contribution,career=saved.stats,revision=saved.revision})
    end
   end
  end
 end
 for id,updates in outbox do
  batches[id]=batches[id]or{}
  local already={}for _,data in batches[id]do already[data.userId]=true end
  for userId,data in updates do if not already[userId]then table.insert(batches[id],data)end end
 end
 for id,updates in batches do
  local ok,record=repository():Contribute(id,updates)
  if ok then
   remember(record)
   local pending=outbox[id]
   if pending then for _,data in updates do
    local queued=pending[data.userId]
    if queued and queued.epoch==data.epoch and queued.revision<=data.revision then pending[data.userId]=nil end
   end if not next(pending)then outbox[id]=nil end end
   for _,data in updates do local player=Players:GetPlayerByUserId(data.userId)local member=record.members[tostring(data.userId)]
    if player then if not member or member.epoch~=data.epoch then clearRef(player,id,data.epoch)else grant(player,record)end end
   end
   notify(record)
  end
 end
 repository()
 if ordered then
  for id,record in pendingIndex do
   local current,earned=Policy.Scores(record)
   local ok=pcall(function()
    if record.archived then ordered.roster:RemoveAsync(id)ordered.earned:RemoveAsync(id)
    else ordered.roster:SetAsync(id,current.XP)ordered.earned:SetAsync(id,earned.XP)end
   end)
   if ok then pendingIndex[id]=nil rankCache={}end
  end
 else pendingIndex={}rankCache={}end
end
function Service.Start()
 if Service.started then return end Service.started=true
 local remotes=game.ReplicatedStorage.Crossgrounds:WaitForChild("Remotes")
 event=remotes:FindFirstChild("ClanState")or Instance.new("RemoteEvent")event.Name="ClanState"event.Parent=remotes
 local remote=remotes:FindFirstChild("ClanCommand")or Instance.new("RemoteFunction")remote.Name="ClanCommand"remote.Parent=remotes
 remote.OnServerInvoke=function(player,action,payload)
  if type(action)~="string"then return false,"Ação inválida."end
  local budget=rates[player]or{}rates[player]=budget local read=action=="get"or action=="view"or action=="leaderboard"local key=read and"read"or"write"local now=os.clock()
  if now-(budget[key]or-10)<(read and .5 or 1)then return false,"Aguarde um instante."end budget[key]=now
  if busy[player]then return false,"Confirmação de clã em andamento."end
  busy[player]=true local ok,accepted,value=pcall(Service.Command,player,action,payload)busy[player]=nil
  if not ok then warn("Clan command: "..tostring(accepted))return false,"Não foi possível concluir a operação de clã."end
  return accepted,value or(accepted and"Clã atualizado."or"Operação indisponível.")
 end
 require(script.Parent.ProgressionService).Awarded:Connect(contribute)
 Career.Committed:Connect(function(player,saved)
  local ref=saved.clan if not ref or ref.state~="active"then return end
  outbox[ref.id]=outbox[ref.id]or{}
  local previous=outbox[ref.id][player.UserId]
  if not previous or previous.revision<saved.revision then outbox[ref.id][player.UserId]={userId=player.UserId,epoch=ref.epoch,contribution=P.Copy(ref.contribution),career=P.Copy(saved.stats),revision=saved.revision}end
 end)
 Players.PlayerRemoving:Connect(function(player)rates[player]=nil busy[player]=nil end)
 task.spawn(function()while true do task.wait(30)local ok,err=pcall(cycle)if not ok then warn("Clan reconciliation: "..tostring(err))end end end)
 game:BindToClose(function()
  local deadline=os.clock()+18
  repeat task.wait(.5)local ok,err=pcall(cycle)if not ok then warn("Clan close: "..tostring(err))end until not next(outbox)or os.clock()>deadline
 end)
end
return Service
