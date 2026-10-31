-- Prestige attributes are published by the server from verified mode rankings.
local Players=game:GetService("Players")
local localPlayer=Players.LocalPlayer
local Style=require(script.Parent:WaitForChild("PrestigeStyle"))
local records={}
local function update(p)
 local record=records[p] if not record then return end
 if record.gui then record.gui:Destroy() record.gui=nil end
 if record.humanoid and record.previous then record.humanoid.DisplayDistanceType=record.previous record.previous=nil end
 local mode=localPlayer:GetAttribute("CrossgroundsMode")
 local rank=mode and p:GetAttribute("Prestige_"..mode)
 if not rank or p:GetAttribute("CrossgroundsMode")~=mode or mode=="hub" then return end
 local char=p.Character local head=char and char:FindFirstChild("Head") local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not head or not hum then return end
 record.humanoid=hum record.previous=hum.DisplayDistanceType hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
 local gui=Instance.new("BillboardGui") gui.Name="ModeLeaderPrestige" gui.Adornee=head gui.Size=UDim2.fromOffset(200,32) gui.StudsOffsetWorldSpace=Vector3.new(0,2,0) gui.MaxDistance=65 gui.AlwaysOnTop=false gui.Parent=char record.gui=gui
 local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=1 label.Font=Enum.Font.GothamBold label.TextSize=14 label.TextStrokeTransparency=.45 label.Text=p.DisplayName label.Parent=gui Style.Apply(label,rank)
end
local function add(p)
 if records[p] then return end
 local r={connections={}} records[p]=r
 table.insert(r.connections,p.CharacterAdded:Connect(function(char) char:WaitForChild("Head",10) update(p) end))
 table.insert(r.connections,p.AttributeChanged:Connect(function(key) if key=="CrossgroundsMode" or key:sub(1,9)=="Prestige_" then update(p) end end))
 update(p)
end
Players.PlayerAdded:Connect(add)
Players.PlayerRemoving:Connect(function(p) local r=records[p] if r then for _,c in r.connections do c:Disconnect() end if r.gui then r.gui:Destroy() end records[p]=nil end end)
localPlayer:GetAttributeChangedSignal("CrossgroundsMode"):Connect(function() for p in records do update(p) end end)
for _,p in Players:GetPlayers() do add(p) end
