local Authority=require(script.Parent.ShotAuthority)
local Damage=require(game.ServerScriptService.MainGameScript.GameManager.DamageService)
local Kits=require(game.ReplicatedStorage.KitDefinitions)
local Combat={} Combat.__index=Combat
Combat.Metrics={shots=0,hits=0,firstShotTotal=0,firstShotCount=0,bands={Near={shots=0,hits=0},Mid={shots=0,hits=0},Far={shots=0,hits=0}}}
local function band(distance) return distance<35 and "Near" or distance<90 and "Mid" or "Far" end
function Combat.new(bot,profile,rng)
 local tool=bot:FindFirstChildOfClass("Tool") local data=tool and Kits.Weapons[tool:GetAttribute("WeaponId")]
 if not data then return end
 tool:SetAttribute("Ammo",data.Magazine) tool:SetAttribute("ReserveAmmo",data.Reserve) tool:SetAttribute("Reloading",false)
 return setmetatable({alive=true,bot=bot,tool=tool,data=data,profile=profile,rng=rng,phase=rng:NextNumber(0,math.pi*2),reaction=rng:NextNumber(table.unpack(profile.Reaction)),direction=bot.HumanoidRootPart.CFrame.LookVector,burst=0,nextBurst=0,shots=0,hits=0,denied="idle"},Combat)
end
function Combat.Rotate(current,desired,radians)
 local angle=math.acos(math.clamp(current:Dot(desired),-1,1))
 if angle<.0001 then return desired end
 return CFrame.lookAt(Vector3.zero,current):Lerp(CFrame.lookAt(Vector3.zero,desired),math.min(1,radians/angle)).LookVector
end
function Combat:Update(memory,dt,now,allow)
 local root=self.bot:FindFirstChild("HumanoidRootPart") local h=self.bot:FindFirstChildOfClass("Humanoid")
 if not root or not h or h.Health<=0 or self.tool.Parent~=self.bot then self.denied="invalid" return end
 local ammo=self.tool:GetAttribute("Ammo") or 0
 if ammo<=0 and (self.tool:GetAttribute("ReserveAmmo") or 0)>0 then Authority.ReloadNPC(self.bot,self.tool,function() return self.alive and self.bot.Parent and h.Health>0 end) end
 if not memory.visible or not memory.position or now-(memory.seenAt or 0)>self.profile.Scan+.15 then self.denied="not_visible" h.AutoRotate=true return end
 local victim=memory.target and memory.target:FindFirstChildOfClass("Humanoid")
 if not victim or victim.Health<=0 then self.denied="target_invalid" return end
 local point=memory.position+(memory.velocity or Vector3.zero)*self.profile.Lead
 local from=root.Position+Vector3.new(0,1.5,0) local delta=point-from if delta.Magnitude<.05 then return end
 local moving=root.AssemblyLinearVelocity.Magnitude>3 and 1.3 or 1
 local errorAngle=math.rad(self.profile.Error*moving)
 local desired=(CFrame.lookAt(Vector3.zero,delta)*CFrame.Angles(math.sin(now*1.3+self.phase)*errorAngle*.65,math.sin(now*.9+self.phase*1.7)*errorAngle,0)).LookVector
 self.direction=Combat.Rotate(self.direction,desired,math.rad(self.profile.AimRate)*dt)
 local flat=Vector3.new(self.direction.X,0,self.direction.Z)
 if flat.Magnitude>.1 then
  local current=Vector3.new(root.CFrame.LookVector.X,0,root.CFrame.LookVector.Z).Unit
  local facing=Combat.Rotate(current,flat.Unit,math.rad(self.profile.TurnRate)*dt)
  h.AutoRotate=false root.CFrame=CFrame.lookAt(root.Position,root.Position+facing)
 end
 if not allow then self.denied="decision" return end
 if now-(memory.acquiredAt or now)<self.reaction then self.denied="reaction" return end
 if self.direction:Dot(delta.Unit)<math.cos(math.rad(7)) then self.denied="acquiring" return end
 if now<self.nextBurst then self.denied="burst_pause" return end
 local accepted,reason=Authority.FireNPC({character=self.bot,tool=self.tool,direction=self.direction,aim=from+self.direction*delta.Magnitude,
  valid=function() return self.alive and self.bot.Parent and h.Health>0 end,
  classify=function(model) return Damage:ShotRelation(self.bot,model) end,
  accept=function() Damage:BreakProtection(self.bot) end,
  onHit=function(hit,model,_,multiplier,distance)
   local target=model:FindFirstChildOfClass("Humanoid")
   local dealt=target and Damage:Deal(self.bot,target,Kits.ShotDamage(self.data,distance,hit.Instance.Name=="Head",multiplier),self.tool:GetAttribute("WeaponId"),hit.Instance.Name=="Head")
   if dealt then self.hits+=1 Combat.Metrics.hits+=1 Combat.Metrics.bands[band(distance)].hits+=1 end return dealt
  end})
 self.denied=accepted and "fired" or reason
 if accepted then
  self.shots+=1 self.burst+=1 Combat.Metrics.shots+=1 Combat.Metrics.bands[band(delta.Magnitude)].shots+=1
  if not self.firstShotDelay then self.firstShotDelay=now-(memory.acquiredAt or now) Combat.Metrics.firstShotTotal+=self.firstShotDelay Combat.Metrics.firstShotCount+=1 end
  if self.burst>=self.rng:NextInteger(2,4) then self.burst=0 self.nextBurst=now+self.rng:NextNumber(.35,.8) end
 end
end
return Combat
