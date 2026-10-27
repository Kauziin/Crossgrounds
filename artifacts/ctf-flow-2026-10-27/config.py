from pathlib import Path
r=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27')
p=Path('ServerScriptService/Crossgrounds/ProgressionBalance.luau');s=(r/'baseline'/p).read_text(encoding='utf-8')
a=s.index('local ok, result'); b=s.index('function Balance.Get',a)
s=s[:a]+'''-- Remote reward config must never block character creation or the round loop.
-- Local unpublished places have no universe config; use the existing defaults.
if game.GameId~=0 then task.defer(function()
 local ok,result=pcall(function() return game:GetService("ConfigService"):GetConfigAsync() end)
 if not ok then warn("Crossgrounds reward config unavailable; using defaults.") return end
 snapshot=result values={}
 snapshot.UpdateAvailable:Connect(function()
  local refreshed,err=pcall(function() snapshot:Refresh() end)
  if refreshed then values={} else warn("Crossgrounds reward config refresh: "..tostring(err)) end
 end)
end) end
''' +s[b:]
(r/'src'/p).write_text(s,encoding='utf-8')
for p in (r/'src').rglob('*.luau'):
 s=p.read_text(encoding='utf-8');s=s.replace('SettingReducedMotion','SettingReducedMenuMotion');p.write_text(s,encoding='utf-8')
