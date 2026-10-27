local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Interaction={}
local Prompts=game:GetService("ProximityPromptService") local Run=game:GetService("RunService")
local player=game.Players.LocalPlayer local Router=require(script.Parent:WaitForChild("ControlRouter")) local Icons=require(script.Parent:WaitForChild("InputIcons")) local Mode=require(script.Parent:WaitForChild("InputMode"))
local visible={} local holding local holdingAt=0
local gui=Instance.new("ScreenGui") gui.Name="AccessibleInteractionHUD" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=17 gui.Parent=player:WaitForChild("PlayerGui")
local button=Instance.new("TextButton") button.Name="Interact" button.AnchorPoint=Vector2.new(.5,.5) button.Position=UDim2.fromScale(.5,.7) button.Size=UDim2.fromOffset(300,48) button.BackgroundColor3=Color3.fromRGB(24,39,57) button.BorderSizePixel=0 button.Text="" button.Visible=false button.Parent=gui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,8) corner.Parent=button
local progress=Instance.new("Frame") progress.Name="HoldProgress" progress.AnchorPoint=Vector2.new(0,1) progress.Position=UDim2.fromScale(0,1) progress.Size=UDim2.fromScale(0,.08) progress.BorderSizePixel=0 progress.BackgroundColor3=Color3.fromRGB(102,209,186) progress.Parent=button
local glyph,refresh=Icons:Glyph(button,"Key",function() return Router:Key("ReloadInteract",Mode:Get()==Enum.PreferredInput.Gamepad and "Gamepad" or "Keyboard") end,32) glyph.Position=UDim2.fromOffset(8,8)
local label=Instance.new("TextLabel") label.Position=UDim2.fromOffset(48,0) label.Size=UDim2.fromOffset(244,48) label.BackgroundTransparency=1 label.Font=Enum.Font.GothamMedium label.TextSize=14 label.TextColor3=Color3.fromRGB(232,241,255) label.Parent=button
local function configure(prompt)
 if not prompt:IsA("ProximityPrompt") then return end
 visible[prompt]=true
 prompt.Style=Enum.ProximityPromptStyle.Custom
 prompt.GamepadKeyCode=Enum.KeyCode.Unknown prompt.KeyboardKeyCode=Enum.KeyCode.Unknown
end
for _,v in workspace:GetDescendants() do if v:IsA("ProximityPrompt") then configure(v) end end
workspace.DescendantAdded:Connect(function(v) if v:IsA("ProximityPrompt") then configure(v) end end)
Prompts.PromptShown:Connect(function(prompt) visible[prompt]=true end)
Prompts.PromptHidden:Connect(function(prompt) if holding==prompt then Interaction:End() end end)
function Interaction:Nearest()
 if not Scope:IsInteractive() then return end
 if Scope:IsGetOut() then local state=player:GetAttribute("GetOutVictimState") if state and state~="Active" and state~="Crawling" then return end end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart") if not root then return end
 local nearest local distance=math.huge
 for prompt in pairs(visible) do if not prompt:IsDescendantOf(workspace) then visible[prompt]=nil end end
 for prompt in pairs(visible) do
  if prompt.Parent and prompt.Enabled and (not Scope:IsGetOut() or not prompt:GetAttribute("GetOutRole") or prompt:GetAttribute("GetOutRole")==player:GetAttribute("GetOutRole")) then
   local parent=prompt.Parent local pos=parent:IsA("Attachment") and parent.WorldPosition or parent:IsA("BasePart") and parent.Position or parent:IsA("Model") and parent:GetPivot().Position
   if pos then
    local d=(pos-root.Position).Magnitude local line=true
    if prompt.RequiresLineOfSight and d<=prompt.MaxActivationDistance+1 then
     local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={player.Character}
     local hit=workspace:Raycast(root.Position,pos-root.Position,params)
     line=not hit or hit.Instance==parent or hit.Instance:IsDescendantOf(parent)
    end
    if line and d<=prompt.MaxActivationDistance+1 and (d<distance-.01 or math.abs(d-distance)<.01 and (not nearest or prompt:GetFullName()<nearest:GetFullName())) then distance=d nearest=prompt end
   end
  end
 end
 return nearest
end
function Interaction:Begin()
 local prompt=self:Nearest() if not prompt or Router:IsBlocked() then return false end
 self:End() holding=prompt holdingAt=os.clock() prompt:InputHoldBegin() return true
end
function Interaction:End() if holding then local old=holding holding=nil if old.Parent then old:InputHoldEnd() end end end
button.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then Interaction:Begin() end end)
button.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then Interaction:End() end end)
Router.Changed:Connect(refresh) Mode.Changed:Connect(refresh)
local elapsed=0
Run.RenderStepped:Connect(function(dt)
 elapsed+=dt if elapsed<.1 then return end elapsed=0
 local prompt=Interaction:Nearest() button.Visible=prompt~=nil and not Router:IsBlocked()
 local fraction=holding and holding==prompt and math.clamp((os.clock()-holdingAt)/math.max(.01,holding.HoldDuration),0,1) or 0
 progress.Size=UDim2.fromScale(fraction,.08)
 if prompt then label.Text=prompt.ActionText..(fraction>0 and (" · "..math.floor(fraction*100).."%") or prompt.HoldDuration>0 and " · SEGURAR" or "") end
 if holding and holding~=prompt then Interaction:End() end
 if Router:IsBlocked() then Interaction:End() end
end)
return Interaction

