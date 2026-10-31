-- Device eligibility is independent of target selection and shot authority.
local Intent={TouchTimeout=.1}
function Intent.Resolve(c)
 if c.focused==false or c.blocked then return Vector2.zero end
 local look=c.look or Vector2.zero
 if look.X~=look.X or look.Y~=look.Y or math.abs(look.X)==math.huge or math.abs(look.Y)==math.huge then return Vector2.zero end
 if c.device=="touch" then
  local age=(c.now or 0)-(c.touchAt or -math.huge)
  if not c.touchOwned or age<0 or age>Intent.TouchTimeout then return Vector2.zero end
 elseif c.device~="gamepad" then return Vector2.zero end
 return look.Magnitude>1 and look.Unit or look
end
function Intent.TouchLook(previous,radians,dt,owned,age)
 if not owned or age<0 or age>Intent.TouchTimeout then return Vector2.zero end
 if radians.Magnitude==0 then return previous or Vector2.zero end
 local look=Vector2.new(-radians.X,-radians.Y)/(math.max(dt,.001)*2.4)
 return look.Magnitude>1 and look.Unit or look
end
return table.freeze(Intent)
