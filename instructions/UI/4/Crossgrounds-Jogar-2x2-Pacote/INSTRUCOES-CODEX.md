# Instruções para o Codex — Implementar Jogar 2×2

Use `PLANO-DE-IMPLEMENTACAO.md` e **a imagem `01_referencias/02_conceito_grid_2x2.png`** como base visual. Implemente somente a tela Jogar/Modalidades no projeto `Kauziin/Crossgrounds`, sem refazer a tela inicial, a pausa ou as configurações.

- Transforme a apresentação das modalidades em **quatro cards grandes**, distribuídos em grade **2×2** na ordem fixa **Arena, Capture a Bandeira, Duels, Get Out**. Preserve a navegação lateral do Crossgrounds.
- Os cards terão imagens de fundo (`02_imagens_dos_modos/`), gradiente escuro para textos, título, descrição breve e indicação de disponibilidade. A borda turquesa luminosa e o losango indicam foco, não disponibilidade.
- Extraia metadados visuais para `ModePresentation.luau` e a montagem do grid para `ModeSelectGrid.luau` (exemplos em `03_exemplos_luau/`). **Adapte esses exemplos ao código real**, sem duplicar os cards, controladores ou estados atuais.
- **Não aplique `UIGridLayout` cegamente à cascata estreita.** A tela Jogar exige largura própria no `HubController`, mantendo o mesmo sistema de menus e `ModeDetails` existente.
- Controle: D-pad entre os 4 cards; **A** entrar apenas quando `canEnter == true`; **X** detalhes; **B** voltar; mouse/toque equivalentes. Card é o único alvo de foco por modalidade.
- Reutilize `HubBridge` e o `SessionCoordinator` atual para join/enter/cancel, status, tickets e erros. Não invente matchmaking cross-server nem novo RemoteEvent. Texto de botão deve corresponder ao fluxo real, não obrigatoriamente “Entrar na fila”.
- **Get Out deve continuar listado, mas indisponível publicamente**: no `GameCatalog.luau`, usar `status="planned"` para o registro do modo. Duels permanece indisponível. Arena e CTF dependem de `canEnter` retornado pelo servidor.
- Mantenha responsividade: 2 colunas em desktop/console, 1 coluna em telas estreitas. Use `rbxassetid://...` apenas quando os PNGs tiverem sido publicados; não criar IDs fictícios.
- Ao concluir, relate arquivos modificados/criados, dependências de assets, testes realizados e pendências. Não publique a experiência nem altere sistemas não relacionados.
