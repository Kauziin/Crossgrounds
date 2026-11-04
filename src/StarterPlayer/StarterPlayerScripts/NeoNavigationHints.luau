-- Contextual text help. Touch has actionable controls instead of navigation hints.
local Hints={}
local Mode=require(script.Parent.InputMode)
local Icons=require(script.Parent.InputIcons)
local Router=require(script.Parent.ControlRouter)
local Art=require(game.ReplicatedStorage.Crossgrounds.InterfaceIcons)
local Accent=require(script.Parent.AccentTheme)
local TextService=game:GetService('TextService')
function Hints.new(parent)
 local root=Instance.new('Frame')root.Name='NeoNavigationHints'root.BackgroundTransparency=1 root.Position=UDim2.new(0,0,1,-32)root.Size=UDim2.new(1,0,0,30)root.Parent=parent
 local layout=Instance.new('UIListLayout')layout.FillDirection=Enum.FillDirection.Horizontal layout.Padding=UDim.new(0,22)layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=root
 local self={Root=root}local signature local connections={}local measured=1
 local function fit()local scale=root:FindFirstChildOfClass('UIScale')or Instance.new('UIScale')scale.Scale=math.min(1,math.max(1,parent.AbsoluteSize.X)/measured)scale.Parent=root end
 function self:Refresh(input,context)
  input=input or Mode:Get()context=context or {}
  root.Visible=input~=Enum.PreferredInput.Touch and not context.Capturing and context.Active~=false
  if not root.Visible then return end
  local gamepad=input==Enum.PreferredInput.Gamepad
  local device=gamepad and 'Gamepad'or 'Keyboard'
  local groups={}
  if context.Navigate then table.insert(groups,{'move',gamepad and {'DPadUp','DPadDown'}or {'Up','Down'},'Navegar'})end
  if context.Confirm then table.insert(groups,{'check',gamepad and {'ButtonA'}or {'Return'},'Confirmar'})end
  if context.Back then table.insert(groups,{'Back',gamepad and {'ButtonB'}or {'Escape'},'Voltar'})end
  if context.Categories then table.insert(groups,{'Frames',{Router:Key('MenuPrevious',device),Router:Key('MenuNext',device)},'Categorias'})end
  if context.Adjust then table.insert(groups,{'Settings',gamepad and {'DPadLeft','DPadRight'}or {'Left','Right'},'Ajustar'})end
  if context.Custom then table.insert(groups,{'Preferences',gamepad and {'ButtonX'}or {'X'},context.CustomLabel or 'Ação contextual'})end
  if context.Reset then table.insert(groups,{'rotate-ccw',gamepad and {'ButtonY'}or {'Y'},context.ResetLabel or 'Restaurar / retornar ao atual'})end
  if context.Options and gamepad then table.insert(groups,{'Settings',{'ButtonL3'},'Opções'})end
  if context.Group and gamepad then table.insert(groups,{'Frames',{'ButtonL2','ButtonR2'},'Grupos'})end
  local key=input.Name..Icons:Platform()
  for _,g in groups do key..=g[1]..g[3]..table.concat(g[2],',')end
  if signature==key then fit()return end signature=key
  for _,v in root:GetChildren()do if v:IsA('GuiObject')then v:Destroy()end end
  local x=0
  for order,g in groups do
   local captionWidth=math.ceil(TextService:GetTextSize(g[3],13,Enum.Font.GothamMedium,Vector2.new(1000,30)).X)
   local keyWidth=#g[2]*34
   local group=Instance.new('Frame')group.Name=g[3]group:SetAttribute('AccessibleLabel',g[3])group.BackgroundTransparency=1 group.Size=UDim2.fromOffset(keyWidth+8+captionWidth,28)group.LayoutOrder=order group.Parent=root
   local caption=Instance.new('TextLabel')caption.Name='ActionText'caption.BackgroundTransparency=1 caption.Position=UDim2.fromOffset(keyWidth+8,0)caption.Size=UDim2.fromOffset(captionWidth,28)caption.Text=g[3]caption.TextSize=13 caption.Font=Enum.Font.GothamMedium caption.TextXAlignment=Enum.TextXAlignment.Left caption.Parent=group Accent.Role(caption,'TextColor3','Text')
   for i,k in g[2]do
    local glyph
    if gamepad then glyph=Icons:Glyph(group,'Key'..i,k,28)
    else
     glyph=Instance.new('Frame')glyph.Name='Key'..i glyph.Size=UDim2.fromOffset(30,26)glyph.BackgroundTransparency=.45 glyph.BorderSizePixel=0 glyph.Parent=group Accent.Role(glyph,'BackgroundColor3','Card')
     Instance.new('UICorner',glyph).CornerRadius=UDim.new(0,5)
     local t=Instance.new('TextLabel')t.Name='Keycap't.BackgroundTransparency=1 t.Size=UDim2.fromScale(1,1)t.Font=Enum.Font.GothamBold t.TextSize=11 t.Text=({Return='ENTER',Escape='ESC',Up='↑',Down='↓',Left='←',Right='→',LeftBracket='[',RightBracket=']'})[k]or Icons:Name(k)t.Parent=glyph Accent.Role(t,'TextColor3','Text')
     if k=='Return'then local enter=Art.Image(glyph,'corner-down-left',16,Accent.Color())if enter then t.Text=''enter.Position=UDim2.fromOffset(7,5)else t.TextSize=8 end end
    end
    glyph.Position=UDim2.fromOffset((i-1)*34,0)
   end
   x+=group.Size.X.Offset+22
  end
  measured=math.max(1,x)fit()
 end
 table.insert(connections,Icons.Changed:Connect(function()signature=nil end))
 root.Destroying:Once(function()for _,c in connections do c:Disconnect()end end)
 return self
end
return Hints
