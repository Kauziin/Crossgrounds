-- Shared, deterministic shot geometry. Never applies damage.
local Shot={}
function Shot.Finite(v)
 return typeof(v)=="Vector3" and v.X==v.X and v.Y==v.Y and v.Z==v.Z and v.Magnitude<100000
end
function Shot.Config(data)
 return {kind=data.ShotType or "hitscan",range=math.clamp(data.Range or 220,.1,15000),
  speed=math.clamp(data.ProjectileSpeed or 1000,1,20000),lifetime=math.clamp(data.ProjectileLifetime or 5,.01,15),
  acceleration=(data.ProjectileAcceleration or Vector3.zero)+Vector3.new(0,-(data.ProjectileGravity or 0),0),
  radius=math.clamp(data.ProjectileRadius or 0,0,5),pellets=math.clamp(math.floor(data.ProjectilesPerShot or 1),1,16),
  visual=data.ShotVisual or {Speed=3000,Length=18,Width=.035}}
end
function Shot.Direction(direction,spread,seed,id,pellet,count)
 if not Shot.Finite(direction) or direction.Magnitude<.0001 then return end
 -- Stratified disc: all pellets cover the cone, with a shot-specific rotation.
 if (count or 1)>1 then
  local rng=Random.new(((seed or 1)+(id or 0)*7919)%2147483646+1)
  local angle=rng:NextNumber(0,math.pi*2)+(pellet-1)*2.3999632297
  local radius=math.sqrt((pellet-.5)/count)*math.tan(math.rad((spread or 0)*.5))
  return CFrame.lookAt(Vector3.zero,direction.Unit):VectorToWorldSpace(Vector3.new(math.cos(angle)*radius,math.sin(angle)*radius,-1).Unit)
 end
 local rng=Random.new(((seed or 1)+(id or 0)*7919+(pellet or 1)*104729)%2147483646+1)
 return (CFrame.lookAt(Vector3.zero,direction.Unit)*CFrame.Angles(math.rad(rng:NextNumber(-.5,.5)*(spread or 0)),math.rad(rng:NextNumber(-.5,.5)*(spread or 0)),0)).LookVector
end
return Shot
