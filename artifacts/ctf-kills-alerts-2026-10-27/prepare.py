from pathlib import Path
R=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-kills-alerts-2026-10-27\src')
def get(p):return (R/p).read_text(encoding='utf-8-sig')
def put(p,s):(R/p).write_text(s,encoding='utf-8')
p='ServerScriptService/MainGameScript/GameManager/DamageService.luau';s=get(p);s=s.replace('local practice=','local MatchStats=require(game.ServerScriptService.Crossgrounds.CTFMatchStats)\nlocal practice=',1)
a=s.index('  local team=Damage:Team(model)',s.index('h.Died:Connect'));b=s.index('\n end))',a)
body=s[a:b]
body=body.replace('local team=Damage:Team(model)','local team=self:Team(model)',1)
body=body.replace('local victimPlayer=Players:GetPlayerFromCharacter(model)','local victimPlayer=Players:GetPlayerFromCharacter(model)\n  if not victimPlayer then MatchStats.Add(model,"Deaths") end',1)
body=body.replace('local killerTeam=killer and Damage:Team(killer)','local killerTeam=killer and self:Team(killer)',1)
body=body.replace('local p=Players:GetPlayerFromCharacter(killer)','local p=Players:GetPlayerFromCharacter(killer)\n   if not p then MatchStats.Add(killer,"Kills") end',1)
s=s[:a]+'  self:ResolveDeath(model,h)'+s[b:]
pos=s.index('function Damage:Practice(')
s=s[:pos]+'''-- Resolve before cleanup as well as on Died. The per-humanoid guard prevents
-- deferred Died handlers and Unwatch from granting a second elimination.
function Damage:ResolveDeath(model,h)
 local watch=watched[h]
 if not watch or watch.resolved or h.Health>0 then return end
 watch.resolved=true
'''+body+'''\nend
'''+s[pos:]
s=s.replace('local watch=h and watched[h]\n if watch then','local watch=h and watched[h]\n if watch and h.Health<=0 then self:ResolveDeath(model,h) end\n if watch then',1)
s=s.replace('victim:TakeDamage(amount)','victim:TakeDamage(amount)\n if victim.Health<=0 then self:ResolveDeath(target,victim) end',1);put(p,s)
p='ServerScriptService/MainGameScript/GameManager/BotManager.luau';s=get(p);s=s.replace('local Factory=require(script.Parent.WeaponFactory)','local Factory=require(script.Parent.WeaponFactory)\nlocal MatchStats=require(game.ServerScriptService.Crossgrounds.CTFMatchStats)',1);s=s.replace('Avatar:Apply(m,slot+(team.Name=="Red" and 6 or 0),team)','Avatar:Apply(m,slot+(team.Name=="Red" and 6 or 0),team)\n MatchStats.Attach(m)',1)
s=s.replace('if list[slot] then Flags:DropCarrier(list[slot]) Brain:Stop(list[slot]) Damage:Unwatch(list[slot]) list[slot]:Destroy() list[slot]=nil respawn[team.Name][slot]=0 end','if list[slot] then MatchStats.Remove(list[slot]) Flags:DropCarrier(list[slot]) Brain:Stop(list[slot]) Damage:Unwatch(list[slot]) list[slot]:Destroy() list[slot]=nil respawn[team.Name][slot]=0 end',1)
s=s.replace('function Bots:StartRound() active=true','function Bots:StartRound() MatchStats.Reset() active=true',1);put(p,s)
p='ServerScriptService/Crossgrounds/StandingsService.luau';s=get(p);s=s.replace('local Sort=require','local MatchStats=require(script.Parent.CTFMatchStats)\nlocal Sort=require',1);s=s.replace('  for _,rows in groups do Sort.Sort(rows) end','  for _,row in MatchStats.Snapshot() do table.insert(groups.ctf,row) end\n  for _,rows in groups do Sort.Sort(rows) end',1);put(p,s)
p='ServerScriptService/MainGameScript/GameManager/FlagService.luau';s=get(p);s=s.replace('local Events = game.ReplicatedStorage.Events','local Events = game.ReplicatedStorage.Events\nlocal MatchStats=require(game.ServerScriptService.Crossgrounds.CTFMatchStats)',1)
s=s.replace('(character:GetAttribute("DisplayName") or character.Name)','(character:GetAttribute("BotAlias") or character:GetAttribute("DisplayName") or character.Name)');s=s.replace('(flag.carrier:GetAttribute("DisplayName") or flag.carrier.Name)','(flag.carrier:GetAttribute("BotAlias") or flag.carrier:GetAttribute("DisplayName") or flag.carrier.Name)')
s=s.replace('notify(enemy,"capture",character)','if not player then MatchStats.Add(character,"Captures") end\n   notify(enemy,"capture",character)',1);put(p,s)
p='StarterPlayer/StarterPlayerScripts/HeldStandings.luau';s=get(p)
s=s.replace('avatar.Image="rbxthumb://type=AvatarHeadShot&id="..entry.userId.."&w=100&h=100"','local portraitId=entry.avatarUserId or entry.userId avatar.Image=portraitId>0 and ("rbxthumb://type=AvatarHeadShot&id="..portraitId.."&w=100&h=100") or "rbxasset://textures/ui/GuiImagePlaceholder.png"',1)
# Keep bot avatars separate from their synthetic participant ID.
s=s.replace('if entry.userId==player.UserId then','if not entry.isBot and entry.userId==player.UserId then',1);put(p,s)
