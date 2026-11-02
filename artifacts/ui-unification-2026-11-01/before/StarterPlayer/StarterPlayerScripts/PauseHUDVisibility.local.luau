-- Preserve each HUD's intended Enabled state while the custom/native pause is open.
local player=game.Players.LocalPlayer local gui=game:GetService('GuiService') local records={} local paused=false
local names={AdminCameraHelp=true,CombatHUD=true,ArenaHUD=true,MatchStandings=true,HeldStandings=true,AccessibleInteractionHUD=true,MobileCombatHUD=true,SniperZoomHUD=true,OpticalSightHUD=true,OpticalReticle=true,FirstPersonDisplay=true,FloatingMapVote=true,CTFFlagNotice=true}
local function apply(o,r) r.writing=true o.Enabled=not paused and r.desired or false r.writing=false end
local function attach(o)
 if not o:IsA('ScreenGui') or not names[o.Name] or records[o] then return end
 local r={desired=o.Enabled} records[o]=r
 r.changed=o:GetPropertyChangedSignal('Enabled'):Connect(function() if not r.writing then r.desired=o.Enabled if paused then apply(o,r) end end end)
 o.Destroying:Connect(function() r.changed:Disconnect() records[o]=nil end) if paused then apply(o,r) end
end
local function refresh()
 paused=player:GetAttribute('ExperienceMenuOpen')==true or gui.MenuIsOpen
 for o,r in records do apply(o,r) end
end
for _,o in player.PlayerGui:GetChildren() do attach(o) end player.PlayerGui.ChildAdded:Connect(attach)
player:GetAttributeChangedSignal('ExperienceMenuOpen'):Connect(refresh) gui.MenuOpened:Connect(refresh) gui.MenuClosed:Connect(refresh) refresh()