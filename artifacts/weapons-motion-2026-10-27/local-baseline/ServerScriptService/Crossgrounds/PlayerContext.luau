local Context={}
local Players=game:GetService("Players")
local changed=Instance.new("BindableEvent") Context.Changed=changed.Event
local started=false local prepared=false local config local scene
local hubConnections={} local loading={}
local function loadHubCharacter(player)
 if loading[player] or not player.Parent then return end loading[player]=true
 player:SetAttribute("ModeCharacterReady",false)
 local ok,err=pcall(function() player:LoadCharacterAsync() end)
 loading[player]=nil
 if not ok and player.Parent then warn("Crossgrounds character: "..tostring(err)) end
end
function Context:GetMode(player)
 return player:GetAttribute("CrossgroundsMode") or (config and (config.PlaceRole=="ctf" or config.PlaceRole=="legacy") and "ctf") or "loading"
end
function Context:IsCTF(player) return self:GetMode(player)=="ctf" end
function Context:SetMode(player,mode)
 assert(mode=="hub" or mode=="ctf" or mode=="arena" or mode=="get_out","Modo não registrado.")
 player:SetAttribute("ModeCharacterReady",false)
 player:SetAttribute("CrossgroundsMode",mode)
 player:SetAttribute("SceneLoading",false)player:SetAttribute("SceneLoadingError",nil)
 changed:Fire(player)
end
function Context:MarkReady(player)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if root then player:SetAttribute("CharacterReadyPosition",root.Position)end
 player:SetAttribute("CharacterReadySerial",(player:GetAttribute("CharacterReadySerial")or 0)+1)
 player:SetAttribute("ModeCharacterReady",true) changed:Fire(player)
end
function Context:Prepare(settings)
 config=settings Players.CharacterAutoLoads=false
 if prepared then return end prepared=true
 local function assign(p)
  if p:GetAttribute("CrossgroundsMode")==nil then
   self:SetMode(p,(config.PlaceRole=="ctf" or config.PlaceRole=="legacy")and"ctf"or"hub")
   p:SetAttribute("CrossgroundsTransition",false)
  end
 end
 Players.PlayerAdded:Connect(assign)for _,p in Players:GetPlayers()do assign(p)end
end
function Context:ReloadHubCharacter(player)if self:GetMode(player)=="hub"then task.spawn(loadHubCharacter,player)end end
function Context:ApplyHubCharacter(player,character)
 if not character or self:GetMode(player)~="hub" then return false end
 local h=character:FindFirstChildOfClass("Humanoid") local root=character:FindFirstChild("HumanoidRootPart")
 if not h or not root or not scene or player.Character~=character then return false end
 player:SetAttribute("InMatch",false) player:SetAttribute("InArena",false) player:SetAttribute("RespawnAt",0)
 player.Neutral=true player.Team=nil character:SetAttribute("AtLobby",false) character:SetAttribute("SpawnProtectedUntil",nil)
 for _,v in character:GetChildren() do if v:IsA("ForceField") and (v.Name=="LobbyShield" or v.Name=="SpawnShield" or v.Name=="HubProtection") then v:Destroy() end end
 h.AutoRotate=true h.MaxHealth=200 h.Health=200 h.WalkSpeed=16 h.UseJumpPower=false h.JumpHeight=7.2
 character:PivotTo(scene.Spawn.CFrame * CFrame.new(0,4,0))
 root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
 local shield=Instance.new("ForceField") shield.Name="HubProtection" shield.Visible=false shield.Parent=character
 self:MarkReady(player) return true
end
function Context:Initialize(settings,hubScene)
 if started then return end started=true self:Prepare(settings) scene=hubScene
 local function added(p)
  if p:GetAttribute("CrossgroundsContextInitialized") then return end
  p:SetAttribute("CrossgroundsContextInitialized",true)
  p:SetAttribute("CrossgroundsCanReturnHub",config.PlaceRole=="combinedPrototype" or config.TeleportEnabled and config.HubPlaceId~=nil)
  p:SetAttribute("CrossgroundsTransition",false)
  if p:GetAttribute("CrossgroundsMode")==nil then self:SetMode(p,(config.PlaceRole=="ctf" or config.PlaceRole=="legacy") and "ctf" or "hub") end
  if config.PlaceRole=="hub" then
   local list={} hubConnections[p]=list
   local function characterAdded(character)
    local h=character:WaitForChild("Humanoid",10) local root=character:WaitForChild("HumanoidRootPart",10)
    if not p.Parent or p.Character~=character or not h or not root then return end
    task.defer(function()
     while loading[p] and p.Parent do task.wait() end
     if p.Parent and p.Character==character then self:ApplyHubCharacter(p,character) end
    end)
    local deathConnection
    deathConnection=h.Died:Once(function()
     task.delay(Players.RespawnTime,function() if p.Parent and p.Character==character then loadHubCharacter(p) end end)
    end)
    table.insert(list,deathConnection)
    character.Destroying:Once(function()
     deathConnection:Disconnect()
     local index=table.find(list,deathConnection) if index then table.remove(list,index) end
    end)
   end
   table.insert(list,p.CharacterAdded:Connect(characterAdded))
   if p.Character then task.spawn(characterAdded,p.Character) else task.spawn(loadHubCharacter,p) end
  end
 end
 Players.PlayerAdded:Connect(added)
 Players.PlayerRemoving:Connect(function(p)
  for _,connection in hubConnections[p] or {} do connection:Disconnect() end
  hubConnections[p]=nil loading[p]=nil
 end)
 for _,p in Players:GetPlayers() do added(p) end
end
return Context

