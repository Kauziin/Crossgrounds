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
local Policy=require(game.ReplicatedStorage:WaitForChild("ControlPolicy"))
local Gui=game:GetService("GuiService")
local focused=true
local owners={} local bindings={} local customContexts={}
local contextChanged=Instance.new("BindableEvent") Router.ContextChanged=contextChanged.Event
function Router:Snapshot()
 local p=player
 local join=p.PlayerGui:FindFirstChild("JoinMenu") local hud=p.PlayerGui:FindFirstChild("CombatHUD")
 local modal=p:GetAttribute("GameMenuOpen")==true or p:GetAttribute("ExperienceMenuOpen")==true
  or p:GetAttribute("ProgressionMenuOpen")==true or p:GetAttribute("LobbyMusicMenuOpen")==true
  or p:GetAttribute("CTFKitMenuOpen")==true or p:GetAttribute("ArenaVotingOpen")==true
  or p:GetAttribute("HUDLayoutEditing")==true or p:GetAttribute("InventoryOpen")==true
  or p:GetAttribute("InventoryMenuOpen")==true or Scope:IsCTF() and
   (join and join.Enabled or hud and hud.Enabled and hud:FindFirstChild("LeaveShade") and hud.LeaveShade.Visible)
 for _,provider in customContexts do if provider() then modal=true end end
 local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
 return {mode=Scope:Get(),sprinting=p:GetAttribute("SprintActive")==true,modal=modal==true,settingsMenu=p:GetAttribute("ExperienceMenuOpen")==true,
  suspended=not focused or capture~=nil or p:GetAttribute("ClientLoading")==true or p:GetAttribute("CrossgroundsTransition")==true or Gui.MenuIsOpen or UIS:GetFocusedTextBox()~=nil,
  admin=p:GetAttribute("AdminFreecam")==true,authorized=p:GetAttribute("CrossgroundsAdmin")==true,
  inMatch=p:GetAttribute("InMatch")==true,arenaPlaying=p:GetAttribute("ArenaPlaying")==true,
  alive=h~=nil and h.Health>0,spectating=p:GetAttribute("SpectatingEliminator")==true,
  role=p:GetAttribute("GetOutRole"),result=p:GetAttribute("GetOutResult"),
  hacking=p:GetAttribute("GetOutHacking")==true,victim=p:GetAttribute("GetOutVictimState"),
  dragging=p:GetAttribute("ControlDragging")==true}
end
function Router:RegisterModal(id,provider)
 assert(type(id)=="string" and type(provider)=="function")
 customContexts[id]=provider
 return function() customContexts[id]=nil end
end
function Router:CanMove()
 local s=self:Snapshot()
 return not s.suspended and not s.modal and (s.admin or s.alive and not s.spectating and
  (s.mode~="arena" or s.arenaPlaying) and (s.mode~="get_out" or s.result==nil or s.result=="active"))
end
function Router:IsBlocked()
 local s=self:Snapshot()
 return s.suspended or s.modal or s.admin or s.spectating or not s.alive
  or not (Scope:IsCombat() or Scope:IsGetOut())
  or Scope:IsArena() and not s.arenaPlaying
  or Scope:IsCTF() and not s.inMatch
  or Scope:IsGetOut() and Policy.Context(s)=="waiting"
end
function Router:IsAvailable(action,snapshot)
 local registered=listeners[action]
 if not registered then return false end
 local s=snapshot or self:Snapshot()
 if not Policy.Available(action,s) then return false end
 local scope=registered.scope
 if scope=="admin" and not s.admin or scope=="get_out" and s.mode~="get_out"
  or scope=="ctf" and s.mode~="ctf" or scope=="combat" and not Scope:IsCombat()
  or scope=="interaction" and not Scope:IsInteractive() and not (action=="ReloadInteract" and Scope:IsArena()) then return false end
 if registered.enabled and not registered.enabled(s) then return false end
 return true
end
local function cancelOwner(token,record)
 if record then record.callback(Enum.UserInputState.Cancel,record.input) end
 owners[token]=false -- Held keys cannot transfer to another context until released.
end
function Router:CancelAll()
 for token,record in owners do if record then cancelOwner(token,record) end end
end
function Router:Dispatch(action,state,input)
 local registered=listeners[action]
 if not registered then return Enum.ContextActionResult.Pass end
 local token=input or ("touch:"..action)
 local record=owners[token]
 if state==Enum.UserInputState.Cancel or state==Enum.UserInputState.End then
  if record and record.action==action then
   owners[token]=nil return record.callback(state,input) or Enum.ContextActionResult.Sink
  end
  if record==false then owners[token]=nil return Enum.ContextActionResult.Sink end
  return Enum.ContextActionResult.Pass
 end
 if not self:IsAvailable(action) then return Enum.ContextActionResult.Pass end
 if state~=Enum.UserInputState.Begin and not record then return Enum.ContextActionResult.Pass end
 if state==Enum.UserInputState.Begin and record~=nil then return Enum.ContextActionResult.Sink end
 local result=registered.callback(state,input) or Enum.ContextActionResult.Sink
 if state==Enum.UserInputState.Begin and result~=Enum.ContextActionResult.Pass then
  owners[token]={action=action,callback=registered.callback,input=input}
 end
 return result
end
local function route(name,state,input)
 local record=owners[input]
 if state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then
  if record then owners[input]=nil return record.callback(state,input) or Enum.ContextActionResult.Sink end
  if record==false then owners[input]=nil return Enum.ContextActionResult.Sink end
  return Enum.ContextActionResult.Pass
 end
 if record~=nil then
  if not record then return Enum.ContextActionResult.Sink end
  if not Router:IsAvailable(record.action) then cancelOwner(input,record) return Enum.ContextActionResult.Sink end
  return record.callback(state,input) or Enum.ContextActionResult.Sink
 end
 if state~=Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
 local s=Router:Snapshot() local candidates={}
 for action in listeners do
  if (Router:Key(action,"Keyboard")==name or Router:Key(action,"Gamepad")==name) and Router:IsAvailable(action,s) then table.insert(candidates,action) end
 end
 table.sort(candidates,function(a,b) local x,y=Policy.Priority(a),Policy.Priority(b) return x==y and a<b or x>y end)
 for _,action in candidates do
  local result=Router:Dispatch(action,state,input)
  if result~=Enum.ContextActionResult.Pass then return result end
 end
 -- UI navigation owns its own keys at a higher priority. Swallow world buttons
 -- below it so Tool.Activated/native jump cannot leak through a modal.
 if s.modal or s.suspended then owners[input]=false return Enum.ContextActionResult.Sink end
 return Enum.ContextActionResult.Pass
end
local function bind()
 Router:CancelAll()
 for name in bindings do CAS:UnbindAction("CrossgroundsInput:"..name) end
 table.clear(bindings)
 for action in listeners do
  for _,device in {"Keyboard","Gamepad"} do
   local name=Router:Key(action,device)
   if not bindings[name] then
    bindings[name]=true
    CAS:BindActionAtPriority("CrossgroundsInput:"..name,function(_,state,input)
     return route(name,state,input)
    end,false,5000,Definition:Input(name))
   end
  end
 end
end
function Router:Register(action,callback,options)
 assert(Definition.Actions[action],"Unknown control: "..tostring(action))
 local previous=listeners[action]
 if previous then
  for token,record in owners do if record and record.action==action then cancelOwner(token,record) end end
 end
 local registered=table.clone(options or {}) registered.callback=callback
 listeners[action]=registered bind()
end
local function reconcile()
 local s=Router:Snapshot()
 for token,record in owners do
  if record and not Router:IsAvailable(record.action,s) then cancelOwner(token,record) end
 end
 local context=s.suspended and "suspended" or Policy.Context(s)
 if Router.Context~=context then Router.Context=context contextChanged:Fire(context) end
end
UIS.WindowFocusReleased:Connect(function() focused=false Router:CancelAll() end)
UIS.WindowFocused:Connect(function() focused=true end)
UIS.TextBoxFocused:Connect(function() Router:CancelAll() end)
UIS.GamepadDisconnected:Connect(function() Router:CancelAll() end)
Gui.MenuOpened:Connect(function() Router:CancelAll() end)
player.CharacterRemoving:Connect(function() Router:CancelAll() end)
player.AttributeChanged:Connect(reconcile)
game:GetService("RunService").Heartbeat:Connect(reconcile)
function Router:Commit(action,device,name)
 local current={} for id in Definition.Actions do current[id]=self:Key(id,device) end
 local plan,reason=Policy.Plan(Definition,current,action,device,name)
 if not plan then return false,reason end
 self:CancelAll()
 for id,value in plan do if value~=current[id] then player:SetAttribute("Setting"..Definition:Attribute(id,device),value) end end
 update:FireServer(Definition:Attribute(action,device),name)
 return true
end
local function finish(success,name)
 if not capture then return end
 local request=capture capture=nil player:SetAttribute("Rebinding",false)
 if success then success=Router:Commit(request.action,request.device,name) end
 captureChanged:Fire(false,success and "Controle atualizado. Atalhos em conflito foram trocados." or "Controle não aplicado. Conflito ou captura cancelada; o anterior foi mantido.")
 local completedGeneration=generation
 task.delay(.15,function() if not capture and generation==completedGeneration then CAS:UnbindAction("CTFCaptureBinding") end end)
end
function Router:Capture(action,device)
 if capture or not Definition.Actions[action] or (device~="Keyboard" and device~="Gamepad") then return end
 Router:CancelAll()
 generation+=1 local token=generation
 capture={action=action,device=device,ready=os.clock()+.2,deadline=os.clock()+5}
 player:SetAttribute("Rebinding",true)
 local inputs={Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
 for _,key in Enum.KeyCode:GetEnumItems() do if key~=Enum.KeyCode.Unknown then table.insert(inputs,key) end end
 CAS:BindActionAtPriority("CTFCaptureBinding",function(_,state,input)
  if not capture then return Enum.ContextActionResult.Sink end
  if state==Enum.UserInputState.Begin and os.clock()>=capture.ready then
   if input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB and capture.device=="Keyboard" then finish(false) return Enum.ContextActionResult.Sink end
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
 self:CancelAll()
 for action,data in pairs(Definition.Actions) do
  for _,device in {"Gamepad","Keyboard"} do if not deviceOnly or deviceOnly==device then player:SetAttribute("Setting"..Definition:Attribute(action,device),data[device]) end end
 end
 update:FireServer("ResetControls",deviceOnly or true)
end
for action in pairs(Definition.Actions) do
 for _,device in {"Gamepad","Keyboard"} do
  player:GetAttributeChangedSignal("Setting"..Definition:Attribute(action,device)):Connect(function() bind() Icons:Refresh() changed:Fire() end)
 end
end
return Router
