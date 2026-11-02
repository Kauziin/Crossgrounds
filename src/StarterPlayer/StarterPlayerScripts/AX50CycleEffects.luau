-- Helper owned by the existing FP renderer; no camera/render/input connections.
local Timeline=require(game.ReplicatedStorage.Crossgrounds.AX50Motion)
local Library=require(game.ReplicatedStorage.Crossgrounds.WeaponAudioLibrary)
local Effects={} Effects.__index=Effects
function Effects.new(tool,world)
 return setmetatable({tool=tool,world=world,voices={},casings={},previous=100},Effects)
end
function Effects:Clear()
 for _,s in self.voices do s:Destroy() end table.clear(self.voices)
 for _,entry in self.casings do entry.part:Destroy() end table.clear(self.casings)
end
function Effects:Update(dt,elapsed,stamp,cooldown,reloading,ejectFrame,scale)
 if stamp~=self.stamp then
  self:Clear() self.stamp=stamp self.previous=elapsed<.12 and -.001 or elapsed self.cancelled=elapsed>=.12
 end
 if (reloading or self.tool:GetAttribute("AX50RejectedShotStamp")==stamp) and not self.cancelled then self.cancelled=true self:Clear() end
 if stamp and not self.cancelled then
  if elapsed-self.previous<=.20 then for _,event in Timeline.Events(self.previous,elapsed,cooldown) do
   if event.sound then
    local id=Library.Banks.awp[event.sound]
    if id then
     local s=Instance.new("Sound") s.Name="AX50_"..event.name s.SoundId="rbxassetid://"..id
     s.Volume=.45*(game.Players.LocalPlayer:GetAttribute("SettingGameSFXVolume") or .5) s.RollOffMaxDistance=45 s.Parent=self.tool.Handle
     table.insert(self.voices,s) game:GetService("Debris"):AddItem(s,3) s:Play()
    end
   elseif event.name=="CasingEject" then
    local templates=game.ReplicatedStorage.Crossgrounds:FindFirstChild("CasingTemplates") local source=templates and templates:FindFirstChild("AX50")
    if source then
     local p=source:Clone() p.Name="AX50SpentCasing" p.Size*=.26*(scale or 1)/math.max(p.Size.X,p.Size.Y,p.Size.Z)
     p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false p.CFrame=ejectFrame p.Parent=self.world
     table.insert(self.casings,{part=p,position=ejectFrame.Position,rotation=ejectFrame.Rotation,velocity=ejectFrame:VectorToWorldSpace(Vector3.new(2.8,1.3,.3))*(scale or 1),born=os.clock(),age=0})
    end
   end
   self.tool:SetAttribute("AX50LastVisualMarker",event.name)
  end end
  self.previous=elapsed
 end
 for i=#self.casings,1,-1 do
  local entry=self.casings[i] local t=math.clamp(dt,0,.10) entry.age+=t
  if os.clock()-entry.born>1.1 then entry.part:Destroy() table.remove(self.casings,i)
  else
   entry.velocity+=Vector3.new(0,-12,0)*t entry.position+=entry.velocity*t
   entry.part.CFrame=CFrame.new(entry.position)*entry.rotation*CFrame.Angles(entry.age*8,entry.age*11,entry.age*6)
  end
 end
end
function Effects:Destroy() self:Clear() end
return Effects
