from pathlib import Path
def edit(n,fn):
 p=Path('src',n+'.luau'); p.write_text(fn(p.read_text(encoding='utf-8')),encoding='utf-8')
def kits(s):
 s=s.replace('Cooldown=1,Automatic=true,Range=210,Magazine=12','Cooldown=1,Automatic=false,Range=210,Magazine=12')
 s=s.replace(' table.insert(Kits.ArenaPistolVisuals,id) Kits.ArenaPistolNames[id]=id',' -- Projectile Test firearms are Conflict choices, never Arena pistol visuals.')
 s=s.replace('function Kits.ArenaGunId(visual) return (visual=="Blaster" or visual=="AutoBlaster") and visual or "ArenaPistol" end','''Kits.ArenaImportedPistols={"m1911","magnum_357","x16","m19","desert_eagle","renetti","sykov"}
for _,id in Kits.ArenaImportedPistols do table.insert(Kits.ArenaPistolVisuals,id) Kits.ArenaPistolNames[id]=Kits.Weapons[id].Name end
function Kits.ArenaGunId(visual) return "ArenaPistol" end
-- The procedural models are shared; Conflict combat definitions are independent.
Kits.ConflictPistolVisuals={Glock18="Glock18",Luger="Luger",Beretta="Beretta"}
local pistolTuning={
 Glock18={Name="Glock 18",Damage=23,MinDamage=12,Cooldown=.085,Automatic=true,Magazine=17,Reserve=102,ReloadTime=1.55,Spread=.65,Range=180,Pitch=2.4,Push=.15},
 Luger={Name="Luger P08",Damage=38,MinDamage=19,Cooldown=.27,Automatic=false,Magazine=8,Reserve=64,ReloadTime=1.85,Spread=.16,Range=230,Pitch=4.4,Push=.28},
 Beretta={Name="Beretta M9",Damage=29,MinDamage=15,Cooldown=.19,Automatic=false,Magazine=15,Reserve=90,ReloadTime=1.45,Spread=.24,Range=210,Pitch=3.0,Push=.20},
}
for id,values in pistolTuning do
 local data=table.clone(Kits.Weapons.ArenaPistol)
 for key,value in values do if key~="Pitch" and key~="Push" then data[key]=value end end
 data.FalloffStart=35 data.FalloffEnd=data.Range*.75
 data.VisualRecoil={Pitch=values.Pitch,Push=values.Push,Roll=.6,Spring=190,Damping=26}
 Kits.Weapons[id]=data
end''')
 return s
edit('ReplicatedStorage/KitDefinitions',kits)
def factory(s):
 s=s.replace('function Factory:Create(id,visual)','''function Factory:Create(id,visual)
 local conflictId=Kits.ConflictPistolVisuals[id] and id
 if conflictId then visual=Kits.ConflictPistolVisuals[id] id="ArenaPistol" end''')
 s=s.replace('local data=Kits.Weapons[id] if not data then return end','local data=Kits.Weapons[conflictId or id] if not data then return end')
 s=s.replace('tool:SetAttribute("WeaponId",id)','tool:SetAttribute("WeaponId",conflictId or id)')
 s=s.replace(' tool:SetAttribute("RestGrip",tool.Grip) return tool',''' if id=="ArenaPistol" and not conflictId then
  tool:SetAttribute("ArenaWeapon",true)
  if table.find(Kits.ArenaImportedPistols,visual) then
   local adapted,err=require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals).Apply(tool,visual,{})
   if not adapted then tool:Destroy() error(err) end
  end
 elseif conflictId then tool.Name=data.Name tool.ToolTip=data.Name.." · Conflict" end
 tool:SetAttribute("RestGrip",tool.Grip) return tool''')
 return s
edit('ServerScriptService/MainGameScript/GameManager/WeaponFactory',factory)
edit('ReplicatedStorage/Crossgrounds/WeaponCatalog',lambda s:s.replace('return Catalog','''for id in Kits.ConflictPistolVisuals do
 local entry=Catalog.Weapons["legacy_"..id]
 if entry then entry.category="PISTOLS" entry.name=Kits.Weapons[id].Name end
end
return Catalog'''))
edit('ReplicatedStorage/Crossgrounds/GameCatalog',lambda s:s.replace('name="Capture a Bandeira"','name="Conflict"'))
edit('StarterPlayer/StarterPlayerScripts/JoinMenu.local',lambda s:s.replace('"CAPTURE A BANDEIRA"','"CONFLICT"'))
edit('StarterPlayer/StarterPlayerScripts/HubController.local',lambda s:s.replace('entrar na rodada CTF','entrar na rodada de Conflict'))
