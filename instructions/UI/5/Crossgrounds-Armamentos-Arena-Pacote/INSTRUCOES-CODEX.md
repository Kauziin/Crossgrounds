# Codex — Refinar somente a interface de Armamentos da Arena

Leia `PLANO-DE-IMPLEMENTACAO.md`, `03_repositorio/MAPA-DE-ARQUIVOS.md` e compare a referência `01_referencias/01_conceito_grade_2x3_com_preview.png` com o código real do projeto **Kauziin/Crossgrounds**, branch `master`.

1. **Não recrie a tela do zero**: `LoadoutMenuView.luau` já possui grid 2×3, oito ViewportFrames e prévia 3D. Primeiro audite o que já está pronto e ajuste somente o necessário.
2. Preserve o menu lateral/pausa do Crossgrounds. Reserve o painel de conteúdo para seis cards de pistolas (M1911, Magnum, Glock 18, Desert Eagle, Luger P08 e Beretta M9) em **2 colunas × 3 linhas**, com nome, miniatura 3D e indicação discreta **Executor · corpo a corpo**.
3. À direita, mantenha uma prévia grande da pistola em `ViewportFrame` e uma seção menor para o **modelo real do Executor (melee)**. Modelos simples/quadriculados são intencionais; não inventar recursos externos.
4. **Nunca reproduza os gráficos de Dano/Controle/Mobilidade da imagem ilustrativa**. Na Arena eles são desnecessários. Não mostre atributos de arma nem classifique o Executor como pistola.
5. **Navegação:** foco (hover, mouse, D-pad) só altera a prévia; **A/click no card confirma a escolha**; **B volta**. Foco e arma confirmada são estados distintos. O card confirmado/pedente recebe estado visual persistente; o foco recebe contorno e losango sem enviar a escolha. Um card por loadout como alvo de navegação; os ViewportFrames não recebem foco.
6. Reutilize `ExperienceMenu`, `MenuNavigation`, `LoadoutDefinitions`, `LoadoutService` e `SelectLoadout`. **Não crie remotes, não altere mecânicas**. Confirmação envia `SelectLoadout:FireServer("arena", id)` uma vez; servidor valida e grava `PendingArenaLoadout`; `ArenaPistolVisual` só muda no próximo nascimento.
7. Dê feedback curto quando o servidor confirmar o atributo pendente: "Selecionado para o próximo nascimento". Não indique sucesso antes de receber o estado replicado. Se a escolha ativa e a pendente coincidirem, evite destaques duplicados. Se houver limitação de chamadas, respeite o throttle atual.
8. Responsividade: desktop/console lado a lado; telas estreitas empilham a prévia abaixo do grid, mantendo scroll, margens seguras, tamanho de fonte configurável e aviso admin. Respeite `ReducedMenuMotion` e alta acessibilidade.
9. Não mexa na **tela Jogar**, na **tela inicial**, nas **configurações**, no **Gunsmith/CTF**, no serviço de dano nem no balanceamento.
10. Teste a inspeção sem mudança, a confirmação, o estado pendente, o respawn, a navegação 2×3 por controle, limpeza dos ViewportFrames ao sair e a responsividade. Relate os arquivos modificados e testes realmente executados. Não publique a experiência.

O objetivo é **uniformizar a apresentação visual**, não reconstruir um recurso já implementado.
