# Bots e UI unificada — diagnóstico antes da implementação

23/10/2026. Documentos da raiz lidos integralmente: Crossgrounds_Bot_Intelligence_System.md e Crossgrounds_Unified_UI_UX_Settings.md. Inspeção das fontes locais e das instâncias reais do Studio Crossgrounds (ALPHA), Place 4375993208, em Edit. Sem publicação.

## Bots: fluxo e evidências

- BotManager preenche CTF até seis por equipe, usa skins/nomes de AvatarService, SpawnService, Humanoid de 200 HP e network ownership do servidor. Template real contém Animate (Script), animações e Animator: serão preservados.
- Arena possui alvos estacionários, não um controlador de bots de combate. Duels e Get Out não possuem APIs jogáveis de objetivos/NPC encontradas no runtime; não serão inventadas modalidades.
- BotBrain mistura percepção, objetivos, disparo e pathfinding em um while por bot (~90 ms). ComputeAsync bloqueia o ciclo de percepção/combate daquele bot; não há limite global de cálculos concorrentes.
- A seleção dispensa o cone para inimigos a menos de 22 studs; dano recente também dispensa o cone. Depois da seleção, objetivo/rotação/disparo consultam HumanoidRootPart do alvo entre scans. Interceptação lê a posição atual do portador inimigo sem exigir visão.
- Rotas são refeitas por deslocamento de 11 studs ou 2,8 s, sem Path.Blocked; falhas caem em MoveTo direto ao destino sem comprovação de caminho livre. MoveTo é reenviado em cada ciclo. Recuperação pode teleportar ao lastSafe.
- Munição/reload são variáveis locais do Brain, com carregadores infinitos. BotAccuracy escolhe um indicador de acerto pretendido e offsets; tiro usa raycast real, porém desvia da nova API autoritativa compartilhada e força headshot=false.
- HealthChanged não é desconectado explicitamente pelo Brain; StopRound destrói modelos, mas não tem um controlador cancelável para rotas/tarefas.

## Ordem e orçamentos iniciais

1. Preservar spawn, papel, skin, animação, bandeiras e dano; substituir somente o controlador monolítico por componentes usados de fato.
2. Navegação cancelável, até duas rotas concorrentes e quatro novos cálculos/s; backoff, progresso, bloqueio e abandono. Nenhum teleporte de resgate.
3. Sensor com cone/LOS, memória degradável e som autoritativo; até 120 consultas de visão/s no conjunto, com scans distribuídos. Decisão a ~0,35–0,55 s, navegação a 0,1 s e mira em coletor compartilhado a 20 Hz. Esses números são orçamentos iniciais, não resultados de benchmark.
4. Integrar NPCs à resolução de disparos existente; preservar dano/cadência/recarga/dispersão/alcance e munição finita. Mira progressiva e erro contínuo, sem sortear um acerto garantido.
5. Dificuldade separada de personalidade, utilidade com histerese, adapter CTF e diagnóstico exclusivamente de desenvolvimento.

## UI: inventário e mapa anterior → proposto

| Local atual observado | Problema | Local proposto | Motivo |
|---|---|---|---|
| Opções → Gráficos: FOV e oscilação | Opções de câmera em categoria gráfica | Mira e Câmera | Classificação pelo efeito percebido |
| Jogabilidade: perspectiva, ombro, Shift Lock | Apresentação/controle de câmera misturados | Mira e Câmera | Um único local coerente, respeitando Arena |
| Controles → Mira e Acessibilidade: AA duplicado | Mesmas chaves aparecem em dois painéis | Mira e Câmera → Mira | Evitar controles duplicados |
| HUD mobile em Controles | Editor já existe e funciona via MobileHUD; preservar | Controles → Toque | Dependência específica do dispositivo |
| ExperienceSettings + SettingsService | Schema real já centraliza validação, mas perfil é plano, sem versão/herança | Evoluir os mesmos módulos | Evitar segundo serviço/DataStore |
| ExperienceMenu e CascadeMenu | Em telas estreitas as colunas anteriores podem virar faixas de 24/28 px | Navegação por nível em tela estreita | Preservar cascata no desktop sem comprimir texto no celular |
| Texto de 12–15 px e linhas fixas | Sem ajuste universal de texto/menu/HUD | Interface + Acessibilidade | Escalas independentes com reflow/scroll |
| Retículo de WeaponController | Geometria fixa, sem prévia ou preferências por modo | Mira e Câmera → Retículo | Componente compartilhado entre prévia e jogo |
| Áudio de lobby e navegação | Sistemas reais disponíveis | Áudio (preservado) | Não oferecer volume de canal inexistente |

Menus reais: ExperienceMenu, HubController, JoinMenu, ArenaHUD, CombatHUD, MobileHUD, ProgressionPanel, HeldStandings/MatchStandingsHUD e LobbyMusicMenu. Preservar MenuTheme, MenuNavigation, ControlRouter, InputIcons, cascatas sólidas e sombras por profundidade. Persistência atual usa CTF_ExperienceSettings_v1, UpdateAsync a cada 30 s e saída; é desativada no Studio. Evoluir o formato sem criar um DataStore por preferência.

Conjunto vertical da UI: categorias corrigidas; escala de menu/HUD/texto, contraste e redução de movimento com efeitos reais; retículo compartilhado e prévia; Global/CTF/Arena com overrides somente em chaves permitidas. Bindings de teclado/gamepad e layout touch já têm semântica de dispositivo e não receberão uma matriz Mode×Device arbitrária. Duels/Get Out não ganharão painéis vazios.
