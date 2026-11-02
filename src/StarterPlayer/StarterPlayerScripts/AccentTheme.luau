local Theme={}
local Catalog=require(game.ReplicatedStorage:WaitForChild('Crossgrounds'):WaitForChild('ThemeCatalog'))
local player=game.Players.LocalPlayer
local signal=Instance.new('BindableEvent') Theme.Changed=signal.Event
local bound=setmetatable({},{__mode='k'}) local records=setmetatable({},{__mode='k'})
local palette local writing=setmetatable({},{__mode='k'})
local semantic={Blue=true,Red=true,Health=true,HealthBar=true,StaminaBar=true,DamageTint=true,HealthFill=true,StaminaFill=true,rank=true}
local function attr(key)return player and player:GetAttribute(key)end
local function refreshPalette()
 local color=Catalog.Resolve(attr('SettingThemePreset')or 1,attr('SettingAccentHue'),attr('SettingAccentSaturation'),attr('SettingAccentValue'),attr('ThemeCustomAllowed'))
 palette=Catalog.Palette(color,attr('SettingHighContrast')==true)
end
refreshPalette()
function Theme.Color() return palette.Accent end
function Theme.Palette() return palette end
function Theme.Role(object,property,role)
 object:SetAttribute('ThemeRole_'..property,role) object[property]=palette[role] Theme.Apply(object)
end
local function preserved(o)
 local a=o
 while a and not a:IsA('ScreenGui') do
  if a:GetAttribute('ThemePreserve') or semantic[a.Name] or a.Name:match('^Rank%d+$') then return true end
  a=a.Parent
 end
 return false
end
local function roleOf(value)
 for _,role in {'Accent','Surface','Card','Button','Selected','Text','Muted','Track','Border','Focus'} do if value==palette[role] then return role end end
end
local function update(object,key,r)
 if not object.Parent then return end
 writing[object]=true
 local role=object:GetAttribute('ThemeRole_'..key) or r.role
 local color
 if typeof(r.base)=='ColorSequence' then
  local points={}for _,point in r.base.Keypoints do table.insert(points,ColorSequenceKeypoint.new(point.Time,Catalog.Tint(point.Value,palette.RawAccent)))end color=ColorSequence.new(points)
 else color=role and palette[role] or Catalog.Tint(r.base,palette.RawAccent)end
 r.output=color if object[key]~=color then object[key]=color end writing[object]=nil
end
function Theme.Apply(o)
 if preserved(o) then return end
 local properties=(o:IsA('UIStroke')or o:IsA('UIGradient')) and {'Color'} or o:IsA('GuiObject') and {'BackgroundColor3','TextColor3','ImageColor3'} or {}
 if o:IsA('ScrollingFrame')then table.insert(properties,'ScrollBarImageColor3')end
 local set=records[o]
 if not set then set={} records[o]=set end
 for _,key in properties do
  local ok,value=pcall(function()return o[key]end)
  if ok then
   local r=set[key]
   if not r then
    r={base=value,role=roleOf(value)} set[key]=r
    o:GetPropertyChangedSignal(key):Connect(function()
     if writing[o] or not o.Parent then return end
     local current=o[key] if current==r.output then return end
     r.base=current r.role=roleOf(current) update(o,key,r)
    end)
   end
   update(o,key,r)
  end
 end
end
function Theme.Bind(root)
 if bound[root] then return end bound[root]=true
 local connections={}
 for _,o in root:GetDescendants() do Theme.Apply(o) end
 table.insert(connections,root.DescendantAdded:Connect(function(o)task.defer(function()if o.Parent then Theme.Apply(o)end end)end))
 table.insert(connections,Theme.Changed:Connect(function()for _,o in root:GetDescendants()do Theme.Apply(o)end end))
 root.Destroying:Once(function()for _,c in connections do c:Disconnect()end end)
end
local queued=false
local function schedule()if queued then return end queued=true task.defer(function()queued=false refreshPalette()signal:Fire()end)end
if player then
for _,key in {'ThemePreset','AccentHue','AccentSaturation','AccentValue','HighContrast'} do
 player:GetAttributeChangedSignal('Setting'..key):Connect(schedule)
end
player:GetAttributeChangedSignal('ThemeCustomAllowed'):Connect(schedule)
end
return Theme
