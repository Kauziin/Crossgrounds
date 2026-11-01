-- Only the peripheral occlusion and reticle are UI. The ocular is the weapon mesh.
local Sight={} Sight.__index=Sight
function Sight.new(player)
 local self=setmetatable({rows={}},Sight)
 local gui=Instance.new("ScreenGui") gui.Name="OpticalSightHUD" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=-20 gui.Enabled=false gui.Parent=player:WaitForChild("PlayerGui") self.gui=gui
 local reticle=gui:Clone() reticle.Name="OpticalReticle" reticle.DisplayOrder=-9 reticle.Parent=gui.Parent self.reticle=reticle
 local function rectangle(parent,name)
  local f=Instance.new("Frame") f.Name=name f.BorderSizePixel=0 f.BackgroundColor3=Color3.new() f.Parent=parent return f
 end
 -- Horizontal slices meet exactly; there are no rotated wedges or radial gaps.
 for i=1,256 do self.rows[i]={rectangle(gui,"PeripheralLeft"),rectangle(gui,"PeripheralRight")} end
 for _,axis in {0,90} do
  local line=rectangle(reticle,"Reticle") line.AnchorPoint=Vector2.new(.5,.5) line.Rotation=axis
  self[axis==0 and "horizontal" or "vertical"]=line
 end
 self.dots={}
 for i=-4,4 do if i~=0 then for _,axis in {0,1} do
  local dot=rectangle(reticle,"MilDot") dot.AnchorPoint=Vector2.new(.5,.5) dot.Size=UDim2.fromOffset(3,3)
  Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
  table.insert(self.dots,{part=dot,x=axis==0 and i or 0,y=axis==1 and i or 0})
 end end end
 return self
end
function Sight:Update(profile,viewport,point)
 self.gui.Enabled=profile~=nil self.reticle.Enabled=profile~=nil
 if not profile then return end
 local radius=math.min(viewport.X,viewport.Y)*.36
 local key=tostring(viewport)..tostring(point)
 if key==self.layoutKey then return end self.layoutKey=key
 for i,row in self.rows do
  local top=math.floor((i-1)*viewport.Y/256) local bottom=math.ceil(i*viewport.Y/256)
  local dy=math.max(math.abs(top-point.Y),math.abs(bottom-point.Y))
  local half=dy<radius and math.sqrt(radius*radius-dy*dy) or 0
  row[1].Position=UDim2.fromOffset(0,top) row[1].Size=UDim2.fromOffset(math.ceil(point.X-half),bottom-top)
  row[2].Position=UDim2.fromOffset(math.floor(point.X+half),top) row[2].Size=UDim2.fromOffset(math.ceil(viewport.X-point.X-half),bottom-top)
 end
 for _,line in {self.horizontal,self.vertical} do line.Position=UDim2.fromOffset(point.X,point.Y) line.Size=UDim2.fromOffset(radius*1.4,1) end
 for _,dot in self.dots do dot.part.Position=UDim2.fromOffset(point.X+dot.x*radius*.11,point.Y+dot.y*radius*.11) end
end
return Sight
