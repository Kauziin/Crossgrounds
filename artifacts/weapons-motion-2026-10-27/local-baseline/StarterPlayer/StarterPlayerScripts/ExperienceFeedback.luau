local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local SoundService=game:GetService("SoundService")
local player=Players.LocalPlayer
local Settings=require(game.ReplicatedStorage:WaitForChild("ExperienceSettings"))
local function setting(key) local v=player:GetAttribute("Setting"..key) if v==nil then return Settings.Rules[key].Default end return v end
local gui=Instance.new("ScreenGui") gui.Name="DamageFeedback" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=70 gui.Parent=player:WaitForChild("PlayerGui") gui.Enabled=Scope:IsCombat()
local tint=Instance.new("Frame") tint.Name="DamageTint" tint.Size=UDim2.fromScale(1,1) tint.BackgroundColor3=Color3.fromRGB(184,28,32) tint.BackgroundTransparency=1 tint.BorderSizePixel=0 tint.Parent=gui
local edges={}
for i,info in {{UDim2.fromScale(0,0),UDim2.fromScale(.18,1),0},{UDim2.fromScale(.82,0),UDim2.fromScale(.18,1),180},{UDim2.fromScale(0,0),UDim2.fromScale(1,.18),90},{UDim2.fromScale(0,.82),UDim2.fromScale(1,.18),270}} do
 local f=Instance.new("Frame") f.Name="Edge"..i f.Position=info[1] f.Size=info[2] f.BackgroundColor3=Color3.fromRGB(205,37,42) f.BackgroundTransparency=1 f.BorderSizePixel=0 f.Parent=gui
 local gradient=Instance.new("UIGradient") gradient.Rotation=info[3] gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}) gradient.Parent=f table.insert(edges,f)
end
local animations={}
local function flash(amount,maxHealth)
 if not Scope:IsCombat() then return end
 for _,t in animations do t:Cancel() end animations={}
 local strength=setting("DamageFlash") local impact=math.clamp(amount/math.max(maxHealth,1),0,1)
 tint.BackgroundTransparency=1-math.clamp((.03+impact*.18)*strength,.015,.18)
 table.insert(animations,Tween:Create(tint,TweenInfo.new(.48,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1}))
 for _,edge in edges do edge.BackgroundTransparency=1-math.clamp((.12+impact*.42)*strength,.04,.42) table.insert(animations,Tween:Create(edge,TweenInfo.new(.6,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1})) end
 for _,t in animations do t:Play() end
 player:SetAttribute("LastDamageFlash",workspace:GetServerTimeNow())
end
local healthConnection
local function characterAdded(c)
 if healthConnection then healthConnection:Disconnect() end
 tint.BackgroundTransparency=1 for _,e in edges do e.BackgroundTransparency=1 end
 local h=c:WaitForChild("Humanoid") local previous=h.Health
 healthConnection=h.HealthChanged:Connect(function(value)
  if value<previous then flash(previous-value,h.MaxHealth) end previous=value
 end)
end
player.CharacterAdded:Connect(characterAdded) if player.Character then task.spawn(characterAdded,player.Character) end
require(script.Parent:WaitForChild("LobbyPlaylist")):Start()

Scope.Changed:Connect(function()
 gui.Enabled=Scope:IsCombat()
 for _,t in animations do t:Cancel() end animations={}
 tint.BackgroundTransparency=1 for _,edge in edges do edge.BackgroundTransparency=1 end
end)

