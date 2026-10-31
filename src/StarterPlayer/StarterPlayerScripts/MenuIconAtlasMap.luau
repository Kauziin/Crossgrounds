-- Crossgrounds: 48 menu sprites (96x96 each, RGBA white).
-- Set ImageLabel.Image = "rbxassetid://YOUR_ATLAS_ID"
-- Set ImageLabel.ImageRectOffset = Vector2.new(entry.x, entry.y)
-- Set ImageLabel.ImageRectSize = Vector2.new(entry.w, entry.h)
-- Set ImageLabel.ImageColor3 = yourThemeAccentOrWhite
return {
    ["home"] = { x = 0, y = 0, w = 96, h = 96 }, -- Início
    ["play"] = { x = 96, y = 0, w = 96, h = 96 }, -- Jogar
    ["stay-lobby"] = { x = 192, y = 0, w = 96, h = 96 }, -- Permanecer no lobby
    ["progress"] = { x = 288, y = 0, w = 96, h = 96 }, -- Progresso
    ["settings"] = { x = 384, y = 0, w = 96, h = 96 }, -- Ajustes / Opções
    ["music"] = { x = 480, y = 0, w = 96, h = 96 }, -- Música / Playlist
    ["resume"] = { x = 576, y = 0, w = 96, h = 96 }, -- Continuar
    ["loadout"] = { x = 672, y = 0, w = 96, h = 96 }, -- Loadout
    ["surrender"] = { x = 0, y = 96, w = 96, h = 96 }, -- Render-se
    ["exit"] = { x = 96, y = 96, w = 96, h = 96 }, -- Sair
    ["gameplay"] = { x = 192, y = 96, w = 96, h = 96 }, -- Geral
    ["controls"] = { x = 288, y = 96, w = 96, h = 96 }, -- Controles
    ["camera-category"] = { x = 384, y = 96, w = 96, h = 96 }, -- Mira e Câmera
    ["interface"] = { x = 480, y = 96, w = 96, h = 96 }, -- Interface
    ["graphics"] = { x = 576, y = 96, w = 96, h = 96 }, -- Gráficos
    ["accessibility"] = { x = 672, y = 96, w = 96, h = 96 }, -- Acessibilidade
    ["audio"] = { x = 0, y = 192, w = 96, h = 96 }, -- Áudio
    ["maps"] = { x = 96, y = 192, w = 96, h = 96 }, -- Votação de mapa
    ["admin-maps"] = { x = 192, y = 192, w = 96, h = 96 }, -- Admin · mapas
    ["development"] = { x = 288, y = 192, w = 96, h = 96 }, -- Desenvolvimento
    ["analog"] = { x = 384, y = 192, w = 96, h = 96 }, -- Analógicos
    ["bindings"] = { x = 480, y = 192, w = 96, h = 96 }, -- Remapear comandos
    ["touch-hud"] = { x = 576, y = 192, w = 96, h = 96 }, -- Toque · editar HUD
    ["camera-perspective"] = { x = 672, y = 192, w = 96, h = 96 }, -- Câmera e perspectiva
    ["aim-sensitivity"] = { x = 0, y = 288, w = 96, h = 96 }, -- Mira e sensibilidade
    ["reticle"] = { x = 96, y = 288, w = 96, h = 96 }, -- Retículo
    ["stats-profile"] = { x = 192, y = 288, w = 96, h = 96 }, -- Estatísticas pessoais
    ["leaders"] = { x = 288, y = 288, w = 96, h = 96 }, -- Placar de líderes
    ["compare-friends"] = { x = 384, y = 288, w = 96, h = 96 }, -- Comparativo com amigos
    ["arena"] = { x = 480, y = 288, w = 96, h = 96 }, -- Arena
    ["get-out"] = { x = 576, y = 288, w = 96, h = 96 }, -- Get Out
    ["duels"] = { x = 672, y = 288, w = 96, h = 96 }, -- Duels
    ["ctf"] = { x = 0, y = 384, w = 96, h = 96 }, -- Capture The Flag
    ["kit"] = { x = 96, y = 384, w = 96, h = 96 }, -- Escolher kit
    ["queue"] = { x = 192, y = 384, w = 96, h = 96 }, -- Entrar na partida
    ["spectate"] = { x = 288, y = 384, w = 96, h = 96 }, -- Espectador
    ["playlist"] = { x = 384, y = 384, w = 96, h = 96 }, -- Editar playlist
    ["track-prev"] = { x = 480, y = 384, w = 96, h = 96 }, -- Faixa anterior
    ["track-next"] = { x = 576, y = 384, w = 96, h = 96 }, -- Próxima faixa
    ["shuffle"] = { x = 672, y = 384, w = 96, h = 96 }, -- Aleatório
    ["pause"] = { x = 0, y = 480, w = 96, h = 96 }, -- Pausar música
    ["reset"] = { x = 96, y = 480, w = 96, h = 96 }, -- Restaurar padrão
    ["back"] = { x = 192, y = 480, w = 96, h = 96 }, -- Voltar
    ["confirm"] = { x = 288, y = 480, w = 96, h = 96 }, -- Confirmar
    ["edit"] = { x = 384, y = 480, w = 96, h = 96 }, -- Editar
    ["scope-global"] = { x = 480, y = 480, w = 96, h = 96 }, -- Escopo global
    ["customize"] = { x = 576, y = 480, w = 96, h = 96 }, -- Personalizar
    ["volume-muted"] = { x = 672, y = 480, w = 96, h = 96 }, -- Silenciar
}
