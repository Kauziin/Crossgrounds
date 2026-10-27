local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Loadouts={Names={ctf={},arena={}}}
function Loadouts.List(mode)
 local out={}
 local ids=mode=="arena" and Kits.ArenaPistolVisuals or mode=="ctf" and Kits.Order or {}
 for i,id in ids do
  local profile=mode=="ctf" and Kits.Profiles[id]
  local first=profile and profile.Weapons[2] or "ArenaPistol"
  local second=profile and profile.Weapons[1] or "Sword"
  table.insert(out,{id=id,number=i,name=Loadouts.Names[mode][id] or ("Loadout "..i),class=profile and profile.Title or "PISTOLA",
   primary=mode=="arena" and Kits.ArenaPistolNames[id] or Kits.Weapons[first].Name,
   secondary=Kits.Weapons[second].Name})
 end
 return out
end
function Loadouts.Valid(mode,id)
 if typeof(id)~="string" then return false end
 return mode=="ctf" and Kits.Profiles[id]~=nil or mode=="arena" and Kits:IsPistolVisual(id) or false
end
function Loadouts.ActiveAttribute(mode) return mode=="arena" and "ArenaPistolVisual" or "SelectedKit" end
function Loadouts.PendingAttribute(mode) return mode=="arena" and "PendingArenaLoadout" or "PendingCTFLoadout" end
return Loadouts

