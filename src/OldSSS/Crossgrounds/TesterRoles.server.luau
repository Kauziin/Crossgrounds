local Players=game:GetService('Players') local config=require(game.ReplicatedStorage.Crossgrounds.TesterConfiguration)
local Access=require(script.Parent.PremiumFeatureAccess)
local function apply(p) p:SetAttribute('CrossgroundsTester',table.find(config.UserIds,p.UserId)~=nil) p:SetAttribute('PremiumFeaturesAllowed',Access.IsPrivileged(p.UserId)) end
Players.PlayerAdded:Connect(apply) for _,p in Players:GetPlayers() do apply(p) end
