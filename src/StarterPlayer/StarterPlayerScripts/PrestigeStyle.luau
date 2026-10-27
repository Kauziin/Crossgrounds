local Style={}
local colors={
 {Color3.fromRGB(255,234,155),Color3.fromRGB(218,161,38)},
 {Color3.fromRGB(245,252,255),Color3.fromRGB(145,168,193)},
 {Color3.fromRGB(248,190,133),Color3.fromRGB(170,91,50)},
}
function Style.Apply(label,rank)
 local old=label:FindFirstChild("LeaderPrestige") if old then old:Destroy() end
 label.TextColor3=Color3.fromRGB(237,244,250)
 local pair=colors[rank] if not pair then return end
 local gradient=Instance.new("UIGradient") gradient.Name="LeaderPrestige" gradient.Color=ColorSequence.new(pair[1],pair[2]) gradient.Rotation=25 gradient.Parent=label
end
return Style
