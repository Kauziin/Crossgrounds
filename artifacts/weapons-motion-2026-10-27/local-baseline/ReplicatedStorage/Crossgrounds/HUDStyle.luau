local Style={}
function Style.Outline(frame,color)
 frame.BackgroundTransparency=1 frame.BorderSizePixel=0
 local stroke=Instance.new("UIStroke") stroke.Name="Outline" stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border stroke.Thickness=1.2 stroke.Transparency=.25 stroke.Color=color or Color3.fromRGB(229,239,248) stroke.Parent=frame
 return stroke
end
function Style.Text(label)
 label.TextStrokeColor3=Color3.fromRGB(8,14,21) label.TextStrokeTransparency=.35
end
return Style
