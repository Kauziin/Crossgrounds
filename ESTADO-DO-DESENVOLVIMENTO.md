# Capture a Bandeira — Estado atual de desenvolvimento

**Recursos CTF no Practice Range — 31/10/2026:** liberei os controles CTF com `InMatch=false` somente quando `CTFPracticeRange=true`; a câmera entra em primeira pessoa por override temporário, sem alterar a preferência global, e pode voltar à perspectiva normal. O `ExperienceMenu` agora carrega e rotula o acesso como “Armeiro”; o comando de kits do CTF é roteado ao Gunsmith durante o treino. Checagem estática dos módulos alterados passou. Play confirmou `CombatCameraActive=true`, `FirstPerson=true`, ExperienceMenu presente e botão “Armeiro”; a instância MCP desconectou antes de confirmar por clique a abertura do Gunsmith via `CTFKits`. Sem publicação.

**Practice Range CTF — 31/10/2026:** opção `Practice Range · Boot Camp` adicionada aos detalhes do card CTF, sem novo card global. A fila preserva a variante `practice`; a entrada usa o CTFAdapter sem atribuir time ou `InMatch`. O Boot Camp é movido para `ServerStorage` antes de o CTF capturar geometria dos mapas, e uma cópia temporária com pares de spawn é criada durante o treino. Cada usuário recebe um rig `PracticeDummy` sem Tools nem scripts; saída remove alvo e cópia temporária. No treino, presets são salvos e equipados imediatamente sem respawn; seleção de kit também reaplica as armas. Play local validou o clique real do card, CTFPracticeRange ativo com `InMatch=false`/`InArena=false`, alvo passivo, troca de loadout para AX-50 com deslocamento de personagem 0 e limpeza ao retornar ao Hub. `CrossgroundsBootPhase=Pronto`; o console contém avisos já existentes de assets sem permissão/arquivados e do plugin GUIEditor. Studio retornou a Edit; sem publicação. Entrada durante round ativo, sessões simultâneas e validação em hardware permanecem pendentes.

**Resumo dinâmico de acessórios — 31/10/2026:** a visão da classe deixa de mostrar categorias fixas no loadout. Sem acessórios, mostra marcadores circulares pequenos; com acessórios, cria chips com os nomes equipados e recalcula a largura disponível. O resumo da arma secundária também lista só itens instalados. Checagem estática sem erros; não foi feita captura visual em Play nesta etapa.

**Categorias do Gunsmith — 31/10/2026:** separei `muzzle` (“Boca”) de `barrel` (“Cano”) nos rótulos do seletor, nos comandos de personalização e na visão da classe. O resumo da primária agora mostra seis slots distintos. Os três módulos de interface passaram na checagem estática; captura/validação visual em Play não realizada nesta etapa.

**AX-50 Extended Barrel — 31/10/2026:** cano acessível no slot `barrel`, independente do slot de supressor. Malha `Barrel` da AX-50 repetida em dois segmentos alinhados: 9,90 studs contra 5,05 originais; ponto de disparo e montagem do supressor movem-se para a nova ponta. Stats: dispersão e recuo visual −25%, alcance/falloff +25%, velocidade ADS −10% e movimento −6%. A dispersão base da AX-50 passou de 0° para 0,2° para que o bônus de precisão tenha efeito mensurável. Play confirmou configuração conjunta com Colossus, montagem e multiplicadores; combinação: alcance +43,8%, bala +22,5%, ADS −19%, movimento −13,5%. O asset reaproveita geometria importada e permanece `publicationBlocked=true`; experiência não publicada. Studio deixado em Play, como encontrado.

**Zoom de snipers — 31/10/2026:** ampliado o ADS da sniper legada e de todas as entradas SNIPER RIFLES do catálogo, incluindo AX-50, Dragunov, HDR e Rytec AMR. Dois níveis ópticos de 4×/8× calculados pela projeção da câmera (FOV 70° resulta em 19,86°/10,00°). Alternância por Z, DPadLeft e botão visível durante ADS; comando integrado ao roteador/remapeamento existente. Volta ao primeiro nível ao sair de ADS, trocar arma ou bloquear o combate. Fontes preparadas em cópia isolada e incorporadas ao Studio principal em Edit, com comparação das fontes antes do merge e backup em `ServerStorage.Development.Revisions.SniperZoomBaseline_20261031`. Verificados classificação, ampliação em quatro FOVs, preservação do ADS de armas comuns, bloqueio por menu e compilação de módulos; `git diff --check` passou. Avaliação visual e acionamento físico em partida ainda pendentes; nenhum Play ou publicação nesta etapa.

**Dano MW e rajadas — 31/10/2026:** dano inicial e mínimo reduzidos em 50% para as 25 armas MW marcadas como automáticas; armas legadas e semiautomáticas preservadas. Implementado módulo BurstFire, sequenciamento no cliente e controle de intervalo/pausa no servidor. FR 5.56 com três tiros por acionamento, AN-94 com dois; AUG automática por padrão e conversão funcional de três tiros no slot fireControl do Gunsmith. A conversão não inventa modelo físico e é uma exceção funcional à regra anterior de acessórios só visuais. Rajada termina mesmo após soltar o gatilho, mas é cancelada por troca, recarga ou bloqueio do combate. Validação de configuração/conversão e intervalo/pausa passou; conferência local confirmou exatamente 25 reduções de Damage/MinDamage. Foi necessário ajustar tolerância de chegada dos pacotes sem acumular ganho de cadência. Testes de disparo com entradas nativas tiveram interferência de foco/respawns; validação extensa com controle físico, latência e poucos cartuchos permanece pendente. Usuário interrompeu Computer Use por Esc; nenhuma nova entrada por esse mecanismo será feita. Play foi deixado para avaliação manual. Backup `ServerStorage.Development.Revisions.MWBurstBaseline_20261031`; sem publicação pelo agente.

**Arsenal importado e Gunsmith — 31/10/2026:** 13 imports retirados do Workspace e preservados em `ServerStorage.ImportedArsenalOriginals`, com prioridade MW sobre duplicatas externas. Catálogo, registro de assets, configurações visuais, estatísticas e Gunsmith integrados à cascata existente. Cinco presets nomeáveis de CTF com primária/secundária independentes, aplicação no nascimento seguinte e corpo a corpo do kit legado preservado; presets visuais independentes e validação no servidor. Três acessórios da M4A1 montáveis; outros itens têm prévia e montagem não verificada. Testados inicialmente M4A1/1911 em jogo, troca, respawn e disparos aceitos; fluxo de UI aplicou os três acessórios e salvou visual sem recriar câmera. Na reabertura da versão 374, alterações paralelas já conectavam 48 armas MW ao combate: preservadas, com **48 criações/adaptações sem erro e dez contratos aprovados**. Isso não valida grips/clipping/animações individuais das 48. Estatísticas e núcleo de combate não foram rebalanceados por esta migração; a expansão de definições veio do trabalho paralelo. Persistência em DataStore está implementada, mas só o estado StudioSessionOnly foi exercitado. **PC/controle têm prioridade; mobile ficou em prioridade mínima por instrução posterior do usuário.** Assets importados seguem `publicationBlocked=true`, até confirmação de direitos. Backup de fontes em `ArsenalBaseline_20261031` e `ArsenalMeleeCompatibility_20261031`. [Inventário, resultados e pendências](docs/ARSENAL-GUNSMITH-2026-10-31.md).

**Sincronização e prioridade — 31/10/2026:** o espelho local de KitDefinitions foi alinhado às definições já carregadas no Studio (versão 374), sem alterar seus valores; cópia anterior e snapshot preservados em `artifacts/arsenal-2026-10-31/`. O Studio foi deixado em Edit, sem exposição temporária de armas no Workspace. Simulação de celular encerrada e viewport padrão restaurado. Nenhuma publicação ou operação de salvamento na nuvem pelo agente nesta etapa.

**Catálogo de armas — ARs jogáveis — 31/10/2026:** as 12 entradas de fuzis de assalto que ainda estavam em `PreviewOnly` agora recebem `VisualAdapter` e `combatId="Rifle"`, seguindo o padrão já aplicado à M4A1. Verificação estática do `WeaponCatalog.luau` sem erros; não houve Play no Studio nem validação de loadout em execução nesta etapa específica anterior à validação de integração registrada acima.

**Colossus Suppressor — 31/10/2026:** criado para a AX-50, com malha do Monolithic escalada 2×, +15% em alcance/falloff, +22,5% em velocidade de projétil, −10% na transição de ADS e −8% na velocidade de caminhada/corrida. Como a AX-50 era hitscan, foi ligada à simulação autoritativa de projéteis existente (velocidade-base 3000) para o bônus de bala afetar o impacto. Play no Studio confirmou validação do loadout, estatísticas efetivas e montagem com dimensão exatamente 2×; compatibilidade/perfis de movimento foram integrados em CTF, Arena e saída do slide. Studio permaneceu em Play; experiência não publicada. O console contém avisos preexistentes/não investigados nesta etapa de assets sem permissão/arquivados, plugin GUIEditor e espera de `Standings`.

**Acessórios da AX-50 — 31/10/2026:** edição feita diretamente no `Crossgrounds (ALPHA)` pelo MCP. Slots `optic`, `muzzle` e `underbarrel` habilitados; mira G.I Mini Reflex, supressor Monolithic e foregrip Commando compatíveis, com pontos de montagem visuais próprios e ocultação da luneta original ao substituir a óptica. Play local confirmou `WeaponVisualConfiguration.Validate` e `ImportedWeaponVisuals.Build` para os três acessórios; compatibilidade existente da M4A1 preservada. Studio retornou ao modo Edit. Os demais acessórios seguem em prévia; a experiência não foi publicada.

**Aim Assist e medidor — 31/10/2026:** investigação com controle físico confirmou desaceleração existente e identificou que o ajuste solicitado era uma leve atração. Implementada preferência independente **Atração suave ao alvo**, padrão 65%, com aquisição gradual, saída manual e distância própria até 300 studs. A atração ajuda a entrar na borda do alvo e zera quando a mira já está dentro da região ou um raycast confirma acerto em uma parte real, incluindo a cabeça; não força o peito. Corrigidas também a penalização do acompanhamento com analógico forte, a segunda zona morta nas microcorreções e as curvas de distância. Medidor numérico em studs abaixo da mira, mantendo a faixa de dano em ADS. Cinco fontes incorporadas ao principal, backup `AimAssistCenteringBaseline_20261031`; **39 contratos passaram novamente em novo Play**, três cenários com geometria/raycasts reais preservaram cabeça/tronco e puxaram apenas de fora. Usuário aprovou a força antes do refinamento final de preservação; conforto prolongado dessa última trajetória, toque físico, multiplayer humano e persistência publicada seguem pendentes. Sem publicação ou salvamento em nuvem pelo agente; novo Play deixado aberto com as fontes incorporadas. [Resultados e limites](docs/AIM-ASSIST-AJUSTE-FINO-2026-10-31.md).

**Persistência do porte — conferência posterior em 28/10/2026:** o usuário reabriu Crossgrounds (ALPHA) pela tela inicial. Confirmados Place ID 4375993208, universo 1404405130, versão 343, igualdade integral das 19 fontes do porte, duas Tools, dois viewmodels e prévias. Nenhuma recuperação foi necessária. Confirmação feita na experiência reaberta, sem alterar ou publicar o place; a versão em execução nos servidores públicos não foi consultada. [Evidência e contexto](docs/BLASTERS-E-AIM-ASSIST-2026-10-28.md).

**Blaster, AutoBlaster e Aim Assist — 28/10/2026:** porte das duas armas incorporado ao principal após teste em cópia: modelos e rigs originais, animações FP/TP, sons por marcadores, recuo de câmera, laser/impactos e hitscan de raio 0,4. Duas opções adicionais de loadout em CTF/Arena, com munição/reserva e dano autoritativos. Assistência corrigida para PracticeDummy no lobby, registro explícito de alvos, eventos espaçados de toque e frames lentos; seleção/acompanhamento conferidos na câmera real com input simulado. **50 contratos aprovados**; mouse nativo confirmou semiautomático, rajada 30 → 23 e R recarregou para 30/173. Erro de carga parcial de animação TP corrigido e repetido sem erro dos novos controladores. Merge de 19 fontes e 152 nós, com backup em `ServerStorage.Development.Revisions.BlastersPortBaseline_20261028`. Injeções e configuração de QA ficaram na cópia. Controle físico, multitoque real, multiplayer humano, R6 e equilíbrio continuam pendentes; nenhuma publicação. [Relatório e limites](docs/BLASTERS-E-AIM-ASSIST-2026-10-28.md).

**Assistência e gráficos — 27/10/2026:** porte integrado em sete fontes do principal após teste em cópia: Friction independente, intenção por dispositivo, expiração de toque de 100 ms, bloqueio após perder foco e limpeza de Tracking ao soltar. Opções → Gráficos contém Desempenho, Equilibrado (padrão), Alto e Visual; profundidade de campo restrita à fotografia Visual. **24 contratos aprovados**, sete fontes compiladas, troca dos quatro perfis via preferências e tela conferida por input/captura. Iluminação base dos mapas preservada. Backup: `ServerStorage.Development.Revisions.ProjectilePortBaseline_20261027`. Sem publicação, teste físico/multitoque, benchmark ou persistência após reconexão publicada. A instrução posterior de aguardar chegou após o merge; novas alterações no principal foram interrompidas. [Resultados e limites](docs/PORTE-PROJECTILE-TEST-2026-10-27.md).

**Atualização em 26/10/2026:** Travessia Ampliada montada e selecionada no Studio: 940 × 560 studs, três rotas a 180 studs de distância e bandeiras separadas por 720 studs; a versão anterior foi preservada. Textos das bandeiras restritos localmente aos participantes na região e com rodada ativa. Modo admin de câmera livre instalado para a conta 1248190494. Compilação, regras isoladas, clearance e navegação geométrica verificados; Play e equilíbrio humano desta versão ainda pendentes, pois o usuário estava editando os spawns da Arena. [Mapa, assets e limites](docs/CTF-WIDE-MAP.md) · [Comandos admin](docs/ADMIN-CAMERA.md). A votação em grid de quadrados foi registrada para uma etapa futura.

**Data:** 23/10/2026  
**Experiência:** Crossgrounds (ALPHA)  
**Place ID:** `4375993208`  
**Workspace:** `C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio`

**Controle — ajuste posterior em 23/10:** indicador lateral fora do texto, foco arredondado com contorno/brilho maiores e som curto de navegação com volume independente em Áudio. D-pad, A, deslocamento lógico pelo analógico e mute verificados com input simulado. 128 fontes compiladas. [Resultados e pacote cumulativo](docs/CONTROLE-CURSOR-FOCO-SOM.md).

**Cascatas — ajuste visual posterior em 23/10:** painéis sólidos, 8 px de separação e sombra progressiva no fundo das seções anteriores. Perfil e opções com quatro níveis verificados por captura e clique. 128 fontes compiladas. [Resultados e incremental](docs/CASCATAS-SOLIDAS.md).

**Aim assist — atualização posterior em 23/10:** assistência dividida em desaceleração e acompanhamento parcial de movimento, sem centralizar no tronco. Rotação reduzida até zerar a 100 studs; desaceleração reduzida até 150. Ajustes independentes, aquisição gradual, saída manual e checagem imediata de visibilidade. **16 contratos aprovados**, integração com input simulado e câmera normal; 128 fontes compiladas. Calibração com hardware/humanos e toque real pendente. [Pesquisa, evidências e pacote](docs/AIM-ASSIST-COMPONENTES.md).

**Lobby, playlist e progresso — atualização mais recente em 23/10:** blur por profundidade (0/18), modos jogáveis no topo em verde, gerenciador de playlist com duas músicas adicionais, bots com 50 XP e treino com 10 XP. Tabelas de perfil/placar reorganizadas; amigos sem registro anterior excluídos do comparativo. **128 fontes compiladas; 7 contratos relevantes aprovados nesta etapa.** Amigos offline, persistência publicada, aparelhos reais e instalação remota permanecem sem validação. [Resultados e pacote cumulativo](docs/LOBBY-PLAYLIST-XP-ESTATISTICAS.md).

**UI — atualização posterior em 23/10:** corrigida cascata coberta pelo próprio fundo (Global → Sibling), confirmada por captura e sobreposição. Tela inicial, kits, progresso e votação usam cascata compartilhada, tema acrílico temporário e ação explícita **Permanecer no lobby**. Estado atual: **122 fontes locais compiladas**; 84 contratos existentes aprovados durante a tarefa. Os pacotes completos da etapa anterior precisam do novo incremental de UI. [Relatório, pacote e limites](docs/UI-CASCATA-ACRILICO.md).

**Etapa anterior:** menu em listas empilhadas, loadout pendente, corrida automática opcional no toque e editor de HUD acessível. Arena com 300 s, intervalo de 1 s, recarga de 900 ms e seis visuais de pistola. Exibidor separado, braços quadrados com skin/iluminação local e classificação no topo. Recuperação de equipamento e bots menos precisos. Os oito bugs do relato de 23/10 receberam correções; Dust tem 53 pontos elegíveis para jogadores e três reservados ao treino. **119 fontes locais e 84 contratos aprovados**. Progresso e lobby recentes preservados. Hardware, PvP humano, latência, publicação e instalação remota da Arena continuam pendentes. [Resultados, pacotes e limites](docs/MENU-LOADOUT-VIEWMODEL-ARENA.md).

## 1. Resumo

O projeto está em uma fase de **protótipo funcional com apresentação e conteúdo ainda incompletos**. Existe uma partida de captura de bandeira, com kits, jogadores e bots, lobby jogável, câmera própria, HUD e menus adaptados para controle. Isso ainda não representa uma experiência visualmente finalizada ou validada em todas as plataformas.

As maiores lacunas atuais são:

1. **Empunhadura das armas:** apoio procedural de duas mãos implementado em R15 para armas de fogo e machado; faltam mira vertical do corpo/arma, animações completas e validação ampla de avatares.
2. **Animações de combate:** faltam poses e sequências próprias de equipar, mirar, disparar, recarregar e atacar com cada arma.
3. **Apresentação em primeira pessoa:** o modelo dedicado existe, mas usa peças rígidas e movimentos procedurais simples.
4. **Bots:** possuem lógica de objetivos e combate, porém ainda têm percepção, movimentação e comportamento visual pouco naturais.
5. **Áudio:** tiros, recarga, hit marker e música existem; a sonorização completa de interface, objetivos e ações ainda não existe.
6. **Mapa e votação:** CTF permanece com Travessia e navegação de bots específica desse cenário. O catálogo real da Arena inclui seis templates, com House preservado como encontrado; não possui bots próprios. Há mapas de Get Out preparados, mas ainda faltam regras e objetivos do modo.
7. **Acessibilidade:** houve avanço na navegação por controle, mas faltam opções adicionais e validação com controles físicos e teclado virtual de console.

### Como interpretar este documento

- **Implementado:** recurso encontrado no código ou nas instâncias atuais. Não significa acabamento final nem validação em produção.
- **Parcial:** existe uma base funcional, mas falta parte da implementação, do conteúdo ou da apresentação.
- **Ausência confirmada:** a implementação correspondente não foi encontrada nos sistemas examinados.
- **Validação pendente:** há implementação, mas o comportamento ainda precisa ser confirmado na condição indicada.
- **Melhoria proposta:** sugestão de evolução; não é tratada como promessa anterior ou defeito comprovado.

A avaliação inicial foi feita por leitura de fontes e instâncias. Os patches seguintes incluíram Play no Studio. A etapa atual verificou o defeito de armas, câmera obrigatória, Factory/respawn, disparo pelo fluxo mobile, editor de HUD, entrada numérica e assistência no cliente com entrada simulada. São 78 contratos aprovados. Os limites estão no relatório vinculado acima; não incluem analógicos físicos, multitoque real, PvP com múltiplos humanos ou publicação.

## 2. O que já existe

| Sistema | Estado | Entrega atual |
|---|---|---|
| Captura de bandeira | Implementado | Captura, transporte, queda, recuperação, entrega e atualização de placar. |
| Equipes | Implementado | Azul e vermelho; bots completam a falta de jogadores até 6 participantes por lado. |
| Partida | Implementado | Rodadas de 5 minutos, 3 capturas para vencer e preparação de 8 segundos. |
| Spawns | Implementado | 24 pontos por equipe, escolha por segurança/ocupação e proteção temporária. |
| Lobby | Implementado, com acabamento parcial | Área jogável, alvos de treino, percurso de saltos, escolha de kit e retorno da partida. |
| Kits | Implementado | Leve, regular e pesado, com velocidades e saltos diferentes. |
| Combate | Implementado, com apresentação parcial | CTF com 200 HP; Arena com 20 HP. Munição, recarga, cadência, queda de dano e melee durante janela de ataque. |
| Equipamentos próprios | Parcial | HUD e seleção próprios; os equipamentos ainda são instâncias `Tool` do Roblox. |
| Câmera | Implementado, com refinamentos pendentes | Arena exclusivamente em primeira pessoa. Armas de fogo sempre travadas; CTF preserva câmera por ombro e preferências nos contextos permitidos. |
| Recuo | Implementado em primeira pessoa | Movimento visual da arma, mais intenso no fuzil e na sniper, sem desviar a câmera. |
| Corrida | Implementado | Alternada, cerca de 10,5 s por carga cheia, com FOV suave e balanço procedural mais lento/amplo. |
| HUD | Implementado, com acabamento parcial | Vida, estamina, munição, slots, objetivo, placar, hit marker, eliminações e killfeed. |
| XP da Arena | Implementado apenas na sessão | 100 por eliminação PvP, +50 por headshot; treino sem recompensa. Sem níveis ou persistência permanente. |
| Menus | Implementado, com acabamento parcial | Catálogo com entrada local direta, ajustes por categoria, editor de HUD mobile, kits, votação e remapeamento. |
| Controle | Implementado; validação física pendente | Cursor próprio nos menus, D-pad, ícones por plataforma e remapeamento. |
| Analógicos e mira assistida | Implementados; hardware/toque pendentes | Zonas mortas 5%/10%, curva S ajustável, assistência com desaceleração/correção e bloqueio por paredes. Sensibilidade até 4×. |
| Votação de mapas | Implementado para testes; conteúdo parcial | Travessia no CTF; Shipment, Dust, Factory, Pátio, Posto e House no catálogo atual da Arena. House não foi explorado neste patch. |
| Preferências | Implementado; produção pendente | Persistência por DataStore fora do Studio; sessão temporária nos testes locais. |
| Chat | Configurado | `TextChatService.ChatVersion` está em `TextChatService`. |

## 3. Armas, empunhadura e animações

### 3.1 Empunhadura com duas mãos — base implementada, acabamento parcial

**Implementado e testado em R15:** WeaponRig, ArmPose e WeaponPose posicionam as mãos nas pegadas de SMG, fuzil, sniper e machado. A pose é calculada após o Animator, com suporte a Motor6D e AnimationConstraint, inclusive em bots cuja aparência troca as juntas. Faca e espada mantêm a montagem da mão direita.

Limitações restantes:

- A mão acompanha as pegadas; a mira vertical do tronco/arma continua pendente.
- Poses procedurais não substituem animações completas de combate.
- R6 possui uma aproximação ainda não validada neste patch.
- Avatares e acessórios extremos precisam de avaliação de alcance, encaixe e interseções.

Em primeira pessoa há braços quadrados com cores da skin e camisa clássica, renderizados em ViewportFrame independente. Recarga move apoio, carregador e mecanismo; roupas em camadas e animações completas de equipar continuam pendentes. Terceira pessoa usa a pose separada existente.

**Próxima entrega sugerida:** camada de mira vertical e animações sincronizadas de combate, compatíveis com os diferentes avatares.

### 3.2 Animações de combate — ausentes como conjunto próprio

O combate ainda não possui um conjunto dedicado e completo de animações para:

- Equipar e guardar cada equipamento.
- Permanecer parado, andar e correr segurando a arma corretamente.
- Entrar/sair da mira e acompanhar a inclinação vertical da pontaria.
- Disparar em terceira pessoa com resposta visível do corpo e da arma.
- Recarregar: retirar/inserir carregador, operar mecanismo e mover as mãos.
- Executar golpes distintos de faca, Executor e Treme-Terra.

O melee altera `Tool.Grip` por código. Em primeira pessoa há arco de ataque e recargas procedurais com peças móveis; o Magnum abre o tambor. Esses movimentos ainda não equivalem a um conjunto completo de animações artísticas, sobretudo em terceira pessoa.

**Limitação concreta de sincronização:** o golpe visual em primeira pessoa usa duração fixa de aproximadamente `0,42 s`, enquanto preparação e janela de dano variam entre as armas. É necessário sincronizar gesto, contato e som com os parâmetros reais de cada equipamento.

### 3.3 Modelos e primeira pessoa — parciais

Os modelos foram retrabalhados por código com corpo, carregador, trilhos, cano, coronha e luneta da sniper. A versão 3 acrescenta chanfros, miras, mecanismos, parafusos e detalhes nas pistolas e melees; luvas recebem peças arredondadas. Os nomes Kastov 545, Vasnev 9mm e Lachmann LMS estão aplicados. O visual permanece geométrico e provisório, sem meshes/texturas próprios ou acabamento final.

Faltam ou precisam de retrabalho:

- Modelos finais, proporções, materiais e detalhes consistentes entre as seis armas.
- Braços articulados de primeira pessoa e animações independentes por ação.
- Alinhamento de miras: mirar atualmente ajusta o FOV; não há um sistema completo de alinhamento com alça/massa de mira ou visão dedicada da luneta.
- Acabamento e sincronização completa do disparo local. Clarões já foram implementados e verificados no viewmodel; permanecem pendentes animações completas e validação dos efeitos sob latência/aparelhos variados.
- Efeitos finais de impacto por material e outros detalhes de disparo. Hoje há traçadores simples e luz de disparo no equipamento real.

**Validação pendente:** enquadramento perto de paredes, transições de perspectiva, interseção dos braços/arma e percepção do recuo em telas e FOVs diferentes.

### 3.4 Sistema de equipamentos — migração parcial

A mochila padrão está oculta e há seleção/HUD próprios, porém `WeaponFactory` ainda cria `Tool`, `KitService` coloca os itens na `Backpack` e o equipamento usa `Humanoid:EquipTool`.

Portanto, **não foi concluída uma substituição integral do sistema de itens do Roblox**. A interface e parte da apresentação são próprias, mas a estrutura de equipamentos ainda usa os mecanismos nativos.

Antes de uma migração completa, é necessário definir o modelo de estado de equipamento, representação no servidor, apresentação local, troca de armas e integração com as animações. A migração não deve ser considerada concluída apenas por esconder a mochila padrão.

## 4. Bots e inteligência artificial

### 4.1 Implementado

- Preenchimento das duas equipes e substituição após morte, com intervalo de 7–9 segundos.
- Papéis de corredor, soldado e guardião, com armas diferentes.
- Captura, retorno, recuperação de bandeira, interceptação, escolta e defesa.
- Reação com atraso, rajadas, dispersão, carregadores e tempo de recarga.
- Busca de cobertura quando a vida está baixa e deslocamento lateral em combate.
- Pathfinding, saltos e tentativas de sair de situações de travamento.
- Aparências de amigos dos jogadores quando disponíveis, com alternativa aleatória.

### 4.2 Animação básica presente; combate visual incompleto

O template atual contém **um `Animator`, 27 instâncias `Animation` e um Script `Animate` habilitado**. Há animações básicas e emotes do Roblox. A reprodução correta com todas as aparências não foi verificada novamente nesta exportação.

Assim, a pendência não deve ser descrita simplesmente como “nenhum recurso de animação existe”. O que falta é principalmente:

- Refinamento das poses e do apoio procedural de duas mãos já implementado.
- Animação de mira, disparo e recarga sincronizada com o cérebro do bot.
- Transições naturais entre patrulhar, correr, buscar cobertura e enfrentar o alvo.
- Orientação visual de cabeça, tronco e braços coerente com a pontaria.

Hoje a orientação de combate gira a raiz do personagem diretamente no plano horizontal. O disparo e o traçador dos bots usam a boca real da arma, com verificação de cobertura. A orientação vertical do corpo/arma ainda precisa acompanhar a pontaria.

### 4.3 Limitações da tomada de decisão

**Confirmadas pela implementação atual:**

- Percepção restringe alvos muito atrás, com exceção para proximidade/alerta após dano. A visão periférica ainda é ampla e exige ajuste com humanos.
- Memória curta e investigação existem, mas não há percepção completa por som ou busca coordenada.
- Papéis definidos pelo número do slot. Quando jogadores entram e bots são removidos, não há recomposição tática dos papéis restantes.
- Rotas, escolta e cobertura são regras simples; não há coordenação de esquadrão ou distribuição dinâmica de ameaças.
- A recarga repõe o carregador sem consumir uma reserva finita equivalente à dos jogadores.
- Não há integração própria de som/animação de recarga no cérebro dos bots.
- A recuperação de travamentos pode mudar a rota, saltar e, em determinadas condições, reposicionar o bot. Isso pode produzir movimentação artificial.

**Validação pendente:** dificuldade contra humanos, previsibilidade, uso real das três rotas, travamentos prolongados e custo de processamento com a partida completa.

### 4.4 Novos mapas ainda exigem adaptação dos bots

O catálogo de mapas existe, mas a IA não está completamente independente do cenário atual. `BotBrain` usa coordenadas fixas como `X = ±32/±42`, altura `Y = 41` e rotas em `Z = -70/0/70`, além de posições de defesa baseadas na orientação atual das equipes.

**Impacto:** cadastrar um novo mapa na votação não garante que os bots consigam jogá-lo corretamente. As rotas precisam virar dados do próprio mapa ou ser substituídas por uma navegação de objetivos que não dependa dessas coordenadas.

## 5. Sons e música

### 5.1 O que existe

- Sons de disparo associados às três armas de fogo.
- Sons de ataque melee; faca e espada compartilham um dos assets.
- Um som de recarga compartilhado entre as armas de fogo.
- Som de hit marker confirmado no cliente.
- Música de lobby/menu com ajuste de volume e transição para a arena.

### 5.2 O que falta

**Ausências nos sistemas examinados:**

- Sons próprios para foco, navegação, confirmação, voltar e erro nos menus.
- Sonorização dedicada de equipar/guardar, carregador vazio e etapas de recarga.
- Sons próprios de impacto e contato diferenciados por arma/material.
- Alertas sonoros próprios de bandeira roubada, recuperada, entregue e de início/fim de rodada.
- Sistema próprio de passos por superfície e ambientação do mapa. Sons padrão do personagem, quando presentes, não constituem esse sistema.
- Integração de recarga sonora dos bots e mixagem final das várias fontes de combate.

**Validação pendente:** carregamento/permissões de todos os assets na experiência publicada, volumes relativos, distância audível e comportamento com vários jogadores e bots atirando.

**Melhoria proposta:** canais separados de volume para música, efeitos, interface e ambiente. Atualmente o menu oferece volume da música, sem um painel completo de mixagem.

## 6. Menu, HUD, lobby e acessibilidade

### 6.1 Base funcional entregue

O menu não está ausente: há escolha simplificada de kit, entrada na partida, Ajustes acessível a partir da seleção inicial, votação, remapeamento e retorno ao lobby. O lobby também já é jogável; a preparação não se resume a prender o jogador em uma tela por 30 segundos.

Há cursor próprio nos menus, navegação por D-pad, rolagem, campos numéricos, sliders, prazo de 5 segundos para remapear e restauração de padrões. Os ícones usam a plataforma do controle conectado.

### 6.2 Acabamento e recursos ainda parciais

- A interface é construída por código com painéis e componentes básicos; identidade visual e acabamento final ainda precisam de revisão.
- Faltam os sons de navegação e confirmação mencionados na seção de áudio.
- A seleção de mapa mostra essencialmente nome e votos; faltam apresentação visual dos mapas e refinamento do feedback de escolha/resultado.
- Falhas de carregamento/salvamento de preferências não possuem uma comunicação completa de erro e recuperação para o jogador.
- O fluxo de resultados ainda é básico; uma apresentação detalhada de desempenho de fim de partida não faz parte da entrega atual.
- Em celular, a área útil reduzida faz o menu exibir poucos ajustes por vez. A rolagem funciona, mas conforto de toque e legibilidade ainda exigem avaliação em aparelho real.

A seleção de kit com texto e nomes das armas foi uma escolha solicitada. A ausência de uma prévia 3D nessa seleção, por si só, não é registrada como falha.

### 6.3 Acessibilidade ainda incompleta

**Opções ainda ausentes:**

- Inverter eixo vertical e ajustar sensibilidade por eixo/dispositivo.
- Ajustar sensibilidade por eixo e ampliar a validação dos filtros existentes; zonas mortas e curva S já são configuráveis.
- Ajustar tamanho do cursor dos menus, texto e contraste por preferência do jogador.
- Modos alternativos de cores/identificação de equipes.
- Desativar completamente o flash de dano: o ajuste atual tem mínimo maior que zero.
- Reduzir/desativar o recuo visual e a expansão de FOV da corrida para conforto de movimento.

**Melhoria proposta:** feedback háptico configurável. Assistência de mira opcional já está implementada; equilíbrio e hardware físico continuam pendentes.

**Limites intencionais do remapeamento atual:** confirmar/voltar e navegação nos menus permanecem fixos para preservar o acesso às configurações. Analógicos, WASD e comandos do sistema Roblox não fazem parte do remapeamento de ações.

### 6.4 Controles padrão atuais

| Ação | Xbox | PlayStation | PC |
|---|---|---|---|
| Alternar corrida | LS | L3 | Ctrl |
| Trocar câmera | RS | R3 | V |
| Trocar arma | Y | Triângulo | G |
| Shift Lock | LB | L1 | Shift |
| Recarga / interação | X | Quadrado | R |
| Trocar ombro | RB | R1 | Q |
| Atacar | RT | R2 | Mouse 1 |
| Mirar | LT | L2 | Mouse 2 |
| Ajustes | D-pad direito | D-pad direito | F2 |

X/Quadrado prioriza recarga quando ela é possível; com o equipamento pronto, pode interagir com um prompt próximo. O cursor nativo do gamepad é suprimido no jogo; a mira própria permanece, e os menus usam o cursor dedicado.

## 7. Mapa, spawns e votação

### Entregue

- Travessia, com três rotas, conexões e coberturas adicionadas ao cenário existente.
- Base azul no lado de Blue Building e base vermelha no lado do Noob.
- Bandeiras, pontos de spawn amplos e lobby separado.
- Catálogo em `ServerStorage.CTFMaps` e votação durante a preparação.

### Incompleto ou pendente

- **Somente um mapa está cadastrado:** `riverside`, com o nome Travessia. A votação está preparada tecnicamente, mas ainda não oferece variedade real de conteúdo.
- A existência das três rotas não comprova equilíbrio de fluxo, linhas de tiro, vantagem de altura ou resistência a pressão sobre o spawn.
- Acabamento visual, continuidade entre estruturas antigas e novas, ambientação e leitura dos acessos ainda precisam de uma revisão de cenário.
- Spawns precisam de testes com equipes humanas completas, ocupação simultânea e inimigos pressionando as bases.
- Novos mapas exigem a adaptação da navegação dos bots descrita na seção 4.4.

Os testes anteriores de pathfinding e captura validaram caminhos e interações pontuais; não substituem sessões de equilíbrio do mapa com jogadores.

## 8. Balanceamento atual

Combatentes do CTF têm 200 HP; Arena tem 20 HP. Na Arena, pistolas usam intervalo de 1 s, 12/120 de munição e recarga de 0,9 s. A tabela abaixo descreve os kits CTF, **não uma confirmação de equilíbrio competitivo**.

| Kit | Melee: dano / intervalo | Arma de fogo: dano próximo → distante | Intervalo do tiro | Carregador | Andar / correr / salto |
|---|---|---|---|---|---|
| Leve | Faca: 26 / 0,32 s | Vasnev 9mm: 19 → 11 | 0,13 s, automática | 32 | 22 / 29 / 9 |
| Regular | Executor: 65 / 0,70 s | Kastov 545: 29 → 20 | 0,20 s, automático | 26 | 18 / 25 / 7,2 |
| Pesado | Treme-Terra: 110 / 1,50 s, área | Lachmann LMS: 150 → 125 | 2,00 s | 5 | 14 / 20 / 5,5 |

Andar/correr e salto são os valores configurados de movimento dos jogadores. Bots usam velocidades e salto definidos separadamente por papel.

Ainda é necessário avaliar:

- Tempo para eliminar e vantagem de cada kit nas distâncias reais do mapa.
- Impacto do headshot de jogadores, que multiplica o dano de arma de fogo por 1,35.
- Capacidade de eliminação do pesado em relação à sua mobilidade e cadência.
- Alcance percebido do melee e concordância entre lâmina visível e contato válido.
- Dificuldade dos bots, precisão e diferença de recursos em relação aos humanos.
- Sensação do disparo sob latência. O recuo visual atualmente começa após a confirmação do servidor; atraso perceptível é um risco a testar, não uma falha de rede reproduzida nesta exportação.

## 9. Validação: o que já foi registrado e o que falta

### Registrado nos patches anteriores

- Sintaxe dos scripts alterados sem erros.
- Captura/entrega de bandeira, placar, respawns e preenchimento por bots.
- Disparos automáticos, consumo de munição, recarga e dano melee por janela de ataque.
- Navegação dos menus por controle, remapeamento com conflito, tempo esgotado e restauração dos padrões.
- Correção de valores digitados de FOV para os limites de 60–110 graus.
- FOV de corrida e recuo visual com retorno ao repouso sem mudar a direção da câmera.
- Prioridade de recarga/interação e entrada nos Ajustes a partir da seleção de kit.
- Ícones PlayStation confirmados no simulador de PS5 e layouts inspecionados em console e iPhone em paisagem.
- Troca entre mapas em Play usando uma cópia temporária de teste; essa cópia não foi mantida no catálogo.

### Ainda não atestado

- Partida longa com vários clientes humanos, entradas/saídas e duas equipes completas.
- Controle físico Xbox e PlayStation, incluindo troca entre mouse/controle e teclado virtual do console.
- Persistência de configurações após sair e entrar em servidores publicados.
- Reprodução e encaixe das animações em diferentes avatares e aparências de amigos.
- Carregamento de todos os sons no jogo publicado.
- Desempenho de CPU, rede e renderização em aparelhos modestos, com combate simultâneo.
- Comportamento sob latência, perda de conexão e falhas dos serviços externos.

O último patch registrou ausência de erros dos sistemas alterados no seu teste final, mas há erros anteriores de um plugin externo GUIEditor. Isso não equivale a uma garantia de ausência de bugs na experiência.

## 10. Ordem sugerida para os próximos patches

As prioridades abaixo são uma avaliação de desenvolvimento, sem estimativa de prazo.

| Prioridade | Entrega | Critério de conclusão |
|---|---|---|
| P1 | Completar poses de armas | Apoio de duas mãos já implementado; faltam mira vertical e validação ampla de avatares/jogadores/bots. |
| P1 | Animações de combate | Equipar, mirar, atirar, recarregar e melee com mãos/arma sincronizadas aos eventos reais. |
| P1 | Validação de controle físico | Percorrer todos os fluxos de menu e combate em Xbox/PlayStation, incluindo edição e remapeamento. |
| P1 | Calibrar Aim Assist em hardware | Refinamento integrado; contratos e simulação aprovados. Controle físico e multitoque real pendentes. Ver `docs/PORTE-PROJECTILE-TEST-2026-10-27.md`. |
| P2 | Medir modos gráficos | Quatro perfis integrados, Equilibrado como padrão. Troca e menu conferidos em Play; ganho de FPS/memória e hardware modestos ainda sem medição. |
| P1, antes do segundo mapa | Navegação de bots por dados do mapa | Novo cenário jogável sem depender das coordenadas fixas de Travessia. |
| P2 | Refinar percepção e movimento dos bots | Menos giros/travamentos artificiais, busca após perder alvo e melhor distribuição de papéis. |
| P2 | Completar áudio e efeitos | Interface, objetivos, recarga, impactos e efeitos locais de primeira pessoa consistentes. |
| P2 | Ampliar acessibilidade | Opções de conforto visual, analógicos, leitura da UI e volumes separados. |
| P2 | Acabamento de cenário e UI | Direção visual consistente, acessos legíveis, votação apresentada e fluxos revisados em telas menores. |
| P2 | Sessões de equilíbrio e desempenho | Resultados registrados de partidas humanas e aparelhos/condições de rede diferentes. |

## 11. Fontes, recuperação e publicação

### Fontes principais desta avaliação

| Tema | Fonte |
|---|---|
| Modelos, empunhadura e `Tool` | [WeaponFactory.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/ServerScriptService/MainGameScript/GameManager/WeaponFactory.luau) |
| Disparo, melee e recarga | [KitService.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/ServerScriptService/MainGameScript/GameManager/KitService.luau) |
| Primeira pessoa, mira e recuo | [CombatPresentation.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/StarterPlayer/StarterPlayerScripts/CombatPresentation.luau) |
| Decisões e rotas dos bots | [BotBrain.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/ServerScriptService/MainGameScript/GameManager/BotBrain.luau) |
| Equipes de bots e aparências | `BotManager.luau`, `AvatarService.luau` e template `ServerStorage.CTFBotTemplate` inspecionado no Studio. |
| Ajustes e limites | [ExperienceSettings.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/ReplicatedStorage/ExperienceSettings.luau) |
| UI, controles e persistência | `ExperienceMenu.luau`, `MenuNavigation.luau`, `ControlRouter.luau`, `InputIcons.luau` e `SettingsService.luau`. |
| Balanceamento e sons de armas | [KitDefinitions.luau](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/src/ReplicatedStorage/KitDefinitions.luau) |
| Testes já registrados | [ACCESSIBILITY-PATCH-NOTES.md](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/ACCESSIBILITY-PATCH-NOTES.md), [CAMERA-PATCH-NOTES.md](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/CAMERA-PATCH-NOTES.md) e [PATCH-NOTES.md](C:/Users/Kauziin/Documents/ChatGPT/RobloxStudio/PATCH-NOTES.md). |

As notas antigas descrevem estados intermediários. Para controles e cursor, prevalecem o patch de acessibilidade e as fontes atuais.

### Pacotes locais

| Arquivo | Tamanho | Estado representado |
|---|---|---|
| `artifacts/crossgrounds-hub-arena-mobile-2026-10-23.rbxm` | 169236 bytes | Hub dedicado atualizado; instalação e publicação remotas pendentes. |
| `artifacts/crossgrounds-arena-mobile-2026-10-23.rbxm` | 1038080 bytes | Arena com correções, HUD mobile e seis templates; instalação remota pendente. |
| `artifacts/accessibility-patch.rbxm` | 211572 bytes | Recuperação histórica anterior à base Crossgrounds e ao patch de pegada. |
| `artifacts/camera-experience-patch.rbxm` | 197947 bytes | Estado anterior, de câmera e menus. |
| `artifacts/three-lanes-patch.rbxm` | 129466 bytes | Estado anterior, de mapa, bots e combate. |

Os pacotes são organizados por serviço para recuperação manual. **Não são um place completo nem um instalador automático.** Há 98 fontes locais em `src/`. Cada pacote dedicado atualizado contém 80 fontes de runtime/autoramento; 17 fontes de testes e o Blood legado ficam fora deles. A correção do Blood está aplicada ao projeto integrado e exportada como fonte local. Originais, templates de Get Out e cenário CTF continuam nas instâncias preservadas no Studio; o pacote de Arena inclui os seis templates encontrados no catálogo. Pacotes anteriores permanecem disponíveis.

O último patch foi aplicado e testado no Studio. A publicação ficou manual no encerramento daquela etapa. **Esta exportação não consultou nem confirmou a versão atualmente publicada na Roblox**, portanto o estado de edição não deve ser apresentado como publicação confirmada.

---

**Conclusão:** a base de jogo existe e permite continuar a produção. O maior débito atual está em empunhadura/animações, apresentação de combate, naturalidade dos bots, sonorização completa e validação real de acessibilidade e multiplayer.


**Progresso — atualização em 27/10/2026:** conferido o place principal (4375993208). A tela de estatísticas ganhou cartão compacto de perfil com avatar e progresso de XP, quatro cartões resumidos por modo e a tabela global existente. Arena mostra eliminações e mortes quando os atributos existem; Get Out e Duels indicam indisponibilidade enquanto não houver dados reais por modo; CTF usa capturas registradas no progresso. A página de placar mantém a indicação de que o serviço global ainda não está conectado, sem dados demonstrativos. Fonte atualizada no Studio e sintaticamente compilável via loadstring no editor. Validação visual e de dados em runtime ainda pendente; filtros por modalidade, ranking global e prestígio permanecem pendentes.


### Progresso — implementação das interfaces e sistemas em 27/10/2026

Implementado o plano de `instructions/UI/progression_change.md` nas fontes locais e no editor do place principal **4375993208** (sem publicação confirmada):

- Três páginas próprias: estatísticas pessoais com avatar, nível, moedas, XP, indicadores e cards por modalidade; ranking com filtros de métrica/escopo/modo, Top 100 e linha pessoal fixa; comparativo com seletor de amigos, perfis lado a lado, barras e diferenças numéricas. Mortes e derrotas usam menor valor como vantagem; tempo e moedas têm diferença neutra.
- Contrato compartilhado `ProgressionSchema`: preserva totais históricos e adiciona contadores por modo à persistência existente. Nenhum total legado foi distribuído artificialmente entre modos. Arena registra eliminações/mortes; CTF registra combate, capturas e resultados de equipe; Get Out registra fugas, vitórias por papel e derrotas, com proteção contra resultado duplicado e exclusão de encerramentos técnicos. Tempo por modo é acumulado ao trocar de modalidade, periodicamente e ao sair.
- Serviço de ranking via OrderedDataStore, apenas com valores persistidos: filtros validados no servidor, cache, limitação de consultas e desempate por valor decrescente/ID crescente. Top 100 visível; posição pessoal fora da lista consultada separadamente, incluindo os empates. Consultas podem falhar por limites dos serviços e retornam indisponibilidade explícita.
- Prestígio autorizado pelo servidor, atualizado a cada 180 segundos e revogado quando a consulta não puder ser verificada: Arena por eliminações; Get Out e Duels por vitórias; CTF por capturas. Ouro/prata/bronze via UIGradient no ranking principal do modo, placar/lista de jogadores da partida e identificação sobre o personagem. Efeitos no mundo aparecem somente entre jogadores daquela modalidade; ranking de amigos e Geral não concedem prestígio.
- Proteção de persistência: falha no carregamento não permite gravar um perfil vazio; UI mostra falha/carregamento. Amigos offline e consultas são armazenados temporariamente em cache. Mantido o bloqueio de controles existente no placar do Studio, que estava além da base local.

**Validações realizadas:** os 11 scripts envolvidos compilaram no editor; interface pessoal abriu em Play e foi inspecionada por captura. Teste de integração isolado do serviço em Studio confirmou Arena (eliminações/mortes e totais) e fuga/vitória no Get Out com registro único. As três páginas foram ativadas pelas ações registradas no navegador; estado indisponível do ranking global no Studio e ausência de prestígio foram confirmados. Após corrigir o popup para permanecer dentro da raiz de navegação, teste confirmou foco por controle, ativação de opção e fechamento. Ganchos temporários de teste removidos da fonte final. `git diff --check` realizado. Logs consultados apresentaram mensagens de plugin GUIEditor/ativos externos anteriores; não foi observada nova exceção dos scripts de progresso durante a última execução de UI.

**Limites e validações pendentes:** DataStores de produção e ranking entre servidores não são exercitados no Studio; validar salvamento/reconexão, paginação com muitos perfis e empates, atualização global do prestígio e orçamento de consultas em servidor publicado. Índices históricos são preenchidos quando perfis voltam a carregar/salvar; não houve varredura retroativa de toda a base. Comparativo consulta até 8 amigos com histórico dentre 60 contatos e mostra esse limite. Duels possui contrato de métricas e ponto de entrada servidor para resultados, mas este repositório ainda não possui gameplay de Duels que produza partidas/resultados; nenhum resultado foi inventado. Validar comparação com dois perfis reais, dispositivos móveis e controle físico. A versão final do acumulador de tempo foi compilada, mas não recebeu um teste longo de troca de modos. Backups dos scripts do Studio anteriores à implementação em `artifacts/progression-2026-10-27/before`.


### Configurações — general_interface_overhaul em 27/10/2026

Implementada a instrução `instructions/UI/general_interface_overhaul.md` nas fontes locais e no editor do place principal 4375993208. Os valores padrão, limites, sanitização e persistência continuam nos contratos existentes de ExperienceSettings e PreferenceClient; não foram alterados por este patch.

- Configurações usam cascatas retráteis: níveis anteriores permanecem como barras de ícones, com seleção marcada; apenas navegação contextual e conteúdo ficam expandidos. Em largura reduzida, todos os níveis anteriores continuam visíveis. Transições de 220 ms cancelam tweens anteriores e respeitam redução de movimento. B expande o nível anterior e recupera sua seleção; páginas de conteúdo retêm foco e rolagem por categoria.
- Novo componente reutilizável SettingsCard: um único alvo de navegação por ajuste; ícone, nome/descrição, separador, slider/seletor e valor. Preenchimento, thumb e botões internos não recebem foco pelo controle. Arraste por mouse/toque, seletores, restauração por ponteiro e herança de Global foram preservados. Em escopo de modo, A alterna a personalização/herança; X edita números e Y restaura o card selecionado.
- MenuNavigation estendido, sem sistema paralelo: ações contextuais X/Y, D-pad horizontal, repetição existente, rolagem automática, losango e borda luminosa. LB/RB alternam páginas irmãs; abas no cabeçalho também permitem essa troca por ponteiro. Teclado mantém as setas/Enter/Escape e acrescenta X/Y nos cards compatíveis. Remapeamento de dispositivos continua nas abas próprias.
- Restauração geral de categoria/global/todos os escopos passa por confirmação com cancelar. Tokens de cores de configurações centralizados em MenuTheme.Settings e ícones vetoriais em SettingsVisual. Estilo novo é restrito às configurações; ao voltar à pausa, textos e estilo anteriores são recuperados.

**Validação efetiva em Play:** abrir Analógicos com quatro níveis visíveis; entrada percentual 17 → 0,17; valor 500 limitado ao máximo 0,40; restauração individual ao padrão; recuperação do foco na zona morta direita após trocar de página; cancelamento da confirmação sem reset; 16 trocas rápidas entre irmãos; retorno à pausa com textos; largura simulada de 480 px; B voltando a Controles e focando Analógicos; D-pad alterando apenas o card ativo; Y restaurando apenas esse card. Capturas usadas para revisar layouts horizontal e estreito. Os cinco componentes compilaram. Ganchos temporários de validação removidos da fonte final.

**Pendências/limites:** controle físico Xbox/PlayStation e toque real ainda precisam de uso manual; repetição prolongada do D-pad, aceitar a restauração geral, escopos de modo/dispositivo em servidor publicado e combinação de todos os tamanhos de fonte precisam de validação ampliada. A largura reduzida foi simulada no painel do Studio, sem emulação completa de um aparelho. O cabeçalho final recebeu ajuste textual após os testes e foi compilado. Publicação na Roblox não realizada. Backups local e Studio em `artifacts/settings-overhaul-2026-10-27/`.

### Progressão — fidelidade visual às referências em 27/10/2026

Reformulada a apresentação das três páginas de progressão em `ProgressionPanel.luau` e no novo componente `ProgressionView.luau`, nas fontes locais e no editor do place principal **4375993208**. A navegação em cascata foi substituída por barra lateral fixa e área ampla de conteúdo, com superfícies escuras, bordas turquesa, ícones desenhados com elementos nativos e indicador da página selecionada. Em telas estreitas a navegação passa para uma faixa superior e o conteúdo usa rolagem.

- Estatísticas pessoais: perfil/avatar destacado, nível, vitórias, moedas, barra de XP, oito indicadores no resumo e quatro cartões de modalidade. O cartão da Arena reutiliza uma imagem já existente do projeto; não foram inventadas imagens de mapas para as outras modalidades. O filtro preserva as estatísticas próprias de cada modo.
- Placar: cabeçalho de classificação, filtros, linhas compactas com avatar, coroas nativas e destaque ouro/prata/bronze para os três primeiros, além da linha pessoal fixa. Mantidos os serviços reais, estados de indisponibilidade e as regras existentes de prestígio.
- Amigos: perfis lado a lado com VS, categorias em abas, barras paralelas e diferenças numéricas. Menos mortes/derrotas continua sendo vantagem; tempo e moedas mantêm diferença neutra. O resumo completo de sete métricas cabe na apresentação de desktop testada. Sem contatos elegíveis, o seletor mostra indisponibilidade explicitamente.
- Pausa do lobby: `Continuar` seguido por `Progressão`. O atalho `Jogar / Modalidades` não ocupa mais a posição de loadout no lobby; o catálogo continua disponível no menu principal do lobby. Quando o botão de loadout está disponível fora do lobby, mantém a segunda posição, antes de Progressão. A ordem é explícita por LayoutOrder e a altura considera os botões visíveis. Preservadas as alterações simultâneas da tela de configurações.

**Validações efetivamente realizadas:** compilação dos três scripts no editor; igualdade entre as fontes finais locais e do Studio para ProgressionPanel/ProgressionView; abertura da tela com dados reais da sessão em Play; capturas e revisão das três páginas. Ações registradas no MenuNavigation confirmaram troca de página, abertura do seletor, foco inicial na opção, seleção de modalidade, fechamento do popup e abertura de Progressão pelo menu de pausa. Ordem real dos botões do lobby inspecionada; segunda posição do Loadout confirmada por simulação apenas do escopo de UI de Arena no cliente e restauração para hub. Layouts de 480 e 360 pixels exercitados; linhas compactas da comparação verificadas. Prévia temporária de comparação verificou sete métricas visíveis no desktop, cores de vantagem para mortes/eliminações e neutralidade de moedas/tempo. Prévia temporária de ranking verificou dez linhas, avatares e coroas. `git diff --check` passou. Recursos de validação e dados demonstrativos usados nessas prévias foram removidos da fonte final; não houve gravação de progresso/classificação de teste.

**Limites:** os testes de navegação usaram ações internas registradas no Studio, não um controle físico; validar mouse/toque e controle em dispositivos reais. Rankings globais continuaram retornando a limitação de servidor publicado; comparação entre duas contas reais e persistência/ranking de produção não foram validados nesta alteração visual. Capturas de ranking/comparação preenchidos são prévias de teste isoladas, não evidência de dados reais do serviço. O log consultado manteve avisos de ativo externo e plugin GUIEditor já presentes; não foi observada nova exceção da progressão nos cenários realizados. Aplicado ao editor, sem publicação confirmada. Backups anteriores e verificações em `artifacts/progression-visual-2026-10-27/`.

### Correção do índice global e conferência de dados por modo — 27/10/2026

Investigado o relato no jogo publicado de ranking global vazio com amigos presentes e estatísticas por modalidade zeradas. Confirmado no backup anterior à implementação recente que a persistência original continha apenas totais gerais; os campos separados por modo foram adicionados na implementação recente, não na reforma visual. Não existe informação suficiente nesses perfis antigos para distribuir corretamente os totais históricos entre modalidades.

Corrigido em `ProgressionRanking`: uma indexação bem-sucedida invalida a consulta global em cache e a posição pessoal correspondente, evitando manter uma lista vazia consultada antes da gravação; snapshots novos recebidos enquanto a indexação está em andamento são enfileirados; falhas de escrita deixam diagnóstico no log, em vez de falhar silenciosamente. Em `ProgressionService`, perfis persistidos offline encontrados na consulta de amigos também são enviados ao índice global. Treino da Arena agora atribui XP/alvos tanto ao Geral quanto aos contadores de Arena.

**Validações:** fontes dos dois módulos sincronizadas e compiladas no editor. Teste determinístico com armazenamento simulado confirmou gravação de pontuações, invalidação de cache vazio/pessoal, supressão de gravações repetidas e processamento de snapshot mais recente durante indexação. Teste em Play, apenas na sessão do Studio, confirmou incremento separado de treino/eliminação/morte/XP na Arena; eliminações/capturas/vitórias de CTF; e vitórias/fugas de Get Out, preservando os totais gerais. O teste chamou as APIs do serviço; não constitui uma partida completa de cada modalidade. Sessão encerrada sem persistência em produção. `git diff --check` realizado.

**Pendências e limites:** alterações aplicadas às fontes e ao editor; publicação não realizada nesta tarefa. Confirmar no jogo publicado a gravação nos OrderedDataStores e os novos contadores após partidas reais. Perfis históricos passam a ser indexados quando carregados/salvos ou descobertos pela consulta de amigos; não foi executada uma migração completa de todos os perfis offline. Estatísticas antigas por modalidade continuam indisponíveis, sem inferência artificial. Duels continua dependente de implementação de gameplay. Backups anteriores à correção em `artifacts/progression-ranking-fix-2026-10-27/`.

### CTF — eliminações dos bots e avisos compactos de bandeira — 27/10/2026

Correção aplicada nas fontes locais e no editor do original **Crossgrounds (ALPHA), Place 4375993208**, preservando as alterações simultâneas de progressão, configurações e armamentos fora deste escopo.

- `DamageService` resolve o crédito de morte antes da limpeza e mantém uma trava por Humanoid para impedir dupla contabilização entre dano letal, evento Died e Unwatch. Jogadores continuam recebendo eliminações/progresso pelo caminho existente; bots passam a registrar eliminações e mortes de partida.
- Novo `CTFMatchStats`: participantes de IA identificados por equipe/slot, com eliminações, mortes e capturas preservadas ao trocar de personagem no respawn. BotManager associa o novo corpo ao registro e reinicia os registros na rodada seguinte. Bots retirados para abrir vaga humana deixam o placar. Esses contadores são de partida e não criam perfis persistidos/ranking global para IA.
- StandingsService publica humanos e bots no mesmo placar CTF, com identificação IA. HeldStandings aceita os IDs de participante dos bots e usa AvatarUserId quando disponível, ou imagem local de fallback. Capturas feitas por bot também incrementam sua linha individual; a pontuação de equipe mantém o evento existente.
- Apresentação de bandeiras separada no novo `CTFFlagNotice`. Após a orientação do usuário, o aviso de evento passou de 110+ para **40 px de altura** no tamanho padrão, redução aproximada de **64%**, sem fundo sólido, borda de painel, faixa preenchida de tempo ou terceira linha de instruções. Mantidos ícone pequeno e dois níveis de texto. Indicações persistentes têm **18 px por portador**, também transparentes. Em telas baixas, essas linhas ficam ocultas durante o evento breve para reduzir a ocupação simultânea. A identificação sobre o portador também perdeu o fundo sólido.
- Roubo da própria bandeira tem prioridade imediata sobre avisos enfileirados. Nomes dos bots usam BotAlias nas mensagens e identificação; retornos, quedas e capturas mantêm mensagens por equipe. Contornos de portadores continuam locais aos participantes CTF.

**Validações efetivamente realizadas:** oito fontes compilaram no editor. Script temporário de integração no servidor de Play exerceu Damage:Deal e a resolução de morte: 14 verificações passaram, cobrindo jogador contra IA, IA contra IA, IA contra jogador, incremento único de progresso geral/CTF/BotKills, mortes, rejeição de fogo amigo, chamadas repetidas de resolução/limpeza e preservação das estatísticas após respawn. Captura de bandeira por IA incrementou seu contador. Nova rodada reiniciou os contadores dos 11 bots. O cliente recebeu 12 participantes, sendo 11 IAs; uma prévia controlada do placar, usando o payload real recebido, renderizou as 11 linhas de IA. Eventos reais de posse/roubo/captura foram inspecionados na interface.

**Verificação visual compacta:** simulador Samsung Galaxy A06 em paisagem; orientação do jogo LandscapeSensor, avisos com CoreUISafeInsets; viewport observado **705 × 338**. Medidos 40 px no evento e 18 px na linha persistente, com BackgroundTransparency=1. Captura visual confirmou o formato de ícone/texto sem painel sólido. Houve prévia desktop da primeira apresentação antes da redução solicitada; a revisão compacta foi conferida no simulador móvel. Preferências temporárias, simulação e Play foram encerrados/restaurados; scripts/ganchos de validação ficaram apenas no DataModel de Play e não constam da fonte final. Evidências, roteiro de integração, diff e backups em `artifacts/ctf-kills-alerts-2026-10-27/`.

**Pendências/limites:** testes de crédito chamaram as APIs reais do servidor em sessão controlada; não substituem uma partida longa com disparos reais, vários humanos, latência e aparelhos físicos. O atalho físico do placar e a combinação de todos os tamanhos de fonte/escala não foram revalidados. A prévia do placar forçou sua abertura somente para conferir a renderização dos dados reais; não introduziu participantes ou pontos demonstrativos. Persistência/ranking de produção não foram exercitados. Logs mantiveram avisos de assets/plugins já existentes e registraram duas limitações das chamadas de ferramenta no cliente durante a montagem da prévia; elas não foram incorporadas ao runtime final. Alterações no original permanecem no editor e nas fontes locais; publicação Roblox não realizada nesta tarefa.

### Pausa — restauração de Jogar em 27/10/2026

Restaurado o botão Jogar no menu de pausa do lobby, reutilizando a ação existente de abrir o catálogo do hub. Ordem: Continuar, Progressão, Jogar, Opções, Render-se e Sair. Fora do lobby, Loadout permanece em segundo lugar. Validação: conferência da alteração pontual e `git diff --check`; validação de runtime e sincronização com o Studio pendentes porque a instância anteriormente conectada não está mais disponível.
Complemento: localizada a nova conexão do mesmo place (4375993208); alteração aplicada ao editor e compilação com loadstring confirmada. Validação visual em Play permanece pendente.

### Ícones de configurações — 28/10/2026

Aplicados os atlas fornecidos em `instructions/UI/3/Crossgrounds-IconAtlas.zip` às categorias e às opções individuais de configurações. SettingsVisual agora utiliza ImageLabels com ImageRectOffset/ImageRectSize e tintura do tema; SettingsCard passa o ID exato da preferência, substituindo os desenhos genéricos. Integrados 40 ícones individuais e o mapa de categorias/ações, incluindo restaurar. Atlas enviados ao Roblox: configurações `95339500252717`, menus/categorias `81260305871356`. Originais e mapas preservados em `assets/ui-icons/`. Layout e ações existentes mantidos.

Validação: quatro módulos compilados e sincronizados no editor do place principal; em Play, todos os 40 recortes de configurações conferidos contra o mapa e carregamento dos dois atlas verificado pelo ContentProvider. Interface temporária de validação removida e Play encerrado. `git diff --check` realizado. Publicação da experiência e revisão visual completa de todas as páginas/dispositivos não realizadas.

### Vida dos bots — 28/10/2026

Habilitada a barra nativa de vida dos bots de CTF em BotManager e AvatarService: HealthDisplayType AlwaysOn, alcance de 45 studs e DisplayDistanceType Viewer. Nome nativo oculto para preservar o identificador de equipe existente. A configuração também é reaplicada após carregar o avatar. Fontes locais e editor atualizados; ambos os módulos compilaram via loadstring e `git diff --check` passou. Inspeção visual em partida e publicação pendentes.


### Loadout de Capture a Bandeira — 28/10/2026

Replicada no CTF a apresentação de Armamentos usada na Arena, reutilizando LoadoutMenuView: grade de duas colunas, seleção turquesa, miniaturas e prévia ampliada. O componente recebe a modalidade e acompanha SelectedKit/PendingCTFLoadout no CTF; o mesmo remoto de seleção continua agendando para o próximo nascimento. Nenhuma alteração no equipamento da vida atual ou nas regras dos kits. Os sete loadouts atuais são listados, com rolagem ajustada à quantidade real de linhas; arma principal e melee correspondem a cada kit (faca, Executor, machado, bastão ou martelo), sem fixar o Executor para todos.

Prévia estática compartilhada preparada por LoadoutPreviewService: cria somente modelos ausentes e reutiliza os existentes. Os modelos são sanitizados para apresentação (partes ancoradas, sem scripts/sons/efeitos/juntas). Ao navegar, o mesmo modelo selecionado não é reclonado desnecessariamente. Sem novo loop por frame. Fontes locais e editor do place principal 4375993208 atualizados; backups anteriores em artifacts/ctf-loadout-2026-10-28/before.

Validação: cinco fontes compilaram no Studio; conferidas as prévias principal e secundária dos sete kits de CTF; segunda preparação manteve 18 modelos, sem duplicação. Contrato de seleção diferida preservado, com alteração somente no preparo de prévias da inicialização do serviço. git diff --check realizado. Para limitar processamento, não foi iniciada uma partida de validação; revisão visual em CTF, navegação com controle físico e seleção seguida de renascimento permanecem pendentes. Publicação não realizada.


### Killfeed pessoal e headshot — 28/10/2026

Killfeeds de Arena e CTF compartilham KillFeedView. Eventos do servidor incluem UserIds de atacante/vítima: eliminações locais usam texto maior, negrito, turquesa e borda; mortes locais usam texto maior e laranja/coral. Entradas sem participação local mantêm tamanho menor e cores de equipe. Headshot no killfeed usa uma caveira vetorial laranja, substituindo o texto HEADSHOT; nenhuma imagem externa precisa ser carregada. Limites de linhas, duração e preferência de visibilidade preservados. Arena deixa de reconstruir o texto do feed a cada frame; as linhas são criadas por evento e removidas após o prazo. Preservado o bloqueio Router:IsBlocked que já existia no CombatHUD do editor.

Fontes locais e editor do place principal 4375993208 atualizados. Cinco scripts compilaram. Teste isolado de UI no editor passou para eliminação local, morte local, entrada neutra, presença da caveira e expiração das linhas. git diff --check realizado. Revisão visual em partida e telas menores ainda pendente; publicação não realizada. Backups em artifacts/killfeed-2026-10-28/before.
`n### UI 5 — 31/10/2026`nRefinados estados da Arena e fallback de modelos. A escolhe o preset CTF existente e X abre sua edição. Aplicação no editor pendente: Studio em Play recusou acesso ao datamodel Edit. Compilação e validação pendentes. Validação em partida e respawn pendentes; publicação não realizada.


### UI 5 e reparo do HUD CTF — aplicação de 31/10/2026

Implementação aplicada no editor do place principal 4375993208 e nas fontes locais. Corrigida a codificação dos textos de LoadoutMenuView/GunsmithView. Arena apresenta as seis pistolas da instrução em 2×3, oito ViewportFrames, estados EM USO / PRÓXIMO NASCIMENTO, prévia sem confirmar e confirmação diferida. Somente a apresentação filtra as seis pistolas; definições de armas não foram alteradas. Gunsmith CTF: A solicita salvar/agendar o preset existente, X abre sua edição. Conferido em ArsenalLoadouts que save grava pending e ApplyPending o aplica no nascimento, sem alterar active no momento da escolha.

Corrigidas duas regressões introduzidas na troca do killfeed: CombatHUD percorria entries inexistente e falhava no resize, interrompendo sua inicialização; ArenaHUD tentava escrever Text em um Frame ao trocar de modo. Ambos agora limpam feedView.Rows. HUD CTF também usa o arsenal ativo para nomes/troca dos slots e oferece melee + primária + secundária; queda para o kit legado permanece disponível. Acesso à infraestrutura CTF protegido quando ausente.

Validação: quatro scripts compilaram e foram aplicados. Em Play, CombatHUD abriu em CTF, timer LOBBY atualizado e terceiro slot criado, sem as exceções anteriores nos logs da nova sessão. Teste isolado da Arena em cliente confirmou foco sem envio, ativação única/throttle, espera de atributo pendente, preservação do ativo e destruição de prévias. Teste isolado do Gunsmith confirmou A sem entrar no editor e X abrindo edição, seguido de limpeza. Após restringir a apresentação às seis pistolas, teste final no editor confirmou seis cards, oito ViewportFrames e limpeza. Persistência publicada, partida humana, controle físico e ciclo real de morte/renascimento permanecem pendentes; o contrato do servidor foi conferido por leitura, sem alegar teste de respawn. Publicação não realizada. Backups anteriores em artifacts/ui5-hud-2026-10-31/before. git diff --check realizado.


### Vida e movimentação na espera — 31/10/2026

Investigados vida do CTF e bloqueio após rodada. No início desta investigação, o HUD atual acompanhou uma mudança servidor para 123/200 (123 e 61,5%); o congelamento específico relatado não foi reproduzido. Ainda assim, CombatHUD agora vincula HealthChanged/MaxHealth ao Humanoid atual e reconecta no respawn; atualiza mesmo oculto, sem depender do restante do polling do HUD, e usa MaxHealth real em vez de divisor fixo 200.

Causas de bloqueio identificadas: ControlRouter.CanMove exigia ArenaPlaying, portanto impedia andar em resultados/espera mesmo vivo; ArenaHUD abria votação automaticamente a cada ballot, tornando a espera modal; EliminationSpectator encerrava somente com mudança de personagem, deixando risco de câmera/bloqueio residual se o mesmo personagem voltasse vivo ou chegasse evento atrasado. CanMove agora permite andar vivo na espera, preservando bloqueios de menus, morte, carregamento e regras de ações de combate. Votação continua acessível por botão/atalho, sem abertura forçada. Câmera de eliminação ignora mensagem para personagem já vivo e encerra ao recuperar vida; Snapshot não considera espectador obsoleto um bloqueio em personagem vivo.

Fontes locais e editor principal 4375993208 atualizados; quatro scripts compilaram. Em Play: servidor definiu 80/200 e 150/300, HUD mostrou 80/40% e 150/50%; após LoadCharacterAsync e ajuste de vida para 97, HUD acompanhou 97. Com estados de espera simulados, W produziu MoveDirection=1 em CTF Results e ArenaPlaying=false, sem menu, com deslocamento observado no CTF. Testes isolados da política preservaram bloqueio por menu/espectador. Evento de nova votação simulado confirmou que ArenaVotingOpen não foi forçado. Não foi disputada uma rodada humana completa; persistência de sessão, rede multiplayer e condição exata original de congelamento ainda precisam de acompanhamento. Logs da sessão de teste de vida não apresentaram nova exceção dos componentes alterados; permanecem mensagens de plugin/ativos externos. Play encerrado, publicação não realizada. git diff --check realizado.


### Votação flutuante e UI 4 (Jogar) — 31/10/2026

Implementados nas fontes locais e no editor principal 4375993208:

- Arena: Posto/outpost retirado do catálogo elegível, mantendo as instâncias antigas preservadas. São 14 mapas elegíveis na biblioteca atual. A cada votação, MapVoteOptions sorteia até quatro IDs distintos; ArenaAdapter cria o ballot somente com esse subconjunto e envia as mesmas opções no snapshot. Não há repetição dentro da mesma votação; sorteios de rodadas diferentes podem reutilizar mapas.
- CTF: servidor de votação existente, iniciado na preparação da rodada, conectado ao novo painel. Sorteio limitado a quatro sem duplicatas e validação de voto contra as opções oferecidas. O catálogo atual tem apenas Travessia e Travessia Ampliada, portanto são oferecidas duas escolhas reais, sem inventar quatro mapas.
- FloatingMapVote: painel compartilhado, flutuante, com contador, nomes/imagens quando disponíveis e votos. Aparece passivamente enquanto a votação estiver ativa, sem capturar movimento. Botão/atalho de votação abre interação por controle via MenuNavigation existente; B volta ao modo passivo. Integração reutiliza remotes existentes, com preferência de foco/modal no router. Votação antiga em cascata da Arena não é mais a rota de abertura pública. UI fecha quando outro menu relevante abre ou votação termina.
- UI 4: Jogar em grade 2×2, ordem fixa Arena, CTF, Duels, Get Out; uma coluna em telas estreitas. HubController recebe layout específico para preservar largura e barra lateral sem alterar a cascata global. ModePresentation e ModeSelectGrid reutilizam foco, ações X e rotas HubBridge existentes. A/clique permite entrada somente com canEnter do servidor; X e ação de detalhes por ponteiro atendem também modos indisponíveis. Get Out passou a planned no catálogo, assim como Duels; nenhum sistema do protótipo foi removido.
- Imagens do pacote importadas e referenciadas por IDs reais: Arena 113015463809046, CTF 91634170272364, Duels 97447858799189, Get Out 72478321570256. Fallback escuro mantém textos legíveis durante carregamento. Imagens e scrim têm camadas explícitas; cores da grade usam tokens do tema.

Validação: 14 fontes compilaram no Studio, com refinamentos finais de duas fontes recompilados/sincronizados. Em Play: 100 ballots sorteados com quatro opções únicas, Posto ausente, voto fora da lista rejeitado e vencedor correto; catálogo de Arena confirmado com 14 mapas; Get Out planned. Consulta/voto CTF por remotes retornou duas opções e confirmou o voto. Captura revisada da grade 2×2 com imagens, nomes e disponibilidade; quatro cards sem duplicação. D-pad seguido de X abriu detalhes de Duels. Teste isolado de UI confirmou bloqueio de A em indisponíveis, ação de detalhes, adaptação para uma coluna, vínculos direcionais e limpeza. Get Out ImageLabel confirmou IsLoaded e AssetFetchStatus Success, assim como carregamento observado das demais imagens. Painel de votação da Arena mostrou quatro opções; D-padDown abriu a interação, B a encerrou, e W manteve MoveDirection=1 em modo passivo sem menu.

Limites: teste de voto CTF invocou o serviço em sessão de Studio, não uma rodada multiplayer completa; admissão/quickEntry completo, votação com vários jogadores, empate entre servidores e hardware móvel/console precisam de revisão manual. O primeiro acionamento de M durante a transição de contexto não abriu a interação; no reteste com modo e raiz de navegação estabilizados, M abriu o painel corretamente. D-padDown também confirmado. A mudança final de foco do botão por ponteiro, texto de indisponibilidade/tokens e guard de runtime foram compilados após a rodada de testes, sem nova revisão completa. Nenhuma experiência foi publicada. Backups em artifacts/vote-ui4-2026-10-31/before; git diff --check realizado. Play encerrado.


### UI 6 revisada — Armamentos Create-a-Class — 31/10/2026

Relida e implementada a versão atualizada de instructions/UI/6/Crossgrounds-Armamentos-CreateAClass-Correto, usando 01_referencia/00_create_a_class_referencia.png. Esta direção substitui a proposta 2×3 anterior: lista vertical de presets à esquerda, bloco central de arma principal e compartimento separado para Executor, painel de detalhes à direita. Em largura menor, lista permanece à esquerda e detalhes vão abaixo da prévia. Nenhum slot fictício, perk, anexo, progressão ou estatística foi criado na Arena.

LoadoutMenuView reorganizado mantendo oito ViewportFrames e modelos existentes. As seis pistolas são extraídas dos metadados reais da lista (classe PISTOLA), sem tabela de IDs hardcoded. CTF continua delegando ao GunsmithView, sem alterações deste patch no editor CTF. Foco/inspeção, ativa e pendente são apresentados separadamente; confirmação usa o callback existente, com throttle compartilhado de 0,2 s entre cards e sem indicação otimista. Estados ATIVA/PRÓXIMA VIDA se atualizam somente pelos atributos. Incluídos ajustes de contraste, fontes maiores, fallback de modelo e layout rolável. ExperienceMenu recebeu somente ajuda contextual de Arena e limpeza do componente ao voltar/fechar; demais fluxos preservados. LoadoutService, LoadoutDefinitions e KitDefinitions não foram alterados nesta etapa.

Validações efetivas: duas fontes compilaram e foram aplicadas ao editor principal 4375993208. Teste isolado em Play confirmou foco sem envio, throttle entre cards diferentes, pendência apenas após atributo replicado, ativo preservado, transição sintética para ativo e destruição de componentes. Capturas revisadas em composição larga de 1200 unidades e painel estreito de 480 unidades. Entrada real na Arena por join/enter existente; F2, navegação e A abriram/confirmaram Armamentos. Seleção real de Desert Eagle manteve ativa e Tool Glock 18 da vida atual (referência de Instance preservada); após morte e respawn real, Desert Eagle tornou-se ativa e PendingArenaLoadout foi limpo. Teste final confirmou oito ViewportFrames no menu real; B voltou à pausa e destruiu ArenaLoadout, liberando prévias. Play encerrado. git diff --check realizado. Publicação não realizada.

Diferenças intencionais da arte: não existem acessórios, armas independentes, habilidades, estatísticas ou novas classes. Modelos são os blocados existentes do jogo. Em telas intermediárias/estreitas o painel de detalhes fica abaixo, exigindo rolagem; três regiões lado a lado ficam reservadas a larguras maiores. Alto contraste/fontes maiores receberam tratamento de layout, mas combinações extremas e hardware físico ainda merecem revisão manual.

Uso do Codex consultado após leitura, implementação e testes: saldo semanal começou em 8% e terminou em 6% (94% usado). O limite de parada pedido pelo usuário é saldo semanal de 1% ou menos, não atingido nesta etapa. Backups em artifacts/ui6-create-a-class-2026-10-31/.

### Tentativa de publicação da experiência principal — 31/10/2026

Publicação solicitada explicitamente pelo usuário. Confirmado no editor Crossgrounds (ALPHA), placeId 4375993208, versão 374, em modo Edit. LoadoutMenuView e ExperienceMenu conferidos contra as fontes locais: comprimentos UTF-8 e hashes correspondem, normalizando CRLF. Nenhuma alteração funcional adicional foi feita nesta etapa.

Tentativa de publicar pelo atalho Alt+P no Studio. Não houve confirmação no console e a consulta posterior continuou retornando PlaceVersion 374; portanto a publicação NÃO está confirmada. O controle do computador falhou repetidamente na captura da janela com "window capture timed out: timed out waiting on channel"; tentativa de clique por acessibilidade falhou com "coordinate input geometry is unavailable". Janela reconectada e ativada novamente sem recuperar a captura. Nenhum reinício de servidores foi solicitado ou realizado. Pendente: recuperar a interação com a janela do Studio e concluir/verificar a publicação. As validações anteriores permanecem de Studio, sem teste da nova versão em servidor público.

Uso do Codex consultado: 95% semanal utilizado, saldo 5%; limite de parada de 1% não atingido.

### Comparação visual da UI 6 — 31/10/2026

Nova captura obtida pelo screen_capture do Studio durante Play real, após entrada na Arena e abertura de Loadout por F2/Down/Return. Comparada diretamente com instructions/UI/6/Crossgrounds-Armamentos-CreateAClass-Correto/01_referencia/00_create_a_class_referencia.png. Sem alteração funcional nesta etapa; Play encerrado.

Resultado: semelhança parcial. Lista vertical, foco turquesa, prévia central e Executor separado estão presentes. A barra lateral antiga do menu ocupa uma coluna adicional; presets estreitos e miniaturas pequenas, bloco principal alto, detalhes direitos com grande vazio, título/hierarquia e acabamento de cabeçalhos distantes da referência. Ausência de acessórios, habilidades e estatísticas na Arena é intencional e deve permanecer, mas não justifica as diferenças de proporção e composição. A captura mostra a implementação atual funcionando; não comprova fidelidade visual elevada. Captura exibida na conversa; tentativa de gravar PNG via node_repl rejeitada pelo limite de tamanho de código da revisão automática. Saldo semanal Codex: 5%.

### Polimento Create-a-Class do CTF — 31/10/2026

Implementado nas fontes locais e no editor principal 4375993208. Novo CTFClassOverview compõe exclusivamente a entrada do Gunsmith CTF: cinco classes verticais com número/nome/arma/status, arma principal com prévia ampliada e cinco espaços de acessórios, arma secundária, Executor, duas habilidades reservadas, aparência e painel direito com valores base reais. Habilidades, progressão, aparência e slots não suportados indicam Em breve; controle/mobilidade sem métrica ficam com travessão, sem números inventados. Nenhum novo sistema de habilidade/progressão ou bônus de acessório foi implementado. Slots existentes conectados ao catálogo; boca/cano usa o slot muzzle real.

GunsmithView preserva A/clique para salvar e agendar, X para editar e subpáginas existentes de armas/acessórios/variantes. Foco inspeciona sem salvar. Previews principal/secundária usam o protocolo existente, com fila local de 160 ms entre solicitações para respeitar o limite do servidor, cancelamento de pedidos obsoletos e validação de vida/token antes de clonar. Executor reutiliza LoadoutPreviews. Nenhuma alteração de servidor/estatísticas de combate neste patch. ExperienceMenu amplia somente Armamentos do CTF até 1560 unidades e limpa Gunsmith ao voltar/fechar; Arena e pausa mantêm suas dimensões anteriores.

Validações realizadas: três fontes compilaram; entrada real no CTF em Play, abertura por F2/Down/Return, D-pad + X abriu edição do Loadout 2 (PresetName presente e overview oculto), B retornou. D-pad + A agendou Loadout 3 no servidor, preservando o mesmo Character e as duas instâncias Tool da vida atual, após aguardar a fila de solicitações. Capturas largas revisadas e gravadas em artifacts/ctf-class-polish-2026-10-31/CTF-CreateAClass.png. Teste de largura de conteúdo de 512 unidades confirmou lista acima da arma principal, com 16 unidades de separação, e secundária 10 unidades abaixo da principal; captura estreita revisada, rolagem preservada. Largura restaurada. B ao sair destruiu Gunsmith. Play encerrado. git diff --check passou.

Uma tentativa intermediária de testar navegação com require(MenuNavigation) pelo executor criou um contexto de módulo separado e invalidou a evidência daquele teste; verificação de X/B refeita em sessão nova somente por entradas reais. Um teste intermediário de preservação de Tool atravessou a transição de preparação da rodada; o teste final foi repetido com Character estável e passou. Ajustes finais de rótulos de slots, comparação de estado incluindo acessórios e altura do aviso foram compilados/aplicados após as capturas, sem repetir a sessão completa. Não houve publicação nesta etapa, nem teste em hardware físico, persistência online ou partida multiplayer completa. O resultado aproxima a composição da referência, mantendo os modelos e a barra lateral reais do projeto.

Backups de GunsmithView e ExperienceMenu anteriores a esta etapa em artifacts/ctf-class-polish-2026-10-31/. Uso do Codex consultado durante implementação e validação: saldo semanal terminou em 3% (97% utilizado), acima da parada obrigatória em 1% ou menos.

### UI 7 — Escolha de armas e acessórios — 31/10/2026

Lidos INSTRUCOES-CODEX.md, PLANO-DE-IMPLEMENTACAO.md e as duas referências de instructions/UI/7/Crossgrounds-Acessorios-e-Escolha-de-Armas. Implementadas duas apresentações no fluxo CTF de GunsmithView usando um shell compartilhado ArsenalSelectionView: escolha por categorias reais e grade de armas, com descrição/prévia à direita; acessórios com contexto da arma à esquerda, arma grande no centro superior, faixa horizontal de slots, grade inferior e descrição/compatibilidade à direita. Categorias e itens derivam dos catálogos. Slots futuros são exibidos estruturalmente sem inventar compatibilidade. Cards usam ícones esquemáticos 2D genéricos, não miniaturas individuais. As imagens da referência permanecem uma direção artística; estes ícones e os modelos reais são uma diferença visual explícita.

Integração: trocar primária/secundária abre o catálogo; A escolhe arma funcional para o rascunho e retorna à edição, armas só de prévia não são equipadas; X nos cards abre acessórios. Selecionar acessório compatível altera o rascunho e a prévia, com Equipado na edição. Confirmar acessórios copia para a classe em edição; somente a ação existente de salvar classe envia o agendamento ao servidor para o próximo nascimento. Mantidas ações de restaurar, salvar e carregar presets visuais. Arena e regras de combate não foram modificadas nesta etapa.

Desempenho: um único ViewportFrame grande visível por tela, sem ViewportFrames nos cards. Cache local limitado a quatro modelos no Gunsmith; troca de foco tem debounce de 120 ms e invalidação por geração, com fila existente de 160 ms entre solicitações. Modelos reutilizados são reparentados, sem reconstrução; limpeza destrói cache, componentes e conexões ao encerrar. Não foram acrescentados loops visuais contínuos. Shell adapta para uma coluna e move detalhes abaixo quando a largura não comporta três painéis.

Validações realizadas: as duas fontes compilaram e foram aplicadas ao editor principal 4375993208; git diff --check passou. Primeiro fluxo por ponteiro no menu real abriu a versão inicial de acessórios, com 22 cards e um único viewport efetivamente visível. Após o refinamento da faixa de slots, a automação de entrada por F2/ponteiro ficou inconsistente na sessão (tentativas não abriram o menu); não foi atribuído sucesso a esses passos. Validação final feita em harness isolado de UI em Play CTF, com o módulo real GunsmithView e adaptador mínimo de navegação: equipar optics_g_i_mini_reflex indicou Equipado na edição; confirmar acessórios e escolher arma voltaram ao preset sem alterar CTFArsenalState; catálogo mostrou uma única prévia visível; AK-47 carregou e a mesma Instance de Model foi reutilizada ao sair e reabrir o catálogo. Largura de 540 unidades confirmou uma coluna e detalhes 10 unidades abaixo do catálogo. Destroy removeu a interface; Play encerrado e nenhum harness ficou nas fontes/Edit.

Capturas reais do harness em artifacts/ui7-2026-10-31/escolha-de-armas.png e acessorios.png. Backup anterior em GunsmithView-before.luau. Pendências: teste ponta a ponta por controle no menu real após o refinamento final, hardware físico, combinações extremas de fonte/escala, seleção/salvamento com múltiplos jogadores e perfil de custo em dispositivo móvel. Nenhuma publicação nesta etapa. Não declarar fidelidade visual total ou todas as rotas validadas somente com o harness.

Uso do Codex consultado em cada etapa grande: começou com saldo semanal de 3%; última consulta antes do registro indicou 2% (98% usado). A parada deve ocorrer em 1% restante ou menos, conforme reforçado pelo usuário.
