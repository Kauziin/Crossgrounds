local R={}
local Players=game:GetService("Players")
local DSS=game:GetService("DataStoreService")
local studio=game:GetService("RunService"):IsStudio()
local S=require(game.ReplicatedStorage.Crossgrounds.ProgressionSchema)
local indexed,cache,names,rate,busy={},{},{},{},{}
local snapshot,friends
local personalCache={}
local function store(mode,metric) return DSS:GetOrderedDataStore("CG_Rank_v2_"..mode.."_"..metric) end
local function name(id)
 local online=Players:GetPlayerByUserId(id) if online then return online.DisplayName end
 if names[id] then return names[id] end
 local ok,value=pcall(function() return Players:GetNameFromUserIdAsync(id) end)
 if ok then names[id]=value end
 return ok and value or ("Jogador "..id)
end
local pendingIndexes={}
function R.Index(id,data)
 if studio or id<=0 or type(data)~="table" then return end
 -- Index only snapshots read from persistence, including discovered offline profiles.
 pendingIndexes[id]=table.clone(data)
 if busy[id] then return end
 busy[id]=true
 indexed[id]=indexed[id] or {}
 local scores=indexed[id]
 task.spawn(function()
  while pendingIndexes[id] do
   local current=pendingIndexes[id] pendingIndexes[id]=nil
   for _,mode in S.Modes do for _,metric in S.Metrics[mode] do
    local key=mode..metric local value=S.Value(current,mode,metric)
    if value>0 and scores[key]~=value then
     local ok,err=pcall(function() store(mode,metric):UpdateAsync(tostring(id),function(old) return math.max(old or 0,value) end) end)
     if ok then
      scores[key]=value
      -- An empty query made before indexing must not hide newly indexed scores.
      cache[key]=nil personalCache[key..":"..id]=nil
     else warn("Crossgrounds ranking index "..key.." / "..id..": "..tostring(err)) end
     task.wait(.1)
    end
   end end
  end
  busy[id]=nil
 end)
end
local function sort(rows)
 table.sort(rows,function(a,b) return a.value==b.value and a.userId<b.userId or a.value>b.value end)
 for i,row in rows do row.rank=i end
end
-- Fetch through the personal score (including ties), capped to protect budgets.
-- A bounded result never fabricates an exact personal position or prestige.
local function global(player,mode,metric)
 if studio then return {entries={},unavailable=true,complete=true,message="Ranking global exige servidor publicado. Dados de Studio não concedem prestígio."} end
 local key=mode..metric local cached=cache[key]
 if not cached or os.clock()-cached.at>120 then
  local pages=store(mode,metric):GetSortedAsync(false,100,1)
  local rows={} local complete=false
  repeat
   for _,entry in pages:GetCurrentPage() do
    local id=tonumber(entry.key) if id then table.insert(rows,{userId=id,value=entry.value}) end
   end
   if pages.IsFinished then complete=true break end
   if #rows>=1000 then break end
   pages:AdvanceToNextPageAsync()
  until false
  sort(rows)
  cached={at=os.clock(),rows=rows,complete=complete} cache[key]=cached
 end
 local entries={} local personal
 for i,row in cached.rows do
  if i<=100 then table.insert(entries,{rank=i,userId=row.userId,name=name(row.userId),value=row.value}) end
  if player and row.userId==player.UserId then personal={rank=i,value=row.value} end
 end
 -- At a truncated tied boundary no exact rank is claimed.
 if personal and not cached.complete and personal.value==cached.rows[#cached.rows].value then personal.rank=nil end
 if player and (not personal or not personal.rank) then
  local personalKey=key..":"..player.UserId local stored=personalCache[personalKey]
  if not stored or os.clock()-stored.at>120 then
   local score=store(mode,metric):GetAsync(tostring(player.UserId))
   if score and score>0 then
    local pages=store(mode,metric):GetSortedAsync(false,100,score) local position=1
    repeat
     for _,entry in pages:GetCurrentPage() do
      local id=tonumber(entry.key)
      if id and (entry.value>score or entry.value==score and id<player.UserId) then position+=1 end
     end
     if pages.IsFinished then break end
     task.wait(.1) pages:AdvanceToNextPageAsync()
    until false
    stored={at=os.clock(),rank=position,value=score} personalCache[personalKey]=stored
   end
  end
  if stored then personal={rank=stored.rank,value=stored.value} end
 end
 return {entries=entries,personal=personal,complete=cached.complete,at=cached.at,message=not cached.complete and "Top 100 · posição pessoal consultada separadamente · empates por ID." or "Top 100 · empates ordenados por ID.",verified=cached.complete or (#cached.rows>3 and cached.rows[3].value>cached.rows[#cached.rows].value)}
end
local function prestige()
 for mode,metric in S.Primary do
  local ok,data=pcall(global,nil,mode,metric)
  local ranks={}
  if ok and data.verified then for i=1,math.min(3,#data.entries) do ranks[data.entries[i].userId]=i end end
  for _,p in Players:GetPlayers() do p:SetAttribute("Prestige_"..mode,ranks[p.UserId]) end
  task.wait(.2)
 end
end
function R.Start(getSnapshot,getFriends)
 if R.started then return end R.started=true snapshot=getSnapshot friends=getFriends
 local remote=Instance.new("RemoteFunction") remote.Name="GetProgressRanking" remote.Parent=game.ReplicatedStorage.Crossgrounds.Remotes
 remote.OnServerInvoke=function(player,mode,metric,scope)
  if not S.Valid(mode,metric) or (scope~="global" and scope~="friends") then return nil,"Filtro inválido." end
  if busy[player] or os.clock()-(rate[player] or -100)<3 then return nil,"Aguarde antes de atualizar." end
  rate[player]=os.clock() busy[player]=true
  local ok,result=pcall(function()
   if scope=="global" then
    local data=global(player,mode,metric)
    if not data.personal then
     local own=snapshot(player)
     data.personal={value=own and S.Value(own,mode,metric) or 0,rank=nil,label=data.unavailable and "Indisponível no Studio" or "Ainda sem classificação"}
    end
    return data
   end
   local records,message=friends(player) local rows={}
   for _,data in records do table.insert(rows,{userId=data.userId,name=data.name,value=S.Value(data,mode,metric)}) end
   sort(rows) local personal
   for _,row in rows do if row.userId==player.UserId then personal={rank=row.rank,value=row.value} end end
   return {entries=rows,personal=personal,message=message or "Amigos com histórico · esta classificação não concede prestígio."}
  end)
  busy[player]=nil
  if not ok then return nil,"Ranking indisponível. Tente novamente em instantes." end
  return result
 end
 Players.PlayerRemoving:Connect(function(p) rate[p]=nil busy[p]=nil indexed[p.UserId]=nil for key in personalCache do if key:match(":"..p.UserId.."$") then personalCache[key]=nil end end end)
 task.spawn(function() while true do prestige() task.wait(180) end end)
end
return R
