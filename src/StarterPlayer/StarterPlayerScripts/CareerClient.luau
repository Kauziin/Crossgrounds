local Client={}
local player=game.Players.LocalPlayer
local P=require(game.ReplicatedStorage.Crossgrounds.CareerPolicy)
local Catalog=require(game.ReplicatedStorage.Crossgrounds.UnlockCatalog)
local changed=Instance.new("BindableEvent") Client.Changed=changed.Event
local state,busy,last=nil,false,-10
function Client.Refresh()
 if busy or player:GetAttribute("CareerReady")~=true then return end
 busy=true
 task.delay(math.max(0,1-(os.clock()-last)),function()
  local remote=game.ReplicatedStorage.Crossgrounds.Remotes:FindFirstChild("CareerCommand")
  if remote then
   local ok,success,data=pcall(function() return remote:InvokeServer("get") end)
   if ok and success and type(data)=="table" then state=data changed:Fire() end
  end
  last=os.clock() busy=false
 end)
end
function Client.Allows(mode,id,weapon)
 if player:GetAttribute("CareerReady")==nil then return true end
 if not state then Client.Refresh() return false,"Carregando desbloqueios..." end
 local item=Catalog.Get(mode,id) if not item then return false,"Somente prévia / indisponível." end
 if state.permanent[mode] and state.permanent[mode][id] then return true end
 if item.weaponLevel then
  local canonical=Catalog.Canonical(weapon)
  return canonical~=nil and P.WeaponLevel(state.weapons[canonical] or 0)>=item.weaponLevel,"Requer arma nível "..item.weaponLevel
 end
 return state.accountUnlocked==true or P.Level(state.cycleXP,state.phase)>=item.level,"Requer conta nível "..item.level
end
player:GetAttributeChangedSignal("CareerReady"):Connect(Client.Refresh)
player:GetAttributeChangedSignal("CareerIdentity"):Connect(Client.Refresh)
player:GetAttributeChangedSignal("CareerCycleXP"):Connect(Client.Refresh)
Client.Refresh()
return Client
