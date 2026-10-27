-- Adapt the controller input before native ControlModule camera/vehicle handling.
-- No PlayerModule sources are modified; keyboard, touch, jump and menus remain native.
local player=game.Players.LocalPlayer local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService") local Gui=game:GetService("GuiService")
local Mode=require(script.Parent:WaitForChild("InputMode"))
local Filter=require(game.ReplicatedStorage.Crossgrounds.AnalogFilter)
local Settings=require(game.ReplicatedStorage.ExperienceSettings)
local module=player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
local controls=require(module):GetControls() local gamepad=require(module:WaitForChild("ControlModule"):WaitForChild("Gamepad"))
local hooked=setmetatable({},{__mode="k"}) local focused=true
UIS.WindowFocusReleased:Connect(function() focused=false end) UIS.WindowFocused:Connect(function() focused=true end)
Run:BindToRenderStep("CrossgroundsAnalogMovement",Enum.RenderPriority.Input.Value,function()
 if controls.activeControlModule~=gamepad then return end
 local controller=controls.activeController if not controller or hooked[controller] then return end
 local original=controller.GetMoveVector hooked[controller]=true
 controller.GetMoveVector=function(self)
  if Mode:Get()~=Enum.PreferredInput.Gamepad then return original(self) end
  if not focused or Gui.MenuIsOpen or UIS:GetFocusedTextBox() or player:GetAttribute("GameMenuOpen") or player:GetAttribute("CrossgroundsTransition") then return Vector3.zero end
  local raw=Vector2.zero
  local ok,state=pcall(function() return UIS:GetGamepadState(self.activeGamepad) end)
  if ok then for _,input in state do if input.KeyCode==Enum.KeyCode.Thumbstick1 then raw=Vector2.new(input.Position.X,input.Position.Y) break end end end
  local deadzone=player:GetAttribute("SettingLeftStickDeadzone") if deadzone==nil then deadzone=Settings.Rules.LeftStickDeadzone.Default end
  local clean=Filter.Radial(raw,deadzone)
  player:SetAttribute("FilteredLeftStick",clean) player:SetAttribute("AnalogMovementAdapter",true)
  return Vector3.new(clean.X,0,-clean.Y)
 end
end)
