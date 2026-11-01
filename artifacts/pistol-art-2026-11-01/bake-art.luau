-- Run only in the isolated edit copy. No imported scripts are executed.
local Root=game.ReplicatedStorage.Crossgrounds
local A=require(Root.AttachmentCatalog)
local Visual=require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals)
local folder=Instance.new('Folder') folder.Name='AttachmentArtBake' folder.Parent=game.ReplicatedStorage
local entries={{id='none',name='Sem acessório'}}
for _,a in A do table.insert(entries,{id=a.id,name=a.name,logical=a.functionalBurst==true}) end
table.sort(entries,function(a,b) if a.id=='none' then return b.id~='none' elseif b.id=='none' then return false end return a.id<b.id end)
for i,entry in entries do
 if entry.id~='none' and not entry.logical then
  local model,err=Visual.Build(entry.id,{}) assert(model,entry.id..': '..tostring(err))
  local handle=model:FindFirstChild('Handle') if handle then handle:Destroy() end model.PrimaryPart=nil
  model.Name=entry.id model.Parent=folder
 end
 if i%12==0 then task.wait() end
end
folder:SetAttribute('Entries',game.HttpService:JSONEncode(entries))
game.HttpService:PostAsync('http://127.0.0.1:18769/art-manifest.json',game.HttpService:JSONEncode({entries=entries,columns=10,cellWidth=160,cellHeight=96,width=1600,height=math.ceil(#entries/10)*96}),Enum.HttpContentType.ApplicationJson)
return {entries=#entries,models=#folder:GetChildren()}
