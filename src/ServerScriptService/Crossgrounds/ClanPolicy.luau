local Career=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
local Catalog=require(game.ReplicatedStorage.Crossgrounds.ClanCatalog)
local C={Keys=Catalog.Keys()}
local function count(members)local n=0 for _ in members do n+=1 end return n end
C.Count=count
function C.Stats(source)
 local result={}for _,key in C.Keys do result[key]=Career.Number(source and source[key])end return result
end
function C.New(data,now)
 return {version=1,id=data.id,code=Catalog.Code(data.id),creator=data.userId,createdAt=now,updatedAt=now,revision=0,metadata={name=data.name,tag=data.tag,emblem=data.emblem,color=data.color},members={[tostring(data.userId)]={userId=data.userId,name=data.displayName,epoch=data.epoch,role="leader",joinedAt=now,career=C.Stats(data.career),contribution={}}},invites={},totals={},archived=false}
end
function C.Validate(record)
 if type(record)~="table"or record.version~=1 or type(record.id)~="string"or type(record.metadata)~="table"or type(record.members)~="table"or type(record.invites)~="table"or type(record.totals)~="table"then return false,"Registro de clã inválido ou de outra versão."end
 local leaders=0
 for key,member in record.members do
  if type(member)~="table"or key~=tostring(member.userId)or type(member.epoch)~="string"or type(member.career)~="table"or type(member.contribution)~="table"or not table.find({"leader","officer","member"},member.role)then return false,"Formação de clã inválida."end
  if member.role=="leader"then leaders+=1 end
 end
 if not record.archived and leaders~=1 or record.archived and count(record.members)~=0 then return false,"Liderança inconsistente."end
 return true
end
function C.CanManage(record,userId)
 local member=record.members[tostring(userId)]return member and(member.role=="leader"or member.role=="officer")
end
function C.Invite(record,actor,target,token,now,expires)
 if record.archived or not C.CanManage(record,actor)then return false,"Sem permissão para convidar."end
 if record.members[tostring(target)]then return false,"Essa pessoa já pertence ao clã."end
 for key,invite in record.invites do if invite.expires<=now then record.invites[key]=nil end end
 if count(record.invites)>=60 and not record.invites[tostring(target)]then return false,"Limite de convites pendentes."end
 record.invites[tostring(target)]={id=token,by=actor,expires=expires}return true
end
function C.Join(record,data,now,capacity)
 if record.archived then return false,"Clã encerrado."end
 local key=tostring(data.userId)local current=record.members[key]
 if current then return current.epoch==data.epoch,current.epoch==data.epoch and nil or"Você já tem outra filiação nesse clã."end
 local invite=record.invites[key]
 if not invite or invite.id~=data.invite or invite.expires<=now then return false,"Convite de clã expirado ou revogado."end
 if count(record.members)>=capacity then return false,"O clã está cheio."end
 record.members[key]={userId=data.userId,name=data.displayName,epoch=data.epoch,role="member",joinedAt=now,career=C.Stats(data.career),contribution={}}
 record.invites[key]=nil return true
end
function C.Remove(record,actor,target,epoch)
 local key=tostring(target)local member=record.members[key]
 if not member then return actor==target,actor~=target and"Integrante não encontrado."or nil end
 if member.epoch~=epoch then return false,"A filiação mudou. Atualize o clã."end
 local caller=record.members[tostring(actor)]
 if actor~=target and(not caller or not C.CanManage(record,actor)or member.role=="leader"or caller.role=="officer"and member.role~="member")then return false,"Sem permissão para remover esse integrante."end
 if actor==target and member.role=="leader"and count(record.members)>1 then return false,"Transfira a liderança antes de sair."end
 record.members[key]=nil
 if count(record.members)==0 then record.archived=true record.invites={}end
 return true
end
function C.Transfer(record,actor,target,epoch)
 local caller=record.members[tostring(actor)]local member=record.members[tostring(target)]
 if not caller or caller.role~="leader"or not member or member==caller or member.epoch~=epoch then return false,"Escolha um integrante atual para liderar."end
 caller.role="officer"member.role="leader"return true
end
function C.Role(record,actor,target,epoch,role)
 local caller=record.members[tostring(actor)]local member=record.members[tostring(target)]
 if not caller or caller.role~="leader"or not member or member.role=="leader"or member.epoch~=epoch or not table.find({"officer","member"},role)then return false,"Alteração de função inválida."end
 member.role=role return true
end
function C.Contribute(record,updates)
 if record.archived then return false,"Clã encerrado."end
 for _,data in updates do
  local member=record.members[tostring(data.userId)]
  if member and member.epoch==data.epoch then
   for _,key in C.Keys do
    local previous=Career.Number(member.contribution[key])local incoming=Career.Number(data.contribution and data.contribution[key])
    if incoming>previous then record.totals[key]=math.min(Career.MaxNumber,Career.Number(record.totals[key])+incoming-previous)member.contribution[key]=incoming end
    member.career[key]=math.max(Career.Number(member.career[key]),Career.Number(data.career and data.career[key]))
   end
  end
 end
 return true
end
function C.Scores(record)
 local current={}
 for _,member in record.members do for _,key in C.Keys do current[key]=math.min(Career.MaxNumber,Career.Number(current[key])+Career.Number(member.career[key]))end end
 return C.Stats(current),C.Stats(record.totals)
end
return C
