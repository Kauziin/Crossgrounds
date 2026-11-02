local Service={}
local Players=game:GetService("Players") local Run=game:GetService("RunService") local Http=game:GetService("HttpService")
local Root=game.ReplicatedStorage.Crossgrounds local Catalog=require(Root.WeaponCatalog) local Config=require(Root.WeaponVisualConfiguration)
local Visuals=require(script.Parent.ImportedWeaponVisuals)
local records={} local rates={} local store
local normalRecords,practiceRecords={},{}
local function snapshot(p)
 local r=records[p] if r then p:SetAttribute("CTFArsenalState",Http:JSONEncode({version=1,presets=r.presets,selectedIndex=r.selectedIndex,visualPresets=r.visualPresets,active=r.active,pending=r.pending,saveState=r.saveState})) end
end
local function save(p)
 local r=normalRecords[p]or records[p] if not r or r.practice or not r.loaded or not store then return end
 local data={version=1,presets=r.presets,visualPresets=r.visualPresets}
 local ok=pcall(function() store:UpdateAsync("u"..p.UserId,function(old) if type(old)=="table" and (old.version or 0)>1 then error("Newer schema") end return data end) end)
 if records[p]==r then r.saveState=ok and "Saved" or "RetryPending" snapshot(p) end
end
local function queueSave(p)
 local r=records[p] if not r or r.queued then return end r.queued=true
 task.delay(1,function() if records[p]==r then r.queued=false save(p) end end)
end
function Service.Get(p) return records[p] end
function Service.Resolve(p)
 local r=records[p] return require(script.Parent.UnlockService).Resolve(p,r and r.active)
end
function Service.Backends(p)
 local c=Service.Resolve(p) if not c then return end
 return {c.meleeWeaponId,Catalog.Get(c.primaryWeaponId).combatId,Catalog.Get(c.secondaryWeaponId).combatId}
end
function Service.ApplyPending(p)
 local r=records[p] if not r then return end
 if p:GetAttribute("PendingCTFLoadout") then r.active=nil r.pending=nil
 elseif r.pending then r.active=r.pending r.pending=nil end snapshot(p)
end
function Service.Start()
 if Service.started then return end Service.started=true
 if not Run:IsStudio() then store=game:GetService("DataStoreService"):GetDataStore("Crossgrounds_VisualArsenal_v1") end
 local function added(p)
  local r={presets={},visualPresets={},saveState=Run:IsStudio() and "StudioSessionOnly" or "Loading",loaded=Run:IsStudio()}
  for i=1,5 do r.presets[i]=Config.Default(i) end records[p]=r normalRecords[p]=r snapshot(p)
  p:GetAttributeChangedSignal("CTFPracticeRange"):Connect(function()
   if p:GetAttribute("CTFPracticeRange")==true then
    if not practiceRecords[p]then
     local practice={presets={},visualPresets={},loaded=true,practice=true,saveState="PracticeSessionOnly"}
     for i=1,5 do practice.presets[i]=Config.Default(i)end practiceRecords[p]=practice
    end
    records[p]=practiceRecords[p]
   else records[p]=normalRecords[p]end
   snapshot(p)
  end)
  if not store then return end
  local ok,data=pcall(function() return store:GetAsync("u"..p.UserId) end)
  if normalRecords[p]~=r then return end
  if ok and (not data or type(data)=="table" and data.version==1) then
   if data then
    for i=1,math.min(Config.MaxLoadouts,math.max(5,type(data.presets)=='table' and #data.presets or 0)) do local valid=Config.Loadout(type(data.presets)=="table" and data.presets[i]) r.presets[i]=valid or Config.Default(i) end
    if type(data.visualPresets)=="table" then for key,v in data.visualPresets do if type(key)=="string" and #key<=48 and type(v)=="table" then local clean=Config.Validate(v.weaponId,v.attachments or {},false) if clean then r.visualPresets[key]={weaponId=v.weaponId,attachments=clean} end end end end
   end r.loaded=true r.saveState="Loaded"
  else r.saveState="LoadFailed" end snapshot(p)
 end
 Players.PlayerAdded:Connect(added) for _,p in Players:GetPlayers() do task.spawn(added,p) end
 Players.PlayerRemoving:Connect(function(p) if normalRecords[p]then records[p]=normalRecords[p]end save(p) records[p]=nil normalRecords[p]=nil practiceRecords[p]=nil rates[p]=nil end)
 game:BindToClose(function() for p in records do task.spawn(save,p) end if store then task.wait(2) end end)
 local remotes=Root.Remotes
 local update=Instance.new("RemoteFunction") update.Name="ArsenalCommand" update.Parent=remotes
 update.OnServerInvoke=function(p,command,payload)
  local r=records[p] if not r or p:GetAttribute("CrossgroundsMode")~="ctf" or p:GetAttribute("CrossgroundsTransition") then return false,"Indisponível nesta modalidade." end
  local now=os.clock() if now-(rates[p] or -10)<.12 then return false,"Aguarde um instante." end rates[p]=now
  if command=="save" then
   if type(payload)~="table" or type(payload.index)~="number" or payload.index%1~=0 or payload.index<1 or payload.index>#r.presets then return false,"Preset inválido." end
   local valid,err=Config.Loadout(payload.loadout) if not valid then return false,err end
   local allowed,reason=require(script.Parent.UnlockService).Validate(p,valid) if not allowed then return false,reason end
   local kits=require(game.ReplicatedStorage.KitDefinitions) local profile=kits.Profiles[p:GetAttribute("SelectedKit")] or kits.Profiles.Regular
   valid.meleeWeaponId=profile.Weapons[1]
   if not r.loaded then return false,"As preferências não foram carregadas; seleção preservada." end
    local practice=p:GetAttribute("CTFPracticeRange")==true
    local character=p.Character local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    if practice and (not character or not humanoid or humanoid.Health<=0 or character:GetAttribute("AtLobby")~=true) then return false,"O personagem do Practice Range não está pronto." end
    r.presets[payload.index]=valid r.selectedIndex=payload.index
    if practice then r.active=valid r.pending=nil else r.pending=valid end
    p:SetAttribute("PendingCTFLoadout",nil) snapshot(p) queueSave(p)
    if practice then
     require(game.ServerScriptService.MainGameScript.GameManager.KitService):ApplyToCharacter(p,character)
    require(game.ServerScriptService.MainGameScript.GameManager.MovementService):ApplyToCharacter(p)
     return true,"Loadout equipado imediatamente no Practice Range."
    end
    return true,"Aplicação no próximo nascimento."
  elseif command=='manage' then
   if type(payload)~='table' or type(payload.index)~='number' or payload.index%1~=0 or not r.presets[payload.index] or not r.loaded then return false,'Classe inválida.' end
   local index=payload.index local preset=r.presets[index]
   if payload.op=='rename' then
    local candidate=Http:JSONDecode(Http:JSONEncode(preset)) candidate.name=payload.name local valid,why=Config.Loadout(candidate) if not valid then return false,why end
    r.presets[index]=valid if r.selectedIndex==index and r.pending then r.pending.name=valid.name end
   elseif payload.op=='duplicate' then
    if #r.presets>=Config.MaxLoadouts then return false,'Limite de 12 classes atingido.' end
    local candidate=Http:JSONDecode(Http:JSONEncode(preset)) candidate.name='Cópia '..(#r.presets+1) table.insert(r.presets,candidate)
   elseif payload.op=='delete' then
    if #r.presets<=1 then return false,'Mantenha pelo menos uma classe.' end
    table.remove(r.presets,index)
    if r.selectedIndex==index then r.selectedIndex=nil r.pending=nil elseif r.selectedIndex and r.selectedIndex>index then r.selectedIndex-=1 end
   else return false,'Operação inválida.' end
   snapshot(p) queueSave(p) return true,'Classe atualizada.'
  elseif command=="visual" then
   if type(payload)~="table" or type(payload.name)~="string" or #payload.name<1 or #payload.name>48 or not r.loaded then return false,"Nome inválido." end
   local count=0 for _ in r.visualPresets do count+=1 end if count>=20 and not r.visualPresets[payload.name] then return false,"Limite de 20 visuais." end
   local clean,err=Config.Validate(payload.weaponId,payload.attachments or {},false) if not clean then return false,err end
   r.visualPresets[payload.name]={weaponId=payload.weaponId,attachments=clean} snapshot(p) queueSave(p) return true,"Visual salvo."
  elseif command=="preview" then
   if type(payload)~="table" or type(payload.weaponId)~="string" then return false,"Arma inválida." end
   local w=Catalog.Get(payload.weaponId) local variant=Catalog.Variants[payload.weaponId] local auxiliary=require(Root.AttachmentCatalog)[payload.weaponId] if not w and not variant and not auxiliary then return false,"Modelo desconhecido." end
   local configuration=payload.attachments or {} if typeof(configuration)~="table" then return false,"Configuração inválida." end if not w and next(configuration) then return false,"Variante de prévia." end
   local model,err=Visuals.Build(payload.weaponId,configuration) if not model then return false,err end
   local gui=p:FindFirstChildOfClass("PlayerGui") if not gui then model:Destroy() return false,"Interface indisponível." end
   local cache=gui:FindFirstChild("ArsenalPreviewCache") or Instance.new("Folder",gui) cache.Name="ArsenalPreviewCache" cache:ClearAllChildren()
   model.Name="Preview_"..Http:GenerateGUID(false) model.Parent=cache return true,model.Name
  end return false,"Comando desconhecido."
 end
end
return Service
