local Bounds = require(script.Parent.SMGGunsmith).Bounds
local Pilot = {}

-- Surface names refer to the normalized copies of the actual imported meshes.
-- A receiver entry uses a small adapter plate in the assembled model.
local rifles = {
 m4a1 = {"Receiver", "Handguard"},
 ak_47 = {"Dust Cover", "Handguard"},
 an_94 = {"Base", "Handguard"},
 as_val = {"Dust Cover", "Handguard"},
 cr_56_amax = {"Dust Cover", "Rail Covers"},
 fal = {"Rail", "Handguard"},
 fr_5_56 = {"Rail"},
 grau_5_56 = {"Rail", "Handguard"},
 kilo_141 = {"Base", "Handguard"},
 m13 = {"Topper", "Handguard"},
 oden = {"Top Rail", "Handguard"},
 ram_7 = {"Rails", "Handguard"},
 scar_h = {"Topper", "Base"},
 legacy_Rifle = {"OpticRail", "LowerRail"},
 legacy_SMG = {"OpticRail", "LowerRail"},
}
local barrelWeapons = {grau_5_56 = true, cr_56_amax = true}
-- Contact points on the lower surfaces, rather than the enclosing mesh bounds.
local foregripContacts = {
 an_94=Vector3.new(0,.347,-2.39),
 as_val=Vector3.new(0,.356,-1.49),
 aug=Vector3.new(0,.287,-1.38),
 fennec=Vector3.new(0,.163,-1.5),
 iso=Vector3.new(0,.513,-1.49),
 ram_7=Vector3.new(0,.188,-1.39),
 scar_h=Vector3.new(0,.597,-2.35),
 striker_45=Vector3.new(0,.538,-2.2),
 uzi=Vector3.new(0,.264,-.85),
}
local stanagWells = {
 kilo_141=Vector3.new(0,.532,-1.064),
 m13=Vector3.new(0,.479,-1.062),
 grau_5_56=Vector3.new(0,.482,-1.097),
 ram_7=Vector3.new(0,.471,1.003),
}
local mountTypes = {optic="TopRail", underbarrel="LowerRail", muzzle="MuzzleThread", barrel="PilotBarrel", magazine="M1911MagazineWell", stock="ARBufferTube"}
local function mountType(id, slot)
 if id=="ak_47" and slot=="magazine" then return "AK47MagazineWell" end
 if stanagWells[id] and slot=="magazine" then return "M4MagazineWell" end
 return mountTypes[slot]
end
Pilot.BarrelWeapons = barrelWeapons

function Pilot.IsLegacy(id)
 return id == "legacy_Rifle" or id == "legacy_SMG"
end

function Pilot.InstallWeapons(weapons)
 local function add(id, slot)
  local weapon = weapons[id]
  weapon.mountPoints = weapon.mountPoints or {}
  weapon.mountPoints[slot] = mountType(id, slot)
  if not table.find(weapon.slots, slot) then table.insert(weapon.slots, slot) end
 end
 weapons.legacy_Rifle.category = "ASSAULT RIFLES"
 weapons.legacy_SMG.category = "SUBMACHINE GUNS"
 for id, surfaces in rifles do
  add(id, "optic")
  if surfaces[2] then add(id, "underbarrel") end
  if id ~= "as_val" then add(id, "muzzle") end
  if barrelWeapons[id] then add(id, "barrel") end
 end
 add("m1911", "magazine")
 add("ak_47", "magazine")
 for id in stanagWells do add(id,"magazine") end
 for _,id in {"m4a1","m13"} do add(id,"stock") end
end

function Pilot.InstallAttachments(catalog)
 local function approve(attachment, id, slot)
  attachment.status = "Available"
  attachment.auditStatus = "Verified"
  attachment.pendingAudit = false
  attachment.mountType = mountType(id, slot)
  if not table.find(attachment.compatible, id) then table.insert(attachment.compatible, id) end
  attachment.compatibleWeapons = attachment.compatible
 end
 local akMagazine = catalog.magazines_40rnd_7_62x39mm_magazine_ak_47
 approve(akMagazine, "ak_47", "magazine")
 akMagazine.alignmentPart = "Bullets"
 akMagazine.statOverrides = {Magazine=40}
 akMagazine.statMultipliers = {MovementSpeedMultiplier=.97, AdsSpeedMultiplier=.94, ReloadTime=1.07}
 akMagazine.visualOnly = false
 akMagazine.description = "40 munições. Movimento -3%, velocidade de ADS -6% e recarga +7%."
 local longAK = catalog.rialag_magazines_ak_magazines_45rd_7_62x39_ak_magazine
 approve(longAK,"ak_47","magazine")
 longAK.alignmentPart = "Part"
 longAK.visualScale = 1.8
 longAK.statOverrides = {Magazine=45}
 longAK.statMultipliers = {MovementSpeedMultiplier=.94, AdsSpeedMultiplier=.90, ReloadTime=1.10}
 longAK.visualOnly = false
 longAK.description = "45 munições. Movimento -6%, velocidade de ADS -10% e recarga +10%."
 for _,attachmentId in {"magazines_ar15_pmag_40","magazines_ar15_surefire_60"} do
  for id in stanagWells do approve(catalog[attachmentId],id,"magazine") end
 end
 local light = catalog.rialag_buffer_tube_stocks_gl_core_stock
 local heavy = catalog.rialag_buffer_tube_stocks_b5_systems_sopmod_stock
 for _,attachment in {light,heavy} do
  for _,id in {"m4a1","m13"} do approve(attachment,id,"stock") end
  attachment.alignmentMode = "Front"
  attachment.mountReferencePart = "Joint"
  attachment.mountAdjustment = CFrame.Angles(0,math.pi,0)
  attachment.visualScale = 1.35
  attachment.visualOnly = false
 end
 light.statMultipliers = {AdsSpeedMultiplier=1.12,AdsMotionMultiplier=1.06}
 light.description = "Velocidade de ADS +12% e balanço ao mirar +6%."
 heavy.statMultipliers = {AdsSpeedMultiplier=.94,AdsMotionMultiplier=.65,VisualRecoil={Push=.80,Pitch=.85,Roll=.80}}
 heavy.description = "Balanço em ADS -35%, menos coice e velocidade de ADS -6%."
 for id, surfaces in rifles do
  approve(catalog.optics_g_i_mini_reflex, id, "optic")
  if surfaces[2] then approve(catalog.foregrips_commando_foregrip, id, "underbarrel") end
  if id ~= "as_val" then approve(catalog.suppressors_monolithic_suppressor, id, "muzzle") end
 end
 local angledGrip = catalog.rialag_foregrips_magpul_afg2
 local verticalGrip = catalog.rialag_foregrips_magpul_rvg
 for _,id in {"m4a1","grau_5_56","kilo_141","ram_7","mp5","mp7","iso"} do
  approve(angledGrip, id, "underbarrel")
  approve(verticalGrip, id, "underbarrel")
 end
 angledGrip.description = "Acoplamento inclinado visual. Mantém os atributos da arma."
 verticalGrip.visualOnly = false
 verticalGrip.statMultipliers = {AdsMotionMultiplier=.80, AdsSpeedMultiplier=.97}
 verticalGrip.description = "Balanço em ADS -20% e velocidade de ADS -3%."
 for id, spec in {
  barrels_fss_20_8_nexus = {weapon="grau_5_56", range=1.18, ads=.90, spread=.9},
  barrels_fss_11_8_squall_cr_56 = {weapon="cr_56_amax", range=.88, ads=1.12, spread=1.08},
 } do
  local attachment = catalog[id]
  approve(attachment, spec.weapon, "barrel")
  attachment.visualOnly = false
  attachment.statMultipliers = {Range=spec.range, FalloffStart=spec.range, FalloffEnd=spec.range, AdsSpeedMultiplier=spec.ads, Spread=spec.spread}
  attachment.description = spec.range>1 and "Cano longo. Alcance +18%, dispersão -10% e velocidade de ADS -10%."
   or "Cano compacto. Velocidade de ADS +12%, alcance -12% e dispersão +8%."
 end
 for _, variant in {
  {id="m1911_classic_mag_7", name="1911 · carregador clássico de 7", capacity=7, group="Reskins", model="1911 (Rusted)", asset="7-Round .45 ACP Magazine"},
  {id="m1911_extended_mag_10", name="1911 · carregador estendido de 10", capacity=10, group="Presets/Blueprint Parts/Unofficials", model="1911 (Phantom6, My Personal Weapon)", asset="10-Round .45 ACP Magazine"},
 } do
  local extended = variant.capacity == 10
  local attachment = {
   id=variant.id, assetId=variant.id, name=variant.name, slot="magazine", compatible={},
   compatibilityMode="SpecificWeapon", requiresMount=true, publicationBlocked=true, sourcePack="mw2019",
   physicalAssetPath={"ServerStorage","ImportedArsenalOriginals","CoD:MW Weapon/Attachment Props",variant.group,variant.model,variant.asset},
   alignmentPart="Bullets", visualOnly=not extended,
   description=extended and "10 munições. Recarga +8% e velocidade de ADS -4%." or "Variante visual de 7 munições.",
  }
  if extended then
   attachment.statOverrides = {Magazine=10}
   attachment.statMultipliers = {ReloadTime=1.08, AdsSpeedMultiplier=.96}
  end
  approve(attachment, "m1911", "magazine")
  catalog[variant.id] = attachment
 end
end

local function addOpticPlate(model, position, opticId)
 if not opticId then return position end
 local plate = Instance.new("Part")
 plate.Name = "OpticAdapter"
 plate.Size = Vector3.new(.28,.075,.52)
 plate.Color = Color3.fromRGB(42,45,48)
 plate.Anchored = true
 plate.CanCollide = false
 plate.CanTouch = false
 plate.CanQuery = false
 plate.CFrame = CFrame.new(position + Vector3.new(0,.035,0))
 plate:SetAttribute("VisualAttachmentSlot","optic")
 plate:SetAttribute("VisualAttachmentId",opticId)
 plate.Parent = model
 return position + Vector3.new(0,.0725,0)
end

function Pilot.Mount(model, handle, id, configuration)
 local function mount(name, position)
  local point = handle:FindFirstChild(name) or Instance.new("Attachment", handle)
  point.Name = name
  point.Position = position
 end
 if id == "m1911" then
  local bullet = model:FindFirstChild("Bullets")
  if bullet then mount("magazine", bullet.Position) end
  return
 end
 if id == "ak_47" then
  local bullet = assert(model:FindFirstChild("Bullets"), "AK-47 magazine reference")
  mount("magazine", bullet.Position)
 end
 if stanagWells[id] then mount("magazine",stanagWells[id]) end
 local foregripContact=foregripContacts[id]
 if foregripContact then mount("underbarrel",foregripContact) end
 if id=="m4a1" or id=="m13" then
  local tube,stock=model:FindFirstChild("Buffer Tube"),model:FindFirstChild("Stock")
  if tube and stock then
   local front=Bounds({stock})
   mount("stock",Vector3.new(tube.Position.X,tube.Position.Y,front.Z))
  end
 end
 -- Local positions sampled on the matching weapon meshes in Studio.
 if id == "m4a1" then
  mount("optic", Vector3.new(0,1.039,-.9))
  mount("underbarrel", Vector3.new(0,.599,-2.4))
  return
 elseif id == "mp7" then
  mount("optic", addOpticPlate(model, Vector3.new(0,.743,-.43), configuration and configuration.optic))
  mount("underbarrel", Vector3.new(0,.216,-1.027))
  return
 elseif id == "mp5" then
  mount("optic", handle.optic.Position-Vector3.new(0,.013,0))
  mount("underbarrel", Vector3.new(0,.45,-2.35))
  return
 end
 local surfaces = rifles[id]
 if not surfaces then return end
 local rail = assert(model:FindFirstChild(surfaces[1]), id .. " optic surface")
 local _, top = Bounds({rail})
 local lowerRail
 if id == "grau_5_56" then
  lowerRail = rail
  for _,part in model:GetChildren() do
   if part:IsA("BasePart") and part.Name=="Rail" then
    local _,candidateTop = Bounds({part})
    if candidateTop.Y>top.Y then rail,top=part,candidateTop end
    if part.Position.Y<lowerRail.Position.Y then lowerRail=part end
   end
  end
 end
 local opticPosition = Vector3.new(0, Pilot.IsLegacy(id) and 1.078 or top.Y, rail.Position.Z)
 if not surfaces[1]:find("Rail") then
  opticPosition = addOpticPlate(model,opticPosition,configuration and configuration.optic)
 end
 mount("optic", opticPosition)
 if surfaces[2] and not foregripContact then
  local guard = lowerRail or assert(model:FindFirstChild(surfaces[2]), id .. " foregrip surface")
  local bottom = Bounds({guard})
  local z = id=="scar_h" and guard.Position.Z-guard.Size.X*.30 or guard.Position.Z
  mount("underbarrel", Vector3.new(0,id=="ak_47" and .499 or bottom.Y,z))
 end
 if Pilot.IsLegacy(id) then
  mount("muzzle", handle.Muzzle.Position)
  return
 end
 local barrel = assert(model:FindFirstChild("Barrel"), id .. " barrel")
 local tip = model:FindFirstChild("Muzzle") or model:FindFirstChild("Flash Hider") or barrel
 local front = Bounds({tip})
 local muzzle = Vector3.new(tip.Position.X,tip.Position.Y,front.Z)
 mount("Muzzle", muzzle)
 if id ~= "as_val" then mount("muzzle", muzzle) end
 if barrelWeapons[id] then
  local _, rear = Bounds({barrel})
  mount("barrel", Vector3.new(barrel.Position.X,barrel.Position.Y,rear.Z))
 end
end

return Pilot
