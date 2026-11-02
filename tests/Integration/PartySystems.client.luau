local event=game.ReplicatedStorage:WaitForChild("PartySystemsIntegration",100)if not event then return end
local player=game.Players.LocalPlayer
local root=game.ReplicatedStorage:WaitForChild("Crossgrounds"):WaitForChild("Remotes")
event.OnClientEvent:Connect(function(id,action,payload)
 local ok,result=pcall(function()
  if action=="party"then task.wait(.35)local success,value=root.PartyCommand:InvokeServer(payload.action,payload.payload)return {success=success,value=value}end
  if action=="session"then root.Command:FireServer(payload)return true end
  if action=="menu"then require(player.PlayerScripts.MenuNavigation):OpenMenu("Social")task.wait(.3)return {open=player.PlayerGui.SocialMenu.Enabled}end
  error("unknown test action")
 end)
 event:FireServer(id,{ok=ok,result=ok and result or nil,error=not ok and tostring(result)or nil})
end)
task.spawn(function()
 player.PlayerGui:WaitForChild("SocialMenu",90)
 local deadline=os.clock()+90 repeat task.wait(.1)until player:GetAttribute("ClientLoading")==false or os.clock()>deadline
 event:FireServer(0,true)
end)
