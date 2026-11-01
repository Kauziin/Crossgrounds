from pathlib import Path
import shutil
root=Path('src'); backup=Path('artifacts/sights-2026-11-01/before')
paths=['ReplicatedStorage/ControlDefinitions','ReplicatedStorage/ControlPolicy','StarterPlayer/StarterPlayerScripts/ControlRouter','StarterPlayer/StarterPlayerScripts/CombatPresentation','ServerScriptService/Crossgrounds/ImportedWeaponVisuals','ServerScriptService/Crossgrounds/ShotAuthority','ReplicatedStorage/Crossgrounds/WeaponStats','StarterPlayer/StarterPlayerScripts/GunsmithView']
for path in paths:
 p=root/(path+'.luau'); dest=backup/(path+'.luau'); dest.parent.mkdir(parents=True,exist_ok=True)
 if dest.exists(): raise RuntimeError('One-shot patch already applied')
 shutil.copy2(p,dest)
 s=p.read_text(encoding='utf-8')
 if path.endswith('ControlDefinitions'):
  s=s.replace('Keyboard="Z",Gamepad="DPadLeft"','Keyboard="Z",Gamepad="ButtonL3"')
 if path.endswith('ControlPolicy'):
  s=s.replace('function Policy.Conflicts(a,b)','function Policy.Conflicts(a,b)\n if a=="SniperZoom" and b=="Sprint" or a=="Sprint" and b=="SniperZoom" then return false end')
 if path.endswith('ControlRouter'):
  s=s.replace('local key=Definition:Attribute(action,device)','local options=listeners[action]\n local inherited=options and options.overrides and options.overrides[device]\n if inherited then action=inherited end\n local key=Definition:Attribute(action,device)',1)
  s=s.replace('local x,y=Policy.Priority(a),Policy.Priority(b) return x==y', 'local x,y=Policy.Priority(a)+(listeners[a].overrides and 1000 or 0),Policy.Priority(b)+(listeners[b].overrides and 1000 or 0) return x==y')
 if path.endswith('CombatPresentation'):
  s=s.replace('local zoomLevel=1','local zoomLevel=1\nlocal SightDefinitions=require(game.ReplicatedStorage.Crossgrounds.SightDefinitions)\nlocal AttachmentEffects=require(game.ReplicatedStorage.Crossgrounds.AttachmentEffects)\nlocal opticalSight=require(script.Parent.OpticalSight).new(player)',1)
  s=s.replace('end,{scope="combat"})\nzoomButton','end,{scope="combat",enabled=canZoom,overrides={Gamepad="Sprint"}})\nzoomButton',1)
  s=s.replace(' zoomButton.Visible=false\n if not aiming',' opticalSight:Update(nil)\n zoomButton.Visible=false\n if not aiming',1)
  s=s.replace(' if tool~=currentTool then',' local sightProfile=aiming and SightDefinitions.Get(tool:GetAttribute("WeaponId"),tool:GetAttribute("OpticalAttachmentId")) or nil\n if sightProfile then firstPerson=true end\n if tool~=currentTool then',1)
  s=s.replace('data.Spread,tool:GetAttribute("ShotSeed")','AttachmentEffects.Spread(data,tool),tool:GetAttribute("ShotSeed")')
  s=s.replace('local profile=data.VisualRecoil or {Push=.08,Roll=.4}','local profile=AttachmentEffects.Recoil(data,tool)')
  s=s.replace('local recoilProfile=data.VisualRecoil or {}','local recoilProfile=AttachmentEffects.Recoil(data,tool)')
  s=s.replace('local scoped=aiming and SniperZoom.IsSniper(weaponId)','local scoped=sightProfile~=nil\n opticalSight:Update(sightProfile,camera.ViewportSize,Presentation:GetAimViewport())')
  s=s.replace('local fov=aiming and SniperZoom.FOV(baseFov,weaponId,zoomLevel)','local fov=aiming and (sightProfile and SightDefinitions.FOV(baseFov,sightProfile,zoomLevel) or SniperZoom.FOV(baseFov,weaponId,zoomLevel))')
  s=s.replace('if firstPerson and renderer then\n','if firstPerson and renderer then\n',1)
  s=s.replace(' elseif renderer then renderer:SetVisible(false) end',' elseif renderer then renderer:SetVisible(false) end\n if sightProfile and renderer then renderer:SetVisible(false) end')
  s=s.replace('t~=nil and SniperZoom.IsSniper(t:GetAttribute("WeaponId"))','t~=nil and SightDefinitions.Get(t:GetAttribute("WeaponId"),t:GetAttribute("OpticalAttachmentId"))~=nil')
 if path.endswith('ImportedWeaponVisuals'):
  s=s.replace('local Visuals={}','local AttachmentEffects=require(Root.AttachmentEffects)\nlocal Visuals={}')
  s=s.replace(' tool:SetAttribute("BurstConversion",',' local applied,why=AttachmentEffects.Apply(tool,id,configuration) if not applied then model:Destroy() return nil,why end\n tool:SetAttribute("OpticalAttachmentId",configuration and configuration.optic)\n tool:SetAttribute("BurstConversion",')
 if path.endswith('ShotAuthority'):
  s='local AttachmentEffects=require(game.ReplicatedStorage.Crossgrounds.AttachmentEffects)\n'+s
  s=s.replace('data.Spread,tool:GetAttribute("ShotSeed")','AttachmentEffects.Spread(data,tool),tool:GetAttribute("ShotSeed")')
 if path.endswith('WeaponStats'):
  s='local Effects=require(script.Parent.AttachmentEffects)\n'+s
  s=s.replace('function Stats.Get(id)','function Stats.Get(id,configuration)')
  s=s.replace('return {statsSchemaVersion=1,provisional=true,baseStats=table.clone(values),attachmentStatIntent={},effectiveGameplayStats=values,combatId=weapon.combatId}', 'local base=table.clone(values) local modifiers=Effects.Configuration(id,configuration or {})\n if modifiers then values.spreadDegrees=(values.spreadDegrees or 0)*modifiers.spread values.horizontalRecoilMultiplier=modifiers.horizontal end\n return {statsSchemaVersion=1,provisional=true,baseStats=base,attachmentStatIntent=modifiers or {},effectiveGameplayStats=values,combatId=weapon.combatId}')
 if path.endswith('GunsmithView'):
  s=s.replace('Stats.Get(id).baseStats','Stats.Get(id,configuration).effectiveGameplayStats')
  s=s.replace('Acessórios são visuais, exceto conversões de modo de disparo.','Commando: −40% dispersão, −15% recuo lateral. Silenciador: som abafado.')
  s=s.replace('Acessórios visuais: sem bônus. Conversão de rajada altera o disparo.','Commando reduz dispersão e recuo lateral; silenciador altera apenas som.')
 p.write_text(s,encoding='utf-8')
