local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Router={}
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local player=game.Players.LocalPlayer
local Definition=require(game.ReplicatedStorage:WaitForChild("ControlDefinitions"))
local Settings=require(game.ReplicatedStorage:WaitForChild("ExperienceSettings"))
local Icons=require(script.Parent:WaitForChild("InputIcons"))
local update=game.ReplicatedStorage.Events:WaitForChild("UpdateExperienceSetting")
local listeners={} local capture local generation=0
local changed=Instance.new("BindableEvent") Router.Changed=changed.Event
local captureChanged=Instance.new("BindableEvent") Router.CaptureChanged=captureChanged.Event
function Router:Key(action,device)
 local key=Definition:Attribute(action,device)
 return player:GetAttribute("Setting"..key) or Definition.Actions[action][device]
end
function Router:IsBlocked()
 local join=player.PlayerGui:FindFirstChild("JoinMenu") local hud=player.PlayerGui:FindFirstChild("CombatHUD")
 return player:GetAttribute("ClientLoading")==true or player:GetAttribute("AdminFreecam")==true or not (Scope:IsCombat() or Scope:IsGetOut()) or (Scope:IsArena() and (not player:GetAttribute("ArenaPlaying") or player:GetAttribute("ArenaVotingOpen"))) or player:GetAttribute("CrossgroundsTransition")==true or player:GetAttribute("HUDLayoutEditing")==true or capture~=nil or player:GetAttribute("ExperienceMenuOpen")==true or join and join.Enabled or hud and hud.LeaveShade.Visible or game:GetService("GuiService").MenuIsOpen or UIS:GetFocusedTextBox()~=nil
end
local function bind(action)
 local registered=listeners[action] if not registered then return end
 CAS:UnbindAction("CTFControl"..action)
 registered.callback(Enum.UserInputState.Cancel,nil)
 CAS:BindActionAtPriority("CTFControl"..action,function(_,state,input)
  return Router:Dispatch(action,state,input)
 end,false,Definition.Actions[action].AdminOnly and 6000 or 3000,Definition:Input(Router:Key(action,"Keyboard")),Definition:Input(Router:Key(action,"Gamepad")))
end
function Router:Dispatch(action,state,input)
 local registered=listeners[action] if not registered then return Enum.ContextActionResult.Pass end
 if (registered.scope=="admin" and (player:GetAttribute("CrossgroundsAdmin")~=true or player:GetAttribute("AdminFreecam")~=true)) or (registered.scope=="get_out" and not Scope:IsGetOut()) or (registered.scope=="ctf" and not Scope:IsCTF()) or (registered.scope=="combat" and not Scope:IsCombat()) or (registered.scope=="interaction" and not Scope:IsInteractive()) or player:GetAttribute("CrossgroundsTransition")==true or capture or (self:IsBlocked() and not registered.allowMenus) then
  if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then registered.callback(Enum.UserInputState.Cancel,input) end
  return Enum.ContextActionResult.Pass
 end
 return registered.callback(state,input) or Enum.ContextActionResult.Sink
end
function Router:Register(action,callback,options)
 options=options or {} local combatActions={Fire=true,ReloadInteract=true,Aim=true,SwitchWeapon=true,Sprint=true,Jump=true,Perspective=true,ShiftLock=true,Shoulder=true}
 options.scope=options.scope or (action=="Menu" and "global" or combatActions[action] and "combat" or "ctf") options.callback=callback listeners[action]=options bind(action)
end
function Router:Commit(action,device,name)
 if not Definition:IsAllowed(device,name,action) then return false end
 local key=Definition:Attribute(action,device) local old=self:Key(action,device)
 for other in pairs(Definition.Actions) do
  if other~=action and Definition:Conflicts(action,other) and self:Key(other,device)==name then player:SetAttribute("Setting"..Definition:Attribute(other,device),old) break end
 end
 player:SetAttribute("Setting"..key,name) update:FireServer(key,name)
 return true
end
local function finish(success,name)
 if not capture then return end
 local request=capture capture=nil player:SetAttribute("Rebinding",false)
 if success then Router:Commit(request.action,request.device,name) end
 captureChanged:Fire(false,success and "Controle atualizado. Atalhos em conflito foram trocados." or "Tempo esgotado. O controle anterior foi mantido.")
 task.delay(.15,function() if not capture then CAS:UnbindAction("CTFCaptureBinding") end end)
end
function Router:Capture(action,device)
 if capture then return end
 generation+=1 local token=generation
 capture={action=action,device=device,ready=os.clock()+.2,deadline=os.clock()+5}
 player:SetAttribute("Rebinding",true)
 local inputs={Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
 for _,key in Enum.KeyCode:GetEnumItems() do if key~=Enum.KeyCode.Unknown then table.insert(inputs,key) end end
 CAS:BindActionAtPriority("CTFCaptureBinding",function(_,state,input)
  if not capture then return Enum.ContextActionResult.Sink end
  if state==Enum.UserInputState.Begin and os.clock()>=capture.ready then
   local name=input.KeyCode.Name
   if input.UserInputType.Name:match("^MouseButton") then name=input.UserInputType.Name end
   if Definition:IsAllowed(capture.device,name,capture.action) then finish(true,name) end
  end
  return Enum.ContextActionResult.Sink
 end,false,10000,table.unpack(inputs))
 captureChanged:Fire(true,Definition.Actions[action].Label)
 task.delay(5,function() if token==generation then finish(false) end end)
end
function Router:CaptureRemaining() return capture and math.max(0,math.ceil(capture.deadline-os.clock())) or 0 end
function Router:Reset(deviceOnly)
 for action,data in pairs(Definition.Actions) do
  for _,device in {"Gamepad","Keyboard"} do if not deviceOnly or deviceOnly==device then player:SetAttribute("Setting"..Definition:Attribute(action,device),data[device]) end end
 end
 update:FireServer("ResetControls",deviceOnly or true)
end
for action in pairs(Definition.Actions) do
 for _,device in {"Gamepad","Keyboard"} do
  player:GetAttributeChangedSignal("Setting"..Definition:Attribute(action,device)):Connect(function() bind(action) Icons:Refresh() changed:Fire() end)
 end
end
return Router


