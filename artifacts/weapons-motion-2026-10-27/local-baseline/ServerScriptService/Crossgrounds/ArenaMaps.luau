local Maps={} Maps.__index=Maps
local Definitions=require(game.ReplicatedStorage.Crossgrounds.ArenaDefinitions)
local Library=require(script.Parent.MapLibrary)
local Spawns=require(script.Parent.MapSpawns)
function Maps.new() return setmetatable({world=nil,spawns={},lastSpawn={}},Maps) end
function Maps:Catalog() return Library.Catalog("Arena") end
function Maps:Clear()
 if self.world then self.world:Destroy() end self.world=nil self.spawns={} self.lastSpawn={} self.killPlaneY=nil workspace:SetAttribute("ArenaMapId",nil) workspace:SetAttribute("ArenaLightingProfile",nil)
end
function Maps:Load(id,canContinue)
 local source=Library.Get("Arena",id)
 if not source then return false,"Mapa de Arena indisponível." end
 self:Clear()
 local world=Instance.new("Folder") world.Name="CrossgroundsArenaRound" world:SetAttribute("CrossgroundsOwned",true) world.Parent=workspace self.world=world
 for _,batch in source.Geometry:GetChildren() do
  if canContinue and not canContinue() then if self.world==world then self:Clear() end return false,"Carregamento cancelado." end
  batch:Clone().Parent=world task.wait()
 end
 for _,marker in source.Spawns:GetChildren() do
  if marker:IsA("BasePart") and Spawns.InRegions(marker.CFrame,source:FindFirstChild("SpawnRegions")) and Spawns.Validate(world,marker.CFrame) then table.insert(self.spawns,marker.CFrame) end
 end
 if #self.spawns<4 then self:Clear() return false,"Mapa sem pontos de reaparecimento livres suficientes." end
 self.killPlaneY=source:GetAttribute("KillPlaneY") or 30
 workspace:SetAttribute("ArenaLightingProfile",source:GetAttribute("LightingProfile") or id)
 workspace:SetAttribute("ArenaMapId",id) return true
end
function Maps:ChooseSpawn(player,members)
 local best,score=self.spawns[1],-math.huge
 for i,cf in self.spawns do
  if Spawns.Validate(self.world,cf) then
  local nearest=1000
  for other in members do
   local root=other.Character and other.Character:FindFirstChild("HumanoidRootPart")
   local h=other.Character and other.Character:FindFirstChildOfClass("Humanoid")
   if other~=player and root and h and h.Health>0 then nearest=math.min(nearest,(root.Position-cf.Position).Magnitude) end
  end
  local exposed=0
  for other in members do
   local r=other.Character and other.Character:FindFirstChild("HumanoidRootPart")
   local h=other.Character and other.Character:FindFirstChildOfClass("Humanoid")
   if other~=player and r and h and h.Health>0 and (r.Position-cf.Position).Magnitude<120 then
    local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Include rp.FilterDescendantsInstances={self.world} rp.RespectCanCollide=true
    if not workspace:Raycast(r.Position,cf.Position-r.Position,rp) then exposed+=1 end
   end
  end
  local value=nearest-exposed*100-math.max(0,8-(os.clock()-(self.lastSpawn[i] or -100)))*30-(cf.Position-Definitions.Origin).Magnitude*.02
  if value>score then best=cf score=value end
  end
 end
 for i,cf in self.spawns do if cf==best then self.lastSpawn[i]=os.clock() break end end
 return best
end
return Maps
