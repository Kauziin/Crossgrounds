-- Fotos de assets/maps importadas para os cards da tela Jogar.
local Presentation = {}

Presentation.Order = { "arena", "ctf", "duels", "get_out" }
Presentation.Cards = {
    arena = {
        Subtitle = "Combate rápido em primeira pessoa",
        Image = "rbxassetid://102765073742237",
        Symbol = "Swords",
    },
    ctf = {
        Subtitle = "Trabalho em equipe e estratégia",
        Image = "rbxassetid://101619043843471",
        Symbol = "Flag",
    },
    duels = {
        Subtitle = "Confrontos competitivos",
        Image = "rbxassetid://125480821363582",
        Symbol = "Crosshair",
    },
    get_out = {
        Subtitle = "Sobrevivência assimétrica",
        Image = "rbxassetid://126566346004931",
        Symbol = "Escape",
        UnavailableLabel = "Protótipo",
    },
}

return Presentation
