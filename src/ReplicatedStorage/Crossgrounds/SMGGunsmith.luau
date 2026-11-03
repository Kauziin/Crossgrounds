-- Explicit SMG pilot mounts and genuine variants from the imported MW pack.
local G={Ids={"mp5","mp7","uzi","p90","aug","pp_19_bizon","striker_45","fennec","iso"}}
local pack={"ServerStorage","ImportedArsenalOriginals","CoD:MW Weapon/Attachment Props"}
local function path(...)
 local p=table.clone(pack) for _,s in {...} do table.insert(p,s) end return p
end
local presets="Presets/Blueprint Parts/Unofficials"
G.Variants={
 {id="smg_mp7_20",weapon="mp7",slot="magazine",name="MP7 · carregador de 20",capacity=20,path=path(presets,"MP7 (A1 Model, Unofficial)","20rnd 4.6x30 HK Magazine")},
 {id="smg_mp5_30_klassik",weapon="mp5",slot="magazine",name="MP5 · carregador Klassik de 30",capacity=30,path=path(presets,"MP5 (Klassik RK, Unofficial)","30rnd 9x19mm Magazine")},
 {id="smg_iso_30",weapon="iso",slot="magazine",name="ISO · carregador de 30",capacity=30,path=path("ATTACHMENTS","Magazines","30rnd 9x19mm Magazine (ISO)")},
 {id="smg_iso_50",weapon="iso",slot="magazine",name="ISO · tambor de 50",capacity=50,path=path("ATTACHMENTS","Magazines","50rnd 9x19mm Drum Magazine (ISO)")},
 {id="smg_uzi_32",weapon="uzi",slot="magazine",name="Uzi · carregador .41 AE de 32",capacity=32,path=path("ATTACHMENTS","Magazines","32rnd .41 AE Magazine (Uzi)")},
 {id="smg_aug_30",weapon="aug",slot="magazine",name="AUG · modelo 5.56 de 30",capacity=30,path=path(presets,"AUG (Dame Fortuna)","30rnd 5.56x45mm Magazine")},
 {id="smg_mp7_xrk_stock",weapon="mp7",slot="stock",name="MP7 · XRK Retractable Stock",path=path(presets,"MP7 (A1 Model, Unofficial)","XRK Retractable Stock")},
 {id="smg_mp5_klassik_stock",weapon="mp5",slot="stock",name="MP5 · coronha Klassik",path=path(presets,"MP5 (Klassik RK, Unofficial)","Stock")},
 {id="smg_uzi_unfolded_stock",weapon="uzi",slot="stock",name="Uzi · coronha aberta",path=path("SUBMACHINE GUNS","Uzi (Default)","Unfolded Stock")},
 {id="smg_striker_ump_stock",weapon="striker_45",slot="stock",name="Striker-45 · coronha UMP",path=path(presets,"Striker-45 (UMP45, Unofficial)","Stock")},
 {id="smg_aug_a2_barrel",weapon="aug",slot="barrel",name="AUG · cano A2",path=path(presets,"AUG (A2 Modified, Unofficial)","Barrel")},
 {id="smg_uzi_pro_barrel",weapon="uzi",slot="barrel",name="Uzi · cano SMG PRO",path=path(presets,"Uzi (SMG PRO, Unofficial)","Barrel")},
 {id="smg_striker_ump_barrel",weapon="striker_45",slot="barrel",name="Striker-45 · cano UMP",path=path(presets,"Striker-45 (UMP45, Unofficial)","Barrel")},
}
local mountTypes={optic="TopRail",muzzle="MuzzleThread",underbarrel="LowerRail",laser="SMGLaser",magazine="SMGMagazineWell",stock="SMGStock",barrel="SMGBarrel"}
function G.InstallWeapons(weapons)
 for _,id in G.Ids do
  local w=weapons[id] w.mountPoints=w.mountPoints or {}
  local function add(slot) if not table.find(w.slots,slot) then table.insert(w.slots,slot) end w.mountPoints[slot]=mountTypes[slot] end
  for _,slot in {"optic","muzzle","laser"} do add(slot) end
  if id~="pp_19_bizon" and id~="p90" then add("underbarrel") end
  for _,v in G.Variants do if v.weapon==id then add(v.slot) end end
 end
end
function G.InstallAttachments(catalog)
 local function extend(id,ids,mount)
  local a=assert(catalog[id]) a.status="Available" a.auditStatus="Verified" a.pendingAudit=false a.mountType=mount
  for _,weapon in ids do if not table.find(a.compatible,weapon) then table.insert(a.compatible,weapon) end end
  a.compatibleWeapons=a.compatible
 end
 extend("optics_g_i_mini_reflex",G.Ids,"TopRail")
 extend("suppressors_monolithic_suppressor",G.Ids,"MuzzleThread")
 local lower={} for _,id in G.Ids do if id~="pp_19_bizon" and id~="p90" then table.insert(lower,id) end end
 extend("foregrips_commando_foregrip",lower,"LowerRail")
 extend("lasers_tac_laser",G.Ids,"SMGLaser")
 local laser=catalog.lasers_tac_laser laser.visualOnly=false laser.statMultipliers={AdsMotionMultiplier=.85}
 laser.description="Laser montado na lateral: 15% menos balanço em ADS. Sem auto-mira ou alteração de dano."
 for _,v in G.Variants do
  local a={id=v.id,name=v.name,slot=v.slot,status="Available",auditStatus="Verified",pendingAudit=false,
   compatible={v.weapon},compatibleWeapons={v.weapon},compatibilityMode="SpecificWeapon",mountType=mountTypes[v.slot],
   requiresMount=true,physicalAssetPath=v.path,publicationBlocked=true,sourcePack="mw2019",visualOnly=false,
   rigDependencies={"Handle."..v.slot},mountName=v.slot}
  if v.slot=="magazine" then
   a.statOverrides={Magazine=v.capacity} a.alignmentPart=v.weapon=="uzi" and "Bullet Visible" or "Bullets"
   a.statMultipliers=v.capacity>=50 and {MovementSpeedMultiplier=.94,AdsSpeedMultiplier=.90,ReloadTime=1.08} or {MovementSpeedMultiplier=.98,AdsSpeedMultiplier=.97}
   a.description=tostring(v.capacity).." munições; dano, calibre balístico e reserva preservados. Variante visual do pacote."
  elseif v.slot=="stock" then
   a.alignmentMode="Front" a.statMultipliers={AdsMotionMultiplier=.65,AdsSpeedMultiplier=.95}
   a.description="35% menos balanço ao mirar; velocidade de ADS -5%."
  else
   a.statMultipliers={Spread=.90,Range=1.08,FalloffStart=1.08,FalloffEnd=1.08,AdsSpeedMultiplier=.95}
   a.description="Variante de cano do pacote: dispersão -10%, alcance +8%, velocidade de ADS -5%. Valores de balanceamento provisórios."
  end
  catalog[v.id]=a
 end
end
function G.Bounds(parts)
 local lo=Vector3.new(math.huge,math.huge,math.huge) local hi=-lo
 for _,p in parts do for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
  local v=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)*.5)
  lo=lo:Min(v) hi=hi:Max(v)
 end end end end
 return lo,hi
end
function G.Mount(model,handle,id)
 if not table.find(G.Ids,id) then return end
 local function find(names)
  for _,name in names do local p=model:FindFirstChild(name) if p and p:IsA("BasePart") then return p end end
 end
 local function mount(name,position,rotation)
  local a=handle:FindFirstChild(name) or Instance.new("Attachment",handle) a.Name=name a.CFrame=CFrame.new(position)*(rotation or CFrame.identity)
 end
 local rail=find({"Rail","Rails","Rail Mount","Top"}) or find({"Base"})
 local lo,hi=G.Bounds({rail}) mount("optic",Vector3.new(0,hi.Y,rail.Position.Z))
 local muzzle=find({"Muzzle","Muzzle Flash","Barrel","Barrel Main"}) or id=="mp5" and find({"Base"})
 lo,hi=G.Bounds({muzzle}) local muzzlePosition=Vector3.new(muzzle.Position.X,muzzle.Position.Y,lo.Z)
 mount("Muzzle",muzzlePosition) mount("muzzle",muzzlePosition)
 local support=handle.SupportGrip.Position
 if id=="aug" then
  local hinge=find({"Grip Part"}) if hinge then support=hinge.Position end
 end
 mount("underbarrel",Vector3.new(0,support.Y,support.Z))
 mount("laser",Vector3.new(.28,support.Y+.18,support.Z),CFrame.Angles(0,0,math.pi/2))
 local bullet=find({"Bullets","Bullet"})
 if bullet then mount("magazine",bullet.Position) else
  local magazine=find({"Magazine"}) if magazine then lo,hi=G.Bounds({magazine}) mount("magazine",Vector3.new(magazine.Position.X,hi.Y-.10,magazine.Position.Z)) end
 end
 local stocks={} for _,p in model:GetChildren() do if p:IsA("BasePart") and p:GetAttribute("NativeStock") and p.Name~="Unfolded Stock" then table.insert(stocks,p) end end
 if #stocks>0 then lo,hi=G.Bounds(stocks) mount("stock",Vector3.new((lo.X+hi.X)*.5,(lo.Y+hi.Y)*.5,lo.Z)) end
 local barrel=find({"Barrel","Barrel Main"}) if barrel then lo,hi=G.Bounds({barrel}) mount("barrel",Vector3.new(barrel.Position.X,barrel.Position.Y,hi.Z)) end
 local unfolded=model:FindFirstChild("Unfolded Stock") if unfolded then unfolded.Transparency=1 end
 local alternate=model:FindFirstChild("Frontend (Alternate Color)") if alternate then alternate.Transparency=1 end
end
return G
