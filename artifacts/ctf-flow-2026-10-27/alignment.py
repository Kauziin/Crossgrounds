from pathlib import Path
root=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27\src')
p=root/'StarterPlayer/StarterPlayerScripts/CTFFlagLabels.luau';s=p.read_text(encoding='utf-8');s=s.replace('local valid=inRound and base:GetAttribute','local valid=inRound and base~=nil and base:GetAttribute');p.write_text(s,encoding='utf-8')
p=root/'ServerScriptService/MainGameScript/GameManager/MapManager.luau';s=p.read_text(encoding='utf-8')
pos=s.index('function Maps:Initialize()')
s=s[:pos]+'''-- Map geometry may be raised during authoring. Keep objectives, spawn markers and
-- bot navigation in the same vertical frame as the actual foundation.
function Maps:AlignInfrastructure()
 local arena=workspace:FindFirstChild("CTFInfrastructure")
 local expected=arena and arena:GetAttribute("NavigationFloorY")
 local base=arena and arena:FindFirstChild("BlueBase")local stand=base and base:FindFirstChild("FlagStand")
 if typeof(expected)~="number" or not stand then return end
 local floorY
 for _,root in owned do
  for _,part in root:GetDescendants() do
   if part:IsA("BasePart") and part.Name=="Foundation" and part.CanCollide then
    local localPoint=part.CFrame:PointToObjectSpace(stand.Position)
    if math.abs(localPoint.X)<=part.Size.X*.5 and math.abs(localPoint.Z)<=part.Size.Z*.5 then
     local top=part.Position.Y+part.Size.Y*.5
     floorY=math.max(floorY or top,top)
    end
   end
  end
 end
 if not floorY or math.abs(floorY-expected)<.01 then return end
 local delta=Vector3.new(0,floorY-expected,0)
 for index,part in arena:GetDescendants() do
  if part:IsA("BasePart") then part.CFrame+=delta end
  if index%500==0 then task.wait() end
 end
 local center=arena:GetAttribute("PlayRegionCenter")
 if typeof(center)=="Vector3" then arena:SetAttribute("PlayRegionCenter",center+delta) end
 arena:SetAttribute("NavigationFloorY",floorY)
 arena:SetAttribute("ClientSceneRevision",nil) arena:SetAttribute("ClientSceneIndex",nil)
end
function Maps:ValidateSpawns()
 local include=self:SceneRoots()table.insert(include,workspace.Terrain)
 local params=RaycastParams.new()params.FilterType=Enum.RaycastFilterType.Include params.FilterDescendantsInstances=include params.RespectCanCollide=true
 local anchors=self:SceneAnchors()
 if #anchors==0 then return false,"O mapa não possui pontos de nascimento." end
 for _,position in anchors do
  if not workspace:Raycast(position+Vector3.new(0,1,0),Vector3.new(0,-14,0),params) then
   return false,"Há um ponto de nascimento sem chão no mapa. Volte ao lobby e avise o desenvolvedor."
  end
 end
 return true
end
''' +s[pos:]
s=s.replace('current=workspace:GetAttribute("CurrentMapId") or "riverside"','self:AlignInfrastructure()\n current=workspace:GetAttribute("CurrentMapId") or "riverside"',1)
s=s.replace('current=id workspace:SetAttribute','self:AlignInfrastructure()\n current=id workspace:SetAttribute',1)
p.write_text(s,encoding='utf-8')
p=root/'ServerScriptService/MainGameScript/GameManager.luau';s=p.read_text(encoding='utf-8');s=s.replace('self.loadReady=SceneLoad:Wait(function()','local safe,mapError=Maps:ValidateSpawns()\n  if not safe then\n   for _,p in game.Players:GetPlayers() do if p:GetAttribute("CrossgroundsMode")=="ctf" and p:GetAttribute("InMatch") then p:SetAttribute("SceneLoadingError",mapError) end end\n  end\n  self.loadReady=safe and SceneLoad:Wait(function()',1);p.write_text(s,encoding='utf-8')
