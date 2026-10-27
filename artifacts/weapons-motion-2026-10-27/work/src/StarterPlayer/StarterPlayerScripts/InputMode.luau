-- Only deliberate input selects a device. Neutral stick noise is not intent.
local InputMode={}
local UIS=game:GetService("UserInputService")
local player=game.Players.LocalPlayer
local changed=Instance.new("BindableEvent") InputMode.Changed=changed.Event
local mode=UIS.PreferredInput
local lastGamepad=-100
InputMode.ActiveGamepad=Enum.UserInputType.Gamepad1
local function set(value)
 if value~=mode then mode=value player:SetAttribute("ActiveInput",value.Name) changed:Fire(value) end
end
local function observe(input)
 local key=input.KeyCode local kind=input.UserInputType
 if kind.Name:match("^Gamepad") then
  if key==Enum.KeyCode.Thumbstick1 or key==Enum.KeyCode.Thumbstick2 then
   local dz=player:GetAttribute(key==Enum.KeyCode.Thumbstick1 and "SettingLeftStickDeadzone" or "SettingRightStickDeadzone") or .1
   if Vector2.new(input.Position.X,input.Position.Y).Magnitude<=math.max(.12,dz+.02) then return end
  elseif input.UserInputState~=Enum.UserInputState.Begin then return end
  lastGamepad=os.clock() InputMode.ActiveGamepad=kind set(Enum.PreferredInput.Gamepad)
 elseif kind==Enum.UserInputType.Touch then
  if input.UserInputState==Enum.UserInputState.Begin then set(Enum.PreferredInput.Touch) end
 elseif kind==Enum.UserInputType.Keyboard then
  -- Thumbstick2Left/Right are synthesized digital directions, not keyboard input.
  if not key.Name:match("^Thumbstick") and input.UserInputState==Enum.UserInputState.Begin then set(Enum.PreferredInput.KeyboardAndMouse) end
 elseif kind==Enum.UserInputType.MouseButton1 or kind==Enum.UserInputType.MouseButton2 then
  if input.UserInputState==Enum.UserInputState.Begin then set(Enum.PreferredInput.KeyboardAndMouse) end
 elseif kind==Enum.UserInputType.MouseMovement then
  local p=UIS:GetMouseLocation()
  if input.Delta.Magnitude>1 and p.X>=0 and p.Y>=0 then set(Enum.PreferredInput.KeyboardAndMouse) end
 end
end
UIS.InputBegan:Connect(observe) UIS.InputChanged:Connect(observe)
UIS:GetPropertyChangedSignal("PreferredInput"):Connect(function()
 local value=UIS.PreferredInput
 -- PreferredInput also reacts to noise; deliberate events above own device changes.
 if value==Enum.PreferredInput.Gamepad and os.clock()-lastGamepad>.3 then return end
 if value==Enum.PreferredInput.KeyboardAndMouse then
  local point=UIS:GetMouseLocation()
  if point.X<0 or point.Y<0 or os.clock()-lastGamepad<.4 then return end
 end
 if value~=Enum.PreferredInput.Touch then set(value) end
end)
function InputMode:Get() return mode end
player:SetAttribute("ActiveInput",mode.Name)
return InputMode
