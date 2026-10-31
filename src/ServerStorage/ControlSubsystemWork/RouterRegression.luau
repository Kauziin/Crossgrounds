-- Run the WORKING router with controlled services; never binds live controls.
local work=script.Parent local P=require(work.Working.Shared.ControlPolicy)
local D=require(work.Working.Shared.ControlDefinitions)
local passed=0 local function check(v,m) passed+=1 assert(v,m) end
local events={}
local function signal() local e=Instance.new("BindableEvent") table.insert(events,e) return e end
local attrs={CrossgroundsMode="ctf",InMatch=true,CrossgroundsAdmin=true}
local changed=signal()
local pg=Instance.new("Folder") local character=Instance.new("Model")
local h=Instance.new("Humanoid") h.Parent=character
local p={PlayerGui=pg,Character=character,AttributeChanged=changed.Event,CharacterRemoving=signal().Event}
function p:GetAttribute(k) return attrs[k] end
function p:SetAttribute(k,v) attrs[k]=v changed:Fire(k) end
function p:GetAttributeChangedSignal(k) return signal().Event end
local u={WindowFocusReleased=signal().Event,WindowFocused=signal().Event,TextBoxFocused=signal().Event,GamepadDisconnected=signal().Event}
local textBox=nil
function u:GetFocusedTextBox() return textBox end
local cas={bindings={}}
function cas:UnbindAction(n) self.bindings[n]=nil end
function cas:BindActionAtPriority(n,callback) self.bindings[n]=callback end
local gui={MenuIsOpen=false,MenuOpened=signal().Event}
local tick=signal() local run={Heartbeat=tick.Event}
local updates={}
local remote={}
function remote:FireServer(...) table.insert(updates,{...}) end
local rs={Events={WaitForChild=function() return remote end}}
function rs:WaitForChild(n) return {Name=n} end
local scope={}
function scope:Get() return attrs.CrossgroundsMode end
function scope:IsCTF() return self:Get()=="ctf" end
function scope:IsArena() return self:Get()=="arena" end
function scope:IsGetOut() return self:Get()=="get_out" end
function scope:IsCombat() return self:IsCTF() or self:IsArena() end
function scope:IsInteractive() return self:IsCTF() or self:IsGetOut() end
local modules={ModeScope=scope,ControlPolicy=P,ControlDefinitions=D,ExperienceSettings={},InputIcons={Refresh=function() end}}
local fakeGame={Players={LocalPlayer=p},ReplicatedStorage=rs}
function fakeGame:GetService(n) return ({UserInputService=u,ContextActionService=cas,GuiService=gui,RunService=run})[n] end
local fn,err=loadstring(work.Working.Client.ControlRouter.Source)
assert(fn,err)
setfenv(fn,setmetatable({game=fakeGame,script={Parent={WaitForChild=function(_,n)return {Name=n}end}},require=function(m)return modules[m.Name]end},{__index=getfenv()}))
local router=fn()
local seen={}
local function register(action)
 seen[action]={}
 router:Register(action,function(state) table.insert(seen[action],state) return Enum.ContextActionResult.Sink end)
end
for _,action in {"Fire","GetOutAttack","Aim","Menu","AdminSpeedUp","AdminMode","MenuNext","MenuPrevious","ReloadInteract"} do register(action) end
local function input(name)
 local key=Enum.KeyCode.Unknown local kind=Enum.UserInputType.Keyboard
 if name:find("MouseButton") then kind=Enum.UserInputType[name] else key=Enum.KeyCode[name] end
 return {KeyCode=key,UserInputType=kind}
end
local function send(name,state,i)
 return cas.bindings["CrossgroundsInput:"..name]("",state,i)
end
local B,E,C=Enum.UserInputState.Begin,Enum.UserInputState.End,Enum.UserInputState.Cancel
local fire=input("MouseButton1")
send("MouseButton1",B,fire)
check(#seen.Fire==1 and #seen.GetOutAttack==0,"Combat key must choose Fire")
attrs.InventoryOpen=true tick:Fire() task.wait()
check(seen.Fire[2]==C,"Inventory must cancel held fire")
attrs.InventoryOpen=false tick:Fire() task.wait()
send("MouseButton1",Enum.UserInputState.Change,fire)
check(#seen.Fire==2,"Closing menu cannot restart held fire")
send("MouseButton1",E,fire)
check(#seen.Fire==2,"Release after cancel must not duplicate callback")
attrs.InventoryOpen=true
send("MouseButton1",B,input("MouseButton1"))
check(#seen.Fire==2,"Inventory blocks new interaction")
check(not router:CanMove(),"Inventory blocks movement")
attrs.InventoryOpen=false
attrs.AdminFreecam=true attrs.InMatch=false
local speed=input("ButtonR1")
send("ButtonR1",B,speed)
check(#seen.AdminSpeedUp==1,"Shared bumper selects admin speed")
attrs.GameMenuOpen=true attrs.ExperienceMenuOpen=true tick:Fire() task.wait()
check(seen.AdminSpeedUp[2]==C,"Menu cancels admin action")
send("ButtonR1",E,speed)
local nextInput=input("ButtonR1") send("ButtonR1",B,nextInput)
check(#seen.MenuNext==1 and #seen.AdminSpeedUp==2,"Menu bumper takes priority over admin")
send("ButtonR1",E,nextInput)
check(not router:CanMove(),"Admin movement blocked by menu")
attrs.GameMenuOpen=false attrs.ExperienceMenuOpen=false
check(router:CanMove(),"Admin movement resumes")
attrs.AdminFreecam=false attrs.CrossgroundsMode="get_out" attrs.GetOutRole="beast"
send("MouseButton1",B,input("MouseButton1"))
check(#seen.GetOutAttack==1,"Shared trigger selects beast attack")
-- Simulate focus/typing by driving the service events.
textBox={} tick:Fire() task.wait()
check(seen.GetOutAttack[2]==C,"Typing cancels held beast attack")
textBox=nil
attrs.CrossgroundsMode="ctf" attrs.InMatch=true attrs.GetOutRole=nil
local before=#updates
check(router:Commit("ReloadInteract","Keyboard","MouseButton1"),"Client multi-swap")
check(attrs.SettingBindFireKeyboard=="R" and attrs.SettingBindGetOutAttackKeyboard=="R","Client applies every conflict")
check(#updates==before+1,"One atomic request sent to server")
for _,e in events do e:Destroy() end
pg:Destroy() character:Destroy()
return {passed=passed}

