-- Applied locally so the hub, CTF and other modes keep their own lighting.
local Profiles={}
Profiles.beach={
 ClockTime=10,Brightness=2,ExposureCompensation=0,
 Ambient=Color3.fromRGB(112,126,143),OutdoorAmbient=Color3.fromRGB(150,164,177),
 ColorShift_Top=Color3.fromRGB(14,9,2),ColorShift_Bottom=Color3.new(),
 EnvironmentDiffuseScale=.7,EnvironmentSpecularScale=.4,ShadowSoftness=.35,
 Atmosphere={Density=.22,Offset=.05,Color=Color3.fromRGB(211,231,250),Decay=Color3.fromRGB(122,146,174),Haze=.8,Glare=.05},
}
Profiles.assault={
 ClockTime=14,Brightness=2,ExposureCompensation=0,
 Ambient=Color3.fromRGB(105,115,135),OutdoorAmbient=Color3.fromRGB(137,147,163),
 ColorShift_Top=Color3.new(),ColorShift_Bottom=Color3.new(),
 EnvironmentDiffuseScale=.65,EnvironmentSpecularScale=.3,ShadowSoftness=.25,
 Atmosphere={Density=.2,Offset=.05,Color=Color3.fromRGB(206,220,238),Decay=Color3.fromRGB(124,138,158),Haze=1,Glare=.04},
}
Profiles.glacier={
 ClockTime=18,Brightness=1.4,ExposureCompensation=-.08,
 Ambient=Color3.fromRGB(82,91,120),OutdoorAmbient=Color3.fromRGB(106,117,145),
 ColorShift_Top=Color3.fromRGB(35,12,24),ColorShift_Bottom=Color3.fromRGB(3,7,18),
 EnvironmentDiffuseScale=.5,EnvironmentSpecularScale=.35,ShadowSoftness=.55,
 Atmosphere={Density=.28,Offset=.08,Color=Color3.fromRGB(205,171,190),Decay=Color3.fromRGB(88,105,145),Haze=1.4,Glare=.03},
}
return table.freeze(Profiles)
