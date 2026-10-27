local Players=game:GetService("Players") local Run=game:GetService("RunService")
local player=Players.LocalPlayer
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Router=require(script.Parent:WaitForChild("ControlRouter"))
local remotes=game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("GetOutRemotes",30)
if not remotes then return end
local action=remotes:WaitForChild("Action") local load=remotes:WaitForChild("LoadReady")
local current local loading={} local cameraMode
load.OnClientEvent:Connect(function(token,name,expected)
 if loading[token] then return end loading[token]=true
 task.spawn(function()
  local deadline=os.clock()+20
  repeat
   local world=workspace:FindFirstChild(name)
   if world and world:GetAttribute("LoadToken")==token then
    local count=0 for _,v in world:GetDescendants() do if v:IsA("BasePart") then count+=1 end end
    local manifest=world:FindFirstChild("GetOut")
    if count>=expected and manifest and manifest:FindFirstChild("BeastSpawn") and manifest:FindFirstChild("SurvivorSpawns") then
     local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Include rp.FilterDescendantsInstances={world} rp.RespectCanCollide=true
     local ready=true local points={manifest.BeastSpawn} for _,p in manifest.SurvivorSpawns:GetChildren() do table.insert(points,p) end
     for _,p in points do if not workspace:Raycast(p.Position,Vector3.new(0,-8,0),rp) then ready=false break end end
     if ready then load:FireServer(token) loading[token]=nil return end
    end
   end
   task.wait(.1)
  until os.clock()>deadline
  loading[token]=nil
 end)
end)
local gui=Instance.new("ScreenGui") gui.Name="GetOutActions" gui.ResetOnSpawn=false gui.DisplayOrder=18 gui.Enabled=false gui.Parent=player:WaitForChild("PlayerGui")
local buttons={}
local function send(name,value)
 if not current or not current.roundId or not Scope:IsGetOut() or Router:IsBlocked() then return end
 action:FireServer(current.roundId,name,value)
end
local function button(key,text,index,callback)
 local b=Instance.new("TextButton") b.Name=key b.AnchorPoint=Vector2.new(1,1) b.Position=UDim2.new(1,-20,1,-160-index*56) b.Size=UDim2.fromOffset(200,48)
 b.BackgroundColor3=Color3.fromRGB(28,55,66) b.TextColor3=Color3.new(1,1,1) b.Font=Enum.Font.GothamMedium b.TextSize=14 b.Text=text b.Parent=gui
 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,8) c.Parent=b b.Activated:Connect(callback) buttons[key]=b
 return b
end
button("Crawl","RASTEJAR",0,function() send("Crawl") end)
button("Attack","GOLPEAR",0,function() send("Attack") end)
button("Drop","SOLTAR VÍTIMA",1,function() send("Drop") end)
local check=button("Check","AGUARDE",2,function() local h=current and current.gameplay and current.gameplay.hack if h then send("Check",h.sequence) end end)
button("Cancel","SAIR DO TERMINAL",1,function() send("CancelHack") end)
local function bind(key,callback)
 Router:Register(key,function(state)
  if state==Enum.UserInputState.Begin then return callback() end
  return Enum.ContextActionResult.Sink
 end,{scope="get_out"})
end
bind("GetOutCrawl",function() send("Crawl") end)
bind("GetOutAttack",function() send("Attack") end)
bind("GetOutDrop",function() send("Drop") end)
Router:Register("GetOutCheck",function(state)
 if state~=Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
 local h=current and current.gameplay and current.gameplay.hack
 if not h then return Enum.ContextActionResult.Pass end
 send("Check",h.sequence) return Enum.ContextActionResult.Sink
end,{scope="get_out"})
local function refresh()
 gui.Enabled=Scope:IsGetOut() and current~=nil and (current.state=="playing" or current.state=="enraged") and (not current.result or current.result=="active")
 local beast=gui.Enabled and current.role=="beast"
 if beast and not cameraMode then cameraMode=player.CameraMode player.CameraMode=Enum.CameraMode.LockFirstPerson
 elseif not beast and cameraMode then player.CameraMode=cameraMode cameraMode=nil end
 if not gui.Enabled then return end
 local g=current.gameplay or {} local hack=g.hack
 buttons.Crawl.Visible=current.role=="survivor" and (g.victim=="Active" or g.victim=="Crawling")
 buttons.Crawl.Text=(g.victim=="Crawling" and "LEVANTAR" or "RASTEJAR").." · "..Router:Key("GetOutCrawl","Keyboard")
 buttons.Attack.Visible=beast buttons.Drop.Visible=beast and g.dragging~=nil buttons.Cancel.Visible=hack~=nil
 check.Visible=hack~=nil
 if hack then
  local time=workspace:GetServerTimeNow() local ready=hack.checkAt and time>=hack.checkAt and time<=(hack.checkEnd or 0)
  check.BackgroundColor3=ready and Color3.fromRGB(47,133,89) or Color3.fromRGB(53,67,79)
  check.Text=ready and ("CONFIRME · "..Router:Key("GetOutCheck","Keyboard")) or ("HACKEANDO · "..math.floor((hack.progress or 0)*100).."%")
 end
end
remotes.State.OnClientEvent:Connect(function(s) current=s refresh() end)
Scope.Changed:Connect(refresh)
local elapsed=0 Run.RenderStepped:Connect(function(dt) elapsed+=dt if elapsed>.05 then elapsed=0 refresh() end end)
local controls=require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
local moveElapsed=0
Run.RenderStepped:Connect(function(dt)
 moveElapsed+=dt if moveElapsed<.1 then return end moveElapsed=0
 if not Scope:IsGetOut() or player:GetAttribute("GetOutPosture")~="Crawling" then return end
 if Run:IsStudio() and workspace:GetAttribute("GetOutP0Testing") then return end
 local direction=Vector3.zero
 if not Router:IsBlocked() then
  local v=controls:GetMoveVector() local camera=workspace.CurrentCamera
  local forward=camera and camera.CFrame.LookVector*Vector3.new(1,0,1) or -Vector3.zAxis
  if forward.Magnitude<.01 then forward=-Vector3.zAxis else forward=forward.Unit end
  direction=Vector3.new(-forward.Z,0,forward.X)*v.X-forward*v.Z
 end
 if current and current.roundId then action:FireServer(current.roundId,"CrawlMove",direction) end
end)
-- Add procedural pose offsets after Animator evaluation, for both joint formats.
local posing={} local rigs={}
Run.PreSimulation:Connect(function()
 local seen={}
 for _,p in Players:GetPlayers() do
  local c=p.Character
  if c and p:GetAttribute("CrossgroundsMode")=="get_out" then
   local rig=rigs[p]
   if not rig or rig.character~=c then
    if rig and rig.connection then rig.connection:Disconnect() end
    rig={character=c,joints={}} rigs[p]=rig
    local function jointAdded(j) if j:IsA("Motor6D") or j:IsA("AnimationConstraint") then table.insert(rig.joints,j) end end
    for _,j in c:GetDescendants() do jointAdded(j) end
    rig.connection=c.DescendantAdded:Connect(jointAdded)
   end
   local posture=p:GetAttribute("GetOutPosture") local low=posture=="Crawling" or posture=="Downed" or posture=="Dragged"
   for _,joint in rig.joints do
    local delta
    if joint.Parent and low and joint.Part0==c:FindFirstChild("HumanoidRootPart") then
     local rotation=joint.C0.Rotation delta=rotation:Inverse()*CFrame.Angles(-math.pi/2,0,0)*rotation
    elseif joint.Parent and p:GetAttribute("GetOutHacking") and joint.Name:lower():find("shoulder",1,true) then
     local phase=joint.Name:lower():find("right",1,true) and 0 or math.pi
     delta=CFrame.Angles(-1.1+math.sin(workspace:GetServerTimeNow()*12+phase)*.08,0,0)
    end
    if delta then
     local old=posing[joint] local base=old and joint.Transform==old.applied and old.base or joint.Transform
     local applied=delta*base joint.Transform=applied posing[joint]={base=base,applied=applied} seen[joint]=true
    end
   end
  end
 end
 for joint,old in posing do if not seen[joint] then if joint.Parent and joint.Transform==old.applied then joint.Transform=old.base end posing[joint]=nil end end
 for p,rig in rigs do if not p.Parent then rig.connection:Disconnect() rigs[p]=nil end end
end)
remotes.Feedback.OnClientEvent:Connect(function(kind,position)
 if kind~="HackError" or not Scope:IsGetOut() or player:GetAttribute("GetOutRole")~="beast" or typeof(position)~="Vector3" then return end
 local p=Instance.new("Part") p.Anchored=true p.CanCollide=false p.CanQuery=false p.CanTouch=false p.Transparency=1 p.Position=position p.Parent=workspace
 local g=Instance.new("BillboardGui") g.Size=UDim2.fromOffset(110,38) g.AlwaysOnTop=true g.Parent=p
 local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundColor3=Color3.fromRGB(126,42,39) t.TextColor3=Color3.new(1,1,1) t.Text="! FALHA DE PC" t.TextSize=14 t.Parent=g
 game:GetService("Debris"):AddItem(p,5)
end)
load:FireServer(0)
