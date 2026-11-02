from pathlib import Path
import shutil
def edit(n,fn):
 p=Path('src',n+'.luau'); b=Path('artifacts/arsenal-round-2026-11-01/before',n+'.luau'); b.parent.mkdir(parents=True,exist_ok=True)
 if b.exists(): raise RuntimeError('One-shot patch already applied')
 shutil.copy2(p,b); p.write_text(fn(p.read_text(encoding='utf-8')),encoding='utf-8')
edit('ReplicatedStorage/Crossgrounds/WeaponCatalog',lambda s:s.replace('return Catalog','table.insert(Catalog.Weapons.m4a1.slots,"magazine")\nCatalog.Weapons.m4a1.mountPoints.magazine="M4MagazineWell"\nreturn Catalog'))
edit('ReplicatedStorage/Crossgrounds/WeaponAssetRegistry',lambda s:s.replace('return Registry','Registry.barrels_ax_50_heavy={"ServerStorage","ImportedArsenalOriginals","CoD:MW Weapon/Attachment Props","ATTACHMENTS","Barrels","AX-50 Heavy Barrel"}\nreturn Registry'))
def attachments(s):
 insert='''
Catalog.barrels_ax_50_heavy={id="barrels_ax_50_heavy",name="AX-50 Heavy Barrel",slot="barrel",status="Available",compatible={"ax_50"},compatibleWeapons={"ax_50"},compatibilityMode="SpecificWeapon",auditStatus="Verified",pendingAudit=false,mountType="AX50Barrel",requiresMount=true,visualOnly=false,publicationBlocked=true,physicalAssetPath=Registry.barrels_ax_50_heavy,statMultipliers={Spread=.65,VisualRecoil={Push=.65,Pitch=.65,Roll=.65},Range=1.10,FalloffStart=1.10,FalloffEnd=1.10,AdsSpeedMultiplier=.85,MovementSpeedMultiplier=.92},description="Heavy: estabilidade maior que Extended, alcance menor; valores provisórios."}
local magazines={magazines_20rnd_5_56x45mm_normal_magazine=20,magazines_30rnd_5_56x45mm_nato_magazine_kilo=30,magazines_30rnd_5_56x45mm_holger_magazine=30}
for id,capacity in magazines do
 local a=Catalog[id] a.status="Available" a.auditStatus="Verified" a.pendingAudit=false
 a.compatible={"m4a1"} a.compatibleWeapons={"m4a1"} a.compatibilityMode="SpecificWeapon"
 a.mountType="M4MagazineWell" a.requiresMount=true a.visualOnly=false a.publicationBlocked=true
 a.statOverrides={Magazine=capacity} a.alignmentPart="Bullets"
 a.description=tostring(capacity).." munições; reserva e dano preservados. Encaixe dedicado M4A1."
end
for _,id in {"suppressors_monolithic_suppressor","suppressors_colossus_suppressor"} do Catalog[id].suppressed=true Catalog[id].noiseMultiplier=.6 Catalog[id].publicationBlocked=true end
'''
 return s.replace('return Catalog',insert+'\nreturn Catalog')
edit('ReplicatedStorage/Crossgrounds/AttachmentCatalog',attachments)
edit('ReplicatedStorage/Crossgrounds/WeaponStats',lambda s:s.replace('\t-- Proteções para valores utilizados no combate.',''' -- Exact capacity overrides are restricted to integer magazine capacities.
 for _,attachment in selected do
  for field,value in attachment.statOverrides or {} do
   if field~="Magazine" or not finite(value) or value%1~=0 or value<1 or value>200 then return nil end
   data.Magazine=value
  end
 end
\t-- Proteções para valores utilizados no combate.'''))
def visuals(s):
 s=s.replace(' elseif id=="ax_50" then','''  local top
  for _,p in model:GetChildren() do if p:IsA("BasePart") and p:GetAttribute("ReloadGroup")=="Magazine" and p.Name=="Bullets" and (not top or p.Position.Y>top.Y) then top=p.Position end end
  if top then attach(handle,"magazine",CFrame.new(top)) end
 elseif id=="ax_50" then''')
 s=s.replace('   local muzzleZ=configuration and configuration.barrel=="barrels_ax_50_extended" and -17.19 or -7.29','   local muzzleZ=-7.29')
 s=s.replace('  for slot,attachmentId in clean do','''  local slots={} for slot in clean do table.insert(slots,slot) end
  table.sort(slots,function(a,b) if a=="barrel" then return b~="barrel" elseif b=="barrel" then return false end return a<b end)
  for _,slot in slots do local attachmentId=clean[slot]''')
 s=s.replace('local accessory=cachedGeometry(attachmentId,src,bound.Position)','local accessory=cachedGeometry(attachmentId,src,slot=="barrel" and origin or bound.Position)')
 marker='   for _,p in accessory:GetChildren() do if p:IsA("BasePart") then p.CFrame=mount.WorldCFrame*CFrame.new(-anchor)*p.CFrame'
 s=s.replace(marker,'''   if slot=="magazine" then
    local alignment=accessory:FindFirstChild(Attachments[attachmentId].alignmentPart)
    if not alignment then model:Destroy() accessory:Destroy() return nil,"Magazine insertion reference missing." end
    anchor=alignment.Position
    for _,native in model:GetChildren() do if native:IsA("BasePart") and not native:GetAttribute("VisualAttachmentId") and native:GetAttribute("ReloadGroup")=="Magazine" then native.Transparency=1 end end
   elseif slot=="barrel" then
    for _,native in model:GetChildren() do if native:IsA("BasePart") and not native:GetAttribute("VisualAttachmentId") and (native.Name=="Barrel" or native.Name=="Muzzle" or attachmentId=="barrels_ax_50_heavy" and native.Name=="Rails") then native.Transparency=1 end end
    local muzzle=accessory:FindFirstChild("Muzzle")
    if muzzle then
     local minZ=math.huge
     for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do minZ=math.min(minZ,muzzle.CFrame:PointToWorldSpace(muzzle.Size*Vector3.new(x,y,z)*.5).Z) end end end
     handle.muzzle.CFrame=CFrame.new(muzzle.Position.X,muzzle.Position.Y,minZ) handle.Muzzle.CFrame=handle.muzzle.CFrame
    end
   end
   for _,p in accessory:GetChildren() do if p:IsA("BasePart") then
    if slot~="barrel" then p.CFrame=mount.WorldCFrame*CFrame.new(-anchor)*p.CFrame end
    if slot=="magazine" then p:SetAttribute("ReloadGroup","Magazine") end''')
 return s
edit('ServerScriptService/Crossgrounds/ImportedWeaponVisuals',visuals)
edit('StarterPlayer/StarterPlayerScripts/ArsenalPreview',lambda s:s.replace("for _,v in self.model:GetChildren() do if changed", "if changed.barrel then changed.muzzle=true end\n\t\tfor _,v in self.model:GetChildren() do if changed",1))
edit('ReplicatedStorage/Crossgrounds/AttachmentEffects',lambda s:s.replace('local Effects={}','local Attachments=require(script.Parent.AttachmentCatalog)\nlocal Effects={}').replace(' return {spread=', ' local suppressed=false local noise=1\n for _,attachmentId in clean do local a=Attachments[attachmentId] if a.suppressed then suppressed=true noise=math.min(noise,a.noiseMultiplier or 1) end end\n return {noise=noise,spread=').replace('suppressed=clean.muzzle=="suppressors_monolithic_suppressor"','suppressed=suppressed').replace(' tool:SetAttribute("AttachmentSpreadMultiplier",',' tool:SetAttribute("Suppressed",m.suppressed) tool:SetAttribute("ShotNoiseMultiplier",m.noise)\n tool:SetAttribute("AttachmentSpreadMultiplier",'))
edit('ServerScriptService/Crossgrounds/ShotAuthority',lambda s:s.replace('Noise.Emit(c,origin,data.FireRange or 100)','Noise.Emit(c,origin,(data.FireRange or 100)*(tool:GetAttribute("ShotNoiseMultiplier") or 1))'))
edit('ServerStorage/Development/Tools/CTFWideAuthoring',lambda s:s.replace('SetAttribute("Enabled",true)','SetAttribute("Enabled",false)'))
