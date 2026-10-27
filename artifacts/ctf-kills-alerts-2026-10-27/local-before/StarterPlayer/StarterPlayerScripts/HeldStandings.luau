local Prestige=require(script.Parent:WaitForChild("PrestigeStyle"))
local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local player = Players.LocalPlayer
local Theme=require(script.Parent:WaitForChild("MenuTheme"))
local Table=require(script.Parent:WaitForChild("StatsTable"))
local remote = game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("Remotes"):WaitForChild("Standings")
local gui = Instance.new("ScreenGui")
gui.Name = "HeldStandings" gui.ResetOnSpawn = false gui.IgnoreGuiInset = true
gui.DisplayOrder = 85 gui.Enabled = false gui.Parent = player:WaitForChild("PlayerGui")
local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1,1) shade.BackgroundColor3 = Color3.fromRGB(2,9,15)
shade.BackgroundTransparency = .22 shade.Parent = gui
local panel = Instance.new("Frame")
panel.Name = "Scoreboard" panel.AnchorPoint = Vector2.new(.5,.5)
panel.Position = UDim2.fromScale(.5,.5) panel.Size = UDim2.fromOffset(710,560)
panel.BackgroundColor3 = Color3.fromRGB(15,30,44) panel.BorderSizePixel = 0 panel.Parent = shade
local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0,12) corner.Parent = panel
local scale = Instance.new("UIScale") scale.Parent = panel
local function label(parent,name,value,pos,size,fontSize)
 local t = Instance.new("TextLabel")
 t.Name = name t.Text = value t.Position = pos t.Size = size
 t.BackgroundTransparency = 1 t.TextColor3 = Color3.fromRGB(231,244,255)
 t.Font = Enum.Font.GothamMedium t.TextSize = fontSize or 16
 t.TextXAlignment = Enum.TextXAlignment.Left t.Parent = parent return t
end
local title = label(panel,"Title","PLACAR",UDim2.fromOffset(22,16),UDim2.fromOffset(600,40),28)
title.Font = Enum.Font.GothamBold
Theme.Surface(panel)
local list=Instance.new("ScrollingFrame") list.Name="Rows" list.Position=UDim2.fromOffset(20,74) list.Size=UDim2.new(1,-40,1,-100) list.BackgroundTransparency=1 list.BorderSizePixel=0 list.ScrollBarThickness=4 list.AutomaticCanvasSize=Enum.AutomaticSize.Y list.CanvasSize=UDim2.new() list.Parent=panel
local function columns(mode)
 return {{id="rank",label="POS.",width=.08},{id="name",label="JOGADOR",width=.44},{id="kills",label="ELIMS.",width=.16,align=Enum.TextXAlignment.Right},{id="deaths",label="MORTES",width=.16,align=Enum.TextXAlignment.Right},{id="score",label=mode=="ctf" and "CAPT." or "PONTOS",width=.16,align=Enum.TextXAlignment.Right}}
end
local board
local holding = false
local current = {mode = nil, entries = {}}
local function render()
 if board then board.Holder:Destroy() end
 local mode=player:GetAttribute("CrossgroundsMode")
 title.Text=mode=="ctf" and "PLACAR · CAPTURE A BANDEIRA" or mode=="arena" and "PLACAR · ARENA" or "JOGADORES · "..string.upper(mode or "")
 board=Table.new(list,"Statistics",columns(mode))
 for i,entry in ipairs(current.entries or {}) do
  local row=board:Add({rank="#"..(entry.rank or i),name=entry.name,kills=entry.kills,deaths=entry.deaths,score=entry.score},i)
  row.Frame.Size=UDim2.new(1,0,0,50)
  Prestige.Apply(row.Fields.name,entry.prestige)
  if entry.userId==player.UserId then row.Frame.BackgroundColor3=Theme.Colors.Selected row.Frame.BackgroundTransparency=.15 end
  row.Fields.rank.TextColor3=({Color3.fromRGB(244,205,109),Color3.fromRGB(204,217,231),Color3.fromRGB(208,155,111)})[i] or Theme.Colors.Muted
  local avatar=Instance.new("ImageLabel") avatar.Name="Avatar" avatar.BackgroundTransparency=1 avatar.Size=UDim2.fromOffset(32,32) avatar.Position=UDim2.new(.08,8,.5,-16) avatar.Image="rbxthumb://type=AvatarHeadShot&id="..entry.userId.."&w=100&h=100" avatar.Parent=row.Frame
  row.Fields.name.Position+=UDim2.fromOffset(40,0) row.Fields.name.Size-=UDim2.fromOffset(40,0)
 end
end
local function refresh()
 if Router:IsBlocked() then holding=false end
 local mode = player:GetAttribute("CrossgroundsMode")
 gui.Enabled = holding and (mode == "ctf" or mode == "arena" or mode == "get_out" or mode == "duels") and
  not player:GetAttribute("ExperienceMenuOpen") and
  not player:GetAttribute("ProgressionMenuOpen") and
  not player:GetAttribute("HUDLayoutEditing") and not player:GetAttribute("LobbyMusicMenuOpen")
end
remote.OnClientEvent:Connect(function(data)
 if type(data) ~= "table" then return end
 current = data
 if gui.Enabled then render() end
end)
local function action(_,state)
 if state == Enum.UserInputState.Begin then
  if Router:IsBlocked() then return Enum.ContextActionResult.Pass end
  holding = true render() refresh()
 elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
  holding = false refresh()
 end
 return Enum.ContextActionResult.Sink
end
CAS:BindActionAtPriority("CrossgroundsHeldStandings",action,false,3000,Enum.KeyCode.Tab,Enum.KeyCode.ButtonSelect)
for _, key in {"CrossgroundsMode","ExperienceMenuOpen","ProgressionMenuOpen","HUDLayoutEditing","LobbyMusicMenuOpen"} do
 player:GetAttributeChangedSignal(key):Connect(refresh)
end
local function resize()
 local v=workspace.CurrentCamera.ViewportSize
 scale.Scale=1 panel.Size=UDim2.fromOffset(math.min(920,v.X-24),math.min(560,v.Y-36))
 title.Size=UDim2.new(1,-44,0,38) title.TextSize=math.clamp(v.X/33,18,28)
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
Router.ContextChanged:Connect(refresh)
game:GetService("RunService").Heartbeat:Connect(function() if holding and Router:IsBlocked() then holding=false refresh() end end)
resize() refresh()
