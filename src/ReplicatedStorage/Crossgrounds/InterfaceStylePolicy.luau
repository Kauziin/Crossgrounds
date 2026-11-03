-- Presentation only. Numeric IDs are persisted by the existing preference service.
local Style={}
Style.Choices={0,1}
Style.Labels={[0]='CLÁSSICA',[1]='NEO'}
function Style.Resolve(value)
 return value==1 and 1 or value==2 and 1 or 0
end
function Style.Metrics(value,technical)
 local id=Style.Resolve(value)
 if id==0 then return {Id=0,Width=technical and 1560 or 1280,Height=720,Gap=8,Title=22} end
 return {Id=id,Width=technical and 1840 or id==2 and 1760 or 1520,Height=technical and 940 or id==2 and 900 or 840,Gap=id==1 and 14 or 10,Title=technical and 26 or 32}
end
-- Lists and previews stay useful before stacking on narrow screens.
function Style.Arsenal(width,accessories,value)
 local modern=Style.Resolve(value)>0
 local right=modern and width>=780 and math.floor(width*.48) or width>=900 and math.clamp(width*(accessories and .33 or .29),270,380) or 0
 local side=accessories and 0 or width<650 and width or math.clamp(width*(modern and .17 or .22),150,240)
 return {Right=right,Side=side,Modern=modern}
end
return Style
