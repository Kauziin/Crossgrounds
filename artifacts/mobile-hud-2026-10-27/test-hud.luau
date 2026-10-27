-- Runs only in the plugin test environment; injects input signals without changing production bindings.
return function(sources)
 local actualGame=game
 local roots={}
 local function signal()
  local callbacks={} local s={}
  function s:Connect(fn) table.insert(callbacks,fn) return {Disconnect=function() end} end
  function s:Fire(...) for _,fn in callbacks do fn(...) end end
  return s
 end
 local captured={}
 local function wire(object,event,callback) captured[object]=captured[object] or {} captured[object][event]=callback end
 local attributes={CrossgroundsAdmin=true}
 local core=actualGame:GetService("CoreGui")
 local p={PlayerGui=core}
 function p:WaitForChild(n) return self[n] end
 function p:GetAttribute(n) return attributes[n] end
 function p:SetAttribute(n,v) attributes[n]=v end
 local UIS={InputChanged=signal(),InputEnded=signal(),WindowFocusReleased=signal()}
 function UIS:GetFocusedTextBox() return nil end
 local run={RenderStepped=signal()}
 local scope={Changed=signal(),IsCombat=function() return true end,IsArena=function() return false end}
 local mode={Changed=signal(),Get=function() return Enum.PreferredInput.Touch end}
 local callbacks={} local focused local dispatches={} local saved
 local nav={MenuRequested=signal(),FocusChanged=signal()}
 function nav:Register(o,fn,adjust) callbacks[o]=fn end
 function nav:Connect(o,fn) callbacks[o]=fn end
 function nav:SetBack() end
 function nav:Focus(o) focused=o end
 function nav:GetFocus() return focused end
 function nav:OpenMenu(id) self.MenuRequested:Fire(id) end
 local cas={}
 function cas:BindActionAtPriority(_,fn) self.callback=fn end
 local router={IsBlocked=function() return false end,Dispatch=function(_,...) table.insert(dispatches,{...}) end}
 local layout=assert(loadstring(sources.MobileLayout))()
 local env=setmetatable({script=actualGame.ReplicatedStorage.ExperienceSettings,require=function(object)
  if object==actualGame.ReplicatedStorage.Crossgrounds.MobileLayout then return layout end
  return require(object)
 end},{__index=getfenv()})
 local settingsFn=assert(loadstring(sources.ExperienceSettings)) setfenv(settingsFn,env) local settings=settingsFn()
 local art=assert(loadstring(sources.TouchActionIcons))()
 local rs={ExperienceSettings="ExperienceSettings",Crossgrounds={MobileLayout="MobileLayout"},Events={UpdateExperienceSetting={FireServer=function(_,key,v) saved=v end}}}
 function rs:WaitForChild(n) return self[n] end function rs.Crossgrounds:WaitForChild(n) return self[n] end function rs.Events:WaitForChild(n) return self[n] end
 local services={UserInputService=UIS,RunService=run,ContextActionService=cas,GuiService={MenuIsOpen=false}}
 local fakeGame={Players={LocalPlayer=p},ReplicatedStorage=rs,GetService=function(_,n) return services[n] end}
 local modules={ModeScope=scope,InputMode=mode,ControlRouter=router,MenuNavigation=nav,InputIcons={},ExperienceSettings=settings,MobileLayout=layout,TouchActionIcons=art}
 local function execute()
  local source=sources.MobileHUD
  for _,name in {"b","canvas"} do source=source:gsub(name..'%.InputBegan:Connect%(', 'wire('..name..',"InputBegan",') end
  local fn=assert(loadstring(source))
  setfenv(fn,setmetatable({game=fakeGame,script={Parent={WaitForChild=function(_,n) return n end}},wire=wire,require=function(n) return assert(modules[n],tostring(n)) end,Instance={new=function(class)
   local v=Instance.new(class) if class=="ScreenGui" then table.insert(roots,v) end return v
  end}},{__index=getfenv()}))
  fn()
  local gui=roots[1] local editor=gui.Editor local controls=gui.Controls
  local checks={}
  local function check(v,message) assert(v,message) table.insert(checks,message) end
  local function frame() run.RenderStepped:Fire() task.wait(.05) end
  nav:OpenMenu("MobileHUD") frame()
  check(not editor.Tools.Visible,"Inspector starts hidden")
  local count=0
  for _,b in editor:GetChildren() do if layout.Buttons[b.Name] then
   count+=1 check(b.Text=="" and not b:FindFirstChildWhichIsA("TextLabel",true),b.Name.." contains only icon artwork")
  end end
  check(count==15,"All fifteen touch actions preserved")
  for _,size in {Vector2.new(1366,768),Vector2.new(749,381),Vector2.new(390,844)} do
   editor.Size=UDim2.fromOffset(size.X,size.Y) controls.Size=editor.Size callbacks[editor.Toolbar.Reset]() frame()
   local b=editor.Fire local center=b.AbsolutePosition+b.AbsoluteSize/2
   local input={UserInputType=Enum.UserInputType.MouseButton1,Position=Vector3.new(center.X+7,center.Y+3,0)}
   captured[b].InputBegan(input) frame()
   check(editor.Tools.Visible,"Selection reveals compact properties "..tostring(size))
   local panelBefore=editor.Tools.Position
   local before=b.AbsolutePosition.X
   UIS.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseMovement,Position=input.Position+Vector3.new(-1.25,2.5,0)}) frame()
   check(math.abs(b.AbsolutePosition.X-before+1.25)<1.1,"Pixel drag has no percent grid snapping "..tostring(size))
   UIS.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseMovement,Position=input.Position+Vector3.new(-size.X,-size.Y,0)}) frame()
   local q=b.AbsolutePosition-editor.AbsolutePosition
   check(q.X>=1.9 and q.Y>=1.9,"Dragging stays within safe canvas "..tostring(size))
   check(editor.Tools.Position~=panelBefore,"Inspector moves away from dragged button "..tostring(size))
   UIS.InputEnded:Fire(input)
   captured[editor.Canvas].InputBegan({UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(editor.AbsolutePosition.X+size.X/2,editor.AbsolutePosition.Y+size.Y/2,0)})
   check(not editor.Tools.Visible,"Empty canvas deselects and hides properties "..tostring(size))
  end
  callbacks[editor.Toolbar.Cancel]() check(not attributes.HUDLayoutEditing and not saved,"Cancel discards pending edits")
  frame()
  check(controls.AdminMode.BackgroundTransparency>controls.Jump.BackgroundTransparency,"Idle admin controls have subtler contrast")
  local jump=controls.Jump local press={UserInputType=Enum.UserInputType.Touch,Position=Vector3.zero}
  captured[jump].InputBegan(press) UIS.InputEnded:Fire(press)
  check(dispatches[#dispatches][1]=="Jump" and dispatches[#dispatches][2]==Enum.UserInputState.End,"Gameplay touch press/release dispatch remains intact")
  nav:OpenMenu("MobileHUD") frame()
  local touchButton=editor.Jump local center=touchButton.AbsolutePosition+touchButton.AbsoluteSize/2
  local touch={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(center.X,center.Y,0)}
  captured[touchButton].InputBegan(touch) local touchBefore=touchButton.AbsolutePosition
  touch.Position+=Vector3.new(-17,9,0) UIS.InputChanged:Fire(touch) frame()
  check(math.abs(touchButton.AbsolutePosition.X-touchBefore.X+17)<1.1,"Touch movement follows the originating finger")
  local afterTouch=touchButton.AbsolutePosition
  UIS.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseMovement,Position=Vector3.new(10,10,0)}) frame()
  check(touchButton.AbsolutePosition==afterTouch,"Mouse movement cannot hijack touch drag")
  UIS.InputEnded:Fire(touch)
  local b=editor.Fire nav:Focus(b) attributes.MenuCursorPosition=Vector2.new(200,200)
  check(cas.callback(nil,Enum.UserInputState.Begin)==Enum.ContextActionResult.Sink,"Gamepad A starts HUD drag")
  frame() local before=b.AbsolutePosition.X attributes.MenuCursorPosition=Vector2.new(160,200) frame()
  check(math.abs(b.AbsolutePosition.X-before+40)<1.1,"Gamepad cursor moves selected button")
  cas.callback(nil,Enum.UserInputState.End)
  callbacks[editor.Toolbar.Save]()
  check(saved and saved.TouchFireX==attributes.SettingTouchFireX,"Save uses existing layout remote and attributes")
  check(math.abs(settings:Sanitize("TouchFireX",.51237)-.5124)<1e-8,"Saved coordinates retain four-decimal precision")
  nav:OpenMenu("MobileHUD") frame() callbacks[editor.Toolbar.Reset]() callbacks[editor.Toolbar.Save]()
  check(saved.TouchFireX==layout.Buttons.Fire.X,"Reset restores original layout defaults")
  return checks
 end
 local ok,result=xpcall(execute,debug.traceback)
 for _,v in roots do v:Destroy() end
 assert(ok,result) return result
end
