-- EXEMPLO ORIENTATIVO. Imagens dependem de upload para a experiência Roblox.
local Presentation = {}

Presentation.Order = { "arena", "ctf", "duels", "get_out" }
Presentation.Cards = {
    arena = {
        Subtitle = "Combate rápido em primeira pessoa",
        Image = "rbxassetid://113015463809046", -- rbxassetid://ID_DEPOIS_DO_UPLOAD
        Symbol = "Swords",
    },
    ctf = {
        Subtitle = "Trabalho em equipe e estratégia",
        Image = "rbxassetid://91634170272364",
        Symbol = "Flag",
    },
    duels = {
        Subtitle = "Confrontos competitivos",
        Image = "rbxassetid://97447858799189",
        Symbol = "Crosshair",
    },
    get_out = {
        Subtitle = "Sobrevivência assimétrica",
        Image = "rbxassetid://72478321570256",
        Symbol = "Escape",
        UnavailableLabel = "Protótipo",
    },
}

return Presentation
