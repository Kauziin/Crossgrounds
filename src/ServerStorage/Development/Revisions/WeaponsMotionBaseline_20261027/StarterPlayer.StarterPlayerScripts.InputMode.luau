local InputMode={}
local UIS=game:GetService("UserInputService")
local player=game.Players.LocalPlayer
local changed=Instance.new("BindableEvent")
InputMode.Changed=changed.Event
local mode=UIS.PreferredInput
if UIS.GamepadEnabled and not UIS.MouseEnabled then mode=Enum.PreferredInput.Gamepad end
local lastGamepad=0
local function set(value)
 if value~=mode then mode=value player:SetAttribute("ActiveInput",value.Name) changed:Fire(value) end
end
local function observe(input)
 local key=input.KeyCode.Name local kind=input.UserInputType
 if kind.Name:match("^Gamepad") or key:match("^Button") or key:match("^DPad") or key:match("^Thumbstick") then lastGamepad=os.clock() set(Enum.PreferredInput.Gamepad)
 elseif kind==Enum.UserInputType.Touch then set(Enum.PreferredInput.Touch)
 elseif kind==Enum.UserInputType.Keyboard then set(Enum.PreferredInput.KeyboardAndMouse)
 elseif kind==Enum.UserInputType.MouseButton1 or kind==Enum.UserInputType.MouseButton2 then set(Enum.PreferredInput.KeyboardAndMouse)
 elseif kind==Enum.UserInputType.MouseMovement then
  local p=UIS:GetMouseLocation()
  if input.Delta.Magnitude>1 and p.X>=0 and p.Y>=0 then set(Enum.PreferredInput.KeyboardAndMouse) end
 end
end
UIS.InputBegan:Connect(observe)
UIS.InputChanged:Connect(observe)
UIS:GetPropertyChangedSignal("PreferredInput"):Connect(function()
 local value=UIS.PreferredInput
 local point=UIS:GetMouseLocation()
 if value==Enum.PreferredInput.KeyboardAndMouse and (point.X<0 or point.Y<0 or os.clock()-lastGamepad<.4) then return end
 set(value)
end)
function InputMode:Get() return mode end
player:SetAttribute("ActiveInput",mode.Name)
return InputMode