-- AX-50 uses a physical ocular; other weapons retain the existing UI mask.
local Sight={} Sight.__index=Sight
local ADS=require(game.ReplicatedStorage.Crossgrounds.ADSTransition)
function Sight.new(player)
 local self=setmetatable({rows={}},Sight)
 local gui=Instance.new("ScreenGui") gui.Name="OpticalSightHUD" gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=-20 gui.Enabled=false gui.Parent=player:WaitForChild("PlayerGui") self.gui=gui
 local reticle=gui:Clone() reticle.Name="OpticalReticle" reticle.DisplayOrder=-9 reticle.Parent=gui.Parent self.reticle=reticle
 local ring=Instance.new('Frame') ring.Name='OcularRing' ring.BackgroundTransparency=1 ring.AnchorPoint=Vector2.new(.5,.5) ring.Parent=reticle self.ring=ring
 Instance.new('UICorner',ring).CornerRadius=UDim.new(1,0)
 local edge=Instance.new('UIStroke',ring) edge.Color=Color3.fromRGB(48,54,58) edge.Thickness=5 self.edge=edge
 local function rectangle(parent,name)
  local f=Instance.new("Frame") f.Name=name f.BorderSizePixel=0 f.BackgroundColor3=Color3.new() f.Parent=parent return f
 end
 -- Horizontal slices meet exactly; there are no rotated wedges or radial gaps.
 for i=1,256 do self.rows[i]={rectangle(gui,"PeripheralLeft"),rectangle(gui,"PeripheralRight")} end
 for _,axis in {0,90} do
  local line=rectangle(reticle,"Reticle") line.AnchorPoint=Vector2.new(.5,.5) line.Rotation=axis
  self[axis==0 and "horizontal" or "vertical"]=line
  line.BackgroundColor3=Color3.fromRGB(205,215,208)
  local outline=Instance.new('UIStroke',line) outline.Thickness=1 outline.Transparency=.45 outline.Color=Color3.new()
 end
 self.dots={}
 for i=-4,4 do if i~=0 then for _,axis in {0,1} do
  local dot=rectangle(reticle,"MilDot") dot.AnchorPoint=Vector2.new(.5,.5) dot.Size=UDim2.fromOffset(3,3)
  Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
  table.insert(self.dots,{part=dot,x=axis==0 and i or 0,y=axis==1 and i or 0})
 end end end
 return self
end
function Sight:Update(profile,viewport,point,progress,aperture,active)
 self.gui.Enabled=profile~=nil self.reticle.Enabled=profile~=nil
 if not profile then return end
 local transition=ADS.Sample(progress==nil and 1 or progress,profile)
 transition.reticle=active==false and 0 or 1 transition.peripheral=transition.reticle
 self.ring.Visible=not aperture
 self.gui.Enabled=profile~=nil and not aperture
 self.edge.Transparency=1-transition.reticle
 if not aperture then for _,row in self.rows do for _,part in row do part.BackgroundTransparency=1-transition.peripheral end end end
 local opacity=active==false and 0 or (aperture and aperture.visible or transition.reticle)
 for _,part in {self.horizontal,self.vertical} do part.BackgroundTransparency=1-opacity part.BackgroundColor3=aperture and Color3.fromRGB(20,24,23) or Color3.fromRGB(205,215,208) end
 for _,dot in self.dots do dot.part.BackgroundTransparency=1-opacity end
 local radius=aperture and aperture.radius or math.min(viewport.X,viewport.Y)*.36
 if aperture then point=aperture.point end
 self.ring.Position=UDim2.fromOffset(point.X,point.Y) self.ring.Size=UDim2.fromOffset(radius*2,radius*2)
 local key=tostring(viewport)..tostring(point)..tostring(radius)
 if key==self.layoutKey then return end self.layoutKey=key
 if not aperture then for i,row in self.rows do
  local top=math.floor((i-1)*viewport.Y/256) local bottom=math.ceil(i*viewport.Y/256)
  local dy=math.max(math.abs(top-point.Y),math.abs(bottom-point.Y))
  local half=dy<radius and math.sqrt(radius*radius-dy*dy) or 0
  row[1].Position=UDim2.fromOffset(0,top) row[1].Size=UDim2.fromOffset(math.ceil(point.X-half),bottom-top)
  row[2].Position=UDim2.fromOffset(math.floor(point.X+half),top) row[2].Size=UDim2.fromOffset(math.ceil(viewport.X-point.X-half),bottom-top)
 end end
 for _,line in {self.horizontal,self.vertical} do line.Position=UDim2.fromOffset(point.X,point.Y) line.Size=UDim2.fromOffset(radius*1.4,1) end
 for _,dot in self.dots do dot.part.Position=UDim2.fromOffset(point.X+dot.x*radius*.11,point.Y+dot.y*radius*.11) end
end
return Sight
