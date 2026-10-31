local p=game.Players.LocalPlayer
local report=Instance.new("StringValue") report.Name="ControlSubsystemRuntimeReport" report.Parent=game.ReplicatedStorage
local results={} local count=0
local function check(value,name) count+=1 assert(value,name) table.insert(results,name) end
local function run()
 local deadline=os.clock()+30
 repeat task.wait(.1) until p:GetAttribute("CrossgroundsMode")=="hub" or os.clock()>deadline
 task.wait(2)
 local r=require(script.Parent.ControlRouter)
 local nav=require(script.Parent.MenuNavigation)
 local readyDeadline=os.clock()+30
 repeat task.wait(.1) until (not r:Snapshot().suspended and r:Snapshot().alive) or os.clock()>readyDeadline
 local function press(action)
  local result=r:Dispatch(action,Enum.UserInputState.Begin)
  r:Dispatch(action,Enum.UserInputState.End)
  return result
 end
 nav:OpenMenu("Resume") task.wait(.5)
 check(not r:Snapshot().modal,"Hub menu closes")
 check(r:CanMove(),"Native movement enabled outside menu")
 local oldInventory=p:GetAttribute("InventoryOpen")
 p:SetAttribute("InventoryOpen",true) task.wait(.1)
 check(r:IsBlocked() and not r:CanMove(),"Inventory blocks movement and world actions")
 check(press("ReloadInteract")==Enum.ContextActionResult.Pass,"Inventory denies interaction")
 p:SetAttribute("InventoryOpen",oldInventory)
 nav:OpenMenu("Settings") task.wait(.3)
 check(p:GetAttribute("ExperienceMenuOpen")==true,"Settings open through navigation")
 check(r.Context=="menu" and not r:CanMove(),"Settings own context and movement")
 local g=p.PlayerGui.ExperienceMenu
 local function title()
  local texts={}
  for _,v in g:GetDescendants() do
   if v:IsA("TextLabel") and (v.Name=="Title" or v.Name=="Heading") then table.insert(texts,v.Text) end
  end
  return table.concat(texts,"|")
 end
 local before=title()
 check(press("MenuNext")==Enum.ContextActionResult.Sink,"RB category action is consumed")
 task.wait(.1)
 check(title()~=before,"RB changes rendered category")
 press("MenuPrevious") task.wait(.1)
 check(press("AdminMode")==Enum.ContextActionResult.Pass,"Menu prevents admin activation")
 nav:OpenMenu("Resume") task.wait(.3)
 check(press("AdminMode")==Enum.ContextActionResult.Sink,"Admin mode can activate outside menus")
 task.wait(1)
 check(p:GetAttribute("AdminFreecam")==true,"Server accepts authorized admin spectator")
 check(r:CanMove(),"Spectator reuses normal movement")
 local controls=require(p.PlayerScripts.PlayerModule):GetControls()
 check(controls.controlsEnabled==true,"Native controls remain enabled for spectator")
 local help=p.PlayerGui.AdminCameraHelp:FindFirstChildOfClass("TextLabel")
 local speedText=help.Text
 press("AdminSpeedUp") task.wait(.1)
 check(help.Text~=speedText,"Shared admin bumper adjusts speed")
 nav:OpenMenu("Settings") task.wait(.3)
 local menuSpeed=help.Text
 check(not r:CanMove(),"Menu blocks spectator movement")
 check(press("AdminSpeedUp")==Enum.ContextActionResult.Pass,"Menu blocks admin speed action")
 press("MenuNext") task.wait(.1)
 check(help.Text==menuSpeed,"Category navigation does not alter admin speed")
 nav:OpenMenu("Resume") task.wait(.3)
 press("AdminMode") task.wait(1)
 check(p:GetAttribute("AdminFreecam")==false,"Admin mode exits and restores character")
 local oldKey=r:Key("ReloadInteract","Keyboard")
 check(r:Commit("ReloadInteract","Keyboard",r:Key("Fire","Keyboard")),"Rebinding submitted")
 task.wait(.5)
 check(r:Key("Fire","Keyboard")==oldKey and r:Key("GetOutAttack","Keyboard")==oldKey,"Server preserves every conflict swap")
 check(r:Commit("ReloadInteract","Keyboard",oldKey),"Session bindings restored")
 task.wait(.3)
 local cursorCount=0
 for _,v in p.PlayerGui:GetChildren() do if v.Name=="AccessibleMenuCursor" then cursorCount+=1 end end
 check(cursorCount==1,"Only one navigation instance")
 return {passed=count,checks=results}
end
local ok,result=xpcall(run,debug.traceback)
report.Value=game.HttpService:JSONEncode({ok=ok,result=result,checks=results})
