local p=game.Players.LocalPlayer
local folder=game.ReplicatedStorage:WaitForChild('AttachmentArtBake')
local entries=game.HttpService:JSONDecode(folder:GetAttribute('Entries'))
local gui=Instance.new('ScreenGui') gui.Name='AttachmentArtBoard' gui.IgnoreGuiInset=true gui.DisplayOrder=10000 gui.ResetOnSpawn=false gui.Parent=p.PlayerGui
local bg=Instance.new('Frame') bg.Size=UDim2.fromOffset(1600,math.ceil(#entries/10)*96) bg.BackgroundColor3=Color3.fromRGB(8,23,29) bg.BorderSizePixel=0 bg.Parent=gui
for i,entry in entries do
 local cell=Instance.new('ViewportFrame') cell.Name=entry.id cell.Size=UDim2.fromOffset(160,96) cell.Position=UDim2.fromOffset((i-1)%10*160,math.floor((i-1)/10)*96) cell.BorderSizePixel=0 cell.BackgroundColor3=Color3.fromRGB(8,23,29)
 cell.Ambient=Color3.fromRGB(205,213,220) cell.LightColor=Color3.new(1,1,1) cell.LightDirection=Vector3.new(-1,-1,-1) cell.Parent=bg
 local source=folder:FindFirstChild(entry.id)
 if source then
  local world=Instance.new('WorldModel') world.Parent=cell local model=source:Clone() model.Parent=world
  local camera=Instance.new('Camera') camera.FieldOfView=24 camera.Parent=cell cell.CurrentCamera=camera
  local cf,size=model:GetBoundingBox() local direction=Vector3.new(5,1.8,2.8).Unit
  local basis=CFrame.lookAt(Vector3.zero,-direction) local tan=math.tan(math.rad(12)) local distance=0
  for _,x in {-1,1} do for _,y in {-1,1} do for _,z in {-1,1} do
   local point=basis:VectorToObjectSpace(cf:PointToWorldSpace(size*Vector3.new(x,y,z)*.5)-cf.Position)
   distance=math.max(distance,math.abs(point.X)/(tan*160/96)+point.Z,math.abs(point.Y)/tan+point.Z)
  end end end
  camera.CFrame=CFrame.lookAt(cf.Position+direction*math.max(.1,distance*1.13),cf.Position)
 else
  local symbol=Instance.new('TextLabel') symbol.BackgroundTransparency=1 symbol.Size=UDim2.fromScale(1,1) symbol.Text=entry.id=='none' and '—' or 'III' symbol.TextColor3=Color3.fromRGB(166,209,218) symbol.Font=Enum.Font.GothamBold symbol.TextSize=48 symbol.Parent=cell
 end
end
return {count=#entries,gui=gui:GetFullName()}
