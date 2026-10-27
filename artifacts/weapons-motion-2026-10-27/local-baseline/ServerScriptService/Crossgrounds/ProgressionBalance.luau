local Balance = {}
local defaults = {
 BotKillXP = 50, TrainingKillXP = 10,
 ArenaKillXP = 100, ArenaHeadshotXP = 50, ArenaKillCoins = 20,
 CTFKillXP = 70, CTFKillCoins = 15, CTFCaptureXP = 250, CTFCaptureCoins = 60,
}
local values={}
local snapshot
local ok, result = pcall(function() return game:GetService("ConfigService"):GetConfigAsync() end)
if ok then
 snapshot = result
 snapshot.UpdateAvailable:Connect(function()
  local refreshed, err = pcall(function() snapshot:Refresh() end)
  if refreshed then values={} end
  if not refreshed then warn("Crossgrounds reward config refresh: " .. tostring(err)) end
 end)
end
function Balance.Get(key)
 local fallback = assert(defaults[key], "Unknown reward " .. tostring(key))
 if values[key]~=nil then return values[key] end
 if snapshot then
  local success, value = pcall(function() return snapshot:GetValue("Crossgrounds" .. key) end)
  if success and typeof(value) == "number" and value == value and value >= 0 and value <= 100000 then
   values[key]=math.floor(value)
   return values[key]
  end
 end
 values[key]=fallback
 return fallback
end
return Balance
