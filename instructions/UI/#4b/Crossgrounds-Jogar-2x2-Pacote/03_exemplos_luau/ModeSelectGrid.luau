-- EXEMPLO DE COMPONENTE DE APRESENTAÇÃO (não é um patch pronto do HubController).
-- O pai deve ser o ScrollingFrame largo da tela Jogar, sem UIListLayout antigo.
-- Integração e permissões de entrada permanecem no HubController/HubBridge.
local Presentation = require(script.Parent:WaitForChild("ModePresentation"))
local Grid = {}
Grid.__index = Grid

local ACCENT = Color3.fromRGB(22, 220, 235) -- substituir por token do tema
local WHITE = Color3.fromRGB(240, 247, 250)
local MUTED = Color3.fromRGB(177, 193, 200)
local SURFACE = Color3.fromRGB(8, 18, 25)

local function make(class, parent, name)
    local v = Instance.new(class)
    v.Name = name
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

    local layout = make("UIGridLayout", container, "ModeGridLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.FillDirectionMaxCells = 2
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.CellPadding = UDim2.fromOffset(12, 12)
    self.Layout = layout

    for index, modeId in ipairs(Presentation.Order) do
        local config = Presentation.Cards[modeId]
        local card = make("TextButton", container, modeId)
        card.Text = ""
        card.AutoButtonColor = false
        card.BackgroundColor3 = SURFACE
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.LayoutOrder = index
        card:SetAttribute("AccessibleLabel", modeId)
        rounded(card, 12)

        local background = make("ImageLabel", card, "ModeImage")
        background.Image = config.Image
        background.ScaleType = Enum.ScaleType.Crop
        background.BackgroundTransparency = 1
        background.Size = UDim2.fromScale(1, 1)
        background.Active = false
        background.Selectable = false

        local scrim = make("Frame", card, "TextScrim")
        scrim.Size = UDim2.fromScale(1, 1)
        scrim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        scrim.BorderSizePixel = 0
        scrim.Active = false
        scrim.Selectable = false
        local gradient = make("UIGradient", scrim, "BottomFade")
        gradient.Rotation = 90
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.95),
            NumberSequenceKeypoint.new(0.42, 0.74),
            NumberSequenceKeypoint.new(1, 0.12),
        })

        local name = label(card, "Name", modeId, 23, true)
        name.Position = UDim2.new(0, 20, 1, -104)
        name.Size = UDim2.new(1, -40, 0, 34)
        local subtitle = label(card, "Description", config.Subtitle, 14, false)
        subtitle.TextColor3 = MUTED
        subtitle.Position = UDim2.new(0, 20, 1, -69)
        subtitle.Size = UDim2.new(1, -40, 0, 23)
        local badge = label(card, "Availability", "Carregando...", 12, true)
        badge.Position = UDim2.new(0, 20, 1, -40)
        badge.Size = UDim2.new(1, -40, 0, 25)

        local stroke = make("UIStroke", card, "FocusOutline")
        stroke.Color = ACCENT
        stroke.Thickness = 2
        stroke.Transparency = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        self.Cards[modeId] = {
            Button = card,
            Background = background,
            Name = name,
            Badge = badge,
            Stroke = stroke,
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
        })
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
    return self
end

function Grid:Update(catalog)
    table.clear(self.Catalog)
    for _, item in ipairs(catalog or {}) do
        self.Catalog[item.id] = item
    end
    for id, card in pairs(self.Cards) do
        local item = self.Catalog[id]
        local enabled = item and item.canEnter == true
        local cfg = Presentation.Cards[id]
        card.Name.Text = item and item.name or id
        card.Badge.Text = enabled and "DISPONÍVEL" or cfg.UnavailableLabel or
            (item and item.status == "planned" and "EM BREVE" or "INDISPONÍVEL")
        card.Badge.TextColor3 = enabled and Color3.fromRGB(130, 235, 175) or MUTED
        card.Background.ImageTransparency = enabled and 0 or 0.4
        card.Button:SetAttribute("Playable", enabled == true)
    end
end

function Grid:Resize()
    local width = self.Parent.AbsoluteSize.X
    if width < 1 then return end
    local columns = width >= 700 and 2 or 1
    local gap = 12
    local cardHeight = columns == 2 and math.clamp(width * 0.25, 190, 270) or 190
    self.Layout.FillDirectionMaxCells = columns
    self.Layout.CellSize = UDim2.new(1 / columns, -gap * (columns - 1) / columns, 0, cardHeight)
    local rows = math.ceil(#Presentation.Order / columns)
    self.Parent.CanvasSize = UDim2.fromOffset(0, rows * cardHeight + math.max(0, rows - 1) * gap)
    -- Em modo 1 coluna, revisar também os links de D-pad na integração definitiva.
end

function Grid:DefaultFocus()
    return self.Cards.arena.Button
end

function Grid:Destroy()
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    for _, card in pairs(self.Cards) do
        card.Button:Destroy()
    end
    self.Layout:Destroy()
end

return Grid
