local Players=game:GetService("Players") local Run=game:GetService("RunService")
local player=Players.LocalPlayer local Audio=require(script.Parent:WaitForChild("GameAudio"))
local Policy=require(game.ReplicatedStorage.Crossgrounds.AudioEventPolicy)
local generation=0 local current local pulseAt=0 local lastCheck local elapsed=0 local lifeCombat=false local spawnHeard=false
local function combat() local m=player:GetAttribute("CrossgroundsMode") return m=="ctf" and player:GetAttribute("InMatch")==true or m=="arena" and player:GetAttribute("ArenaPlaying")==true end
local function characterAdded(character)
 generation+=1 local token=generation lifeCombat=false spawnHeard=false
 task.spawn(function()
  local h=character:WaitForChild("Humanoid",15) if not h or token~=generation then return end
  if combat() then lifeCombat=true spawnHeard=true Audio:Play("Respawn") end
  local last=h.Health
  local damage=h.HealthChanged:Connect(function(health) if health>0 and health<last and combat() then Audio:Play("Hurt") end last=health end)
  h.Died:Once(function() damage:Disconnect() if token==generation and (lifeCombat or combat()) then Audio:Play("Eliminated") end end)
  character.Destroying:Once(function() damage:Disconnect() end)
 end)
end
player.CharacterAdded:Connect(characterAdded) if player.Character then characterAdded(player.Character) end
task.spawn(function()
 local events=game.ReplicatedStorage:WaitForChild("Events") local remote=events:WaitForChild("CTFFlagAlert",30)
 if remote then remote.OnClientEvent:Connect(function(event)
  if not combat() or player:GetAttribute("CrossgroundsMode")~="ctf" then return end
  local cue=Policy.Flag(event,player.Team and player.Team.Name) if cue then Audio:Play(cue) end
 end) end
end)
task.spawn(function()
 local folder=game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("GetOutRemotes",30) if not folder then return end
 folder.State.OnClientEvent:Connect(function(state)
  if player:GetAttribute("CrossgroundsMode")~="get_out" or type(state)~="table" or state.id~="get_out" then return end
  for _,cue in Policy.GetOut(current,state) do Audio:Play(cue) end
  if not current or current.roundId~=state.roundId then lastCheck=nil pulseAt=0 end
  current=state
 end)
 folder.Feedback.OnClientEvent:Connect(function(kind) if kind=="HackError" then Audio:Play("HackError") end end)
end)
local lastRound=workspace:GetAttribute("RoundState")
workspace:GetAttributeChangedSignal("RoundState"):Connect(function()
 local state=workspace:GetAttribute("RoundState")
 if player:GetAttribute("CrossgroundsMode")=="ctf" and combat() and state~=lastRound then if state=="Playing" then Audio:Play("RoundStart") elseif lastRound=="Playing" then Audio:Play("RoundEnd") end end
 lastRound=state
end)
player:GetAttributeChangedSignal("CrossgroundsMode"):Connect(function() current=nil lastCheck=nil pulseAt=0 lifeCombat=false spawnHeard=false player:SetAttribute("BeastProximity",0) end)
Run.Heartbeat:Connect(function(dt)
 elapsed+=dt if elapsed<.1 then return end elapsed=0
 local now=workspace:GetServerTimeNow() local mode=player:GetAttribute("CrossgroundsMode")
 local live=mode=="get_out" and current and (current.state=="playing" or current.state=="enraged") and (not current.result or current.result=="active")
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if h and h.Health>0 and combat() then lifeCombat=true if not spawnHeard then spawnHeard=true Audio:Play("Respawn") end end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not live or not h or h.Health<=0 or not root then Audio:Stop("BeastPulse") player:SetAttribute("BeastProximity",0) return end
 local hack=(current.gameplay or {}).hack
 if hack and hack.checkAt and now>=hack.checkAt and now<=(hack.checkEnd or 0) then
  local key=tostring(current.roundId)..":"..tostring(hack.sequence)..":"..tostring(hack.checkAt)
  if key~=lastCheck then lastCheck=key Audio:Play("HackCheck") end
 end
 local proximity=0 local interval=1.55
 if current.role=="survivor" and (current.gameplay or {}).victim~="Captured" then
  for _,other in Players:GetPlayers() do
   if other~=player and other:GetAttribute("CrossgroundsMode")=="get_out" and other:GetAttribute("GetOutRole")=="beast" and other:GetAttribute("GetOutRoundId")==current.roundId then
    local c=other.Character local r=c and c:FindFirstChild("HumanoidRootPart") local humanoid=c and c:FindFirstChildOfClass("Humanoid")
    if r and humanoid and humanoid.Health>0 then proximity,interval=Policy.Proximity((r.Position-root.Position).Magnitude) end
    break
   end
  end
 end
 player:SetAttribute("BeastProximity",proximity)
 if proximity>0 then if now>=pulseAt then pulseAt=now+interval Audio:Play("BeastPulse",proximity) end else Audio:Stop("BeastPulse") pulseAt=0 end
end)
