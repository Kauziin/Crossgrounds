local Directory={}
local Players=game:GetService("Players")
local Career=require(script.Parent.CareerService)
local cursors,recent,rates={},{},{}
local session=function()return false end
function Directory.SetSession(callback)session=callback end
function Directory.InviteAllowed(target)
 local p=Career.Get(target)
 if Career.Enabled() and not p then return false,"Aguarde o perfil dessa pessoa carregar."end
 if p and p.social and p.social.invites=="none"then return false,"Essa pessoa desativou convites de grupo."end
 return true
end
local function validId(value)return type(value)=="number"and value==value and value%1==0 and math.abs(value)<2^53 end
local function preference(player)
 local p=Career.Get(player)
 return p and p.social or {favorites={},invites="friends",publicStats=true}
end
local function rows(player,list)
 local result={}local prefs=preference(player)
 for _,entry in list do
  local id=entry.Id or entry.userId
  if validId(id)then
   local live=Players:GetPlayerByUserId(id)
   table.insert(result,{userId=id,name=live and live.DisplayName or entry.DisplayName or entry.name or entry.Username or "Jogador",username=live and live.Name or entry.Username or entry.username or "",here=live~=nil,mode=live and live:GetAttribute("CrossgroundsMode"),online=live and true or entry.IsOnline,favorite=prefs.favorites[tostring(id)]==true,lastSeen=entry.lastSeen,public=live and Career.Public(live)})
  end
 end
 table.sort(result,function(a,b)if a.favorite~=b.favorite then return a.favorite end if a.here~=b.here then return a.here end return a.name:lower()<b.name:lower()end)
 return result
end
function Directory.Friends(player,action)
 if action~=nil and not table.find({"first","next","previous","refresh"},action)then return false,"Página inválida."end
 local current=cursors[player]
 if current and current.busy then return false,"Aguarde a consulta de amigos."end
 if not current or action=="refresh"or os.clock()-current.at>120 then
  if current and action=="refresh"and os.clock()-current.at<10 then return false,"Aguarde antes de consultar a lista novamente."end
  current={busy=true,at=os.clock(),index=1,cache={}}cursors[player]=current
  local ok,pages=pcall(function()return Players:GetFriendsAsync(player.UserId)end)
  current.busy=false
  if not player.Parent or cursors[player]~=current then return false,"Consulta interrompida."end
  if not ok then cursors[player]=nil return false,"Lista de amigos indisponível. Tente novamente."end
  current.pages=pages current.cache[1]=pages:GetCurrentPage() current.finished=pages.IsFinished
 else
  if action=="first"then current.index=1
  elseif action=="previous"then current.index=math.max(1,current.index-1)
  elseif action=="next"then
   if current.cache[current.index+1]then current.index+=1
   elseif not current.finished then
    current.busy=true local ok=pcall(function()current.pages:AdvanceToNextPageAsync()end)current.busy=false
    if not player.Parent or cursors[player]~=current then return false,"Consulta interrompida."end
    if not ok then return false,"Não foi possível abrir a próxima página."end
    current.index+=1 current.cache[current.index]=current.pages:GetCurrentPage()current.finished=current.pages.IsFinished
   end
  end
 end
 return true,{rows=rows(player,current.cache[current.index]or{}),page=current.index,hasPrevious=current.index>1,hasNext=current.cache[current.index+1]~=nil or not current.finished,at=os.time()}
end
function Directory.Recent(player)
 local list={}for _,entry in recent[player]or{}do table.insert(list,entry)end
 table.sort(list,function(a,b)return a.lastSeen>b.lastSeen end)
 local result=rows(player,list)
 table.sort(result,function(a,b)return a.lastSeen>b.lastSeen end)
 return {rows=result,sessionOnly=true}
end
function Directory.Profile(player,id)
 if not validId(id)then return false,"Jogador inválido."end
 local live=Players:GetPlayerByUserId(id) local name=live and live.DisplayName
 if not live then
  local observed=recent[player]and recent[player][id]
  local known
  local cursor=cursors[player]
  if cursor then for _,page in cursor.cache do for _,friend in page do if friend.Id==id then known=friend break end end if known then break end end end
  if not observed and not known then
   local ok,friends=pcall(function()return player:IsFriendsWithAsync(id)end)
   if not ok or not friends then return false,"Abra um amigo ou jogador encontrado nesta sessão."end
  end
  name=observed and observed.name or known and(known.DisplayName or known.Username)
  if not name then local ok,value=pcall(function()return Players:GetNameFromUserIdAsync(id)end)if ok then name=value end end
 end
 local data=Career.ReadPublic(id,name)
 return data~=nil,data or "Perfil de carreira indisponível neste momento."
end
function Directory.Command(player,action,payload)
 if action=="friends"then return Directory.Friends(player,payload)end
 if action=="recent"then return true,Directory.Recent(player)end
 if action=="players"then
  local list={}for _,p in Players:GetPlayers()do if p~=player then table.insert(list,{userId=p.UserId,name=p.DisplayName,username=p.Name})end end
  return true,{rows=rows(player,list)}
 end
 if action=="profile"then return Directory.Profile(player,payload)end
 if action=="preferences"then local p=preference(player)return true,{invites=p.invites,publicStats=p.publicStats}end
 if action=="invitePreference"and table.find({"friends","none"},payload)then
  return Career.Mutate(player,function(p)p.social=p.social or{favorites={},publicStats=true}p.social.invites=payload return true end)
 end
 if action=="statsPreference"and type(payload)=="boolean"then
  return Career.Mutate(player,function(p)p.social=p.social or{favorites={},invites="friends"}p.social.publicStats=payload return true end)
 end
 if action=="favorite"and type(payload)=="table"and validId(payload.userId)and type(payload.value)=="boolean"then
  local id=payload.userId if id==player.UserId then return false,"Escolha outra pessoa."end
  if payload.value then local ok,friends=pcall(function()return player:IsFriendsWithAsync(id)end)if not ok or not friends then return false,"Favoritos são amigos do Roblox."end end
  return Career.Mutate(player,function(p)
   p.social=p.social or{favorites={},invites="friends",publicStats=true}
   local count=0 for _ in p.social.favorites do count+=1 end
   local key=tostring(id)if payload.value and count>=50 and not p.social.favorites[key]then return false,"Limite de 50 favoritos."end
   p.social.favorites[key]=payload.value and true or nil return true
  end)
 end
 return false,"Ação social inválida."
end
function Directory.Start()
 if Directory.started then return end Directory.started=true
 local remotes=game.ReplicatedStorage.Crossgrounds:WaitForChild("Remotes")
 local remote=remotes:FindFirstChild("SocialCommand")or Instance.new("RemoteFunction")remote.Name="SocialCommand"remote.Parent=remotes
 remote.OnServerInvoke=function(player,action,payload)
  if type(action)~="string"then return false,"Ação inválida."end
  local budget=rates[player]or{}rates[player]=budget local now=os.clock()
  local interval=(action=="friends"or action=="profile")and 1 or .25
  if now-(budget[action]or-10)<interval then return false,"Aguarde um instante."end budget[action]=now
  return Directory.Command(player,action,payload)
 end
 Players.PlayerRemoving:Connect(function(p)cursors[p]=nil recent[p]=nil rates[p]=nil end)
 task.spawn(function()
  while true do task.wait(2)
   local groups={}
   for _,p in Players:GetPlayers()do local active,key=session(p,p:GetAttribute("CrossgroundsMode"))if active and key then groups[key]=groups[key]or{}table.insert(groups[key],p)end end
   for _,members in groups do for _,p in members do
    local list=recent[p]or{}recent[p]=list
    for _,other in members do if other~=p then list[other.UserId]={userId=other.UserId,name=other.DisplayName,username=other.Name,lastSeen=os.time()}end end
    local ordered={}for _,entry in list do table.insert(ordered,entry)end table.sort(ordered,function(a,b)return a.lastSeen>b.lastSeen end)
    for i=51,#ordered do list[ordered[i].userId]=nil end
   end end
  end
 end)
end
return Directory
