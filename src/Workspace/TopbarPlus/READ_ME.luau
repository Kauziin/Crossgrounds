-- TopbarPlus entry point. The former Example icon now opens the pause list.
local player=game.Players.LocalPlayer
local Nav=require(player:WaitForChild("PlayerScripts"):WaitForChild("MenuNavigation"))
local Icon=require(script.Parent.Icon)
local icon=Icon.new():setName("CrossgroundsMenu"):align("Right"):setLabel("Menu"):setImage(16086868244,"Deselected"):setImage(16086868447,"Selected")
icon:bindEvent("selected",function() Nav:OpenMenu("Main") end)
icon:bindEvent("deselected",function() if player:GetAttribute("ExperienceMenuOpen") then Nav:OpenMenu("Resume") end end)
player:GetAttributeChangedSignal("ExperienceMenuOpen"):Connect(function()
 if player:GetAttribute("ExperienceMenuOpen")~=true then icon:deselect() end
end)
