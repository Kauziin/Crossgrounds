-- Deliberately unavailable on published servers, including private servers.
local Dev={}
local Run=game:GetService("RunService")
function Dev:Start(coordinator,ctfRoot)
 if not Run:IsStudio() then return end
 workspace:SetAttribute("DevelopmentToolsAvailable",true)
 local remote=Instance.new("RemoteFunction") remote.Name="DevelopmentCommand" remote.Parent=game.ReplicatedStorage.Crossgrounds.Remotes
 local rates={} local busy=false
 remote.OnServerInvoke=function(player,action,payload)
  if not Run:IsStudio() or typeof(action)~="string" then return false,"Indisponível." end
  if os.clock()-(rates[player] or -10)<.2 then return false,"Aguarde um instante." end rates[player]=os.clock()
  if action=="botsDebug" and typeof(payload)=="boolean" then workspace:SetAttribute("BotDiagnosticsEnabled",payload) return true,"Diagnostico de bots: "..tostring(payload) end
  if action=="botsDifficulty" then
   local profiles=require(script.Parent.BotProfiles)
   if typeof(payload)~="string" or not profiles.Difficulties[payload] then return false,"Perfil invalido." end
   workspace:SetAttribute("BotDifficulty",payload) return true,"Perfil dos proximos bots: "..payload
  end
  if action=="botsSnapshot" then
   local snapshot=require(script.Parent.BotRuntime):Snapshot()
   workspace:SetAttribute("BotDiagnosticsSnapshot",game.HttpService:JSONEncode(snapshot))
   return true,string.format("Bots %d | CPU medio %.2f ms | rotas %d | fila %d",snapshot.active,snapshot.meanTickMs,snapshot.navigation.computations,snapshot.navigation.queued)
  end
  local mode=player:GetAttribute("CrossgroundsMode") local arena=coordinator.adapters.arena
  if action=="respawn" and (mode=="arena" or mode=="ctf") then player:LoadCharacterAsync() return true,"Personagem recriado." end
  if mode=="arena" and arena then
   if arena.phase=="loading" and table.find({"vote","map","restart"},action) then return false,"Aguarde o carregamento atual." end
   if action=="pause" and arena.phase=="playing" then
    if not arena.paused then arena.remaining=math.max(0,arena.endsAt-workspace:GetServerTimeNow()) arena.paused=true end
   elseif action=="resume" and arena.phase=="playing" then
    if arena.paused then arena.endsAt=workspace:GetServerTimeNow()+(arena.remaining or 0) arena.paused=false arena.remaining=nil end
   elseif action=="time" and arena.phase=="playing" then
    if typeof(payload)~="number" or payload~=payload or math.abs(payload)==math.huge then return false,"Tempo inválido." end
    payload=math.clamp(payload,1,3600)
    if arena.paused then arena.remaining=payload else arena.endsAt=workspace:GetServerTimeNow()+payload end
   elseif action=="vote" then
    if busy then return false,"Carregamento em andamento." end arena:BeginVote()
   elseif action=="map" or action=="restart" then
    local id=action=="restart" and arena.mapId or payload
    local valid=false for _,option in arena.maps:Catalog() do if option.id==id then valid=true break end end
    if not valid then return false,"Mapa não cadastrado." end
    if busy then return false,"Carregamento em andamento." end
    busy=true local ok,err=pcall(function() arena:StartMap(id) end) busy=false
    if not ok then warn(err) return false,"Falha ao carregar o mapa." end
   else return false,"Esta ação requer uma rodada ativa." end
   arena:Publish() return true,"Arena atualizada."
  elseif mode=="ctf" and coordinator.adapters.ctf then
   if workspace:GetAttribute("RoundState")~="Playing" then return false,"Aguarde a rodada CTF começar." end
   local time=require(ctfRoot.TimeManager)
   if action=="pause" then time:SetPaused(true)
   elseif action=="resume" then time:SetPaused(false)
   elseif action=="time" and typeof(payload)=="number" and payload==payload and math.abs(payload)<math.huge then time:SetRemaining(math.clamp(payload,1,3600))
   elseif action=="vote" or action=="restart" then workspace:SetAttribute("DevelopmentEndCTF",true)
   else return false,"CTF usa Travessia; mapas extras são da Arena." end
   return true,"CTF atualizado."
  end
  return false,"Entre em uma modalidade para usar estas ferramentas."
 end
 game.Players.PlayerRemoving:Connect(function(p) rates[p]=nil end)
end
return Dev
