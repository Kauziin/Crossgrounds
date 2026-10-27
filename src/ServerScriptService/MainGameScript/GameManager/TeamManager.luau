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
	local smallestTeam
	local lowestCount = math.huge
	for team, playerList in pairs(TeamPlayers) do
		if #playerList < 6 and #playerList < lowestCount then
			smallestTeam = team
			lowestCount = #playerList
		end
	end
	if not smallestTeam then return nil end
	table.insert(TeamPlayers[smallestTeam], player)
	player.Neutral = false
	player.TeamColor = smallestTeam.TeamColor
	return smallestTeam
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
	for _, team in ipairs(Teams:GetTeams()) do
		TeamPlayers[team] = {}
	end
	local players = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player:GetAttribute('InMatch') then
			table.insert(players, player)
		end
	end
	while #players > 0 do
		local rIndex = math.random(1, #players)
		local player = table.remove(players, rIndex)
		TeamManager:AssignPlayerToTeam(player)
	end
end

function TeamManager:AddTeamScore(teamColor, score)
	local team = GetTeamFromColor(teamColor)
	TeamScores[team] = TeamScores[team] + score
	DisplayManager:UpdateScore(team, TeamScores[team])
end

return TeamManager
