-- Explicit menu decoration; never traverses combat HUDs or changes input targets.
local Style={}
local Policy=require(game.ReplicatedStorage.Crossgrounds.InterfaceStylePolicy)
local player=game.Players.LocalPlayer
local saved=setmetatable({},{__mode='k'})
-- Legacy views keep their original composition until individually migrated.
function Style.Id()return 0 end
function Style.IsNova()return Policy.Resolve(player:GetAttribute('SettingInterfaceStyle'))==1 end
function Style.Metrics(technical)return Policy.Metrics(Style.Id(),technical)end
function Style.Observe(owner,callback)
 local c=player:GetAttributeChangedSignal('SettingInterfaceStyle'):Connect(callback)
 owner.Destroying:Once(function()c:Disconnect()end)
 return c
end
function Style.Surface(o,kind)
 local record=saved[o]
 if not record then record={alpha=o.BackgroundTransparency,edges={}}saved[o]=record end
 local id=Style.Id()
 o.BackgroundTransparency=id==0 and record.alpha or kind=='navigation' and id==1 and .28 or kind=='inner' and .24 or .12
 if player:GetAttribute('SettingHighContrast')then o.BackgroundTransparency=0 end
 for _,s in o:GetChildren()do if s:IsA('UIStroke')then
  if record.edges[s]==nil then record.edges[s]=s.Transparency end
  s.Transparency=id==0 and record.edges[s] or kind=='inner' and 1 or .78
 end end
end
function Style.Hero(panel,title,compact)
 local modern=Style.Id()>0
 local brand=panel:FindFirstChild('StyleBrand')
 if not brand then
  brand=Instance.new('TextLabel')brand.Name='StyleBrand'brand:SetAttribute('SettingsStyled',true)brand:SetAttribute('CascadeDecoration',true)
  brand.BackgroundTransparency=1 brand.Font=Enum.Font.GothamBold brand.Text='//  CROSSGROUNDS'brand.TextSize=12 brand.TextXAlignment=Enum.TextXAlignment.Left
  brand.Size=UDim2.new(1,-16,0,18)brand.Position=UDim2.fromOffset(8,0)brand.Parent=panel
  require(script.Parent.AccentTheme).Role(brand,'TextColor3','Accent')
 end
 brand.Visible=modern
 if title:GetAttribute('OriginalStyleFont')==nil then title:SetAttribute('OriginalStyleFont',title.Font.Name)end
 title.Font=modern and Enum.Font.GothamBold or Enum.Font[title:GetAttribute('OriginalStyleFont')]
 title.Position=UDim2.fromOffset(8,modern and (compact and 15 or 23) or 0)
 title.TextSize=modern and (compact and 24 or 30) or 24 title.Size=UDim2.new(1,-16,0,modern and (compact and 32 or 40) or 32)
 return modern and (compact and 54 or 74) or 42
end
return Style
