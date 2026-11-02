-- Coordinates are normalized within ScreenInsets.DeviceSafeInsets.
local Layout={Order={"Fire","Aim","ReloadInteract","Jump","Slide","Sprint","SwitchWeapon","Perspective","ShiftLock","Shoulder"}}
Layout.Buttons={
 Fire={Label="DISPARO",Glyph="âŠ•",X=.88,Y=.52,Size=76,Opacity=.85},
 Aim={Label="MIRA",Glyph="â—Ž",X=.73,Y=.47,Size=60,Opacity=.8},
 ReloadInteract={Label="RECARREGAR",Glyph="R",X=.72,Y=.70,Size=58,Opacity=.8},
 Jump={Label="PULAR",Glyph="â†‘",X=.90,Y=.79,Size=64,Opacity=.8},
 Slide={Label="DESLIZAR",Glyph="â†˜",X=.80,Y=.85,Size=54,Opacity=.8},
 Sprint={Label="CORRER",Glyph="Â»",X=.25,Y=.60,Size=58,Opacity=.8},
 SwitchWeapon={Label="ARMA",Glyph="â‡„",X=.58,Y=.82,Size=54,Opacity=.8},
 Perspective={Label="CÃ‚MERA",Glyph="â—‰",X=.50,Y=.18,Size=48,Opacity=.7},
 ShiftLock={Label="TRAVA",Glyph="â—‡",X=.34,Y=.18,Size=48,Opacity=.7},
 Shoulder={Label="OMBRO",Glyph="â†”",X=.66,Y=.18,Size=48,Opacity=.7},
}
 Layout.Buttons["AdminMode"]={Label="ADMIN",Glyph="A",X=0.120,Y=0.300,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminMode")
 Layout.Buttons["AdminClean"]={Label="LIMPAR",Glyph="2",X=0.240,Y=0.300,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminClean")
 Layout.Buttons["AdminPreviousMap"]={Label="MAPA âˆ’",Glyph="3",X=0.360,Y=0.300,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminPreviousMap")
 Layout.Buttons["AdminNextMap"]={Label="MAPA +",Glyph="4",X=0.480,Y=0.300,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminNextMap")
 Layout.Buttons["AdminSpeedDown"]={Label="VELOC. âˆ’",Glyph="13",X=0.720,Y=0.620,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminSpeedDown")
 Layout.Buttons["AdminSpeedUp"]={Label="VELOC. +",Glyph="14",X=0.840,Y=0.620,Size=48,Opacity=.8,AdminOnly=true} table.insert(Layout.Order,"AdminSpeedUp")
-- Core combat controls remain available; secondary and admin shortcuts are optional.
for _,action in {'Slide','Sprint','Perspective','ShiftLock','Shoulder'} do Layout.Buttons[action].Optional=true end
for _,data in Layout.Buttons do if data.AdminOnly then data.Optional=true end if data.Optional then data.Visible=true end end
function Layout.Key(action,field) return "Touch"..action..field end
function Layout.Read(action,get)
 local d=Layout.Buttons[action] local r={}
 for _,field in {"X","Y","Size","Opacity"} do local v=get(Layout.Key(action,field)) r[field]=v==nil and d[field] or v end
 if d.Optional then local v=get(Layout.Key(action,"Visible")) r.Visible=v~=false end
 return r
end
function Layout.SafeBounds(viewport,safeX,safeY)
 local margin=Vector2.new(viewport.X*math.clamp(safeX or 0,0,.2),viewport.Y*math.clamp(safeY or 0,0,.2))
 return margin,viewport-margin*2
end
function Layout.ClampPoint(point,diameter,viewport,safeX,safeY)
 local margin=Layout.SafeBounds(viewport,safeX,safeY)
 local half=diameter*.5+2
 return Vector2.new(math.clamp(point.X,margin.X+half,math.max(margin.X+half,viewport.X-margin.X-half)),math.clamp(point.Y,margin.Y+half,math.max(margin.Y+half,viewport.Y-margin.Y-half)))
end
function Layout.NormalizePoint(point,viewport,safeX,safeY)
 local margin,size=Layout.SafeBounds(viewport,safeX,safeY)
 return Vector2.new(math.clamp((point.X-margin.X)/math.max(1,size.X),0,1),math.clamp((point.Y-margin.Y)/math.max(1,size.Y),0,1))
end
function Layout.Pixels(layout,viewport,safeX,safeY)
 local margin,usable=Layout.SafeBounds(viewport,safeX,safeY)
 local diameter=math.max(1,math.min(math.clamp(math.min(viewport.X/900,viewport.Y/480),.72,1.5)*layout.Size,usable.X-4,usable.Y-4))
 return Layout.ClampPoint(margin+Vector2.new(usable.X*layout.X,usable.Y*layout.Y),diameter,viewport,safeX,safeY),diameter
end
return Layout
