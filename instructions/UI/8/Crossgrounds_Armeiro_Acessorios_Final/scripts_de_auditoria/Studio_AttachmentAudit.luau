-- Crossgrounds - Studio Attachment Audit
-- Execute manualmente no Studio para gerar um inventário inicial.

local root = workspace:FindFirstChild("ImportedArsenalOriginals")
    or game.ServerStorage:FindFirstChild("ImportedArsenalOriginals")
    or game.ReplicatedStorage:FindFirstChild("ImportedArsenalOriginals")

if not root then
    warn("ImportedArsenalOriginals não encontrado.")
    return
end

local SLOT_RULES = {
    {key = "Muzzle", tokens = {"suppressor", "silencer", "muzzle", "compensator", "brake", "flash", "monolithic"}},
    {key = "Barrel", tokens = {"barrel", "cqb", "extended", "long barrel", "short barrel"}},
    {key = "Laser", tokens = {"laser", "tac laser", "5mw", "1mw"}},
    {key = "Optic", tokens = {"optic", "scope", "sight", "reflex", "holo", "sniper scope", "thermal"}},
    {key = "Stock", tokens = {"stock", "stalker", "coronha"}},
    {key = "Underbarrel", tokens = {"grip", "underbarrel", "foregrip", "commando", "operator", "ranger", "merc", "bipod"}},
    {key = "Magazine", tokens = {"mag", "magazine", "drum", "round", "carregador"}},
    {key = "RearGrip", tokens = {"rear grip", "grip tape", "empunhadura traseira"}},
    {key = "Ammunition", tokens = {"ammo", "ammunition", "fmj", "hollow", "incendiary", "frangible"}},
    {key = "Perk", tokens = {"perk", "sleight", "fully loaded", "mo money"}},
}

local function inferSlot(name)
    local lower = string.lower(name)
    for _, rule in ipairs(SLOT_RULES) do
        for _, token in ipairs(rule.tokens) do
            if string.find(lower, token, 1, true) then
                return rule.key
            end
        end
    end
    return "Unknown"
end

local report = {}

for _, desc in ipairs(root:GetDescendants()) do
    if desc:IsA("Model") or desc:IsA("Folder") or desc:IsA("Tool") or desc:IsA("MeshPart") then
        local entry = {
            name = desc.Name,
            className = desc.ClassName,
            fullName = desc:GetFullName(),
            slotGuess = inferSlot(desc.Name),
            childCount = #desc:GetChildren(),
        }
        table.insert(report, entry)
    end
end

table.sort(report, function(a, b)
    if a.slotGuess == b.slotGuess then
        return a.name < b.name
    end
    return a.slotGuess < b.slotGuess
end)

print("=== ATTACHMENT AUDIT REPORT ===")
for _, item in ipairs(report) do
    print(string.format("[%s] %s | %s | children=%d", item.slotGuess, item.name, item.className, item.childCount))
end
print("Total:", #report)
