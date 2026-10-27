-- Recover inventory without replacing valid tools, health, ammo or the current loadout.
local Service={}
local Players=game:GetService("Players") local Run=game:GetService("RunService")
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Factory=require(game.ServerScriptService.MainGameScript.GameManager.WeaponFactory)
local states={}
function Service.Expected(player)
 local mode=player:GetAttribute("CrossgroundsMode") or "ctf"
 if mode=="arena" then return Kits.ArenaWeapons end
 if mode=="ctf" then local p=Kits.Profiles[player:GetAttribute("SelectedKit") or "Regular"] return p and p.Weapons end
end
function Service.Ensure(player)
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") local bag=player:FindFirstChild("Backpack")
 local state=states[player]
 if not state or state.repairing or not h or h.Health<=0 or not bag or player:GetAttribute("CrossgroundsTransition") or player:GetAttribute("ModeCharacterReady")~=true then return end
 local ids=Service.Expected(player) if not ids then return end
 state.repairing=true
 local ok,err=pcall(function()
  local found={}
  for _,container in {c,bag} do for _,tool in container:GetChildren() do
   local id=tool:IsA("Tool") and tool:GetAttribute("WeaponId")
   if id and table.find(ids,id) then
    if not tool:FindFirstChild("Handle") then tool:Destroy()
    else
     found[id]=tool local data=Kits.Weapons[id]
     if tool:GetAttribute("WeaponKind")==nil then tool:SetAttribute("WeaponKind",data.Kind) end
     if data.Kind=="Gun" and tool:GetAttribute("Ammo")==nil then tool:SetAttribute("Ammo",data.Magazine) tool:SetAttribute("ReserveAmmo",data.Reserve) end
    end
   end
  end end
  local repaired=0
  for _,id in ids do if not found[id] then
   local data=Kits.Weapons[id] local tool=Factory:Create(id,player:GetAttribute("ArenaPistolVisual"))
   tool:SetAttribute("ArenaWeapon",player:GetAttribute("CrossgroundsMode")=="arena")
   if data.Kind=="Gun" then tool:SetAttribute("Ammo",data.Magazine) tool:SetAttribute("ReserveAmmo",data.Reserve) tool:SetAttribute("Reloading",false) end
   tool:SetAttribute("RecoveredEquipment",true) tool.Parent=bag found[id]=tool repaired+=1
  end end
  local held=c:FindFirstChildOfClass("Tool")
  if not held then
   local chosen=state.lastEquipped and found[state.lastEquipped]
   if not chosen then for _,id in ids do if Kits.Weapons[id].Kind=="Gun" then chosen=found[id] break end end end
   chosen=chosen or found[ids[1]]
   if chosen and player.Character==c then h:EquipTool(chosen) end
  end
  if repaired>0 then player:SetAttribute("EquipmentRecoveries",(player:GetAttribute("EquipmentRecoveries") or 0)+repaired) end
 end)
 state.repairing=false
 if not ok then warn("Equipment recovery: "..tostring(err)) end
end
local function schedule(player)
 local state=states[player] if not state or state.pending then return end state.pending=true
 task.delay(.35,function() if states[player]~=state then return end state.pending=false if player.Parent then Service.Ensure(player) end end)
end
function Service:Start()
 if self.started then return end self.started=true
 local function added(p)
  if states[p] then return end
  local state={connections={}} states[p]=state
  local function watch(c)
   if state.characterConnections then for _,v in state.characterConnections do v:Disconnect() end end
   state.characterConnections={
    c.ChildRemoved:Connect(function(t) if t:IsA("Tool") then schedule(p) end end),
    c.ChildAdded:Connect(function(t) if t:IsA("Tool") and t:GetAttribute("WeaponId") then state.lastEquipped=t:GetAttribute("WeaponId") end end),
   }
   schedule(p)
  end
  table.insert(state.connections,p.CharacterAdded:Connect(watch))
  table.insert(state.connections,p:GetAttributeChangedSignal("ModeCharacterReady"):Connect(function() schedule(p) end))
  task.spawn(function()
   local bag=p:WaitForChild("Backpack",15)
   if bag and states[p]==state then table.insert(state.connections,bag.ChildRemoved:Connect(function(t) if t:IsA("Tool") then schedule(p) end end)) end
  end)
  if p.Character then watch(p.Character) end
 end
 Players.PlayerAdded:Connect(added)
 Players.PlayerRemoving:Connect(function(p)
  local s=states[p] if not s then return end
  for _,c in s.connections do c:Disconnect() end for _,c in s.characterConnections or {} do c:Disconnect() end states[p]=nil
 end)
 for _,p in Players:GetPlayers() do added(p) end
 local elapsed=0 Run.Heartbeat:Connect(function(dt) elapsed+=dt if elapsed<1 then return end elapsed=0 for p in states do Service.Ensure(p) end end)
end
return Service
