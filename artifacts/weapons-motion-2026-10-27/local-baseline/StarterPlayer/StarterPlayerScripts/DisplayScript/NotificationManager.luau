local NotificationManager = {}

-- Local Variables
local ScoreFrame = script.Parent.ScreenGui.ScoreFrame
local VictoryFrame = script.Parent.ScreenGui.VictoryMessage
local Events = game.ReplicatedStorage.Events
local DisplayNotification = Events.DisplayNotification
local DisplayVictory = Events.DisplayVictory
local DisplayScore = Events.DisplayScore
local ResetMouseIcon = Events.ResetMouseIcon
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local MouseIcon = Mouse.Icon

-- Local Functions
local function OnDisplayNotification(teamColor, message)
	local notificationFrame = ScoreFrame[tostring(teamColor)].Notification
	notificationFrame.Text = message
	notificationFrame:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad, .25, false)
	wait(1.5)
	notificationFrame:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad, .1, false)
end

local function OnScoreChange(team, score)
	ScoreFrame[tostring(team.TeamColor)].Text = score
end

local function OnDisplayVictory(winningTeam)
	if winningTeam then
		VictoryFrame.Visible = true
		if winningTeam == 'Tie' then
			VictoryFrame.Tie.Visible = true
		else
			VictoryFrame.Win.Visible = true
			local WinningFrame = VictoryFrame.Win[winningTeam.Name]
			WinningFrame.Visible = true
		end
	else
		VictoryFrame.Visible = false
		VictoryFrame.Win.Visible = false
		VictoryFrame.Win.Red.Visible = false
		VictoryFrame.Win.Blue.Visible = false
		VictoryFrame.Tie.Visible = false
	end
end

local function OnResetMouseIcon()
	Mouse.Icon = MouseIcon
end

-- Event Bindings
DisplayNotification.OnClientEvent:connect(OnDisplayNotification)
DisplayVictory.OnClientEvent:connect(OnDisplayVictory)
DisplayScore.OnClientEvent:connect(OnScoreChange)
ResetMouseIcon.OnClientEvent:connect(OnResetMouseIcon)

return NotificationManager
