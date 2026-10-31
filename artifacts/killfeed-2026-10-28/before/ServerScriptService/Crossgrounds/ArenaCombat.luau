-- Arena-only authoritative combat; shares weapon definitions/models/input, not CTF teams or objectives.
local Combat={} Combat.__index=Combat
local Players=game:GetService("Players")
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Authority=require(script.Parent.ShotAuthority)
local Effects=require(game.ReplicatedStorage.Crossgrounds.WeaponEffects)
local Rewards=require(script.Parent.ArenaRewards)
function Combat.new(owner,factory)
 local self=setmetatable({owner=owner,factory=factory,last={},connections={}},Combat)
 local events=game.ReplicatedStorage.Events
 local function remote(name) local r=events:FindFirstChild(name) or Instance.new("RemoteEvent") r.Name=name r.Parent=events return r end
 self.feedback=remote("CombatFeedback")
 table.insert(self.connections,remote("WeaponAction").OnServerEvent:Connect(function(player,tool,aim,requestedOrigin,shotId,request) self:Attack(player,tool,aim,requestedOrigin,shotId,request) end))
 table.insert(self.connections,remote("WeaponReload").OnServerEvent:Connect(function(player,tool) self:Reload(player,tool) end))
 return self
end
function Combat:Valid(player,tool)
 if player:GetAttribute("CrossgroundsMode")~="arena" or player:GetAttribute("CrossgroundsTransition") or not self.owner:IsPlaying(player) then return end
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 if not h or h.Health<=0 or typeof(tool)~="Instance" or not tool:IsA("Tool") or tool.Parent~=c or tool:GetAttribute("ArenaWeapon")~=true then return end
 local id=tool:GetAttribute("WeaponId")
 if id~="Sword" and id~=Kits.ArenaGunId(player:GetAttribute("ArenaPistolVisual")) then return end
 return c,Kits.Weapons[id],id
end
function Combat:Strip(player)
 for _,container in {player.Backpack,player.StarterGear,player.Character} do if container then for _,t in container:GetChildren() do if t:IsA("Tool") and t:GetAttribute("WeaponId") then t:Destroy() end end end end
 self.last[player]=nil
end
function Combat:Equip(player)
 self:Strip(player) local gun
 for _,id in Kits.ArenaWeapons do
  local t=self.factory:Create(id,player:GetAttribute("ArenaPistolVisual")) local data=Kits.Weapons[t:GetAttribute("WeaponId")] t:SetAttribute("ArenaWeapon",true)
  if data.Kind=="Gun" then t:SetAttribute("Ammo",data.Magazine) t:SetAttribute("ReserveAmmo",data.Reserve) t:SetAttribute("Reloading",false) gun=t end
  t.Parent=player.Backpack
 end
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if h and gun then h:EquipTool(gun) end
end
function Combat:Damage(player,part,data,id,distance,multiplier)
 local model=part
 while model and model~=workspace and not (model:IsA("Model") and model:FindFirstChildOfClass("Humanoid")) do model=model.Parent end
 local h=model and model:FindFirstChildOfClass("Humanoid") if not h or h.Health<=0 or model==player.Character then return false end
 local target=Players:GetPlayerFromCharacter(model)
 if target then
  if not self.owner:IsPlaying(target) or (model:GetAttribute("ArenaProtectedUntil") or 0)>workspace:GetServerTimeNow() then return false end
 elseif not model:GetAttribute("ArenaTarget") or not self.owner.maps.world or not model:IsDescendantOf(self.owner.maps.world) then return false end
 local headshot=data.Kind=="Gun" and part.Name=="Head"
 local amount=data.Kind=="Gun" and Kits.ShotDamage(data,distance,headshot,multiplier) or data.Damage
 h:TakeDamage(amount)
 
 if h.Health<=0 then
  local reward=Rewards.Apply(player,target,headshot)
  local tool=player.Character and player.Character:FindFirstChildOfClass("Tool")
  local weaponName=id=="ArenaPistol" and tool and tool.Name or data.Name
  self.feedback:FireClient(player,{kind="Kill",victim=target and target.DisplayName or "Alvo de treino",weapon=weaponName,weaponId=id,headshot=headshot,xp=reward.xp,bonusXP=reward.bonusXP,sessionXP=reward.sessionXP,training=reward.training})
  if target then self.feedback:FireClient(target,{kind="Eliminated",character=model,killer=player.Character,killerName=player.DisplayName,weapon=weaponName}) end
  if target then self.feedback:FireAllClients({kind="ArenaKillFeed",attacker=player.DisplayName,victim=target.DisplayName,weapon=weaponName,headshot=headshot}) end
  self.owner:Publish()
 else self.feedback:FireClient(player,{kind="Hit",headshot=headshot}) end
 return true
end
local function rayParams(character)
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={character} return params
end
function Combat:Reload(player,tool)
 local _,data=self:Valid(player,tool) if not data or data.Kind~="Gun" or tool:GetAttribute("Reloading") then return end
 if (tool:GetAttribute("Ammo") or 0)>=data.Magazine or (tool:GetAttribute("ReserveAmmo") or 0)<=0 then return end
 tool:SetAttribute("Reloading",true) tool:SetAttribute("ReloadStartedAt",workspace:GetServerTimeNow()) tool:SetAttribute("ReloadDuration",data.ReloadTime)
 local sound=tool.Handle:FindFirstChild("ReloadSound") if sound then sound:Play() end
 task.delay(data.ReloadTime,function()
  local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
  if not player.Parent or player:GetAttribute("CrossgroundsMode")~="arena" or not h or h.Health<=0 or not tool:IsDescendantOf(player) and tool.Parent~=c then
   if tool.Parent then tool:SetAttribute("Reloading",false) end return
  end
  local amount=math.min(data.Magazine-(tool:GetAttribute("Ammo") or 0),tool:GetAttribute("ReserveAmmo") or 0)
  tool:SetAttribute("Ammo",(tool:GetAttribute("Ammo") or 0)+amount) tool:SetAttribute("ReserveAmmo",(tool:GetAttribute("ReserveAmmo") or 0)-amount) tool:SetAttribute("Reloading",false)
  tool:SetAttribute("ShotAmmoVersion",(tool:GetAttribute("ShotAmmoVersion") or 0)+1)
 end)
end
function Combat:Attack(player,tool,aim,requestedOrigin,shotId,request)
 local c,data,id=self:Valid(player,tool) if not c then return end
 if data.Kind=="Gun" then
  Authority.Fire({player=player,character=c,tool=tool,data=data,weapon=id,aim=aim,requestedOrigin=requestedOrigin,shotId=shotId,request=request,cooldown=data.SourcePack=="ProjectileTest" and data.Cooldown or math.max(1,data.Cooldown),
   valid=function() return self:Valid(player,tool)~=nil end,
   classify=function(model)
    local h=model:FindFirstChildOfClass("Humanoid") if h and h.Health<=0 then return "ignore" end
    local target=Players:GetPlayerFromCharacter(model)
    return (target and self.owner:IsPlaying(target) or model:GetAttribute("ArenaTarget")) and "target" or "block"
   end,
   onHit=function(hit,_,_,multiplier,distance) return self:Damage(player,hit.Instance,data,id,distance,multiplier) end,
   accept=function()
    local state=self.last[player] or {} state.any=os.clock() self.last[player]=state
    c:SetAttribute("ArenaProtectedUntil",0) local shield=c:FindFirstChild("ArenaShield") if shield then shield:Destroy() end
   end})
  if (tool:GetAttribute("Ammo") or 0)==0 then self:Reload(player,tool) end
  return
 end
 if shotId~=nil and (typeof(shotId)~="number" or shotId%1~=0 or shotId<1 or shotId>1000000000) then return end
 local state=self.last[player] or {} local now=os.clock()
 if now-(state[id] or -100)<math.max(1,data.Cooldown) or now-(state.any or -100)<.07 or tool:GetAttribute("Reloading") or tool:GetAttribute("Attacking") then return end
 state[id]=now state.any=now self.last[player]=state
 Authority.NoteMelee(player,now)
 c:SetAttribute("ArenaProtectedUntil",0) local shield=c:FindFirstChild("ArenaShield") if shield then shield:Destroy() end
 self.feedback:FireClient(player,{kind="Shot",weapon=id,shotId=shotId})
  Effects.PlaySound(tool)
  local blade=tool:FindFirstChild("Hitbox") if not blade then return end
  local root=c:FindFirstChild("HumanoidRootPart") if not root then return end
  local base=tool:GetAttribute("RestGrip") or tool.Grip local started=os.clock() local hitOnce=false
  tool:SetAttribute("Attacking",true)
  task.spawn(function()
   while tool.Parent==c and self.owner:IsPlaying(player) and os.clock()-started<data.Windup+data.ActiveTime+.12 do
    local time=os.clock()-started local swing=math.clamp((time-data.Windup)/data.ActiveTime,0,1)
    tool.Grip=base*CFrame.Angles(math.rad(20+115*swing),0,math.rad(45-90*swing))
    if not hitOnce and time>=data.Windup and time<=data.Windup+data.ActiveTime then
     local overlap=OverlapParams.new() overlap.FilterType=Enum.RaycastFilterType.Exclude overlap.FilterDescendantsInstances={c}
     for _,part in workspace:GetPartBoundsInBox(blade.CFrame,blade.Size+Vector3.new(.3,.3,.3),overlap) do
      if (part.Position-root.Position).Magnitude<data.Range+4 then
       local obstruction=workspace:Raycast(root.Position+Vector3.new(0,1,0),part.Position-root.Position-Vector3.new(0,1,0),rayParams(c))
       if not obstruction or obstruction.Instance==part or obstruction.Instance:IsDescendantOf(part.Parent) then if self:Damage(player,part,data,id,0) then hitOnce=true break end end
      end
     end
    end
    game:GetService("RunService").Heartbeat:Wait()
   end
   if tool.Parent then tool.Grip=base tool:SetAttribute("Attacking",false) end
  end)
end
return Combat

