local player=game.Players.LocalPlayer
local Nav=require(script.Parent:WaitForChild("MenuNavigation"))
local Scope=require(script.Parent:WaitForChild("ModeScope"))
local Cascade=require(script.Parent:WaitForChild("CascadeMenu"))
local P=require(game.ReplicatedStorage.Crossgrounds:WaitForChild("CareerPolicy"))
local Catalog=require(game.ReplicatedStorage.Crossgrounds:WaitForChild("IdentityCatalog"))
local Identity=require(script.Parent:WaitForChild("PlayerIdentityView"))
local Unlocks=require(game.ReplicatedStorage.Crossgrounds.UnlockCatalog)
local remote=game.ReplicatedStorage.Crossgrounds:WaitForChild("Remotes"):WaitForChild("CareerCommand")
local gui=Instance.new("ScreenGui") gui.Name="CareerMenu" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=79 gui.Enabled=false gui.Parent=player.PlayerGui
local browser=Cascade.new(gui,"Backdrop","CARREIRA E IDENTIDADE")
browser:AddPane("Identity","PERSONALIZAR PERFIL") browser:AddPane("Prestige","CONFIRMAR TRANSIÇÃO")
browser:AddPane("Unlocks","DESBLOQUEIOS") browser:AddPane("UnlockConfirm","DESBLOQUEIO PERMANENTE")
local state,busy
local selectedItem,selectedMode
local tokenInfo=browser:Info("Unlocks","Tokens","",76)
local tokenConfirm=browser:Info("UnlockConfirm","Description","",132)
local tokenStatus=browser:Info("UnlockConfirm","Status","",58)
local status=browser:Info("RootPane","Status","Carregando...",64)
local identityStatus=browser:Info("Identity","Status","Escolha um cosmético conquistado.",64)
local transitionStatus=browser:Info("Prestige","Status","",52)
status:GetPropertyChangedSignal("Text"):Connect(function() identityStatus.Text=status.Text transitionStatus.Text=status.Text tokenInfo.Text=status.Text tokenStatus.Text=status.Text end)
local previewHolder=browser:Info("RootPane","Preview","",138) previewHolder.Text=""
local preview=Identity.new(previewHolder) preview.Frame.Size=UDim2.new(1,0,0,126)
preview:Render({userId=player.UserId,name=player.DisplayName,level=player:GetAttribute("CareerLevel") or 1,phase=player:GetAttribute("CareerPhase"),prestige=player:GetAttribute("CareerPrestige") or 0})
local info=browser:Info("RootPane","Progress","",78)
local confirmInfo=browser:Info("Prestige","Effects","",170)
local function close()
 gui.Enabled=false browser:SetOpen(false) player:SetAttribute("CareerMenuOpen",false) Nav:OpenMenu(Scope:IsHub() and "Hub" or "Main")
end
browser.OnClose=close
local refresh,renderUnlocks
local function call(action,payload)
 if busy then return false end busy=true
 local ok,success,result=pcall(function() return remote:InvokeServer(action,payload) end)
 busy=false
 if not ok then status.Text="Não foi possível concluir. Tente atualizar." return false end
 if not success then status.Text=tostring(result) return false end
 return true,result
end
refresh=function()
 local ok,data=call("get") if not ok then return end state=data
 preview:Render(P.Public(state,player.UserId,player.DisplayName))
 info.Text="XP histórico: "..state.lifetimeXP.."\nXP desta etapa: "..state.cycleXP..(state.phase=="legend" and " · sem teto de nível" or " / "..P.Cap(state.phase)).."\n"..(player:GetAttribute("CareerSaveState")=="StudioSessionOnly" and "Studio: progresso apenas nesta sessão." or "Progresso da conta")
 status.Text="Progressão das armas e cosméticos conquistados permanecem após o prestígio."
 tokenInfo.Text="Tokens · Conflict: "..state.tokens.ctf.." · Arena: "..state.tokens.arena.."\nDesbloqueios permanentes atravessam os resets."
 if renderUnlocks then renderUnlocks() end
 confirmInfo.Text=(state.phase=="mastery" and "Entrar na Lenda" or state.prestige==10 and "Entrar na Maestria" or "Entrar no Prestígio "..(state.prestige+1)).."\n\nNível volta a 1. "..(state.phase=="mastery" and "Desbloqueios da conta permanecem." or "Desbloqueios funcionais por nível serão reiniciados.").."\nArmas, cosméticos e permanências são preservados.\nVocê recebe um token por modalidade."
end
browser:Button("RootPane","Refresh","Atualizar",refresh)
browser:Button("RootPane","Identity","Personalizar perfil  ›",function() browser:Push({"RootPane","Identity"}) end)
browser:Button("RootPane","Unlocks","Desbloqueios e tokens  ›",function() browser:Push({"RootPane","Unlocks"}) end)
browser:Button("RootPane","Prestige","Prestígio / próxima etapa  ›",function() if state and state.phase~="legend" then browser:Push({"RootPane","Prestige"}) else status.Text="A Lenda não possui outro reset." end end)
browser:Button("RootPane","Close","Voltar",close)
browser:Button("Prestige","Confirm","Confirmar transição",function()
 if not state then return end local ok=call("prestige",state.transitions) if ok then browser:Push({"RootPane"}) refresh() end
end)
browser:Button("UnlockConfirm","Confirm","Usar 1 token desta modalidade",function()
 if not selectedItem then return end
 local ok=call("unlock",{mode=selectedMode,item=selectedItem.id})
 if ok then browser:Push({"RootPane","Unlocks"}) refresh() end
end)
local unlockRows={} local unlockPage=1 local unlockMode="ctf"
renderUnlocks=function()
 for _,row in unlockRows do row:Destroy() end table.clear(unlockRows)
 local items=Unlocks.List(unlockMode) local last=math.min(#items,unlockPage*20)
 for i=(unlockPage-1)*20+1,last do
  local item=items[i]
  local permanent=state and state.permanent[unlockMode][item.id]
  table.insert(unlockRows,browser:Button("Unlocks","Item"..i,item.name.." · "..(permanent and "Permanente" or item.level and "Conta nível "..item.level or "Arma nível "..item.weaponLevel),function()
   selectedItem=item selectedMode=unlockMode
   tokenConfirm.Text=item.name.."\n"..(unlockMode=="ctf" and "Conflict" or "Arena").."\nCusta 1 token. A permanência sobrevive aos resets. Acessórios continuam exigindo uma arma compatível."
   browser:Push({"RootPane","Unlocks","UnlockConfirm"})
  end,52))
 end
end
browser:Button("Unlocks","Mode","Alternar Conflict / Arena",function() unlockMode=unlockMode=="ctf" and "arena" or "ctf" unlockPage=1 renderUnlocks() end)
browser:Button("Unlocks","NextPage","Próxima página",function() local count=#Unlocks.List(unlockMode) unlockPage=unlockPage*20<count and unlockPage+1 or 1 renderUnlocks() end)
renderUnlocks()
for _,entry in {{"card","cards"},{"frame","frames"},{"title","titles"},{"emblem","emblems"}} do
 local slot,category=table.unpack(entry)
 local ids={} for id in Catalog[category] do table.insert(ids,id) end table.sort(ids)
 for _,id in ids do
  local label=({card="Cartão",frame="Moldura",title="Título",emblem="Emblema"})[slot]
  browser:Button("Identity",slot.."_"..id,label.." · "..Catalog[category][id].name,function()
   if not state or not state.cosmetics[category][id] then status.Text="Cosmético ainda não conquistado." return end
   local ok=call("identity",{slot=slot,id=id}) if ok then refresh() end
  end)
 end
end
Nav.MenuRequested:Connect(function(id)
 if id=="Career" then
  player:SetAttribute("ProgressionMenuOpen",false) player:SetAttribute("LobbyMusicMenuOpen",false) player:SetAttribute("CareerMenuOpen",true)
  gui.Enabled=true browser:Push({"RootPane"}) browser:SetOpen(true) refresh()
  if not state then task.delay(.35,function() if gui.Enabled and not state then refresh() end end) end
 elseif table.find({"Main","Hub","Settings","Resume","Playlist","Progress","Pause"},id) then gui.Enabled=false browser:SetOpen(false) player:SetAttribute("CareerMenuOpen",false) end
end)
Scope.Changed:Connect(function() gui.Enabled=false browser:SetOpen(false) player:SetAttribute("CareerMenuOpen",false) end)
