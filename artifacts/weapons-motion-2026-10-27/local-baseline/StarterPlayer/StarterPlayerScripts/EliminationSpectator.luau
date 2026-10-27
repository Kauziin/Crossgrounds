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
local function stop()
 if not state then return end state=nil caption.Visible=false player:SetAttribute("SpectatingEliminator",false)
 local camera=workspace.CurrentCamera local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 camera.CameraType=Enum.CameraType.Custom if h then camera.CameraSubject=h end
 camera.FieldOfView=player:GetAttribute("SettingFieldOfView") or Settings.Rules.FieldOfView.Default
end
game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("CombatFeedback").OnClientEvent:Connect(function(message)
 if message.kind~="Eliminated" or not Scope:IsCombat() or message.character~=player.Character then return end
 local killer=message.killer
 if typeof(killer)~="Instance" or not killer:IsA("Model") or killer==player.Character or not killer:IsDescendantOf(workspace) then return end
 Nav:OpenMenu("Resume")
 state={victim=message.character,killer=killer,name=tostring(message.killerName or killer.Name),cf=workspace.CurrentCamera.CFrame}
 player:SetAttribute("SpectatingEliminator",true) caption.Visible=true
end)
player.CharacterAdded:Connect(stop)
player.CharacterRemoving:Connect(stop)
Scope.Changed:Connect(stop)
Run:BindToRenderStep("CrossgroundsEliminatorView",Enum.RenderPriority.Camera.Value+2,function(dt)
 local view=state if not view then return end
 if player.Character~=view.victim or not Scope:IsCombat() then stop() return end
 local camera=workspace.CurrentCamera local killer=view.killer
 local h=killer:FindFirstChildOfClass("Humanoid") local root=killer:FindFirstChild("HumanoidRootPart")
 if killer:IsDescendantOf(workspace) and h and h.Health>0 and root then
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
 caption.Text="ELIMINADO POR "..view.name.."\nAguardando renascimento"
end)
script.Destroying:Connect(function() stop() Run:UnbindFromRenderStep("CrossgroundsEliminatorView") gui:Destroy() end)

