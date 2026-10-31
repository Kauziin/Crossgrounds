local Kits = {}
Kits.Order={"Leve","Regular","Pesado","Invasor","Demolidor"}
Kits.Profiles={
 Leve={Title="LEVE",Description="Mobilidade",WalkSpeed=22,SprintSpeed=29,JumpHeight=9,Weapons={"Knife","SMG"}},
 Regular={Title="REGULAR",Description="Versatilidade",WalkSpeed=18,SprintSpeed=25,JumpHeight=7.2,Weapons={"Sword","Rifle"}},
 Pesado={Title="PESADO",Description="Impacto",WalkSpeed=14,SprintSpeed=20,JumpHeight=5.5,Weapons={"Axe","Sniper"}},
 Invasor={Title="INVASOR",Description="Combate próximo",WalkSpeed=19,SprintSpeed=26,JumpHeight=7.5,Weapons={"Baton","Shotgun725"}},
 Demolidor={Title="DEMOLIDOR",Description="Pressão de curta distância",WalkSpeed=16,SprintSpeed=23,JumpHeight=6.5,Weapons={"Hammer","SPAS12"}},
}
Kits.Weapons={
 Knife={Name="Faca",Kind="Melee",Damage=26,Cooldown=.32,Range=5.5,Windup=.04,ActiveTime=.13,FireSound="rbxassetid://74419593834838"},
 SMG={Name="Vasnev 9mm",Kind="Gun",Damage=22,MinDamage=8,FalloffStart=30,FalloffEnd=110,Cooldown=.13,Automatic=true,Range=180,Magazine=32,Reserve=160,ReloadTime=1.65,Spread=.7,FireSound="rbxassetid://132539859090895"},
 Sword={Name="Executor",Kind="Melee",Damage=65,Cooldown=.70,Range=7,Windup=.1,ActiveTime=.22,FireSound="rbxassetid://74419593834838"},
 Rifle={Name="Kastov 545",Kind="Gun",Damage=34,MinDamage=17,FalloffStart=75,FalloffEnd=220,Cooldown=.20,Automatic=true,Range=360,Magazine=26,Reserve=130,ReloadTime=2,Spread=.25,FireSound="rbxassetid://113879008765178"},
 Axe={Name="Treme-Terra",Kind="MeleeArea",Damage=110,Cooldown=1.50,Range=8.5,Windup=.2,ActiveTime=.32,FireSound="rbxassetid://6241709963"},
 Sniper={Name="Lachmann LMS",Kind="Gun",Damage=150,MinDamage=100,FalloffStart=220,FalloffEnd=600,Cooldown=2.00,Automatic=false,Range=800,Magazine=5,Reserve=30,ReloadTime=2.6,Spread=0,FireSound="rbxassetid://109306405910383"},
 Shotgun725={Name="725",Kind="Gun",Damage=29,MinDamage=4,FalloffStart=18,FalloffEnd=75,Cooldown=.5,Automatic=false,Range=110,Magazine=2,Reserve=32,ReloadTime=2.2,Spread=8.5,ProjectilesPerShot=8,FireSound="rbxassetid://109306405910383",FireVolume=.68,FirePlaybackSpeed=.82,FireRange=150,PunchyAudio=true,VisualRecoil={Push=.7,Pitch=7,Roll=1.2,Spring=135,Damping=22}},
 SPAS12={Name="SPAS-12 Semi-Auto",Kind="Gun",Damage=22,MinDamage=3,FalloffStart=24,FalloffEnd=100,Cooldown=.65,Automatic=false,Range=135,Magazine=8,Reserve=48,ReloadTime=3,Spread=7,ProjectilesPerShot=8,FireSound="rbxassetid://109306405910383",FireVolume=.65,FirePlaybackSpeed=1.12,FireRange=145,PunchyAudio=true,VisualRecoil={Push=.5,Pitch=5.5,Roll=.9,Spring=155,Damping=23}},
 Baton={Name="Bastão",Kind="Melee",Damage=40,Cooldown=.38,Range=6.4,Windup=.06,ActiveTime=.18,FireSound="rbxassetid://74419593834838"},
 Hammer={Name="Martelo",Kind="Melee",Damage=85,Cooldown=.95,Range=7,Windup=.15,ActiveTime=.25,FireSound="rbxassetid://6241709963"},
}
-- Arena variants share one weapon definition, including magazine, recoil and fire mode.
Kits.ArenaWeapons={"Sword","ArenaPistol"}
Kits.ArenaPistolVisuals={"M1911","Magnum","Glock18","DesertEagle","Luger","Beretta"}
Kits.ArenaPistolNames={M1911="M1911",Magnum="Magnum",Glock18="Glock 18",DesertEagle="Desert Eagle",Luger="Luger P08",Beretta="Beretta M9"}
Kits.Weapons.ArenaPistol={Name="Pistola",Kind="Gun",Damage=45,MinDamage=14,FalloffStart=35,FalloffEnd=140,Cooldown=1,Automatic=true,Range=210,Magazine=12,Reserve=120,ReloadTime=.9,Spread=.2,FireSound="rbxassetid://115486270266848",FireVolume=.68,FirePlaybackSpeed=.96,FireRange=160,PunchyAudio=true,VisualRecoil={Push=.22,Pitch=4.5,Roll=.65,Spring=220,Damping=28}}
Kits.Weapons.Sniper.MaxTargets=2
Kits.Weapons.Sniper.PenetrationLoss=.2
function Kits:IsPistolVisual(id) return table.find(self.ArenaPistolVisuals,id)~=nil end
Kits.Weapons.SMG.VisualRecoil={Push=.13,Pitch=1.8,Roll=.35,Spring=240,Damping=29}
Kits.Weapons.Rifle.VisualRecoil={Push=.32,Pitch=3.6,Roll=.8,Spring=180,Damping=24}
Kits.Weapons.Sniper.VisualRecoil={Push=.9,Pitch=7.5,Roll=1.6,Spring=115,Damping=20}
-- Original Projectile Test firearms; damage remains server authoritative.
Kits.Weapons.Blaster={Name="Blaster",Kind="Gun",SourcePack="ProjectileTest",Damage=35,Range=1000,Magazine=10,Reserve=100,ReloadTime=1,Cooldown=.1,Automatic=false,Spread=2,ProjectileRadius=.4,ShotVisual={Speed=200,Length=18,Width=.08,SourcePack="ProjectileTest"},FireSound="rbxassetid://17682716783",CameraRecoilMin=Vector2.new(0,15),CameraRecoilMax=Vector2.new(5,20),VisualRecoil={Push=0,Pitch=0,Roll=0}}
Kits.Weapons.AutoBlaster={Name="AutoBlaster",Kind="Gun",SourcePack="ProjectileTest",Damage=10,Range=1000,Magazine=30,Reserve=180,ReloadTime=1.5,Cooldown=.1,Automatic=true,Spread=2,ProjectileRadius=.4,ShotVisual={Speed=200,Length=18,Width=.08,SourcePack="ProjectileTest"},FireSound="rbxassetid://17682714653",CameraRecoilMin=Vector2.new(-2,5),CameraRecoilMax=Vector2.new(2,7),VisualRecoil={Push=0,Pitch=0,Roll=0}}
for _,id in {"Blaster","AutoBlaster"} do
 table.insert(Kits.Order,id)
 Kits.Profiles[id]={Title=id=="Blaster" and "BLASTER" or "AUTO BLASTER",Description="Projectile Test",WalkSpeed=18,SprintSpeed=25,JumpHeight=7.2,Weapons={"Sword",id}}
 table.insert(Kits.ArenaPistolVisuals,id) Kits.ArenaPistolNames[id]=id
end
function Kits.ArenaGunId(visual) return (visual=="Blaster" or visual=="AutoBlaster") and visual or "ArenaPistol" end
-- All existing guns remain instant hitscan. Simulated travel is opt-in per definition.
for _,data in Kits.Weapons do if data.Kind=="Gun" then
 data.ShotType=data.ShotType or "hitscan" data.ProjectilesPerShot=data.ProjectilesPerShot or 1
 data.ShotVisual=data.ShotVisual or {Speed=3000,Length=18,Width=.035}
end end
Kits.ReloadSound="rbxassetid://139048584127232"
function Kits.DamageAtDistance(data,distance)
 local alpha=math.clamp((distance-(data.FalloffStart or data.Range))/math.max(1,(data.FalloffEnd or data.Range)-(data.FalloffStart or data.Range)),0,1)
 return math.floor(data.Damage+((data.MinDamage or data.Damage)-data.Damage)*alpha+.5)
end
function Kits.RangeBand(data,distance)
 if distance>data.Range then return "FORA DE ALCANCE" end
 if distance>(data.FalloffStart or data.Range) then return "DANO REDUZIDO" end
 return "ALCANCE EFETIVO"
end
function Kits.ShotDamage(data,distance,headshot,multiplier)
 local amount=Kits.DamageAtDistance(data,distance)*(multiplier or 1)
 if headshot then amount*=1.5 end
 return amount
end
return Kits
