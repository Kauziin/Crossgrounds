-- Prototype slide tuning, shared by authority and presentation. No airborne boost.
local Movement={Duration=.72,Cooldown=1.25,MinSpeed=12,ExitSpeed=7}
function Movement.CanSlide(s)
 return (s.mode=="ctf" and s.playing or s.mode=="arena" and s.playing)==true
  and s.alive==true and s.grounded==true and s.sprinting==true
  and not s.blocked and (s.speed or 0)>=Movement.MinSpeed and (s.cooldown or 0)<=0
end
function Movement.Speed(initial,elapsed)
 local t=math.clamp(elapsed/Movement.Duration,0,1)
 return initial+(Movement.ExitSpeed-initial)*(t*(2-t))
end
return table.freeze(Movement)
