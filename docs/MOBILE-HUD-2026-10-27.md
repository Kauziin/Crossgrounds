# HUD mobile e apresentação de admin

Aplicado ao Crossgrounds (ALPHA), placeId 4375993208, no modelo de edição do Studio em 2026-10-27. Nenhuma publicação foi executada.

## Alterações

- Os quinze controles de toque usam somente ícones vetoriais locais, sem legendas, letras de ação ou números de atalho. Os nomes continuam disponíveis no painel de edição.
- Os controles de admin mantêm a área de toque e os comandos existentes, com menor contraste em repouso. O aviso de admin ocupa 210 × 26 em repouso e 300 × 42 no modo espectador, limitado pela largura da tela. Mensagens continuam disponíveis; captura limpa e edição de HUD ocultam o aviso.
- O painel de propriedades passou de 370 × 318 para 232 × 132, com tamanho e opacidade. Ele começa oculto, aparece ao selecionar e ocupa o canto mais distante do botão ajustado. A barra de salvar/cancelar/padrão permanece independente.
- Arraste contínuo por mouse e toque, conservando o ponto onde o botão foi agarrado. O limite considera o tamanho real do botão e a área segura. Clicar/tocar no espaço vazio desseleciona e oculta as propriedades.
- No controle, segurar A sobre um botão e mover o cursor permite reposicioná-lo. Os controles de propriedades e a navegação anterior continuam disponíveis.
- Coordenadas são salvas com passo de 0,0001, preservando o protocolo MobileHUDLayout e as preferências existentes. Tamanho e opacidade mantêm seus limites anteriores.

## Validação

As cinco fontes compilam no Luau do Studio. O teste isolado `artifacts/mobile-hud-2026-10-27/test-hud.luau` executou o código de produção com instâncias reais de GUI e sinais de entrada injetados, sem iniciar uma sessão de jogo na experiência principal. As 42 verificações passaram: quinze ações sem TextLabel, seleção, arraste sem grade percentual, limites seguros, painel que muda de canto, toque no vazio, cancelar, eventos de jogo, arraste por toque e controle, salvar e restaurar. Formatos testados: 1366 × 768, 749 × 381 e 390 × 844.

Também foram verificados os tamanhos do aviso de admin, ocultação no editor/captura limpa e preservação de mensagens. As GUIs temporárias foram removidas. Leitura das fontes após a aplicação confirmou os cinco componentes no principal. `git diff --check` passou nos quatro arquivos existentes modificados.

O teste isolado não comprova ergonomia em celular físico nem persistência após reconectar ao servidor; esses cenários não foram executados nesta sessão.

## Fontes e recuperação

As versões exatas anteriores do principal estão em `artifacts/mobile-hud-2026-10-27/current/`, e as novas versões em `artifacts/mobile-hud-2026-10-27/after/`. O módulo novo está em `src/StarterPlayer/StarterPlayerScripts/TouchActionIcons.luau`. Não foram alterados servidor de combate, regras de loadout ou outras telas.
