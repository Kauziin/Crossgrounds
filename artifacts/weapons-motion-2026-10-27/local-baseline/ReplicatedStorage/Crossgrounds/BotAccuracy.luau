local Accuracy={}
function Accuracy.Offset(rng,role,distance)
 local base=({Runner=.30,Soldier=.40,Guardian=.48})[role] or .35
 local chance=math.clamp(base-distance*.0011,.16,.48)
 if rng:NextNumber()<chance then return Vector2.new(rng:NextNumber(-.7,.7),rng:NextNumber(-.55,.6)),true end
 local radius=rng:NextNumber(3.2,6.2)+distance*.015
 local side=rng:NextNumber()<.5 and -1 or 1
 return Vector2.new(side*radius,rng:NextNumber(-1.7,2.2)),false
end
return Accuracy
