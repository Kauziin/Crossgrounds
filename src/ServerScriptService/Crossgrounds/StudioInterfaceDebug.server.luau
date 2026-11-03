local Run=game:GetService("RunService")if not Run:IsStudio()then return end
local Root=game.ReplicatedStorage.Crossgrounds
local scenarios=require(Root.StudioInterfaceScenarios)local byId={}for _,s in scenarios do byId[s.id]=s end
local command=Instance.new("RemoteFunction")command.Name="StudioInterfaceDebug"command.Parent=Root
local last=setmetatable({},{__mode="k"})
local preview=Instance.new("RemoteFunction")preview.Name="StudioInterfacePreview"preview.Parent=Root
preview.OnServerInvoke=function(player,action,payload)
 if not Run:IsStudio()or action~="preview"or type(payload)~="table"or type(payload.weaponId)~="string"or type(payload.attachments or {})~="table"then return false,"Prévia inválida"end
 local now=os.clock()if now-(last[player]or -1)<.1 then return false,"Aguarde"end last[player]=now
 local model,err=require(script.Parent.ImportedWeaponVisuals).Build(payload.weaponId,payload.attachments or {})if not model then return false,err end
 local gui=player:FindFirstChildOfClass("PlayerGui")if not gui then model:Destroy()return false end
 local cache=gui:FindFirstChild("ArsenalPreviewCache")or Instance.new("Folder",gui)cache.Name="ArsenalPreviewCache"cache:ClearAllChildren()
 model.Name="StudioPreview_"..game.HttpService:GenerateGUID(false)model.Parent=cache return true,model.Name
end
command.OnServerInvoke=function(player,id)
 if not Run:IsStudio()or type(id)~="string"or not byId[id]then return false,"Cenário indisponível"end
 local now=os.clock()if now-(last[player]or -1)<.1 then return false,"Aguarde"end last[player]=now
 for _,event in byId[id].events do
  local remote=game.ReplicatedStorage for part in event.path:gmatch("[^.]+")do remote=remote and remote:FindFirstChild(part)end
  if not remote or not remote:IsA("RemoteEvent")then return false,"Evento ausente: "..event.path end
  local data=event.data or event.value
  if event.special=="blue"then data=game.Teams:FindFirstChild("Blue")end
  if event.special=="eliminated"then data={kind="Eliminated",character=player.Character,killerName="Adversário de teste",weapon="M4A1",studioPreview=true,identity={name="Adversário de teste",level=24,prestige=2,userId=0}}end
  if type(data)=="table"and event.special~="eliminated"then data=game.HttpService:JSONDecode(game.HttpService:JSONEncode(data))if data.endsAt then data.endsAt=workspace:GetServerTimeNow()+30 end end
  remote:FireClient(player,data)
 end
 return true
end
