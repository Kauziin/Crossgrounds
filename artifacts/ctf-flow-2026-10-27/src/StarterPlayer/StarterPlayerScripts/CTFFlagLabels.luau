-- World objective text is local to participants physically inside the active CTF map.
local player=game.Players.LocalPlayer
local Run=game:GetService("RunService")
local arena local labels={} local elapsed=0 local added
local function track(obj)
 if (obj:IsA("BillboardGui") or obj:IsA("SurfaceGui")) and obj.Name=="FlagLabel" then table.insert(labels,obj) obj.Enabled=false end
end
local function refreshArena()
 local current=workspace:FindFirstChild("CTFInfrastructure")
 if current==arena then return end
 if added then added:Disconnect() added=nil end
 arena=current table.clear(labels)
 if arena then
  added=arena.DescendantAdded:Connect(track)
  for _,obj in arena:GetDescendants() do track(obj) end
 end
end
Run.Heartbeat:Connect(function(dt)
 elapsed+=dt if elapsed<.15 then return end elapsed=0 refreshArena()
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 local visible=arena~=nil and root~=nil and h~=nil and h.Health>0
  and player:GetAttribute("CrossgroundsMode")=="ctf" and player:GetAttribute("InArena")==true
  and workspace:GetAttribute("RoundState")=="Playing" and player:GetAttribute("AdminFreecam")~=true
 if visible then
  local center=arena:GetAttribute("PlayRegionCenter") or Vector3.new(0,60,0)
  local size=arena:GetAttribute("PlayRegionSize") or Vector3.new(420,160,240)
  local delta=root.Position-center local half=size*.5
  visible=math.abs(delta.X)<=half.X and math.abs(delta.Y)<=half.Y and math.abs(delta.Z)<=half.Z
 end
 for _,gui in labels do if gui.Parent and gui.Enabled~=visible then gui.Enabled=visible end end
end)
refreshArena()


-- Carrier indicators are client-owned and only visible to active CTF participants.
local Tween=game:GetService("TweenService")
local indicators={}
local hud=Instance.new("ScreenGui") hud.Name="CTFFlagAlerts" hud.ResetOnSpawn=false hud.IgnoreGuiInset=false hud.DisplayOrder=85 hud.Enabled=false hud.Parent=player:WaitForChild("PlayerGui")
local toast=Instance.new("TextLabel") toast.Name="Alert" toast.AnchorPoint=Vector2.new(.5,0) toast.Position=UDim2.new(.5,0,0,100)
toast.Size=UDim2.new(.9,0,0,76) toast.BackgroundColor3=Color3.fromRGB(33,19,24) toast.TextColor3=Color3.fromRGB(255,239,221)
toast.TextSize=21 toast.TextWrapped=true toast.Font=Enum.Font.GothamBold toast.Visible=false toast.BorderSizePixel=0 toast.Parent=hud
local cap=Instance.new("UISizeConstraint") cap.MaxSize=Vector2.new(640,100) cap.Parent=toast
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,10) corner.Parent=toast
local border=Instance.new("UIStroke") border.Thickness=2 border.Color=Color3.fromRGB(255,104,86) border.Parent=toast
local pad=Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0,14) pad.PaddingRight=UDim.new(0,14) pad.Parent=toast
local persistent=toast:Clone() persistent.Name="CarrierStatus" persistent.Position=UDim2.new(.5,0,0,184) persistent.Size=UDim2.new(.9,0,0,46)
persistent.TextSize=15 persistent.BackgroundTransparency=.12 persistent.Parent=hud
local queue={}local showing=false local generation=0
local function participating()
 return player:GetAttribute("CrossgroundsMode")=="ctf" and player:GetAttribute("InMatch")==true and player:GetAttribute("AdminFreecam")~=true
end
local function color(team) return team=="Blue" and Color3.fromRGB(80,178,255) or Color3.fromRGB(255,103,91) end
local function flagName(team) return team=="Blue" and "azul" or "vermelha" end
local function playAlerts()
 if showing then return end showing=true
 local serial=generation
 task.spawn(function()
  while #queue>0 and participating() and serial==generation do
   local item=table.remove(queue,1) toast.Text=item.text border.Color=item.color toast.Visible=true
   toast.BackgroundTransparency=.05 toast.TextTransparency=0
   if not player:GetAttribute("SettingReducedMenuMotion") then
    toast.Position=UDim2.new(.5,0,0,90)
    Tween:Create(toast,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(.5,0,0,100)}):Play()
   end
   local untilTime=os.clock()+3.5
   repeat task.wait(.1) until os.clock()>=untilTime or not participating() or serial~=generation
   if serial~=generation then return end
   toast.Visible=false
  end
  if serial==generation then showing=false end
 end)
end
local function forget(team)
 local item=indicators[team] if not item then return end
 item.highlight:Destroy() item.label:Destroy() indicators[team]=nil
end
local tick=0
Run.Heartbeat:Connect(function(dt)
 tick+=dt if tick<.15 then return end tick=0
 local on=participating() hud.Enabled=on
 local inRound=on and player:GetAttribute("InArena")==true and workspace:GetAttribute("RoundState")=="Playing"
 local current=workspace:FindFirstChild("CTFInfrastructure")
 local lines={}
 for _,team in {"Blue","Red"} do
  local base=current and current:FindFirstChild(team.."Base")local ref=base and base:FindFirstChild("FlagCarrier")
  local carrier=ref and ref.Value local root=carrier and carrier:FindFirstChild("HumanoidRootPart")
  local valid=inRound and base~=nil and base:GetAttribute("FlagState")=="carried" and root~=nil
  local item=indicators[team]
  if item and (not valid or item.character~=carrier) then forget(team) item=nil end
  if valid then
   local own=player.Team and player.Team.Name==team
   if not item then
    local highlight=Instance.new("Highlight") highlight.Name="CTFFlagCarrierHighlight" highlight.Adornee=carrier highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency=.7 highlight.OutlineTransparency=0 highlight.FillColor=color(team) highlight.OutlineColor=own and Color3.fromRGB(255,230,100) or color(team) highlight.Parent=carrier
    local label=Instance.new("BillboardGui") label.Name="CTFCarrierMarker" label.Adornee=root label.Size=UDim2.fromOffset(220,48)label.StudsOffsetWorldSpace=Vector3.new(0,5.5,0)label.AlwaysOnTop=true label.MaxDistance=1400 label.Parent=carrier
    local text=Instance.new("TextLabel")text.Size=UDim2.fromScale(1,1)text.BackgroundColor3=Color3.fromRGB(12,19,28)text.BackgroundTransparency=.15 text.BorderSizePixel=0 text.TextColor3=color(team)text.Font=Enum.Font.GothamBold text.TextSize=14 text.TextWrapped=true text.Parent=label
    Instance.new("UICorner",text).CornerRadius=UDim.new(0,6)
    item={character=carrier,highlight=highlight,label=label,text=text} indicators[team]=item
   end
   local name=base:GetAttribute("FlagCarrierName") or carrier.Name
   item.text.Text=name.."\nBANDEIRA "..string.upper(flagName(team))
   if carrier==player.Character then
    table.insert(lines,"LEVE À BASE: você está com a bandeira "..flagName(team).."!")
   else
    table.insert(lines,(own and "INTERCEPTE: " or "ESCOLTE: ")..name..(own and " está com a sua bandeira!" or " está com a bandeira "..flagName(team).."!"))
   end
  end
 end
 persistent.Visible=#lines>0 persistent.Text=table.concat(lines,"\n") persistent.Size=UDim2.new(.9,0,0,#lines>1 and 64 or 46)
 if not on then
  generation+=1 table.clear(queue) showing=false toast.Visible=false persistent.Visible=false
 end
end)
task.spawn(function()
 local remote=game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("CTFFlagAlert")
 remote.OnClientEvent:Connect(function(data)
  if not participating() or typeof(data)~="table" or (data.team~="Blue" and data.team~="Red") then return end
  local own=player.Team and player.Team.Name==data.team
  local target=own and "a sua bandeira" or "a bandeira "..flagName(data.team)
  local name=data.self and "Você" or tostring(data.carrier or "Jogador")
  local message
  if data.kind=="pickup" then message=data.self and ("Você está com "..target.."! Leve-a à sua base.") or (name.." está com "..target.."!")
  elseif data.kind=="drop" then message=name.." deixou "..target.." cair!"
  elseif data.kind=="return" then message=own and "Sua bandeira voltou à base!" or "A bandeira "..flagName(data.team).." voltou à base!"
  elseif data.kind=="capture" then message=name.." capturou "..target.."!" end
  if not message then return end
  if #queue>=4 then table.remove(queue,1)end
  table.insert(queue,{text=message,color=own and Color3.fromRGB(255,115,83) or color(data.team)}) playAlerts()
 end)
end)
