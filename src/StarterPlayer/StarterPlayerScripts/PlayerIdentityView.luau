local Catalog=require(game.ReplicatedStorage.Crossgrounds.IdentityCatalog)
local Frames=require(script.Parent.ProfileFrameView)
local View={}
local function color(rgb) return Color3.fromRGB(table.unpack(rgb)) end
function View.decorateButton(button,data)
 local padding=button:FindFirstChildOfClass("UIPadding")or Instance.new("UIPadding")padding.PaddingLeft=UDim.new(0,58)padding.Parent=button
 local image=Instance.new("ImageLabel")image.Name="ProfileAvatar"image.BackgroundColor3=Color3.fromRGB(16,32,40)image.Position=UDim2.new(0,-47,.5,-18)image.Size=UDim2.fromOffset(36,36)image.Parent=button
 if type(data.userId)=="number"and data.userId>0 then image.Image="rbxthumb://type=AvatarHeadShot&id="..data.userId.."&w=150&h=150"end
 Frames.Render(image,data)
 return image
end
function View.new(parent)
 local card=Instance.new("Frame") card.Name="PlayerIdentity" card.Size=UDim2.new(1,0,0,126) card.BorderSizePixel=0 card.Parent=parent
 local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,10) corner.Parent=card
 local gradient=Instance.new("UIGradient") gradient.Parent=card
 local image=Instance.new("ImageLabel") image.Name="Avatar" image.BackgroundTransparency=1 image.Position=UDim2.fromOffset(12,14) image.Size=UDim2.fromOffset(78,78) image.Parent=card
 local labels={}
 for _,def in {{"Name",98,12,22},{"Title",98,43,15},{"Progress",98,69,14},{"Emblem",14,96,17}} do
  local label=Instance.new("TextLabel") label.Name=def[1] label.Text="" label.BackgroundTransparency=1 label.Position=UDim2.fromOffset(def[2],def[3]) label.Size=UDim2.new(1,-def[2]-10,0,24) label.TextXAlignment=Enum.TextXAlignment.Left label.TextColor3=Color3.new(1,1,1) label.Font=Enum.Font.GothamMedium label.TextSize=def[4] label.TextTruncate=Enum.TextTruncate.AtEnd label.Parent=card labels[def[1]]=label
 end
 local version=0
 local result={Frame=card}
 function result:Render(data)
  version+=1 local current=version local identity=data.identity or {}
  local art=Catalog.cards[identity.card] or Catalog.cards.default
  card.BackgroundColor3=Color3.new(1,1,1) gradient.Color=ColorSequence.new(color(art.a),color(art.b))
  Frames.Render(image,data)
  labels.Name.Text=data.name or "Jogador"
  labels.Title.Text=(Catalog.titles[identity.title] or Catalog.titles.default).name
  labels.Progress.Text=(data.phase=="legend" and "Lenda" or data.phase=="mastery" and "Maestria" or "Prestígio "..tostring(data.prestige or 0)).." · Nível "..tostring(data.level or 1)
  local rank=Catalog.rankStyles[data.rankStyle]or Catalog.rankStyles.classic
  local special=data.phase=="mastery"or data.phase=="legend"
  labels.Progress.TextColor3=special and color(rank.color)or Color3.new(1,1,1)
  if special then labels.Progress.Text=rank.glyph.." "..labels.Progress.Text end
  labels.Emblem.Text=(Catalog.emblems[identity.emblem] or Catalog.emblems.default).glyph.."  "..art.name..(data.clan and(" · Clã "..tostring(data.clan.code))or"")
  local id=data.userId image.Image=""
  if type(id)=="number" and id>0 then task.spawn(function()
   local ok,url=pcall(function() return game.Players:GetUserThumbnailAsync(id,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
   if ok and version==current and image.Parent then image.Image=url end
  end) end
 end
 return result
end
return View
