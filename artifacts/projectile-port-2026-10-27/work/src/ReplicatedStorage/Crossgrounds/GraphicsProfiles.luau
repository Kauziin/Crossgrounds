-- Local presentation presets. Map lighting and Roblox's own quality remain independent.
local Profiles={}
Profiles.Default=2
Profiles.List={
 {Name="Desempenho",Shadows=false,LightShadows=false,Bloom=0,Rays=0,Saturation=0,Contrast=0,MinQuality=1},
 {Name="Equilibrado",Shadows=true,LightShadows=false,Bloom=.06,Rays=0,Saturation=.015,Contrast=.015,MinQuality=2},
 {Name="Alto",Shadows=true,LightShadows=true,Bloom=.12,Rays=.02,Saturation=.035,Contrast=.025,MinQuality=3},
 {Name="Visual",Shadows=true,LightShadows=true,Bloom=.2,Rays=.035,Saturation=.05,Contrast=.035,MinQuality=4},
}
function Profiles.Get(value)
 return Profiles.List[value] or Profiles.List[Profiles.Default]
end
return Profiles
