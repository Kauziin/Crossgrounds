local Scope=require(script.Parent:WaitForChild("ModeScope"))
if not Scope:HasCombatRuntime() then return end
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local events=game.ReplicatedStorage:WaitForChild("Events")
local action=events:WaitForChild("WeaponAction") local reload=events:WaitForChild("WeaponReload")
local Kits=require(game.ReplicatedStorage:WaitForChild("KitDefinitions"))
local Presentation=require(script.Parent:WaitForChild("CombatPresentation"))
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local Interaction=require(script.Parent:WaitForChild("InteractionController"))
local prediction=require(game.ReplicatedStorage.Crossgrounds.ShotPrediction).new()
local held=false local nextUse=0 local equipped local shotSequence=0
local gui=Instance.new("ScreenGui") gui.Name="WeaponHUD" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=19 gui.Parent=player:WaitForChild("PlayerGui")
local reticle=require(game.ReplicatedStorage.Crossgrounds.Reticle).new(gui,"Crosshair")
local cross=reticle.Root
local rangeText=Instance.new("TextLabel") rangeText.Name="RangeBand" rangeText.AnchorPoint=Vector2.new(.5,0)
rangeText.Size=UDim2.fromOffset(220,22) rangeText.BackgroundTransparency=1 rangeText.Font=Enum.Font.GothamMedium
rangeText.TextSize=12 rangeText.TextColor3=Color3.fromRGB(223,232,241) rangeText.TextStrokeTransparency=.4 rangeText.Visible=false rangeText.Parent=gui
local function scan()
 local c=player.Character local tool=c and c:FindFirstChildOfClass("Tool")
 if tool~=equipped then held=false Presentation:SetFiring(false) Presentation:ClearShots() equipped=tool nextUse=0 end
end
local function canUse()
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 return equipped and h and h.Health>0 and not Presentation:IsBlocked()
end
local function use()
 if not canUse() or os.clock()<nextUse then return end
 local data=Kits.Weapons[equipped:GetAttribute("WeaponId")] if not data then return end
 if equipped:GetAttribute("Reloading") then return end
 if data.Kind=="Gun" and prediction:Available(equipped)<=0 then reload:FireServer(equipped) nextUse=os.clock()+.3 return end
 local now=os.clock() local cooldown=Scope:IsArena() and data.SourcePack~="ProjectileTest" and math.max(1,data.Cooldown) or data.Cooldown
 -- Preserve the schedule across small frame overruns; never send a catch-up burst.
 nextUse=nextUse==0 and now+cooldown or math.max(nextUse+cooldown,now+cooldown-.025)
 local target,cameraOrigin,cameraDirection,hit=Presentation:GetAimWorld(data.Range+12)
 local request={version=1,time=workspace:GetServerTimeNow(),cameraOrigin=cameraOrigin,cameraDirection=cameraDirection}
 -- Position is an observation hint, never an authoritative hit/damage report.
 local model=hit and require(game.ReplicatedStorage.Crossgrounds.ShotQuery).ModelFromPart(hit.Instance)
 if model then request.view={part=hit.Instance,position=hit.Instance.Position} end
 local shotId
 if data.Kind=="Gun" then shotSequence+=1 shotId=shotSequence prediction:Reserve(shotId,equipped,now) Presentation:PredictShot(shotId,equipped,target,request) end
 action:FireServer(equipped,target,Presentation:GetShotOrigin(),shotId,request)
end
Router:Register("Fire",function(state,input)
 if state==Enum.UserInputState.Begin then
  if not canUse() or input.UserInputType==Enum.UserInputType.MouseButton1 and Presentation:PointerOverButton() then return Enum.ContextActionResult.Pass end
  held=true Presentation:SetFiring(true) use()
 elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then held=false Presentation:SetFiring(false) end
 return Enum.ContextActionResult.Sink
end,{touch=true,title="TIRO",position=UDim2.fromScale(.87,.58)})
Router:Register("ReloadInteract",function(state)
 if state==Enum.UserInputState.Begin then
  scan() local data=equipped and Kits.Weapons[equipped:GetAttribute("WeaponId")]
  if Interaction:Nearest() then Interaction:Begin()
  elseif canUse() and data and data.Kind=="Gun" and not equipped:GetAttribute("Reloading")
   and (equipped:GetAttribute("Ammo") or 0)<data.Magazine and (equipped:GetAttribute("ReserveAmmo") or 0)>0 then
   reload:FireServer(equipped)
  end
 else Interaction:End() end
 return Enum.ContextActionResult.Sink
end,{touch=true,title="RECARGA / USAR",position=UDim2.fromScale(.74,.7),scope="interaction"})
Router:Register("Aim",function(state)
 if state==Enum.UserInputState.Begin then
  if not canUse() then return Enum.ContextActionResult.Pass end
  Presentation:SetAiming(true)
 else Presentation:SetAiming(false) end
 return Enum.ContextActionResult.Sink
end,{touch=true,title="MIRA",position=UDim2.fromScale(.9,.34)})
Router:Register("SwitchWeapon",function(state)
 if state==Enum.UserInputState.Begin and not Presentation:IsBlocked() then
  local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") local profile=Kits.Profiles[player:GetAttribute("SelectedKit")]
  local weapons=require(script.Parent.ModeScope):IsArena() and {Kits.ArenaWeapons[1],Kits.ArenaGunId(player:GetAttribute("ArenaPistolVisual"))} or profile and profile.Weapons
  if not h or not weapons or h.Health<=0 then return end
  local id=equipped and equipped:GetAttribute("WeaponId") local nextId=weapons[1]==id and weapons[2] or weapons[1]
  for _,container in {player.Backpack,c} do for _,t in container:GetChildren() do if t:IsA("Tool") and t:GetAttribute("WeaponId")==nextId then h:EquipTool(t) return end end end
 end
end)
events:WaitForChild("CombatFeedback").OnClientEvent:Connect(function(data)
 if data.kind=="Shot" and not data.shotId then Presentation:Kick(data.weapon) end
end)
events:WaitForChild("ShotResult").OnClientEvent:Connect(function(message)
 prediction:Confirm(message) Presentation:ConfirmShot(message)
 player:SetAttribute("LastShotAccepted",message.accepted) player:SetAttribute("LastShotReason",message.reason)
end)
events:WaitForChild("ShotVisual").OnClientEvent:Connect(function(message) Presentation:RenderShot(message) end)
player.CharacterRemoving:Connect(function() prediction:Clear() Presentation:ClearShots() end)
UIS.WindowFocusReleased:Connect(function() held=false Presentation:SetFiring(false) end)
RunService:BindToRenderStep("CTFWeaponInput",Enum.RenderPriority.Camera.Value+3,function()
 scan() prediction:Prune(os.clock())
 if equipped then equipped:SetAttribute("PredictedAmmo",prediction:Available(equipped)) end
 local data=equipped and Kits.Weapons[equipped:GetAttribute("WeaponId")]
 cross.Visible=data and data.Kind=="Gun" and canUse() or false
 rangeText.Visible=false
 if data then
  reticle:Update(function(key) local v=player:GetAttribute("Setting"..key) if v==nil then v=require(game.ReplicatedStorage.ExperienceSettings).Rules[key].Default end return v end,math.clamp((player.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude/30)+(held and .25 or 0),0,1))
  local point=Presentation:GetAimViewport()
  cross.Position=UDim2.fromOffset(point.X,point.Y)
  local hit,origin=Presentation:GetRangeTarget()
  local model=hit and require(game.ReplicatedStorage.Crossgrounds.ShotQuery).ModelFromPart(hit.Instance)
  if cross.Visible and player:GetAttribute("CombatAiming") and model and origin then
   rangeText.Text=Kits.RangeBand(data,(hit.Position-origin).Magnitude)
   rangeText.Position=UDim2.fromOffset(point.X,point.Y+32) rangeText.Visible=true
  end
  if held and data.Kind=="Gun" and data.Automatic then use() end
 end
 if Presentation:IsBlocked() then held=false Presentation:SetFiring(false) end
end)
