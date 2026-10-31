-- This is an example macro


local macro = {}
local utilFolder = script.Parent.Parent.Util
local circleGenerate = require(utilFolder.CircleGenerator)

function macro:Init(plugin, pluginSettings, updatePluginSettingsCallback)

end


local button = {}
button.Type = "Button"
button.Text = "⭕ Generate Circle"

function button:Activate()
	print("Generating circle ⭕")
	local circle = circleGenerate:Generate(radius.Value, width.Value, height.Value, segments.Value)
	circle.Parent = workspace
	game.Selection:Set({circle})
end


radius = {}
radius.Type = "Number"
radius.Text = "Radius"
radius.SettingId = "CircleRadius"
radius.Value = 12

function radius:Changed(newValue, oldValue)
	
end


width = {}
width.Type = "Number"
width.Text = "Edge Width"
width.SettingId = "CircleWidth"
width.Value = 4

function width:Changed(newValue, oldValue)
	
end

height = {}
height.Type = "Number"
height.Text = "Edge Height"
height.SettingId = "CircleHeight"
height.Value = 4

function height:Changed(newValue, oldValue)
	
end


segments = {}
segments.Type = "Number"
segments.Text = "Segment Count"
segments.SettingId = "CircleWidth"
segments.Value = 20

function segments:Changed(newValue, oldValue)
	if not (newValue % 1 == 0) then
		segments:Set(math.floor(newValue + 0.5))
	end	
end


macro.Items = {button, radius, width, height, segments}

return macro 