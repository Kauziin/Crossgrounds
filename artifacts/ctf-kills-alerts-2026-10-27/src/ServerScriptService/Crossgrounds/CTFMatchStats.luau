-- Per-round bot participants, keyed by team/slot rather than disposable characters.
local Stats={}
local records={}
local function id(model)
 if not model or not model:GetAttribute("CTFBot") then return end
 local team=model:GetAttribute("CTFTeam") local slot=model:GetAttribute("CTFSlot")
 if (team~="Blue" and team~="Red") or typeof(slot)~="number" then return end
 return -(team=="Blue" and 100 or 200)-slot,team
end
local function sync(record)
 local model=record.model
 if model and model.Parent then
  record.name=model:GetAttribute("BotAlias") or record.name
  record.avatarUserId=model:GetAttribute("AvatarUserId") or record.avatarUserId
  for _,key in {"Kills","Deaths","Captures"} do model:SetAttribute("CTF"..key,record[key]) end
 end
end
function Stats.Attach(model)
 local key,team=id(model) if not key then return end
 local record=records[key] or {id=key,team=team,Kills=0,Deaths=0,Captures=0,name=model:GetAttribute("BotAlias") or model.Name}
 records[key]=record record.model=model sync(record)
end
function Stats.Add(model,field)
 local key=id(model) local record=key and records[key]
 if not record or (field~="Kills" and field~="Deaths" and field~="Captures") then return end
 record[field]+=1 sync(record)
end
function Stats.Remove(model)
 local key=id(model) local record=key and records[key]
 if record and record.model==model then records[key]=nil end
end
function Stats.Reset() table.clear(records) end
function Stats.Snapshot()
 local rows={}
 for _,record in records do
  sync(record)
  table.insert(rows,{userId=record.id,avatarUserId=record.avatarUserId or 0,isBot=true,name=record.name.." · IA",team=record.team,kills=record.Kills,deaths=record.Deaths,score=record.Captures})
 end
 return rows
end
return Stats
