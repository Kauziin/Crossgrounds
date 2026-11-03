-- Server-selected eliminator view, live until the victim respawns. No kill replay.
local Scope=require(script.Parent:WaitForChild("ModeScope"))
if not Scope:HasCombatRuntime() then return end
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local player=Players.LocalPlayer
local Settings=require(game.ReplicatedStorage.ExperienceSettings)
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local state
local gui=Instance.new("ScreenGui") gui.Name="EliminatorView" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=25 gui.Parent=player:WaitForChild("PlayerGui")
local caption=Instance.new("TextLabel") caption.Name="Eliminator" caption.AnchorPoint=Vector2.new(.5,1) caption.Position=UDim2.fromScale(.5,.84)
caption.Size=UDim2.new(.9,0,0,48) caption.BackgroundTransparency=1 caption.Font=Enum.Font.GothamBold caption.TextSize=20 caption.TextColor3=Color3.new(1,1,1) caption.TextStrokeTransparency=.35 caption.TextWrapped=true caption.Visible=false caption.Parent=gui
local identity=require(script.Parent:WaitForChild("PlayerIdentityView")).new(gui)
identity.Frame.AnchorPoint=Vector2.new(.5,1) identity.Frame.Position=UDim2.fromScale(.5,.76) identity.Frame.Size=UDim2.new(.9,0,0,126) identity.Frame.Visible=false
local constraint=Instance.new("UISizeConstraint") constraint.MaxSize=Vector2.new(470,126) constraint.Parent=identity.Frame
local function stop()
 if not state then return end state=nil caption.Visible=false identity.Frame.Visible=false player:SetAttribute("SpectatingEliminator",false)
 local camera=workspace.CurrentCamera local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 camera.CameraType=Enum.CameraType.Custom if h then camera.CameraSubject=h end
 camera.FieldOfView=player:GetAttribute("SettingFieldOfView") or Settings.Rules.FieldOfView.Default
end
game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("CombatFeedback").OnClientEvent:Connect(function(message)
 if message.kind~="Eliminated" or not Scope:IsCombat() or message.character~=player.Character then return end
 local victimHumanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 local preview=Run:IsStudio()and message.studioPreview==true
 if victimHumanoid and victimHumanoid.Health>0 and not preview then return end
 local killer=message.killer
 if typeof(killer)~="Instance" or not killer:IsA("Model") or killer==player.Character or not killer:IsDescendantOf(workspace) then killer=nil end
 if not killer and type(message.identity)~="table" then return end
 Nav:OpenMenu("Resume")
 state={preview=preview,victim=message.character,killer=killer,name=tostring(message.killerName or killer and killer.Name or "Jogador"),weapon=tostring(message.weapon or ""),cf=workspace.CurrentCamera.CFrame}
 if type(message.identity)=="table" then identity:Render(message.identity) identity.Frame.Visible=true end
 player:SetAttribute("SpectatingEliminator",true) caption.Visible=true
end)
player.CharacterAdded:Connect(stop)
player.CharacterRemoving:Connect(stop)
Scope.Changed:Connect(stop)
Run:BindToRenderStep("CrossgroundsEliminatorView",Enum.RenderPriority.Camera.Value+2,function(dt)
 local view=state if not view then return end
 local victimHumanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if player.Character~=view.victim or not Scope:IsCombat() or victimHumanoid and victimHumanoid.Health>0 and not view.preview then stop() return end
 local camera=workspace.CurrentCamera local killer=view.killer
 local h=killer and killer:FindFirstChildOfClass("Humanoid") local root=killer and killer:FindFirstChild("HumanoidRootPart")
 if killer and killer:IsDescendantOf(workspace) and h and h.Health>0 and root then
  local focus=root.Position+Vector3.new(0,1.5,0)
  local desired=focus-root.CFrame.LookVector*7+Vector3.new(0,2.3,0)
  local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={killer,view.victim}
  local hit=workspace:Raycast(focus,desired-focus,params)
  local position=hit and hit.Position+hit.Normal*.35 or desired
  if (position-focus).Magnitude>.1 then view.cf=view.cf:Lerp(CFrame.lookAt(position,focus),1-math.exp(-dt*10)) end
  camera.Focus=CFrame.new(focus)
 end
 -- If the killer dies/leaves, hold the last view instead of revealing another enemy.
 camera.CameraType=Enum.CameraType.Scriptable camera.CFrame=view.cf
 camera.FieldOfView=player:GetAttribute("SettingFieldOfView") or Settings.Rules.FieldOfView.Default
 caption.Text="ELIMINADO POR "..view.name.." · "..view.weapon.."\nAguardando renascimento"
end)
script.Destroying:Connect(function() stop() Run:UnbindFromRenderStep("CrossgroundsEliminatorView") gui:Destroy() end)

