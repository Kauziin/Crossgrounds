-- Short-lived, server-authored handoffs. TeleportData contains only the opaque key.
local P=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
local Repository={}Repository.__index=Repository
function Repository.new(map,clock)return setmetatable({map=map,clock=clock or os.time},Repository)end
function Repository.Validate(r)
 if type(r)~="table"or r.version~=1 or type(r.members)~="table"or #r.members<1 or #r.members>12 or type(r.leader)~="number"or type(r.sameTeam)~="boolean"or not table.find({"ctf","arena"},r.mode)or type(r.placeId)~="number"or type(r.expires)~="number"or type(r.id)~="string"or type(r.groupId)~="string"or type(r.sourceJob)~="string"or type(r.arrivals)~="table"then return false end
 local seen={}for _,id in r.members do if type(id)~="number"or id%1~=0 or id<=0 or seen[id]then return false end seen[id]=true end
 return seen[r.leader]==true and #r.members<=(r.mode=="ctf"and r.sameTeam and 6 or 12)
end
function Repository:Create(data)
 local r=P.Copy(data)r.version=1 r.expires=self.clock()+120 r.arrivals={}r.targetJob=nil r.closed=false
 if not Repository.Validate(r)then return false,"Formação de viagem inválida."end
 local collision=false
 local ok,saved=pcall(function()return self.map:UpdateAsync(r.id,function(previous)
  collision=false
  if previous then if Repository.Validate(previous)and previous.groupId==r.groupId and previous.sourceJob==r.sourceJob then return previous end collision=true return nil end
  return r
 end,150)end)
 if not ok or collision or not saved then return false,"Não foi possível reservar a viagem do grupo."end
 return true,P.Copy(saved)
end
function Repository:Claim(token,userId,placeId,jobId)
 local reason
 local ok,saved=pcall(function()return self.map:UpdateAsync(token,function(previous)
  reason=nil
  if not Repository.Validate(previous)or previous.closed or previous.expires<=self.clock()then reason="Viagem expirada ou encerrada."return nil end
  if previous.placeId~=placeId or not table.find(previous.members,userId)then reason="Viagem não pertence a este jogador ou Place."return nil end
  if previous.targetJob and previous.targetJob~=jobId then reason="O Roblox separou a chegada do grupo. Volte ao lobby de origem para reagrupar."return nil end
  local r=P.Copy(previous)r.targetJob=jobId r.arrivals[tostring(userId)]=true return r
 end,150)end)
 if not ok or reason or not saved then return false,reason or"Não foi possível confirmar a chegada. Tente novamente no lobby."end
 return true,P.Copy(saved)
end
function Repository:Get(token)
 local ok,r=pcall(function()return self.map:GetAsync(token)end)
 if not ok or not Repository.Validate(r)then return nil end return P.Copy(r)
end
function Repository:Close(token,jobId)
 local accepted=false
 local ok=pcall(function()self.map:UpdateAsync(token,function(previous)
  accepted=false if not Repository.Validate(previous)or previous.targetJob~=jobId then return nil end
  local r=P.Copy(previous)r.closed=true accepted=true return r
 end,150)end)return ok and accepted
end
function Repository.Complete(record)
 for _,id in record.members do if not record.arrivals[tostring(id)]then return false end end return true
end
return Repository
