-- Local vector artwork: no asset downloads, captions, or letter substitutes.
local Icons={}
function Icons.Create(parent,action)
 local root=Instance.new("Frame") root.Name="Symbol" root.AnchorPoint=Vector2.new(.5,.5) root.Position=UDim2.fromScale(.5,.5) root.Size=UDim2.fromScale(.54,.54) root.BackgroundTransparency=1 root:SetAttribute("CascadeDecoration",true) root.Parent=parent
 local canvas=Instance.new("Frame") canvas.Size=UDim2.fromOffset(24,24) canvas.BackgroundTransparency=1 canvas:SetAttribute("CascadeDecoration",true) canvas.Parent=root
 local scale=Instance.new("UIScale") scale.Parent=canvas
 root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() scale.Scale=root.AbsoluteSize.X/24 end)
 local ink={}
 local function rect(x,y,w,h,r,outline)
  local f=Instance.new("Frame") f.AnchorPoint=Vector2.new(.5,.5) f.Position=UDim2.fromOffset(x,y) f.Size=UDim2.fromOffset(w,h) f.BorderSizePixel=0 f.BackgroundColor3=Color3.fromRGB(239,246,255) f:SetAttribute("CascadeDecoration",true) f.Parent=canvas
  if r then local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=f end
  if outline then f.BackgroundTransparency=1 local s=Instance.new("UIStroke") s.Thickness=1.6 s.Color=f.BackgroundColor3 s.Parent=f table.insert(ink,s) else table.insert(ink,f) end return f
 end
 local function line(x,y,a,b) local d=Vector2.new(a-x,b-y) local f=rect((x+a)/2,(y+b)/2,d.Magnitude,1.7,1) f.Rotation=math.deg(math.atan2(d.Y,d.X)) end
 local function arrow(x,y,dir) line(x-dir*4,y-4,x,y) line(x-dir*4,y+4,x,y) end
 if action=="Fire" or action=="Aim" then
  rect(12,12,action=="Aim" and 17 or 12,action=="Aim" and 17 or 12,12,true) rect(12,12,3,3,2)
  if action=="Fire" then line(12,1,12,6) line(12,18,12,23) line(1,12,6,12) line(18,12,23,12) end
 elseif action=="Jump" then line(12,21,12,3) line(5,10,12,3) line(19,10,12,3) line(5,22,19,22)
 elseif action=="Sprint" then arrow(11,12,1) arrow(20,12,1)
 elseif action=="SwitchWeapon" then line(3,7,21,7) arrow(21,7,1) line(21,17,3,17) arrow(3,17,-1)
 elseif action=="ReloadInteract" then
  for i=0,9 do local a=math.rad(25+i*27) local b=a+math.rad(27) line(12+8*math.cos(a),12+8*math.sin(a),12+8*math.cos(b),12+8*math.sin(b)) end line(20,5,20,11) line(20,5,14,5)
 elseif action=="Perspective" then rect(12,14,20,13,3,true) rect(12,14,7,7,7,true) line(7,7,9,3) line(9,3,15,3) line(15,3,17,7)
 elseif action=="ShiftLock" then rect(12,16,16,12,2,true) rect(12,8,10,11,5,true) rect(12,16,2,4,1)
 elseif action=="Shoulder" then rect(12,7,7,7,7,true) line(7,21,7,16) line(7,16,17,16) line(17,16,17,21) arrow(23,12,1) arrow(1,12,-1)
 elseif action=="AdminClean" then for _,p in {{3,3,1,1},{21,3,-1,1},{3,21,1,-1},{21,21,-1,-1}} do line(p[1],p[2],p[1]+p[3]*6,p[2]) line(p[1],p[2],p[1],p[2]+p[4]*6) end
 elseif action=="AdminMode" then rect(12,12,20,12,8,true) rect(12,12,6,6,6,true)
 elseif action=="AdminPreviousMap" or action=="AdminNextMap" then
  line(3,5,8,3) line(8,3,16,6) line(16,6,21,3) line(3,5,3,20) line(21,3,21,20) line(8,3,8,10) line(16,6,16,10)
  local dir=action=="AdminNextMap" and 1 or -1 line(5,16,19,16) arrow(dir==1 and 19 or 5,16,dir)
 else -- speed controls
  for i=0,5 do local a=math.rad(180+i*30) local b=a+math.rad(30) line(12+9*math.cos(a),15+9*math.sin(a),12+9*math.cos(b),15+9*math.sin(b)) end
  line(12,15,17,8) line(8,21,16,21) if action=="AdminSpeedUp" then line(12,17,12,24) end
 end
 return {SetOpacity=function(_,opacity) for _,v in ink do if v:IsA("UIStroke") then v.Transparency=1-opacity else v.BackgroundTransparency=1-opacity end end end}
end
return Icons
