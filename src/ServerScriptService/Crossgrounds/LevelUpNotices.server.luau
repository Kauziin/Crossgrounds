-- Observe confirmed server profiles; never grant XP from this presentation.
local Players=game:GetService("Players")
local Root=game.ReplicatedStorage.Crossgrounds
local Career=require(script.Parent.CareerService)
local P=require(Root.CareerPolicy)
local remote=Instance.new("RemoteEvent") remote.Name="LevelUpNotice" remote.Parent=Root:WaitForChild("Remotes")
local previous={}
local function update(player)
 local p=Career.Get(player) if not p then previous[player]=nil return end
 local now={phase=p.phase,prestige=p.prestige,level=P.Level(p.cycleXP,p.phase),weapons={}}
 for id,xp in p.weapons do now.weapons[id]=P.WeaponLevel(xp) end
 local old=previous[player] previous[player]=now
 if not old then return end -- Loading a saved profile is not a level-up.
 if old.phase==now.phase and old.prestige==now.prestige and now.level>old.level then remote:FireClient(player,{kind="account",level=now.level,from=old.level}) end
 for id,level in now.weapons do local before=old.weapons[id] or 1
  if level>before then remote:FireClient(player,{kind="weapon",weapon=id,level=level,from=before}) end
 end
end
Career.Changed:Connect(update)
for _,p in Players:GetPlayers() do update(p) end
Players.PlayerRemoving:Connect(function(p)previous[p]=nil end)
