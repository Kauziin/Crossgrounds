local Service={}
local Players=game:GetService("Players")
local Def=require(game.ReplicatedStorage.Crossgrounds.LoadoutDefinitions)
local last={}
function Service.ApplyPending(player,mode)
 local key=Def.PendingAttribute(mode) local id=player:GetAttribute(key)
 if Def.Valid(mode,id) then player:SetAttribute(Def.ActiveAttribute(mode),id) end
 player:SetAttribute(key,nil)
end
function Service:Start()
 if self.started then return end self.started=true
 local root=game.ReplicatedStorage.Crossgrounds.Remotes
 local select=root:FindFirstChild("SelectLoadout") or Instance.new("RemoteEvent") select.Name="SelectLoadout" select.Parent=root
 select.OnServerEvent:Connect(function(player,mode,id)
  if player:GetAttribute("CrossgroundsMode")~=mode or player:GetAttribute("CrossgroundsTransition") or not Def.Valid(mode,id) then return end
  if os.clock()-(last[player] or -10)<.2 then return end last[player]=os.clock()
  player:SetAttribute(Def.PendingAttribute(mode),id)
 end)
 Players.PlayerRemoving:Connect(function(p) last[p]=nil end)
end
return Service
