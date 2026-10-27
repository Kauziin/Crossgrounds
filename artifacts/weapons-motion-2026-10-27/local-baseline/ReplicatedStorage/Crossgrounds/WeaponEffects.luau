-- Burst emission uses Roblox's built-in particle texture; no uploaded asset required.
local Effects={}
local generations=setmetatable({},{__mode="k"})
function Effects.Attach(tool,strength)
 local handle=tool:FindFirstChild("Handle") local muzzle=handle and handle:FindFirstChild("Muzzle")
 if not muzzle then return end
 strength=strength or 1
 local burst=Instance.new("ParticleEmitter") burst.Name="MuzzleBurst" burst.Enabled=false burst.Rate=0
 burst.Lifetime=NumberRange.new(.035,.065) burst.Speed=NumberRange.new(2,5) burst.SpreadAngle=Vector2.new(22,22)
 burst.EmissionDirection=Enum.NormalId.Front burst.LightEmission=1 burst.LightInfluence=0
 burst.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.25*strength),NumberSequenceKeypoint.new(.2,.7*strength),NumberSequenceKeypoint.new(1,0)})
 burst.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.6,.15),NumberSequenceKeypoint.new(1,1)})
 burst.Color=ColorSequence.new(Color3.fromRGB(255,249,206),Color3.fromRGB(255,135,32)) burst.Parent=muzzle
 local tip=Instance.new("Attachment") tip.Name="FlashTip" tip.CFrame=muzzle.CFrame*CFrame.new(0,0,-.8*strength) tip.Parent=handle
 local beam=Instance.new("Beam") beam.Name="MuzzleFlame" beam.Attachment0=muzzle beam.Attachment1=tip beam.FaceCamera=true
 beam.Width0=.32*strength beam.Width1=.02 beam.LightEmission=1 beam.LightInfluence=0 beam.Segments=1 beam.Enabled=false
 beam.Color=ColorSequence.new(Color3.fromRGB(255,253,221),Color3.fromRGB(255,139,35)) beam.Parent=muzzle
 local light=Instance.new("PointLight") light.Name="MuzzleFlash" light.Color=Color3.fromRGB(255,208,116) light.Brightness=3*strength light.Range=9*strength light.Enabled=false light.Parent=muzzle
end
function Effects.Play(tool)
 local handle=tool and tool:FindFirstChild("Handle") local muzzle=handle and handle:FindFirstChild("Muzzle")
 if not muzzle then return end
 local burst=muzzle:FindFirstChild("MuzzleBurst") local beam=muzzle:FindFirstChild("MuzzleFlame") local light=muzzle:FindFirstChild("MuzzleFlash")
 if burst then burst:Emit(4) end
 if beam then beam.Enabled=true end if light then light.Enabled=true end
 local token=(generations[muzzle] or 0)+1 generations[muzzle]=token
 task.delay(.045,function()
  if generations[muzzle]~=token then return end
  if beam and beam.Parent then beam.Enabled=false end if light and light.Parent then light.Enabled=false end
 end)
end
-- Each tail has an independent spatial emitter, surviving reloads/weapon swaps.
function Effects.PlaySound(tool)
 local handle=tool and tool:FindFirstChild("Handle") local source=handle and handle:FindFirstChild("FireSound")
 if not source then return end
 local muzzle=handle:FindFirstChild("Muzzle")
 local emitter=Instance.new("Part") emitter.Name="ShotAudio" emitter.Size=Vector3.new(.05,.05,.05)
 emitter.Transparency=1 emitter.Anchored=true emitter.CanCollide=false emitter.CanTouch=false emitter.CanQuery=false
 emitter.CFrame=CFrame.new(muzzle and muzzle.WorldPosition or handle.Position)
 local sound=source:Clone() sound.Name="ShotVoice" sound.TimePosition=0 sound.Looped=false sound.Parent=emitter
 emitter.Parent=workspace sound.Ended:Once(function() if emitter.Parent then emitter:Destroy() end end)
 game:GetService("Debris"):AddItem(emitter,12) sound:Play()
 return emitter
end
local Cosmetics=require(script.Parent.ShotCosmetics)
Effects.Trace=Cosmetics.Trace
Effects.CancelTrace=Cosmetics.Cancel
Effects.CorrectTrace=Cosmetics.Correct
Effects.Projectile=Cosmetics.Projectile
Effects.FinishProjectile=Cosmetics.Finish
return Effects
