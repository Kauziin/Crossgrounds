-- Shared, deterministic control policy. No services: safe to exercise in isolation.
local Policy={}
local combat={"ctf","arena"}
local world={"ctf","arena","survivor","hacking","beast","waiting","hub","admin"}
Policy.Contexts={
 Fire=combat,Aim=combat,Sprint=combat,Perspective=combat,SwitchWeapon=combat,ShiftLock=combat,Shoulder=combat,
 Jump=combat,ReloadInteract={"ctf","survivor","beast"},
 Menu={"ctf","arena","survivor","hacking","beast","waiting","hub","admin","menu"},
 KitMenu={"ctf"},VoteMenu={"ctf","arena"},Leave={"ctf","arena","survivor","hacking","beast","waiting"},
 AdminMode=world,AdminSpeedUp={"admin"},AdminSpeedDown={"admin"},AdminPreviousMap={"admin"},AdminNextMap={"admin"},AdminClean={"admin"},
 GetOutCrawl={"survivor"},GetOutAttack={"beast"},GetOutDrop={"beast"},GetOutCheck={"hacking"},GetOutHacker={"beast"},
 MenuPrevious={"menu"},MenuNext={"menu"},
}
function Policy.Context(s)
 if s.modal then return "menu" end
 if s.admin then return "admin" end
 if s.mode=="get_out" then
  if not s.alive or s.result and s.result~="active" then return "waiting" end
  if s.role=="beast" then return "beast" end
  if s.role=="survivor" then return s.hacking and "hacking" or "survivor" end
  return "waiting"
 end
 return s.mode
end
function Policy.Conflicts(a,b)
 if a=="Slide" and b=="Leave" or a=="Leave" and b=="Slide" then return false end
 local first,second=Policy.Contexts[a],Policy.Contexts[b]
 if not first or not second then return true end
 for _,context in first do if table.find(second,context) then return true end end
 return false
end
function Policy.Available(action,s)
 if s.suspended then return false,"suspended" end
 if action=="Slide" and not s.sprinting then return false,"not-sprinting" end
 if action=="Leave" and s.sprinting and (s.mode=="ctf" or s.mode=="arena") then return false,"sprinting" end
 local context=Policy.Context(s)
 if not table.find(Policy.Contexts[action] or {},context) then return false,"context:"..tostring(context) end
 if action:match("^Admin") and not s.authorized then return false,"permission" end
 if action=="Menu" and s.modal and not s.settingsMenu then return false,"another-menu" end
 if action=="AdminMode" and (s.inMatch or s.mode=="arena" and s.arenaPlaying) and not s.admin then return false,"in-match" end
 if action=="GetOutCrawl" and s.victim~="Active" and s.victim~="Crawling" then return false,"victim" end
 if action=="GetOutDrop" and not s.dragging then return false,"no-victim" end
 if context=="ctf" or context=="arena" then
  if action~="Menu" and action~="KitMenu" and action~="VoteMenu" and action~="Leave" and action~="AdminMode" then
   if not s.alive or s.spectating or context=="ctf" and not s.inMatch or context=="arena" and not s.arenaPlaying then return false,"inactive" end
  end
 end
 return true
end
function Policy.Resolve(actions,s)
 local winner
 for _,action in actions do
  if Policy.Available(action,s) and (not winner or Policy.Priority(action)>Policy.Priority(winner) or Policy.Priority(action)==Policy.Priority(winner) and action<winner) then winner=action end
 end
 return winner
end
function Policy.Priority(action)
 if action=="MenuPrevious" or action=="MenuNext" then return 800 end
 if action=="Menu" then return 700 end
 if action=="AdminMode" then return 600 end
 if action:match("^Admin") then return 500 end
 return 100
end
-- Reassign every overlapping action, then verify the entire graph before committing.
-- Incompatible legacy profiles fail without partially changing any binding.
function Policy.Plan(definitions,bindings,action,device,name)
 if not definitions.Actions[action] or not definitions:IsAllowed(device,name,action) then return nil,"invalid" end
 local plan=table.clone(bindings) local old=plan[action] plan[action]=name
 local affected={[action]=true}
 for other in definitions.Actions do
  if other~=action and Policy.Conflicts(action,other) and plan[other]==name then
   if not definitions:IsAllowed(device,old,other) then return nil,"reserved" end
   plan[other]=old affected[other]=true
  end
 end
 for first in definitions.Actions do
  for second in definitions.Actions do
   if first<second and (affected[first] or affected[second]) and plan[first]==plan[second] and Policy.Conflicts(first,second) then return nil,"conflict" end
  end
 end
 return plan
end
function Policy.Normalize(definitions,bindings,device)
 local result={} local order={}
 for action in definitions.Actions do table.insert(order,action) end
 table.sort(order,function(a,b) local x,y=Policy.Priority(a),Policy.Priority(b) return x==y and a<b or x>y end)
 local function free(action,key)
  if not definitions:IsAllowed(device,key,action) then return false end
  for other,value in result do if value==key and Policy.Conflicts(action,other) then return false end end
  return true
 end
 for _,action in order do
  local key=bindings[action]
  if not free(action,key) then
   local candidates={definitions.Actions[action][device]}
   if device=="Gamepad" then for _,value in definitions.GamepadKeys do table.insert(candidates,value) end
   else for _,value in {"F8","F9","F10","F11","F12","Z","X","C","B","N","H","J","U","I","O","P","T","Y","Equals","Minus","LeftBracket","RightBracket"} do table.insert(candidates,value) end end
   key=nil for _,candidate in candidates do if free(action,candidate) then key=candidate break end end
  end
  if not key then return nil,"no-free-binding:"..action end
  result[action]=key
 end
 return result
end
return Policy
