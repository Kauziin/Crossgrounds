local Travel={}
Travel.__index=Travel
function Travel.new(config,deps)
 deps=deps or {}
 local self=setmetatable({config=config,pending={},verified=nil,alive=true},Travel)
 self.placeId=deps.PlaceId or game.PlaceId self.universeId=deps.UniverseId or game.GameId
 self.isStudio=deps.IsStudio or function() return game:GetService("RunService"):IsStudio() end
 self.fetchPlaces=deps.FetchPlaces or function()
  local ids={} local pages=game:GetService("AssetService"):GetGamePlacesAsync()
  for _=1,100 do
   for _,p in pages:GetCurrentPage() do ids[p.PlaceId]=true end
   if pages.IsFinished then return ids end pages:AdvanceToNextPageAsync()
  end
  error("Catálogo de Places excedeu o limite de consulta.")
 end
 self.teleport=deps.Teleport or function(id,players,options) return game:GetService("TeleportService"):TeleportAsync(id,players,options) end
 self.schedule=deps.Schedule or function(seconds,callback) task.delay(seconds,callback) end
 local signal=deps.FailureSignal or game:GetService("TeleportService").TeleportInitFailed
 self.connection=signal:Connect(function(player,_,_,placeId)
  local pending=self.pending[player]
  if pending and pending.placeId==placeId then self.pending[player]=nil pending.fail("O Roblox não concluiu a viagem. Você permanece no servidor atual.") end
 end)
 return self
end
function Travel:Verify(destination)
 if not self.config.TeleportEnabled then return false,"Viagens entre Places ainda não foram habilitadas." end
 if typeof(destination)~="number" or destination%1~=0 or destination<=0 or destination==math.huge then return false,"Place de destino não configurado." end
 if not self.config.ApprovedUniverseId or self.config.ApprovedUniverseId~=self.universeId or self.universeId<=0 then return false,"Universe de destino ainda não foi confirmado." end
 if destination==self.placeId then return false,"A rota entre Places não pode apontar para o próprio Place." end
 if not self.verified then
  local ok,ids=pcall(self.fetchPlaces)
  if not ok then return false,"Não foi possível verificar os Places desta experiência." end
  self.verified=ids
 end
 if not self.verified[destination] then return false,"O destino não pertence ao catálogo confirmado desta experiência." end
 return true
end
function Travel:Route(gameId,localAvailable)
 if gameId=="ctf" and self.config.PlaceRole=="combinedPrototype" and self.config.EnableLocalCTFPrototype and localAvailable then return {kind="local",gameId=gameId} end
 if gameId=="arena" and self.config.PlaceRole=="combinedPrototype" and self.config.EnableLocalArenaPrototype and localAvailable then return {kind="local",gameId="arena"} end
 if gameId=="get_out" and self.config.PlaceRole=="combinedPrototype" and self.config.EnableLocalGetOutPrototype and localAvailable then return {kind="local",gameId="get_out"} end
 if gameId=="hub" and self.config.PlaceRole=="combinedPrototype" then return {kind="local",gameId="hub"} end
 local destination=gameId=="ctf" and self.config.CTFPlaceId or gameId=="arena" and self.config.ArenaPlaceId or gameId=="hub" and self.config.HubPlaceId
 local ok,reason=self:Verify(destination)
 if not ok then return nil,reason end
 if self.isStudio() then return nil,"Teleporte real indisponível no Studio. Configure e teste somente após publicação privada autorizada." end
 return {kind="teleport",gameId=gameId,placeId=destination}
end
function Travel:Begin(player,route,onFailure)
 if self.pending[player] then return false,"Já existe uma viagem em andamento." end
 local ok,reason=self:Verify(route.placeId) if not ok then return false,reason end
 if self.isStudio() then return false,"O Studio não executa teleporte real." end
 local options=Instance.new("TeleportOptions")
 options:SetTeleportData({crossgroundsVersion=1,requestedMode=route.gameId,sourcePlaceId=self.placeId})
 -- Arrival data is informational only. The destination's server configuration chooses its role.
 local token={} self.pending[player]={placeId=route.placeId,fail=onFailure,token=token}
 local sent,err=pcall(self.teleport,route.placeId,{player},options)
 options:Destroy()
 if not sent then self.pending[player]=nil return false,"Não foi possível iniciar a viagem. Você permanece no servidor atual." end
 self.schedule(30,function()
  local current=self.pending[player]
  if self.alive and current and current.token==token and player.Parent then self.pending[player]=nil current.fail("A viagem não foi confirmada. Você permanece no servidor atual.") end
 end)
 return true
end
function Travel:Forget(player) self.pending[player]=nil end
function Travel:Destroy() self.alive=false if self.connection then self.connection:Disconnect() end table.clear(self.pending) end
return Travel

