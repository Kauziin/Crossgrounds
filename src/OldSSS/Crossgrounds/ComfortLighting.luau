local Service={}
function Service:Start()
 if self.started then return end self.started=true
 local lighting=game:GetService("Lighting")
 lighting.ExposureCompensation=math.min(lighting.ExposureCompensation,.05)
 lighting.Brightness=math.min(lighting.Brightness,2)
 local function tune(v)
  if v:IsA("SunRaysEffect") then v.Intensity=math.min(v.Intensity,.035)
  elseif v:IsA("BloomEffect") then v.Intensity=math.min(v.Intensity,.12) v.Threshold=math.max(v.Threshold,1.5)
  elseif v:IsA("ColorCorrectionEffect") then v.Brightness=math.min(v.Brightness,.02)
  elseif v:IsA("Light") and v:IsDescendantOf(workspace) then
   if v:GetAttribute("CrossgroundsOriginalBrightness")==nil then v:SetAttribute("CrossgroundsOriginalBrightness",v.Brightness) end
   v.Brightness=math.min(v.Brightness,2.5) v.Range=math.min(v.Range,40)
  end
 end
 for _,v in lighting:GetChildren() do tune(v) end
 for i,v in workspace:GetDescendants() do tune(v) if i%1000==0 then task.wait() end end
 lighting.ChildAdded:Connect(tune) workspace.DescendantAdded:Connect(tune)
end
return Service
