local Policy=require(script.Parent.ClanPolicy)
local Career=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
local Repo={}Repo.__index=Repo
function Repo.new(store,options)
 options=options or{}return setmetatable({store=store,clock=options.clock or os.time,capacity=options.capacity or function()return 30 end},Repo)
end
function Repo:Get(id)
 local ok,value=pcall(function()return self.store:GetAsync("clan:"..id)end)
 if not ok then return nil,"Clã indisponível. Tente novamente."end
 if value==nil then return nil,"Clã não encontrado."end
 local valid,why=Policy.Validate(value)if not valid then return nil,why end
 return Career.Copy(value)
end
function Repo:Update(id,fn)
 local rejection
 local ok,saved=pcall(function()return self.store:UpdateAsync("clan:"..id,function(previous)
  rejection=nil
  local valid,why=Policy.Validate(previous)if not valid then rejection=why return nil end
  local nextRecord=Career.Copy(previous)local accepted,message=fn(nextRecord,self.clock())
  if not accepted then rejection=message return nil end
  valid,why=Policy.Validate(nextRecord)if not valid then rejection=why return nil end
  nextRecord.revision+=1 nextRecord.updatedAt=self.clock()return nextRecord
 end)end)
 if not ok or rejection or not saved then return false,rejection or"Confirmação do clã pendente. Tente novamente."end
 return true,Career.Copy(saved)
end
function Repo:Create(data)
 local rejection
 local ok,saved=pcall(function()return self.store:UpdateAsync("clan:"..data.id,function(previous)
  rejection=nil
  if previous~=nil then
   local valid,why=Policy.Validate(previous)if not valid then rejection=why return nil end
   local owner=previous.members[tostring(data.userId)]
   if previous.creator==data.userId and owner and owner.epoch==data.epoch and not previous.archived then return previous end
   rejection="Identificador de clã já utilizado."return nil
  end
  local record=Policy.New(data,self.clock())local valid,why=Policy.Validate(record)if not valid then rejection=why return nil end return record
 end)end)
 if not ok or rejection or not saved then return false,rejection or"Criação pendente; a origem foi preservada."end
 return true,Career.Copy(saved)
end
function Repo:Join(id,data)return self:Update(id,function(record,now)return Policy.Join(record,data,now,self.capacity())end)end
function Repo:Contribute(id,updates)return self:Update(id,function(record)return Policy.Contribute(record,updates)end)end
function Repo:Remove(id,actor,target,epoch)return self:Update(id,function(record)return Policy.Remove(record,actor,target,epoch)end)end
function Repo:Abort(id,userId,epoch,operation)
 local rejection
 local ok,saved=pcall(function()return self.store:UpdateAsync("clan:"..id,function(previous)
  rejection=nil
  local record
  if not previous then
   if operation.kind~="create"then rejection="Clã não encontrado."return nil end
   record=Policy.New(operation.data,self.clock())record.members={}record.archived=true
  else
   local valid,why=Policy.Validate(previous)if not valid then rejection=why return nil end record=Career.Copy(previous)
   local member=record.members[tostring(userId)]
   if member then local removed,message=Policy.Remove(record,userId,userId,epoch)if not removed then rejection=message return nil end end
   local invite=record.invites[tostring(userId)]if invite and operation.data and invite.id==operation.data.invite then record.invites[tostring(userId)]=nil end
  end
  record.revision+=1 record.updatedAt=self.clock()return record
 end)end)
 if not ok or rejection or not saved then return false,rejection or"Cancelamento pendente."end return true,saved
end
return Repo
