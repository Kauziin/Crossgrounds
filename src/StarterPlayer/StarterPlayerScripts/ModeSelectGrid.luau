-- Shared Play cards. Entry and training permissions remain in HubController/HubBridge.
local Presentation = require(script.Parent:WaitForChild("ModePresentation"))
local Grid = {}
local Players=game:GetService('Players')
local Input=require(script.Parent.InputMode)
local Keys=require(script.Parent.InputIcons)
local Art=require(game.ReplicatedStorage.Crossgrounds.InterfaceIcons)
local Theme=require(script.Parent.MenuTheme)
Grid.__index = Grid

local Palette=require(script.Parent:WaitForChild("MenuTheme")).Settings
local ACCENT=Palette.Accent local WHITE=Palette.Text local MUTED=Palette.Muted local SURFACE=Palette.Surface

local function make(class, parent, name)
    local v = Instance.new(class)
    v.Name = name
    if v:IsA("GuiObject") then v:SetAttribute("CascadeDecoration",true) v.Active=false v.Selectable=false end
    v.Parent = parent
    return v
end

local function rounded(object, radius)
    local corner = make("UICorner", object, "Corner")
    corner.CornerRadius = UDim.new(0, radius)
    return corner
end

local function label(parent, name, value, size, bold)
    local v = make("TextLabel", parent, name)
    v.BackgroundTransparency = 1
    v.ZIndex=4
    v.Text = value
    v.TextColor3 = WHITE
    v.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
    v.TextSize = size
    v.TextXAlignment = Enum.TextXAlignment.Left
    v.TextYAlignment = Enum.TextYAlignment.Center
    v.TextTruncate = Enum.TextTruncate.AtEnd
    return v
end

function Grid.new(container, nav, callbacks)
    assert(container:IsA("ScrollingFrame"), "Grade: espera um ScrollingFrame")
    assert(not container:FindFirstChildOfClass("UIListLayout"), "Remova UIListLayout antes de criar a grade")

    local self = setmetatable({
        Parent = container,
        Nav = nav,
        Callbacks = callbacks,
        Cards = {},
        Catalog = {},
        Connections = {},
    }, Grid)

    local layout = container:FindFirstChildOfClass('UIGridLayout')or make("UIGridLayout", container, "ModeGridLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.FillDirectionMaxCells = 2
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.CellPadding = UDim2.fromOffset(12, 12)
    self.Layout = layout

    for index, modeId in ipairs(Presentation.Order) do
        local config = Presentation.Cards[modeId]
        local card = make("TextButton", container, modeId)
        card.Text = "" card.Active=true
        card.AutoButtonColor = false
        card.BackgroundColor3 = SURFACE
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.LayoutOrder = index
        card:SetAttribute("AccessibleLabel", modeId)
        rounded(card, 12)

        local background = make("ImageLabel", card, "ModeImage")
        background.ZIndex=2
        background.Image = config.Image
        background.ScaleType = Enum.ScaleType.Crop
        background.BackgroundTransparency = 1
        background.Size = UDim2.fromScale(1, 1)
        background.Active = false
        background.Selectable = false

        local scrim = make("Frame", card, "TextScrim")
        scrim.ZIndex=3
        scrim.Size = UDim2.fromScale(1, 1)
        scrim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        scrim.BorderSizePixel = 0
        scrim.Active = false
        scrim.Selectable = false
        local gradient = make("UIGradient", scrim, "BottomFade")
        gradient.Rotation = 90
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.48),
            NumberSequenceKeypoint.new(0.42, 0.74),
            NumberSequenceKeypoint.new(1, 0.12),
        })

        local name = label(card, "Name", modeId, 20, true)
        name.Position = UDim2.fromOffset(30,8)
        name.Size = UDim2.fromOffset(0, 32)
        name.AutomaticSize = Enum.AutomaticSize.X
        local dot = make("Frame", name, "StatusDot")
        dot.Position = UDim2.new(0, -15, .5, -4)
        dot.Size = UDim2.fromOffset(8, 8)
        dot.BorderSizePixel = 0
        dot.ZIndex = name.ZIndex
        rounded(dot, 8)
        local subtitle = label(card, "Description", config.Subtitle, 14, false)
        subtitle.TextColor3 = MUTED
        subtitle.Position = UDim2.new(0, 16, 1, -108)
        subtitle.Size = UDim2.new(1, -32, 0, 36) subtitle.TextWrapped=true subtitle.TextTruncate=Enum.TextTruncate.None
        local tag=label(card,'ModeType',({ctf='OBJETIVO · EQUIPES',arena='FPS · PISTOLAS',duels='DUELOS',get_out='SOBREVIVÊNCIA'})[modeId],10,true)
        tag.Position=UDim2.fromOffset(16,55)tag.Size=UDim2.new(1,-32,0,20)
        local population=label(card,'PlayerCount','—',12,true)
        population.AnchorPoint=Vector2.new(1,0)
        population.Position=UDim2.new(1,-14,0,11)
        population.Size=UDim2.fromOffset(0,20)
        population.AutomaticSize=Enum.AutomaticSize.X
        local person=Art.Image(population,'user-round',14,WHITE)
        if person then person.ZIndex=4 person.Position=UDim2.fromOffset(-18,3) end
        local globalPopulation=label(card,'GlobalPlayerCount','— em todos os servidores',10,false)
        globalPopulation.Position=UDim2.fromOffset(16,33)
        globalPopulation.Size=UDim2.new(1,-30,0,18)
        globalPopulation.TextXAlignment=Enum.TextXAlignment.Right

        local stroke = make("UIStroke", card, "FocusOutline")
        stroke.Color = ACCENT
        stroke.Thickness = 2
        stroke.Transparency = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local function shortcut(id, text, key, callback)
            local button=make('TextButton',card,id)
            button.ZIndex=5
            button.Text=''
            button:SetAttribute('AccessibleLabel',text)
            button.BackgroundTransparency=.18
            button.BackgroundColor3=SURFACE
            button.Active=true
            button.AnchorPoint=Vector2.new(1,1)
            rounded(button,8)

            local glyph=Keys:Glyph(button,'ShortcutGlyph',key,18)
            glyph.Position=UDim2.new(0,7,.5,-9)
            glyph.ZIndex=6
            for _,child in glyph:GetChildren() do child.ZIndex=6 end
            local caption=label(button,'ShortcutLabel',text,12,false)
            caption.ZIndex=6
            caption.TextXAlignment=Enum.TextXAlignment.Center
            caption.TextWrapped=true
            caption.TextTruncate=Enum.TextTruncate.None
            button.Activated:Connect(callback)
            return button
        end
        local play=shortcut('Play','Jogar','ButtonA',function()local e=self.Catalog[modeId]if e and e.canEnter then callbacks.Play(modeId)end end)
        local details=shortcut('Details','Detalhes','ButtonX',function()callbacks.Details(modeId)end)
        local practice=modeId=='ctf' and callbacks.Practice and shortcut('PracticeRange','Practice Range','ButtonY',function()local e=self.Catalog[modeId]if e and e.canEnter then callbacks.Practice(modeId)end end) or nil
        self.Cards[modeId] = {
            Button = card,
            Background = background,
            Name = name,
            TypeTag = tag,
            ModeType = tag.Text,
            Dot = dot,
            Stroke = stroke,
            Population=population,GlobalPopulation=globalPopulation,Details=details,Play=play,Practice=practice,
        }

        nav:Connect(card, function()
            local entry = self.Catalog[modeId]
            if entry and entry.canEnter == true then
                callbacks.Play(modeId)
            else
                -- Indisponíveis recebem foco, mas nunca ingressam na partida.
                -- Use X para ler os detalhes.
            end
        end)
        nav:SetActions(card, {
            custom = function()
                callbacks.Details(modeId)
            end,
            reset=practice and function()local e=self.Catalog[modeId]if e and e.canEnter then callbacks.Practice(modeId)end end or nil,
        })
        if practice then card:SetAttribute('MenuResetLabel','Practice Range')end
        card:SetAttribute('MenuCustomLabel','Detalhes')
    end

    -- Ligação determinística de D-pad na grade 2×2.
    local a = self.Cards
    local order = Presentation.Order
    for i, id in ipairs(order) do
        local button = a[id].Button
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        button.NextSelectionLeft = a[order[row * 2 + 1]].Button
        button.NextSelectionRight = a[order[row * 2 + 2]].Button
        button.NextSelectionUp = a[order[col + 1]].Button
        button.NextSelectionDown = a[order[2 + col + 1]].Button
    end

    table.insert(self.Connections, nav.FocusChanged:Connect(function(target)
        for _, card in pairs(self.Cards) do
            card.Stroke.Transparency = card.Button == target and 0 or 1
        end
    end))
    table.insert(self.Connections, container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        self:Resize()
    end))
    self:Resize()
    local function refresh()self:RefreshPopulation()self:RefreshShortcuts()end
    table.insert(self.Connections,Input.Changed:Connect(refresh))table.insert(self.Connections,Keys.Changed:Connect(refresh))
    for id in self.Cards do
        table.insert(self.Connections,workspace:GetAttributeChangedSignal('CrossgroundsGlobalPlayers_' .. id):Connect(function() self:RefreshPopulation() end))
    end
    self.PlayerConnections={}
    local function observe(p)local cs={}for _,key in {'CrossgroundsMode','CTFPracticeRange'}do table.insert(cs,p:GetAttributeChangedSignal(key):Connect(function()self:RefreshPopulation()end))end self.PlayerConnections[p]=cs self:RefreshPopulation()end
    for _,p in Players:GetPlayers()do observe(p)end
    table.insert(self.Connections,Players.PlayerAdded:Connect(observe))
    table.insert(self.Connections,Players.PlayerRemoving:Connect(function(p)for _,c in self.PlayerConnections[p]or{}do c:Disconnect()end self.PlayerConnections[p]=nil task.defer(function()if self.Parent.Parent then self:RefreshPopulation()end end)end))
    self:RefreshShortcuts()
    return self
end

function Grid:RefreshPopulation()
 for id,c in self.Cards do
  local entry=self.Catalog[id]local cap=entry and entry.capacity and entry.capacity.maxCombatants
  if entry and entry.route=='local'then
   local n=0 for _,p in Players:GetPlayers()do if p:GetAttribute('CrossgroundsMode')==id and not p:GetAttribute('CTFPracticeRange')then n+=1 end end
   c.Population.Text=tostring(n)..(cap and ' / '..cap or '')..' neste servidor'
  else c.Population.Text=cap and 'Até '..cap..' jogadores'or id=='get_out'and '2–5 jogadores'or 'Capacidade a definir'end
  local global=workspace:GetAttribute('CrossgroundsGlobalPlayers_' .. id)
  c.GlobalPopulation.Text=global ~= nil and tostring(global)..' em todos os servidores' or 'Total global indisponível'
 end
end
function Grid:RefreshShortcuts()
    local touch=Theme.Mobile()
    local gamepad=not touch and Input:Get()==Enum.PreferredInput.Gamepad
    for _,card in self.Cards do
        card.Play.ShortcutLabel.Text=(touch or gamepad) and 'Jogar' or 'Enter · Jogar'
        card.Details.ShortcutLabel.Text=(touch or gamepad) and 'Detalhes' or 'X · Detalhes'
        if card.Practice then
            card.Practice.ShortcutLabel.Text=(touch or gamepad) and 'Practice Range' or 'Y · Practice Range'
        end
        for _,button in {card.Play,card.Details,card.Practice} do
            button.ShortcutGlyph.Visible=gamepad
            local inset=gamepad and 28 or 0
            button.ShortcutLabel.Position=UDim2.fromOffset(inset,0)
            button.ShortcutLabel.Size=UDim2.new(1,-inset,1,0)
        end
    end
end
function Grid:SetVisible(on)for _,c in self.Cards do c.Button.Visible=on end end

function Grid:Update(catalog)
    table.clear(self.Catalog)
    for _, item in ipairs(catalog or {}) do
        self.Catalog[item.id] = item
    end
    for id, card in pairs(self.Cards) do
        local item = self.Catalog[id]
        local enabled = item and item.canEnter == true
        local cfg = Presentation.Cards[id]
        card.Name.Text = item and item.name or ({arena="Arena",ctf="Conflito",duels="Duels",get_out="Get Out"})[id]
        local availability = cfg.UnavailableLabel or (item and item.status == "planned" and "Em breve" or "Indisponível")
        card.TypeTag.Text = enabled and card.ModeType or card.ModeType .. " · " .. availability
        card.Dot.BackgroundColor3 = enabled and Color3.fromRGB(130, 235, 175) or Color3.fromRGB(164, 57, 64)
        card.Button:SetAttribute('AccessibleLabel',card.Name.Text .. ' · ' .. (enabled and 'Disponível' or availability))
        card.Background.ImageTransparency = enabled and 0 or 0.4
        card.Button:SetAttribute("Playable", enabled == true)
        for _,button in {card.Play,card.Practice} do
            local transparency=enabled and 0 or .55
            button.ShortcutLabel.TextTransparency=transparency
            button.ShortcutGlyph.Icon.ImageTransparency=transparency
            button.ShortcutGlyph.Fallback.TextTransparency=transparency
        end
    end
    self:RefreshPopulation()
end

function Grid:Resize()
    self:RefreshShortcuts()
    local scale=1 local at=self.Parent while at do local modifier=at:FindFirstChildOfClass("UIScale") if modifier then scale*=modifier.Scale end at=at.Parent end
    local width = self.Parent.AbsoluteSize.X/math.max(.1,scale)
    if width < 1 then return end
    local gap = 12
    local minimumCardWidth = 3 * 96 + 2 * 4 + 2 * 12
    local columns = width >= 2 * minimumCardWidth + gap and 2 or 1
    local cardWidth = (width - gap * (columns - 1)) / columns
    local shortcutWidth = cardWidth >= minimumCardWidth and 96 or 80
    local shortcutHeight = shortcutWidth * 9 / 16
    local shortcutsPerRow = math.max(1,math.floor((cardWidth-20)/(shortcutWidth+4)))
    local viewportHeight=self.Parent.AbsoluteSize.Y/math.max(.1,scale)
    local cardHeight = Theme.Mobile()and math.clamp(viewportHeight,180,220)or math.clamp((viewportHeight-12)/2,220,290)
    cardHeight = math.max(cardHeight, 128 + math.ceil(3 / shortcutsPerRow) * (shortcutHeight + 4))
    self.Layout.FillDirectionMaxCells = columns
    self.Layout.CellSize = UDim2.new(1 / columns, -gap * (columns - 1) / columns, 0, cardHeight)
    local rows = math.ceil(#Presentation.Order / columns)
    for i,id in Presentation.Order do
        local card=self.Cards[id]
        local shortcuts={card.Play,card.Details,card.Practice}
        for index, button in shortcuts do
            local column=(index-1)%shortcutsPerRow
            local row=math.floor((index-1)/shortcutsPerRow)
            button.Size=UDim2.fromOffset(shortcutWidth,shortcutHeight)
            button.Position=UDim2.new(1,-12-column*(shortcutWidth+4),1,-12-row*(shortcutHeight+4))
        end
        local description=card.Button.Description
        local occupied=#shortcuts*(shortcutWidth+4)+24
        local alongside=cardWidth-occupied>=160
        local actionRows=math.ceil(#shortcuts/shortcutsPerRow)
        description.AnchorPoint=Vector2.new(0,1)
        description.Position=UDim2.new(0,16,1,alongside and -12 or -16-actionRows*(shortcutHeight+4))
        description.Size=UDim2.new(1,alongside and -occupied-16 or -32,0,36)
        description.TextSize=cardWidth<400 and 12 or 14
        local b=self.Cards[id].Button
        if columns==1 then b.NextSelectionUp=self.Cards[Presentation.Order[math.max(1,i-1)]].Button b.NextSelectionDown=self.Cards[Presentation.Order[math.min(4,i+1)]].Button b.NextSelectionLeft=b b.NextSelectionRight=b
        else local row=math.floor((i-1)/2) local col=(i-1)%2 b.NextSelectionLeft=self.Cards[Presentation.Order[row*2+1]].Button b.NextSelectionRight=self.Cards[Presentation.Order[row*2+2]].Button b.NextSelectionUp=self.Cards[Presentation.Order[col+1]].Button b.NextSelectionDown=self.Cards[Presentation.Order[col+3]].Button end
    end
    self.Parent.CanvasSize = UDim2.fromOffset(0, rows * cardHeight + math.max(0, rows - 1) * gap)
    -- Em modo 1 coluna, revisar também os links de D-pad na integração definitiva.
end

function Grid:DefaultFocus()
    return self.Cards.arena.Button
end

function Grid:Destroy()
    for _,cs in self.PlayerConnections or {}do for _,c in cs do c:Disconnect()end end
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    for _, card in pairs(self.Cards) do
        card.Button:Destroy()
    end
    self.Layout:Destroy()
end

return Grid
