local Scope={}
local player=game.Players.LocalPlayer
-- Wait for server role before starting mode-specific clients in a hub-only Place.
if game.ReplicatedStorage:FindFirstChild("Crossgrounds") then
 local deadline=os.clock()+10
 while workspace:GetAttribute("CrossgroundsPlaceRole")==nil and os.clock()<deadline do task.wait() end
end
function Scope:HasCTFRuntime() local role=workspace:GetAttribute("CrossgroundsPlaceRole") return role~="hub" and role~="arena" end
function Scope:Get()
 return player:GetAttribute("CrossgroundsMode") or (workspace:GetAttribute("CrossgroundsEnabled") and "hub" or "ctf")
end
function Scope:IsCTF() return self:Get()=="ctf" end
function Scope:HasCombatRuntime() return workspace:GetAttribute("CrossgroundsPlaceRole")~="hub" end
function Scope:IsArena() return self:Get()=="arena" end
function Scope:IsGetOut() return self:Get()=="get_out" end
function Scope:IsInteractive() return self:IsCTF() or self:IsGetOut() end
function Scope:IsCombat() return self:IsCTF() or self:IsArena() end
function Scope:IsHub() return self:Get()=="hub" end
Scope.Changed=player:GetAttributeChangedSignal("CrossgroundsMode")
return Scope

