local GameManager={}
local Config=require(game.ServerStorage.Configurations)
local Settings=require(script.SettingsService)
local Maps=require(script.MapManager)
local Voting=require(script.MapVotingService)
local Team=require(script.TeamManager)
local Player=require(script.PlayerManager)
local Time=require(script.TimeManager)
local Display=require(script.DisplayManager)
local Flags=require(script.FlagService)
local Bots=require(script.BotManager)
local MapLoadGate=require(game.ServerScriptService.Crossgrounds.MapLoadGate)
local SceneLoad=require(game.ServerScriptService.Crossgrounds.SceneLoadService)
local active=false local lastReconcile=0 local resultRecorded=false
local Events=game.ReplicatedStorage.Events
function GameManager:Initialize()
 workspace:SetAttribute("RoundState","Lobby")
 Maps:Initialize()
 Flags:Initialize()
end
function GameManager:RunIntermission()
 self.loadReady=false
 workspace:SetAttribute("RoundState","Lobby")
 Display:UpdateTimerInfo(true,true)
 while Player:GetJoinedCount()<Config.MIN_PLAYERS do task.wait(.5) end
 workspace:SetAttribute("RoundState","Countdown")
 Time:StartTimer(Config.INTERMISSION_DURATION)
 Voting:Begin(Config.INTERMISSION_DURATION)
 Display:UpdateTimerInfo(true,false)
 local untilTime=os.clock()+Config.INTERMISSION_DURATION
 while os.clock()<untilTime and Player:GetJoinedCount()>=Config.MIN_PLAYERS do task.wait(.2) end
 local winner=Voting:Finish(Player:GetJoinedCount()<Config.MIN_PLAYERS)
 if Player:GetJoinedCount()>=Config.MIN_PLAYERS then workspace:SetAttribute("RoundState","Loading")end
 if winner then local changed,err=Maps:Load(winner) if changed then Flags:Initialize() elseif err then warn("Mapa: "..err) end end
 if Player:GetJoinedCount()>=Config.MIN_PLAYERS then
  workspace:SetAttribute("RoundState","Loading")
  Time:StartTimer(MapLoadGate.Seconds)
  local safe,mapError=Maps:ValidateSpawns()
  if not safe then
   for _,p in game.Players:GetPlayers() do if p:GetAttribute("CrossgroundsMode")=="ctf" and p:GetAttribute("InMatch") then p:SetAttribute("SceneLoadingError",mapError) end end
  end
  self.loadReady=safe and SceneLoad:Wait(function()
   local list={}for _,p in game.Players:GetPlayers()do if p:GetAttribute("CrossgroundsMode")=="ctf"and p:GetAttribute("InMatch")then table.insert(list,p)end end return list
  end,Maps:SceneRoots(),Maps:SceneAnchors(),function()return Player:GetJoinedCount()>=Config.MIN_PLAYERS end,MapLoadGate.Seconds,true)
  if not self.loadReady and Player:GetJoinedCount()>=Config.MIN_PLAYERS then
   workspace:SetAttribute("RoundState","LoadFailed")
   local retry=workspace:GetAttribute("CTFLoadRetry") or 0
   repeat task.wait(.2) until Player:GetJoinedCount()<Config.MIN_PLAYERS or (workspace:GetAttribute("CTFLoadRetry") or 0)~=retry
  end
 end
end
function GameManager:GameReady() return self.loadReady==true and Player:GetJoinedCount()>=Config.MIN_PLAYERS end
function GameManager:StopIntermission() Display:UpdateTimerInfo(false,false) Display:StopIntermission() end
function GameManager:StartRound()
 Team:ClearTeamScores() Player:ClearPlayerScores()
 resultRecorded=false active=true workspace:SetAttribute("DevelopmentEndCTF",false) workspace:SetAttribute("RoundState","Playing")
 Player:SetGameRunning(true)
 Flags:StartRound() Player:LoadPlayers() Bots:StartRound()
 lastReconcile=os.clock() Time:StartTimer(Config.ROUND_DURATION)
end
function GameManager:Update()
 if os.clock()-lastReconcile>=.5 then Bots:Reconcile() lastReconcile=os.clock() end
end
local function recordResult(winner)
 if resultRecorded or not winner or winner=="Tie" then return end
 resultRecorded=true
 local progress=require(game.ServerScriptService.Crossgrounds.ProgressionService)
 for _,p in game.Players:GetPlayers() do
  if p:GetAttribute("CrossgroundsMode")=="ctf" and p:GetAttribute("InMatch") then
   progress.Result(p,"ctf",p.TeamColor==winner or p.Team==winner or (p.Team and p.Team.Name==tostring(winner)))
  end
 end
end
function GameManager:RoundOver()
 if game:GetService("RunService"):IsStudio() and workspace:GetAttribute("DevelopmentEndCTF") then return true end
 local winner=Team:HasTeamWon()
 if winner then recordResult(winner) Display:DisplayVictory(winner) return true end
 if Time:TimerDone() or Player:GetJoinedCount()==0 then
  local result=Team:AreTeamsTied() and "Tie" or Team:GetWinningTeam() recordResult(result) Display:DisplayVictory(result) return true
 end
 return false
end
function GameManager:RoundCleanup()
 active=false workspace:SetAttribute("RoundState","Results")
 Flags:StopRound() Bots:StopRound()
 Player:SetGameRunning(false) Player:SendToLobby()
 task.wait(Config.END_GAME_WAIT)
 Display:DisplayVictory(nil) Team:ClearTeamScores() Team:ShuffleTeams()
end
Events.CaptureFlag.Event:Connect(function(player,color)
 if not active then return end
 if player then Player:AddPlayerScore(player,1) end
 Team:AddTeamScore(color,1) Display:DisplayNotification(color,"Bandeira capturada!")
end)
Events.ReturnFlag.Event:Connect(function(color) if active then Display:DisplayNotification(color,"Bandeira devolvida!") end end)
return GameManager
