-- EXEMPLO ORIENTATIVO. Imagens dependem de upload para a experiência Roblox.
local Presentation = {}

Presentation.Order = { "arena", "ctf", "duels", "get_out" }
Presentation.Cards = {
    arena = {
        Subtitle = "Combate rápido em primeira pessoa",
        Image = "", -- rbxassetid://ID_DEPOIS_DO_UPLOAD
        Symbol = "Swords",
    },
    ctf = {
        Subtitle = "Trabalho em equipe e estratégia",
        Image = "",
        Symbol = "Flag",
    },
    duels = {
        Subtitle = "Confrontos competitivos",
        Image = "",
        Symbol = "Crosshair",
    },
    get_out = {
        Subtitle = "Sobrevivência assimétrica",
        Image = "",
        Symbol = "Escape",
        UnavailableLabel = "Protótipo",
    },
}

return Presentation
