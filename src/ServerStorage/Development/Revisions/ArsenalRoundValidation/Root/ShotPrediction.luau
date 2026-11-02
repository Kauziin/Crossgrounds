-- Reservations bridge attribute replication and acknowledgements, including reordering.
local Prediction={} Prediction.__index=Prediction
function Prediction.new() return setmetatable({pending={},versions=setmetatable({},{__mode="k"})},Prediction) end
function Prediction:Available(tool)
 local version=tool:GetAttribute("ShotAmmoVersion") or 0
 local ammo=tool:GetAttribute("Ammo") or 0 local known=self.versions[tool]
 if known and known.version>=version then ammo=known.ammo version=known.version end
 for _,p in self.pending do if p.tool==tool and (not p.version or p.version>version) then ammo-=1 end end
 return math.max(0,ammo)
end
function Prediction:Reserve(id,tool,now) self.pending[id]={tool=tool,at=now} end
function Prediction:Confirm(message)
 local p=self.pending[message.shotId] if not p then return end
 local tool=p.tool
 if message.tool~=tool then return end
 if message.accepted then p.version=message.version else self.pending[message.shotId]=nil end
 if typeof(message.version)=="number" and typeof(message.ammo)=="number" then
  local known=self.versions[tool]
  if not known or message.version>=known.version then self.versions[tool]={version=message.version,ammo=message.ammo} end
 end
 if message.accepted then self.pending[message.shotId]=nil end
end
function Prediction:Prune(now)
 for id,p in self.pending do if not p.tool.Parent or now-p.at>3 then self.pending[id]=nil end end
end
function Prediction:Clear() table.clear(self.pending) end
return Prediction
