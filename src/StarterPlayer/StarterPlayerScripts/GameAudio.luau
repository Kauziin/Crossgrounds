local Audio={}
local player=game.Players.LocalPlayer
local SoundService=game:GetService("SoundService") local Content=game:GetService("ContentProvider")
local Catalog=require(game.ReplicatedStorage.Crossgrounds.GameAudioCatalog)
local voices={} local last={} local sequence=0
local function setting(key,default) local v=player:GetAttribute("Setting"..key) return v==nil and default or v end
local function allowed(scope)
 local mode=player:GetAttribute("CrossgroundsMode")
 if player:GetAttribute("AdminCaptureClean") or player:GetAttribute("AdminFreecam") then return false end
 if scope=="combat" then return mode=="ctf" and player:GetAttribute("InMatch")==true or mode=="arena" and player:GetAttribute("ArenaPlaying")==true end
 if scope=="combatMode" then return mode=="ctf" or mode=="arena" end
 if scope=="match" then return mode=="ctf" or mode=="arena" or mode=="get_out" end
 return mode==scope
end
for kind,data in Catalog do
 local pool={cursor=0,items={}} voices[kind]=pool
 for i=1,2 do
  local primary=Instance.new("Sound") primary.Name="Crossgrounds"..kind..i primary.SoundId=data.id primary.Volume=0 primary.Parent=SoundService
  local fallback=Instance.new("Sound") fallback.Name=primary.Name.."Fallback" fallback.SoundId=data.fallback fallback.Volume=0 fallback.Parent=SoundService
  table.insert(pool.items,{primary=primary,fallback=fallback})
 end
end
task.spawn(function()
 local all={} for _,pool in voices do for _,pair in pool.items do table.insert(all,pair.primary) table.insert(all,pair.fallback) end end
 pcall(function() Content:PreloadAsync(all) end)
end)
function Audio:Play(kind,gain)
 local data=Catalog[kind] if not data or not allowed(data.scope) then return false end
 local volume=setting(data.setting or "GameSFXVolume",data.setting and .35 or .5)
 if volume<=0 then return false end
 local now=os.clock() if now-(last[kind] or -100)<data.cooldown then return false end
 last[kind]=now local pool=voices[kind] pool.cursor=pool.cursor%#pool.items+1
 local pair=pool.items[pool.cursor] local voice=pair.primary.IsLoaded and pair.primary or pair.fallback
 voice:Stop() voice.Volume=math.clamp(volume*data.gain*(gain or 1),0,1) voice.PlaybackSpeed=data.pitch voice.TimePosition=0 voice:Play()
 sequence+=1 player:SetAttribute("LastGameSound",kind) player:SetAttribute("GameSoundCount",sequence)
 return true
end
function Audio:Stop(kind)
 local pool=voices[kind] if not pool then return end
 for _,pair in pool.items do pair.primary:Stop() pair.fallback:Stop() end
end
function Audio:StopAll() for kind in voices do self:Stop(kind) end end
player:GetAttributeChangedSignal("CrossgroundsMode"):Connect(function() Audio:StopAll() table.clear(last) end)
for _,key in {"GameSFXVolume","BeastProximityVolume"} do
 player:GetAttributeChangedSignal("Setting"..key):Connect(function()
  if setting(key,.5)<=0 then for kind,data in Catalog do if (data.setting or "GameSFXVolume")==key then Audio:Stop(kind) end end end
 end)
end
player:GetAttributeChangedSignal("AdminCaptureClean"):Connect(function() if player:GetAttribute("AdminCaptureClean") then Audio:StopAll() end end)
return Audio
