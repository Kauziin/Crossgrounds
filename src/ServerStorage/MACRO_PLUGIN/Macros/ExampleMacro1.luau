-- This is an example macro


local macro = {}
local utilFolder = script.Parent.Parent.Util

function macro:Init(plugin, pluginSettings, updatePluginSettingsCallback)
	print("Example macro initialized")
end



local title = {}
title.Type = "Title"
title.Text = "Macro Item Types Template"


local buttonTest = {}
buttonTest.Type = "Button"
buttonTest.Text = "Test button"

function buttonTest:Activate()
	print("Button clicked")
end


local numberTest = {}
numberTest.Type = "Number"
numberTest.Text = "Test number"
numberTest.SettingId = "TestNumber"
numberTest.Value = 1337

function numberTest:Changed(newValue, oldValue)
	print("Number changed to ", newValue)
	if newValue > 2000 then
		self:Set(oldValue)
	end
end


local booleanTest = {}
booleanTest.Type = "Boolean"
booleanTest.Text = "Test bool"
booleanTest.SettingId = "TestBool"
booleanTest.Value = false

function booleanTest:Changed(newValue, oldValue)
	print("Bool changed to ", newValue)
end


local stringTest = {}
stringTest.Type = "String"
stringTest.Text = "Test string"
stringTest.SettingId = "TestString"
stringTest.Value = "test string"

function stringTest:Changed(newValue, oldValue)
	print("String changed to ", newValue)
end


local vector3Test = {}
vector3Test.Type = "Vector3"
vector3Test.Text = "Test vector3"
vector3Test.SettingId = "TestVector"
vector3Test.Value = Vector3.new(0, 1, 2)

function vector3Test:Changed(newValue, oldValue)
	print("Vector3 changed to ", newValue)
end


macro.Items = {title, buttonTest, numberTest, booleanTest, stringTest, vector3Test}

return macro 