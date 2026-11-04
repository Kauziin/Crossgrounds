-- A shared, cancellable settling period after a server map load and before any round spawn.
local Gate={Seconds=5}

function Gate.Wait(canContinue,duration)
 local deadline=workspace:GetServerTimeNow()+(duration or Gate.Seconds)
 repeat
  if canContinue and not canContinue() then return false end
  local remaining=deadline-workspace:GetServerTimeNow()
  if remaining<=0 then break end
  task.wait(math.min(.2,remaining))
 until false
 return not canContinue or canContinue()
end

return Gate
