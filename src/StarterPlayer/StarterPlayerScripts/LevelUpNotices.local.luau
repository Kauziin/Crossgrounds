local player=game.Players.LocalPlayer
local Root=game.ReplicatedStorage.Crossgrounds
local Catalog=require(Root.WeaponCatalog)
local Theme=require(script.Parent:WaitForChild("AccentTheme"))
local gui=Instance.new("ScreenGui") gui.Name="LevelUpNotices" gui.ResetOnSpawn=false gui.IgnoreGuiInset=false gui.DisplayOrder=88 gui.Parent=player:WaitForChild("PlayerGui")
local card=Instance.new("Frame") card.Name="Notice" card.AnchorPoint=Vector2.new(.5,0) card.Position=UDim2.new(.5,0,0,72) card.Size=UDim2.new(.8,0,0,86) card.BackgroundColor3=Color3.fromRGB(10,17,24) card.BackgroundTransparency=.08 card.Visible=false card:SetAttribute("ThemePreserve",true) card.Parent=gui
local limit=Instance.new("UISizeConstraint") limit.MaxSize=Vector2.new(460,86) limit.Parent=card
Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
local edge=Instance.new("UIStroke") edge.Thickness=2 edge.Parent=card
local title=Instance.new("TextLabel") title.BackgroundTransparency=1 title.Position=UDim2.fromOffset(16,10) title.Size=UDim2.new(1,-32,0,24) title.Font=Enum.Font.GothamBold title.TextSize=15 title.TextColor3=Color3.new(1,1,1) title.Parent=card
local detail=title:Clone() detail.Name="Level" detail.Position=UDim2.fromOffset(16,37) detail.Size=UDim2.new(1,-32,0,35) detail.TextSize=20 detail.TextWrapped=true detail.Parent=card
local sound=Instance.new("Sound") sound.Name="LevelUpChime" sound.SoundId="rbxassetid://10066968815" sound.Parent=game:GetService("SoundService")
task.spawn(function()pcall(function()game:GetService("ContentProvider"):PreloadAsync({sound})end)end)
local queue={} local running=false
local function display()
 if running then return end running=true
 while #queue>0 do
  local message=table.remove(queue,1)
  if not player:GetAttribute("AdminCaptureClean") then
   local weapon=message.kind=="weapon" and Catalog.Get(message.weapon)
   local name=weapon and weapon.name or message.weapon
   local kits=require(game.ReplicatedStorage.KitDefinitions)
   if message.kind=="weapon" and kits.Weapons[message.weapon] then name=kits.Weapons[message.weapon].Name end
   edge.Color=Theme.Color() title.Text=message.kind=="account" and "PERSONAGEM · NOVO NÍVEL" or "ARMA · NOVO NÍVEL"
   detail.Text=(message.kind=="weapon" and (name.." · ") or "").."Nível "..message.level
   card.Visible=true
   sound:Stop() sound.PlaybackSpeed=message.kind=="account" and 1 or 1.12 sound.Volume=math.clamp(player:GetAttribute("SettingGameSFXVolume") or .5,0,1)*.65 sound:Play()
   task.wait(3.5) card.Visible=false task.wait(.15)
  end
 end
 running=false
end
Root:WaitForChild("Remotes"):WaitForChild("LevelUpNotice").OnClientEvent:Connect(function(message)
 if type(message)~="table" or not table.find({"account","weapon"},message.kind) or type(message.level)~="number" then return end
 -- Coalesce bursts for the same subject, preserving the highest confirmed level.
 for _,pending in queue do if pending.kind==message.kind and pending.weapon==message.weapon then pending.level=math.max(pending.level,message.level) return end end
 if #queue>=8 then table.remove(queue,1) end table.insert(queue,message) task.spawn(display)
end)
player:GetAttributeChangedSignal("SettingGameSFXVolume"):Connect(function()sound.Volume=math.clamp(player:GetAttribute("SettingGameSFXVolume") or .5,0,1)*.65 end)
