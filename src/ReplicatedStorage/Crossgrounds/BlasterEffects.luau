local E={}
local Debris=game:GetService("Debris") local Tween=game:GetService("TweenService")
function E.Flash(tool)
 local muzzle=tool:FindFirstChild("MuzzleAttachment",true)
 if muzzle then for _,v in muzzle:GetChildren() do if v:IsA("ParticleEmitter") then v:Emit(1) end end end
end
function E.Sound(tool,key,position)
 local folder=tool:FindFirstChild("Sounds") local template=folder and folder:FindFirstChild(key)
 if not template then return end
 if template:IsA("Folder") then local list=template:GetChildren() if #list==0 then return end template=list[math.random(#list)] end
 local holder=Instance.new("Part") holder.Name="BlasterAudio" holder.Size=Vector3.one*.05 holder.Transparency=1 holder.Anchored=true holder.CanCollide=false holder.CanTouch=false holder.CanQuery=false
 holder.Position=position or (tool:FindFirstChild("Handle") and tool.Handle.Position or Vector3.zero)
 local s=Instance.new("Sound") s.SoundId=template:IsA("AudioPlayer") and template.Asset or template.SoundId
 local p=game.Players.LocalPlayer local gain=p and p:GetAttribute("SettingGameSFXVolume") or .5
 s.Volume=template.Volume*(gain or .5) s.PlaybackSpeed=template.PlaybackSpeed s.RollOffMaxDistance=180 s.RollOffMinDistance=12
 s.Parent=holder holder.Parent=workspace s.Ended:Once(function()holder:Destroy()end) Debris:AddItem(holder,8) s:Play()
 return holder
end
function E.Bind(track,tool,position)
 local c={}
 table.insert(c,track:GetMarkerReachedSignal("Sound"):Connect(function(key) E.Sound(tool,key,position and position()) end))
 -- Shoot is played immediately once by shot prediction/replication, never twice by a marker.
 return c
end
function E.Trace(origin,endpoint)
 local part=game.ReplicatedStorage.Crossgrounds.ProjectileTest.Objects.LaserBeam:Clone()
 part.CFrame=CFrame.lookAt(origin,endpoint) part.Anchored=true part.CanCollide=false part.CanTouch=false part.CanQuery=false
 local beam=part:FindFirstChildOfClass("Beam") local a,b=beam.Attachment0,beam.Attachment1
 a.Position=Vector3.zero b.Position=Vector3.new(0,0,-(endpoint-origin).Magnitude) part.Parent=workspace
 local duration=math.max(.02,(endpoint-origin).Magnitude/200)
 local tween=Tween:Create(a,TweenInfo.new(duration,Enum.EasingStyle.Linear),{Position=b.Position})
 tween:Play() Debris:AddItem(part,duration+.1)
 return {blaster=true,part=part,target=b}
end
function E.Impact(position,normal,character)
 local name=character and "CharacterImpact" or "EnvironmentImpact"
 local part=game.ReplicatedStorage.Crossgrounds.ProjectileTest.Objects[name]:Clone()
 part.CFrame=CFrame.lookAt(position,position+(normal or Vector3.yAxis)) part.Parent=workspace
 for _,v in part:GetDescendants() do if v:IsA("ParticleEmitter") then v:Emit(v.Name:lower():find("circle") and 2 or 10) end end
 Debris:AddItem(part,.5)
end
return E
