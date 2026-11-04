-- Read-only projections of existing progression contracts; never awards anything.
local P=require(script.Parent.CareerPolicy)
local Unlocks=require(script.Parent.UnlockCatalog)
local Weapons=require(script.Parent.WeaponCatalog)
local Attachments=require(script.Parent.AttachmentCatalog)
local Compatibility=require(script.Parent.AttachmentCompatibility)
local Finishes=require(script.Parent.WeaponFinishCatalog)
local Clans=require(script.Parent.ClanCatalog)
local T={}
T.Categories={all='Todas as recompensas',weapon='Armas',appearance='Aparências',attachment='Acessórios',finish='Acabamentos'}
T.Slots={optic='Mira',muzzle='Boca',barrel='Cano',underbarrel='Acoplamento',magazine='Carregador',stock='Coronha',laser='Laser',ammo='Munição',grip='Cabo',fireControl='Disparo'}
local function add(track,level,reward)
 track.rows[level]=track.rows[level] or {} table.insert(track.rows[level],reward)
end
local function base(kind,profile,xp,current,lower,upper)
 return {kind=kind,ready=profile~=nil,xp=xp,current=current,lower=lower,upper=upper,max=math.max(55,current+3),rows={}}
end
function T.Allows(p,mode,item,weapon)
 if not p then return nil end
 if p.permanent[mode] and p.permanent[mode][item.id] then return true end
 if item.weaponLevel then return P.WeaponLevel(p.weapons[Unlocks.Canonical(weapon or item.weaponId)] or 0)>=item.weaponLevel end
 return p.accountUnlocked==true or P.Level(p.cycleXP,p.phase)>=item.level
end
function T.Account(p,mode,category)
 local xp=p and p.cycleXP or 0 local level,lo,hi=P.Progress(xp,p and p.phase)
 local track=base('account',p,xp,level,lo,hi)
 track.title='Desbloqueios de Nível' track.subtitle=p and ('Nível '..level..' · XP nesta etapa da carreira') or 'Carreira indisponível ou carregando'
 track.totalXP=p and p.lifetimeXP or nil
 for _,m in mode=='all' and {'ctf','arena'} or {mode} do
  for _,item in Unlocks.List(m) do if item.level and (not category or category=='all' or item.kind==category) then
   local row=table.clone(item) row.mode=m row.available=T.Allows(p,m,item) row.description=(m=='ctf' and 'Conflito' or 'Arena')..' · '..(item.kind=='weapon' and 'Armamento' or 'Aparência')..' · Conta nível '..item.level
   add(track,item.level,row)
  end end
 end
 return track
end
function T.Weapon(p,id,category)
 local w=Weapons.Get(id) local canonical=Unlocks.Canonical(id)
 local xp=p and P.Number(p.weapons[canonical]) or 0 local level=P.WeaponLevel(xp)
 local lo=200*(level-1)^2 local hi=level<55 and 200*level^2 or lo
 local track=base('weapon',p,xp,level,lo,hi) track.max=55 track.weaponId=id
 track.title=w and w.name or id track.subtitle='Nível da arma '..level..' · XP de arma'
 local count=0
 if w then for _,slot in w.slots do for _,result in Compatibility.ForSlot(w,Attachments,slot) do if result.available then
  local item=Unlocks.Get('ctf',result.attachment.id,id)
  if item and (not category or category=='all' or category==slot) then
   local row=table.clone(item) row.slot=slot row.available=T.Allows(p,'ctf',item,id) row.description=(T.Slots[slot] or slot)..' · Arma nível '..item.weaponLevel
   add(track,item.weaponLevel,row)
  end count+=1
 end end end end
 if not category or category=='all' or category=='finish' then for finish,item in Finishes.Items do
  local token=Finishes.TokenId(canonical or id,finish)
  add(track,item.level,{id=token,name=item.name,kind='finish',finish=finish,weaponId=id,available=p and Finishes.Allows(p,canonical,finish,'ctf',level) or nil,description='Acabamento cosmético · sem alteração de atributos.',color=item.a})
 end end
 track.note=count==0 and 'Esta arma ainda não possui acessórios com montagem aprovada. Os acabamentos abaixo são os do catálogo atual.' or 'Acessórios e acabamentos do catálogo compartilhado com o Armeiro.'
 return track
end
function T.Guild(snapshot,p)
 local c=snapshot and not snapshot.pending and snapshot.clan
 if not c or not c.role or not c.epoch or c.archived then return {kind='guild',ready=false,current=1,max=5,rows={},title='Progressão da Guilda',subtitle=snapshot and snapshot.pending and 'Filiação em confirmação' or 'Você não possui uma associação ativa confirmada.',note='Gerencie seu clã pelo menu existente. Missões semanais aguardam um serviço próprio.'} end
 local level=Clans.Level(c.xp) local track=base('guild',c,c.xp,level,Clans.Threshold(level),Clans.Threshold(level+1))
 track.max=math.max(5,level+3) track.title=c.name..' ['..c.tag..']' track.subtitle='Nível '..level..' · '..#c.members..' / '..c.capacity..' membros' track.clan=c
 local contribution=0 for _,m in c.members do if m.epoch==c.epoch then contribution=m.contributionXP or 0 end end
 local owned=p and p.cosmetics and p.cosmetics.cards.clan==true and p.cosmetics.frames.clan==true and p.cosmetics.titles.clan==true
 add(track,Clans.IdentityReward.Level,{id='clan_identity',name=Clans.IdentityReward.Name,kind='guild',claimed=owned==true,available=owned==true or level>=Clans.IdentityReward.Level and contribution>=Clans.IdentityReward.ContributionXP,description='Cartão, moldura e título existentes. Requer clã nível 3 e 1.000 XP de contribuição pessoal; concessão automática pelo servidor.'})
 track.note='Missões semanais: indisponíveis no backend atual. Contribuições abaixo são acumuladas desde a entrada, não semanais.'
 return track
end
return T
