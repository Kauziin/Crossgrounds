local Pathfinding=game:GetService("PathfindingService")
local Run=game:GetService("RunService")
local Config=require(script.Parent.BotProfiles).Budget
local Navigation={} Navigation.__index=Navigation
local queue={} local busy=0 local tokens=Config.PathsPerSecond local stamp=os.clock()
Navigation.Metrics={computations=0,failures=0,stuck=0,recoveries=0,abandoned=0,maxConcurrent=0}
function Navigation.Pump(now)
 tokens=math.min(Config.PathsPerSecond,tokens+(now-stamp)*Config.PathsPerSecond) stamp=now
 while busy<Config.ConcurrentPaths and tokens>=1 and #queue>0 do
  local job=table.remove(queue,1) local self=job.nav
  if self.alive and job.generation==self.generation then
   busy+=1 tokens-=1 Navigation.Metrics.computations+=1 Navigation.Metrics.maxConcurrent=math.max(busy,Navigation.Metrics.maxConcurrent)
   task.spawn(function()
    local path=Pathfinding:CreatePath({AgentRadius=2.1,AgentHeight=5.5,AgentCanJump=true,AgentCanClimb=true,WaypointSpacing=4,Costs={Water=25}})
    local ok=pcall(function() path:ComputeAsync(self.root.Position,job.goal) end)
    busy-=1
    if not self.alive or job.generation~=self.generation then path:Destroy() return end
    self.pending=false
    if ok and path.Status==Enum.PathStatus.Success then
     self:_clearRoute() self.route=path self.waypoints=path:GetWaypoints() self.index=2 self.failures=0 self.plannedAt=os.clock()
     self.blocked=path.Blocked:Connect(function(index) if self.alive and job.generation==self.generation and index>=self.index then self.replan=true self.reason="blocked" end end)
     if Run:IsStudio() and workspace:GetAttribute("BotDiagnosticsEnabled") then
      local debugFolder=Instance.new("Folder") debugFolder.Name="BotRoute" debugFolder.Parent=self.bot self.debugFolder=debugFolder
      for i=2,math.min(#self.waypoints,24) do
       local a,b=self.waypoints[i-1].Position,self.waypoints[i].Position local delta=b-a
       if delta.Magnitude>.1 then local p=Instance.new("Part") p.Name="Waypoint" p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Size=Vector3.new(.07,.07,delta.Magnitude) p.CFrame=CFrame.lookAt((a+b)*.5,b) p.Color=Color3.fromRGB(255,220,90) p.Material=Enum.Material.Neon p.Parent=debugFolder end
      end
     end
    else
     path:Destroy() self.failures+=1 Navigation.Metrics.failures+=1 self.nextPlan=os.clock()+math.min(5,self.failures*1.2)
     self.reason="no_path" self:_clearRoute()
     if self.failures>=3 then self:Abandon(os.clock()) end
    end
   end)
  end
 end
end
function Navigation.new(bot)
 local self=setmetatable({bot=bot,root=bot.HumanoidRootPart,humanoid=bot.Humanoid,alive=true,generation=0,index=2,failures=0,nextPlan=0,plannedAt=0,lastMove=0,lastProgress=os.clock(),travel=0,recovery=0},Navigation)
 self.position=self.root.Position self.progressPosition=self.root.Position self.updatedAt=os.clock() self.idleSeconds=0 self.stuckCount=0 return self
end
function Navigation:_clearRoute()
 if self.blocked then self.blocked:Disconnect() self.blocked=nil end
 if self.route then self.route:Destroy() self.route=nil end
 if self.debugFolder then self.debugFolder:Destroy() self.debugFolder=nil end self.waypoints=nil self.command=nil
end
function Navigation:Clear(from,to)
 local delta=to-from
 if delta.Magnitude>18 or math.abs(delta.Y)>4 then return false end
 local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={self.bot} params.RespectCanCollide=true
 local hit=delta.Magnitude>.1 and workspace:Blockcast(CFrame.new(from+Vector3.new(0,.4,0)),Vector3.new(3.2,3.5,3.2),delta,params)
 local ground=workspace:Raycast(to+Vector3.new(0,2,0),Vector3.new(0,-10,0),params)
 return not hit and ground~=nil
end
function Navigation:SetGoal(goal,now)
 if self.failedGoal and now<(self.failedUntil or 0) and (goal-self.failedGoal).Magnitude<12 then return false end
 if not self.goal or (self.goal-goal).Magnitude>10 then
  self.goal=goal self.generation+=1 self.pending=false self.replan=true self.nextPlan=math.max(now,self.nextPlan) self.reason="goal_changed"
  self:_clearRoute() self.lastProgress=now self.position=self.root.Position self.recovery=0
 end
 return true
end
function Navigation:Abandon(now)
 self.failedGoal=self.goal self.failedUntil=now+7 self.goal=nil self.generation+=1 self.pending=false self:_clearRoute()
 self.humanoid:MoveTo(self.root.Position) self.reason="abandoned" self.recovery=0 Navigation.Metrics.abandoned+=1
end
function Navigation:Pause()
 self.goal=nil self.generation+=1 self.pending=false self:_clearRoute() self.humanoid:MoveTo(self.root.Position)
end
function Navigation.ReachedWaypoint(position,waypoint)
 local delta=position-waypoint
 -- Path waypoints are on the navmesh floor; HumanoidRootPart is above it.
 return Vector3.new(delta.X,0,delta.Z).Magnitude<2.8 and math.abs(delta.Y)<6
end
function Navigation:Update(now)
 if not self.goal or not self.alive then return end
 local root,h=self.root,self.humanoid local distance=(root.Position-self.goal).Magnitude
 local progress=(root.Position-self.position).Magnitude self.travel+=progress self.position=root.Position
 local step=math.min(.5,now-self.updatedAt) self.updatedAt=now
 if progress<.1 then self.idleSeconds+=math.max(0,step) end
 if distance<3.5 then self.lastProgress=now self.recovery=0 h:Move(Vector3.zero) self.command=nil return end
 if (root.Position-self.progressPosition).Magnitude>1.2 then self.lastProgress=now self.recovery=0 self.progressPosition=root.Position end
 if now-self.lastProgress>2.5 then
  self.recovery+=1 self.stuckCount+=1 self.lastProgress=now Navigation.Metrics.stuck+=1 self.reason="recover_"..self.recovery
  if self.recovery==1 then
   local delta=self.goal-root.Position local side=Vector3.new(-delta.Z,0,delta.X)
   if side.Magnitude>.1 then local point=root.Position+side.Unit*3 if self:Clear(root.Position,point) then h:MoveTo(point) self.localUntil=now+.5 Navigation.Metrics.recoveries+=1 end end
  elseif self.recovery==2 then self.localUntil=now+.45 h:Move(Vector3.zero)
  elseif self.recovery<5 then self.replan=true self.nextPlan=now self:_clearRoute()
  else self:Abandon(now) return end
 end
 if now<(self.localUntil or 0) then return end
 if now>=(self.nextProbe or 0) then self.direct=self:Clear(root.Position,self.goal) self.nextProbe=now+.4 end
 if not self.direct and not self.pending and now>=self.nextPlan and (not self.waypoints or self.replan or now-self.plannedAt>6) then
  self.pending=true self.replan=false self.nextPlan=now+1.5 table.insert(queue,{nav=self,generation=self.generation,goal=self.goal})
 end
 local waypoint=self.waypoints and self.waypoints[self.index]
 if waypoint and Navigation.ReachedWaypoint(root.Position,waypoint.Position) then
  if waypoint.Action==Enum.PathWaypointAction.Jump then h.Jump=true end
  self.index+=1 waypoint=self.waypoints[self.index]
 end
 local destination=self.direct and self.goal or waypoint and waypoint.Position
 if not destination then h:Move(Vector3.zero) self.command=nil return end
 if waypoint and not self.direct and waypoint.Action==Enum.PathWaypointAction.Jump then h.Jump=true end
 if not self.command or (destination-self.command).Magnitude>1 or now-self.lastMove>2 then h:MoveTo(destination) self.command=destination self.lastMove=now end
end
function Navigation:Destroy()
 if not self.alive then return end self.alive=false self.generation+=1 self:_clearRoute()
 for i=#queue,1,-1 do if queue[i].nav==self then table.remove(queue,i) end end
end
function Navigation.Stats() local copy=table.clone(Navigation.Metrics) copy.queued=#queue copy.concurrent=busy return copy end
return Navigation
