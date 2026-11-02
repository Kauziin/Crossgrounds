local Players=game:GetService("Players") local Run=game:GetService("RunService")
local Library=require(game.ReplicatedStorage.Crossgrounds.WeaponAudioLibrary)
local states=setmetatable({},{__mode="k"}) local elapsed=0
local function clear(state)
 for _,sound in state.voices do if sound.Parent then sound:Destroy() end end
end
Run.Heartbeat:Connect(function(dt)
 elapsed+=dt if elapsed<.03 then return end elapsed=0
 local now=workspace:GetServerTimeNow() local seen={}
 for _,player in Players:GetPlayers() do
  local c=player.Character local h=c and c:FindFirstChildOfClass("Humanoid") local tool=c and c:FindFirstChildOfClass("Tool")
  if h and h.Health>0 and tool and tool:GetAttribute("Reloading")==true and tool:GetAttribute("SourcePack")~="ProjectileTest" then
   local start=tool:GetAttribute("ReloadStartedAt") local duration=tool:GetAttribute("ReloadDuration")
   local handle=tool:FindFirstChild("Handle")
   if start and duration and duration>0 and handle then
    seen[tool]=true local progress=math.clamp((now-start)/duration,0,1) local state=states[tool]
    if not state or state.start~=start then
     if state then clear(state) end
     state={start=start,progress=progress<.05 and -1 or progress,voices={},events=Library.Events(tool:GetAttribute("WeaponId"),tool:GetAttribute("ReloadWasEmpty"))} states[tool]=state
    end
    for _,event in Library.Crossed(state.events,state.progress,progress) do
     local sound=Instance.new("Sound") sound.Name="Reload_"..event.name sound.SoundId="rbxassetid://"..event.id
     sound.Volume=.45 sound.RollOffMinDistance=5 sound.RollOffMaxDistance=65 sound.Parent=handle
     table.insert(state.voices,sound) game:GetService("Debris"):AddItem(sound,4) sound:Play()
    end
    state.progress=progress
   end
  end
 end
 for tool,state in states do if not seen[tool] then clear(state) states[tool]=nil end end
end)
