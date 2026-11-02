-- Shared cosmetic definitions. Theme ids are stable persisted preference values.
local Catalog={}
Catalog.Presets={
 {Name='Crossgrounds',Color=Color3.fromRGB(26,224,232)},
 {Name='Oceano',Color=Color3.fromRGB(50,183,255)},
 {Name='Safira',Color=Color3.fromRGB(93,143,255)},
 {Name='Índigo',Color=Color3.fromRGB(133,132,255)},
 {Name='Ametista',Color=Color3.fromRGB(179,126,255)},
 {Name='Lavanda',Color=Color3.fromRGB(202,170,255)},
 {Name='Orquídea',Color=Color3.fromRGB(231,121,244)},
 {Name='Rosa',Color=Color3.fromRGB(255,137,192)},
 {Name='Cereja',Color=Color3.fromRGB(255,100,132)},
 {Name='Coral',Color=Color3.fromRGB(255,143,124)},
 {Name='Laranja',Color=Color3.fromRGB(255,169,83)},
 {Name='Âmbar',Color=Color3.fromRGB(255,193,76)},
 {Name='Dourado',Color=Color3.fromRGB(240,213,117)},
 {Name='Lima',Color=Color3.fromRGB(184,225,94)},
 {Name='Esmeralda',Color=Color3.fromRGB(82,221,144)},
 {Name='Floresta',Color=Color3.fromRGB(100,190,135)},
 {Name='Menta',Color=Color3.fromRGB(126,238,202)},
 {Name='Petróleo',Color=Color3.fromRGB(68,187,184)},
 {Name='Gelo',Color=Color3.fromRGB(180,232,246)},
 {Name='Prata',Color=Color3.fromRGB(205,216,228)},
 {Name='Areia',Color=Color3.fromRGB(222,202,164)},
 {Name='Pêssego',Color=Color3.fromRGB(246,189,161)},
}
Catalog.Keys={'ThemePreset','AccentHue','AccentSaturation','AccentValue'}
function Catalog.IsProtected(key,value)
 return key=='AccentHue' or key=='AccentSaturation' or key=='AccentValue' or key=='ThemePreset' and value==0
end
function Catalog.CanEdit(key,value,owned)
 return not Catalog.IsProtected(key,value) or owned==true
end
function Catalog.Resolve(preset,hue,saturation,value,owned)
 if preset==0 and owned==true then return Color3.fromHSV(math.clamp(hue or 180,0,359)/360,math.clamp(saturation or .84,0,1),math.clamp(value or 1,0,1)) end
 local entry=Catalog.Presets[preset] or Catalog.Presets[1]
 return entry.Color
end
function Catalog.NearestHue(degrees)
 local best,distance=1,math.huge
 for i,p in Catalog.Presets do
  local h=p.Color:ToHSV() local d=math.abs(h*360-degrees)%360 d=math.min(d,360-d)
  if d<distance then best,distance=i,d end
 end
 return best
end
local function luminance(c)
 local function linear(x)return x<=.04045 and x/12.92 or ((x+.055)/1.055)^2.4 end
 return .2126*linear(c.R)+.7152*linear(c.G)+.0722*linear(c.B)
end
function Catalog.Contrast(a,b)
 local x,y=luminance(a),luminance(b) return (math.max(x,y)+.05)/(math.min(x,y)+.05)
end
function Catalog.Palette(raw,highContrast)
 local h,s=raw:ToHSV()
 local surface=Color3.fromHSV(h,s*.30,.065)
 local card=Color3.fromHSV(h,s*.36,.11)
 local accent=raw
 -- Custom black/dark colors retain their swatch while focus and labels stay legible.
 for _=1,12 do if Catalog.Contrast(accent,card)>=4.5 then break end accent=accent:Lerp(Color3.new(1,1,1),.14) end
 return {
  RawAccent=raw,Accent=accent,Focus=highContrast and Color3.new(1,1,1) or accent,
  Surface=surface,Card=card,Button=Color3.fromHSV(h,s*.30,.14),Selected=Color3.fromHSV(h,s*.55,.24),
  Text=Color3.fromRGB(243,248,250),Muted=Color3.fromHSV(h,s*.10,.77),Track=Color3.fromHSV(h,s*.22,.27),
  Border=Color3.fromHSV(h,s*.32,highContrast and .72 or .42),Glow=accent,
 }
end
function Catalog.Tint(base,raw)
 local h,s,v=base:ToHSV()
 if h<.43 or h>.72 or s<.045 or v<.015 then return base end
 local th,ts=raw:ToHSV()
 if v>.58 and s>.44 then return Catalog.Palette(raw).Accent end
 return Color3.fromHSV(th,math.min(.70,s)*ts,v)
end
return Catalog
