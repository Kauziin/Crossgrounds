-- Versioned persistence contract. Changing these thresholds requires a migration.
-- Live reward tuning belongs to ProgressionBalance, never to saved level thresholds.
local P={Version=2,CurveVersion=1,MaxLevel=55,MaxPrestige=10,MasteryMax=1000}
P.Modes={"arena","ctf","get_out","duels"}
P.MaxNumber=2^50
function P.Number(value)
 return type(value)=="number" and value==value and value>=0 and value<math.huge and math.min(P.MaxNumber,math.floor(value)) or 0
end
function P.Threshold(level)
 local n=math.clamp(P.Number(level)-1,0,54)
 return 800*n+105*n*(n-1)
end
P.CycleCost=P.Threshold(55)
function P.Level(xp,phase)
 xp=P.Number(xp)
 if phase=="legend" then return math.floor(xp/12000)+1 end
 if phase=="mastery" and xp>=P.CycleCost then return math.min(1000,55+math.floor((xp-P.CycleCost)/12000)) end
 local low,high=1,55
 while low<high do local mid=math.ceil((low+high)/2) if P.Threshold(mid)<=xp then low=mid else high=mid-1 end end
 return low
end
function P.Cap(phase)
 if phase=="legend" then return P.MaxNumber end
 return phase=="mastery" and P.CycleCost+945*12000 or P.CycleCost
end
function P.Progress(xp,phase)
 local level=P.Level(xp,phase)
 local current,nextXP
 if phase=="legend" then current=(level-1)*12000 nextXP=current+12000
 elseif phase=="mastery" and level>=55 then current=P.CycleCost+(level-55)*12000 nextXP=level<1000 and current+12000 or current
 else current=P.Threshold(level) nextXP=level<55 and P.Threshold(level+1) or current end
 return level,current,nextXP
end
local function copy(value)
 if type(value)~="table" then return value end
 local result={} for k,v in value do result[k]=copy(v) end return result
end
P.Copy=copy
function P.New()
 local p={schemaVersion=2,curveVersion=1,revision=0,lifetimeXP=0,phase="normal",prestige=0,cycleXP=0,stats={},weapons={},tokens={},permanent={},cosmetics={cards={default=true},frames={default=true},titles={default=true},emblems={default=true}},identity={card="default",frame="default",title="default",emblem="default"},transitions=0}
 for _,mode in P.Modes do p.tokens[mode]=0 p.permanent[mode]={} end
 p.social={favorites={},invites="friends",publicStats=true}
 p.clanInvites={} p.weaponFinishes={}p.rankStyle="classic"
 return p
end
function P.Transition(p)
 if p.phase=="legend" or p.cycleXP<P.Cap(p.phase) then return false,"Alcance o limite da etapa." end
 if p.phase=="mastery" then p.phase="legend"
 elseif p.prestige<10 then p.prestige+=1
 else p.phase="mastery" end
 p.cycleXP=0 p.transitions+=1
 for _,mode in P.Modes do p.tokens[mode]+=1 end
 -- Unlocks are derived from cycle level. Legend retains completed account unlocks.
 p.accountUnlocked=p.phase=="legend"
 return true
end
function P.Migrate(old)
 if old==nil then return P.New() end
 if type(old)~="table" then return nil,"Perfil inválido; origem preservada." end
 if old.schemaVersion~=nil then
  if old.schemaVersion~=2 or old.curveVersion~=1 then return nil,"Versão de perfil incompatível." end
  if not table.find({"normal","mastery","legend"},old.phase) or type(old.stats)~="table" or type(old.weapons)~="table" or type(old.tokens)~="table" or type(old.permanent)~="table" or type(old.cosmetics)~="table" or type(old.identity)~="table" then return nil,"Estrutura de perfil inválida." end
  for _,mode in P.Modes do if type(old.tokens[mode])~="number" or type(old.permanent[mode])~="table" then return nil,"Inventário incompleto." end end
  for _,key in {"revision","lifetimeXP","prestige","cycleXP","transitions"} do if type(old[key])~="number" or old[key]~=P.Number(old[key]) then return nil,"Progresso inválido." end end
  if old.prestige>10 or old.cycleXP>P.Cap(old.phase) then return nil,"Etapa inválida." end
  local transitions=old.phase=="legend" and 12 or old.phase=="mastery" and 11 or old.prestige
  if old.transitions~=transitions or old.phase~="normal" and old.prestige~=10 or old.accountUnlocked==true and old.phase~="legend" then return nil,"Transições inconsistentes." end
  for _,mode in P.Modes do if old.tokens[mode]~=P.Number(old.tokens[mode]) or old.tokens[mode]>transitions then return nil,"Saldo de token inválido." end end
  for _,category in {"cards","frames","titles","emblems"} do if type(old.cosmetics[category])~="table" then return nil,"Coleção incompleta." end end
  for _,slot in {"card","frame","title","emblem"} do if type(old.identity[slot])~="string" or #old.identity[slot]>80 then return nil,"Identidade inválida." end end
  if old.social~=nil and (type(old.social)~="table" or type(old.social.favorites)~="table" or not table.find({"friends","none"},old.social.invites) or type(old.social.publicStats)~="boolean") then return nil,"Preferências sociais inválidas." end
  if old.clan~=nil and(type(old.clan)~="table"or type(old.clan.id)~="string"or type(old.clan.epoch)~="string"or type(old.clan.contribution)~="table"or not table.find({"joining","active"},old.clan.state))then return nil,"Filiação inválida."end
  if old.clanInvites~=nil and type(old.clanInvites)~="table"then return nil,"Caixa de convites inválida."end
  if old.weaponFinishes~=nil and type(old.weaponFinishes)~="table"then return nil,"Acabamentos inválidos."end
  if old.frameLayers~=nil and not require(script.Parent.ProfileFramePolicy).Validate(old.frameLayers,old.cosmetics.frames)then return nil,"Camadas de moldura inválidas."end
  if old.rankStyle~=nil and not table.find({"classic","astral","solar"},old.rankStyle)then return nil,"Insígnia inválida."end
  local result=copy(old) result.rankStyle=result.rankStyle or"classic" result.weaponFinishes=result.weaponFinishes or{} result.social=result.social or {favorites={},invites="friends",publicStats=true}
  result.clanInvites=result.clanInvites or{}
  return result
 end
 local p=P.New()
 for key,value in old do if type(key)=="string" and type(value)=="number" then p.stats[key]=P.Number(value) end end
 p.lifetimeXP=P.Number(old.XP)
 local remaining=p.lifetimeXP
 -- At an exact boundary leave the voluntary transition available, not consumed.
 while p.phase~="legend" and remaining>P.Cap(p.phase) do
  local cost=P.Cap(p.phase) remaining-=cost p.cycleXP=cost P.Transition(p)
 end
 p.cycleXP=remaining p.migratedFrom=1
 return p
end
function P.Award(p,amounts,mode,weaponId,weaponXP)
 for key,value in amounts do
  local n=P.Number(value)
  p.stats[key]=math.min(P.MaxNumber,P.Number(p.stats[key])+n)
  if table.find(P.Modes,mode) then local k=mode.."_"..key p.stats[k]=math.min(P.MaxNumber,P.Number(p.stats[k])+n) end
 end
 local xp=P.Number(amounts.XP)
 p.lifetimeXP=math.min(P.MaxNumber,p.lifetimeXP+xp)
 p.cycleXP=math.min(P.Cap(p.phase),p.cycleXP+xp)
 if type(weaponId)=="string" and #weaponId<=80 then p.weapons[weaponId]=math.min(P.MaxNumber,P.Number(p.weapons[weaponId])+P.Number(weaponXP)) end
end
function P.WeaponLevel(xp) return math.min(55,math.floor(math.sqrt(P.Number(xp)/200))+1) end
function P.Unlock(p,mode,item)
 if not table.find(P.Modes,mode) or type(item)~="string" then return false,"Item inválido." end
 if p.permanent[mode][item] then return false,"Item já permanente." end
 if p.tokens[mode]<1 then return false,"Sem token nesta modalidade." end
 p.tokens[mode]-=1 p.permanent[mode][item]=true return true
end
function P.EquipIdentity(p,slot,id)
 local categories={card="cards",frame="frames",title="titles",emblem="emblems"}
 local category=categories[slot]
 if not category or type(id)~="string" or not p.cosmetics[category] or not p.cosmetics[category][id] then return false,"Cosmético não conquistado." end
 p.identity[slot]=id if slot=="frame"then p.frameLayers=nil end return true
end
function P.SetRankStyle(p,id)
 if p.phase~="mastery"and p.phase~="legend"then return false,"Personalização da insígnia requer Maestria."end
 if not table.find({"classic","astral","solar"},id)then return false,"Estilo de insígnia inválido."end
 p.rankStyle=id return true
end
function P.Public(p,userId,name)
 local result={userId=userId,name=name,phase=p.phase,prestige=p.prestige,level=P.Level(p.cycleXP,p.phase),identity=copy(p.identity),revision=p.revision}
 result.rankStyle=p.rankStyle or"classic" result.frameLayers=copy(p.frameLayers)
 if p.clan and p.clan.state=="active"then result.clan={id=p.clan.id,code=p.clan.code,emblem=p.clan.emblem,color=p.clan.color}end
 return result
end
return P
