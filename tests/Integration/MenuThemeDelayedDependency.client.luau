-- Studio-only regression for a late-cloned StarterPlayerScripts dependency.
assert(game:GetService("RunService"):IsStudio(),"Studio only")
local scripts=game.Players.LocalPlayer.PlayerScripts
local result=Instance.new("StringValue",game.TestService) result.Name="MenuThemeDelayedDependency" result.Value="Running"
local folder=Instance.new("Folder",scripts) folder.Name="DelayedThemeQA"
local menu=scripts.MenuTheme:Clone() menu.Parent=folder
local done=false local success,err
task.spawn(function()success,err=pcall(require,menu)done=true end)
task.wait(.25)
assert(not done,"MenuTheme must wait for AccentTheme rather than fail")
scripts.AccentTheme:Clone().Parent=folder
local deadline=os.clock()+5
repeat task.wait() until done or os.clock()>deadline
folder:Destroy()
assert(done and success,tostring(err))
result.Value="Passed"
