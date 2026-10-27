local Scope=require(script.Parent:WaitForChild("ModeScope")) if not Scope:HasCTFRuntime() then return end
local player=game.Players.LocalPlayer
local Nav=require(script.Parent:WaitForChild("MenuNavigation")) local Router=require(script.Parent:WaitForChild("ControlRouter"))
local Bridge=require(script.Parent:WaitForChild("HubBridge")) local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local Kits=require(game.ReplicatedStorage.KitDefinitions) local events=game.ReplicatedStorage.Events
local joinResult=events:WaitForChild("JoinMatchResult")
local joinRemote=events:WaitForChild("JoinMatch") local previewRemote=events:WaitForChild("PreviewKit") local leaveRemote=events:WaitForChild("LeaveMatch")
local gui=Instance.new("ScreenGui") gui.Name="JoinMenu" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=50 gui.Enabled=false gui.Parent=player.PlayerGui
local browser=Cascade.new(gui,"Backdrop","CAPTURE A BANDEIRA")
browser:AddPane("Loadouts","ESCOLHER KIT") browser:AddPane("KitDetails","EQUIPAMENTO")
local selected=player:GetAttribute("SelectedKit") or "Regular" local joining=false
local show
local function stay()
 if player:GetAttribute("InMatch") and not player:GetAttribute("InArena") then leaveRemote:FireServer() end
 show(false) player:SetAttribute("CTFLobbyMenuDismissed",true)
end
browser.OnClose=stay
local keep=browser:Button("RootPane","StayLobby","Permanecer no lobby",stay)
local function request()
 if joining or not Scope:IsCTF() or player:GetAttribute("InArena") or player:GetAttribute("CrossgroundsTransition") then return end
 joining=true joinRemote:FireServer(selected)
 task.delay(5,function() joining=false end)
end
browser:Button("RootPane","JoinButton","Entrar na partida",request)
browser:Button("RootPane","Loadout","Escolher kit  ›",function() browser:Push({"RootPane","Loadouts"}) end)
browser:Button("RootPane","Settings","Ajustes",function() show(false) Nav:OpenMenu("Settings") end)
browser:Button("RootPane","ReturnHub","Voltar ao lobby principal",function() show(false) Bridge:Send("returnHub") end)
local details=browser:Info("KitDetails","Weapons","",100)
browser:Button("KitDetails","JoinSelected","Entrar com este kit",request)
browser:Button("KitDetails","StayLobby","Permanecer no lobby",stay)
local status=browser:Info("KitDetails","Status","",0) status.LayoutOrder=-1
local cards={}
local function select(id,notify)
 selected=id local profile=Kits.Profiles[id]
 details.Text=profile.Title.."\n\nPrimária: "..Kits.Weapons[profile.Weapons[2]].Name.."\nSecundária: "..Kits.Weapons[profile.Weapons[1]].Name
 for key,button in cards do button.Text="  "..Kits.Profiles[key].Title..(key==selected and "  ✓" or "") end
 if notify then previewRemote:FireServer(id) end
end
for _,id in Kits.Order do
 cards[id]=browser:Button("Loadouts",id,Kits.Profiles[id].Title,function() select(id,true) browser:Push({"RootPane","Loadouts","KitDetails"}) end,58)
end
show=function(on)
 on=on and Scope:IsCTF() and not player:GetAttribute("InArena")
 gui.Enabled=on browser:SetOpen(on) player:SetAttribute("CTFKitMenuOpen",on)
end
Nav:SetBack(browser.Panel,function() if #browser.Stack>1 then browser:Push({"RootPane"}) else stay() end end,keep)
joinResult.OnClientEvent:Connect(function(success,message) joining=false status.Text=message or "" status.Size=UDim2.new(1,-8,0,success and 0 or 62) if success then show(false) else browser:Push({"RootPane","Loadouts","KitDetails"}) end end)
Router:Register("KitMenu",function(state) if state==Enum.UserInputState.Begin and not player:GetAttribute("InArena") and not player:GetAttribute("ExperienceMenuOpen") then show(not gui.Enabled) end end,{allowMenus=true})
game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt) if prompt.Name=="KitPrompt" then browser:Push({"RootPane","Loadouts"}) show(true) end end)
player:GetAttributeChangedSignal("InArena"):Connect(function() if player:GetAttribute("InArena") then show(false) end end)
Scope.Changed:Connect(function() joining=false browser:Push({"RootPane"}) show(Scope:IsCTF()) end)
Nav.MenuRequested:Connect(function(id) if id=="CTFKits" and Scope:IsCTF() then browser:Push({"RootPane","Loadouts"}) show(true) elseif id=="Resume" or id=="Settings" or id=="Main" then show(false) end end)
select(selected,false) browser:Push({"RootPane"}) show(Scope:IsCTF())

