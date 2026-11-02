-- Cosmetic preferences only; never changes movement, hit detection or weapon timings.
local Motion={}
function Motion.Get(player,key,default)
 local value=player:GetAttribute("Setting"..key) if value==nil then return default end return value
end
function Motion.CharacterWeight(player) return Motion.Get(player,"SimpleAnimations",false) and .15 or 1 end
function Motion.WeaponWeight(player)
 return math.clamp(Motion.Get(player,"WeaponAnimationIntensity",1),0,1)*(Motion.Get(player,"SimpleAnimations",false) and .2 or 1)
end
function Motion.FOVAlpha(dt,speed,normalRate)
 return 1-math.exp(-math.clamp(dt,0,.1)*(normalRate or 12)*math.clamp(speed or 1,.15,1))
end
function Motion.WeaponProjection(worldFov,strength)
 strength=math.clamp(strength or 1,.75,1.25)
 -- Normal preserves the established 70-degree weapon camera. Other choices
 -- increase/reduce perspective, responding more strongly at wide world FOVs.
 local fov=math.clamp((70+(worldFov-70)*(strength-1))*strength,40,105)
 return fov,math.tan(math.rad(35))/math.tan(math.rad(fov*.5))
end
function Motion.Transform(cf,weight) return CFrame.identity:Lerp(cf,math.clamp(weight,0,1)) end
return Motion
