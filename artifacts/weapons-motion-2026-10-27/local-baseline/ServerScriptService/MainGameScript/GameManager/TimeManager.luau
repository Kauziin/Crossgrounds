local Time={}
local folder=workspace:FindFirstChild("MapPurgeProof") or Instance.new("Folder",workspace) folder.Name="MapPurgeProof"
local value=folder:FindFirstChild("Time") or Instance.new("IntValue",folder) value.Name="Time"
local finish,remaining,token=0,0,0 local paused=false
function Time:GetRemaining() return paused and remaining or math.max(0,finish-os.clock()) end
function Time:SetRemaining(seconds)
 remaining=math.clamp(seconds,0,3600) finish=os.clock()+remaining value.Value=math.ceil(remaining)
end
function Time:SetPaused(on)
 if on==paused then return end
 remaining=self:GetRemaining() paused=on finish=os.clock()+remaining
 workspace:SetAttribute("CTFTimerPaused",paused)
end
function Time:StartTimer(duration)
 token+=1 local mine=token paused=false workspace:SetAttribute("CTFTimerPaused",false) self:SetRemaining(duration)
 task.spawn(function()
  while mine==token do
   value.Value=math.ceil(self:GetRemaining())
   if not paused and self:TimerDone() then break end task.wait(.2)
  end
 end)
end
function Time:TimerDone() return not paused and self:GetRemaining()<=0 end
return Time
