-- This is an example macro


local macro = {}
local utilFolder = script.Parent.Parent.Util

local blinking = false

function macro:Init(plugin, pluginSettings, updatePluginSettingsCallback)

end


local title = {}
title.Type = "Title"
title.Text = "Macro:SetVisible() Demo"


local buttonTest1 = {}
buttonTest1.Type = "Button"
buttonTest1.Text = "Blink Whole Macro"

function buttonTest1:Activate()
	if blinking then
		return
	end
	blinking = true
	buttonTest1:UpdateText("BLINKING")
	for i = 1, 4 do
		macro:SetVisible(false)
		wait(0.3)
		macro:SetVisible(true)
		wait(0.3)
	end
	buttonTest1:UpdateText("Blink Whole Macro")
	blinking = false
end


local buttonTest2 = {}
buttonTest2.Type = "Button"
buttonTest2.Text = "Blink This Button"

function buttonTest2:Activate()
	if blinking then
		return
	end
	blinking = true
	buttonTest2:UpdateText("BLINKING")
	for i = 1, 4 do
		buttonTest2:SetVisible(false)
		wait(0.3)
		buttonTest2:SetVisible(true)
		wait(0.3)
	end
	buttonTest2:UpdateText("Blink This Button")
	blinking = false
end


macro.Items = {title, buttonTest1, buttonTest2}

return macro 