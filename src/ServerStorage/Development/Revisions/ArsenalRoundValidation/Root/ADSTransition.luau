-- Shared reversible ADS timeline. Progress is owned by the weapon controller,
-- so releasing/re-entering ADS continues from the current pose without a snap.
local ADS={}
local function ramp(value,first,last)
 local t=math.clamp((value-first)/(last-first),0,1)
 return t*t*(3-2*t)
end
function ADS.Sample(progress,profile)
 local p=math.clamp(progress or 0,0,1)
 profile=profile or {}
 return {
  alignment=ramp(p,0,1),
  lens=ramp(p,profile.lensFadeStart or .35,profile.lensFadeEnd or .90),
  peripheral=ramp(p,.70,1),
  reticle=ramp(p,.78,1),
  arms=ramp(p,.60,1),
 }
end
function ADS.Pose(hip,aligned,progress) return hip:Lerp(aligned,ADS.Sample(progress).alignment) end
return ADS
