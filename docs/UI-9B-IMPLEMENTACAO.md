# UI #9b — progressão e desbloqueios

Implementação de 02/11/2026 em master, checkout Kauziin/Crossgrounds. Aplicada ao editor principal 4375993208; sem publicação, commit ou push nesta etapa. Alterações simultâneas de armas, munição e HUD foram preservadas.

## Arquitetura e escopo

A auditoria anterior às alterações está em UI-9B-AUDITORIA.md. Referências: os três PNGs de instructions/UI/#9b; não existe pasta Local neste checkout. A apresentação amplia ProgressionPanel/ProgressionView e GunsmithView. Não substitui estatísticas pessoais, ranking, amigos, presets nem o gerenciamento de clãs.

ProgressionTracks é uma projeção somente de leitura de CareerPolicy, UnlockCatalog, AttachmentCompatibility, WeaponFinishCatalog e ClanCatalog. Não concede XP, itens ou benefícios. ProgressionTrackView compartilha identidade, barra de XP, trilha virtualizada, estados, detalhes, paginação e filtros. Até oito cards são criados por vez; não há nova animação em RenderStepped nem múltiplos ViewportFrames por card. O Armeiro reutiliza o modelo/ViewportFrame existentes. Não foi medido FPS/GPU.

## Comportamento implementado

**Conta:** entrada Desbloqueios de Nível no menu Progresso. Avatar, nome, nível da etapa, XP da etapa/total e próximo limiar seguem CareerPolicy. Sete cards na captura larga, redução conforme largura, marcações na linha de progresso, losango, borda dupla, várias recompensas no mesmo nível e detalhes de níveis sem recompensa. O estado considera permanências por token e a fase da carreira; não há segundo perfil de desbloqueios. Filtros incluem categorias e as modalidades que possuem dados de desbloqueios (Conflict/Arena). Níveis anteriores/futuros e salto ao atual disponíveis.

**Arma:** botão Progressão da arma nas ferramentas da seleção do Armeiro. A arma inspecionada pode ser consultada sem equipá-la ou substituir o preset. A validação percorreu o fluxo real PrimarySlot → lista de armas → foco ODEN → ferramenta Progressão. XP/nível usam a chave canônica da arma no perfil existente. A prévia usa o modelo real da ODEN pelo ArsenalCommand/ArsenalPreview. Acabamentos e acessórios reutilizam os catálogos; os acabamentos usam WeaponFinishVisual e o protocolo CareerCommand/finish, com sua restrição existente de alteração no hub. Acessórios funcionais compatíveis usam o save de preset existente e mostram diferenças dos atributos efetivos sustentados por WeaponStats. Arena não recebeu estatísticas nem esta tela de Armeiro CTF.

A ODEN ainda tem slots={} e não possui montagem de acessórios aprovada. Sua trilha contém os acabamentos reais Original/Bosque/Deserto/Oceano/Ouro, nos níveis 1/10/25/40/55. Nos demais níveis consta Sem recompensa. Não foram adicionadas miras, encaixes ou valores de balanceamento para imitar o mockup. O botão de equipar é desativado quando o contexto exige voltar ao lobby; a exceção existente do Practice Range é explicitada para acessórios.

**Guilda:** página Progresso da Guilda em Progresso e atalho no gerenciamento de clãs. Integra ClanBridge/ClanService: associação ativa confirmada, nome/tag/emblema, XP coletiva acumulada, nível e membros. A lista de contribuições é ordenada por XP, com empate por userId, e informa Desde a entrada. Filiação pendente, ausência de membro/epoch ou clã arquivado não são apresentados como associação ativa. A recompensa de identidade já existente (cartão/moldura/título) continua concedida automaticamente pelo servidor ao atingir clã nível 3 e contribuição de 1.000 XP; constantes extraídas para ClanCatalog sem mudar os valores. Cosméticos anteriormente conquistados continuam marcados como disponíveis após troca de clã. Não há resgate ou concessão feita pelo cliente.

Não existe backend semanal: a área Missões semanais informa essa indisponibilidade. Não foram criadas missões, recompensas fictícias, bônus competitivos ou agregações semanais. O clã Teste UI9b das capturas foi criado pelo protocolo real somente na memória da sessão de Studio.

**Controle:** A seleciona; B fecha filtros/volta; X abre filtro; Y vai ao atual; LB/RB alternam categorias com foco na trilha; LT/RT saltam grupos. MenuNavigation procura o handler mais próximo do foco e deixa triggers passarem quando o controle focado não oferece essa ação, inclusive na liberação do botão. Rodapé contextual usa os comandos da trilha. Filtros flutuantes capturam/restauram foco; ocultar a interface fecha os popups. Mouse, teclado e botões de paginação/toque permanecem disponíveis.

**Responsividade:** menu lateral preservado nas telas largas. Em telas estreitas o mesmo menu oferece um seletor de seção e rolagem por etapas. A compensação das escalas herdadas mantém os cards legíveis sem aumentar a largura do contêiner. Na captura mobile final foram medidos dois cards de 197×126 pixels dentro de lista com 138 pixels de altura, foco em Level1 e CanvasPosition.Y=196. A seleção da seção espera dois frames para restaurar foco depois do popup. A paleta global do usuário continua sendo respeitada, inclusive o turquesa nas capturas; não foi fixado roxo por cima do tema configurado.

## Arquivos desta etapa

- src/ReplicatedStorage/Crossgrounds/ProgressionTracks.luau — projeções das três trilhas (novo).
- src/ReplicatedStorage/Crossgrounds/ClanCatalog.luau — metadados da recompensa já existente.
- src/ServerScriptService/Crossgrounds/ClanService.luau — reutiliza os mesmos metadados na concessão existente.
- src/StarterPlayer/StarterPlayerScripts/ProgressionTrackView.luau — apresentação compartilhada (novo).
- src/StarterPlayer/StarterPlayerScripts/ProgressionView.luau — novas entradas e seletor compacto.
- src/StarterPlayer/StarterPlayerScripts/ProgressionPanel.local.luau — integra conta e guilda.
- src/StarterPlayer/StarterPlayerScripts/CareerClient.luau — consulta do snapshot já carregado, condicionada a CareerReady.
- src/StarterPlayer/StarterPlayerScripts/GunsmithView.luau — progressão da arma inspecionada, prévia e fluxo existente de equipar.
- src/StarterPlayer/StarterPlayerScripts/MenuNavigation.luau — categorias com escopo de foco, triggers e ajuda contextual.
- src/StarterPlayer/StarterPlayerScripts/ClanMenu.local.luau — atalho para a progressão coletiva.
- tests/Unit/Cases/ProgressionTracks_Test.luau — seis contratos novos.
- docs/UI-9B-AUDITORIA.md, este relatório e ESTADO-DO-DESENVOLVIMENTO.md — documentação.

## Validação e resultados

As dez fontes de runtime compilaram em Edit e foram comparadas com os arquivos locais, normalizando CRLF: todas iguais. git diff --check passou (somente avisos de CRLF em arquivos de outros trabalhos).

Rodada ampliada: **71/72** testes passaram, em seis suítes: ProgressionTracks, CareerFoundation, ClanSystems, ProgressionPolicy, Plan8Arsenal e ThemeAndInterface. A única falha foi Plan8Arsenal > pistol classification excludes rifles and blasters: a asserção de Mount.Z ainda espera -0.7, enquanto WeaponHold já foi alterado por trabalho de empunhadura preexistente para -1.1. A classificação não foi alterada nesta etapa; a posição e o teste alheios foram preservados. Resultado bruto em artifacts/progression-9b-2026-11-02/unit-results.json.

Após acrescentar a preservação de cosméticos já conquistados de guilda, a rodada final dos contratos novos passou **6/6** (unit-tracks-final.json). Os contratos cobrem curvas existentes, permanências, múltiplas recompensas/filtros, ODEN/XP/acabamentos, ausência de perfil e filiações pendentes/removidas/arquivadas. A concessão de XP continua integralmente nos serviços existentes.

Em Play: abertura das três apresentações, perfil de teste no nível 31, ODEN com 16.200 XP/nível 10, modelo real no Armeiro e clã criado pelo backend da sessão. Os dados controlados foram configurados por script temporário normal do servidor, protegido por IsStudio; não são o perfil de produção do jogador. Não foi salvo preset nem efetuado resgate/compra como parte da captura. A prévia standalone no hub recebeu Indisponível nesta modalidade; foi descartada como validação de modelo e substituída pelo percurso real no Practice Range.

Entradas simuladas com o Studio em foco confirmaram D-pad direito Level1→Level2, RT→Level8, Y→atual, X abrindo filtros, B fechando/restaurando foco e RB alterando categoria para Armas. O fluxo mobile final abriu a seção pelo seletor e confirmou o foco em Level1 após os dois frames de transição. Não equivale a validação em controle físico.

Capturas em artifacts/progression-9b-2026-11-02/: 01-account-1080.jpg, 02-oden-armeiro-1080.jpg, 03-guild-backend-1080.jpg, 04-filters.jpg, 05-account-720.jpg, 06-account-4by3.jpg, 07-mobile-final.jpg. As capturas de conta 1080 e guilda usam fixtures somente da sessão. A captura 720 registra uma iteração anterior à compensação final de escala; 4:3 e mobile foram recapturados após a correção. Simulação em Xbox 1920×1080, 1280×720, proporção 1024×768 e iPhone 17 Pro landscape 874×402 (viewport informado 750×382), usando a API oficial: https://create.roblox.com/docs/reference/engine/classes/StudioDeviceSimulatorService.

Play foi encerrado, simulator=default e nenhuma instância UI9B temporária ficou nos contêineres do editor. Avisos anteriores de assets sem permissão/arquivados, GUIEditor e configurações ausentes permanecem fora do escopo.

## Pendências e limites

1. Aprovar e implementar montagens reais de acessórios para a ODEN antes de exibi-los/equipá-los como compatíveis.
2. Serviço de missões semanais e contribuições por período, com política própria de concessão e deduplicação; a UI não simula esses dados.
3. Hardware Xbox/mobile, todos os gestos de toque, multiplayer humano e benchmark de desempenho ainda não validados.
4. Não foi testada persistência em DataStore de produção nem alteração de acabamento/equipamento em todas as modalidades. Os testes de repositório usam stores em memória e a sessão usa StudioSessionOnly. CareerCutoverApproved continua sendo a decisão existente para ativação da carreira em produção.
5. Expectativa antiga do teste de empunhadura deve ser conciliada pelo trabalho responsável por WeaponHold. Não é falha introduzida pela nova apresentação.
6. As últimas proteções de popup oculto e de trigger sem handler receberam compilação e revisão de fonte, sem repetir todos os percursos anteriores depois desses ajustes.

Saldo semanal conferido no encerramento das etapas: 11% restante na última consulta, acima da parada de 1%. Nenhuma experiência foi publicada.
