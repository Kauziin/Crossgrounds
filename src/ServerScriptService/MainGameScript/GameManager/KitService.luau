local KitService={}
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local definitions=require(game.ReplicatedStorage.KitDefinitions)
local Factory=require(script.Parent.WeaponFactory)
local Authority=require(game.ServerScriptService.Crossgrounds.ShotAuthority)
local Effects=require(game.ReplicatedStorage.Crossgrounds.WeaponEffects)
local Damage=require(script.Parent.DamageService)
local events=game.ReplicatedStorage.Events
local function remote(name) local r=events:FindFirstChild(name) or Instance.new("RemoteEvent") r.Name=name r.Parent=events return r end
local action=remote("WeaponAction") local reload=remote("WeaponReload")
local feedback=remote("CombatFeedback")
local lastUse={}
local function validTool(player,tool)
 if (player:GetAttribute("CrossgroundsMode") and player:GetAttribute("CrossgroundsMode")~="ctf") or player:GetAttribute("CrossgroundsTransition") then return end
 local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
 if not h or h.Health<=0 or not (player:GetAttribute("InArena") or c:GetAttribute("AtLobby")) then return end
 if typeof(tool)~="Instance" or not tool:IsA("Tool") or tool.Parent~=c then return end
 local id=tool:GetAttribute("WeaponId")
 local profile=definitions.Profiles[player:GetAttribute("SelectedKit") or "Regular"]
 local weapons=require(game.ServerScriptService.Crossgrounds.ArsenalLoadouts).Backends(player) or profile and profile.Weapons
 if not weapons or not table.find(weapons,id) then return end
 return c,definitions.Weapons[id],id
end
local function rayParams(character)
 local p=RaycastParams.new() p.FilterType=Enum.RaycastFilterType.Exclude p.FilterDescendantsInstances={character} return p
end
local function deal(player,character,part,data,id,distance,multiplier)
 local model=Damage:ModelFromPart(part)
 local h=model and model:FindFirstChildOfClass("Humanoid")
 if not h then return false end
 if character:GetAttribute("AtLobby") then
  if model:GetAttribute("PracticeDummy") then
   local headshot=data.Kind=="Gun" and part.Name=="Head"
   local amount=data.Kind=="Gun" and definitions.ShotDamage(data,distance,headshot,multiplier) or data.Damage
   return Damage:Practice(player,model,amount,id,headshot)
  end
  return false
 end
 local headshot=data.Kind=="Gun" and part.Name=="Head"
 local damage=data.Kind=="Gun" and definitions.ShotDamage(data,distance,headshot,multiplier) or data.Damage
 return Damage:Deal(character,h,damage,id,headshot)
end
local function melee(player,character,tool,data,id)
 local root=character:FindFirstChild("HumanoidRootPart") local blade=tool:FindFirstChild("Hitbox")
 if not root or not blade then return end
 local base=tool:GetAttribute("RestGrip") or tool.Grip local hit={} local count=0
 local overlap=OverlapParams.new() overlap.FilterType=Enum.RaycastFilterType.Exclude overlap.FilterDescendantsInstances={character}
 local duration=math.min(data.Cooldown,data.Windup+data.ActiveTime+.12) local start=os.clock()
 tool:SetAttribute("Attacking",true)
 local trail=blade:FindFirstChildOfClass("Trail")
 task.spawn(function()
  local previous=blade.CFrame
  while tool.Parent==character and os.clock()-start<duration do
   local t=os.clock()-start
   local swing=math.clamp((t-data.Windup)/data.ActiveTime,0,1)
   tool.Grip=base*CFrame.Angles(math.rad(20+115*swing),0,math.rad(45-90*swing))
   local active=t>=data.Windup and t<=data.Windup+data.ActiveTime
   if trail then trail.Enabled=active end
   if active then
    local current=blade.CFrame
    for sample=1,3 do
     local cf=previous:Lerp(current,sample/3)
     for _,part in workspace:GetPartBoundsInBox(cf,blade.Size+Vector3.new(.3,.3,.3),overlap) do
      local model=Damage:ModelFromPart(part)
      local h=model and model:FindFirstChildOfClass("Humanoid")
      local targetRoot=model and model:FindFirstChild("HumanoidRootPart")
      if h and targetRoot and not hit[h] and (data.Kind=="MeleeArea" or count==0) and (targetRoot.Position-root.Position).Magnitude<=data.Range+2 then
       local obstruction=workspace:Raycast(root.Position+Vector3.new(0,1,0),part.Position-root.Position-Vector3.new(0,1,0),rayParams(character))
       if not obstruction or obstruction.Instance:IsDescendantOf(model) then
        if deal(player,character,part,data,id,0) then hit[h]=true count+=1 end
       end
      end
     end
    end
    previous=current
   else previous=blade.CFrame end
   RunService.Heartbeat:Wait()
  end
  if tool.Parent then tool.Grip=base tool:SetAttribute("Attacking",false) end
  if trail then trail.Enabled=false end
 end)
end
local function startReload(player,tool,data)
 if data.Kind~="Gun" or tool:GetAttribute("Reloading") then return end
 local ammo=tool:GetAttribute("Ammo") or 0 local reserve=tool:GetAttribute("ReserveAmmo") or 0
 if ammo>=data.Magazine or reserve<=0 then return end
 tool:SetAttribute("Reloading",true) tool:SetAttribute("ReloadStartedAt",workspace:GetServerTimeNow()) tool:SetAttribute("ReloadDuration",data.ReloadTime)
 local sound=tool.Handle:FindFirstChild("ReloadSound") if sound then sound:Play() end
 task.delay(data.ReloadTime,function()
  local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid")
  if not player.Parent or not h or h.Health<=0 or not tool:IsDescendantOf(player) and tool.Parent~=c then
   if tool.Parent then tool:SetAttribute("Reloading",false) end return
  end
  local amount=math.min(data.Magazine-(tool:GetAttribute("Ammo") or 0),tool:GetAttribute("ReserveAmmo") or 0)
  tool:SetAttribute("Ammo",(tool:GetAttribute("Ammo") or 0)+amount)
  tool:SetAttribute("ReserveAmmo",(tool:GetAttribute("ReserveAmmo") or 0)-amount)
  tool:SetAttribute("Reloading",false)
  tool:SetAttribute("ShotAmmoVersion",(tool:GetAttribute("ShotAmmoVersion") or 0)+1)
 end)
end
function KitService:GetProfile(id) return definitions.Profiles[id] or definitions.Profiles.Regular end
function KitService:ApplyToCharacter(player,character)
 local profile=self:GetProfile(player:GetAttribute("SelectedKit"))
 local h=character:WaitForChild("Humanoid")
 h.MaxHealth=200 h.Health=200 h.WalkSpeed=profile.WalkSpeed h.UseJumpPower=false h.JumpHeight=profile.JumpHeight
 player:SetAttribute("KitWalkSpeed",profile.WalkSpeed) player:SetAttribute("KitSprintSpeed",profile.SprintSpeed) player:SetAttribute("KitJumpHeight",profile.JumpHeight)
 for _,container in {player:WaitForChild("Backpack"),player.StarterGear,character} do for _,v in container:GetChildren() do if v:IsA("Tool") then v:Destroy() end end end
 local gun
 local arsenal=require(game.ServerScriptService.Crossgrounds.ArsenalLoadouts)
 local custom=arsenal.Resolve(player)
 local weapons=arsenal.Backends(player) or profile.Weapons
 for index,id in weapons do
  local tool=Factory:Create(id) local data=definitions.Weapons[id]
  if custom and index>1 then
   local visualId=index==2 and custom.primaryWeaponId or custom.secondaryWeaponId
   local configuration=index==2 and custom.primaryAttachments or custom.secondaryAttachments
   require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals).Apply(tool,visualId,configuration)
  end
  if data.Kind=="Gun" then tool:SetAttribute("Ammo",data.Magazine) tool:SetAttribute("ReserveAmmo",data.Reserve) tool:SetAttribute("Reloading",false) if not gun then gun=tool end end
  tool.Parent=player.Backpack
 end
 Damage:Watch(character)
 if gun then task.defer(function() if character.Parent and h.Health>0 and gun.Parent==player.Backpack then h:EquipTool(gun) end end) end
end
reload.OnServerEvent:Connect(function(player,tool)
 local c,data=validTool(player,tool) if c then startReload(player,tool,data) end
end)
action.OnServerEvent:Connect(function(player,tool,aim,requestedOrigin,shotId,request)
 local c,data,id=validTool(player,tool) if not c then return end
 if data.Kind=="Gun" then
  Authority.Fire({player=player,character=c,tool=tool,data=data,weapon=id,aim=aim,requestedOrigin=requestedOrigin,shotId=shotId,request=request,
   valid=function() return validTool(player,tool)~=nil end,
   classify=function(model) return Damage:ShotRelation(c,model) end,
   onHit=function(hit,_,_,multiplier,distance) return deal(player,c,hit.Instance,data,id,distance,multiplier) end,
   accept=function() local state=lastUse[player] or {} state.any=os.clock() lastUse[player]=state Damage:BreakProtection(c) end})
  if (tool:GetAttribute("Ammo") or 0)==0 then startReload(player,tool,data) end
  return
 end
 if shotId~=nil and (typeof(shotId)~="number" or shotId%1~=0 or shotId<1 or shotId>1000000000) then return end
 local now=os.clock() local state=lastUse[player] or {}
 if now-(state[id] or -100)<data.Cooldown*.95 or now-(state.any or -100)<.07 then return end
 if data.Kind~="Gun" and tool:GetAttribute("Attacking") then return end
 state[id]=now state.any=now lastUse[player]=state
 Authority.NoteMelee(player,now)
 feedback:FireClient(player,{kind="Shot",weapon=id,shotId=shotId})
 Damage:BreakProtection(c)
 Effects.PlaySound(tool) melee(player,c,tool,data,id)
end)
Players.PlayerRemoving:Connect(function(p) lastUse[p]=nil end)
return KitService
