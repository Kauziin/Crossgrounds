local View={}
local Catalog=require(game.ReplicatedStorage.Crossgrounds.ThemeCatalog)
local Theme=require(script.Parent.MenuTheme) local Accent=require(script.Parent.AccentTheme)
local Market=game:GetService('MarketplaceService') local player=game.Players.LocalPlayer
function View.new(parent,options)
 local nav=options.Navigation local preferences=options.Preferences
 local root=Instance.new('Frame')root.Name='ThemeSelection'root.BackgroundTransparency=1 root.Size=UDim2.new(1,-8,0,1)root.Parent=parent
 local fit=Instance.new('UIScale')fit.Name='StyleReadability'fit.Parent=root
 local self={Root=root} local connections={}local buttons={}local dead=false local busy=false
 local function connect(signal,fn)local c=signal:Connect(fn)table.insert(connections,c)return c end
 local function text(holder,name,value,height,size)
  local l=Theme.Text(holder,name,value,height,size) l:SetAttribute('SettingsStyled',true)return l
 end
 text(root,'Intro','Estilo define a composição. Paleta define as cores. Escolha os dois independentemente.',42,14)
 local styles=Instance.new('Frame')styles.Name='InterfaceStyles'styles.BackgroundTransparency=1 styles.Position=UDim2.fromOffset(0,46)styles.Size=UDim2.new(1,0,0,72)styles.Parent=root
 local styleButtons={}
 for i,entry in {{0,'Clássica','Interface original'},{1,'Neo','Nova navegação'}}do
  local b=Instance.new('TextButton')b.Name='Style'..entry[1]b.Text=entry[2]b.TextSize=15 b.TextWrapped=true b:SetAttribute('SettingsStyled',true)b:SetAttribute('AccessibleLabel',entry[2]..' · '..entry[3])b.Parent=styles Theme.Button(b)
  b.Position=UDim2.new((i-1)/2,0,0,0)b.Size=UDim2.new(1/2,-8,0,64)
  nav:Connect(b,function()preferences:Edit('InterfaceStyle','Global',entry[1])end)styleButtons[entry[1]]=b
 end
 local sample=Instance.new('Frame')sample.Name='LiveStylePreview'sample.Position=UDim2.fromOffset(0,124)sample.Size=UDim2.new(1,-8,0,102)sample.Parent=root Theme.Surface(sample)
 local sampleTitle=text(sample,'Title','PRÉVIA · ESTILO E PALETA',24,13)sampleTitle.Position=UDim2.fromOffset(12,8)
 local sampleButton=Instance.new('TextButton')sampleButton.Name='SampleButton'sampleButton.Text='Item selecionado'sampleButton.TextSize=14 sampleButton:SetAttribute('SettingsStyled',true)sampleButton:SetAttribute('MenuSelected',true)sampleButton.Active=false sampleButton.Selectable=false sampleButton.Position=UDim2.fromOffset(12,40)sampleButton.Size=UDim2.new(.52,-18,0,44)sampleButton.Parent=sample Theme.Button(sampleButton)
 local sampleBar=Instance.new('Frame')sampleBar.Name='Progress'sampleBar.Position=UDim2.new(.55,0,0,60)sampleBar.Size=UDim2.new(.42,-12,0,7)sampleBar.BorderSizePixel=0 sampleBar.Parent=sample Accent.Role(sampleBar,'BackgroundColor3','Track')
 local fill=Instance.new('Frame')fill.Name='Fill'fill.Size=UDim2.fromScale(.65,1)fill.BorderSizePixel=0 fill.Parent=sampleBar Accent.Role(fill,'BackgroundColor3','Accent')
 local grid=Instance.new('Frame')grid.Name='Presets'grid.BackgroundTransparency=1 grid.Position=UDim2.fromOffset(0,240)grid.Size=UDim2.new(1,0,0,1)grid.Parent=root
 local layout=Instance.new('UIGridLayout')layout.CellPadding=UDim2.fromOffset(8,8)layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=grid
 for i,preset in Catalog.Presets do
  local b=Instance.new('TextButton')b.Name='Preset'..i b.Text=''b.LayoutOrder=i b:SetAttribute('SettingsStyled',true)b:SetAttribute('AccessibleLabel',preset.Name)b.Parent=grid Theme.Button(b)
  local sample=Instance.new('Frame')sample.Name='PalettePreview'sample:SetAttribute('ThemePreserve',true)sample.BackgroundTransparency=1 sample.Size=UDim2.new(1,-20,0,23)sample.Position=UDim2.fromOffset(10,10)sample.Parent=b
  local p=Catalog.Palette(preset.Color)
  for n,c in {p.Accent,p.Selected,p.Card}do local swatch=Instance.new('Frame')swatch.BackgroundColor3=c swatch.BorderSizePixel=0 swatch.Position=UDim2.new((n-1)/3,2,0,0)swatch.Size=UDim2.new(1/3,-4,1,0)Instance.new('UICorner',swatch).CornerRadius=UDim.new(0,5)swatch.Parent=sample end
  local label=text(b,'Name',preset.Name,26,14)label.Position=UDim2.fromOffset(12,38)label.Size=UDim2.new(1,-34,0,26)label.TextTruncate=Enum.TextTruncate.AtEnd label.TextWrapped=false
  local check=text(b,'SelectionMarker','✓',24,16)check.Position=UDim2.new(1,-26,1,-28)check.Size=UDim2.fromOffset(20,24)
  nav:Connect(b,function()preferences:Edit('ThemePreset','Global',i)end)buttons[i]=b
 end
 local custom=Instance.new('Frame')custom.Name='Custom'custom.BackgroundTransparency=1 custom.Size=UDim2.new(1,0,0,1)custom.Parent=root
 local customHeight=110 local customRows={}
 local function clearCustom()for _,x in custom:GetChildren()do x:Destroy()end customRows={}end
 local function button(name,value,y,callback)
  local b=Instance.new('TextButton')b.Name=name b.Text=value b.Position=UDim2.fromOffset(0,y)b.Size=UDim2.new(1,-6,0,46)b.TextSize=14 b:SetAttribute('SettingsStyled',true)b.Parent=custom Theme.Button(b)nav:Connect(b,callback)return b
 end
 local reflow
 local function buildCustom()
  clearCustom()
  text(custom,'Title','COR PERSONALIZADA · HSV',30,17).Font=Enum.Font.GothamBold
  local allowed=player:GetAttribute('ThemeCustomAllowed')==true
  if allowed then
   button('UseCustom','Usar minha cor personalizada',34,function()preferences:Edit('ThemePreset','Global',0)end)
   local body=Instance.new('Frame')body.Name='Controls'body.Position=UDim2.fromOffset(0,88)body.BackgroundTransparency=1 body.Size=UDim2.new(1,0,0,1)body.Parent=custom
   local list=Instance.new('UIListLayout')list.Padding=UDim.new(0,8)list.Parent=body
   for _,key in {'AccentHue','AccentSaturation','AccentValue'}do
    local cfg=table.clone(options.CardConfig)
    cfg.Scale=function()return (options.Scale and options.Scale()or 1)*fit.Scale end
    cfg.Context=function()return 'Global'end
    cfg.Commit=function(field,value)preferences:Edit(field,'Global',value)preferences:Edit('ThemePreset','Global',0)end
    table.insert(customRows,require(script.Parent.SettingsCard).new(body,key,cfg))
   end
   connect(list:GetPropertyChangedSignal('AbsoluteContentSize'),function()if reflow and not dead then reflow()end end)
   customHeight=400
  else
   local status=player:GetAttribute('ThemeCustomAccess')
   local info=text(custom,'Info',status=='Checking' and 'Verificando acesso à personalização…' or 'Crie qualquer cor com matiz, saturação e brilho. Requer o passe de personalização.',52,13)info.Position=UDim2.fromOffset(0,32)
   local id=player:GetAttribute('ThemeCustomPassId')or 0
   local buy=button('Unlock',id>0 and (status=='Retry'and 'Verificar acesso novamente'or 'Desbloquear personalização')or 'Personalização disponível em breve',88,function()
    if busy or id<=0 then return end busy=true
    if status=='Retry' then
     task.spawn(function()pcall(function()game.ReplicatedStorage.Crossgrounds.Remotes.RefreshThemeAccess:InvokeServer()end)busy=false end)
    else local ok=pcall(function()Market:PromptGamePassPurchase(player,id)end)busy=false if not ok and info.Parent then info.Text='Não foi possível abrir a compra. Tente novamente.'end end
   end)
   buy.Active=id>0 and status~='Checking'buy.Selectable=buy.Active buy.AutoButtonColor=false
   if not buy.Active then buy.TextTransparency=.35 end customHeight=146
  end
  if reflow then reflow()end
 end
 reflow=function()
  if dead or root.AbsoluteSize.X<1 then return end
  local scale=options.Scale and options.Scale()or 1
  local mobile=Theme.Style.Id()>0 and Theme.MobileFactor()or 1
  fit.Scale=1/mobile
  local width=root.AbsoluteSize.X/math.max(.1,scale*fit.Scale)
  local fs=player:GetAttribute('SettingFontScale')or 1
  local columns=math.clamp(math.floor((width+8)/(146*math.min(1.2,fs)+8)),1,5)
  local rowHeight=math.max(72,56+18*fs) local cell=math.max(1,math.floor((width-(columns-1)*8)/columns))
  layout.FillDirectionMaxCells=columns layout.CellSize=UDim2.fromOffset(cell,rowHeight)
  local gh=math.ceil(#buttons/columns)*(rowHeight+8)-8 grid.Size=UDim2.new(1,0,0,gh)
  for i,b in buttons do b.NextSelectionLeft=buttons[i-1] b.NextSelectionRight=buttons[i+1] b.NextSelectionUp=buttons[i-columns]b.NextSelectionDown=buttons[i+columns]end
  local body=custom:FindFirstChild('Controls')local flow=body and body:FindFirstChildOfClass('UIListLayout')
  if flow then local h=0 for _,row in customRows do h+=row.Size.Y.Offset+8 end customHeight=88+h body.Size=UDim2.new(1,0,0,h)end
  custom.Position=UDim2.fromOffset(0,gh+260)custom.Size=UDim2.new(1,0,0,customHeight)root.Size=UDim2.new(mobile,-8,0,gh+260+customHeight+12)
 end
 local function refresh()
  local id=preferences:Value('InterfaceStyle','Global')or 0
  for key,b in styleButtons do b:SetAttribute('MenuSelected',key==id)end
  Theme.Style.Surface(sample,id==1 and 'navigation' or 'panel')
  sample:SetAttribute('NeoSettingsPage',id==1)
  Theme.Surface(sample)
  for _,button in styleButtons do
   button:SetAttribute('NeoCascadeButton',id==1)
   Theme.RefreshAccessibility(button)
  end
  sampleTitle.Text='PRÉVIA · '..(({[0]='CLÁSSICA',[1]='NEO'})[id] or 'NEO')
  local selected=preferences:Value('ThemePreset','Global')
  if selected==0 and player:GetAttribute('ThemeCustomAllowed')~=true then selected=1 end
  for i,b in buttons do b:SetAttribute('MenuSelected',selected==i)b:FindFirstChild('SelectionMarker').Visible=selected==i end
 end
 connect(root:GetPropertyChangedSignal('AbsoluteSize'),reflow)
 connect(player:GetAttributeChangedSignal('SettingFontScale'),reflow)
 connect(player:GetAttributeChangedSignal('ThemeCustomAllowed'),buildCustom)
 connect(player:GetAttributeChangedSignal('ThemeCustomAccess'),buildCustom)
 connect(preferences.Changed,function(changes)if not changes or changes.ThemePreset or changes.InterfaceStyle then refresh()reflow()end end)
 buildCustom()refresh()reflow()
 function self:DefaultFocus()return styleButtons[preferences:Value('InterfaceStyle','Global')or 0]or styleButtons[0]end
 function self:Destroy()if dead then return end dead=true for _,c in connections do c:Disconnect()end root:Destroy()end
 return self
end
return View
