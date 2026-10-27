-- Coordinates are normalized within ScreenInsets.DeviceSafeInsets.
local Layout={Order={"Fire","Aim","ReloadInteract","Jump","Sprint","SwitchWeapon","Perspective","ShiftLock","Shoulder"}}
Layout.Buttons={
 Fire={Label="DISPARO",Glyph="⊕",X=.88,Y=.52,Size=76,Opacity=.85},
 Aim={Label="MIRA",Glyph="◎",X=.73,Y=.47,Size=60,Opacity=.8},
 ReloadInteract={Label="RECARREGAR",Glyph="R",X=.72,Y=.70,Size=58,Opacity=.8},
 Jump={Label="PULAR",Glyph="↑",X=.90,Y=.79,Size=64,Opacity=.8},
 Sprint={Label="CORRER",Glyph="»",X=.25,Y=.60,Size=58,Opacity=.8},
 SwitchWeapon={Label="ARMA",Glyph="⇄",X=.58,Y=.82,Size=54,Opacity=.8},
 Perspective={Label="CÂMERA",Glyph="◉",X=.50,Y=.18,Size=48,Opacity=.7},
 ShiftLock={Label="TRAVA",Glyph="◇",X=.34,Y=.18,Size=48,Opacity=.7},
 Shoulder={Label="OMBRO",Glyph="↔",X=.66,Y=.18,Size=48,Opacity=.7},
}
 Layout.Buttons["AdminMode"]={Label="ADMIN",Glyph="A",X=0.120,Y=0.300,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminMode")
 Layout.Buttons["AdminClean"]={Label="LIMPAR",Glyph="2",X=0.240,Y=0.300,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminClean")
 Layout.Buttons["AdminPreviousMap"]={Label="MAPA −",Glyph="3",X=0.360,Y=0.300,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminPreviousMap")
 Layout.Buttons["AdminNextMap"]={Label="MAPA +",Glyph="4",X=0.480,Y=0.300,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminNextMap")
 Layout.Buttons["AdminSpeedDown"]={Label="VELOC. −",Glyph="13",X=0.720,Y=0.620,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminSpeedDown")
 Layout.Buttons["AdminSpeedUp"]={Label="VELOC. +",Glyph="14",X=0.840,Y=0.620,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminSpeedUp")
function Layout.Key(action,field) return "Touch"..action..field end
function Layout.Read(action,get)
 local d=Layout.Buttons[action] local r={}
 for _,field in {"X","Y","Size","Opacity"} do local v=get(Layout.Key(action,field)) r[field]=v==nil and d[field] or v end
 return r
end
function Layout.Pixels(layout,viewport)
 local diameter=math.clamp(math.min(viewport.X/900,viewport.Y/480),.72,1.5)*layout.Size
 local half=diameter*.5+8
 return Vector2.new(math.clamp(viewport.X*layout.X,half,math.max(half,viewport.X-half)),math.clamp(viewport.Y*layout.Y,half,math.max(half,viewport.Y-half))),diameter
end
return Layout

