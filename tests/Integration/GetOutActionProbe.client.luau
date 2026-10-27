local event=game.ReplicatedStorage:WaitForChild("GetOutActionProbe",30)if not event then return end
local p=game.Players.LocalPlayer
local Router=require(p.PlayerScripts:WaitForChild("ControlRouter"))
local Interaction=require(p.PlayerScripts:WaitForChild("InteractionController"))
task.spawn(function()
 p.PlayerGui:WaitForChild("GetOutActions",60)
 local deadline=os.clock()+60 repeat task.wait(.1)until p:GetAttribute("ClientLoading")==false or os.clock()>deadline
 event:FireServer({ready=true})
 repeat task.wait(.1)until p:GetAttribute("CrossgroundsMode")=="get_out"and p.PlayerGui.GetOutActions.Enabled and p:GetAttribute("ClientLoading")==false
 event:FireServer({playingReady=true})
end)
event.OnClientEvent:Connect(function(command)
 if command~="interact"then return end
 local prompt=Interaction:Nearest()
 local data={blocked=Router:IsBlocked(),nearest=prompt and prompt:GetFullName(),attributes={}}
 for _,key in {"CrossgroundsMode","ClientLoading","CrossgroundsTransition","ExperienceMenuOpen","GetOutRole","GetOutVictimState","ModeCharacterReady","HUDLayoutEditing"}do data.attributes[key]=p:GetAttribute(key)end
 local ok,err=pcall(function()Router:Dispatch("ReloadInteract",Enum.UserInputState.Begin)task.wait(.65)Router:Dispatch("ReloadInteract",Enum.UserInputState.End)end)
 data.ok=ok data.error=not ok and tostring(err)or nil event:FireServer(data)
end)
