-- Injected storage/clock: the same transaction path is used in Studio fixtures.
local Policy=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
local Repository={} Repository.__index=Repository
function Repository.new(store,legacy,owner,clock)
 return setmetatable({store=store,legacy=legacy,owner=owner,clock=clock or os.time,leases={},leaseSeconds=180},Repository)
end
local function key(id) return "u"..tostring(id) end
function Repository:Open(id)
 if self.leases[id] then return nil,"Perfil já aberto nesta sessão." end
 local ok,existing=pcall(function() return self.store:GetAsync(key(id)) end)
 if not ok then return nil,"Não foi possível ler o perfil." end
 local origin
 if existing==nil then
  local read,data=pcall(function() return self.legacy:GetAsync(key(id)) end)
  if not read then return nil,"Histórico indisponível; migração cancelada." end
  local migrated,why=Policy.Migrate(data) if not migrated then return nil,why end origin=migrated
 end
 local rejection
 local success,saved=pcall(function()
  return self.store:UpdateAsync(key(id),function(current)
   rejection=nil
   if current~=nil and type(current)~="table" then rejection="Registro inválido." return nil end
   if current and (type(current.profile)~="table" or type(current.sequence)~="number") then rejection="Registro incompleto; origem preservada." return nil end
   local lease=current and current.lease
   if lease and lease.owner~=self.owner and lease.expires>self.clock() then rejection="Perfil ativo em outro servidor." return nil end
   local p,why=Policy.Migrate(current and current.profile or origin)
   if not p then rejection=why return nil end
   return {profile=p,lease={owner=self.owner,expires=self.clock()+self.leaseSeconds},sequence=current and current.sequence or 0}
  end)
 end)
 if not success or rejection or not saved then return nil,rejection or "Não foi possível reservar o perfil." end
 self.leases[id]={sequence=saved.sequence,profile=saved.profile}
 return Policy.Copy(saved.profile)
end
function Repository:Commit(id,profile)
 local session=self.leases[id] if not session then return false,"Perfil sem sessão." end
 local clean,why=Policy.Migrate(profile) if not clean then return false,why end
 -- Callers serialize mutations until Commit confirms. Retain uncertain writes.
 if session.pending then clean=Policy.Copy(session.pending) else session.pending=Policy.Copy(clean) end
 local sequence=session.sequence+1
 clean.revision=sequence
 local rejection
 local ok,saved=pcall(function()
  return self.store:UpdateAsync(key(id),function(current)
   rejection=nil
   if not current or not current.lease or current.lease.owner~=self.owner or current.lease.expires<=self.clock() then rejection="Sessão expirada; escrita recusada." return nil end
   -- Retrying an uncertain write confirms exactly the same sequence.
   if current.sequence==sequence then return current end
   if current.sequence~=session.sequence then rejection="Conflito de revisão." return nil end
   return {profile=clean,sequence=sequence,lease={owner=self.owner,expires=self.clock()+self.leaseSeconds}}
  end)
 end)
 if not ok or rejection or not saved then return false,rejection or "Gravação pendente." end
 session.sequence=saved.sequence session.profile=Policy.Copy(saved.profile) session.pending=nil
 return true,Policy.Copy(saved.profile)
end
function Repository:Renew(id)
 local session=self.leases[id] if not session then return false end
 local accepted=false
 local ok=pcall(function() self.store:UpdateAsync(key(id),function(current)
  accepted=false
  if not current or not current.lease or current.lease.owner~=self.owner or current.lease.expires<=self.clock() then return nil end
  current.lease.expires=self.clock()+self.leaseSeconds accepted=true return current
 end) end)
 return ok and accepted
end
function Repository:Close(id)
 local session=self.leases[id] if not session then return true end
 if session.pending then return false end
 local accepted=false
 local ok=pcall(function() self.store:UpdateAsync(key(id),function(current)
  accepted=false
  if not current or not current.lease or current.lease.owner~=self.owner then return nil end
  current.lease=nil accepted=true return current
 end) end)
 if ok and accepted then self.leases[id]=nil return true end
 return false
end
return Repository
