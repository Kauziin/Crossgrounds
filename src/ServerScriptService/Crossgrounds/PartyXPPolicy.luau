local XP={}
function XP.Boost(base,others,percent,remainder)
 if type(base)~="number" or base~=base or base<0 or base==math.huge then return 0,0 end
 base=math.floor(base) others=math.clamp(math.floor(others or 0),0,11) percent=math.clamp(math.floor(percent or 0),0,100)
 local numerator=base*others*percent+math.clamp(math.floor(remainder or 0),0,99)
 return base+math.floor(numerator/100),numerator%100
end
return XP
