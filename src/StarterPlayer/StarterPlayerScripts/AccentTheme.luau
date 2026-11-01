local Theme={}
local bound=setmetatable({},{__mode='k'})
local player=game.Players.LocalPlayer
local accents={Color3.fromRGB(36,224,232),Color3.fromRGB(40,230,235),Color3.fromRGB(16,224,227)}
function Theme.Color() return Color3.fromHSV((player:GetAttribute('SettingAccentHue') or 180)/360,.84,1) end
function Theme.Apply(o)
 local properties=o:IsA('UIStroke') and {'Color'} or o:IsA('GuiObject') and {'BackgroundColor3','TextColor3','ImageColor3'} or {}
 for _,key in properties do
  local attr='ThemeAccent_'..key local ok,value=pcall(function() return o[key] end)
  if ok and (o:GetAttribute(attr) or table.find(accents,value) or value==Theme.Color()) then o:SetAttribute(attr,true) o[key]=Theme.Color() end
 end
end
function Theme.Bind(root)
 if bound[root] then return end bound[root]=true
 local dead=false local connections={}
 local function refresh() for _,o in root:GetDescendants() do Theme.Apply(o) end end
 table.insert(connections,root.DescendantAdded:Connect(function(o) task.defer(function() if o.Parent then Theme.Apply(o) end end) end))
 table.insert(connections,player:GetAttributeChangedSignal('SettingAccentHue'):Connect(refresh))
 root.Destroying:Connect(function() if dead then return end dead=true for _,c in connections do c:Disconnect() end end)
 refresh()
end
return Theme
