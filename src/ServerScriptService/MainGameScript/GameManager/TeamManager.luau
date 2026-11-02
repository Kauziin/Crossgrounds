local TeamManager = {}

-- ROBLOX services
local Teams = game.Teams
local Players = game.Players

-- Game services
local Configurations = require(game.ServerStorage.Configurations)
local DisplayManager = require(script.Parent.DisplayManager)

-- Local variables

local TeamPlayers = {}
local TeamScores = {}
local reservations={}
local reservedBy={}
local AdmissionPolicy=require(game.ServerScriptService.Crossgrounds.TeamAdmissionPolicy)
local capacity=require(game.ReplicatedStorage.Crossgrounds.GameCatalog):Get("ctf").capacity.combatantsPerTeam
local function teamsOrdered()
 local teams=Teams:GetTeams() table.sort(teams,function(a,b)return a.Name<b.Name end) return teams
end
local function counts()
 local result={}
 for team,list in TeamPlayers do result[team]=#list end
 for _,plan in reservations do for player,team in plan do
  if not table.find(TeamPlayers[team],player) then result[team]=(result[team] or 0)+1 end
 end end
 return result
end

-- Initialization

for _, team in ipairs(Teams:GetTeams()) do
	TeamPlayers[team] = {}
	TeamScores[team] = 0
end

-- Local Functions

local function GetTeamFromColor(teamColor)
	for _, team in ipairs(Teams:GetTeams()) do
		if team.TeamColor == teamColor then
			return team
		end
	end
	return nil
end

-- Public Functions

function TeamManager:ClearTeamScores()
	for _, team in ipairs(Teams:GetTeams()) do
		TeamScores[team] = 0
		DisplayManager:UpdateScore(team, 0)
	end
end

function TeamManager:HasTeamWon()
	for _, team in ipairs(Teams:GetTeams()) do
		if TeamScores[team] >= Configurations.CAPS_TO_WIN then
			return team
		end
	end
	return false
end

function TeamManager:GetWinningTeam()
	local highestScore = 0
	local winningTeam = nil
	for _, team in ipairs(Teams:GetTeams()) do
		if TeamScores[team] > highestScore then
			highestScore = TeamScores[team]
			winningTeam = team
		end
	end
	return winningTeam
end

function TeamManager:AreTeamsTied()
	local teams = Teams:GetTeams()
	local highestScore = 0
	local tied = false
	for _, team in ipairs(teams) do
		if TeamScores[team] == highestScore then
			tied = true
		elseif TeamScores[team] > highestScore then
			tied = false
			highestScore = TeamScores[team]
		end
	end
	return tied
end

function TeamManager:AssignPlayerToTeam(player)
	for team,list in TeamPlayers do if table.find(list,player) then player.Neutral=false player.TeamColor=team.TeamColor return team end end
	local token=reservedBy[player]
	if token and reservations[token] and reservations[token][player] then
	 local team=reservations[token][player]
	 if #TeamPlayers[team]>=capacity then return nil end
	 table.insert(TeamPlayers[team],player) player.Neutral=false player.TeamColor=team.TeamColor return team
	end
	local smallestTeam
	local lowestCount = math.huge
	local occupied=counts()
	for team, playerList in pairs(TeamPlayers) do
		if occupied[team] < capacity and occupied[team] < lowestCount then
			smallestTeam = team
			lowestCount = occupied[team]
		end
	end
	if not smallestTeam then return nil end
	table.insert(TeamPlayers[smallestTeam], player)
	player.Neutral = false
	player.TeamColor = smallestTeam.TeamColor
	return smallestTeam
end

function TeamManager:ReservePlayers(players,sameTeam,token)
 if reservations[token] then return false,"Reserva já existente." end
 local seen={}
 for _,p in players do
  if seen[p] or reservedBy[p] then return false,"Um integrante já possui reserva." end seen[p]=true
  for _,list in TeamPlayers do if table.find(list,p) then return false,"Um integrante já está na partida." end end
 end
 local plan,reason=AdmissionPolicy.Plan(players,sameTeam,teamsOrdered(),counts(),capacity)
 if not plan then return false,reason end
 reservations[token]=plan for p in plan do reservedBy[p]=token end return true
end
function TeamManager:ReleaseReservation(token)
 local plan=reservations[token] if not plan then return end
 for p in plan do if reservedBy[p]==token then reservedBy[p]=nil end end reservations[token]=nil
end

function TeamManager:RemovePlayer(player)
	for _, teamTable in pairs(TeamPlayers) do
		for i = #teamTable, 1, -1 do
			if teamTable[i] == player then
				table.remove(teamTable, i)
			end
		end
	end
end

function TeamManager:ShuffleTeams()
 -- Preserve a reservation in progress instead of invalidating its assigned seats.
 if next(reservations) then return end
 local Party=require(game.ServerScriptService.Crossgrounds.PartyService)
 local players={} for _,p in Players:GetPlayers() do if p:GetAttribute("InMatch") then table.insert(players,p) end end
 local blocks,seen={},{}
 for _,p in players do
  if not seen[p] then
   local block={p} seen[p]=true local group=Party.Get(p)
   if group and group.sameTeam then for _,other in players do if not seen[other] and table.find(group.members,other.UserId) then table.insert(block,other) seen[other]=true end end end
   table.insert(blocks,block)
  end
 end
 table.sort(blocks,function(a,b)return #a>#b end)
 local teams=teamsOrdered()
 for i=#teams,2,-1 do local j=math.random(i) teams[i],teams[j]=teams[j],teams[i] end
 local plan=AdmissionPolicy.PlanBlocks(blocks,teams,capacity)
 -- Keep the previous valid assignment if whole groups cannot be repacked.
 if not plan then return end
 for _,team in teams do TeamPlayers[team]={} end
 for _,p in players do local team=plan[p] table.insert(TeamPlayers[team],p) p.Neutral=false p.TeamColor=team.TeamColor end
end

function TeamManager:AddTeamScore(teamColor, score)
	local team = GetTeamFromColor(teamColor)
	TeamScores[team] = TeamScores[team] + score
	DisplayManager:UpdateScore(team, TeamScores[team])
end

return TeamManager
