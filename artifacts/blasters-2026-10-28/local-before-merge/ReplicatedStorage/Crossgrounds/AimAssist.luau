-- Input assistance only: no shot redirection, snap-to-target or head preference.
local Assist={}
Assist.Tuning=table.freeze({
 MaxRange=150,FrictionFadeStart=50,TrackingFadeStart=40,TrackingRange=100,
 NearStart=2,NearFull=12,Reaction=.09,Ramp=.10,PaddingHip=1.15,PaddingADS=.8,
 MaxSlowdown=.5,TrackingFraction=.60,MaxYawRate=90,MaxPitchRate=30,
})
local function smooth(a,b,value)
 local t=math.clamp((value-a)/math.max(.000001,b-a),0,1) return t*t*(3-2*t)
end
local function wrap(a) return (a+math.pi)%(2*math.pi)-math.pi end
local function angles(delta)
 return Vector2.new(math.atan2(-delta.X,-delta.Z),math.asin(math.clamp(delta.Unit.Y,-1,1)))
end
function Assist.Eligible(state)
 if state.health<=0 or state.allied or state.protected or not state.shooterActive then return false end
 if state.mode=="ctf" then return state.targetActive or state.targetBot or false end
 if state.mode=="arena" then return state.targetActive or state.targetTraining or false end
 return false
end
function Assist.Distance(distance)
 local t=Assist.Tuning
 local near=.45+.55*smooth(t.NearStart,t.NearFull,distance)
 return near*(1-smooth(t.FrictionFadeStart,t.MaxRange,distance)),near*(1-smooth(t.TrackingFadeStart,t.TrackingRange,distance))
end
function Assist.Window(origin,direction,candidate,aiming,range)
 if direction.Magnitude<.001 then return end
 local frame=candidate.frame or CFrame.new(candidate.point)
 local center=frame.Position local delta=center-origin local distance=delta.Magnitude
 if distance<1.25 or distance>math.min(range or Assist.Tuning.MaxRange,Assist.Tuning.MaxRange) then return end
 local unit=direction.Unit local along=delta:Dot(unit) if along<=0 then return end
 local size=candidate.size or Vector3.new(2.8,5,2)
 local half=size*.5
 local rayPoint=frame:PointToObjectSpace(origin+unit*along)
 local localPoint=Vector3.new(math.clamp(rayPoint.X,-half.X,half.X),math.clamp(rayPoint.Y,-half.Y,half.Y),math.clamp(rayPoint.Z,-half.Z,half.Z))
 local point=frame:PointToWorldSpace(localPoint)
 local edge=math.acos(math.clamp(unit:Dot((point-origin).Unit),-1,1))
 local padding=math.rad(aiming and Assist.Tuning.PaddingADS or Assist.Tuning.PaddingHip)
 if edge>padding then return end
 local error=angles(point-origin)-angles(unit) error=Vector2.new(wrap(error.X),error.Y)
 return {candidate=candidate,center=center,point=point,distance=distance,weight=1-smooth(0,padding,edge),edge=edge,error=error,onBody=edge<.0001}
end
function Assist.Select(origin,direction,candidates,visible,range,aiming,previous)
 local selected,best=nil,math.huge
 for _,candidate in candidates do
  local window=Assist.Window(origin,direction,candidate,aiming,range)
  if window then
   local centerAngle=math.acos(math.clamp(direction.Unit:Dot((window.center-origin).Unit),-1,1))
   local score=window.edge*4+centerAngle*.15
   if candidate.id==previous then score-=math.rad(.25) end
   if score<best and visible(candidate,origin,window.point) then selected=window best=score end
  end
 end
 return selected
end
function Assist.NewState() return {friction=1,age=0,velocity=Vector2.zero} end
function Assist.Reset(state)
 table.clear(state) state.friction=1 state.age=0 state.velocity=Vector2.zero
end
function Assist.Friction(state,window,context)
 local dt=context.dt local strength=math.clamp(context.strength or 0,0,1)
 local input=context.look or Vector2.zero
 local magnitude=math.min(1,input.Magnitude)
 local frictionRange,trackingRange=Assist.Distance(window.distance)
 local escape=1-.9*smooth(.7,1,magnitude)
 if window.error.Magnitude>.0001 and input.Magnitude>.025 and input.Unit:Dot(window.error.Unit)<-.1 then escape*=.15 end
 local slowdown=math.clamp(context.slowdown or 1,0,1)
 local goal=1-Assist.Tuning.MaxSlowdown*strength*slowdown*window.weight*frictionRange*escape
 local response=goal>state.friction and .025 or .055
 state.friction+=(goal-state.friction)*(1-math.exp(-dt/response))
 return state.friction,trackingRange,escape
end
function Assist.Step(state,window,context)
 local dt=context.dt or 0 local strength=math.clamp(context.strength or 0,0,1)
 if not window or strength<=0 or dt<=0 or dt>.075 then Assist.Reset(state) return 1,Vector2.zero end
 local input=context.look or Vector2.zero
 local magnitude=math.min(1,input.Magnitude)
 local friction,trackingRange,escape=Assist.Friction(state,window,context)
 -- Releasing intent cannot retain tracking velocity or acquisition time.
 if magnitude<=.025 then
  state.target=nil state.anchor=nil state.velocity=Vector2.zero state.age=0
  return friction,Vector2.zero
 end
 local origin=context.origin
 local same=state.target==window.candidate.id and state.anchor~=nil
 local previousOrigin,previousAnchor,previousCenter=state.origin,state.anchor,state.center
 state.target=window.candidate.id state.origin=origin state.anchor=window.point state.center=window.center
 if not same then state.age=0 state.velocity=Vector2.zero return state.friction,Vector2.zero end
 state.age+=dt
 local targetMove=window.center-previousCenter local selfMove=origin-previousOrigin
 if targetMove.Magnitude/dt>80 or selfMove.Magnitude/dt>110 then
  state.age=0 state.velocity=Vector2.zero return state.friction,Vector2.zero
 end
 -- Use translation of the last player-chosen body anchor. Manual look and rig rotation
 -- do not become target velocity, so they cannot create attraction to a body center.
 local before=previousAnchor-previousOrigin local after=previousAnchor+targetMove-origin
 if before.Magnitude<.1 or after.Magnitude<.1 then return state.friction,Vector2.zero end
 local a,b=angles(before),angles(after)
 local velocity=Vector2.new(wrap(b.X-a.X),b.Y-a.Y)/dt
 if velocity.Magnitude<.0001 then state.velocity=Vector2.zero return state.friction,Vector2.zero end

 if state.velocity:Dot(velocity)<0 then state.velocity=velocity
 else state.velocity=state.velocity:Lerp(velocity,1-math.exp(-dt/.065)) end
 if state.velocity.Magnitude<.0001 then return state.friction,Vector2.zero end
 local gate=0
 if magnitude>.025 then
  local alignment=math.max(0,input.Unit:Dot(state.velocity.Unit))
  gate=alignment*smooth(.025,.15,magnitude)

 end
 if state.age<Assist.Tuning.Reaction then return state.friction,Vector2.zero end
 local ramp=smooth(Assist.Tuning.Reaction,Assist.Tuning.Reaction+Assist.Tuning.Ramp,state.age)
 local gain=Assist.Tuning.TrackingFraction*strength*math.clamp(context.tracking or 1,0,1)*trackingRange*window.weight^2*gate*escape*ramp
 local delta=state.velocity*dt*gain
 local yawLimit=math.rad(Assist.Tuning.MaxYawRate)*strength*trackingRange*dt
 local pitchLimit=math.rad(Assist.Tuning.MaxPitchRate)*strength*trackingRange*dt

 -- Each axis yields immediately when the user lets go or looks the other way.
 local x=math.abs(input.X)>.025 and input.X*delta.X>0 and math.clamp(delta.X,-yawLimit,yawLimit) or 0
 local y=math.abs(input.Y)>.025 and input.Y*delta.Y>0 and math.clamp(delta.Y*.35,-pitchLimit,pitchLimit) or 0
 return state.friction,Vector2.new(x,y)
end
return Assist
