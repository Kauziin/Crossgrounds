local Players=game:GetService('Players') local player=Players.LocalPlayer local config=require(game.ReplicatedStorage.Crossgrounds.TesterConfiguration)
local labels=setmetatable({},{__mode='k'})
local function update(t)
 if not t.Parent then return end local tester
 for _,p in Players:GetPlayers() do if p:GetAttribute('CrossgroundsTester') and (t.Text==p.DisplayName or t.Text==p.Name) then tester=p break end end
 local icon=t:FindFirstChild('TesterAndroid')
 if not tester then if icon then icon.Visible=false end return end
 if not icon then icon=Instance.new('ImageLabel') icon.Name='TesterAndroid' icon.Image=config.Icon icon.ImageColor3=Color3.fromRGB(61,220,132) icon.BackgroundTransparency=1 icon.Size=UDim2.fromOffset(20,20) icon:SetAttribute('CascadeDecoration',true) icon.Parent=t end
 icon.Visible=true icon.ZIndex=t.ZIndex+1
 local x=t.TextXAlignment==Enum.TextXAlignment.Center and t.AbsoluteSize.X*.5-t.TextBounds.X*.5-23 or t.TextXAlignment==Enum.TextXAlignment.Right and t.AbsoluteSize.X-t.TextBounds.X-23 or -23
 icon.Position=UDim2.fromOffset(x,math.max(0,(t.AbsoluteSize.Y-20)*.5))
end
local function attach(t)
 if not t:IsA('TextLabel') or labels[t] then return end labels[t]=true
 local c={} for _,key in {'Text','TextBounds','AbsoluteSize'} do table.insert(c,t:GetPropertyChangedSignal(key):Connect(function() update(t) end)) end
 t.Destroying:Connect(function() for _,v in c do v:Disconnect() end end) task.defer(function() update(t) end)
end
local function refresh() for t in labels do update(t) end end
local function person(p) p:GetAttributeChangedSignal('CrossgroundsTester'):Connect(refresh) end
Players.PlayerAdded:Connect(person) for _,p in Players:GetPlayers() do person(p) end
for _,o in player.PlayerGui:GetDescendants() do attach(o) end player.PlayerGui.DescendantAdded:Connect(attach)