local Entitlements={}
local Players=game:GetService('Players')
local Market=game:GetService('MarketplaceService')
local config=require(game.ServerStorage.ThemePassConfiguration)
local records={} local changed
local passId=tonumber(config.CustomThemePassId) or 0
if passId~=passId or passId<1 or passId%1~=0 or passId==math.huge then passId=0 end
function Entitlements.Owns(player) return records[player] and records[player].owned==true or false end
function Entitlements.Refresh(player)
 local r=records[player] if not r or r.busy then return end
 player:SetAttribute('ThemeCustomPassId',passId)
 if passId==0 then player:SetAttribute('ThemeCustomAllowed',false) player:SetAttribute('ThemeCustomAccess','Unavailable') return end
 r.busy=true player:SetAttribute('ThemeCustomAccess','Checking')
 local ok,owned=pcall(function()return Market:UserOwnsGamePassAsync(player.UserId,passId)end)
 if records[player]~=r or not player.Parent then return end
 r.busy=false
 if ok then r.owned=owned==true end
 player:SetAttribute('ThemeCustomAllowed',r.owned==true)
 player:SetAttribute('ThemeCustomAccess',r.owned and 'Owned' or ok and 'Locked' or 'Retry')
 if changed then changed(player) end
end
function Entitlements.Add(player)
 records[player]={owned=false} player:SetAttribute('ThemeCustomAllowed',false)
 task.spawn(Entitlements.Refresh,player)
end
function Entitlements.Start(onChanged)
 changed=onChanged
 Market.PromptGamePassPurchaseFinished:Connect(function(player,id,purchased)
  if id==passId and purchased==true then task.spawn(Entitlements.Refresh,player) end
 end)
 Players.PlayerRemoving:Connect(function(player)records[player]=nil end)
 local remote=Instance.new('RemoteFunction') remote.Name='RefreshThemeAccess' remote.Parent=game.ReplicatedStorage.Crossgrounds.Remotes
 local rate={}
 remote.OnServerInvoke=function(player)
  local now=os.clock() if now-(rate[player] or -10)<3 then return Entitlements.Owns(player) end rate[player]=now
  Entitlements.Refresh(player) return Entitlements.Owns(player)
 end
 Players.PlayerRemoving:Connect(function(player)rate[player]=nil end)
end
return Entitlements
