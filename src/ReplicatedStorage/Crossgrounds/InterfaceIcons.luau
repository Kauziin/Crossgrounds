-- Creator Store 119136002207552; upstream Lucide/Feather attribution in assets/vendor/lucide.
local Pack=require(script.Parent.LucideIcons)
local I={}
I.Roles={Play="play",StayLobby="armchair",Progress="chart-no-axes-combined",Career="contact-round",Social="users",Clan="shield",Settings="settings",Music="music",Profile="user-round",Friends="users-round",Leaders="crown",Wins="trophy",Losses="heart-crack",Deaths="skull",Kills="crosshair",BotKills="bot",TrainingKills="target",XP="sparkles",Level="trending-up",Coins="coins",PlaySeconds="clock",Captures="flag",ctf="flag-triangle-right",arena="swords",duels="sword",get_out="door-open",Escapes="footprints",Ratio="activity",general="chart-column",Back="arrow-left",Frames="layers",Identity="palette",Unlocks="lock-open",Weapons="wrench",Prestige="medal",Recent="history",Preferences="sliders-horizontal",Invites="mail",Members="group",Players="user-plus",Close="log-out"}
function I.Asset(role)return Pack.GetAsset(I.Roles[role]or role)end
function I.Apply(image,role,color)
 local asset=I.Asset(role)if not asset then return false end
 image.Image=asset.Url image.ImageRectSize=asset.ImageRectSize image.ImageRectOffset=asset.ImageRectOffset
 image.ImageColor3=color or Color3.new(1,1,1)image.BackgroundTransparency=1 image:SetAttribute("IconRole",role)image:SetAttribute("LucideIcon",asset.IconName)return true
end
function I.Image(parent,role,size,color)
 local image=Instance.new("ImageLabel")image.Name="LibraryIcon"image.Size=UDim2.fromOffset(size or 24,size or 24)image:SetAttribute("SettingsStyled",true)
 if not I.Apply(image,role,color)then image:Destroy()return nil end image.Parent=parent return image
end
return I
