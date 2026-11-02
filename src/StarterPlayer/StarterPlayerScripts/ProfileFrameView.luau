local Catalog=require(game.ReplicatedStorage.Crossgrounds.IdentityCatalog)
local Policy=require(game.ReplicatedStorage.Crossgrounds.ProfileFramePolicy)
local V={}
function V.Render(avatar,data)
 local old=avatar:FindFirstChild("FrameLayers")if old then old:Destroy()end
 local frameId=data.identity and data.identity.frame or"default"local definition=Catalog.frames[frameId]or Catalog.frames.default
 local layers=Policy.Validate(data.frameLayers)or{{frame=frameId,color=definition.color}}
 local root=Instance.new("Frame")root.Name="FrameLayers"root.Size=UDim2.fromScale(1,1)root.BackgroundTransparency=1 root.Active=false root.ZIndex=avatar.ZIndex+1 root.Parent=avatar
 local function line(parent,pos,size,color,rotation)
  local p=Instance.new("Frame")p:SetAttribute("ThemePreserve",true)p.BackgroundColor3=color p.BorderSizePixel=0 p.Position=pos p.Size=size p.Rotation=rotation or 0 p.ZIndex=root.ZIndex p.Parent=parent
 end
 for i,layer in layers do
  local spec=Catalog.frames[layer.frame]or Catalog.frames.default local color=Color3.fromRGB(table.unpack(layer.color))local gap=(i-1)*2
  local f=Instance.new("Frame")f:SetAttribute("ThemePreserve",true)f.Name="Layer"..i f.BackgroundTransparency=1 f.Position=UDim2.fromOffset(-gap,-gap)f.Size=UDim2.new(1,gap*2,1,gap*2)f.ZIndex=root.ZIndex f.Parent=root
  local corner=Instance.new("UICorner")corner.CornerRadius=UDim.new(spec.roundness or .12,0)corner.Parent=f
  local stroke=Instance.new("UIStroke")stroke:SetAttribute("ThemePreserve",true)stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Color=color stroke.Thickness=1.5 stroke.Parent=f
  if layer.frame~="default"then
   local length=layer.frame=="mastery"and 12 or layer.frame=="legend"and 9 or 7
   for _,xy in {{0,0},{1,0},{0,1},{1,1}}do
    local x,y=xy[1],xy[2]
    if layer.frame=="legend"then line(f,UDim2.new(x,-3,y,-3),UDim2.fromOffset(6,6),color,45)
    else line(f,UDim2.new(x,x==0 and 0 or-length,y,y==0 and 0 or-2),UDim2.fromOffset(length,2),color)
     if layer.frame=="mastery"or layer.frame=="clan"then line(f,UDim2.new(x,x==0 and 0 or-2,y,y==0 and 0 or-length),UDim2.fromOffset(2,length),color)end
    end
   end
  end
 end return root
end
return V
