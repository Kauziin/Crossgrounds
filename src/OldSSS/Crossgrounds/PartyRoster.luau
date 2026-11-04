-- Ephemeral membership policy. Does not grant XP or trust client-supplied rosters.
local Roster={} Roster.__index=Roster
function Roster.new(options)
 options=options or {}
 return setmetatable({groups={},membership={},invites={},clock=options.clock or os.clock,id=assert(options.id),maxMembers=options.maxMembers or 12,inviteSeconds=options.inviteSeconds or function() return 60 end,changed=options.changed or function() end},Roster)
end
function Roster:Get(userId) return self.groups[self.membership[userId]] end
-- Only the verified server handoff may call this; never exposed as a client command.
function Roster:Restore(data)
 if type(data)~="table"or type(data.id)~="string"or self.groups[data.id]or type(data.members)~="table"or #data.members<1 or #data.members>self.maxMembers or type(data.sameTeam)~="boolean"then return false,"Não foi possível restaurar o grupo."end
 local seen={}for _,id in data.members do if type(id)~="number"or seen[id]or self:Get(id)then return false,"Um integrante já está em outro grupo."end seen[id]=true end
 if not seen[data.leader]then return false,"Líder ausente na formação."end
 local group={id=data.id,leader=data.leader,members=table.clone(data.members),sameTeam=data.sameTeam,revision=1}
 self.groups[group.id]=group for _,id in group.members do self.membership[id]=group.id end self.changed(group.members)return true,group
end
function Roster:Touch(group,extra)
 group.revision+=1
 local ids=table.clone(group.members) if extra and not table.find(ids,extra) then table.insert(ids,extra) end
 self.changed(ids)
end
function Roster:Create(userId)
 if self:Get(userId) then return false,"Você já participa de um grupo." end
 local id=self.id()
 local group={id=id,leader=userId,members={userId},sameTeam=true,revision=1}
 self.groups[id]=group self.membership[userId]=id self.changed({userId}) return true,group
end
function Roster:Invite(actor,target)
 local group=self:Get(actor)
 if not group or group.leader~=actor then return false,"Somente o líder pode convidar." end
 if group.lock then return false,"Cancele a entrada antes de alterar o grupo." end
 if self:Get(target) then return false,"Essa pessoa já está em um grupo." end
 if #group.members>=self.maxMembers then return false,"O grupo está cheio." end
 self.invites[target]={id=self.id(),groupId=group.id,actor=actor,expires=self.clock()+self.inviteSeconds()}
 self.changed({target}) return true
end
function Roster:Accept(userId,invitationId)
 local invite=self.invites[userId]
 if not invite or invite.id~=invitationId or invite.expires<=self.clock() then return false,"Convite expirado ou substituído." end
 local group=self.groups[invite.groupId]
 if not group or group.leader~=invite.actor then return false,"O grupo mudou de liderança." end
 if group.lock then return false,"O grupo está entrando em uma partida." end
 if self:Get(userId) then return false,"Saia do seu grupo primeiro." end
 if #group.members>=self.maxMembers then return false,"O grupo ficou cheio." end
 self.invites[userId]=nil self.membership[userId]=group.id table.insert(group.members,userId) self:Touch(group) return true
end
function Roster:Decline(userId,invitationId)
 local invite=self.invites[userId]
 if not invite or invite.id~=invitationId then return false,"Convite não encontrado." end
 self.invites[userId]=nil self.changed({userId}) return true
end
function Roster:Remove(actor,target,force)
 local group=self:Get(target)
 if not group or (actor~=target and actor~=group.leader) then return false,"Sem permissão para remover essa pessoa." end
 if group.lock and not force then return false,"Cancele a entrada antes de sair ou remover alguém." end
 self.membership[target]=nil
 local i=table.find(group.members,target) if i then table.remove(group.members,i) end
 if #group.members==0 then self.groups[group.id]=nil
 elseif group.leader==target then group.leader=group.members[1] end
 self:Touch(group,target)
 return true
end
function Roster:SetLeader(actor,target)
 local group=self:Get(actor)
 if not group or group.leader~=actor or not table.find(group.members,target) then return false,"Escolha um integrante do seu grupo." end
 if group.lock then return false,"Cancele a entrada antes de mudar a liderança." end
 group.leader=target self:Touch(group) return true
end
function Roster:SetTeamPolicy(actor,sameTeam)
 local group=self:Get(actor)
 if not group or group.leader~=actor or type(sameTeam)~="boolean" then return false,"Somente o líder escolhe a política de equipes." end
 if group.lock then return false,"Cancele a entrada antes de mudar a opção." end
 group.sameTeam=sameTeam self:Touch(group) return true
end
function Roster:SetLock(group,token)
 if self.groups[group.id]~=group then return false end
 if token and group.lock then return false end
 group.lock=token self:Touch(group) return true
end
function Roster:Snapshot(userId)
 local group=self:Get(userId) local data={}
 if group then data.group={id=group.id,leader=group.leader,members=table.clone(group.members),sameTeam=group.sameTeam,revision=group.revision,locked=group.lock~=nil} end
 local invite=self.invites[userId]
 if invite and invite.expires>self.clock() and self.groups[invite.groupId] then data.invite={id=invite.id,leader=invite.actor,expiresIn=math.max(0,math.ceil(invite.expires-self.clock()))} end
 return data
end
function Roster:Forget(userId)
 self.invites[userId]=nil
 if self:Get(userId) then return self:Remove(userId,userId,true) end
 return true
end
function Roster:Expire()
 local expired={}
 for id,invite in self.invites do if invite.expires<=self.clock() or not self.groups[invite.groupId] then self.invites[id]=nil table.insert(expired,id) end end
 if #expired>0 then self.changed(expired) end
end
return Roster
