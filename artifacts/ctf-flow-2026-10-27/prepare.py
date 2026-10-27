from pathlib import Path
import shutil
root=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27')
shutil.copytree(root/'baseline',root/'src',dirs_exist_ok=True)
def load(name): return (root/'src'/Path(*name.split('.'))).with_suffix('.luau').read_text(encoding='utf-8')
def save(name,s): (root/'src'/Path(*name.split('.'))).with_suffix('.luau').write_text(s,encoding='utf-8')
def replace(s,a,b):
 assert a in s,a[:100]
 return s.replace(a,b,1)
n='ServerScriptService.MainGameScript.GameManager.PlayerManager'; s=load(n)
a=s.index('join.OnServerEvent:Connect('); b=s.index('preview.OnServerEvent:',a)
s=s[:a]+'''-- Shared server entry path: the adapter and the explicit kit button use the same checks.
function PlayerManager:Join(player,id)
 if not player.Parent or not Context:IsCTF(player) or player:GetAttribute("ModeCharacterReady")~=true then return false,"Aguarde seu personagem ficar pronto." end
 if typeof(id)~="string" or not Kits.Profiles[id] then return false,"Escolha um kit válido." end
 if player:GetAttribute("InArena") then return true,"Boa partida!" end
 if loading[player] then return false,"Seu personagem está sendo preparado." end
 if not player:GetAttribute("InMatch") and not TeamManager:AssignPlayerToTeam(player) then return false,"Equipes cheias. Aguarde uma vaga no lobby." end
 player:SetAttribute("SelectedKit",id)
 if running then
  local maps=require(script.Parent.MapManager)local mapId=workspace:GetAttribute("CurrentMapId")
  loading[player]=true player:SetAttribute("ModeCharacterReady",false)
  local ready,message=require(game.ServerScriptService.Crossgrounds.SceneLoadService):Wait({player},maps:SceneRoots(),maps:SceneAnchors(),function()return player.Parent and Context:IsCTF(player) and running and workspace:GetAttribute("CurrentMapId")==mapId end,.3,true)
  loading[player]=nil
  if not ready then
   if player.Parent and Context:IsCTF(player) then TeamManager:RemovePlayer(player)PlayerManager:Spawn(player) end
   return false,message or "A rodada mudou. Tente entrar novamente."
  end
 end
 if not player.Parent or not Context:IsCTF(player) then return false,"Entrada interrompida." end
 player:SetAttribute("InMatch",true)
 self:Spawn(player)
 return true,running and "Boa partida!" or "Você está pronto! A rodada começa automaticamente."
end
join.OnServerEvent:Connect(function(player,id)
 if player:GetAttribute("CrossgroundsTransition") then return end
 if os.clock()-(lastRequest[player] or -10)<.4 then return end
 lastRequest[player]=os.clock()
 local ok,message=PlayerManager:Join(player,id)
 if player.Parent then result:FireClient(player,ok,message) end
end)
''' +s[b:]; save(n,s)
n='ServerScriptService.Crossgrounds.CTFAdapter';s=load(n)
s=replace(s,'return waitReady(player,self.context,"ctf")','''local ready,message=waitReady(player,self.context,"ctf")
 if not ready then return false,message end
 local joined,reason=self.players:Join(player,player:GetAttribute("SelectedKit") or "Regular")
 if not joined then return false,reason end
 return waitReady(player,self.context,"ctf")'''); save(n,s)
n='StarterPlayer.StarterPlayerScripts.JoinMenu';s=load(n)
s=replace(s,'show(Scope:IsCTF()) end)','show(false) end)')
s=replace(s,'show(Scope:IsCTF())','show(false)')
s=replace(s,'local status=browser:Info("KitDetails","Status","",0) status.LayoutOrder=-1','local status=browser:Info("KitDetails","Status","",0) status.LayoutOrder=-1\nlocal rootStatus=browser:Info("RootPane","Status","Você entra automaticamente com seu kit atual. Use este menu para trocar de kit ou permanecer no lobby.",74) rootStatus.LayoutOrder=-1')
s=replace(s,'if success then show(false) else browser:Push({"RootPane","Loadouts","KitDetails"}) end','if success then show(false) else browser:Push({"RootPane","Loadouts","KitDetails"}) show(true) end');save(n,s)
n='ServerScriptService.Crossgrounds.SceneLoadService';s=load(n)
s=replace(s,'self.prepare=remote("PrepareScene")','self.prepare=remote("PrepareScene")\n self.finished=remote("SceneLoadFinished")')
s=replace(s,'if workspace:GetAttribute("CrossgroundsBootReady")and context:GetMode(player)=="hub"and not player:GetAttribute("CrossgroundsTransition")then context:ReloadHubCharacter(player)end','''if not workspace:GetAttribute("CrossgroundsBootReady") or player:GetAttribute("CrossgroundsTransition") then return end
  if context:GetMode(player)=="hub" then context:ReloadHubCharacter(player)
  elseif context:GetMode(player)=="ctf" and player:GetAttribute("InMatch") and workspace:GetAttribute("RoundState")=="LoadFailed" then
   workspace:SetAttribute("CTFLoadRetry",(workspace:GetAttribute("CTFLoadRetry") or 0)+1)
  end''')
s=replace(s,'if player.Parent then player:SetAttribute("SceneLoading",false)player:SetAttribute("SceneLoadingError",self.context:GetMode(player)==state.mode and message or nil)end','''if player.Parent then
    player:SetAttribute("SceneLoading",false)player:SetAttribute("SceneLoadingError",self.context:GetMode(player)==state.mode and message or nil)
    self.finished:FireClient(player,token,ok,message)
   end''')
s=replace(s,'if pending[player]==state then pending[player]=nil if player.Parent then player:SetAttribute("SceneLoading",false)player:SetAttribute("SceneLoadingError",nil)end end','if pending[player]==state then pending[player]=nil if player.Parent then player:SetAttribute("SceneLoading",false)player:SetAttribute("SceneLoadingError",nil)self.finished:FireClient(player,token,false)end end')
s=replace(s,'root:SetAttribute("ClientSceneIndex",index)end','root:SetAttribute("ClientSceneIndex",index)end')
# Stable identity is per root; a fresh root always receives a fresh revision.
s=replace(s,'if os.clock()>=deadline then return finish(false,"O cenário não terminou de carregar. Volte ao lobby e tente novamente.")end','if os.clock()>=deadline then return finish(false,"O mapa não ficou pronto. Tente carregar novamente ou volte ao lobby pelo menu.")end');save(n,s)
n='ServerScriptService.MainGameScript.GameManager';s=load(n)
s=replace(s,'if not self.loadReady then workspace:SetAttribute("RoundState","LoadFailed")task.wait(2)end','''if not self.loadReady and Player:GetJoinedCount()>=Config.MIN_PLAYERS then
   workspace:SetAttribute("RoundState","LoadFailed")
   local retry=workspace:GetAttribute("CTFLoadRetry") or 0
   repeat task.wait(.2) until Player:GetJoinedCount()<Config.MIN_PLAYERS or (workspace:GetAttribute("CTFLoadRetry") or 0)~=retry
  end''');save(n,s)
n='ReplicatedFirst.CrossgroundsLoading';s=load(n)
s=replace(s,'readyRemote=remotes:WaitForChild("SceneReady")remotes:WaitForChild("PrepareScene").OnClientEvent:Connect(beginScene)','''readyRemote=remotes:WaitForChild("SceneReady")remotes:WaitForChild("PrepareScene").OnClientEvent:Connect(beginScene)
 remotes:WaitForChild("SceneLoadFinished").OnClientEvent:Connect(function(token)
  if request and request.token==token then request=nil end
  prepared[token]=nil
 end)''')
s=replace(s,'if player:GetAttribute("CrossgroundsMode")=="hub"then','if player:GetAttribute("CrossgroundsMode")=="hub" or (player:GetAttribute("CrossgroundsMode")=="ctf" and workspace:GetAttribute("RoundState")=="LoadFailed")then')
s=replace(s,'retry.Text=mode=="hub"and"Recarregar personagem"or"Voltar ao lobby"','retry.Text=mode=="hub"and"Recarregar personagem"or(mode=="ctf" and workspace:GetAttribute("RoundState")=="LoadFailed")and"Tentar carregar mapa"or"Voltar ao lobby"')
# Error UI must include a real exit while a CTF round waits for retry.
s=replace(s,'local elapsed=0','''local exit=retry:Clone() exit.Name="ReturnHub" exit.Text="Voltar ao lobby" exit.Position=UDim2.new(.5,0,0,284) exit.Visible=false exit.Parent=panel
exit.Activated:Connect(function()
 local command=remotes and remotes:FindFirstChild("Command")
 if command then command:FireServer({action="returnHub"}) end
end)
local elapsed=0''')
s=replace(s,'else retry.Visible=false end','else retry.Visible=false end\n exit.Visible=retry.Visible and mode=="ctf" and workspace:GetAttribute("RoundState")=="LoadFailed"')
s=replace(s,'local limit=Instance.new("UISizeConstraint")limit.MaxSize=Vector2.new(540,330)','local limit=Instance.new("UISizeConstraint")limit.MaxSize=Vector2.new(540,370)')
# Finished messages can race one last reliable resend: retire completed tokens briefly.
s=replace(s,'local prepared={}local remotes','local retired={}\nlocal prepared={}local remotes')
s=replace(s,'if prepared[data.token]then','if retired[data.token] then return end\n if prepared[data.token]then')
s=replace(s,'prepared[token]=nil','prepared[token]=nil retired[token]=true\n  task.delay(35,function() retired[token]=nil end)')
s=replace(s,'cosmeticDone=false prepared={}end','cosmeticDone=false prepared={} retired={}end');save(n,s)
n='ServerScriptService.MainGameScript.GameManager.FlagService';s=load(n)
s=replace(s,'local active = false','''local active = false
local alert=Events:FindFirstChild("CTFFlagAlert") or Instance.new("RemoteEvent") alert.Name="CTFFlagAlert" alert.Parent=Events
local function notify(flag,kind,character)
 local actor=character and Players:GetPlayerFromCharacter(character)
 local name=actor and actor.DisplayName or character and (character:GetAttribute("DisplayName") or character.Name) or ""
 for _,viewer in Players:GetPlayers() do
  if viewer:GetAttribute("CrossgroundsMode")=="ctf" and viewer:GetAttribute("InMatch") then
   alert:FireClient(viewer,{kind=kind,team=flag.team.Name,carrier=name,self=actor==viewer})
  end
 end
end''')
s=replace(s,'flag.base:SetAttribute("FlagState",flag.state)','''flag.base:SetAttribute("FlagState",flag.state)
 local ref=flag.base:FindFirstChild("FlagCarrier") or Instance.new("ObjectValue") ref.Name="FlagCarrier" ref.Value=flag.carrier ref.Parent=flag.base
 local actor=flag.carrier and Players:GetPlayerFromCharacter(flag.carrier)
 flag.base:SetAttribute("FlagCarrierName",actor and actor.DisplayName or flag.carrier and (flag.carrier:GetAttribute("DisplayName") or flag.carrier.Name) or nil)''')
s=replace(s,'flag.carrier = nil','if flag.carrier then flag.carrier:SetAttribute("CarryingFlag",nil) end\n flag.carrier = nil')
s=replace(s,'if active and wasAway and not silent then Events.ReturnFlag:Fire(flag.team.TeamColor) end','if active and wasAway and not silent then Events.ReturnFlag:Fire(flag.team.TeamColor) notify(flag,"return") end')
s=replace(s,'flag.state = "dropped"','flag.state = "dropped"\n   notify(flag,"drop",character)')
s=replace(s,'flag.carrier = character','flag.carrier = character\n character:SetAttribute("CarryingFlag",flag.team.Name)')
s=replace(s,'hideFlag(flag)\n local root','hideFlag(flag)\n notify(flag,"pickup",character)\n local root')
s=replace(s,'self:Return(enemy, true)','notify(enemy,"capture",character)\n   self:Return(enemy, true)');save(n,s)
