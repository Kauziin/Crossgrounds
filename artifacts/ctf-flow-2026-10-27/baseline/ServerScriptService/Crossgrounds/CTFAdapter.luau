local Adapter={}
Adapter.__index=Adapter
function Adapter.new(moduleRoot,context)
 return setmetatable({id="ctf",version="0.1.0",state="prototype",context=context,manager=require(moduleRoot),players=require(moduleRoot.PlayerManager),flags=require(moduleRoot.FlagService),bots=require(moduleRoot.BotManager),voting=require(moduleRoot.MapVotingService),damage=require(moduleRoot.DamageService),started=false},Adapter)
end
function Adapter:IsAvailable()
 return not self.failure and workspace:FindFirstChild("CTFInfrastructure")~=nil and workspace:FindFirstChild("CTFLobby")~=nil
end
function Adapter:Start()
 if self.started then return end self.started=true
 self.manager:Initialize()
 workspace:SetAttribute("CTFRoundLoopCount",(workspace:GetAttribute("CTFRoundLoopCount") or 0)+1)
 self.thread=task.spawn(function()
  local ok,err=xpcall(function()
   while self.started do
    repeat self.manager:RunIntermission() until self.manager:GameReady()
    self.manager:StopIntermission() self.manager:StartRound()
    repeat self.manager:Update() task.wait() until self.manager:RoundOver()
    self.manager:RoundCleanup()
   end
  end,debug.traceback)
  if not ok then self.failure=tostring(err) workspace:SetAttribute("CTFRuntimeError",self.failure) warn(self.failure) end
 end)
end
local function waitReady(player,context,mode)
 local deadline=os.clock()+12
 repeat
  if not player.Parent or context:GetMode(player)~=mode then return false,"A entrada foi interrompida." end
  if player:GetAttribute("ModeCharacterReady") then return true end
  task.wait(.05)
 until os.clock()>deadline
 return false,"O personagem não ficou pronto. Tente novamente."
end
function Adapter:Enter(player)
 if not self:IsAvailable() then return false,"Protótipo CTF indisponível." end
 self.context:SetMode(player,"ctf") self.players:Spawn(player)
 return waitReady(player,self.context,"ctf")
end
function Adapter:Leave(player)
 local character=player.Character
 if character then self.flags:DropCarrier(character) self.damage:Unwatch(character) end
 self.voting:RemovePlayer(player)
 self.players:LeaveMatch(player)
 self.context:SetMode(player,"hub")
 self.players:Spawn(player)
 return waitReady(player,self.context,"hub")
end
function Adapter:Snapshot(player)
 local round=workspace:GetAttribute("RoundState") or "Lobby"
 local phase=player:GetAttribute("InArena") and "playing" or player:GetAttribute("InMatch") and "ready" or "preparation"
 if round=="Results" and player:GetAttribute("InMatch") then phase="results" end
 if not player:GetAttribute("ModeCharacterReady") then phase="preparing" end
 return {id=self.id,version=self.version,state=phase,round=round,inMatch=player:GetAttribute("InMatch")==true,inArena=player:GetAttribute("InArena")==true,map=workspace:GetAttribute("CurrentMapId") or "riverside"}
end
return Adapter
