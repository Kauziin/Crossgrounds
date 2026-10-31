from pathlib import Path
import re, shutil
R=Path(__file__).resolve().parents[1]
backup=R/'artifacts/mw-bursts-2026-10-31/baseline'
def edit(path,fn):
 p=R/path;s=p.read_text(encoding='utf-8-sig');b=backup/path;b.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,b);p.write_text(fn(s),encoding='utf-8')
catalog=(R/'src/ReplicatedStorage/Crossgrounds/WeaponCatalog.luau').read_text()
mw=re.findall(r'"([a-z0-9_]+)",?',catalog[catalog.index('local MW2019CombatIds'):catalog.index('for _, id in MW2019CombatIds')])
changed=[]
def damage(s):
 for weapon in mw:
  pattern=r'(Kits.Weapons\.'+re.escape(weapon)+r'\s*=\s*\{)(.*?)(\n\s*\})'
  def patch(m):
   body=m[2]
   if re.search(r'Automatic\s*=\s*true',body):
    body=re.sub(r'(\b(?:Damage|MinDamage)\s*=\s*)([\d.]+)',lambda n:n[1]+str(float(n[2])/2).removesuffix('.0'),body);changed.append(weapon)
   return m[1]+body+m[3]
  s=re.sub(pattern,patch,s,flags=re.S)
 settings='\n-- Burst timing is game tuning, independent of historical sustained RPM.\nKits.Weapons.fr_5_56.BurstCount=3\nKits.Weapons.fr_5_56.BurstInterval=.1\nKits.Weapons.fr_5_56.BurstPause=.28\nKits.Weapons.an_94.BurstCount=2\nKits.Weapons.an_94.BurstInterval=.08\nKits.Weapons.an_94.BurstPause=.22\n'
 return s.replace('return Kits',settings+'return Kits')
edit('src/ReplicatedStorage/KitDefinitions.luau',damage)
def client(s):
 s=s.replace('local held=false','local Burst=require(game.ReplicatedStorage.Crossgrounds.BurstFire)\nlocal burstGeneration=0 local bursting=false\nlocal held=false',1)
 s=s.replace('if tool~=equipped then held=false','if tool~=equipped then burstGeneration+=1 bursting=false held=false')
 s=s.replace('local now=os.clock() local cooldown=', 'local burst=Burst.Config(data,equipped:GetAttribute("BurstConversion")==true)\n local now=os.clock() local cooldown=burst and burst.interval or ')
 s=s.replace('action:FireServer(equipped,target,Presentation:GetShotOrigin(),shotId,request)\nend','action:FireServer(equipped,target,Presentation:GetShotOrigin(),shotId,request)\n return true\nend\nlocal function beginFire()\n if bursting then return end\n local tool=equipped local data=tool and Kits.Weapons[tool:GetAttribute("WeaponId")]\n local cfg=data and Burst.Config(data,tool:GetAttribute("BurstConversion")==true)\n if not cfg then use() return end\n if os.clock()<nextUse then return end\n bursting=true local token=burstGeneration\n task.spawn(function()\n  for i=1,cfg.count do\n   if token~=burstGeneration or equipped~=tool or not canUse() or tool:GetAttribute("Reloading") then break end\n   if not use() then break end\n   if i<cfg.count then task.wait(cfg.interval+.002) end\n  end\n  if token==burstGeneration then nextUse=math.max(nextUse,os.clock()+cfg.pause) bursting=false end\n end)\nend')
 s=s.replace('held=true Presentation:SetFiring(true) use()','held=true Presentation:SetFiring(true) beginFire()')
 s=s.replace('if held and data.Kind=="Gun" and data.Automatic then use() end','if held and data.Kind=="Gun" and data.Automatic and not Burst.Config(data,equipped:GetAttribute("BurstConversion")==true) then use() end')
 return s
edit('src/StarterPlayer/StarterPlayerScripts/WeaponController.luau',client)
def server(s):
 s=s.replace('local Authority={}','local Burst=require(game.ReplicatedStorage.Crossgrounds.BurstFire)\nlocal burstStates=setmetatable({},{__mode="k"})\nlocal function burstState(tool)\n local state=burstStates[tool]\n if not state then state={} burstStates[tool]=state tool.AncestryChanged:Connect(function()burstStates[tool]=nil end) end\n return state\nend\nlocal Authority={}')
 s=s.replace('if not ledger:Ready(o.weapon,now,o.cooldown or data.Cooldown)', 'local burst=Burst.Config(data,tool:GetAttribute("BurstConversion")==true)\n local state=burst and burstState(tool)\n if burst and not Burst.Ready(state,now) then return reject("burst_cadence") end\n local fireCooldown=burst and burst.interval or o.cooldown or data.Cooldown\n if not ledger:Ready(o.weapon,now,fireCooldown)')
 s=s.replace('ledger:Commit(o.weapon,now,o.cooldown or data.Cooldown)','ledger:Commit(o.weapon,now,fireCooldown)\n if burst then Burst.Commit(state,now,burst) end')
 s=s.replace('if not ledger:Ready(id,now,data.Cooldown)', 'local burst=Burst.Config(data,tool:GetAttribute("BurstConversion")==true) local state=burst and burstState(tool)\n if burst and not Burst.Ready(state,now) then return false,"burst_cadence" end\n if not ledger:Ready(id,now,burst and burst.interval or data.Cooldown)')
 s=s.replace('ledger:Commit(id,now,data.Cooldown)','ledger:Commit(id,now,burst and burst.interval or data.Cooldown)\n if burst then Burst.Commit(state,now,burst) end')
 return s
edit('src/ServerScriptService/Crossgrounds/ShotAuthority.luau',server)
def attachments(s):
 return s.replace('return Catalog','Catalog.aug_burst_conversion={id="aug_burst_conversion",name="Conversão de rajada (3 tiros)",slot="fireControl",status="Available",compatible={"aug"},functionalBurst=true,description="Conversão funcional: três tiros por acionamento. Sem modelo físico adicional."}\nreturn Catalog')
edit('src/ReplicatedStorage/Crossgrounds/AttachmentCatalog.luau',attachments)
edit('src/ReplicatedStorage/Crossgrounds/WeaponCatalog.luau',lambda s:s.replace('return Catalog','table.insert(Catalog.Weapons.aug.slots,"fireControl")\nreturn Catalog'))
def visuals(s):
 s=s.replace('local src=resolve(attachmentId) local mount=', 'if not Attachments[attachmentId].functionalBurst then\n   local src=resolve(attachmentId) local mount=')
 s=s.replace('if slot=="optic" then for _,p in model:GetChildren() do if p.Name=="Rear Sight" or p.Name=="Front Sight" then p.Transparency=1 end end end','if slot=="optic" then for _,p in model:GetChildren() do if p.Name=="Rear Sight" or p.Name=="Front Sight" then p.Transparency=1 end end end\n   end')
 s=s.replace('tool.Name=weapon.name','tool:SetAttribute("BurstConversion",id=="aug" and configuration and configuration.fireControl=="aug_burst_conversion" or false)\n tool.Name=weapon.name')
 return s
edit('src/ServerScriptService/Crossgrounds/ImportedWeaponVisuals.luau',visuals)
edit('src/StarterPlayer/StarterPlayerScripts/GunsmithView.luau',lambda s:s.replace('Acessórios são somente visuais.','Acessórios são visuais, exceto conversões de modo de disparo.').replace('Acessórios: nenhum bônus funcional.','Acessórios visuais: sem bônus. Conversão de rajada altera o disparo.'))
print('Automatic MW weapons adjusted:',len(changed),','.join(changed))
