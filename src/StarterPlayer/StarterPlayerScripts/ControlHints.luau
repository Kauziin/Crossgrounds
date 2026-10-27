if not require(script.Parent:WaitForChild("ModeScope")):HasCombatRuntime() then return end
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local player=game.Players.LocalPlayer
local Mode=require(script.Parent:WaitForChild("InputMode")) local Router=require(script.Parent:WaitForChild("ControlRouter")) local Icons=require(script.Parent:WaitForChild("InputIcons"))
local gui=Instance.new("ScreenGui") gui.Name="GamepadInstructions" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=14 gui.Parent=player:WaitForChild("PlayerGui") gui.Enabled=Scope:IsCombat()
Scope.Changed:Connect(function() gui.Enabled=Scope:IsCombat() end)
local panel=Instance.new("Frame") panel.Name="Actions" panel.AnchorPoint=Vector2.new(1,1) panel.Position=UDim2.new(1,-28,1,-28) panel.Size=UDim2.fromOffset(332,108) panel.BackgroundColor3=Color3.fromRGB(16,27,41) panel.BackgroundTransparency=.2 panel.BorderSizePixel=0 panel.Parent=gui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,8) corner.Parent=panel
local scale=Instance.new("UIScale") scale.Parent=panel
for i,action in {"Sprint","SwitchWeapon","ShiftLock","Perspective","ReloadInteract","Menu"} do
 local x=((i-1)%2)*166 local y=math.floor((i-1)/2)*34+3
 local glyph=Icons:Glyph(panel,action,function() return Router:Key(action,"Gamepad") end,27) glyph.Position=UDim2.fromOffset(x+7,y+2)
 local label=Instance.new("TextLabel") label.Name=action.."Label" label.Position=UDim2.fromOffset(x+40,y) label.Size=UDim2.fromOffset(125,32) label.BackgroundTransparency=1 label.Text=({Sprint="CORRER",SwitchWeapon="TROCAR ARMA",ShiftLock="TRAVAR MIRA",Perspective="CÂMERA",ReloadInteract="RECARREGAR / USAR",Menu="AJUSTES"})[action] label.TextSize=11 label.Font=Enum.Font.GothamMedium label.TextColor3=Color3.fromRGB(225,237,252) label.TextXAlignment=Enum.TextXAlignment.Left label.Parent=panel
end
game:GetService("RunService").RenderStepped:Connect(function()
 local v=workspace.CurrentCamera.ViewportSize scale.Scale=math.clamp(v.Y/720,.8,1.3) panel.Position=UDim2.new(1,-math.max(24,v.X*.05),1,-math.max(24,v.Y*.05))
 panel.Visible=Mode:Get()==Enum.PreferredInput.Gamepad and not Router:IsBlocked()
end)

