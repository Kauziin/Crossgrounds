from pathlib import Path
import shutil

root = Path(__file__).resolve().parents[1]
out = root / 'artifacts/loadout-2026-10-27'
target = root / 'src/StarterPlayer/StarterPlayerScripts/ExperienceMenu.luau'
backup = out / 'before/ExperienceMenu-local.luau'
if not backup.exists():
 shutil.copyfile(target, backup)
source = (out / 'before/ExperienceMenu.luau').read_text(encoding='utf-8-sig')
def replace(old, new):
 global source
 assert source.count(old) == 1, old
 source = source.replace(old, new)
replace('local show,render,resize', 'local activeLoadoutView\nlocal show,render,resize')
replace('local function cleanDetail()\n', 'local function cleanDetail()\n if activeLoadoutView then activeLoadoutView:Destroy() activeLoadoutView=nil end\n')
replace('  local mode=Scope:IsArena() and "arena" or "ctf"\n', '''  local mode=Scope:IsArena() and "arena" or "ctf"
  if mode=="arena" then
   activeLoadoutView=require(script.Parent:WaitForChild("LoadoutMenuView")).new(lists.Detail,{
    Player=player,Navigation=Nav,Definitions=Loadouts,Loadouts=Loadouts.List(mode),
    Select=function(id) remotes.SelectLoadout:FireServer(mode,id) end,
   })
   resize(true) return
  end
''')
replace('  task.defer(function() if shade.Visible and target.Parent then Nav:Focus(target) end end)', '''  if page=="Loadout" and activeLoadoutView then
   target=activeLoadoutView:DefaultFocus()
   task.delay(.08,function() if page=="Loadout" and shade.Visible and target.Parent then Nav:Focus(target) end end)
  else task.defer(function() if shade.Visible and target.Parent then Nav:Focus(target) end end) end''')
target.write_text(source, encoding='utf-8', newline='\n')
(out / 'ExperienceMenu-after.luau').write_text(source, encoding='utf-8', newline='\n')
print('Only loadout construction, disposal and default focus changed.')
