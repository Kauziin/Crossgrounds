local Players=game:GetService("Players") local player=Players.LocalPlayer
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local gui=Instance.new("ScreenGui") gui.Name="MatchStandings" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=44 gui.Parent=player.PlayerGui
local list=Instance.new("ScrollingFrame") list.Name="TopStandings" list.AnchorPoint=Vector2.new(.5,0) list.Position=UDim2.new(.5,0,0,12) list.Size=UDim2.new(.62,0,0,68) list.BackgroundTransparency=1 list.BorderSizePixel=0 list.ScrollBarThickness=2 list.AutomaticCanvasSize=Enum.AutomaticSize.X list.CanvasSize=UDim2.new() list.ScrollingDirection=Enum.ScrollingDirection.X list.Parent=gui
local layout=Instance.new("UIListLayout") layout.FillDirection=Enum.FillDirection.Horizontal layout.Padding=UDim.new(0,6) layout.Parent=list
local count=0
local function alignment() layout.HorizontalAlignment=count*138<=list.AbsoluteSize.X and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left end
local rows={} local colors={gold=Color3.fromRGB(255,206,85),silver=Color3.fromRGB(200,219,231),bronze=Color3.fromRGB(204,143,89),standard=Color3.fromRGB(113,144,162)}
local function row(index)
 local f=Instance.new("Frame") f.Name="Rank"..index f.BackgroundColor3=Color3.fromRGB(13,24,34) f.BackgroundTransparency=.15 f.BorderSizePixel=0 f.Size=UDim2.fromOffset(132,58) f.Parent=list
 local stroke=Instance.new("UIStroke") stroke.Thickness=1 stroke.Parent=f
 local portrait=Instance.new("ImageLabel") portrait.Name="Avatar" portrait.BackgroundTransparency=1 portrait.Size=UDim2.fromOffset(38,38) portrait.Position=UDim2.fromOffset(3,10) portrait.Parent=f
 local text=Instance.new("TextLabel") text.Name="Ranking" text.BackgroundTransparency=1 text.Position=UDim2.fromOffset(44,4) text.Size=UDim2.fromOffset(84,50) text.Font=Enum.Font.GothamBold text.TextColor3=Color3.new(1,1,1) text.TextSize=12 text.TextXAlignment=Enum.TextXAlignment.Left text.TextYAlignment=Enum.TextYAlignment.Center text.TextTruncate=Enum.TextTruncate.AtEnd text.Parent=f
 rows[index]={frame=f,stroke=stroke,portrait=portrait,text=text} return rows[index]
end
game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("Remotes"):WaitForChild("Standings").OnClientEvent:Connect(function(data)
 if typeof(data)~="table" or data.mode~="arena" then return end
 count=#(data.entries or {}) alignment()
 for i,entry in data.entries or {} do
  local r=rows[i] or row(i) r.frame.Visible=true r.frame.LayoutOrder=i r.stroke.Color=colors[entry.medal] or colors.standard
  r.text.Text="#"..entry.rank.."  "..entry.name.."\n"..entry.kills.." K  ·  "..entry.deaths.." D"
  r.portrait.Image=entry.userId>0 and ("rbxthumb://type=AvatarHeadShot&id="..entry.userId.."&w=100&h=100") or "rbxasset://textures/ui/GuiImagePlaceholder.png"
 end
 for i=#(data.entries or {})+1,#rows do rows[i].frame.Visible=false end
end)
local function refresh()
 gui.Enabled=Scope:IsArena() and not player:GetAttribute("ExperienceMenuOpen") and not player:GetAttribute("HUDLayoutEditing")
 local v=workspace.CurrentCamera.ViewportSize list.Size=UDim2.fromOffset(math.max(138,math.min(820,v.X-180)),64) alignment()
end
Scope.Changed:Connect(refresh) player:GetAttributeChangedSignal("ExperienceMenuOpen"):Connect(refresh) player:GetAttributeChangedSignal("HUDLayoutEditing"):Connect(refresh)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh) refresh()

