local Filter={}
function Filter.Radial(value,deadzone)
 deadzone=math.clamp(deadzone or 0,0,.4)
 local length=value.Magnitude
 if length<=deadzone or length<.00001 then return Vector2.zero end
 return value.Unit*math.clamp((length-deadzone)/(1-deadzone),0,1)
end
function Filter.Axis(value,deadzone)
 local clean=Filter.Radial(Vector2.new(value,0),deadzone) return clean.X
end
-- Radial S response preserves direction and the maximum turn rate.
function Filter.Dynamic(value,strength)
 local m=math.min(value.Magnitude,1) if m<.00001 then return Vector2.zero end
 local smooth=m*m*(3-2*m)
 return value.Unit*(m+(smooth-m)*math.clamp(strength or .65,0,1))
end
function Filter.Look(value,deadzone,curve,strength)
 local clean=Filter.Radial(value,deadzone)
 return curve==1 and Filter.Dynamic(clean,strength) or clean
end
function Filter.TouchRadians(delta,width,sensitivity,ads)
 return delta*(math.rad(240)/math.max(width,320))*sensitivity*(ads or 1)
end

-- Schmitt gate avoids flicker on the deadzone boundary; never retains a direction.
function Filter.Stick(state,value,deadzone)
 deadzone=math.clamp(deadzone or 0,0,.4)
 local length=value.Magnitude
 if length<=deadzone or length<.00001 then state.active=false return Vector2.zero end
 if not state.active and length<=deadzone+.015 then return Vector2.zero end
 state.active=true return Filter.Radial(value,deadzone)
end
return Filter
