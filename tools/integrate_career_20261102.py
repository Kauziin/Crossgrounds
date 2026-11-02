from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'artifacts/social-systems-2026-11-02/before'

def edit(name, replacements):
    path = ROOT / 'src' / name
    backup = OUT / name
    if not backup.exists():
        backup.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, backup)
    source = path.read_text(encoding='utf-8-sig')
    for old, new in replacements:
        if old not in source:
            raise RuntimeError(f'Missing integration anchor: {name}: {old[:90]}')
        source = source.replace(old, new)
    path.write_text(source, encoding='utf-8')

edit('ServerScriptService/Crossgrounds/ProgressionService.luau', [
    ('local Service = {}', 'local Service = {}\nlocal Career=require(script.Parent.CareerService)'),
    ('player:SetAttribute("ProgressLevel", level(record.base.XP + record.pending.XP))', 'local career=Career.Get(player)\n player:SetAttribute("ProgressLevel", career and require(game.ReplicatedStorage.Crossgrounds.CareerPolicy).Level(career.cycleXP,career.phase) or level(record.base.XP + record.pending.XP))'),
    (' if not record then return end\n for key, value in pairs(amounts) do', ' if not record then return end\n if Career.Enabled() and record.loaded then Career.Award(player,amounts,mode) end\n for key, value in pairs(amounts) do'),
    ('if not record or not record.loaded or record.saving or RunService:IsStudio() or player.UserId <= 0 then return end', 'if not record or not record.loaded or record.saving then return end\n if Career.Enabled() then\n  local delta=table.clone(record.pending) record.saving=true\n  local ok,saved=Career.Flush(player)\n  if ok then record.base=clean(saved.stats) for _,key in fields do record.pending[key]=math.max(0,record.pending[key]-delta[key]) end publish(player,record) end\n  record.saving=false return\n end\n if RunService:IsStudio() or player.UserId<=0 then return end'),
    ('  if not RunService:IsStudio() and player.UserId > 0 then', '  if Career.Enabled() then\n   local data,err=Career.Open(player)\n   if not data then player:SetAttribute("ProgressionLoadError",true) return end\n   record.base=clean(data.stats) record.visitSaved=true\n   Career.Award(player,record.pending)\n  elseif not RunService:IsStudio() and player.UserId > 0 then'),
    ('data.Level=level(data.XP) return data', 'local career=Career.Get(player)\n data.Level=career and require(game.ReplicatedStorage.Crossgrounds.CareerPolicy).Level(career.cycleXP,career.phase) or level(data.XP) return data'),
    (' self.started = true\n local remotes', ' self.started = true\n Career.Start()\n Career.Changed:Connect(function(player) local r=state[player] if r then publish(player,r) end end)\n local remotes'),
])
for name in ['ServerScriptService/Crossgrounds/ProgressionRanking.luau', 'ServerScriptService/Crossgrounds/StandingsService.luau', 'StarterPlayer/StarterPlayerScripts/PrestigePresentation.local.luau']:
    replacements=[('Prestige_', 'Podium_')]
    if name.endswith('PrestigePresentation.local.luau'):
        replacements.append(('key:sub(1,9)', 'key:sub(1,7)'))
    edit(name,replacements)
