# Get Out — rascunho de implementação v0.4

**Revisão:** 23/10/2026, v0.4. **Estado:** plano técnico; Get Out continua indisponível no catálogo. Este documento não aprova parâmetros marcados como pendentes nem ativa mapas, rotas ou filas.

## Fontes e precedência

1. As decisões do criador registradas em [`GET-OUT-DESIGN-v0.4.md`](../GET-OUT-DESIGN-v0.4.md) e no [`GetOutConfig.luau` versão 2](../Crossgrounds-ModeConfigs/Crossgrounds-ModeConfigs/GetOutConfig.luau) são a base de regras. A [v0.3](../GET-OUT-DESIGN-v0.3.md) foi preservada. O [`GetOutConfig.luau`](../GetOutConfig.luau) da raiz é a versão 1 e está defasado quanto ao sorteio de rota, à fase de fúria e ao Hacker.
2. [`MAPAS-E-IMPORTACAO.md`](MAPAS-E-IMPORTACAO.md) descreve o contrato atual dos cenários preparados. A inspeção do Studio nesta revisão confirmou nove templates em `ServerStorage.CrossgroundsMaps.GetOut`, todos com `Sanitized=true`, `Enabled=true` e 24 spawns neutros. Esses atributos indicam apenas disponibilidade de geometria para o importador; não certificam gameplay de Get Out.
3. Como referência de gênero, [a descrição do jogo original](https://www.roblox.com/games/893973440/Flee-the-Facility) resume fugir da Besta e liberar saídas. O [histórico publicado pelo criador](https://devforum.roblox.com/t/flee-the-facility-change-log-71820/680486) documenta alterações de objetivos, portas e captura; as [regras atuais do jogo](https://devforum.roblox.com/t/flee-the-facility-game-rules/3941301) tratam camping e colaboração indevida como problemas de partida. O ciclo de hack, perseguição, pods e resgate é descrito em detalhe na [wiki comunitária de Flee the Facility](https://flee-the-facility.fandom.com/wiki/Home). Essas fontes inspiram legibilidade e contrajogo; os números e finais próprios do Get Out seguem os rascunhos do Crossgrounds.

## Visão jogável

Get Out é uma partida assimétrica com sobreviventes e uma Besta. Na variante Clássica, o servidor escolhe **uma** rota de fuga compatível com o mapa no começo da rodada. Os sobreviventes concluem essa rota e escapam individualmente; durante a fase final também podem conter a Besta. A Besta persegue, captura e impede a fuga. A rodada tem 600 s normais mais 300 s com Besta enfurecida e instável. A contenção só pode começar nos últimos 300 s e não aparece como objetivo explícito no HUD. Ao completar 900 s, sobreviventes ainda dentro são eliminados; não há empate de gameplay.

Cada sobrevivente mantém um resultado individual: `escaped`, `beast_contained`, `captured` ou `eliminated_at_timeout`. Um jogador já escapado não perde esse resultado porque outro foi capturado depois. Um jogador capturado não passa a ter fuga retroativa se alguém contiver a Besta. Desconexão e cancelamento técnico devem ser estados administrativos separados dos quatro resultados, para não conceder vitória artificial.

## Escopo da primeira versão jogável

**Corte vertical recomendado, ainda sujeito à escolha do criador:** Clássico com uma Besta humana, rota **Travas**, um mapa explicitamente preparado, interface para PC/controle/toque e ciclo completo de captura, resgate, fuga e resultados. `Meat Factory` é o primeiro candidato por já estar entre os três mapas inicialmente atribuídos ao modo; `Facility` é alternativa para avaliação de autoria dos marcadores, pois seu original traz mais nomes relacionados a computadores, pods e saídas. Nenhum deles está pronto apenas por existir na biblioteca.

O primeiro corte deve conter toda a partida, inclusive falhas e retorno ao hub, antes de adicionar outra rota. O código deve permitir ampliar para Cofre, Lasers, ferramenta térmica e Demolição sem duplicar o controlador de rodada. Mutação, Infestação e Juggernaut ficam atrás de capacidade e regras próprias; especialmente Juggernaut não herda a lógica de fuga humana da Clássica.

### Estados e transições

| Camada | Estados propostos | Autoridade e condição |
|---|---|---|
| Sessão | `waiting → voting → loading → head_start → active → enraged → results → cleanup` | O servidor inicia e encerra cada transição; `active` dura até o marco de 600 s, `enraged` até 900 s, salvo resolução anterior. A duração de votação e vantagem inicial da Besta ficam pendentes. |
| Sobrevivente | `active → downed → dragged → pod → rescued/returned`, ou `escaped/captured/eliminated_at_timeout` | Cada transição exige personagem, papel, proximidade e objeto válidos. O fluxo exato de captura, sangramento/congelamento e resgate é uma proposta de implementação inspirada no jogo de referência, não uma regra numérica aprovada. |
| Besta | `active → contained` ou resultado de rodada | Não tratar a Besta como sobrevivente; a contenção só é elegível em `enraged`. |
| Objetivo | `locked → in_progress → complete → exit_open` | Uma única implementação de rota recebe eventos validados. Depois que uma saída abre, rollback de PC não pode fechá-la sem uma regra expressa. |

O servidor fixa `roundId`, `mapId`, `variantId`, `routeId`, horário de início, participantes, papéis e resultados. Cada pedido do cliente inclui a rodada observada; requisições antigas são recusadas. Mudança de papel, morte, retorno ao hub e desconexão invalidam interações em andamento.

## Mapas: conteúdo disponível e preparação necessária

A inspeção do Studio encontrou nove originais em `CrossgroundsMapSources.GetOut`: `Backrooms`, `Office`, `Meat Factory`, `Shopping Center`, `Abandoned Facility`, `Facility`, `Farmland`, `Hotel` e `Construct`. Todos possuem template preparado em `CrossgroundsMaps.GetOut` com 24 spawns genéricos. Os originais não são o runtime: o importador remove scripts, prompts e interações legadas das cópias jogáveis. `Meat Factory` possui 16 scripts no original; `Facility` 49; `Shopping Center` 53. Seus comportamentos não devem ser reativados como atalho.

Contagem de nomes é apenas pista para trabalho manual: `Facility` e `Shopping Center` têm peças nomeadas como computadores, teclados, pods e saídas; `Meat Factory` tem teclados, pods e saídas; `Backrooms` e `Office` não apresentam esses nomes. Modelos podem conter peças sem função ou com nomes genéricos. A inspeção não validou conexões entre salas, espaços de captura, duas saídas operáveis nem acessibilidade física das rotas.

Cada mapa jogável precisa de um **manifesto autorado** em uma pasta própria do template, separado da geometria importada. Não deduzir capacidades pelo nome de `Part` ou pela quantidade de spawns. Contrato sugerido:

```text
CrossgroundsMaps/GetOut/<mapId>
  Geometry/                cenário estático sanitizado
  Spawns/                  candidatos genéricos existentes
  GetOut/                  novos marcadores autorados e revisados
    BeastSpawn             1 ponto livre e distante dos sobreviventes
    SurvivorSpawns/        pontos livres e distribuídos
    ExitDoors/             2 portas e zonas de fuga verificáveis
    FreezePods/            pontos de captura e resgate
    Computers/             4 PCs com IDs únicos para Travas/Cofre
    Locks/                 4 travas para Travas
    Cranks/                interações nas saídas para Travas
    Vault/                 disco e saída para Cofre, se habilitado
    SecurityPanels/        4 painéis para Lasers, se habilitado
    LaserBeams/            4 feixes vinculados aos painéis
    Containers/            pontos de peças, se rota de ferramenta
    Workbench/             bancada, se rota de ferramenta
    SealedDoor/            porta final para ferramenta/Demolição
    Containment/           pontos cênicos e de interação, se suportado
```

O manifesto lista `SupportedRoutes` explicitamente. `Validate(map, route)` confere quantidade, IDs únicos, objetos presentes, espaço livre e vínculos (painel→feixe, PC→dígito, porta→zona de fuga). Falha de qualquer exigência remove **aquela rota** do sorteio; se não sobrar rota, o mapa não entra na votação. Uma cópia com geometria válida e 24 spawns continua inelegível até ter marcadores de papel e objetivos. A seleção aleatória ocorre somente após validar o mapa carregado. Peso igual ou pesos por mapa permanecem pendentes; o código admite ambos, mas não publica ponderação como regra definida.

## Contrato das cinco rotas

| Rota | Preparação do mapa | Progressão no servidor | Saída |
|---|---|---|---|
| **Travas** | 4 PCs, 4 travas, 2 portas, manivelas | Cada PC concluído conta uma vez; quatro conclusões liberam o conjunto de travas. | Jogador opera manivela longa; porta aberta permite travessia individual. Associação travas/portas e duração pendentes. |
| **Cofre** | 4 PCs com slots de dígito, cofre com disco rotativo | Cada PC revela um dígito distinto. A combinação final só é montada/ativada após os quatro; antes disso nenhuma tentativa é válida. Erro posterior bloqueia entrada por 30 s. | Código correto abre a saída. Ordem dos dígitos pendente. |
| **Lasers** | 4 feixes letais e painéis vinculados | Cada painel resolvido desativa exatamente um feixe. Qualquer personagem que tocar feixe ativo morre instantaneamente, conforme regra definida. | Após quatro feixes desligados, travessia segura. Catálogo de puzzles pendente; três minijogos do v0.3 são propostas. |
| **Ferramenta térmica** | Containers, peças, bancada e porta lacrada | Peças rastreadas pelo servidor; portadores necessários se reúnem e montam a ferramenta. | Um portador corta/derrete bordas, porta cai, sobreviventes atravessam. Tipo e quantidades pendentes. |
| **Demolição** | Containers, bancada, porta e ponto de plantio | Recursos fictícios de jogo são reunidos e viram carga; plantio validado inicia 15 s. | Porta é destruída após a contagem. Regras de interrupção, alcance e número de cargas pendentes. |

As cinco rotas compartilham a interface `CanStart(mapManifest)`, `Start(round)`, `HandleAction(player, objectId, payload)`, `Snapshot(player)` e `Close()`. O controlador da rodada recebe somente eventos de conclusão, nunca dados de progresso escritos pelo cliente. Objetos de rotas não sorteadas podem permanecer como cenário, mas não aceitam interações de missão.

## Besta, contenção e variantes

**Hacker definido:** em Travas/Cofre, reverte hack de PC(s) com recarga de 150 s; alvo e extensão do rollback são pendentes. Nas outras três rotas, emite EMP circular expansivo por cinco pulsos de 2 s (10 s ao todo) com recarga de 180 s para localizar objetos metálicos. Alcance, audiência, duração da marcação e efeito além da detecção são pendentes. A habilidade consulta `routeId` da rodada, não a existência casual de PCs no mapa.

**Contenção definida apenas como desfecho:** elegível em `enraged`, independente da rota, sem instrução explícita no HUD. A sequência de dois quadros, câmara e alavanca do v0.3 é **proposta não aprovada**. Antes de implementar, autorar uma interação que dê pistas ambientais, risco para ambos os lados e condição de fechamento verificável no servidor. Se o mapa não tiver cenário compatível, a contenção não pode ser anunciada como disponível nele; a regra de aplicabilidade por mapa precisa de decisão.

**Variantes especiais definidas conceitualmente:** Mutação tem 7 jogadores (6 sobreviventes, 1 Besta), poderes de Besta combinados e antídoto alternativo; Infestação tem 5 jogadores, converte capturados em Bestas Corredoras e beneficia sobreviventes restantes; Juggernaut tem 9 jogadores, um Exorcista contra 8 Bestas. Os valores, condições de vitória e a aplicação das cinco rotas às variantes ainda não estão fechados. A fila `get_out_special` não deve reunir 9 jogadores e depois descartar excedentes por sortear variante de 5 ou 7. A estratégia de escolha/voto precisa ser decidida antes da fila jogável.

## Integração com a base Crossgrounds

1. **Biblioteca:** estender `MapLibrary` com validação de manifesto Get Out, sem alterar o importador de originais por inferência automática. Conservar `CrossgroundsMapSources` como fonte editável e `CrossgroundsMaps` como cópia de jogo.
2. **Sessão:** criar `GetOutAdapter` no padrão `ArenaAdapter`/`CTFAdapter`, com `IsAvailable`, `Snapshot`, `Enter`, `Leave`, `Start` e limpeza de mapa. Atualizar `PlayerContext` para aceitar `get_out` e manter personagem, câmera, equipe e ferramentas segregados. O `SessionCoordinator` registra o adaptador e só remove `planned` de `GameCatalog` depois do corte vertical completo.
3. **Rota de Place:** `TravelService` e `CrossgroundsConfiguration` ganham destino Get Out apenas quando houver Place de teste configurado; o protótipo combinado pode usar rota local explicitamente habilitada. Não ativar teleporte pela existência de um ID.
4. **Interação:** um serviço no servidor valida `roundId`, papel, distância, linha de visão quando pertinente, estado do objeto, tempo e repetição. Cliente usa `InteractionController`/`ControlRouter` e UI com foco navegável; disco e puzzles precisam funcionar com D-pad, teclado e toque sem texto livre ou arrastar obrigatório.
5. **Apresentação:** HUD mostra fase, tempo, método de fuga escolhido, progresso que o papel pode conhecer, estado de aliados e pistas de captura. A contenção não ganha marcador de objetivo. O placar de resultados usa estados individuais; espectadores não podem transmitir informação privilegiada à Besta.
6. **Recompensas:** eventos finais e ações válidas saem do servidor para a progressão geral; repetir prompt, treinar ou abandonar não concede progresso. A versão local `src/` do projeto e o Studio precisam ser reconciliados antes de integrar esse serviço, pois há trabalho recente de progressão feito diretamente no Studio.

## Ordem de construção e critérios de pronto

1. **Manifesto de um mapa:** autorar pontos de papel, quatro PCs, quatro travas, duas portas, manivelas, pods e limites. Validar navegação, esconderijos/aberturas, zonas de colisão e spawns em jogo com mais de um humano. Registrar capacidades faltantes dos outros oito mapas sem classificá-los como prontos.
2. **Rodada Clássica:** implementar estados, escolha de Besta, entrada/saída, relógio de 900 s, neutralização de ferramentas de outros modos, captura e resgate. Testar desconexão da Besta, sobrevivente em pod, jogador que volta ao hub e resultado individual persistido na sessão.
3. **Travas:** implementar hack e manivela no servidor, progressão cooperativa, abertura e fuga individual. Testar duas portas, ações simultâneas, interrupção e remotos adulterados. Não usar scripts importados dos modelos.
4. **Fúria e contenção:** adicionar a fase de 300 s e a condição alternativa somente após decidir o mecanismo. Verificar a fronteira exata de 600/900 s, captura simultânea com fuga e ausência de empate.
5. **Demais rotas:** adicionar uma por vez, com manifesto e percurso completo em pelo menos um mapa antes de marcá-la elegível. Só depois avaliar votação, pesos e expansão para mapas adicionais.
6. **Especial:** fechar estratégia de fila e regras próprias de cada variante; construir e validar separadamente. Não reutilizar automaticamente Travas ou contenção em Juggernaut.

**Porta de liberação do catálogo:** um modo só passa de `planned` para `prototype` quando há ao menos um mapa validado, rodada completa, retorno limpo ao hub, controles nos três tipos de entrada, resultados por jogador e teste multiplayer humano. Geometria e spawns genéricos não satisfazem essa porta.

## Refinamento visual das armas e ferramentas

O trabalho visual das armas atuais de Arena/CTF tem um [plano próprio](WEAPON-VISUAL-REFINEMENT-v0.4.md), com inventário por modelo, ordem de execução, contratos técnicos e critérios de aceite. Get Out usa esse aprendizado de apresentação para sua Besta e seus objetos de rota, conforme a [especificação v0.4](../GET-OUT-DESIGN-v0.4.md), mas depende da definição de seu kit. O primeiro corte jogável exige leitura clara de equipamento, alcance e estados de interação; arte final e variantes cosméticas podem seguir em etapas. Nenhuma peça de Arena/CTF se torna equipamento de Get Out por este plano.

## Decisões necessárias antes de codificar partes específicas

| Tema | Decisão pendente | Pode avançar sem ela? |
|---|---|---|
| Clássico | Lotação final, seleção da Besta, duração da votação e vantagem inicial | Manifesto e arquitetura: sim. Fila pública: não. |
| Travas | Distribuição das quatro travas, duração/manivela por porta | Hack e validação: sim. Saída final: não. |
| Captura | Tempo de imobilização/congelamento, resgate e contrajogo ao camping | Máquina de estados: sim. Balanceamento e resultados: não. |
| Rotas | Pesos do sorteio e elegibilidade por mapa | Estrutura: sim. Votação/ativação: não. |
| Cofre/Lasers | Ordem dos dígitos, catálogo de puzzles e punições | Contratos: sim. UI final: não. |
| Ferramentas | Peças, porte, recuperação, duração e tipo térmico; regras da carga fictícia | Inventário de objetos: sim. Implementação final: não. |
| Hacker | Quanto rollback; alcance e visibilidade do EMP | Separação por rota: sim. Poder jogável: não. |
| Contenção | Mecanismo e disponibilidade por mapa/variante | Fase de fúria: sim. Final secreto: não. |
| Especial | Voto/fila para 5, 7 e 9; vitórias próprias | Clássico: sim. Especial jogável: não. |

Este rascunho preserva as propostas do v0.3 como opções para decisão; nenhuma delas deve ser convertida em regra apenas por estar escrita em arquivo de configuração. O [changelog v0.4](../changelogs/GET-OUT-v0.4.md) registra esta revisão.
