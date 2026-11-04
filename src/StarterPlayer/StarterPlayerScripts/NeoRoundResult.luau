local Style = require(script.Parent.InterfaceStyle)
local Accent = require(script.Parent.AccentTheme)
local HUDStyle = require(game.ReplicatedStorage.Crossgrounds.HUDStyle)
local player = game.Players.LocalPlayer
local guiService = game:GetService("GuiService")

local Result = {}
Result.__index = Result

local function label(parent, name, y, height, size, font)
 local text = Instance.new("TextLabel")
 text.Name = name
 text.BackgroundTransparency = 1
 text.Position = UDim2.fromOffset(12, y)
 text.Size = UDim2.new(1, -24, 0, height)
 text.Font = font
 text.TextSize = size
 text.TextColor3 = Color3.fromRGB(237, 246, 251)
 text.TextTruncate = Enum.TextTruncate.AtEnd
 text.Parent = parent
 HUDStyle.Text(text)
 return text
end

function Result.new(gui, mode, legacy)
 local banner = Instance.new("Frame")
 banner.Name = "NeoRoundResult"
 banner.AnchorPoint = Vector2.new(.5, 0)
 banner.Position = UDim2.new(.5, 0, 0, 106)
 banner.Size = UDim2.new(1, -36, 0, 110)
 banner.BackgroundColor3 = Color3.fromRGB(8, 15, 22)
 banner.BorderSizePixel = 0
 banner.Visible = false
 banner.Parent = gui
 local bounds = Instance.new("UISizeConstraint", banner)
 bounds.MaxSize = Vector2.new(480, 110)
 local corner = Instance.new("UICorner", banner)
 corner.CornerRadius = UDim.new(0, 12)
 local edge = Instance.new("UIStroke", banner)
 edge.Transparency = .45
 Accent.Role(edge, "Color", "Accent")

 local eyebrow = label(banner, "Mode", 9, 18, 12, Enum.Font.GothamBold)
 eyebrow.Text = mode .. "  /  RESULTADO"
 Accent.Role(eyebrow, "TextColor3", "Accent")
 local title = label(banner, "Title", 29, 43, 24, Enum.Font.GothamBold)
 title.TextWrapped = true
 local titleSize = Instance.new("UITextSizeConstraint", title)
 titleSize.MinTextSize = 14
 titleSize.MaxTextSize = 24
 title.TextScaled = true
 local detail = label(banner, "Detail", 73, 26, 14, Enum.Font.GothamMedium)

 local view = setmetatable({Root = banner, Title = title, Detail = detail}, Result)
 function view:Refresh()
  local neo = Style.IsNova()
  local hasResult = self.Title.Text ~= ""
  local covered = player:GetAttribute("ExperienceMenuOpen") or player:GetAttribute("HUDLayoutEditing") or guiService.MenuIsOpen
  banner.Visible = neo and hasResult and not covered
  banner.BackgroundTransparency = player:GetAttribute("SettingHighContrast") and 0 or .2
  if legacy then legacy.Visible = not neo or not hasResult end
 end
 Style.Observe(banner, function() view:Refresh() end)
 local connections = {
  guiService.MenuOpened:Connect(function() view:Refresh() end),
  guiService.MenuClosed:Connect(function() view:Refresh() end),
 }
 for _, attribute in {"ExperienceMenuOpen", "HUDLayoutEditing", "SettingHighContrast"} do
  table.insert(connections, player:GetAttributeChangedSignal(attribute):Connect(function() view:Refresh() end))
 end
 banner.Destroying:Once(function()
  for _, connection in connections do connection:Disconnect() end
 end)
 view:Set(nil)
 return view
end

function Result:Set(title, detail)
 self.Title.Text = title or ""
 self.Detail.Text = detail or ""
 self:Refresh()
end

return Result
