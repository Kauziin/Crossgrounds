local Service={}
local Players=game:GetService("Players")
local ServerStorage=game:GetService("ServerStorage")
local slots={} local used={} local targets={}
local pairsBySpawn={} local template local world local targetsFolder local started=false

local function buildPairs(model)
 local center=model:GetBoundingBox()
 local floors={}
 for _,part in model:GetDescendants() do
  if part:IsA("BasePart") and part.CanCollide and part.Size.X>=8 and part.Size.Z>=8 and part.CFrame.UpVector.Y>.85 and part.Position.Y<center.Position.Y then
   local delta=part.Position-center.Position
   table.insert(floors,{part=part,distance=delta.X*delta.X+delta.Z*delta.Z})
  end
 end
 table.sort(floors,function(a,b)return a.distance<b.distance end)
 local reserved={} local pairs={}
 for _,entry in floors do
  if not reserved[entry.part] then
   local source=entry.part
   local best,bestScore
   for _,candidate in floors do
    local delta=candidate.part.Position-source.Position
    local flat=Vector3.new(delta.X,0,delta.Z)
    if candidate.part~=source and math.abs(flat.Magnitude-15)<1.5 and math.abs(delta.Y)<1 then
     local score=math.abs(flat.Magnitude-15)+math.abs(flat.X)*.02
     if not bestScore or score<bestScore then best=candidate.part bestScore=score end
    end
   end
   if best then
    local spawn=source.Position+Vector3.new(0,source.Size.Y*.5+3.5,0)
    local target=best.Position+Vector3.new(0,best.Size.Y*.5+3,0)
    table.insert(pairs,{spawn=CFrame.lookAt(spawn,target),target=CFrame.lookAt(target,spawn)})
    reserved[source]=true reserved[best]=true
   end
  end
 end
 return pairs
end

local function ensureWorld()
 if world and world.Parent then return true end
 if not template then return false end
 world=Instance.new("Folder") world.Name="CTFPracticeRange" world:SetAttribute("PracticeRangeWorld",true)
 local map=template:Clone() map.Name="Boot Camp" map.Parent=world
 targetsFolder=Instance.new("Folder") targetsFolder.Name="PassivePracticeBots" targetsFolder.Parent=world
 world.Parent=workspace
 return true
end

local function makeTarget(player,index)
 local source=ServerStorage:FindFirstChild("CTFBotTemplate")
 if not source then return nil end
 local target=source:Clone() target.Name="Practice Bot "..tostring(index)
 target:SetAttribute("PracticeDummy",true) target:SetAttribute("BotAlias","Bot de treino")
 target:SetAttribute("CTFBot",nil) target:SetAttribute("CTFTeam",nil)
 for _,item in target:GetDescendants() do
  if item:IsA("Tool") or item:IsA("BaseScript") then item:Destroy()
  elseif item:IsA("BasePart") then item.Anchored=true item.CanCollide=false item.CanTouch=false item.CanQuery=true end
 end
 local humanoid=target:FindFirstChildOfClass("Humanoid")
 if not humanoid then target:Destroy() return nil end
 humanoid.DisplayName="BOT DE TREINO" humanoid.WalkSpeed=0 humanoid.AutoRotate=false humanoid.HealthDisplayType=Enum.HumanoidHealthDisplayType.AlwaysOff
 humanoid.MaxHealth=200 humanoid.Health=200
 local root=target:FindFirstChild("HumanoidRootPart") if root then target.PrimaryPart=root end
 target:PivotTo(pairsBySpawn[index].target) target.Parent=targetsFolder
 return target
end

function Service:Start()
 if started then return self:Available() end
 started=true
 local folder=ServerStorage:FindFirstChild("CrossgroundsPracticeAssets") or Instance.new("Folder")
 folder.Name="CrossgroundsPracticeAssets" folder.Parent=ServerStorage
 template=folder:FindFirstChild("Boot Camp") or workspace:FindFirstChild("Boot Camp")
 if template and template.Parent==workspace then
  template:SetAttribute("PracticeRangeAsset",true)
  template.Parent=folder
 end
 if template then pairsBySpawn=buildPairs(template) end
 Players.PlayerRemoving:Connect(function(player) self:Leave(player) end)
 return self:Available()
end

function Service:Available()
 return template~=nil and #pairsBySpawn>0 and ServerStorage:FindFirstChild("CTFBotTemplate")~=nil
end

function Service:Join(player)
 if not self:Available() then return false,"Boot Camp ou o bot de treino está indisponível." end
 if slots[player] then return true end
 if not ensureWorld() then return false,"Não foi possível carregar o Boot Camp." end
 local index
 for candidate=1,#pairsBySpawn do if not used[candidate] then index=candidate break end end
 if not index then return false,"O Practice Range está cheio." end
 local target=makeTarget(player,index)
 if not target then return false,"Não foi possível criar o bot de treino." end
 slots[player]=index used[index]=player targets[player]=target
 return true
end

function Service:IsActive(player)
 return slots[player]~=nil and player:GetAttribute("CTFPracticeRange")==true
end

function Service:PlaceCharacter(player,character)
 local index=slots[player]
 local root=character and character:FindFirstChild("HumanoidRootPart")
 if not index or not root then return false end
 character:PivotTo(pairsBySpawn[index].spawn)
 root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
 return true
end

function Service:Leave(player)
 local index=slots[player]
 slots[player]=nil
 if index then used[index]=nil end
 local target=targets[player] targets[player]=nil
 if target and target.Parent then target:Destroy() end
 player:SetAttribute("CTFPracticeRange",false)
 local any=false for _ in slots do any=true break end
 if not any and world then world:Destroy() world=nil targetsFolder=nil end
end

return Service