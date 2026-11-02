local Config=require(script.Parent.WeaponVisualConfiguration)
local Attachments=require(script.Parent.AttachmentCatalog)
local Effects={}
function Effects.Configuration(id,configuration)
 local clean,err=Config.Validate(id,configuration or {},true)
 if not clean then return nil,err end
 local suppressed=false local noise=1
 for _,attachmentId in clean do local a=Attachments[attachmentId] if a.suppressed then suppressed=true noise=math.min(noise,a.noiseMultiplier or 1) end end
 return {noise=noise,spread=clean.underbarrel=="foregrips_commando_foregrip" and .6 or 1,horizontal=clean.underbarrel=="foregrips_commando_foregrip" and .85 or 1,suppressed=suppressed}
end
-- Combat data is already resolved once by WeaponStats on both peers.
function Effects.Spread(data,tool) return data.Spread or 0 end
function Effects.Recoil(data,tool)
 local p=table.clone(data.VisualRecoil or {Push=.08,Roll=.4})
 return p
end
function Effects.Apply(tool,id,configuration)
 local m,err=Effects.Configuration(id,configuration) if not m then return nil,err end
 tool:SetAttribute("Suppressed",m.suppressed) tool:SetAttribute("ShotNoiseMultiplier",m.noise)
 tool:SetAttribute("AttachmentSpreadMultiplier",m.spread) tool:SetAttribute("AttachmentHorizontalMultiplier",m.horizontal)
 local sound=tool:FindFirstChild("Handle") and tool.Handle:FindFirstChild("FireSound")
 if sound then
  local base=sound:GetAttribute("UnsuppressedVolume") or sound.Volume sound:SetAttribute("UnsuppressedVolume",base)
  sound.Volume=base*(m.suppressed and .6 or 1)
  local eq=sound:FindFirstChild("SuppressorEQ") if eq then eq:Destroy() end
  if m.suppressed then eq=Instance.new("EqualizerSoundEffect") eq.Name="SuppressorEQ" eq.HighGain=-20 eq.MidGain=-8 eq.LowGain=-3 eq.Parent=sound end
 end
 return tool
end
return Effects
