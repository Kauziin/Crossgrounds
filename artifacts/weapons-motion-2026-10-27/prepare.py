from pathlib import Path
import json

ROOT=Path(__file__).resolve().parent
SRC=ROOT/'work/src'
def put(name,text):
    path=SRC/Path(*name.split('.')).with_suffix('.luau')
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(text.strip()+'\n',encoding='utf-8',newline='\n')
def edit(name,old,new):
    path=SRC/Path(*name.split('.')).with_suffix('.luau')
    text=path.read_text(encoding='utf-8-sig')
    assert text.count(old)==1,(name,old[:100],text.count(old))
    path.write_text(text.replace(old,new),encoding='utf-8',newline='\n')

put('StarterPlayer.StarterPlayerScripts.InputMode',r'''
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
''')

edit('ReplicatedStorage.Crossgrounds.AnalogFilter','return Filter',r'''
-- Schmitt gate avoids flicker on the deadzone boundary; never retains a direction.
function Filter.Stick(state,value,deadzone)
 deadzone=math.clamp(deadzone or 0,0,.4)
 local length=value.Magnitude
 if length<=deadzone or length<.00001 then state.active=false return Vector2.zero end
 if not state.active and length<=deadzone+.015 then return Vector2.zero end
 state.active=true return Filter.Radial(value,deadzone)
end
return Filter''')

edit('ReplicatedStorage.Crossgrounds.AimAssist',r''' elseif context.device=="gamepad" then
  gate=.14*smooth(.15,.75,math.abs(context.strafe or 0))''','')
edit('ReplicatedStorage.Crossgrounds.AimAssist','state.velocity=state.velocity:Lerp(velocity,1-math.exp(-dt/.065))',r'''
 if state.velocity:Dot(velocity)<0 then state.velocity=velocity
 else state.velocity=state.velocity:Lerp(velocity,1-math.exp(-dt/.065)) end''')
edit('ReplicatedStorage.Crossgrounds.AimAssist','return state.friction,Vector2.new(math.clamp(delta.X,-yawLimit,yawLimit),math.clamp(delta.Y*.35,-pitchLimit,pitchLimit))',r'''
 -- Each axis yields immediately when the user lets go or looks the other way.
 local x=math.abs(input.X)>.025 and input.X*delta.X>0 and math.clamp(delta.X,-yawLimit,yawLimit) or 0
 local y=math.abs(input.Y)>.025 and input.Y*delta.Y>0 and math.clamp(delta.Y*.35,-pitchLimit,pitchLimit) or 0
 return state.friction,Vector2.new(x,y)''')

name='StarterPlayer.StarterPlayerScripts.CombatPresentation'
edit(name,'local keyStick=Vector2.zero','local stickGate={}\nlocal touchDelta=Vector2.zero')
start='local directions={'
path=SRC/Path(*name.split('.')).with_suffix('.luau')
text=path.read_text(); a=text.index(start); b=text.index('UIS.InputChanged:Connect',a)
text=text[:a]+r'''
local function clearLook()
 stick=Vector2.zero touchDelta=Vector2.zero touchIntent=Vector2.zero
 touchLook=nil touchPosition=nil lastTouchLook=0 touchSampleAt=0
 table.clear(stickGate) assistFriction=1 Assist:Reset()
end
'''+text[b:]; path.write_text(text,encoding='utf-8')
edit(name,'if input.KeyCode==Enum.KeyCode.Thumbstick2 then stick=Vector2.new(input.Position.X,input.Position.Y) return end','if input.KeyCode==Enum.KeyCode.Thumbstick2 then return end')
edit(name,'if delta.Magnitude>.2 then lastTouchLook=os.clock() end\n  turn(delta.X,delta.Y)','touchDelta+=delta')
edit(name,'if not owned or Presentation:IsBlocked() then return end\n local overFire=false','if not owned or Presentation:IsBlocked() or touchLook then return end\n local overFire=false')
edit(name,'touchLook=input touchPosition=Vector2.new(input.Position.X,input.Position.Y)','touchLook=input touchPosition=Vector2.new(input.Position.X,input.Position.Y) touchDelta=Vector2.zero touchIntent=Vector2.zero touchSampleAt=os.clock()')
edit(name,'UIS.TouchEnded:Connect(function(input) if touchLook==input then touchLook=nil touchPosition=nil touchIntent=Vector2.zero end end)','UIS.TouchEnded:Connect(function(input) if touchLook==input then clearLook() end end)')
edit(name,'UIS.GamepadDisconnected:Connect(function() stick=Vector2.zero keyStick=Vector2.zero Assist:Reset() end)','UIS.GamepadDisconnected:Connect(clearLook)')
edit(name,'UIS.WindowFocusReleased:Connect(function() stick=Vector2.zero keyStick=Vector2.zero aiming=false firing=false touchLook=nil end)','UIS.WindowFocusReleased:Connect(function() clearLook() aiming=false firing=false end)')
edit(name,'GuiService.MenuOpened:Connect(function() aiming=false firing=false touchLook=nil end)','GuiService.MenuOpened:Connect(function() clearLook() aiming=false firing=false end)')
edit(name,'InputMode.Changed:Connect(function() if owned then cursorMode() end end)','InputMode.Changed:Connect(function() clearLook() if owned then cursorMode() end end)\nplayer.CharacterRemoving:Connect(clearLook)')
edit(name,'if blocked then\n  motion:Reset()','if blocked then\n  clearLook()\n  motion:Reset()')
edit(name,'local movement=Analog.Look(keyStick.Magnitude>0 and keyStick or stick,setting("RightStickDeadzone"),setting("StickCurve"),setting("StickCurveStrength"))',r'''
 -- Poll the selected physical controller. No synthesized direction can latch a turn.
 stick=Vector2.zero
 if input==Enum.PreferredInput.Gamepad then
  local ok,inputs=pcall(function() return UIS:GetGamepadState(InputMode.ActiveGamepad) end)
  if ok then for _,v in inputs do if v.KeyCode==Enum.KeyCode.Thumbstick2 then stick=Vector2.new(v.Position.X,v.Position.Y) break end end end
 end
 local clean=Analog.Stick(stickGate,stick,setting("RightStickDeadzone"))
 local movement=setting("StickCurve")==1 and Analog.Dynamic(clean,setting("StickCurveStrength")) or clean
 local pixels=touchDelta touchDelta=Vector2.zero
 local touchRadians=input==Enum.PreferredInput.Touch and touchLook and Analog.TouchRadians(pixels,camera.ViewportSize.X,setting("LookSensitivity"),aiming and setting("AimSensitivity") or 1) or Vector2.zero
 touchIntent=touchRadians.Magnitude>0 and Vector2.new(-touchRadians.X,-touchRadians.Y)/(math.max(deltaTime,.001)*2.4) or Vector2.zero
 if touchIntent.Magnitude>1 then touchIntent=touchIntent.Unit end''')
edit(name,'local lookIntent=input==Enum.PreferredInput.Gamepad and Vector2.new(-movement.X,movement.Y) or touchLook and os.clock()-lastTouchLook<.12 and touchIntent or Vector2.zero','local lookIntent=input==Enum.PreferredInput.Gamepad and Vector2.new(-movement.X,movement.Y) or touchIntent')
edit(name,'if assisted and (locked or firstPerson) then',r'''
 if input==Enum.PreferredInput.Touch then
  yaw-=touchRadians.X*assistFriction pitch=math.clamp(pitch-touchRadians.Y*assistFriction,-1.25,1.25)
 end
 if assisted and (locked or firstPerson) then''')

edit('StarterPlayer.StarterPlayerScripts.AnalogMovement','local Settings=require(game.ReplicatedStorage.ExperienceSettings)','local Settings=require(game.ReplicatedStorage.ExperienceSettings)\nlocal Router=require(script.Parent:WaitForChild("ControlRouter"))\nlocal gate={}')
edit('StarterPlayer.StarterPlayerScripts.AnalogMovement','if not focused or Gui.MenuIsOpen or UIS:GetFocusedTextBox() or player:GetAttribute("GameMenuOpen") or player:GetAttribute("CrossgroundsTransition") then return Vector3.zero end','if not focused or not Router:CanMove() then table.clear(gate) player:SetAttribute("FilteredLeftStick",Vector2.zero) return Vector3.zero end')
edit('StarterPlayer.StarterPlayerScripts.AnalogMovement','local clean=Filter.Radial(raw,deadzone)','local clean=Filter.Stick(gate,raw,deadzone)')
print('Prepared input and assistance fixes')
