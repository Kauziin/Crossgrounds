-- Coordinates client geometry/floor readiness before starting a round.
local Service={}
local Players=game:GetService("Players")
local pending={}local sequence=0
function Service:Start(context)
 if self.started then return end self.started=true self.context=context
 local remotes=game.ReplicatedStorage.Crossgrounds.Remotes
 local function remote(name)local r=remotes:FindFirstChild(name)or Instance.new("RemoteEvent")r.Name=name r.Parent=remotes return r end
 self.prepare=remote("PrepareScene")
 remote("SceneReady").OnServerEvent:Connect(function(player,token)
  local state=pending[player]
  if state and typeof(token)=="string"and state.token==token and context:GetMode(player)==state.mode then state.ready=true end
 end)
 local retryRates={}
 remote("RetryLoading").OnServerEvent:Connect(function(player)
  if os.clock()-(retryRates[player]or-10)<3 then return end retryRates[player]=os.clock()
  if workspace:GetAttribute("CrossgroundsBootReady")and context:GetMode(player)=="hub"and not player:GetAttribute("CrossgroundsTransition")then context:ReloadHubCharacter(player)end
 end)
 Players.PlayerRemoving:Connect(function(player)pending[player]=nil retryRates[player]=nil end)
end
function Service:Wait(players,roots,anchors,canContinue,minSeconds,terrain)
 assert(self.started,"SceneLoadService não iniciado.")
 sequence+=1 local token="scene_"..sequence local descriptors={}local parts=0
 for index,root in roots do
  if not root:GetAttribute("ClientSceneRevision")then root:SetAttribute("ClientSceneRevision",token)root:SetAttribute("ClientSceneIndex",index)end
  local count=root:IsA("BasePart")and 1 or 0
  for i,obj in root:GetDescendants()do if obj:IsA("BasePart")then count+=1 end if i%1000==0 then task.wait()end end
  parts+=count table.insert(descriptors,{name=root.Name,revision=root:GetAttribute("ClientSceneRevision"),index=root:GetAttribute("ClientSceneIndex"),parts=count})
 end
 local payload={token=token,roots=descriptors,anchors=anchors or{},terrain=terrain==true,parts=parts}
 local states={}local started=os.clock()local deadline=started+30 local nextSend=0
 local function finish(ok,message)
  for player,state in states do if pending[player]==state then pending[player]=nil
   if player.Parent then player:SetAttribute("SceneLoading",false)player:SetAttribute("SceneLoadingError",self.context:GetMode(player)==state.mode and message or nil)end
  end end
  return ok,message
 end
 while true do
  if canContinue and not canContinue()then return finish(false)end
  local current=typeof(players)=="function"and players()or players local allReady=true
  local present={}for _,player in current do present[player]=true end
  for player,state in states do if not present[player]then
   if pending[player]==state then pending[player]=nil if player.Parent then player:SetAttribute("SceneLoading",false)player:SetAttribute("SceneLoadingError",nil)end end
   states[player]=nil
  end end
  for _,player in current do if player.Parent then
   local state=states[player]
   if not state then state={token=token,ready=false,mode=self.context:GetMode(player)}states[player]=state pending[player]=state
    player:SetAttribute("SceneLoadingError",nil)player:SetAttribute("SceneLoading",true)
    self.prepare:FireClient(player,payload)
   end
   if not state.ready then allReady=false end
  end end
  if allReady and os.clock()-started>=(minSeconds or 0)then return finish(true)end
  if os.clock()>=deadline then return finish(false,"O cenário não terminou de carregar. Volte ao lobby e tente novamente.")end
  if os.clock()>=nextSend then nextSend=os.clock()+1 for _,player in current do local state=states[player]if player.Parent and state and not state.ready then self.prepare:FireClient(player,payload)end end end
  task.wait(.1)
 end
end
return Service
